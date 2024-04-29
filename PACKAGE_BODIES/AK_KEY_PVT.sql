--------------------------------------------------------
--  DDL for Package Body AK_KEY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_KEY_PVT" as
/* $Header: akdvkeyb.pls 120.3 2005/09/15 22:18:28 tshort ship $: AKDVKEYB.pls */

--=======================================================
--  Procedure   CREATE_FOREIGN_KEY
--
--  Usage       Private API for creating a foreign key. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a foreign key using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_FOREIGN_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_application_id           IN      NUMBER,
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
p_from_to_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_from_to_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
l_api_version_number  CONSTANT number := 1.0;
l_api_name            CONSTANT varchar2(30) := 'Create_Foreign_Key';
l_attribute_category  VARCHAR2(30);
l_attribute1          VARCHAR2(150);
l_attribute2          VARCHAR2(150);
l_attribute3          VARCHAR2(150);
l_attribute4          VARCHAR2(150);
l_attribute5          VARCHAR2(150);
l_attribute6          VARCHAR2(150);
l_attribute7          VARCHAR2(150);
l_attribute8          VARCHAR2(150);
l_attribute9          VARCHAR2(150);
l_attribute10         VARCHAR2(150);
l_attribute11         VARCHAR2(150);
l_attribute12         VARCHAR2(150);
l_attribute13         VARCHAR2(150);
l_attribute14         VARCHAR2(150);
l_attribute15         VARCHAR2(150);
l_created_by          number;
l_creation_date       date;
l_error               boolean;
l_from_to_description VARCHAR2(1500);
l_from_to_name        VARCHAR2(45);
l_lang                varchar2(30);
l_last_update_date    date;
l_last_update_login   number;
l_last_updated_by     number;
l_return_status       varchar2(1);
l_to_from_description VARCHAR2(1500);
l_to_from_name        VARCHAR2(45);
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

savepoint start_create_foreign_key;

--** check to see if row already exists **
if  AK_KEY_PVT.FOREIGN_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_EXISTS');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(l_api_name || 'Error - Row already exists');
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_database_object_name => p_database_object_name,
p_unique_key_name => p_unique_key_name,
p_application_id => p_application_id,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || 'validation failed');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load non-required columns if their values are given **
if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
end if;

if (p_from_to_name <> FND_API.G_MISS_CHAR) then
l_from_to_name := p_from_to_name;
end if;

if (p_from_to_description <> FND_API.G_MISS_CHAR) then
l_from_to_description := p_from_to_description;
end if;

if (p_to_from_name <> FND_API.G_MISS_CHAR) then
l_to_from_name := p_to_from_name;
end if;

if (p_to_from_description <> FND_API.G_MISS_CHAR) then
l_to_from_description := p_to_from_description;
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

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

select userenv('LANG') into l_lang
from dual;

