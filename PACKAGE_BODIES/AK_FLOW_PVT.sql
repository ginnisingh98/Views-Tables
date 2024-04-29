--------------------------------------------------------
--  DDL for Package Body AK_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_FLOW_PVT" as
/* $Header: akdvflob.pls 120.3 2005/09/15 22:18:27 tshort ship $ */

--
-- global constants
--
-- These values are used as the page and region codes to
-- indicate that there is no primary page or region assigned.
-- These values should be consistent to the ones used in Forms.
--
G_NO_PRIMARY_PAGE_CODE     CONSTANT    VARCHAR2(30) := '-1';
G_NO_PRIMARY_REGION_CODE   CONSTANT    VARCHAR2(30) := '-1';

--=======================================================
--  Function    FLOW_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a flow with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a flow record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a flow
--              exists, or FALSE otherwise.
--  Parameters  Flow key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function FLOW_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FLOWS
where flow_application_id = p_flow_application_id
and   flow_code = p_flow_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Flow_Exists';
l_dummy              number;
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
end FLOW_EXISTS;

--=======================================================
--  Function    PAGE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a flow page with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a flow page record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a flow
--              exists, or FALSE otherwise.
--  Parameters  Flow Page key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function PAGE_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FLOW_PAGES
where flow_application_id = p_flow_application_id
and   flow_code = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Page_Exists';
l_dummy              number;
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
end PAGE_EXISTS;

--=======================================================
--  Function    PAGE_REGION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a flow page region with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a flow page region record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a flow
--              exists, or FALSE otherwise.
--  Parameters  Flow Page Region key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function PAGE_REGION_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FLOW_PAGE_REGIONS
where flow_application_id = p_flow_application_id
and   flow_code = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code
and   region_application_id = p_region_application_id
and   region_code = p_region_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Page_Region_Exists';
l_dummy              number;
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
end PAGE_REGION_EXISTS;

--=======================================================
--  Function    PAGE_REGION_ITEM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a flow page region item with the given key values.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a flow page region item record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a flow
--              exists, or FALSE otherwise.
--  Parameters  Flow Page Region Item key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function PAGE_REGION_ITEM_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FLOW_PAGE_REGION_ITEMS
where flow_application_id = p_flow_application_id
and   flow_code = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code
and   region_application_id = p_region_application_id
and   region_code = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Page_Region_Item_Exists';
l_dummy              number;
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
end PAGE_REGION_ITEM_EXISTS;

--=======================================================
--  Function    REGION_RELATION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a flow region relation with the given key values.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a flow region relation record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such a flow
--              exists, or FALSE otherwise.
--  Parameters  Flow Region Relation key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function REGION_RELATION_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_from_page_appl_id        IN      NUMBER,
p_from_page_code           IN      VARCHAR2,
p_from_region_appl_id      IN      NUMBER,
p_from_region_code         IN      VARCHAR2,
p_to_page_appl_id          IN      NUMBER,
p_to_page_code             IN      VARCHAR2,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2
) return BOOLEAN is
cursor l_check_csr is
select 1
from  AK_FLOW_REGION_RELATIONS
where flow_application_id = p_flow_application_id
and   flow_code = p_flow_code
and   foreign_key_name = p_foreign_key_name
and   from_page_appl_id = p_from_page_appl_id
and   from_page_code = p_from_page_code
and   from_region_appl_id = p_from_region_appl_id
and   from_region_code = p_from_region_code
and   to_page_appl_id = p_to_page_appl_id
and   to_page_code = p_to_page_code
and   to_region_appl_id = p_to_region_appl_id
and   to_region_code = p_to_region_code;
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Region_Relation_Exists';
l_dummy              number;
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
end REGION_RELATION_EXISTS;

