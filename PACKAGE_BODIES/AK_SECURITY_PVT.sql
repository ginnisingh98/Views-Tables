--------------------------------------------------------
--  DDL for Package Body AK_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_SECURITY_PVT" as
/* $Header: akdvsecb.pls 120.3 2005/09/15 22:18:31 tshort ship $ */

--=======================================================
--  Function    EXCLUDED_ITEM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an attribute with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an attribute record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an attribute
--              exists, or FALSE otherwise.
--  Parameters  Attribute key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function EXCLUDED_ITEM_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_responsibility_id        IN      NUMBER,
p_resp_application_id      IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_application_id IN      NUMBER
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_EXCLUDED_ITEMS
where responsibility_id = p_responsibility_id
and   resp_application_id = p_resp_application_id
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Excluded_Item_Exists';
l_dummy number;
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

end EXCLUDED_ITEM_EXISTS;


--=======================================================
--  Function    RESP_SECURITY_ATTR_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an attribute with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an attribute record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an attribute
--              exists, or FALSE otherwise.
--  Parameters  Attribute key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function RESP_SECURITY_ATTR_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_responsibility_id        IN      NUMBER,
p_resp_application_id      IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_application_id IN      NUMBER
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_RESP_SECURITY_ATTRIBUTES
where responsibility_id = p_responsibility_id
and   resp_application_id = p_resp_application_id
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number      CONSTANT number := 1.0;
l_api_name                CONSTANT varchar2(30) := 'Resp_Security_Attr_Exists';
l_dummy number;
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

end RESP_SECURITY_ATTR_EXISTS;

--=======================================================
--  Procedure   CREATE_EXCLUDED_ITEM
--
--  Usage       Private API for creating an excluded item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an attribute using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_EXCLUDED_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_responsibility_id        IN      NUMBER,
p_resp_application_id      IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE
) is
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Create_Excluded_Item';
l_created_by             number;
l_creation_date          date;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_return_status          varchar2(1);
l_upper_case_flag        VARCHAR2(1) := null;
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


savepoint start_create_excluded_item;

--
-- check to see if row already exists
--
--dbms_output.put_line('Call Excluded_item_exists');
if AK_SECURITY_PVT.EXCLUDED_ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_id => p_responsibility_id,
p_resp_application_id => p_resp_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
--  validate table columns passed in
--
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) then
--
-- Validate all columns passed in
--
--dbms_output.put_line('Call validate_security');
if NOT VALIDATE_SECURITY(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_id => p_responsibility_id,
p_responsibility_appl_id => p_resp_application_id,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE
) then
raise FND_API.G_EXC_ERROR;
end if;
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

--
--  Create record if no validation error was found
--
--   Set WHO columns
--
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

insert into AK_EXCLUDED_ITEMS (
RESPONSIBILITY_ID,
RESP_APPLICATION_ID,
ATTRIBUTE_CODE,
ATTRIBUTE_APPLICATION_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_responsibility_id,
p_resp_application_id,
p_attribute_code,
p_attribute_application_id,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
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
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_excluded_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_excluded_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_excluded_item;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);


end CREATE_EXCLUDED_ITEM;

--=======================================================
--  Procedure   CREATE_RESP_SECURITY_ATTR
--
--  Usage       Private API for creating an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an attribute using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_RESP_SECURITY_ATTR (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_responsibility_id        IN      NUMBER,
p_resp_application_id      IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE
) is
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Create_Resp_Security_Attr';
l_created_by             number;
l_creation_date          date;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_return_status          varchar2(1);
l_upper_case_flag        VARCHAR2(1) := null;
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


savepoint start_create_excluded_item;

--
-- check to see if row already exists
--
if AK_SECURITY_PVT.RESP_SECURITY_ATTR_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_id => p_responsibility_id,
p_resp_application_id => p_resp_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
--  validate table columns passed in
--
if (p_validation_level <> FND_API.G_VALID_LEVEL_NONE) then
--
-- Validate all columns passed in
--
if NOT VALIDATE_SECURITY(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_id => p_responsibility_id,
p_responsibility_appl_id => p_resp_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE
) then
raise FND_API.G_EXC_ERROR;
end if;
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

--
--  Create record if no validation error was found
--
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

insert into AK_RESP_SECURITY_ATTRIBUTES (
RESPONSIBILITY_ID,
RESP_APPLICATION_ID,
ATTRIBUTE_CODE,
ATTRIBUTE_APPLICATION_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN
) values (
p_responsibility_id,
p_resp_application_id,
p_attribute_code,
p_attribute_application_id,
l_creation_date,
l_created_by,
l_last_update_date,
l_last_updated_by,
l_last_update_login
);

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
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
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_excluded_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY',to_char(p_responsibility_id)||
' '||to_char(p_resp_application_id)||
' '||to_char(p_attribute_application_id) ||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_excluded_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_excluded_item;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);