insert into AK_FOREIGN_KEYS (
FOREIGN_KEY_NAME,
DATABASE_OBJECT_NAME,
UNIQUE_KEY_NAME,
APPLICATION_ID,
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
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_foreign_key_name,
p_database_object_name,
p_unique_key_name,
p_application_id,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--** row should exists before inserting rows for other languages **
if  NOT AK_KEY_PVT.FOREIGN_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) THEN
FND_MESSAGE.SET_NAME('AK','AK_INSERT_FK_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line(G_PKG_NAME || 'Error - First insert failed');
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_FOREIGN_KEYS_TL (
FOREIGN_KEY_NAME,
LANGUAGE,
FROM_TO_NAME,
FROM_TO_DESCRIPTION,
TO_FROM_NAME,
TO_FROM_DESCRIPTION,
SOURCE_LANG,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) select
p_foreign_key_name,
L.LANGUAGE_CODE,
l_from_to_name,
l_from_to_description,
l_to_from_name,
l_to_from_description,
decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
from FND_LANGUAGES L
where L.INSTALLED_FLAG in ('I', 'B')
and not exists
(select NULL
from AK_FOREIGN_KEYS_TL T
where T.FOREIGN_KEY_NAME = p_foreign_key_name
and T.LANGUAGE = L.LANGUAGE_CODE);

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_foreign_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_foreign_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_foreign_key;
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_FOREIGN_KEY;

--=======================================================
--  Procedure   CREATE_FOREIGN_KEY_COLUMN
--
--  Usage       Private API for creating a foreign key column record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a foreign key column record using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key Column columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_FOREIGN_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_foreign_key_sequence     IN      NUMBER,
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
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Foreign_Key_Column';
l_attribute_category     VARCHAR2(30);
l_attribute1             VARCHAR2(150);
l_attribute2             VARCHAR2(150);
l_attribute3             VARCHAR2(150);
l_attribute4             VARCHAR2(150);
l_attribute5             VARCHAR2(150);
l_attribute6             VARCHAR2(150);
l_attribute7             VARCHAR2(150);
l_attribute8             VARCHAR2(150);
l_attribute9             VARCHAR2(150);
l_attribute10            VARCHAR2(150);
l_attribute11            VARCHAR2(150);
l_attribute12            VARCHAR2(150);
l_attribute13            VARCHAR2(150);
l_attribute14            VARCHAR2(150);
l_attribute15            VARCHAR2(150);
l_created_by         number;
l_creation_date      date;
l_error              boolean;
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
l_return_status      varchar2(1);
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

savepoint start_create_key_column;

--** check to see if row already exists **
if  AK_KEY_PVT.FOREIGN_KEY_COLUMN_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_foreign_key_sequence => p_foreign_key_sequence,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load non-required columns if their values are given **
--
if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
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

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

insert into AK_FOREIGN_KEY_COLUMNS (
FOREIGN_KEY_NAME,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
FOREIGN_KEY_SEQUENCE,
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
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_foreign_key_name,
p_attribute_application_id,
p_attribute_code,
p_foreign_key_sequence,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_FOREIGN_KEY_COLUMN',TRUE);
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_key_column;
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_FOREIGN_KEY_COLUMN',TRUE);
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_FOREIGN_KEY_COLUMN;

--=======================================================
--  Procedure   CREATE_UNIQUE_KEY
--
--  Usage       Private API for creating a unique key. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a unique key using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_UNIQUE_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2,
p_application_id           IN      NUMBER,
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
l_attribute_category VARCHAR2(30);
l_attribute1         VARCHAR2(150);
l_attribute2         VARCHAR2(150);
l_attribute3         VARCHAR2(150);
l_attribute4         VARCHAR2(150);
l_attribute5         VARCHAR2(150);
l_attribute6         VARCHAR2(150);
l_attribute7         VARCHAR2(150);
l_attribute8         VARCHAR2(150);
l_attribute9         VARCHAR2(150);
l_attribute10        VARCHAR2(150);
l_attribute11        VARCHAR2(150);
l_attribute12        VARCHAR2(150);
l_attribute13        VARCHAR2(150);
l_attribute14        VARCHAR2(150);
l_attribute15        VARCHAR2(150);
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Unique_Key';
l_created_by         number;
l_creation_date      date;
l_dummy              number;
l_error              boolean;
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
l_return_status      varchar2(1);
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

savepoint start_create_unique_key;

--** check to see if row already exists **
if  AK_KEY_PVT.UNIQUE_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_database_object_name => p_database_object_name,
p_application_id => p_application_id,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
raise FND_API.G_EXC_ERROR;
end if;
end if;

--
-- Load non-required columns if their values are given
if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
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

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

insert into AK_UNIQUE_KEYS (
UNIQUE_KEY_NAME,
DATABASE_OBJECT_NAME,
APPLICATION_ID,
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
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_unique_key_name,
p_database_object_name,
p_application_id,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_unique_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_unique_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_unique_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_UNIQUE_KEY;

--=======================================================
--  Procedure   CREATE_UNIQUE_KEY_COLUMN
--
--  Usage       Private API for creating a unique key column record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a unique key column record using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key Column columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_UNIQUE_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_unique_key_sequence      IN      NUMBER,
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
l_attribute_category VARCHAR2(30);
l_attribute1         VARCHAR2(150);
l_attribute2         VARCHAR2(150);
l_attribute3         VARCHAR2(150);
l_attribute4         VARCHAR2(150);
l_attribute5         VARCHAR2(150);
l_attribute6         VARCHAR2(150);
l_attribute7         VARCHAR2(150);
l_attribute8         VARCHAR2(150);
l_attribute9         VARCHAR2(150);
l_attribute10        VARCHAR2(150);
l_attribute11        VARCHAR2(150);
l_attribute12        VARCHAR2(150);
l_attribute13        VARCHAR2(150);
l_attribute14        VARCHAR2(150);
l_attribute15        VARCHAR2(150);
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Unique_Key_Column';
l_created_by         number;
l_creation_date      date;
l_error              boolean;
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
l_return_status      varchar2(1);
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

savepoint start_create_key_column;

--** check to see if row already exists **
if  AK_KEY_PVT.UNIQUE_KEY_COLUMN_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_unique_key_sequence => p_unique_key_sequence,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
raise FND_API.G_EXC_ERROR;
end if;
end if;

--
-- Load non-required columns if their values are given
--
if (p_attribute_category <> FND_API.G_MISS_CHAR) then
l_attribute_category := p_attribute_category;
end if;

if (p_attribute1 <> FND_API.G_MISS_CHAR) then
l_attribute1 := p_attribute1;
end if;

if (p_attribute2 <> FND_API.G_MISS_CHAR) then
l_attribute2 := p_attribute2;
end if;

if (p_attribute3 <> FND_API.G_MISS_CHAR) then
l_attribute3 := p_attribute3;
end if;

if (p_attribute4 <> FND_API.G_MISS_CHAR) then
l_attribute4 := p_attribute4;
end if;

if (p_attribute5 <> FND_API.G_MISS_CHAR) then
l_attribute5 := p_attribute5;
end if;

if (p_attribute6 <> FND_API.G_MISS_CHAR) then
l_attribute6 := p_attribute6;
end if;

if (p_attribute7 <> FND_API.G_MISS_CHAR) then
l_attribute7:= p_attribute7;
end if;

if (p_attribute8 <> FND_API.G_MISS_CHAR) then
l_attribute8 := p_attribute8;
end if;

if (p_attribute9 <> FND_API.G_MISS_CHAR) then
l_attribute9 := p_attribute9;
end if;

if (p_attribute10 <> FND_API.G_MISS_CHAR) then
l_attribute10 := p_attribute10;
end if;

if (p_attribute11 <> FND_API.G_MISS_CHAR) then
l_attribute11 := p_attribute11;
end if;

if (p_attribute12 <> FND_API.G_MISS_CHAR) then
l_attribute12 := p_attribute12;
end if;

if (p_attribute13 <> FND_API.G_MISS_CHAR) then
l_attribute13 := p_attribute13;
end if;

if (p_attribute14 <> FND_API.G_MISS_CHAR) then
l_attribute14 := p_attribute14;
end if;

if (p_attribute15 <> FND_API.G_MISS_CHAR) then
l_attribute15 := p_attribute15;
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

-- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

insert into AK_UNIQUE_KEY_COLUMNS (
UNIQUE_KEY_NAME,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
UNIQUE_KEY_SEQUENCE,
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
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_unique_key_name,
p_attribute_application_id,
p_attribute_code,
p_unique_key_sequence,
l_attribute_category,
l_attribute1,
l_attribute2,
l_attribute3,
l_attribute4,
l_attribute5,
l_attribute6,
l_attribute7,
l_attribute8,
l_attribute9,
l_attribute10,
l_attribute11,
l_attribute12,
l_attribute13,
l_attribute14,
l_attribute15,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name || ' ' ||
to_char(p_attribute_application_id) || ' "' ||
p_attribute_code || '"');
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name || ' ' ||
to_char(p_attribute_application_id) || ' "' ||
p_attribute_code || '"');
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name || ' ' ||
to_char(p_attribute_application_id) || ' "' ||
p_attribute_code || '"');
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_UNIQUE_KEY_COLUMN;

--=======================================================
--  Procedure   DELETE_FOREIGN_KEY
--
--  Usage       Private API for deleting a foreign key. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a foreign key with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_foreign_key_name : IN required
--                  The name of the foreign key to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_FOREIGN_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_columns_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_FOREIGN_KEY_COLUMNS
where  FOREIGN_KEY_NAME = p_foreign_key_name;
cursor l_get_relations_csr  is
select FLOW_APPLICATION_ID, FLOW_CODE, FROM_PAGE_APPL_ID, FROM_PAGE_CODE,
FROM_REGION_APPL_ID, FROM_REGION_CODE, TO_PAGE_APPL_ID,
TO_PAGE_CODE, TO_REGION_APPL_ID, TO_REGION_CODE
from  AK_FLOW_REGION_RELATIONS
where FOREIGN_KEY_NAME = p_foreign_key_name;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Foreign_Key';
l_attribute_appl_id     NUMBER;
l_attribute_code        VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_flow_application_id   NUMBER;
l_flow_code             VARCHAR2(30);
l_from_page_appl_id     NUMBER;
l_from_page_code        VARCHAR2(30);
l_from_region_appl_id   NUMBER;
l_from_region_code      VARCHAR2(30);
l_return_status         varchar2(1);
l_to_page_appl_id       NUMBER;
l_to_page_code          VARCHAR2(30);
l_to_region_appl_id     NUMBER;
l_to_region_code        VARCHAR2(30);
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

savepoint start_delete_foreign_key;

--
-- error if foreign key to be deleted does not exists
--
if NOT AK_KEY_PVT.FOREIGN_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the foreign key if it is being referenced in any of
-- following tables.
--
-- AK_FOREIGN_KEY_COLUMNS
--
open l_get_columns_csr;
fetch l_get_columns_csr into l_attribute_appl_id, l_attribute_code;
if l_get_columns_csr%found then
close l_get_columns_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_FK_FKC');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_columns_csr;
--
-- AK_FLOW_REGION_RELATIONS
--
open l_get_relations_csr;
fetch l_get_relations_csr into l_flow_application_id, l_flow_code,
l_from_page_appl_id, l_from_page_code,
l_from_region_appl_id, l_from_region_code,
l_to_page_appl_id, l_to_page_code,
l_to_region_appl_id, l_to_region_code;
if l_get_relations_csr%found then
close l_get_relations_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_FK_REL');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_relations_csr;

else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_FOREIGN_KEY_COLUMNS
--
open l_get_columns_csr;
loop
fetch l_get_columns_csr into l_attribute_appl_id, l_attribute_code;
exit when l_get_columns_csr%notfound;
AK_KEY_PVT.DELETE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => l_attribute_appl_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_columns_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_columns_csr;
--
-- AK_FLOW_REGION_RELATIONS
--
open l_get_relations_csr;
loop
fetch l_get_relations_csr into l_flow_application_id, l_flow_code,
l_from_page_appl_id, l_from_page_code,
l_from_region_appl_id, l_from_region_code,
l_to_page_appl_id, l_to_page_code,
l_to_region_appl_id, l_to_region_code;
exit when l_get_relations_csr%notfound;
AK_FLOW_PVT.DELETE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_flow_application_id => l_flow_application_id,
p_flow_code => l_flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => l_from_page_appl_id,
p_from_page_code => l_from_page_code,
p_from_region_appl_id => l_from_region_appl_id,
p_from_region_code => l_from_region_code,
p_to_page_appl_id => l_to_page_appl_id,
p_to_page_code => l_to_page_code,
p_to_region_appl_id => l_to_region_appl_id,
p_to_region_code => l_to_region_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_relations_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_relations_csr;

end if;

--
-- delete foreign key once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_foreign_keys
where  foreign_key_name = p_foreign_key_name;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_foreign_keys_tl
where  foreign_key_name = p_foreign_key_name;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_foreign_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_foreign_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_FOREIGN_KEY;

--=======================================================
--  Procedure   DELETE_FOREIGN_KEY_COLUMN
--
--  Usage       Private API for deleting a foreign key column record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a foreign key column record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_foreign_key_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  The key of the foreign key column record to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_FOREIGN_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Foreign_Key_Column';
l_return_status         varchar2(1);
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

savepoint start_delete_key_column;

--
-- error if foreign key to be deleted does not exists
--
if NOT AK_KEY_PVT.FOREIGN_KEY_COLUMN_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the foreign key column if it is being referenced in any of
-- following tables.
--
-- (currently none - add logic here in the future)
--
null;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- (currently none - add logic here in the future)
--
null;
end if;

--
-- delete foreign key column once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_foreign_key_columns
where  foreign_key_name = p_foreign_key_name
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_FOREIGN_KEY_COLUMN',TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_FOREIGN_KEY_COLUMN;

--=======================================================
--  Procedure   DELETE_UNIQUE_KEY
--
--  Usage       Private API for deleting a unique key. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a unique key with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_unique_key_name : IN required
--                  The name of the unique key to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_UNIQUE_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_columns_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_UNIQUE_KEY_COLUMNS
where  UNIQUE_KEY_NAME = p_unique_key_name;
cursor l_get_fk_csr  is
select FOREIGN_KEY_NAME
from   AK_FOREIGN_KEYS
where  UNIQUE_KEY_NAME = p_unique_key_name;

l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Unique_Key';
l_attribute_appl_id     NUMBER;
l_attribute_code        VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_foreign_key_name      VARCHAR2(30);
l_return_status         varchar2(1);
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

savepoint start_delete_unique_key;

--
-- error if foreign key to be deleted does not exists
--
if NOT AK_KEY_PVT.UNIQUE_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the primary key if it is being referenced in any of
-- following tables.
--
-- AK_UNIQUE_KEY_COLUMNS
--
open l_get_columns_csr;
fetch l_get_columns_csr into l_attribute_appl_id, l_attribute_code;
if l_get_columns_csr%found then
close l_get_columns_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_UK_UKC');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_columns_csr;
--
-- AK_FOREIGN_KEYS
--
open l_get_fk_csr;
fetch l_get_fk_csr into l_foreign_key_name;
if l_get_fk_csr%found then
close l_get_fk_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_UK_FK');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_fk_csr;

else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_UNIQUE_KEYS
--
open l_get_columns_csr;
loop
fetch l_get_columns_csr into l_attribute_appl_id, l_attribute_code;
exit when l_get_columns_csr%notfound;
AK_KEY_PVT.DELETE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => l_attribute_appl_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_columns_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_columns_csr;
--
-- AK_FLOW_REGION_RELATIONS
--
open l_get_fk_csr;
loop
fetch l_get_fk_csr into l_foreign_key_name;
exit when l_get_fk_csr%notfound;
AK_KEY_PVT.DELETE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => l_foreign_key_name,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_fk_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_fk_csr;

end if;

--
-- delete unique key once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_unique_keys
where  unique_key_name = p_unique_key_name;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_unique_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_unique_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_UNIQUE_KEY;

--=======================================================
--  Procedure   DELETE_UNIQUE_KEY_COLUMN
--
--  Usage       Private API for deleting a unique key column record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a unique key column record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_unique_key_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  The key of the unique key column record to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_UNIQUE_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2,
p_override                 IN      VARCHAR2 := 'N'
) is
cursor l_get_fkc_csr is
select fkc.FOREIGN_KEY_NAME, fkc.ATTRIBUTE_APPLICATION_ID,
fkc.ATTRIBUTE_CODE
from   AK_FOREIGN_KEY_COLUMNS fkc,
AK_FOREIGN_KEYS fk,
AK_UNIQUE_KEY_COLUMNS pkc
where  fk.unique_key_name = pkc.unique_key_name
and    fk.foreign_key_name = fkc.foreign_key_name
and    fkc.foreign_key_sequence = pkc.unique_key_sequence
and    pkc.unique_key_name = p_unique_key_name
and    pkc.attribute_application_id = p_attribute_application_id
and    pkc.attribute_code = p_attribute_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Unique_Key_Column';
l_attribute_appl_id     NUMBER;
l_attribute_code        VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_foreign_key_name      VARCHAR2(30);
l_return_status         varchar2(1);
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