--=======================================================
--  Procedure   CREATE_FLOW
--
--  Usage       Private API for creating a flow. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a flow using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow columns except primary_page_appl_id and
--              primary_page_code since there are no
--              flow pages for this flow at this time.
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_FLOW (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
l_api_version_number   CONSTANT number := 1.0;
l_api_name             CONSTANT varchar2(30) := 'Create_Flow';
l_created_by           number;
l_creation_date        date;
l_description          VARCHAR2(2000) := null;
l_error                boolean;
l_lang                 varchar2(30);
l_last_update_date     date;
l_last_update_login    number;
l_last_updated_by      number;
l_primary_page_appl_id NUMBER := null;
l_primary_page_code    VARCHAR2(30) := null;
l_attribute_category   VARCHAR2(30);
l_attribute1           VARCHAR2(150);
l_attribute2           VARCHAR2(150);
l_attribute3           VARCHAR2(150);
l_attribute4           VARCHAR2(150);
l_attribute5           VARCHAR2(150);
l_attribute6           VARCHAR2(150);
l_attribute7           VARCHAR2(150);
l_attribute8           VARCHAR2(150);
l_attribute9           VARCHAR2(150);
l_attribute10          VARCHAR2(150);
l_attribute11          VARCHAR2(150);
l_attribute12          VARCHAR2(150);
l_attribute13          VARCHAR2(150);
l_attribute14          VARCHAR2(150);
l_attribute15          VARCHAR2(150);
l_return_status        varchar2(1);
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

savepoint start_create_flow;

--
--** check to see if row already exists **
--
if AK_FLOW_PVT.FLOW_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Since there would not be any flow pages for this flow at this
-- point, create the flow with a primary page code of
-- G_NO_PRIMARY_PAGE_CODE
--
l_primary_page_appl_id := p_flow_application_id;
l_primary_page_code := G_NO_PRIMARY_PAGE_CODE;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_primary_page_appl_id => l_primary_page_appl_id,
p_primary_page_code => l_primary_page_code,
p_name => p_name,
p_description => p_description,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
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

if (p_description <> FND_API.G_MISS_CHAR) then
l_description := p_description;
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

insert into AK_FLOWS (
FLOW_APPLICATION_ID,
FLOW_CODE,
PRIMARY_PAGE_APPL_ID,
PRIMARY_PAGE_CODE,
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
p_flow_application_id,
p_flow_code,
l_primary_page_appl_id,
l_primary_page_code,
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
if NOT AK_FLOW_PVT.FLOW_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INSERT_FLOW_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_FLOWS_TL (
FLOW_APPLICATION_ID,
FLOW_CODE,
LANGUAGE,
NAME,
DESCRIPTION,
SOURCE_LANG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
) select
p_flow_application_id,
p_flow_code,
L.LANGUAGE_CODE,
p_name,
l_description,
decode(L.LANGUAGE_CODE, l_lang, L.LANGUAGE_CODE, l_lang),
l_created_by,
l_creation_date,
l_last_updated_by,
l_last_update_date,
l_last_update_login
from FND_LANGUAGES L
where L.INSTALLED_FLAG in ('I', 'B')
and not exists
(select NULL
from AK_FLOWS_TL T
where T.FLOW_APPLICATION_ID = p_flow_application_id
and T.FLOW_CODE = p_flow_code
and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);


EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_flow;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_flow;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_flow;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_FLOW;

--=======================================================
--  Procedure   CREATE_PAGE
--
--  Usage       Private API for creating a flow page. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a flow page using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page columns except primary_region_appl_id and
--              primary_region_code since there are no
--              flow page regions for this flow page at this time.
--              p_set_primary_page : IN optional
--                  Set the current page as the primary page of
--                  the flow if this flag is 'Y'.
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_PAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_page         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
) is
l_api_version_number   CONSTANT number := 1.0;
l_api_name             CONSTANT varchar2(30) := 'Create_Page';
l_created_by           number;
l_creation_date        date;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_description          VARCHAR2(2000) := null;
l_error                boolean;
l_lang                 varchar2(30);
l_last_update_date     date;
l_last_update_login    number;
l_last_updated_by      number;
l_primary_region_appl_id NUMBER := null;
l_primary_region_code  VARCHAR2(30) := null;
l_attribute_category   VARCHAR2(30);
l_attribute1           VARCHAR2(150);
l_attribute2           VARCHAR2(150);
l_attribute3           VARCHAR2(150);
l_attribute4           VARCHAR2(150);
l_attribute5           VARCHAR2(150);
l_attribute6           VARCHAR2(150);
l_attribute7           VARCHAR2(150);
l_attribute8           VARCHAR2(150);
l_attribute9           VARCHAR2(150);
l_attribute10          VARCHAR2(150);
l_attribute11          VARCHAR2(150);
l_attribute12          VARCHAR2(150);
l_attribute13          VARCHAR2(150);
l_attribute14          VARCHAR2(150);
l_attribute15          VARCHAR2(150);
l_return_status        varchar2(1);
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

savepoint start_create_page;

--
--** check to see if row already exists **
--
if AK_FLOW_PVT.PAGE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Since there would not be any flow page regions for this page region
-- at this time, create the flow page with its primary region set to
-- G_NO_PRIMARY_REGION_CODE
--
l_primary_region_appl_id := p_flow_application_id;
l_primary_region_code := G_NO_PRIMARY_REGION_CODE;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_primary_region_appl_id => l_primary_region_appl_id,
p_primary_region_code => l_primary_region_code,
p_name => p_name,
p_description => p_description,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
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

if (p_description <> FND_API.G_MISS_CHAR) then
l_description := p_description;
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

insert into AK_FLOW_PAGES (
FLOW_APPLICATION_ID,
FLOW_CODE,
PAGE_APPLICATION_ID,
PAGE_CODE,
PRIMARY_REGION_APPL_ID,
PRIMARY_REGION_CODE,
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
p_flow_application_id,
p_flow_code,
p_page_application_id,
p_page_code,
l_primary_region_appl_id,
l_primary_region_code,
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
if NOT AK_FLOW_PVT.PAGE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_INSERT_FLOW_PAGE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

insert into AK_FLOW_PAGES_TL (
FLOW_APPLICATION_ID,
FLOW_CODE,
PAGE_APPLICATION_ID,
PAGE_CODE,
LANGUAGE,
NAME,
DESCRIPTION,
SOURCE_LANG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
) select
p_flow_application_id,
p_flow_code,
p_page_application_id,
p_page_code,
L.LANGUAGE_CODE,
p_name,
l_description,
decode(L.NLS_LANGUAGE, l_lang, L.NLS_LANGUAGE, l_lang),
l_created_by,
l_creation_date,
l_last_updated_by,
l_last_update_date,
l_last_update_login
from FND_LANGUAGES L
where L.INSTALLED_FLAG in ('I', 'B')
and not exists
(select NULL
from AK_FLOW_PAGES_TL T
where T.FLOW_APPLICATION_ID = p_flow_application_id
and T.FLOW_CODE = p_flow_code
and T.PAGE_APPLICATION_ID = p_page_application_id
and T.PAGE_CODE = p_page_code
and T.LANGUAGE = L.LANGUAGE_CODE);

--  /** commit the insert **/
--  commit;

--
-- Set current page as the primary page of the flow if
-- p_set_primary_page is 'Y'.
--
if (p_set_primary_page = 'Y') then
AK_FLOW_PVT.UPDATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_primary_page_appl_id => p_page_application_id,
p_primary_page_code => p_page_code,
p_attribute_category => l_attribute_category,
p_attribute1 => l_attribute1,
p_attribute2 => l_attribute2,
p_attribute3 => l_attribute3,
p_attribute4 => l_attribute4,
p_attribute5 => l_attribute5,
p_attribute6 => l_attribute6,
p_attribute7 => l_attribute7,
p_attribute8 => l_attribute8,
p_attribute9 => l_attribute9,
p_attribute10 => l_attribute10,
p_attribute11 => l_attribute11,
p_attribute12 => l_attribute12,
p_attribute13 => l_attribute13,
p_attribute14 => l_attribute14,
p_attribute15 => l_attribute15,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_page;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_page;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_page;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_PAGE;

--=======================================================
--  Procedure   CREATE_PAGE_REGION
--
--  Usage       Private API for creating a flow page region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a flow page region using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page Region columns
--              p_set_primary_region : IN optional
--                  Set the current page region as the primary region of
--                  the flow page if this flag is 'Y'.
--              p_foreign_key_name : IN optional
--                  If a foreign key name is passed, and that this page
--                  region has a parent region, then this API will
--                  create an intrapage flow region relation connecting
--                  this page region with the parent region using the
--                  foreign key name. If there is already an intrapage
--                  flow region relation exists connecting these two
--                  page regions, it will be replaced by a new one using
--                  this foreign key.
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_PAGE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_display_sequence         IN      NUMBER := FND_API.G_MISS_NUM,
p_region_style             IN      VARCHAR2,
p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_parent_region_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_parent_region_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_region       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_version_number   CONSTANT number := 1.0;
l_api_name             CONSTANT varchar2(30) := 'Create_Page_Region';
l_created_by           number;
l_creation_date        date;
l_display_sequence     NUMBER := null;
l_icx_custom_call      VARCHAR2(80) := null;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_error                boolean;
l_lang                 varchar2(30);
l_last_update_date     date;
l_last_update_login    number;
l_last_updated_by      number;
l_num_columns          NUMBER := null;
l_parent_region_appl_id NUMBER := null;
l_parent_region_code   VARCHAR2(30) := null;
l_attribute_category   VARCHAR2(30);
l_attribute1           VARCHAR2(150);
l_attribute2           VARCHAR2(150);
l_attribute3           VARCHAR2(150);
l_attribute4           VARCHAR2(150);
l_attribute5           VARCHAR2(150);
l_attribute6           VARCHAR2(150);
l_attribute7           VARCHAR2(150);
l_attribute8           VARCHAR2(150);
l_attribute9           VARCHAR2(150);
l_attribute10          VARCHAR2(150);
l_attribute11          VARCHAR2(150);
l_attribute12          VARCHAR2(150);
l_attribute13          VARCHAR2(150);
l_attribute14          VARCHAR2(150);
l_attribute15          VARCHAR2(150);
l_return_status        varchar2(1);
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

savepoint start_create_page_region;

--
--** check to see if row already exists **
--
if AK_FLOW_PVT.PAGE_REGION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PAGE_REGION_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_display_sequence IS NOT NULL) and
(p_display_sequence <> FND_API.G_MISS_NUM) then
--** Check the given display sequence number
CHECK_DISPLAY_SEQUENCE (  p_validation_level => p_validation_level,
p_flow_code => p_flow_code,
p_flow_application_id => p_flow_application_id,
p_page_code => p_page_code,
p_page_application_id => p_page_application_id,
p_region_code => p_region_code,
p_region_application_id => p_region_application_id,
p_display_sequence => p_display_sequence,
p_return_status => l_return_status,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag);
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_display_sequence => p_display_sequence,
p_region_style => p_region_style,
p_num_columns => p_num_columns,
p_icx_custom_call => p_icx_custom_call,
p_parent_region_application_id => p_parent_region_application_id,
p_parent_region_code => p_parent_region_code,
p_foreign_key_name => p_foreign_key_name,
p_set_primary_region => p_set_primary_region,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load non-required columns if their values are given **
if (p_display_sequence <> FND_API.G_MISS_NUM) then
l_display_sequence := p_display_sequence;
end if;

if (p_num_columns <> FND_API.G_MISS_NUM) then
l_num_columns := p_num_columns;
end if;

if (p_icx_custom_call <> FND_API.G_MISS_CHAR) then
l_icx_custom_call := p_icx_custom_call;
end if;

if (p_parent_region_application_id <> FND_API.G_MISS_NUM) then
l_parent_region_appl_id := p_parent_region_application_id;
end if;

if (p_parent_region_code <> FND_API.G_MISS_CHAR) then
l_parent_region_code := p_parent_region_code;
end if;

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

select userenv('LANG') into l_lang
from dual;

insert into AK_FLOW_PAGE_REGIONS (
FLOW_APPLICATION_ID,
FLOW_CODE,
PAGE_APPLICATION_ID,
PAGE_CODE,
REGION_APPLICATION_ID,
REGION_CODE,
DISPLAY_SEQUENCE,
REGION_STYLE,
NUM_COLUMNS,
ICX_CUSTOM_CALL,
PARENT_REGION_APPLICATION_ID,
PARENT_REGION_CODE,
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
p_flow_application_id,
p_flow_code,
p_page_application_id,
p_page_code,
p_region_application_id,
p_region_code,
l_display_sequence,
p_region_style,
l_num_columns,
l_icx_custom_call,
l_parent_region_appl_id,
l_parent_region_code,
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

--  /** commit the insert **/
--  commit;

--
-- Set current region as the primary region of the flow page if
-- p_set_primary_region is 'Y'.
--
if (p_set_primary_region = 'Y') then
AK_FLOW_PVT.UPDATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_primary_region_appl_id => p_region_application_id,
p_primary_region_code => p_region_code,
p_attribute1 => l_attribute1,
p_attribute2 => l_attribute2,
p_attribute3 => l_attribute3,
p_attribute4 => l_attribute4,
p_attribute5 => l_attribute5,
p_attribute6 => l_attribute6,
p_attribute7 => l_attribute7,
p_attribute8 => l_attribute8,
p_attribute9 => l_attribute9,
p_attribute10 => l_attribute10,
p_attribute11 => l_attribute11,
p_attribute12 => l_attribute12,
p_attribute13 => l_attribute13,
p_attribute14 => l_attribute14,
p_attribute15 => l_attribute15,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--
-- if a foreign key name is specified, and there is a parent region for
-- this new page region, create an intrapage relation record.
--
if (p_foreign_key_name <> FND_API.G_MISS_CHAR) and
(p_foreign_key_name is not null) and
(p_parent_region_application_id <> FND_API.G_MISS_NUM) and
(p_parent_region_application_id is not null) and
(p_parent_region_code <> FND_API.G_MISS_CHAR) and
(p_parent_region_code is not null) then
AK_FLOW_PVT.CREATE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => p_page_application_id,
p_from_page_code => p_page_code,
p_from_region_appl_id => p_parent_region_application_id,
p_from_region_code => p_parent_region_code,
p_to_page_appl_id => p_page_application_id,
p_to_page_code => p_page_code,
p_to_region_appl_id => p_region_application_id,
p_to_region_code => p_region_code,
p_application_id => p_flow_application_id,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_OBJECT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_page_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_page_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_page_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_PAGE_REGION;

--=======================================================
--  Procedure   CREATE_PAGE_REGION_ITEM
--
--  Usage       Private API for creating a flow page region item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a flow page region item using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_PAGE_REGION_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_to_page_appl_id          IN      NUMBER := FND_API.G_MISS_NUM,
p_to_page_code             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_url_attribute_appl_id IN      NUMBER := FND_API.G_MISS_NUM,
p_to_url_attribute_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_version_number   CONSTANT number := 1.0;
l_api_name             CONSTANT varchar2(30) := 'Create_Page_Region_Item';
l_created_by           number;
l_creation_date        date;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_error                boolean;
l_lang                 varchar2(30);
l_last_update_date     date;
l_last_update_login    number;
l_last_updated_by      number;
l_return_status        varchar2(1);
l_to_page_appl_id      NUMBER :=null;
l_to_page_code         VARCHAR2(30) := null;
l_to_url_attribute_appl_id NUMBER :=null;
l_to_url_attribute_code VARCHAR2(30) := null;
l_attribute_category   VARCHAR2(30);
l_attribute1           VARCHAR2(150);
l_attribute2           VARCHAR2(150);
l_attribute3           VARCHAR2(150);
l_attribute4           VARCHAR2(150);
l_attribute5           VARCHAR2(150);
l_attribute6           VARCHAR2(150);
l_attribute7           VARCHAR2(150);
l_attribute8           VARCHAR2(150);
l_attribute9           VARCHAR2(150);
l_attribute10          VARCHAR2(150);
l_attribute11          VARCHAR2(150);
l_attribute12          VARCHAR2(150);
l_attribute13          VARCHAR2(150);
l_attribute14          VARCHAR2(150);
l_attribute15          VARCHAR2(150);
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

savepoint start_create_link;

--
--** check to see if row already exists **
--
if AK_FLOW_PVT.PAGE_REGION_ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_to_page_appl_id => p_to_page_appl_id,
p_to_page_code => p_to_page_code,
p_to_url_attribute_appl_id => p_to_url_attribute_appl_id,
p_to_url_attribute_code => p_to_url_attribute_code,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load non-required columns if their values are given **
if (p_to_page_appl_id <> FND_API.G_MISS_NUM) then
l_to_page_appl_id := p_to_page_appl_id;
end if;

if (p_to_page_code <> FND_API.G_MISS_CHAR) then
l_to_page_code := p_to_page_code;
end if;

if (p_to_url_attribute_appl_id <> FND_API.G_MISS_NUM) then
l_to_url_attribute_appl_id := p_to_url_attribute_appl_id;
end if;

if (p_to_url_attribute_code <> FND_API.G_MISS_CHAR) then
l_to_url_attribute_code := p_to_url_attribute_code;
end if;

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

select userenv('LANG') into l_lang
from dual;

insert into AK_FLOW_PAGE_REGION_ITEMS (
FLOW_APPLICATION_ID,
FLOW_CODE,
PAGE_APPLICATION_ID,
PAGE_CODE,
REGION_APPLICATION_ID,
REGION_CODE,
ATTRIBUTE_APPLICATION_ID,
ATTRIBUTE_CODE,
TO_PAGE_APPL_ID,
TO_PAGE_CODE,
TO_URL_ATTRIBUTE_APPL_ID,
TO_URL_ATTRIBUTE_CODE,
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
p_flow_application_id,
p_flow_code,
p_page_application_id,
p_page_code,
p_region_application_id,
p_region_code,
p_attribute_application_id,
p_attribute_code,
l_to_page_appl_id,
l_to_page_code,
l_to_url_attribute_appl_id,
l_to_url_attribute_code,
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

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
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
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_link;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_link;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_link;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_PAGE_REGION_ITEM;

--=======================================================
--  Procedure   CREATE_REGION_RELATIONS
--
--  Usage       Private API for creating a flow region relation. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a flow region relation using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Region Relation columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_REGION_RELATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_from_page_appl_id        IN      NUMBER,
p_from_page_code           IN      VARCHAR2,
p_from_region_appl_id      IN      NUMBER,
p_from_region_code         IN      VARCHAR2,
p_to_page_appl_id          IN      NUMBER,
p_to_page_code             IN      VARCHAR2,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2,
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
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Region_Relation';
l_created_by         number;
l_creation_date      date;
l_lang               varchar2(30);
l_last_update_date   date;
l_last_update_login  number;
l_last_updated_by    number;
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

savepoint start_create_relation;

--** check to see if row already exists **
if AK_FLOW_PVT.REGION_RELATION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => p_from_page_appl_id,
p_from_page_code => p_from_page_code,
p_from_region_appl_id => p_from_region_appl_id,
p_from_region_code => p_from_region_code,
p_to_page_appl_id => p_to_page_appl_id,
p_to_page_code => p_to_page_code,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RELATION_EXISTS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => p_from_page_appl_id,
p_from_page_code => p_from_page_code,
p_from_region_appl_id => p_from_region_appl_id,
p_from_region_code => p_from_region_code,
p_to_page_appl_id => p_to_page_appl_id,
p_to_page_code => p_to_page_code,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code,
p_application_id => p_application_id,
p_caller => AK_ON_OBJECTS_PVT.G_CREATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
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

select userenv('LANG') into l_lang
from dual;

insert into AK_FLOW_REGION_RELATIONS (
FLOW_APPLICATION_ID,
FLOW_CODE,
FOREIGN_KEY_NAME,
FROM_PAGE_APPL_ID,
FROM_PAGE_CODE,
FROM_REGION_APPL_ID,
FROM_REGION_CODE,
TO_PAGE_APPL_ID,
TO_PAGE_CODE,
TO_REGION_APPL_ID,
TO_REGION_CODE,
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
p_flow_application_id,
p_flow_code,
p_foreign_key_name,
p_from_page_appl_id,
p_from_page_code,
p_from_region_appl_id,
p_from_region_code,
p_to_page_appl_id,
p_to_page_code,
p_to_region_appl_id,
p_to_region_code,
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

--  /** commit the insert **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_RELATION_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN VALUE_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RELATION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_relation;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RELATION_NOT_CREATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_relation;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_relation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end CREATE_REGION_RELATION;

--=======================================================
--  Procedure   DELETE_FLOW
--
--  Usage       Private API for deleting a flow. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a flow with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_flow_application_id : IN required
--              p_flow_code : IN required
--                  Key value of the flow to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_FLOW (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_pages_csr is
select PAGE_APPLICATION_ID, PAGE_CODE
from   AK_FLOW_PAGES
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Flow';
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_page_application_id   NUMBER;
l_page_code             VARCHAR2(30);
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

savepoint start_delete_flow;

--
-- error if flow to be deleted does not exists
--
if NOT AK_FLOW_PVT.FLOW_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the flow if it is being referenced in any of
-- following tables.
--
-- AK_FLOW_PAGES
--
open l_get_pages_csr;
fetch l_get_pages_csr into l_page_application_id, l_page_code;
if l_get_pages_csr%found then
close l_get_pages_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_FLOW_PG');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_pages_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_FLOW_PAGES
--
open l_get_pages_csr;
loop
fetch l_get_pages_csr into l_page_application_id, l_page_code;
exit when l_get_pages_csr%notfound;
AK_FLOW_PVT.DELETE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => l_page_application_id,
p_page_code => l_page_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_pages_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_pages_csr;
end if;

--
-- delete flow once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_flows
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_flows_tl
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_flow;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_flow;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_FLOW;

--=======================================================
--  Procedure   DELETE_PAGE
--
--  Usage       Private API for deleting a flow page. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a flow page with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_flow_application_id : IN required
--              p_flow_code : IN required
--              p_page_application_id : IN required
--              p_page_code : IN required
--                  Key value of the flow page to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_PAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_page_regions_csr is
select REGION_APPLICATION_ID, REGION_CODE
from   AK_FLOW_PAGE_REGIONS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code;
cursor l_check_primary_csr is
select 1
from   AK_FLOWS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    primary_page_appl_id = p_page_application_id
and    primary_page_code = p_page_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Page';
l_dummy                 NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_region_application_id NUMBER;
l_region_code           VARCHAR2(30);
l_return_status         varchar2(1);
l_pass                  NUMBER := 2;
l_copy_redo_flag        BOOLEAN := FALSE;
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

savepoint start_delete_page;

--
-- error if flow page to be deleted does not exists
--
if NOT AK_FLOW_PVT.PAGE_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the flow page if it is being referenced in any of
-- following tables.
--
-- AK_FLOW_PAGE_REGIONS
--
open l_get_page_regions_csr;
fetch l_get_page_regions_csr into l_region_application_id, l_region_code;
if l_get_page_regions_csr%found then
close l_get_page_regions_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_PG_PGREG');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_page_regions_csr;
--
-- AK_FLOWS (primary page of a flow)
--
open l_check_primary_csr;
fetch l_check_primary_csr into l_dummy;
if l_check_primary_csr%found then
close l_check_primary_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_PPG_FLOW');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_check_primary_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_FLOW_PAGE_REGIONS
--
open l_get_page_regions_csr;
loop
fetch l_get_page_regions_csr into l_region_application_id, l_region_code;
exit when l_get_page_regions_csr%notfound;
AK_FLOW_PVT.DELETE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => l_region_application_id,
p_region_code => l_region_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_page_regions_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_page_regions_csr;
--
-- AK_FLOWS (primary page of a flow)
--
-- - invalidates flow's primary page
--
open l_check_primary_csr;
fetch l_check_primary_csr into l_dummy;
if l_check_primary_csr%found then
AK_FLOW_PVT.UPDATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_primary_page_code => G_NO_PRIMARY_PAGE_CODE,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_check_primary_csr;
raise FND_API.G_EXC_ERROR;
end if;
--
-- issue a warning asking the user to re-assign a primary page
-- to this flow
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_ASSIGN_PRIMARY_PG_FLOW');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;
end if;
close l_check_primary_csr;
end if;

--
-- delete flow page once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_flow_pages
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

delete from ak_flow_pages_tl
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_page;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_page;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_PAGE;

--=======================================================
--  Procedure   DELETE_PAGE_REGION
--
--  Usage       Private API for deleting a flow page region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a flow page region with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_flow_application_id : IN required
--              p_flow_code : IN required
--              p_page_application_id : IN required
--              p_page_code : IN required
--              p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the flow page region to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_PAGE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_items_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_FLOW_PAGE_REGION_ITEMS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code
and    region_application_id = p_region_application_id
and    region_code = p_region_code;
cursor l_get_from_relations_csr is
select FOREIGN_KEY_NAME, TO_PAGE_APPL_ID, TO_PAGE_CODE,
TO_REGION_APPL_ID, TO_REGION_CODE
from   AK_FLOW_REGION_RELATIONS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    from_page_appl_id = p_page_application_id
and    from_page_code = p_page_code
and    from_region_appl_id = p_region_application_id
and    from_region_code = p_region_code;
cursor l_get_to_relations_csr is
select FOREIGN_KEY_NAME, FROM_PAGE_APPL_ID, FROM_PAGE_CODE,
FROM_REGION_APPL_ID, FROM_REGION_CODE
from   AK_FLOW_REGION_RELATIONS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    to_page_appl_id = p_page_application_id
and    to_page_code = p_page_code
and    to_region_appl_id = p_region_application_id
and    to_region_code = p_region_code;
cursor l_check_primary_csr is
select 1
from   AK_FLOW_PAGES
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code
and    primary_region_appl_id = p_region_application_id
and    primary_region_code = p_region_code;
cursor l_get_child_regions_csr is
select region_application_id, region_code
from   AK_FLOW_PAGE_REGIONS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code
and    parent_region_application_id = p_region_application_id
and    parent_region_code = p_region_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Page_Region';
l_attribute_appl_id     NUMBER;
l_attribute_code        VARCHAR2(30);
l_dummy                 NUMBER;
l_foreign_key_name      VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_page_appl_id          NUMBER;
l_page_code             VARCHAR2(30);
l_region_appl_id        NUMBER;
l_region_code           VARCHAR2(30);
l_return_status         varchar2(1);
l_copy_redo_flag        BOOLEAN := FALSE;
l_pass                  NUMBER := 2;
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

savepoint start_delete_page_region;

--
-- error if page region to be deleted does not exists
--
if NOT AK_FLOW_PVT.PAGE_REGION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the flow page region if it is being referenced in any of
-- following tables.
--
-- AK_FLOW_PAGE_REGION_ITEMS
--
open l_get_items_csr;
fetch l_get_items_csr into l_attribute_appl_id, l_attribute_code;
if l_get_items_csr%found then
close l_get_items_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_PGREG_ITEM');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_items_csr;
--
-- AK_FLOW_REGION_RELATIONS (as from page region)
--
open l_get_from_relations_csr;
fetch l_get_from_relations_csr into l_foreign_key_name,
l_page_appl_id, l_page_code, l_region_appl_id, l_region_code;
if l_get_from_relations_csr%found then
close l_get_from_relations_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_PGREG_REL');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_from_relations_csr;
--
-- AK_FLOW_REGION_RELATIONS (as to page region)
--
open l_get_to_relations_csr;
fetch l_get_to_relations_csr into l_foreign_key_name,
l_page_appl_id, l_page_code, l_region_appl_id, l_region_code;
if l_get_to_relations_csr%found then
close l_get_to_relations_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_PGREG_REL');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_to_relations_csr;
--
-- AK_FLOW_PAGE_REGIONS (parent region of another region)
--
open l_get_child_regions_csr;
fetch l_get_child_regions_csr into l_region_appl_id, l_region_code;
if l_get_child_regions_csr%found then
close l_get_child_regions_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','EXISTING_CHILDREN_PAGE_REGIONS');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_child_regions_csr;
--
-- AK_FLOW_PAGES (primary region of a page)
--
open l_check_primary_csr;
fetch l_check_primary_csr into l_dummy;
if l_check_primary_csr%found then
close l_check_primary_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_PPGREG_PG');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_check_primary_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_FLOW_PAGE_REGION_ITEMS
--
open l_get_items_csr;
loop
fetch l_get_items_csr into l_attribute_appl_id, l_attribute_code;
exit when l_get_items_csr%notfound;
AK_FLOW_PVT.DELETE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => l_attribute_appl_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_items_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_items_csr;
--
-- AK_FLOW_REGION_RELATIONS (as from page region)
--
open l_get_from_relations_csr;
loop
fetch l_get_from_relations_csr into l_foreign_key_name,
l_page_appl_id, l_page_code, l_region_appl_id, l_region_code;
exit when l_get_from_relations_csr%notfound;
AK_FLOW_PVT.DELETE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => l_foreign_key_name,
p_from_page_appl_id => p_page_application_id,
p_from_page_code => p_page_code,
p_from_region_appl_id => p_region_application_id,
p_from_region_code => p_region_code,
p_to_page_appl_id => l_page_appl_id,
p_to_page_code => l_page_code,
p_to_region_appl_id => l_region_appl_id,
p_to_region_code => l_region_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_from_relations_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_from_relations_csr;
--
-- AK_FLOW_REGION_RELATIONS (as to page region)
--
open l_get_to_relations_csr;
loop
fetch l_get_to_relations_csr into l_foreign_key_name,
l_page_appl_id, l_page_code, l_region_appl_id, l_region_code;
exit when l_get_to_relations_csr%notfound;
AK_FLOW_PVT.DELETE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => l_foreign_key_name,
p_from_page_appl_id => l_page_appl_id,
p_from_page_code => l_page_code,
p_from_region_appl_id => l_region_appl_id,
p_from_region_code => l_region_code,
p_to_page_appl_id => p_page_application_id,
p_to_page_code => p_page_code,
p_to_region_appl_id => p_region_application_id,
p_to_region_code => p_region_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_from_relations_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_to_relations_csr;
--
-- AK_FLOW_PAGE_REGIONS (parent region of another region)
--
-- -blank out the parent region columns of the child regions.
--
open l_get_child_regions_csr;
loop
fetch l_get_child_regions_csr into l_region_appl_id, l_region_code;
exit when l_get_child_regions_csr%notfound;
AK_FLOW_PVT.UPDATE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => l_region_appl_id,
p_region_code => l_region_code,
p_parent_region_application_id => null,
p_parent_region_code => null,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_child_regions_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_child_regions_csr;
--
-- AK_FLOW_PAGES (primary region of a page)
--
-- - invalidates flow page's primary region
--
open l_check_primary_csr;
fetch l_check_primary_csr into l_dummy;
if l_check_primary_csr%found then
AK_FLOW_PVT.UPDATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_primary_region_code => G_NO_PRIMARY_REGION_CODE,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_check_primary_csr;
raise FND_API.G_EXC_ERROR;
end if;
--
-- issue a warning asking the user to re-assign a primary page
-- to this flow
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_ASSIGN_PRIMARY_PGREG_PG');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;
end if;
close l_check_primary_csr;
end if;

--
-- delete flow page region once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_flow_page_regions
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code
and    region_application_id = p_region_application_id
and    region_code = p_region_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_PAGE_REGION_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_page_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_page_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_PAGE_REGION;

--=======================================================
--  Procedure   DELETE_PAGE_REGION_ITEM
--
--  Usage       Private API for deleting a flow page region item.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a flow page region item with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_flow_application_id : IN required
--              p_flow_code : IN required
--              p_page_application_id : IN required
--              p_page_code : IN required
--              p_region_application_id : IN required
--              p_region_code : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the flow page region item to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_PAGE_REGION_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Page_Region_Item';
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

savepoint start_delete_region_item;

--
-- error if page region item to be deleted does not exists
--
if NOT AK_FLOW_PVT.PAGE_REGION_ITEM_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the page region item if it is being referenced in any of
-- following tables.
--
-- none
--
null;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- none
--
null;
end if;

--
-- delete page region item once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_flow_page_region_items
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_page_application_id
and    page_code = p_page_code
and    region_application_id = p_region_application_id
and    region_code = p_region_code
and    attribute_application_id = p_attribute_application_id
and    attribute_code = p_attribute_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
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
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_region_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_region_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_PAGE_REGION_ITEM;

--=======================================================
--  Procedure   DELETE_REGION_RELATION
--
--  Usage       Private API for deleting a flow region relation.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes a flow region relation with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_flow_application_id : IN required
--              p_flow_code : IN required
--              p_foreign_key_name : IN required
--              p_from_page_appl_id : IN required
--              p_from_page_code : IN required
--              p_from_region_appl_id : IN required
--              p_from_region_code : IN required
--              p_to_page_appl_id : IN required
--              p_to_page_code : IN required
--              p_to_region_appl_id : IN required
--              p_to_region_code : IN required
--                  Key value of the flow region relation to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this record.
--                  Otherwise, this record will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_REGION_RELATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_from_page_appl_id        IN      NUMBER,
p_from_page_code           IN      VARCHAR2,
p_from_region_appl_id      IN      NUMBER,
p_from_region_code         IN      VARCHAR2,
p_to_page_appl_id          IN      NUMBER,
p_to_page_code             IN      VARCHAR2,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
) is
cursor l_get_items_csr is
select ATTRIBUTE_APPLICATION_ID, ATTRIBUTE_CODE
from   AK_FLOW_PAGE_REGION_ITEMS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    page_application_id = p_from_page_appl_id
and    page_code = p_from_page_code
and    region_application_id = p_from_region_appl_id
and    region_code = p_from_region_code
and    to_page_appl_id = p_to_page_appl_id
and    to_page_code = p_to_page_code;
l_api_version_number    CONSTANT number := 1.0;
l_api_name              CONSTANT varchar2(30):= 'Delete_Region_Relation';
l_attribute_application_id NUMBER;
l_attribute_code        VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
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

savepoint start_delete_relation;

--
-- error if region relation to be deleted does not exists
--
if NOT AK_FLOW_PVT.REGION_RELATION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => p_from_page_appl_id,
p_from_page_code => p_from_page_code,
p_from_region_appl_id => p_from_region_appl_id,
p_from_region_code => p_from_region_code,
p_to_page_appl_id => p_to_page_appl_id,
p_to_page_code => p_to_page_code,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RELATION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

if (p_delete_cascade = 'N') then
--
-- If we are not deleting any referencing records, we cannot
-- delete the region relation if it is being referenced in any of
-- following tables.
--
-- AK_FLOW_PAGE_REGION_ITEMS
--
open l_get_items_csr;
fetch l_get_items_csr into l_attribute_application_id, l_attribute_code;
if l_get_items_csr%found then
close l_get_items_csr;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_CANNOT_DEL_REF_REL_ITEM');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_items_csr;
else
--
-- Otherwise, delete all referencing rows in other tables
--
-- AK_REGION_TIEMS
--
open l_get_items_csr;
loop
fetch l_get_items_csr into l_attribute_application_id, l_attribute_code;
exit when l_get_items_csr%notfound;
AK_FLOW_PVT.DELETE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_from_page_appl_id,
p_page_code => p_from_page_code,
p_region_application_id => p_from_region_appl_id,
p_region_code => p_from_region_code,
p_attribute_application_id => l_attribute_application_id,
p_attribute_code => l_attribute_code,
p_delete_cascade => p_delete_cascade
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
close l_get_items_csr;
raise FND_API.G_EXC_ERROR;
end if;
end loop;
close l_get_items_csr;
end if;

--
-- delete region relation once we checked that there are no references
-- to it, or all references have been deleted.
--
delete from ak_flow_region_relations
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    foreign_key_name = p_foreign_key_name
and    from_page_appl_id = p_from_page_appl_id
and    from_page_code = p_from_page_code
and    from_region_appl_id = p_from_region_appl_id
and    from_region_code = p_from_region_code
and    to_page_appl_id = p_to_page_appl_id
and    to_page_code = p_to_page_code
and    to_region_appl_id = p_to_region_appl_id
and    to_region_code = p_to_region_code;

if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RELATION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- Load success message
--
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) then
FND_MESSAGE.SET_NAME('AK','AK_RELATION_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RELATION_NOT_DELETED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_relation;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_relation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end DELETE_REGION_RELATION;

--=======================================================
--  Procedure   UPDATE_FLOW
--
--  Usage       Private API for updating a flow.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a flow using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_FLOW (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_primary_page_appl_id     IN      NUMBER := FND_API.G_MISS_NUM,
p_primary_page_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
from  AK_FLOWS
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
for   update of primary_page_appl_id;
cursor l_get_tl_row_csr (lang_parm varchar2) is
select *
from  AK_FLOWS_TL
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   LANGUAGE = lang_parm
for update of name;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Flow';
l_created_by             number;
l_creation_date          date;
l_flows_rec              ak_flows%ROWTYPE;
l_flows_tl_rec           ak_flows_tl%ROWTYPE;
l_error                  boolean;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_return_status          varchar2(1);
l_file_version	   number;
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

savepoint start_update_flow;

select userenv('LANG') into l_lang
from dual;

--
-- retrieve ak_flows row if it exists
--
open l_get_row_csr;
fetch l_get_row_csr into l_flows_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--
-- retrieve ak_flows_tl row if it exists
--
open l_get_tl_row_csr(l_lang);
fetch l_get_tl_row_csr into l_flows_tl_rec;
if (l_get_tl_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_tl_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_tl_row_csr;

--
-- validate table columns passed in
--
-- (A null primary page code means that the user wants to invalidate
--  the primary page selection. It should be updated with
--  G_NO_PRIMARY_PAGE_CODE)
--
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_primary_page_appl_id =>
nvl(p_primary_page_appl_id,p_flow_application_id),
p_primary_page_code =>
nvl(p_primary_page_code,G_NO_PRIMARY_PAGE_CODE),
p_name => p_name,
p_description => p_description,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_flows_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_flows_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_flows_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_flows_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_flows_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_flows_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_flows_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_flows_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_flows_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_flows_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_flows_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_flows_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_flows_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_flows_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_flows_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_flows_rec.attribute15 := p_attribute15;
end if;

if (p_description <> FND_API.G_MISS_CHAR) or
(p_description is null) then
l_flows_tl_rec.description := p_description;
end if;

--** - next, load non-null columns **

-- primary page code should be loaded with G_NO_PRIMARY_PAGE_CODE
-- if user wants to invalidate the primary page selection
--
if (p_primary_page_code <> FND_API.G_MISS_CHAR) then
l_flows_rec.primary_page_code := p_primary_page_code;
elsif (p_primary_page_code is null) then
l_flows_rec.primary_page_code := G_NO_PRIMARY_PAGE_CODE;
end if;

if (p_primary_page_appl_id <> FND_API.G_MISS_NUM) then
l_flows_rec.primary_page_appl_id := p_primary_page_appl_id;
end if;
if (p_name <> FND_API.G_MISS_CHAR) then
l_flows_tl_rec.name := p_name;
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

-- Set WHO columns
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_flows_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_flows_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_FLOWS set
PRIMARY_PAGE_APPL_ID = l_flows_rec.primary_page_appl_id,
PRIMARY_PAGE_CODE = l_flows_rec.primary_page_code,
ATTRIBUTE_CATEGORY = l_flows_rec.attribute_category,
ATTRIBUTE1 = l_flows_rec.attribute1,
ATTRIBUTE2 = l_flows_rec.attribute2,
ATTRIBUTE3 = l_flows_rec.attribute3,
ATTRIBUTE4 = l_flows_rec.attribute4,
ATTRIBUTE5 = l_flows_rec.attribute5,
ATTRIBUTE6 = l_flows_rec.attribute6,
ATTRIBUTE7 = l_flows_rec.attribute7,
ATTRIBUTE8 = l_flows_rec.attribute8,
ATTRIBUTE9 = l_flows_rec.attribute9,
ATTRIBUTE10 = l_flows_rec.attribute10,
ATTRIBUTE11 = l_flows_rec.attribute11,
ATTRIBUTE12 = l_flows_rec.attribute12,
ATTRIBUTE13 = l_flows_rec.attribute13,
ATTRIBUTE14 = l_flows_rec.attribute14,
ATTRIBUTE15 = l_flows_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

update AK_FLOWS_TL set
NAME = l_flows_tl_rec.name,
DESCRIPTION = l_flows_tl_rec.description,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATE_LOGIN = l_last_update_login,
SOURCE_LANG = l_lang
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   l_lang in (LANGUAGE, SOURCE_LANG);
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
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
FND_MESSAGE.SET_NAME('AK','AK_FLOW_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_flow;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_flow;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_flow;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_FLOW;

--=======================================================
--  Procedure   UPDATE_PAGE
--
--  Usage       Private API for updating a flow page.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a flow page using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page columns
--              p_set_primary_page : IN optional
--                  Set the current page as the primary page of
--                  the flow if this flag is 'Y'.
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_PAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_primary_region_appl_id   IN      NUMBER := FND_API.G_MISS_NUM,
p_primary_region_code      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_page         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
from  AK_FLOW_PAGES
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code
for   update of primary_region_appl_id;
cursor l_get_tl_row_csr (lang_parm varchar2) is
select *
from  AK_FLOW_PAGES_TL
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code
and   LANGUAGE = lang_parm
for  update of name;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Page';
l_created_by             number;
l_creation_date          date;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_error                  boolean;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_pages_rec              ak_flow_pages%ROWTYPE;
l_pages_tl_rec           ak_flow_pages_tl%ROWTYPE;
l_return_status          varchar2(1);
l_file_version	   number;
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

savepoint start_update_page;

select userenv('LANG') into l_lang
from dual;

--
-- retrieve ak_flow_pages row if it exists
--
open l_get_row_csr;
fetch l_get_row_csr into l_pages_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--
-- retrieve ak_pages_tl row if it exists
--
open l_get_tl_row_csr(l_lang);
fetch l_get_tl_row_csr into l_pages_tl_rec;
if (l_get_tl_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_tl_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_tl_row_csr;

--
-- validate table columns passed in
--
-- (A null primary region code means that the user wants to invalidate
--  the primary region selection. It should be updated with
--  G_NO_PRIMARY_REGION_CODE)
--
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_primary_region_appl_id =>
nvl(p_primary_region_appl_id,p_flow_application_id),
p_primary_region_code =>
nvl(p_primary_region_code,G_NO_PRIMARY_REGION_CODE),
p_name => p_name,
p_description => p_description,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_pages_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_pages_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_pages_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_pages_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_pages_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_pages_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_pages_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_pages_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_pages_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_pages_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_pages_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_pages_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_pages_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_pages_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_pages_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_pages_rec.attribute15 := p_attribute15;
end if;
if (p_description <> FND_API.G_MISS_CHAR) or
(p_description is null) then
l_pages_tl_rec.description := p_description;
end if;

--** - next, load non-null columns **

-- primary region code should be loaded with G_NO_PRIMARY_REGION_CODE
-- if user wants to invalidate the primary region selection
--
if (p_primary_region_code <> FND_API.G_MISS_CHAR) then
l_pages_rec.primary_region_code := p_primary_region_code;
elsif (p_primary_region_code is null) then
l_pages_rec.primary_region_code := G_NO_PRIMARY_REGION_CODE;
end if;

if (p_primary_region_appl_id <> FND_API.G_MISS_NUM) then
l_pages_rec.primary_region_appl_id := p_primary_region_appl_id;
end if;
if (p_name <> FND_API.G_MISS_CHAR) then
l_pages_tl_rec.name := p_name;
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
       p_db_last_updated_by => l_pages_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_pages_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_FLOW_PAGES set
PRIMARY_REGION_APPL_ID = l_pages_rec.primary_region_appl_id,
PRIMARY_REGION_CODE = l_pages_rec.primary_region_code,
ATTRIBUTE_CATEGORY = l_pages_rec.attribute_category,
ATTRIBUTE1 = l_pages_rec.attribute1,
ATTRIBUTE2 = l_pages_rec.attribute2,
ATTRIBUTE3 = l_pages_rec.attribute3,
ATTRIBUTE4 = l_pages_rec.attribute4,
ATTRIBUTE5 = l_pages_rec.attribute5,
ATTRIBUTE6 = l_pages_rec.attribute6,
ATTRIBUTE7 = l_pages_rec.attribute7,
ATTRIBUTE8 = l_pages_rec.attribute8,
ATTRIBUTE9 = l_pages_rec.attribute9,
ATTRIBUTE10 = l_pages_rec.attribute10,
ATTRIBUTE11 = l_pages_rec.attribute11,
ATTRIBUTE12 = l_pages_rec.attribute12,
ATTRIBUTE13 = l_pages_rec.attribute13,
ATTRIBUTE14 = l_pages_rec.attribute14,
ATTRIBUTE15 = l_pages_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   PAGE_APPLICATION_ID = p_page_application_id
and   PAGE_CODE = p_page_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

update AK_FLOW_PAGES_TL set
NAME = l_pages_tl_rec.name,
DESCRIPTION = l_pages_tl_rec.description,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATE_LOGIN = l_last_update_login,
SOURCE_LANG = l_lang
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   PAGE_APPLICATION_ID = p_page_application_id
and   PAGE_CODE = p_page_code
and   l_lang in (LANGUAGE, SOURCE_LANG);
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
--  commit;

--
-- Set current page as the primary page of the flow if
-- p_set_primary_page is 'Y'.
--
if (p_set_primary_page = 'Y') then
AK_FLOW_PVT.UPDATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_primary_page_appl_id => p_page_application_id,
p_primary_page_code => p_page_code,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
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
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_page;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_FLOW_PAGE_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_page;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_page;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_PAGE;

--=======================================================
--  Procedure   UPDATE_PAGE_REGION
--
--  Usage       Private API for updating a flow page region.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a flow page region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page Region columns
--              p_foreign_key_name : IN optional
--                  If a foreign key name is passed, and that this page
--                  region has a parent region, then this API will
--                  create an intrapage flow region relation connecting
--                  this page region with the parent region using the
--                  foreign key name. If there is already an intrapage
--                  flow region relation exists connecting these two
--                  page regions, it will be replaced by a new one using
--                  this foreign key.
--              p_set_primary_region : IN optional
--                  Set the current page region as the primary region of
--                  the flow page if this flag is 'Y'.
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_PAGE_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_display_sequence         IN      NUMBER := FND_API.G_MISS_NUM,
p_region_style             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_parent_region_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_parent_region_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_region       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_created_by		     IN     NUMBER := FND_API.G_MISS_NUM,
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
from  AK_FLOW_PAGE_REGIONS
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code
and   region_application_id = p_region_application_id
and   region_code = p_region_code
for   update of display_sequence;
cursor l_get_old_fk_csr (parent_region_appl_id_param NUMBER,
parent_region_code_param varchar2) is
select foreign_key_name
from   AK_FLOW_REGION_RELATIONS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    from_page_appl_id = p_page_application_id
and    from_page_code = p_page_code
and    from_region_appl_id = parent_region_appl_id_param
and    from_region_code = parent_region_code_param
and    to_page_appl_id = p_page_application_id
and    to_page_code = p_page_code
and    to_region_appl_id = p_region_application_id
and    to_region_code = p_region_code;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Page_Region';
l_dummy                  CONSTANT varchar2(30) := 'DUM_OLD_KEY_ZZZ';
l_created_by             number;
l_creation_date          date;
l_foreign_key_name_old   VARCHAR2(30);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_error                  boolean;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_parent_region_changed  varchar2(1);
l_regions_rec            ak_flow_page_regions%ROWTYPE;
l_return_status          varchar2(1);
l_file_version	   number;
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

savepoint start_update_page_region;

select userenv('LANG') into l_lang
from dual;

--
-- retrieve ak_flow_page_regions row if it exists
--
open l_get_row_csr;
fetch l_get_row_csr into l_regions_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

if (p_display_sequence IS NOT NULL) and
(p_display_sequence <> FND_API.G_MISS_NUM) then
--** Check the given display sequence number
CHECK_DISPLAY_SEQUENCE (  p_validation_level => p_validation_level,
p_flow_code => p_flow_code,
p_flow_application_id => p_flow_application_id,
p_page_code => p_page_code,
p_page_application_id => p_page_application_id,
p_region_code => p_region_code,
p_region_application_id => p_region_application_id,
p_display_sequence => p_display_sequence,
p_return_status => l_return_status,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag);
end if;

--
-- validate table columns passed in
--
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_display_sequence => p_display_sequence,
p_region_style => p_region_style,
p_num_columns => p_num_columns,
p_icx_custom_call => p_icx_custom_call,
p_parent_region_application_id => p_parent_region_application_id,
p_parent_region_code => p_parent_region_code,
p_foreign_key_name => p_foreign_key_name,
p_set_primary_region => p_set_primary_region,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--
-- retrieve the foreign key name of the original intrapage relation.
--
open l_get_old_fk_csr (l_regions_rec.parent_region_application_id,
l_regions_rec.parent_region_code);
fetch l_get_old_fk_csr into l_foreign_key_name_old;
if (l_get_old_fk_csr%notfound) then
l_foreign_key_name_old := null;
end if;
close l_get_old_fk_csr;

--
-- set flag indicating whether there is a change in parent region
--
if (p_parent_region_application_id =
l_regions_rec.parent_region_application_id) and
(p_parent_region_code = l_regions_rec.parent_region_code) then
l_parent_region_changed := 'N';
else
l_parent_region_changed := 'Y';
end if;

--
-- if changing the foreign key name, or removing or changing parent region,
-- we need to delete the existing intrapage relation with the
-- old foreign key.
--
if ( (p_foreign_key_name <> FND_API.G_MISS_CHAR) and
(p_foreign_key_name is not null) and
(p_foreign_key_name <> NVL(l_foreign_key_name_old, l_dummy) ) ) or
(l_parent_region_changed = 'Y') then
--
-- delete only if such a relation exists
--
if (l_foreign_key_name_old is not null) then
AK_FLOW_PVT.DELETE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => l_regions_rec.flow_application_id,
p_flow_code => l_regions_rec.flow_code,
p_foreign_key_name => l_foreign_key_name_old,
p_from_page_appl_id => l_regions_rec.page_application_id,
p_from_page_code => l_regions_rec.page_code,
p_from_region_appl_id => l_regions_rec.parent_region_application_id,
p_from_region_code => l_regions_rec.parent_region_code,
p_to_page_appl_id => l_regions_rec.page_application_id,
p_to_page_code => l_regions_rec.page_code,
p_to_region_appl_id => l_regions_rec.region_application_id,
p_to_region_code => l_regions_rec.region_code,
p_delete_cascade => 'Y'
);
end if;
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_display_sequence <> FND_API.G_MISS_NUM) or
(p_display_sequence is null) then
l_regions_rec.display_sequence := p_display_sequence;
end if;
if (p_num_columns <> FND_API.G_MISS_NUM) or
(p_num_columns is null) then
l_regions_rec.num_columns := p_num_columns;
end if;
if (p_parent_region_application_id <> FND_API.G_MISS_NUM) or
(p_parent_region_application_id is null) then
l_regions_rec.parent_region_application_id :=
p_parent_region_application_id;
end if;
if (p_parent_region_code <> FND_API.G_MISS_CHAR) or
(p_parent_region_code is null) then
l_regions_rec.parent_region_code := p_parent_region_code;
end if;
if (p_icx_custom_call <> FND_API.G_MISS_CHAR) or
(p_icx_custom_call is null) then
l_regions_rec.icx_custom_call := p_icx_custom_call;
end if;
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_regions_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_regions_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_regions_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_regions_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_regions_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_regions_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_regions_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_regions_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_regions_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_regions_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_regions_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_regions_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_regions_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_regions_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_regions_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_regions_rec.attribute15 := p_attribute15;
end if;

--** - next, load non-null columns **
if (p_region_style <> FND_API.G_MISS_CHAR) then
l_regions_rec.region_style := p_region_style;
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
       p_db_last_updated_by => l_regions_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_regions_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

--
-- Create a new intrapage relation if the foreign key name is changed,
-- or a different (non-null) parent region is specified.
--
if ( (p_foreign_key_name <> FND_API.G_MISS_CHAR) and
(p_foreign_key_name is not null) and
(p_foreign_key_name <> NVL(l_foreign_key_name_old, l_dummy) ) ) or
(l_parent_region_changed = 'Y') then
--
-- Create region relation only if it doesn't already exists,
-- and a parent region is given.
--
if NOT AK_FLOW_PVT.REGION_RELATION_EXISTS (
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => l_regions_rec.flow_application_id,
p_flow_code => l_regions_rec.flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => l_regions_rec.page_application_id,
p_from_page_code => l_regions_rec.page_code,
p_from_region_appl_id => l_regions_rec.parent_region_application_id,
p_from_region_code => l_regions_rec.parent_region_code,
p_to_page_appl_id => l_regions_rec.page_application_id,
p_to_page_code => l_regions_rec.page_code,
p_to_region_appl_id => l_regions_rec.region_application_id,
p_to_region_code => l_regions_rec.region_code
) and
(l_regions_rec.parent_region_application_id is not null) and
(l_regions_rec.parent_region_code is not null) then
AK_FLOW_PVT.CREATE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => l_regions_rec.flow_application_id,
p_flow_code => l_regions_rec.flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => l_regions_rec.page_application_id,
p_from_page_code => l_regions_rec.page_code,
p_from_region_appl_id => l_regions_rec.parent_region_application_id,
p_from_region_code => l_regions_rec.parent_region_code,
p_to_page_appl_id => l_regions_rec.page_application_id,
p_to_page_code => l_regions_rec.page_code,
p_to_region_appl_id => l_regions_rec.region_application_id,
p_to_region_code => l_regions_rec.region_code,
p_application_id => l_regions_rec.flow_application_id,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
RAISE FND_API.G_EXC_ERROR;
end if;
end if; --/* if l_return_status */
end if;
end if;

update AK_FLOW_PAGE_REGIONS set
DISPLAY_SEQUENCE = l_regions_rec.display_sequence,
REGION_STYLE = l_regions_rec.region_style,
NUM_COLUMNS = l_regions_rec.num_columns,
PARENT_REGION_APPLICATION_ID =l_regions_rec.parent_region_application_id,
PARENT_REGION_CODE = l_regions_rec.parent_region_code,
ICX_CUSTOM_CALL = l_regions_rec.icx_custom_call,
ATTRIBUTE_CATEGORY = l_regions_rec.attribute_category,
ATTRIBUTE1 = l_regions_rec.attribute1,
ATTRIBUTE2 = l_regions_rec.attribute2,
ATTRIBUTE3 = l_regions_rec.attribute3,
ATTRIBUTE4 = l_regions_rec.attribute4,
ATTRIBUTE5 = l_regions_rec.attribute5,
ATTRIBUTE6 = l_regions_rec.attribute6,
ATTRIBUTE7 = l_regions_rec.attribute7,
ATTRIBUTE8 = l_regions_rec.attribute8,
ATTRIBUTE9 = l_regions_rec.attribute9,
ATTRIBUTE10 = l_regions_rec.attribute10,
ATTRIBUTE11 = l_regions_rec.attribute11,
ATTRIBUTE12 = l_regions_rec.attribute12,
ATTRIBUTE13 = l_regions_rec.attribute13,
ATTRIBUTE14 = l_regions_rec.attribute14,
ATTRIBUTE15 = l_regions_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   PAGE_APPLICATION_ID = p_page_application_id
and   PAGE_CODE = p_page_code
and   REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
--  commit;


--
-- Set current region as the primary region of the flow page if
-- p_set_primary_region is 'Y'.
--
if (p_set_primary_region = 'Y') then
AK_FLOW_PVT.UPDATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => l_msg_count,
p_msg_data => l_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_primary_region_appl_id => p_region_application_id,
p_primary_region_code => p_region_code,
p_created_by => l_created_by,
p_creation_date => l_creation_date,
p_last_updated_by => l_last_updated_by,
p_last_update_date => l_last_update_date,
p_last_update_login => l_last_update_login,
p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag
);
if (l_return_status = FND_API.G_RET_STS_ERROR) or
(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_PAGE_REGION_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
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
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_page_region;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REGION_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_page_region;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_page_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_PAGE_REGION;

--=======================================================
--  Procedure   UPDATE_PAGE_REGION_ITEM
--
--  Usage       Private API for updating a flow page region item.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a flow page region item using the
--              given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_PAGE_REGION_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_page_application_id      IN      NUMBER,
p_page_code                IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_to_page_appl_id          IN      NUMBER := FND_API.G_MISS_NUM,
p_to_page_code             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_url_attribute_appl_id IN      NUMBER := FND_API.G_MISS_NUM,
p_to_url_attribute_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
from  AK_FLOW_PAGE_REGION_ITEMS
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   page_application_id = p_page_application_id
and   page_code = p_page_code
and   region_application_id = p_region_application_id
and   region_code = p_region_code
and   attribute_application_id = p_attribute_application_id
and   attribute_code = p_attribute_code
for   update of to_page_appl_id;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Page_Region_Item';
l_created_by             number;
l_creation_date          date;
l_error                  boolean;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_items_rec              ak_flow_page_region_items%ROWTYPE;
l_return_status          varchar2(1);
l_file_version	   number;
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

savepoint start_update_item;

select userenv('LANG') into l_lang
from dual;

--
-- retrieve ak_flow_page_region_items row if it exists
--
open l_get_row_csr;
fetch l_get_row_csr into l_items_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--
-- validate table columns passed in
--
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_to_page_appl_id => p_to_page_appl_id,
p_to_page_code => p_to_page_code,
p_to_url_attribute_appl_id => p_to_url_attribute_appl_id,
p_to_url_attribute_code => p_to_url_attribute_code,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

--** Load record to be updated to the database **
--** - first load nullable columns **

if (p_to_page_appl_id <> FND_API.G_MISS_NUM) or
(p_to_page_appl_id is null) then
l_items_rec.to_page_appl_id := p_to_page_appl_id;
end if;
if (p_to_page_code <> FND_API.G_MISS_CHAR) or
(p_to_page_code is null) then
l_items_rec.to_page_code := p_to_page_code;
end if;
if (p_to_url_attribute_appl_id <> FND_API.G_MISS_NUM) or
(p_to_url_attribute_appl_id is null) then
l_items_rec.to_url_attribute_appl_id := p_to_url_attribute_appl_id;
end if;
if (p_to_page_code <> FND_API.G_MISS_CHAR) or
(p_to_page_code is null) then
l_items_rec.to_url_attribute_code := p_to_url_attribute_code;
end if;
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_items_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_items_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_items_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_items_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_items_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_items_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_items_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_items_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_items_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_items_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_items_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_items_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_items_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_items_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_items_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_items_rec.attribute15 := p_attribute15;
end if;

--** - next, load non-null columns **
--
-- none

--
-- - either to_page or to_url_attribute must be specified,
--
if  (l_items_rec.to_page_code is null)  and
(l_items_rec.to_url_attribute_code is null) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_NO_LINK_SELECTED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--
-- - cannot specify both to_page and to_url_attribute
--
if  ( ( (l_items_rec.to_page_code is not null) and
(l_items_rec.to_page_code <> FND_API.G_MISS_CHAR) ) or
( (l_items_rec.to_page_appl_id is not null) and
(l_items_rec.to_page_appl_id <> FND_API.G_MISS_NUM) ) ) and
( ( (l_items_rec.to_url_attribute_code is not null) and
(l_items_rec.to_url_attribute_code <> FND_API.G_MISS_CHAR) ) or
( (l_items_rec.to_url_attribute_appl_id is not null) and
(l_items_rec.to_url_attribute_appl_id <> FND_API.G_MISS_NUM) ) ) then
l_error := TRUE;
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_TWO_LINK_SELECTED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
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
       p_db_last_updated_by => l_items_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_items_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_FLOW_PAGE_REGION_ITEMS set
TO_PAGE_APPL_ID = l_items_rec.to_page_appl_id,
TO_PAGE_CODE = l_items_rec.to_page_code,
TO_URL_ATTRIBUTE_APPL_ID = l_items_rec.to_url_attribute_appl_id,
TO_URL_ATTRIBUTE_CODE = l_items_rec.to_url_attribute_code,
ATTRIBUTE_CATEGORY = l_items_rec.attribute_category,
ATTRIBUTE1 = l_items_rec.attribute1,
ATTRIBUTE2 = l_items_rec.attribute2,
ATTRIBUTE3 = l_items_rec.attribute3,
ATTRIBUTE4 = l_items_rec.attribute4,
ATTRIBUTE5 = l_items_rec.attribute5,
ATTRIBUTE6 = l_items_rec.attribute6,
ATTRIBUTE7 = l_items_rec.attribute7,
ATTRIBUTE8 = l_items_rec.attribute8,
ATTRIBUTE9 = l_items_rec.attribute9,
ATTRIBUTE10 = l_items_rec.attribute10,
ATTRIBUTE11 = l_items_rec.attribute11,
ATTRIBUTE12 = l_items_rec.attribute12,
ATTRIBUTE13 = l_items_rec.attribute13,
ATTRIBUTE14 = l_items_rec.attribute14,
ATTRIBUTE15 = l_items_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where FLOW_APPLICATION_ID = p_flow_application_id
and   FLOW_CODE = p_flow_code
and   PAGE_APPLICATION_ID = p_page_application_id
and   PAGE_CODE = p_page_code
and   REGION_APPLICATION_ID = p_region_application_id
and   REGION_CODE = p_region_code
and   ATTRIBUTE_APPLICATION_ID = p_attribute_application_id
and   ATTRIBUTE_CODE = p_attribute_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_UPDATE_FAILED');
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
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
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
' ' || p_attribute_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_item;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_PG_REG_ITEM_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || to_char(p_page_application_id) ||
' ' || p_page_code ||
' ' || to_char(p_region_application_id) ||
' ' || p_region_code ||
' ' || to_char(p_attribute_application_id)||
' ' || p_attribute_code ||
' ' || p_to_page_code ||
' ' || p_to_url_attribute_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_item;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_PAGE_REGION_ITEM;

--=======================================================
--  Procedure   UPDATE_REGION_RELATION
--
--  Usage       Private API for updating a flow region relation.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a flow region relation using the
--              given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Region Relation columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_REGION_RELATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_flow_application_id      IN      NUMBER,
p_flow_code                IN      VARCHAR2,
p_foreign_key_name         IN      VARCHAR2,
p_from_page_appl_id        IN      NUMBER,
p_from_page_code           IN      VARCHAR2,
p_from_region_appl_id      IN      NUMBER,
p_from_region_code         IN      VARCHAR2,
p_to_page_appl_id          IN      NUMBER,
p_to_page_code             IN      VARCHAR2,
p_to_region_appl_id        IN      NUMBER,
p_to_region_code           IN      VARCHAR2,
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
from  AK_FLOW_REGION_RELATIONS
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    foreign_key_name = p_foreign_key_name
and    from_page_appl_id = p_from_page_appl_id
and    from_page_code = p_from_page_code
and    from_region_appl_id = p_from_region_appl_id
and    from_region_code = p_from_region_code
and    to_page_appl_id = p_to_page_appl_id
and    to_page_code = p_to_page_code
and    to_region_appl_id = p_to_region_appl_id
and    to_region_code = p_to_region_code
for    update of application_id;
l_api_version_number     CONSTANT number := 1.0;
l_api_name               CONSTANT varchar2(30) := 'Update_Region_Relation';
l_created_by             number;
l_creation_date          date;
l_relations_rec          AK_FLOW_REGION_RELATIONS%ROWTYPE;
l_lang                   varchar2(30);
l_last_update_date       date;
l_last_update_login      number;
l_last_updated_by        number;
l_return_status          varchar2(1);
l_file_version	   number;
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

savepoint start_update_relation;

select userenv('LANG') into l_lang
from dual;

--** retrieve ak_flow_region_relations row if it exists **
open l_get_row_csr;
fetch l_get_row_csr into l_relations_rec;
if (l_get_row_csr%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RELATION_DOES_NOT_EXIST');
FND_MSG_PUB.Add;
end if;
close l_get_row_csr;
raise FND_API.G_EXC_ERROR;
end if;
close l_get_row_csr;

--** validate table columns passed in **
if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
if not AK_FLOW3_PVT.VALIDATE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_foreign_key_name => p_foreign_key_name,
p_from_page_appl_id => p_from_page_appl_id,
p_from_page_code => p_from_page_code,
p_from_region_appl_id => p_from_region_appl_id,
p_from_region_code => p_from_region_code,
p_to_page_appl_id => p_to_page_appl_id,
p_to_page_code => p_to_page_code,
p_to_region_appl_id => p_to_region_appl_id,
p_to_region_code => p_to_region_code,
p_application_id => p_application_id,
p_caller => AK_ON_OBJECTS_PVT.G_UPDATE,
p_pass => p_pass
) then
-- Do not raise an error if it's the first pass
if (p_pass = 1) then
p_copy_redo_flag := TRUE;
else
raise FND_API.G_EXC_ERROR;
end if;
end if;
end if;

-- Load record to be updated to the database
-- - first load nullable columns
--
if (p_attribute_category <> FND_API.G_MISS_CHAR) or
(p_attribute_category is null) then
l_relations_rec.attribute_category := p_attribute_category;
end if;
if (p_attribute1 <> FND_API.G_MISS_CHAR) or
(p_attribute1 is null) then
l_relations_rec.attribute1 := p_attribute1;
end if;
if (p_attribute2 <> FND_API.G_MISS_CHAR) or
(p_attribute2 is null) then
l_relations_rec.attribute2 := p_attribute2;
end if;
if (p_attribute3 <> FND_API.G_MISS_CHAR) or
(p_attribute3 is null) then
l_relations_rec.attribute3 := p_attribute3;
end if;
if (p_attribute4 <> FND_API.G_MISS_CHAR) or
(p_attribute4 is null) then
l_relations_rec.attribute4 := p_attribute4;
end if;
if (p_attribute5 <> FND_API.G_MISS_CHAR) or
(p_attribute5 is null) then
l_relations_rec.attribute5 := p_attribute5;
end if;
if (p_attribute6 <> FND_API.G_MISS_CHAR) or
(p_attribute6 is null) then
l_relations_rec.attribute6 := p_attribute6;
end if;
if (p_attribute7 <> FND_API.G_MISS_CHAR) or
(p_attribute7 is null) then
l_relations_rec.attribute7 := p_attribute7;
end if;
if (p_attribute8 <> FND_API.G_MISS_CHAR) or
(p_attribute8 is null) then
l_relations_rec.attribute8 := p_attribute8;
end if;
if (p_attribute9 <> FND_API.G_MISS_CHAR) or
(p_attribute9 is null) then
l_relations_rec.attribute9 := p_attribute9;
end if;
if (p_attribute10 <> FND_API.G_MISS_CHAR) or
(p_attribute10 is null) then
l_relations_rec.attribute10 := p_attribute10;
end if;
if (p_attribute11 <> FND_API.G_MISS_CHAR) or
(p_attribute11 is null) then
l_relations_rec.attribute11 := p_attribute11;
end if;
if (p_attribute12 <> FND_API.G_MISS_CHAR) or
(p_attribute12 is null) then
l_relations_rec.attribute12 := p_attribute12;
end if;
if (p_attribute13 <> FND_API.G_MISS_CHAR) or
(p_attribute13 is null) then
l_relations_rec.attribute13 := p_attribute13;
end if;
if (p_attribute14 <> FND_API.G_MISS_CHAR) or
(p_attribute14 is null) then
l_relations_rec.attribute14 := p_attribute14;
end if;
if (p_attribute15 <> FND_API.G_MISS_CHAR) or
(p_attribute15 is null) then
l_relations_rec.attribute15 := p_attribute15;
end if;

-- next, load non-null, non-key columns

if (p_application_id <> FND_API.G_MISS_NUM) then
l_relations_rec.application_id := p_application_id;
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
       p_db_last_updated_by => l_relations_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_relations_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then

update AK_FLOW_REGION_RELATIONS set
APPLICATION_ID = l_relations_rec.application_id,
ATTRIBUTE_CATEGORY = l_relations_rec.attribute_category,
ATTRIBUTE1 = l_relations_rec.attribute1,
ATTRIBUTE2 = l_relations_rec.attribute2,
ATTRIBUTE3 = l_relations_rec.attribute3,
ATTRIBUTE4 = l_relations_rec.attribute4,
ATTRIBUTE5 = l_relations_rec.attribute5,
ATTRIBUTE6 = l_relations_rec.attribute6,
ATTRIBUTE7 = l_relations_rec.attribute7,
ATTRIBUTE8 = l_relations_rec.attribute8,
ATTRIBUTE9 = l_relations_rec.attribute9,
ATTRIBUTE10 = l_relations_rec.attribute10,
ATTRIBUTE11 = l_relations_rec.attribute11,
ATTRIBUTE12 = l_relations_rec.attribute12,
ATTRIBUTE13 = l_relations_rec.attribute13,
ATTRIBUTE14 = l_relations_rec.attribute14,
ATTRIBUTE15 = l_relations_rec.attribute15,
LAST_UPDATE_DATE = l_last_update_date,
LAST_UPDATED_BY = l_last_updated_by,
LAST_UPDATE_LOGIN = l_last_update_login
where  flow_application_id = p_flow_application_id
and    flow_code = p_flow_code
and    foreign_key_name = p_foreign_key_name
and    from_page_appl_id = p_from_page_appl_id
and    from_page_code = p_from_page_code
and    from_region_appl_id = p_from_region_appl_id
and    from_region_code = p_from_region_code
and    to_page_appl_id = p_to_page_appl_id
and    to_page_code = p_to_page_code
and    to_region_appl_id = p_to_region_appl_id
and    to_region_code = p_to_region_code;
if (sql%notfound) then
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
FND_MESSAGE.SET_NAME('AK','AK_RELATION_DOES_NOT_EXIST');
FND_MESSAGE.SET_TOKEN('OBJECT','EC_FLOW_REGION_RELATIONSHIP', TRUE);
FND_MSG_PUB.Add;
end if;
raise FND_API.G_EXC_ERROR;
end if;

--  /** commit the update **/
--  commit;

if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
FND_MESSAGE.SET_NAME('AK','AK_RELATION_UPDATED');
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
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
FND_MESSAGE.SET_NAME('AK','AK_RELATION_VALUE_ERROR');
FND_MESSAGE.SET_TOKEN('OBJECT', 'EC_FLOW_REGION_RELATIONSHIP',TRUE);
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;
rollback to start_update_relation;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
FND_MESSAGE.SET_NAME('AK','AK_RELATION_NOT_UPDATED');
FND_MESSAGE.SET_TOKEN('OBJECT', 'EC_FLOW_REGION_RELATIONSHIP',TRUE);
FND_MESSAGE.SET_TOKEN('KEY', to_char(p_flow_application_id) ||
' ' || p_flow_code ||
' ' || p_foreign_key_name ||
' ' || to_char(p_from_page_appl_id) ||
' ' || p_from_page_code ||
' ' || to_char(p_from_region_appl_id) ||
' ' || p_from_region_code ||
' ' || to_char(p_to_page_appl_id) ||
' ' || p_to_page_code ||
' ' || to_char(p_to_region_appl_id) ||
' ' || p_to_region_code);
FND_MSG_PUB.Add;
end if;
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_relation;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_relation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
end UPDATE_REGION_RELATION;

--=======================================================
--  Procedure   CHECK_DISPLAY_SEQUENCE
--
--  Usage       Private API for making sure that the
--              display sequence is unique for a given flow code.
--
--  Desc        This API updates a page region, if necessary
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Page Region columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CHECK_DISPLAY_SEQUENCE (  p_validation_level        IN      NUMBER,
p_flow_code               IN      VARCHAR2,
p_flow_application_id     IN      NUMBER,
p_page_code               IN      VARCHAR2,
p_page_application_id     IN      NUMBER,
p_region_code             IN      VARCHAR2,
p_region_application_id   IN      NUMBER,
p_display_sequence        IN      NUMBER,
p_return_status           OUT NOCOPY     VARCHAR2,
p_msg_count               OUT NOCOPY     NUMBER,
p_msg_data                OUT NOCOPY     VARCHAR2,
p_pass                    IN      NUMBER,
p_copy_redo_flag          IN OUT NOCOPY  BOOLEAN
) is
cursor l_fpr_csr( flow_code_param IN VARCHAR2,
flow_application_id_param IN NUMBER,
page_code_param IN VARCHAR2,
page_application_id_param IN NUMBER,
display_sequence_param IN NUMBER) is
select *
from   ak_flow_page_regions
where  flow_code = flow_code_param
and    flow_application_id = flow_application_id_param
and    page_code = page_code_param
and    page_application_id = page_application_id_param
and    display_sequence = display_sequence_param;

l_api_name                CONSTANT varchar2(30) := 'Check_Display_Sequence';
l_new_display_sequence    NUMBER;
l_return_status           VARCHAR2(1);
l_fpr_rec                 ak_flow_page_regions%ROWTYPE;
l_orig_fpr_rec            ak_flow_page_regions%ROWTYPE;

begin
l_return_status := FND_API.G_RET_STS_SUCCESS;
open l_fpr_csr(   p_flow_code,
p_flow_application_id,
p_page_code,
p_page_application_id,
p_display_sequence);
fetch l_fpr_csr into l_fpr_rec;

--** Does it exists?
if (l_fpr_csr%found) then
if ((l_fpr_rec.region_code <> p_region_code) or
(l_fpr_rec.region_application_id <> p_region_application_id)) then

--** Save it.
l_orig_fpr_rec := l_fpr_rec;

--** Bump up the display sequence value of the page regions record
l_new_display_sequence := p_display_sequence + 1000000;
close l_fpr_csr;
open l_fpr_csr( p_flow_code,
p_flow_application_id,
p_page_code,
p_page_application_id,
l_new_display_sequence);
fetch l_fpr_csr into l_fpr_rec;

--** Keep looping until you can't find a record.
while (l_fpr_csr%found) loop
close l_fpr_csr;
l_new_display_sequence := l_new_display_sequence + 1;
open l_fpr_csr(   p_flow_code,
p_flow_application_id,
p_page_code,
p_page_application_id,
l_new_display_sequence);
fetch l_fpr_csr into l_fpr_rec;
end loop;

--** ASSUMPTION: You have found a unique sequence number for this flow_code + page_code combination.
AK_FLOW_PVT.UPDATE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => l_orig_fpr_rec.flow_application_id,
p_flow_code => l_orig_fpr_rec.flow_code,
p_page_application_id => l_orig_fpr_rec.page_application_id,
p_page_code => l_orig_fpr_rec.page_code,
p_region_application_id => l_orig_fpr_rec.region_application_id,
p_region_code => l_orig_fpr_rec.region_code,
p_display_sequence => l_new_display_sequence,
p_region_style => l_orig_fpr_rec.region_style,
p_num_columns => l_orig_fpr_rec.num_columns,
p_parent_region_application_id => l_orig_fpr_rec.parent_region_application_id,
p_parent_region_code => l_orig_fpr_rec.parent_region_code,
p_icx_custom_call => l_orig_fpr_rec.icx_custom_call,

p_pass => p_pass,
p_copy_redo_flag => p_copy_redo_flag);
end if;
end if;

p_return_status := l_return_status;
close l_fpr_csr;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;

end CHECK_DISPLAY_SEQUENCE;

end AK_FLOW_PVT;

/
