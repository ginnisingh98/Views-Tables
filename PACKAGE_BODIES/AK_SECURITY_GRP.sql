--------------------------------------------------------
--  DDL for Package Body AK_SECURITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_SECURITY_GRP" as
/* $Header: akdgsecb.pls 120.2 2005/09/15 22:26:42 tshort ship $ */

--=======================================================
--  Procedure   DOWNLOAD_RESP
--
--  Usage       Group API for downloading attributes
--
--  Desc        This API first write out standard loader
--              file header for attributes to a flat file.
--              Then it calls the private API to extract the
--              attributes selected by application ID or by
--              key values from the database to the output file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_directory
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following three parameters must be given:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all attributes for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_excluded_pk_tbl : IN optional
--                  If given, only excluded_items whose key values are
--                  included in this table will be written to the
--                  output file.
--              p_resp_pk_tbl : IN optional
--                  If given, only resp_sec_attributes whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_RESP (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_excluded_pk_tbl          IN      AK_SECURITY_PUB.Resp_PK_Tbl_Type :=
AK_SECURITY_PUB.G_MISS_RESP_PK_TBL,
p_resp_pk_tbl              IN      AK_SECURITY_PUB.Resp_PK_Tbl_Type :=
AK_SECURITY_PUB.G_MISS_RESP_PK_TBL
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download Resp';
l_application_id     number;
l_index              NUMBER;
l_index_out          NUMBER;
l_nls_language       VARCHAR2(30);
l_return_status      varchar2(1);
begin
--
-- Check verion number
--
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

savepoint Start_download;
if (AK_DOWNLOAD_GRP.G_WRITE_HEADER) then
--
-- Call private download procedure to verify parameters,
-- load application ID, and write header information such
-- as nls_language and codeset to data file.
--
AK_ON_OBJECTS_PVT.download_header(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_nls_language => p_nls_language,
p_application_id => p_application_id,
p_application_short_name => p_application_short_name,
p_table_size => p_resp_pk_tbl.count,
p_download_by_object => AK_ON_OBJECTS_PVT.G_SECURITY,
p_nls_language_out => l_nls_language,
p_application_id_out => l_application_id
);
else
l_application_id := p_application_id;
select userenv('LANG') into l_nls_language
from dual;
end if;

--
-- If API call returns with an error status...
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

--
-- - call the download procedure for attributes to retrieve the
--   selected attributes from the database into a table of type
--   AK_ON_OBJECTS_PUB.Buffer_Tbl_Type.
--
-- dbms_output.put_line('Start downloading excluded items');

AK_SECURITY_PVT.DOWNLOAD_EXCLUDED(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_excluded_pk_tbl => p_excluded_pk_tbl,
p_nls_language => l_nls_language
);

--
-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

AK_SECURITY_PVT.DOWNLOAD_RESP_SEC(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_resp_pk_tbl => p_resp_pk_tbl,
p_nls_language => l_nls_language
);

--
-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
--
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DOWNLOAD_RESP;

--=======================================================
--  Procedure   CREATE_EXCLUDED_ITEM
--
--  Usage       Group API for creating an attribute
--
--  Desc        Calls the private API to creates an attribute
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
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
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Excluded_Items';
l_return_status      VARCHAR2(1);
begin
/* Check API version number */
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
-- Call private procedure to create an excluded item
--
AK_SECURITY_PVT.CREATE_EXCLUDED_ITEM(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_responsibility_id => p_responsibility_id,
p_resp_application_id => p_resp_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login
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
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_excluded_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_create_excluded_item;
end CREATE_EXCLUDED_ITEM;

--=======================================================
--  Procedure   CREATE_RESP_SECURITY_ATTR
--
--  Usage       Group API for creating an attribute
--
--  Desc        Calls the private API to creates an attribute
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
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
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Resp_Sec_Attr';
l_return_status      VARCHAR2(1);
begin
/* Check API version number */
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

savepoint start_create_resp_sec_attr;

--
-- Call private procedure to create a resp security attribute
--
AK_SECURITY_PVT.CREATE_RESP_SECURITY_ATTR(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_responsibility_id => p_responsibility_id,
p_resp_application_id => p_resp_application_id,
p_attribute_code => p_attribute_code,
p_attribute_application_id => p_attribute_application_id,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login
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
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_resp_sec_attr;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_create_resp_sec_attr;
end CREATE_RESP_SECURITY_ATTR;

end AK_SECURITY_grp;

/