savepoint start_delete_key_column;

--
-- error if unique key to be deleted does not exists
--
if NOT AK_KEY_PVT.UNIQUE_KEY_COLUMN_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

-- p_override is set to 'Y' during upload
--
if (p_override = 'N') then
if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the unique key column if it is being referenced in any of
-- following tables.
--
-- AK_FOREIGN_KEY_COLUMNS
--
open l_get_fkc_csr;
fetch l_get_fkc_csr into l_foreign_key_name, l_attribute_appl_id,
l_attribute_code;
if l_get_fkc_csr%found then
close l_get_fkc_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_UKC_FKC');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_fkc_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_FOREIGN_KEY_COLUMNS
--
open l_get_fkc_csr;
loop
fetch l_get_fkc_csr into l_foreign_key_name, l_attribute_appl_id,
l_attribute_code;
exit when l_get_fkc_csr%notfound;
AK_KEY_PVT.DELETE_FOREIGN_KEY_COLUMN(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => l_foreign_key_name,
p_attribute_application_id => l_attribute_appl_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_fkc_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_fkc_csr;
end if; -- /* if p_delete_cascade */
end if; -- /* if p_override */
--
-- delete unique key column once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_unique_key_columns
where  unique_key_name = p_unique_key_name
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_UNIQUE_KEY_COLUMN;

--=======================================================
--  Function    FOREIGN_KEY_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a foreign key with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a foreign key record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a foreign key
--              exists, or FALSE otherwise.
--  Parameters  Foreign Key key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function FOREIGN_KEY_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FOREIGN_KEYS
where FOREIGN_KEY_NAME = p_foreign_key_name;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Foreign_Key_Exists';
l_dummy                   number;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end FOREIGN_KEY_EXISTS;

--=======================================================
--  Function    FOREIGN_KEY_COLUMN_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a foreign key column record with the given key values.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a foreign key column record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a foreign key
--              exists, or FALSE otherwise.
--  Parameters  Foreign Key Column key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function FOREIGN_KEY_COLUMN_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FOREIGN_KEY_COLUMNS
where FOREIGN_KEY_NAME = p_foreign_key_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Foreign_Key_Column_Exists'
;
l_dummy                   number;
begin
open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end FOREIGN_KEY_COLUMN_EXISTS;

--=======================================================
--  Function    UNIQUE_KEY_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a unique key with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a unique key record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a foreign key
--              exists, or FALSE otherwise.
--  Parameters  Unique Key key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function UNIQUE_KEY_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_UNIQUE_KEYS
where UNIQUE_KEY_NAME = p_unique_key_name;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Unique_Key_Exists';
l_dummy                   number;
begin
open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end UNIQUE_KEY_EXISTS;

--=======================================================
--  Function    UNIQUE_KEY_COLUMN_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a unique key column record with the given key values.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a unique key column record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a unique key
--              exists, or FALSE otherwise.
--  Parameters  Unique Key Column key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function UNIQUE_KEY_COLUMN_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_UNIQUE_KEY_COLUMNS
where UNIQUE_KEY_NAME = p_unique_key_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Unique_Key_Column_Exists';
l_dummy                   number;
begin
open l_check_csr;
fetch l_check_csr into l_dummy;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return FALSE;
else
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end UNIQUE_KEY_COLUMN_EXISTS;

--=======================================================
--  Procedure   UPDATE_FOREIGN_KEY
--
--  Usage       Private API for updating a foreign key.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a foreign key using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_FOREIGN_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_unique_key_name          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
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
p_from_to_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_from_to_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
from  AK_FOREIGN_KEYS
where FOREIGN_KEY_NAME = p_foreign_key_name
for   update of DATABASE_OBJECT_NAME;
cursor l_get_tl_row_csr (lang_parm varchar2) is
select *
from  AK_FOREIGN_KEYS_TL
where FOREIGN_KEY_NAME = p_foreign_key_name
and   LANGUAGE = lang_parm
for   update of FROM_TO_NAME;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Update_Foreign_Key';
l_created_by            number;
l_creation_date         date;
l_foreign_key_rec       ak_foreign_keys%ROWTYPE;
l_foreign_key_tl_rec    ak_foreign_keys_tl%ROWTYPE;
l_error                 boolean;
l_lang                  varchar2(30);
l_last_update_date      date;
l_last_update_login     number;
l_last_updated_by       number;
l_return_status         varchar2(1);
l_file_version	  number;
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

savepoint start_update_foreign_key;

select userenv('LANG') into l_lang
from dual;

--** retrieve ak_foreign_keys row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_foreign_key_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Error - Row does not exist');
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** retrieve ak_foreign_keys_tl row if it exists **
open l_get_tl_row_csr(l_lang);
fetch l_get_tl_row_csr into l_foreign_key_tl_rec;
if (l_get_tl_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Error - TL Row does not exist');
close l_get_tl_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_tl_row_csr;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_database_object_name => p_database_object_name,
p_unique_key_name => p_unique_key_name,
p_application_id => p_application_id,
p_from_to_name => p_from_to_name,
p_from_to_description => p_from_to_description,
p_to_from_name => p_to_from_name,
p_to_from_description => p_to_from_description,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || ' validation failed');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_foreign_key_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_foreign_key_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_foreign_key_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_foreign_key_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_foreign_key_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_foreign_key_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_foreign_key_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_foreign_key_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_foreign_key_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_foreign_key_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_foreign_key_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_foreign_key_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_foreign_key_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_foreign_key_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_foreign_key_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_foreign_key_rec.attribute15 := p_attribute15;
end if;
if (p_from_to_name <> FND_API.G_MISS_CHAR) or
(p_from_to_name is null) then
l_foreign_key_tl_rec.from_to_name := p_from_to_name;
end if;

if (p_from_to_description <> FND_API.G_MISS_CHAR) or
(p_from_to_description is null) then
l_foreign_key_tl_rec.from_to_description := p_from_to_description;
end if;

if (p_to_from_name <> FND_API.G_MISS_CHAR) or
(p_to_from_name is null) then
l_foreign_key_tl_rec.to_from_name := p_to_from_name;
end if;

if (p_to_from_description <> FND_API.G_MISS_CHAR) or
(p_to_from_description is null) then
l_foreign_key_tl_rec.to_from_description := p_to_from_description;
end if;

--** - load non-null columns **
if (p_database_object_name <> FND_API.G_MISS_CHAR) then
l_foreign_key_rec.database_object_name := p_database_object_name;
end if;
if (p_unique_key_name <> FND_API.G_MISS_CHAR) then
l_foreign_key_rec.unique_key_name := p_unique_key_name;
end if;
if (p_application_id <> FND_API.G_MISS_NUM) then
l_foreign_key_rec.application_id := p_application_id;
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
       p_db_last_updated_by => l_foreign_key_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_foreign_key_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_FOREIGN_KEYS set
DATABASE_OBJECT_NAME = l_foreign_key_rec.database_object_name,
UNIQUE_KEY_NAME = l_foreign_key_rec.unique_key_name,
APPLICATION_ID = l_foreign_key_rec.application_id,
ATTRIBUTE_CATEGORY = l_foreign_key_rec.attribute_category,
ATTRIBUTE1 = l_foreign_key_rec.attribute1,
ATTRIBUTE2 = l_foreign_key_rec.attribute2,
ATTRIBUTE3 = l_foreign_key_rec.attribute3,
ATTRIBUTE4 = l_foreign_key_rec.attribute4,
ATTRIBUTE5 = l_foreign_key_rec.attribute5,
ATTRIBUTE6 = l_foreign_key_rec.attribute6,
ATTRIBUTE7 = l_foreign_key_rec.attribute7,
ATTRIBUTE8 = l_foreign_key_rec.attribute8,
ATTRIBUTE9 = l_foreign_key_rec.attribute9,
ATTRIBUTE10 = l_foreign_key_rec.attribute10,
ATTRIBUTE11 = l_foreign_key_rec.attribute11,
ATTRIBUTE12 = l_foreign_key_rec.attribute12,
ATTRIBUTE13 = l_foreign_key_rec.attribute13,
ATTRIBUTE14 = l_foreign_key_rec.attribute14,
ATTRIBUTE15 = l_foreign_key_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where foreign_key_name = p_foreign_key_name;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

update AK_FOREIGN_KEYS_TL set
FROM_TO_NAME = l_foreign_key_tl_rec.from_to_name,
FROM_TO_DESCRIPTION = l_foreign_key_tl_rec.from_to_description,
TO_FROM_NAME = l_foreign_key_tl_rec.to_from_name,
TO_FROM_DESCRIPTION = l_foreign_key_tl_rec.to_from_description,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login,
SOURCE_LANG = l_lang
where foreign_key_name = p_foreign_key_name
and   l_lang in (LANGUAGE, SOURCE_LANG);
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('TL Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
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
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;
rollback to start_update_foreign_key;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FOREIGN_KEY_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_foreign_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_foreign_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_FOREIGN_KEY;

--=======================================================
--  Procedure   UPDATE_FOREIGN_KEY_COLUMN
--
--  Usage       Private API for updating a foreign key column.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a foreign key column using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key Column columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_FOREIGN_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_foreign_key_sequence     IN      NUMBER := FND_API.G_MISS_NUM,
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
cursor l_get_row_csr is
select *
from  AK_FOREIGN_KEY_COLUMNS
where FOREIGN_KEY_NAME = p_foreign_key_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
for   update of FOREIGN_KEY_SEQUENCE;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Update_Foreign_Key_Column';
l_created_by            number;
l_creation_date         date;
l_key_column_rec        ak_foreign_key_columns%ROWTYPE;
l_error                 boolean;
l_last_update_date      date;
l_last_update_login     number;
l_last_updated_by       number;
l_return_status         varchar2(1);
l_file_version	  number;
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

savepoint start_update_key_column;

--** retrieve ak_foreign_key_columns row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_key_column_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_foreign_key_sequence => p_foreign_key_sequence,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **
-- (none)

--** - load non-null columns **

if (p_foreign_key_sequence <> FND_API.G_MISS_NUM) then
l_key_column_rec.foreign_key_sequence := p_foreign_key_sequence;
end if;
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_key_column_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_key_column_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_key_column_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_key_column_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_key_column_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_key_column_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_key_column_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_key_column_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_key_column_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_key_column_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_key_column_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_key_column_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_key_column_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_key_column_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_key_column_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_key_column_rec.attribute15 := p_attribute15;
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
       p_db_last_updated_by => l_key_column_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_key_column_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_FOREIGN_KEY_COLUMNS set
FOREIGN_KEY_SEQUENCE = l_key_column_rec.foreign_key_sequence,
ATTRIBUTE_CATEGORY = l_key_column_rec.attribute_category,
ATTRIBUTE1 = l_key_column_rec.attribute1,
ATTRIBUTE2 = l_key_column_rec.attribute2,
ATTRIBUTE3 = l_key_column_rec.attribute3,
ATTRIBUTE4 = l_key_column_rec.attribute4,
ATTRIBUTE5 = l_key_column_rec.attribute5,
ATTRIBUTE6 = l_key_column_rec.attribute6,
ATTRIBUTE7 = l_key_column_rec.attribute7,
ATTRIBUTE8 = l_key_column_rec.attribute8,
ATTRIBUTE9 = l_key_column_rec.attribute9,
ATTRIBUTE10 = l_key_column_rec.attribute10,
ATTRIBUTE11 = l_key_column_rec.attribute11,
ATTRIBUTE12 = l_key_column_rec.attribute12,
ATTRIBUTE13 = l_key_column_rec.attribute13,
ATTRIBUTE14 = l_key_column_rec.attribute14,
ATTRIBUTE15 = l_key_column_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where foreign_key_name = p_foreign_key_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_UPDATED');
FND_MESSAGE.SET_TOKEN('OBJECT','AK_FOREIGN_KEY_COLUMN',TRUE);
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
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
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_key_column;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_FOREIGN_KEY_COLUMN;

--=======================================================
--  Procedure   UPDATE_UNIQUE_KEY
--
--  Usage       Private API for updating a unique key.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a unique key using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_UNIQUE_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
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
cursor l_get_row_csr is
select *
from  AK_UNIQUE_KEYS
where UNIQUE_KEY_NAME = p_unique_key_name
for   update of DATABASE_OBJECT_NAME;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Update_Unique_Key';
l_created_by            number;
l_creation_date         date;
l_unique_key_rec        ak_unique_keys%ROWTYPE;
l_error                 boolean;
l_last_update_date      date;
l_last_update_login     number;
l_last_updated_by       number;
l_return_status         varchar2(1);
l_file_version	  number;
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

savepoint start_update_unique_key;

--** retrieve ak_unique_keys row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_unique_key_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Error - Row does not exist');
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_database_object_name => p_database_object_name,
p_application_id => p_application_id,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || ' validation failed');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load record to be updated to the database **
--** - load non-null columns **

if (p_database_object_name <> FND_API.G_MISS_CHAR) then
l_unique_key_rec.database_object_name := p_database_object_name;
end if;
if (p_application_id <> FND_API.G_MISS_NUM) then
l_unique_key_rec.application_id := p_application_id;
end if;
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_unique_key_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_unique_key_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_unique_key_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_unique_key_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_unique_key_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_unique_key_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_unique_key_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_unique_key_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_unique_key_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_unique_key_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_unique_key_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_unique_key_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_unique_key_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_unique_key_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_unique_key_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_unique_key_rec.attribute15 := p_attribute15;
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
       p_db_last_updated_by => l_unique_key_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_unique_key_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_UNIQUE_KEYS set
DATABASE_OBJECT_NAME = l_unique_key_rec.database_object_name,
APPLICATION_ID = l_unique_key_rec.application_id,
ATTRIBUTE_CATEGORY = l_unique_key_rec.attribute_category,
ATTRIBUTE1 = l_unique_key_rec.attribute1,
ATTRIBUTE2 = l_unique_key_rec.attribute2,
ATTRIBUTE3 = l_unique_key_rec.attribute3,
ATTRIBUTE4 = l_unique_key_rec.attribute4,
ATTRIBUTE5 = l_unique_key_rec.attribute5,
ATTRIBUTE6 = l_unique_key_rec.attribute6,
ATTRIBUTE7 = l_unique_key_rec.attribute7,
ATTRIBUTE8 = l_unique_key_rec.attribute8,
ATTRIBUTE9 = l_unique_key_rec.attribute9,
ATTRIBUTE10 = l_unique_key_rec.attribute10,
ATTRIBUTE11 = l_unique_key_rec.attribute11,
ATTRIBUTE12 = l_unique_key_rec.attribute12,
ATTRIBUTE13 = l_unique_key_rec.attribute13,
ATTRIBUTE14 = l_unique_key_rec.attribute14,
ATTRIBUTE15 = l_unique_key_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where unique_key_name = p_unique_key_name;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
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
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;
rollback to start_update_unique_key;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_KEY_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_unique_key;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_unique_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_UNIQUE_KEY;

--=======================================================
--  Procedure   UPDATE_UNIQUE_KEY_COLUMN
--
--  Usage       Private API for updating a unique key column.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a unique key column using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key Column columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_UNIQUE_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_unique_key_sequence      IN      NUMBER := FND_API.G_MISS_NUM,
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
cursor l_get_row_csr is
select *
from  AK_UNIQUE_KEY_COLUMNS
where UNIQUE_KEY_NAME = p_unique_key_name
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code
for   update of UNIQUE_KEY_SEQUENCE;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Update_Unique_Key_Column';
l_created_by            number;
l_creation_date         date;
l_key_column_rec        ak_unique_key_columns%ROWTYPE;
l_error                 boolean;
l_last_update_date      date;
l_last_update_login     number;
l_last_updated_by       number;
l_return_status         varchar2(1);
l_file_version	  number;
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

savepoint start_update_key_column;

--** retrieve ak_unique_key_columns row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_key_column_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Error - Row does not exist');
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_unique_key_sequence => p_unique_key_sequence,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
--dbms_output.put_line(l_api_name || ' validation failed');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--** Load record to be updated to the database **
--** - load non-null columns **

if (p_unique_key_sequence <> FND_API.G_MISS_NUM) then
l_key_column_rec.unique_key_sequence := p_unique_key_sequence;
end if;
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_key_column_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_key_column_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_key_column_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_key_column_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_key_column_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_key_column_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_key_column_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_key_column_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_key_column_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_key_column_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_key_column_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_key_column_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_key_column_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_key_column_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_key_column_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_key_column_rec.attribute15 := p_attribute15;
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
       p_db_last_updated_by => l_key_column_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_key_column_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_UNIQUE_KEY_COLUMNS set
UNIQUE_KEY_SEQUENCE = l_key_column_rec.unique_key_sequence,
ATTRIBUTE_CATEGORY = l_key_column_rec.attribute_category,
ATTRIBUTE1 = l_key_column_rec.attribute1,
ATTRIBUTE2 = l_key_column_rec.attribute2,
ATTRIBUTE3 = l_key_column_rec.attribute3,
ATTRIBUTE4 = l_key_column_rec.attribute4,
ATTRIBUTE5 = l_key_column_rec.attribute5,
ATTRIBUTE6 = l_key_column_rec.attribute6,
ATTRIBUTE7 = l_key_column_rec.attribute7,
ATTRIBUTE8 = l_key_column_rec.attribute8,
ATTRIBUTE9 = l_key_column_rec.attribute9,
ATTRIBUTE10 = l_key_column_rec.attribute10,
ATTRIBUTE11 = l_key_column_rec.attribute11,
ATTRIBUTE12 = l_key_column_rec.attribute12,
ATTRIBUTE13 = l_key_column_rec.attribute13,
ATTRIBUTE14 = l_key_column_rec.attribute14,
ATTRIBUTE15 = l_key_column_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where unique_key_name = p_unique_key_name
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Row does not exist during update');
raise FND_API.G_EXC_ERROR;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name || ' ' ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
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
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name || ' ' ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_key_column;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name || ' ' ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_key_column;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_UNIQUE_KEY_COLUMN;

--========================================================
--  Function    VALIDATE_FOREIGN_KEY
--
--  Usage       Private API for validating a foreign key. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a foreign key record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Foreign Key columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--========================================================
function VALIDATE_FOREIGN_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_unique_key_name          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_from_to_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_from_to_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN is
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Foreign_Key';
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--** check that key columns are not null and not missing **
if ((p_foreign_key_name is null) or
(p_foreign_key_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'FOREIGN_KEY_NAME');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent object exists
--* (This check can be skipped if called from the download procedure
--*  which have already read the parent object.)
--* (This check is only done if a view name is given, which may not
--*  be the case if called from the Update_Foreign_Key API.)
if (p_caller <> AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
if (p_database_object_name <> FND_API.G_MISS_CHAR) then
if (NOT AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OBJECT_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
end if;
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_unique_key_name is null) or
(p_unique_key_name = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIQUE_KEY_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_application_id is null) or
(p_application_id = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

--** Validate columns **
-- - application ID
if (p_application_id <> FND_API.G_MISS_NUM) then
if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => p_application_id) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - unique_key_name
if (p_unique_key_name <> FND_API.G_MISS_CHAR) then
if (NOT AK_KEY_PVT.UNIQUE_KEY_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_UK_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_unique_key_name);
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Invalid unique key name');
end if;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_FOREIGN_KEY;

--========================================================
--  Function    VALIDATE_FOREIGN_KEY_COLUMN
--
--  Usage       Private API for validating a foreign key column record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a foreign key column record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Foreign Key Column columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--========================================================
function VALIDATE_FOREIGN_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_foreign_key_sequence     IN      NUMBER := FND_API.G_MISS_NUM,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN is
cursor l_check_fk_csr is
select  database_object_name
from    AK_FOREIGN_KEYS
where   FOREIGN_KEY_NAME = p_foreign_key_name;
cursor l_check_seq_csr is
select  1
from    AK_UNIQUE_KEY_COLUMNS pkc, AK_FOREIGN_KEYS fk
where   fk.FOREIGN_KEY_NAME = p_foreign_key_name
and     fk.UNIQUE_KEY_NAME = pkc.UNIQUE_KEY_NAME
and     pkc.UNIQUE_KEY_SEQUENCE = p_foreign_key_sequence;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Foreign_Key_Column';
l_dummy                   NUMBER;
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
l_database_object_name    VARCHAR2(30);
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--** check that key columns are not null and not missing **
if ((p_foreign_key_name is null) or
(p_foreign_key_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'FOREIGN_KEY_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_application_id is null) or
(p_attribute_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_code is null) or
(p_attribute_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent foreign key exists, and retrieve
--   the view name for checking of valid column name below
open l_check_fk_csr;
fetch l_check_fk_csr into l_database_object_name;
if (l_check_fk_csr%notfound) then
close l_check_fk_csr;
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_FK_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_foreign_key_name);
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Parent foreign key does not exist!');
else
close l_check_fk_csr;
-- - verify that the column attribute is a valid object attribute
if (NOT AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => l_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OA_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', l_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_foreign_key_sequence is null) or
(p_foreign_key_sequence = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'FOREIGN_KEY_SEQUENCE');
FND_MSG_PUB.Add;
end if;
end if;

--** check that the foreign_key_sequence should be referencing   *
--** some valid unique key columns                              *
--** (Check this only if a foreign_key_sequence value is passed) *
if (p_foreign_key_sequence <> FND_API.G_MISS_NUM) then
open l_check_seq_csr;
fetch l_check_seq_csr into l_dummy;
if (l_check_seq_csr%notfound) then
close l_check_seq_csr;
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_FOREIGN_KEY_SEQ');
FND_MESSAGE.SET_TOKEN('SEQUENCE', to_char(p_foreign_key_sequence));
FND_MSG_PUB.Add;
end if;
else
close l_check_seq_csr;
end if;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_FOREIGN_KEY_COLUMN;

--========================================================
--  Function    VALIDATE_UNIQUE_KEY
--
--  Usage       Private API for validating a unique key. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a unique key record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Unique Key columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--========================================================
function VALIDATE_UNIQUE_KEY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_database_object_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN is
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Unique_Key';
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--** check that key columns are not null and not missing **
if ((p_unique_key_name is null) or
(p_unique_key_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIQUE_KEY_NAME');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent object exists
--* (This check can be skipped if called from the download procedure
--*  which have already read the parent object.)
--* (This check will only be done if a view name is passed.)
if (p_caller <> AK_ON_OBJECTS_PVT.G_DOWNLOAD) then
if (p_database_object_name <> FND_API.G_MISS_CHAR) then
if (NOT AK_OBJECT_PVT.OBJECT_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => p_database_object_name) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OBJECT_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_database_object_name);
FND_MSG_PUB.Add;
end if;
end if;
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_database_object_name is null) or
(p_database_object_name = FND_API.G_MISS_CHAR and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'DATABASE_OBJECT_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_application_id is null) or
(p_application_id = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;


--** Validate columns **
-- - application ID
if (p_application_id <> FND_API.G_MISS_NUM) then
if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => p_application_id) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Invalid application ID');
end if;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_UNIQUE_KEY;

--========================================================
--  Function    VALIDATE_UNIQUE_KEY_COLUMN
--
--  Usage       Private API for validating a unique key column record.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a unique key column record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Unique Key Column columns
--              p_caller : IN required
--                  Must be one of the following values defined
--                  in package AK_ON_OBJECTS_PVT:
--                  - G_CREATE   (if calling from the Create API)
--                  - G_DOWNLOAD (if calling from the Download API)
--                  - G_UPDATE   (if calling from the Update API)
--
--  Note        This API is intended for performing record-level
--              validation. It is not designed for item-level
--              validation.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--========================================================
function VALIDATE_UNIQUE_KEY_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_unique_key_sequence      IN      NUMBER := FND_API.G_MISS_NUM,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN is
cursor l_check_pk_csr is
select  database_object_name
from    AK_UNIQUE_KEYS
where   UNIQUE_KEY_NAME = p_unique_key_name;
cursor l_check_seq_csr is
select  1
from    AK_UNIQUE_KEY_COLUMNS
where   UNIQUE_KEY_NAME = p_unique_key_name
and     UNIQUE_KEY_SEQUENCE = p_unique_key_sequence
and     ( (ATTRIBUTE_APPLICATION_ID <> p_attribute_application_id)
or        (ATTRIBUTE_CODE <> p_attribute_code) );
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Validate_Unique_Key_Column';
l_dummy                   NUMBER;
l_error                   BOOLEAN;
l_return_status           VARCHAR2(1);
l_database_object_name    VARCHAR2(30);
begin

IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;

--** if validation level is none, no validation is necessary
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--** check that key columns are not null and not missing **
if ((p_unique_key_name is null) or
(p_unique_key_name = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIQUE_KEY_NAME');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_application_id is null) or
(p_attribute_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_code is null) or
(p_attribute_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;

-- - Check that the parent unique key exists, and retrieve
--   the database object name for checking of valid column name below
open l_check_pk_csr;
fetch l_check_pk_csr into l_database_object_name;
if (l_check_pk_csr%notfound) then
close l_check_pk_csr;
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_UK_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', p_unique_key_name);
FND_MSG_PUB.Add;
end if;
else
close l_check_pk_csr;
-- - verify that the column attribute is a valid object attribute
if (NOT AK_OBJECT_PVT.ATTRIBUTE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_database_object_name => l_database_object_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_OA_REFERENCE');
FND_MESSAGE.SET_TOKEN('KEY', l_database_object_name ||
' ' || to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
end if;
end if;

--** check that required columns are not null and, unless calling  **
--** from UPDATE procedure, the columns are not missing            **
if ((p_unique_key_sequence is null) or
(p_unique_key_sequence = FND_API.G_MISS_NUM and
p_caller <> AK_ON_OBJECTS_PVT.G_UPDATE))
then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'UNIQUE_KEY_SEQUENCE');
FND_MSG_PUB.Add;
end if;
end if;

--** check that the unique_key_sequence should be unique within *
--** the same unique key                                        *
open l_check_seq_csr;
fetch l_check_seq_csr into l_dummy;
if (l_check_seq_csr%found) then
close l_check_seq_csr;
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
FND_MESSAGE.SET_NAME('AK','AK_UNIQUE_UNIQUE_SEQ');
FND_MESSAGE.SET_TOKEN('SEQUENCE', to_char(p_unique_key_sequence) );
FND_MESSAGE.SET_TOKEN('KEY', p_unique_key_name);
FND_MSG_PUB.Add;
end if;
else
close l_check_seq_csr;
end if;

-- return true if no error, false otherwise
p_return_status := FND_API.G_RET_STS_SUCCESS;
return (not l_error);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
return FALSE;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
return FALSE;

end VALIDATE_UNIQUE_KEY_COLUMN;


--=======================================================
--  Procedure   CHECK_FOREIGN_KEY_SEQUENCE
--
--  Usage       Private API for checking for the existence of
--              a foreign key column record with the given foreign_
--              key_name and foreign_key_sequence. If such a record
--              exists but has attribute_codes or attribute_application
--              id values different from the parameters, the record
--              will be deleted
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a foreign key column record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key Column key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CHECK_FOREIGN_KEY_SEQUENCE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_foreign_key_sequence     IN      NUMBER
) is
cursor l_check_csr is
select ATTRIBUTE_CODE, ATTRIBUTE_APPLICATION_ID
from  AK_FOREIGN_KEY_COLUMNS
where FOREIGN_KEY_NAME = p_foreign_key_name
and   FOREIGN_KEY_SEQUENCE = p_foreign_key_sequence;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Cbeck_Foreign_Key_Sequence';
l_attribute_code                   varchar2(30);
l_attribute_application_id         number;
l_done                             boolean := FALSE;
l_return_status                    varchar(1);
l_msg_data                         VARCHAR2(2000);
l_msg_count                        number;
begin
open l_check_csr;
loop
fetch l_check_csr into l_attribute_code, l_attribute_application_id;
if (l_check_csr%notfound) then
close l_check_csr;
p_return_status := FND_API.G_RET_STS_SUCCESS;
exit;
else
if (l_attribute_code <> p_attribute_code) or
(l_attribute_application_id <> p_attribute_application_id) then
--
-- Delete the record in foreign_key_column that has the same
-- foreign_key_name and foreign_key_sequence, but has different
-- attribute_code or attribute_application_id
--
AK_KEY_PVT.DELETE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => l_attribute_application_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => 'Y'
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_check_csr;
raise FND_API.G_EXC_ERROR;
end if;
end if; -- /* if l_attribute_code */
end if; -- /* if l_check_csr%notfound */
end loop;
if l_check_csr%isopen then
close l_check_csr;
end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;

END CHECK_FOREIGN_KEY_SEQUENCE;


--=======================================================
--  Procedure   DELETE_RELATED_FOREIGN_KEY_COL
--
--  Usage       Private API for deleting foreign key columns.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API deletes foreign key columns from a
--              given foreign_key_name.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_RELATED_FOREIGN_KEY_COL (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_foreign_key_name         IN      VARCHAR2
) is

cursor l_get_columns_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_FOREIGN_KEY_COLUMNS
where  FOREIGN_KEY_NAME = p_foreign_key_name;

l_api_name                 CONSTANT varchar2(30):= 'Delete_Related_Foreign_Key_Col';
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_return_status            VARCHAR2(1);
l_attribute_code           VARCHAR2(30);
l_attribute_appl_id        NUMBER;
i                          NUMBER := 0;
begin

savepoint start_delete_rel_foreign_col;

for csr_rec in l_get_columns_csr loop
AK_KEY_PVT.DELETE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => csr_rec.attribute_application_id,
p_attribute_code => csr_rec.attribute_code,
p_delete_cascade => 'Y'
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
l_attribute_code := csr_rec.attribute_code;
l_attribute_appl_id := csr_rec.attribute_application_id;
raise FND_API.G_EXC_ERROR;
end if;
end loop;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FK_COLUMN_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY',p_foreign_key_name ||
' ' || to_char(l_attribute_appl_id) ||
' ' || l_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_rel_foreign_col;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
-- dbms_output.put_line('Unexpected error:'||substr(SQLERRM,1,240));
rollback to start_delete_rel_foreign_col;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_RELATED_FOREIGN_KEY_COL;

--=======================================================
--  Procedure   DELETE_RELATED_UNIQUE_KEY_COL
--
--  Usage       Private API for deleting foreign key columns.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API deletes foreign key columns from a
--              given foreign_key_name.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_RELATED_UNIQUE_KEY_COL (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_unique_key_name          IN      VARCHAR2
) is

cursor l_get_columns_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_UNIQUE_KEY_COLUMNS
where  UNIQUE_KEY_NAME = p_unique_key_name;

l_api_name                 CONSTANT varchar2(30):= 'Delete_Related_Unique_Key_Col';
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_return_status            VARCHAR2(1);
l_attribute_code           VARCHAR2(30);
l_attribute_appl_id        NUMBER;
begin

savepoint start_delete_rel_unique_col;

for csr_rec in l_get_columns_csr loop
--
-- p_override flag is set to 'Y' here so that only AK_UNIQUE_KEY_COLUMNS
-- get deleted, other references would not be deleted and would not be
-- checked.
AK_KEY_PVT.DELETE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => csr_rec.attribute_application_id,
p_attribute_code => csr_rec.attribute_code,
p_delete_cascade => 'N',
p_override => 'Y'
);

if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
l_attribute_code := csr_rec.attribute_code;
l_attribute_appl_id := csr_rec.attribute_application_id;
raise FND_API.G_EXC_ERROR;
end if;
end loop;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_UK_COLUMN_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('OBJECT', 'AK_UNIQUE_KEY_COLUMN',TRUE);
FND_MESSAGE.SET_TOKEN('KEY',p_unique_key_name ||
' ' || to_char(l_attribute_appl_id) ||
' ' || l_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_rel_unique_col;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_rel_unique_col;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_RELATED_UNIQUE_KEY_COL;

end AK_KEY_PVT;

/