end CREATE_RESP_SECURITY_ATTR;

--=======================================================
--  Procedure   WRITE_RESP_SEC_ATTR_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing one resp sec attribute to
--              the output file. Not designed to be called
--              from outside this package.
--
--  Desc        Appends the single attribute passed in through the
--              parameters to the specified output file. The
--              output will be in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Excluded items record.
--=======================================================
procedure WRITE_RESP_SEC_ATTR_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_resp_sec_attr_rec        IN      ak_resp_security_attributes%ROWTYPE
) is
l_api_name           CONSTANT varchar2(30) := 'Write_Resp_Sec_Attr_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_return_status      varchar2(1);
begin
--
-- Attribute must be validated before it is written to the file
--

if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_SECURITY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_appl_id =>
p_resp_sec_attr_rec.resp_application_id,
p_responsibility_id => p_resp_sec_attr_rec.responsibility_id,
p_attribute_application_id =>
p_resp_sec_attr_rec.attribute_application_id,
p_attribute_code => p_resp_sec_attr_rec.attribute_code,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
--dbms_output.put_line('Responsibility_id ' || to_char(p_resp_sec_attr_rec.responsibility_id)
--			|| ' not downloaded due to validation error');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--
-- Write excluded items record into buffer
--
l_databuffer_tbl.DELETE;
l_index := 1;

l_databuffer_tbl(l_index) := 'BEGIN RESP_SECURITY_ATTRIBUTES ' ||
nvl(to_char(p_resp_sec_attr_rec.responsibility_id),'""') ||' '||
nvl(to_char(p_resp_sec_attr_rec.resp_application_id),'""') ||' '||
nvl(to_char(p_resp_sec_attr_rec.attribute_application_id),'""')||' "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
p_resp_sec_attr_rec.attribute_code)|| '"';
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATED_BY = ' ||
nvl(to_char(p_resp_sec_attr_rec.created_by),'""');
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
to_char(p_resp_sec_attr_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = ' ||
--nvl(to_char(p_resp_sec_attr_rec.last_updated_by),'""');
l_databuffer_tbl(l_index) := '  OWNER = ' ||
FND_LOAD_UTIL.OWNER_NAME(p_resp_sec_attr_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
to_char(p_resp_sec_attr_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = ' ||
nvl(to_char(p_resp_sec_attr_rec.last_update_login),'""');

l_index := l_index + 1;
l_databuffer_tbl(l_index) := 'END RESP_SECURITY_ATTRIBUTES';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

--
-- - Write attribute data out to the specified file
--
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);

--
-- If API call returns with an error status...
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',
to_char(p_resp_sec_attr_rec.attribute_application_id) ||
' ' || p_resp_sec_attr_rec.attribute_code);
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_NOT_DWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY',
to_char(p_resp_sec_attr_rec.attribute_application_id) ||
' ' || p_resp_sec_attr_rec.attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_NOT_DWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY',
to_char(p_resp_sec_attr_rec.attribute_application_id) ||
' ' || p_resp_sec_attr_rec.attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_RESP_SEC_ATTR_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing one excluded item to
--              the output file. Not designed to be called
--              from outside this package.
--
--  Desc        Appends the single attribute passed in through the
--              parameters to the specified output file. The
--              output will be in loader file format.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Excluded items record.
--=======================================================
procedure WRITE_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_excluded_rec             IN      ak_excluded_items%ROWTYPE
) is
l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_lov_object         VARCHAR2(30);
l_return_status      varchar2(1);
begin
--
-- Attribute must be validated before it is written to the file
--
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not VALIDATE_SECURITY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_appl_id =>
p_excluded_rec.resp_application_id,
p_responsibility_id => p_excluded_rec.responsibility_id,
p_attribute_application_id =>
p_excluded_rec.attribute_application_id,
p_attribute_code => p_excluded_rec.attribute_code,
p_caller => AK_ON_OBJECTS_PVT.G_DOWNLOAD)
then
--dbms_output.put_line('Responsibility_id ' || to_char(p_excluded_rec.responsibility_id)
--			|| ' not downloaded due to validation error');
raise FND_API.G_EXC_ERROR;
end if;
end if;

--
-- Write excluded items record into buffer
--
l_databuffer_tbl.DELETE;
l_index := 1;

l_databuffer_tbl(l_index) := 'BEGIN EXCLUDED_ITEMS ' ||
nvl(to_char(p_excluded_rec.responsibility_id),'""') ||' '||
nvl(to_char(p_excluded_rec.resp_application_id),'""') ||' '||
nvl(to_char(p_excluded_rec.attribute_application_id),'""')||' "'||
AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(
p_excluded_rec.attribute_code)|| '"';
-- - Write out who columns
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATED_BY = ' ||
nvl(to_char(p_excluded_rec.created_by),'""');
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
to_char(p_excluded_rec.creation_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = ' ||
--nvl(to_char(p_excluded_rec.last_updated_by),'""');
l_databuffer_tbl(l_index) := '  OWNER = ' ||
FND_LOAD_UTIL.OWNER_NAME(p_excluded_rec.last_updated_by) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
to_char(p_excluded_rec.last_update_date,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = ' ||
nvl(to_char(p_excluded_rec.last_update_login),'""');

l_index := l_index + 1;
l_databuffer_tbl(l_index) := 'END EXCLUDED_ITEMS';
l_index := l_index + 1;
l_databuffer_tbl(l_index) := ' ';

--
-- - Write attribute data out to the specified file
--
AK_ON_OBJECTS_PVT.WRITE_FILE (
p_return_status => l_return_status,
p_buffer_tbl => l_databuffer_tbl,
p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
);

--
-- If API call returns with an error status...
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY',
to_char(p_excluded_rec.attribute_application_id) ||
' ' || p_excluded_rec.attribute_code);
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY',
to_char(p_excluded_rec.attribute_application_id) ||
' ' || p_excluded_rec.attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY',
to_char(p_excluded_rec.attribute_application_id) ||
' ' || p_excluded_rec.attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end WRITE_TO_BUFFER;

--=======================================================
--  Procedure   DOWNLOAD_EXCLUDED
--
--  Usage       Private API for downloading excluded_items. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the attributes selected
--              by application ID or by key values from the
--              database to the output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_attribute_pk_tbl.
--              p_resp_pk_tbl : IN optional
--                  If given, only ICX tables whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_EXCLUDED (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_excluded_pk_tbl          IN      AK_SECURITY_PUB.Resp_PK_Tbl_Type :=
AK_SECURITY_PUB.G_MISS_RESP_PK_TBL,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_resp_1_csr (appl_id_parm number) is
select *
from AK_EXCLUDED_ITEMS
where RESP_APPLICATION_ID = appl_id_parm;
cursor l_get_resp_2_csr (appl_id_parm number, resp_id_parm number) is
select *
from AK_EXCLUDED_ITEMS
where RESP_APPLICATION_ID = appl_id_parm
and RESPONSIBILITY_ID = resp_id_parm;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download Excluded Items';
l_responsibility_found    BOOLEAN;
i number;
l_responsibility_appl_id  NUMBER;
l_excluded_rec            ak_excluded_items%ROWTYPE;
l_return_status           varchar2(1);
l_select_by_appl_id       BOOLEAN;
begin


IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;
--
-- Check that one of the following selection criteria is given:
-- - p_application_id alone, or
-- - attribute_application_id and attribute_code pairs in
--   p_excluded_pk_tbl, or
-- - both p_application_id and p_excluded_pk_tbl if any
--   p_attribute_application_id is missing in p_excluded_pk_tbl
--
if (p_application_id = FND_API.G_MISS_NUM) then
if (p_excluded_pk_tbl.count = 0) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
else
--
-- since no application ID is passed in thru p_application_id,
-- none of the responsibility_appl_id or responsibility_id
-- in table can be null
--

for i in p_excluded_pk_tbl.FIRST .. p_excluded_pk_tbl.LAST LOOP
if (p_excluded_pk_tbl.exists(i)) then
if (p_excluded_pk_tbl(i).responsibility_appl_id = FND_API.G_MISS_NUM) or
(p_excluded_pk_tbl(i).responsibility_id = FND_API.G_MISS_NUM)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_INVALID_LIST');
FND_MESSAGE.SET_TOKEN('ELEMENT_NUM',to_char(i));
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if; /* if responsibility_appl_id is null */
end if; /* if exists */
end LOOP;

end if;
end if;

--
-- selection is by application ID if the excluded items list table is empty
--
if (p_excluded_pk_tbl.count = 0) then
l_select_by_appl_id := TRUE;
else
l_select_by_appl_id := FALSE;
end if;

--
-- Retrieve excluded items from AK_EXCLUDED_ITEMS that fits the selection
-- criteria, one at a time, and write it the buffer table
--
if (l_select_by_appl_id) then
--
-- download by application ID
--
open l_get_resp_1_csr(p_application_id);

loop
fetch l_get_resp_1_csr into l_excluded_rec;
exit when l_get_resp_1_csr%notfound;

WRITE_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_excluded_rec => l_excluded_rec
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_resp_1_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

end loop;
close l_get_resp_1_csr;

else
--
-- download by list of excluded items
--

for i in p_excluded_pk_tbl.FIRST .. p_excluded_pk_tbl.LAST LOOP
if (p_excluded_pk_tbl.exists(i)) then
--
-- default application ID to p_application_id if not given
--
if (p_excluded_pk_tbl(i).responsibility_appl_id = FND_API.G_MISS_NUM) then
l_responsibility_appl_id := p_application_id;
else
l_responsibility_appl_id := p_excluded_pk_tbl(i).responsibility_appl_id;
end if;

--
-- Retrieve attribute and its TL entry from the database
--
l_responsibility_found := TRUE;
open l_get_resp_2_csr(l_responsibility_appl_id,
p_excluded_pk_tbl(i).responsibility_id);
fetch l_get_resp_2_csr into l_excluded_rec;
if (l_get_resp_2_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_EXCL_ITEM_NOT_DOWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(l_responsibility_appl_id) ||
' ' || p_excluded_pk_tbl(i).attribute_code);
FND_MSG_PUB.Add;
end if;
l_responsibility_found := FALSE;
end if;
close l_get_resp_2_csr;

--
-- write excluded items entry to buffer
--
if l_responsibility_found then
WRITE_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_excluded_rec => l_excluded_rec
);
--
-- Download aborts when validation in WRITE_TO_BUFFER fails
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if; /* if l_responsibility_found */
end if; /* if exists(i) */
end loop;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_EXCLUDED;


--=======================================================
--  Procedure   DOWNLOAD_RESP_SEC
--
--  Usage       Private API for downloading resp_attributes. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the attributes selected
--              by application ID or by key values from the
--              database to the output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_attribute_pk_tbl.
--              p_resp_pk_tbl : IN optional
--                  If given, only ICX tables whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_RESP_SEC (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_resp_pk_tbl              IN      AK_SECURITY_PUB.Resp_PK_Tbl_Type :=
AK_SECURITY_PUB.G_MISS_RESP_PK_TBL,
p_nls_language             IN      VARCHAR2
) is
cursor l_get_resp_1_csr (appl_id_parm number) is
select *
from AK_RESP_SECURITY_ATTRIBUTES
where RESP_APPLICATION_ID = appl_id_parm;
cursor l_get_resp_2_csr (appl_id_parm number, resp_id_parm number) is
select *
from AK_RESP_SECURITY_ATTRIBUTES
where RESP_APPLICATION_ID = appl_id_parm
and RESPONSIBILITY_ID = resp_id_parm;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download Resp Sec Attributes';
l_responsibility_found    BOOLEAN;
i number;
l_responsibility_appl_id  NUMBER;
l_resp_rec            ak_resp_security_attributes%ROWTYPE;
l_return_status           varchar2(1);
l_select_by_appl_id       BOOLEAN;
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

--
-- Check that one of the following selection criteria is given:
-- - p_application_id alone, or
-- - attribute_application_id and attribute_code pairs in
--   p_resp_pk_tbl, or
-- - both p_application_id and p_resp_pk_tbl if any
--   p_attribute_application_id is missing in p_resp_pk_tbl
--
if (p_application_id = FND_API.G_MISS_NUM) then
if (p_resp_pk_tbl.count = 0) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
else
--
-- since no application ID is passed in thru p_application_id,
-- none of the responsibility_appl_id or responsibility_id
-- in table can be null
--

for i in p_resp_pk_tbl.FIRST .. p_resp_pk_tbl.LAST LOOP
if (p_resp_pk_tbl.exists(i)) then
if (p_resp_pk_tbl(i).responsibility_appl_id = FND_API.G_MISS_NUM) or
(p_resp_pk_tbl(i).responsibility_id = FND_API.G_MISS_NUM)
then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_INVALID_LIST');
FND_MESSAGE.SET_TOKEN('ELEMENT_NUM',to_char(i));
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if; /* if responsibility_appl_id is null */
end if; /* if exists */
end LOOP;

end if;
end if;

--
-- selection is by application ID if the excluded items list table is empty
--
if (p_resp_pk_tbl.count = 0) then
l_select_by_appl_id := TRUE;
else
l_select_by_appl_id := FALSE;
end if;

--
-- Retrieve excluded items from AK_RESP_SECURITY_ATTRIBUTES that fits the selection
-- criteria, one at a time, and write it the buffer table
--
if (l_select_by_appl_id) then
--
-- download by application ID
--
open l_get_resp_1_csr(p_application_id);

loop
fetch l_get_resp_1_csr into l_resp_rec;
exit when l_get_resp_1_csr%notfound;

WRITE_RESP_SEC_ATTR_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_resp_sec_attr_rec => l_resp_rec
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
close l_get_resp_1_csr;
RAISE FND_API.G_EXC_ERROR;
end if;

end loop;
close l_get_resp_1_csr;

else
--
-- download by list of resp security attributes
--
for i in p_resp_pk_tbl.FIRST .. p_resp_pk_tbl.LAST LOOP
if (p_resp_pk_tbl.exists(i)) then
--
-- default application ID to p_application_id if not given
--
if (p_resp_pk_tbl(i).responsibility_appl_id = FND_API.G_MISS_NUM) then
l_responsibility_appl_id := p_application_id;
else
l_responsibility_appl_id := p_resp_pk_tbl(i).responsibility_appl_id;
end if;

--
-- Retrieve resp security attribute entry from the database
--
l_responsibility_found := TRUE;
open l_get_resp_2_csr(l_responsibility_appl_id,
p_resp_pk_tbl(i).responsibility_id);

fetch l_get_resp_2_csr into l_resp_rec;
if (l_get_resp_2_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_DOES_NOT_EXIS');
FND_MSG_PUB.Add;
FND_MESSAGE.SET_NAME('AK','AK_RESP_SEC_ATTR_NOT_DWNLOADED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(l_responsibility_appl_id) ||
' ' || p_resp_pk_tbl(i).attribute_code);
FND_MSG_PUB.Add;
end if;
l_responsibility_found := FALSE;
end if;
close l_get_resp_2_csr;

--
-- write resp security attribute entry to buffer
--
if l_responsibility_found then
WRITE_RESP_SEC_ATTR_TO_BUFFER(
p_validation_level => p_validation_level,
p_return_status => l_return_status,
p_resp_sec_attr_rec => l_resp_rec
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if; /* if l_responsibility_found */
end if; /* if exists(i) */
end loop;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_RESP_SEC;

--=======================================================
--  Procedure   INSERT_ATTRIBUTE_PK_TABLE
--
--  Usage       Private API for inserting the given attribute's
--              primary key value into the given attribute
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given attribute primary
--              key value into a given attribute table
--              (of type Attribute_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_attribute_application_id : IN required
--                  Application ID of the attribute to be inserted to the
--                  table.
--              p_attribute_code : IN required
--                  Application code of the attribute to be inserted to the
--                  table.
--              p_attribute_pk_tbl : IN OUT
--                  Attribute table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_ATTRIBUTE_PK_TABLE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_pk_tbl         IN OUT NOCOPY  AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Insert_Attribute_PK_Table';
l_index         NUMBER;
begin
--
-- if table is empty, just insert the attribute primary key into it
--
if (p_attribute_pk_tbl.count = 0) then
p_attribute_pk_tbl(1).attribute_appl_id := p_attribute_application_id;
p_attribute_pk_tbl(1).attribute_code := p_attribute_code;
return;
end if;

--
-- otherwise, insert the attribute to the end of the table if it is
-- not already in the table. If it is already in the table, return
-- without changing the table.
--
for l_index in p_attribute_pk_tbl.FIRST .. p_attribute_pk_tbl.LAST loop
if (p_attribute_pk_tbl.exists(l_index)) then
if (p_attribute_pk_tbl(l_index).attribute_appl_id = p_attribute_application_id)
and
(p_attribute_pk_tbl(l_index).attribute_code = p_attribute_code) then
return;
end if;
end if;
end loop;

l_index := p_attribute_pk_tbl.LAST + 1;
p_attribute_pk_tbl(l_index).attribute_appl_id := p_attribute_application_id;
p_attribute_pk_tbl(l_index).attribute_code := p_attribute_code;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end INSERT_ATTRIBUTE_PK_TABLE;

--=======================================================
--  Procedure   UPLOAD_SECURITY
--
--  Usage       Private API for loading attributes from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the attribute data stored in
--              the loader file currently being processed, parses
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
procedure UPLOAD_SECURITY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_index                    IN OUT NOCOPY  NUMBER,
p_loader_timestamp         IN      DATE,
p_line_num                 IN NUMBER := FND_API.G_MISS_NUM,
p_buffer                   IN AK_ON_OBJECTS_PUB.Buffer_Type,
p_line_num_out             OUT NOCOPY    NUMBER,
p_buffer_out               OUT NOCOPY    AK_ON_OBJECTS_PUB.Buffer_Type,
p_upl_loader_cur           IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp
) is
l_api_version_number       CONSTANT number := 1.0;
l_api_name                 CONSTANT varchar2(30) := 'Upload_Security';
l_excluded_items_rec       ak_excluded_items%ROWTYPE;
l_resp_sec_attr_rec        ak_resp_security_attributes%ROWTYPE;
l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
l_column  	             varchar2(30);
l_dummy                    NUMBER;
l_empty_excluded_items_rec ak_excluded_items%ROWTYPE;
l_empty_resp_sec_attr_rec  ak_resp_security_attributes%ROWTYPE;
l_eof_flag                 VARCHAR2(1);
l_line_num                 NUMBER;
l_lines_read               NUMBER;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_more_item                BOOLEAN := TRUE;
l_return_status            varchar2(1);
l_saved_token              AK_ON_OBJECTS_PUB.Buffer_type;
l_state                    NUMBER;       /* parse state */
l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
l_value_count              NUMBER;  /* # of values read for current column */
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return;
END IF;

--dbms_output.put_line('Started security upload: ' ||
--                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

SAVEPOINT Start_Upload;

--
-- Retrieve the first non-blank, non-comment line
--
l_state := 0;
l_eof_flag := 'N';
--
-- if calling from ak_on_objects.upload (ie, loader timestamp is given),
-- the tokens 'BEGIN EXCLUDED_ITEMS' has already been parsed. Set initial
-- buffer to 'BEGIN EXCLUDED_ITEMS' before reading the next line from the
-- file. Otherwise, set initial buffer to null.
--
if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
l_buffer := 'BEGIN ' || p_buffer;
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

--
-- Read tokens from file, one at a time
--
while (l_eof_flag = 'N') and (l_buffer is not null)
and (l_more_item) loop

AK_ON_OBJECTS_PVT.GET_TOKEN(
p_return_status => l_return_status,
p_in_buf => l_buffer,
p_token => l_token
);

--dbms_output.put_line(' State:' || l_state || 'Token:' || l_token || ' -' ||
--                              to_char(sysdate, 'MON-DD HH24:MI:SS'));

if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Error parsing buffer');
raise FND_API.G_EXC_ERROR;
end if;

if (l_state = 0) then
if (l_token = 'BEGIN') then
--== Clear out previous column data  ==--
l_excluded_items_rec := l_empty_excluded_items_rec;
l_resp_sec_attr_rec := l_empty_resp_sec_attr_rec;
l_state := 1;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','BEGIN');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 1) then
if (l_token = 'EXCLUDED_ITEMS') then
l_state := 2;
elsif (l_token = 'RESP_SECURITY_ATTRIBUTES') then
l_state := 32;
else
-- Found the beginning of a non-attribute object,
-- rebuild last line and pass it back to the caller
-- (ak_on_objects_pvt.upload).
p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
l_more_item := FALSE;
end if;
elsif (l_state = 2) then
if (l_token is not null) then
l_excluded_items_rec.responsibility_id := to_number(l_token);
l_state := 3;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','RESPONSIBILITY_ID');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Expecting responsibility ID');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 3) then
if (l_token is not null) then
l_excluded_items_rec.resp_application_id := to_number(l_token);
l_state := 4;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','RESP_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting resp application id');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 4) then
if (l_token is not null) then
l_excluded_items_rec.attribute_application_id := to_number(l_token);
l_state := 5;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting attribute code');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 5) then
if (l_token is not null) then
l_excluded_items_rec.attribute_code := l_token;
l_value_count := null;
l_state := 10;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting attribute code');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 10) then
if (l_token = 'END') then
l_state := 19;
elsif
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
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
if (l_value_count is null) then
FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
else
FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
end if;
FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE');
FND_MSG_PUB.Add;
end if;
--        dbms_output.put_line('Expecting attribute field or END');
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
if (l_column = 'CREATED_BY') then
l_excluded_items_rec.created_by := to_number(l_token);
l_state := 10;
elsif (l_column = 'CREATION_DATE') then
l_excluded_items_rec.creation_date := to_date(l_token,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
l_state := 10;
elsif (l_column = 'LAST_UPDATED_BY') then
l_excluded_items_rec.last_updated_by := to_number(l_token);
l_state := 10;
elsif (l_column = 'OWNER') then
l_excluded_items_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
l_state := 10;
elsif (l_column = 'LAST_UPDATE_DATE') then
l_excluded_items_rec.last_update_date := to_date(l_token,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
l_state := 10;
elsif (l_column = 'LAST_UPDATE_LOGIN') then
l_excluded_items_rec.last_update_login := to_number(l_token);
l_state := 10;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED',l_column);
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting ' || l_column || ' value');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 19) then
if (l_token = 'EXCLUDED_ITEMS') then
if not AK_SECURITY_PVT.EXCLUDED_ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_id =>
l_excluded_items_rec.responsibility_id,
p_resp_application_id =>
l_excluded_items_rec.resp_application_id,
p_attribute_code => l_excluded_items_rec.attribute_code,
p_attribute_application_id=>
l_excluded_items_rec.attribute_application_id) then

-- Insert record into ak_excluded_items if record does not exist
--
AK_SECURITY_PVT.CREATE_EXCLUDED_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_responsibility_id =>
l_excluded_items_rec.responsibility_id,
p_resp_application_id =>
l_excluded_items_rec.resp_application_id,
p_attribute_code => l_excluded_items_rec.attribute_code,
p_attribute_application_id =>
l_excluded_items_rec.attribute_application_id,
p_created_by => l_excluded_items_rec.created_by,
p_creation_date => l_excluded_items_rec.creation_date,
p_last_updated_by => l_excluded_items_rec.last_updated_by,
p_last_update_date => l_excluded_items_rec.last_update_date,
p_last_update_login => l_excluded_items_rec.last_update_login,
p_loader_timestamp => p_loader_timestamp
);
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if; -- /* if EXCLUDED_ITEM_EXISTS */
l_state := 0;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','EXCLUDED_ITEMS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 30) then
if (l_token = 'END') then
l_state := 39;
elsif
(l_token = 'CREATED_BY') or
(l_token = 'CREATION_DATE') or
(l_token = 'LAST_UPDATED_BY') or
(l_token = 'OWNER') or
(l_token = 'LAST_UPDATE_DATE') or
(l_token = 'LAST_UPDATE_LOGIN') then
l_column := l_token;
l_state := 36;
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
FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE');
FND_MSG_PUB.Add;
end if;
--        dbms_output.put_line('Expecting attribute field or END');
raise FND_API.G_EXC_ERROR;
end if;
end if;
elsif (l_state = 32) then
if (l_token is not null) then
l_resp_sec_attr_rec.responsibility_id := to_number(l_token);
l_state := 33;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','RESPONSIBILITY_ID');
FND_MSG_PUB.Add;
end if;
-- dbms_output.put_line('Expecting responsibility ID');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 33) then
if (l_token is not null) then
l_resp_sec_attr_rec.resp_application_id := to_number(l_token);
l_state := 34;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','RESP_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting resp application id');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 34) then
if (l_token is not null) then
l_resp_sec_attr_rec.attribute_application_id := to_number(l_token);
l_state := 35;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting attribute code');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 35) then
if (l_token is not null) then
l_resp_sec_attr_rec.attribute_code := l_token;
l_value_count := null;
l_state := 30;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting attribute code');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 36) then
if (l_token = '=') then
l_state := 37;
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
elsif (l_state = 37) then
l_value_count := 1;
if (l_column = 'CREATED_BY') then
l_resp_sec_attr_rec.created_by := to_number(l_token);
l_state := 30;
elsif (l_column = 'CREATION_DATE') then
l_resp_sec_attr_rec.creation_date := to_date(l_token,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
l_state := 30;
elsif (l_column = 'LAST_UPDATED_BY') then
l_resp_sec_attr_rec.last_updated_by := to_number(l_token);
l_state := 30;
elsif (l_column = 'OWNER') then
l_resp_sec_attr_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
l_state := 30;
elsif (l_column = 'LAST_UPDATE_DATE') then
l_resp_sec_attr_rec.last_update_date := to_date(l_token,
AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
l_state := 30;
elsif (l_column = 'LAST_UPDATE_LOGIN') then
l_resp_sec_attr_rec.last_update_login := to_number(l_token);
l_state := 30;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED',l_column);
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Expecting ' || l_column || ' value');
raise FND_API.G_EXC_ERROR;
end if;
elsif (l_state = 39) then
if (l_token = 'RESP_SECURITY_ATTRIBUTES') then
if not AK_SECURITY_PVT.RESP_SECURITY_ATTR_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_responsibility_id =>
l_resp_sec_attr_rec.responsibility_id,
p_resp_application_id =>
l_resp_sec_attr_rec.resp_application_id,
p_attribute_code => l_resp_sec_attr_rec.attribute_code,
p_attribute_application_id=>
l_resp_sec_attr_rec.attribute_application_id) then

-- Insert record into ak_l_resp_sec_attributes if record does not exist
--
AK_SECURITY_PVT.CREATE_RESP_SECURITY_ATTR (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_responsibility_id =>
l_resp_sec_attr_rec.responsibility_id,
p_resp_application_id =>
l_resp_sec_attr_rec.resp_application_id,
p_attribute_code => l_resp_sec_attr_rec.attribute_code,
p_attribute_application_id =>
l_resp_sec_attr_rec.attribute_application_id,
p_created_by => l_resp_sec_attr_rec.created_by,
p_creation_date => l_resp_sec_attr_rec.creation_date,
p_last_updated_by => l_resp_sec_attr_rec.last_updated_by,
p_last_update_date => l_resp_sec_attr_rec.lasT_update_date,
p_lasT_update_login => l_resp_sec_attr_rec.last_update_login,
p_loader_timestamp => p_loader_timestamp
);
--
-- If API call returns with an error status, upload aborts
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if; -- /* if l_return_status */
end if; -- /* if RESP_SECURITY_ATTR_EXISTS */
l_state := 0;
else
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
FND_MESSAGE.SET_TOKEN('EXPECTED','RESP_SECURITY_ATTRIBUTES');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
end if;

--
-- Get rid of leading white spaces, so that buffer would become
-- null if the only thing in it are white spaces
--
l_buffer := LTRIM(l_buffer);

--
-- Get the next non-blank, non-comment line if current line is
-- fully parsed
--
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

end LOOP;

-- If the loops end in a state other then at the end of an attribute
-- (state 0) or when the beginning of another business object was
-- detected, then the file must have ended prematurely, which is an error
--
if (l_state <> 0) and (l_more_item) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
FND_MESSAGE.SET_TOKEN('TOKEN','END OF FILE');
FND_MESSAGE.SET_TOKEN('EXPECTED',null);
FND_MSG_PUB.Add;
end if;
--dbms_output.put_line('Unexpected END OF FILE: state is ' ||
--		to_char(l_state));
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load line number of the last file line processed
--
p_line_num_out := l_line_num;

p_return_status := FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line('Leaving security upload: ' ||
--                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPLOAD_SECURITY;


--=======================================================
--  Function    VALIDATE_SECURITY
--
--  Usage       Private API for validating an excluded items. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an exluded items record or
--              resp_security_attributes record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Excluded_items or Resp_Security columns
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
--=======================================================
function VALIDATE_SECURITY (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_responsibility_appl_id   IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2
) return BOOLEAN is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Validate_Security';
l_error              BOOLEAN;
l_return_status      VARCHAR2(1);
begin
IF NOT FND_API.Compatible_API_Call (
l_api_version_number, p_api_version_number, l_api_name,
G_PKG_NAME) then
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
return FALSE;
END IF;

l_error := FALSE;
--
-- if validation level is none, no validation is necessary
--
if (p_validation_level = FND_API.G_VALID_LEVEL_NONE) then
p_return_status := FND_API.G_RET_STS_SUCCESS;
return TRUE;
end if;

--
-- check that key columns are not null and not missing
--
if ((p_responsibility_appl_id is null) or
(p_responsibility_appl_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'RESP_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_responsibility_id is null) or
(p_responsibility_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'RESPONSIBILITY_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_application_id is null) or
(p_attribute_application_id = FND_API.G_MISS_NUM)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;

if ((p_attribute_code is null) or
(p_attribute_code = FND_API.G_MISS_CHAR)) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_BE_NULL');
FND_MESSAGE.SET_TOKEN('COLUMN', 'ATTRIBUTE_CODE');
FND_MSG_PUB.Add;
end if;
end if;


--*** Validate columns ***

-- - responsibility application ID
if (p_responsibility_appl_id <> FND_API.G_MISS_NUM) then
if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => p_responsibility_appl_id)
) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','RESP_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;
end if;

-- - attribute application ID
if (p_attribute_application_id <> FND_API.G_MISS_NUM) then
if (NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => p_attribute_application_id)
) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
FND_MESSAGE.SET_TOKEN('COLUMN','ATTRIBUTE_APPLICATION_ID');
FND_MSG_PUB.Add;
end if;
end if;
end if;

/* return true if no error, false otherwise */
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

end VALIDATE_SECURITY;

end AK_SECURITY_pvt;

/
