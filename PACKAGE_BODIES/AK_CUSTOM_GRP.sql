--------------------------------------------------------
--  DDL for Package Body AK_CUSTOM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_CUSTOM_GRP" as
/* $Header: akdgcreb.pls 120.2 2005/09/15 22:30:01 tshort noship $ */

--=======================================================
--  Procedure   CREATE_CUSTOM
--
--  Usage       Group API for creating a region
--
--  Desc        Calls the private API to create a region
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CUSTOM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code		     IN      VARCHAR2,
p_region_appl_id           IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_localization_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_org_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_site_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_web_user_id              IN      NUMBER := FND_API.G_MISS_NUM,
p_default_customization_flag  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
p_developer_mode	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_reference_path           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_name		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Custom';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_create_custom;

-- Call private procedure to create a region
AK_CUSTOM_PVT.CREATE_CUSTOM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id =>p_custom_appl_id,
p_custom_code => p_custom_code,
p_region_appl_id => p_region_appl_id,
p_region_code => p_region_code,
p_verticalization_id => p_verticalization_id,
p_localization_code => p_localization_code,
p_org_id => p_org_id,
p_site_id => p_site_id,
p_responsibility_id => p_responsibility_id,
p_web_user_id => p_web_user_id,
p_default_customization_flag => p_default_customization_flag,
p_customization_level_id => p_customization_level_id,
p_developer_mode => p_developer_mode,
p_reference_path => p_reference_path,
p_function_name => p_function_name,
p_start_date_active => p_start_date_active,
p_end_date_active => p_end_date_active,
p_name => p_name,
p_description => p_description,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Custom failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_custom;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_custom;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_CUSTOM;

--=======================================================
--  Procedure   CREATE_CUST_REGION
--
--  Usage       Group API for creating a region item
--
--  Desc        Calls the private API to creates a region item
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CUST_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_appl_id           IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_property_name	     IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_name           CONSTANT varchar2(30) := 'Create_Cust_Region';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_create_cust_region;

-- Call private procedure to create a region item
AK_CUSTOM_PVT.CREATE_CUST_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_code,
p_region_appl_id => p_region_appl_id,
p_region_code => p_region_code,
p_property_name => p_property_name,
p_property_varchar2_value => p_property_varchar2_value,
p_property_number_value => p_property_number_value,
p_criteria_join_condition => p_criteria_join_condition,
p_property_varchar2_value_tl => p_property_varchar2_value_tl,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Cust_Region failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_cust_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_cust_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_CUST_REGION;

--=======================================================
--  Procedure   CREATE_CUST_REG_ITEM
--
--  Usage       Group API for creating a region item
--
--  Desc        Calls the private API to creates a region item
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CUST_REG_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_appl_id           IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attr_appl_id	     IN      NUMBER,
p_attr_code 		     IN      VARCHAR2,
p_property_name            IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
l_api_name           CONSTANT varchar2(30) := 'Create_Cust_Reg_Item';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_create_cust_reg_item;

-- Call private procedure to create a region item
AK_CUSTOM_PVT.CREATE_CUST_REG_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_code,
p_region_appl_id => p_region_appl_id,
p_region_code => p_region_code,
p_attr_appl_id => p_attr_appl_id,
p_attr_code => p_attr_code,
p_property_name => p_property_name,
p_property_varchar2_value => p_property_varchar2_value,
p_property_number_value => p_property_number_value,
p_property_date_value => p_property_date_value,
p_property_varchar2_value_tl => p_property_varchar2_value_tl,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Cust_Reg_Item failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_cust_reg_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_cust_reg_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_CUST_REG_ITEM;

--=======================================================
--  Procedure   CREATE_CRITERIA
--
--  Usage       Group API for creating a region item
--
--  Desc        Calls the private API to creates a region item
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_CRITERIA (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_appl_id           IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attr_appl_id	     IN      NUMBER,
p_attr_code		     IN      VARCHAR2,
p_sequence_number	     IN      NUMBER,
p_operation		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_start_date_Active        IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
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
l_api_name           CONSTANT varchar2(30) := 'Create_Criteria';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_create_criteria;

-- Call private procedure to create a region item
AK_CUSTOM_PVT.CREATE_CRITERIA (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_code,
p_region_appl_id => p_region_appl_id,
p_region_code => p_region_code,
p_attr_appl_id => p_attr_appl_id,
p_attr_code => p_attr_code,
p_sequence_number => p_sequence_number,
p_operation => p_operation,
p_value_varchar2 => p_value_varchar2,
p_value_number => p_value_number,
p_value_date => p_value_date,
p_start_date_active => p_start_date_active,
p_end_date_active => p_end_date_active,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_loader_timestamp => p_loader_timestamp,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Create_Criteria failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_criteria;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_criteria;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_CRITERIA;

--=======================================================
--  Procedure   DOWNLOAD_CUSTOM
--
--  Usage       Group API for downloading customized regions
--
--  Desc        This API first write out standard loader
--              file header for regions to a flat file.
--              Then it calls the private API to extract the
--              regions selected by application ID or by
--              key values from the database to the output file.
--              If a region is selected for writing to the loader
--              file, all its children records (including region
--              items) will also be written.
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
--              One of the following three parameters must be given:
--
--              p_application_id : IN optional
--                  If given, all regions for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all regions for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_custom_pk_tbl : IN optional
--                  If given, only regions whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_CUSTOM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_custom_pk_tbl	     IN      AK_CUSTOM_PUB.Custom_PK_Tbl_Type 						:= AK_CUSTOM_PUB.G_MISS_CUSTOM_PK_TBL,
p_level		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_levelpk		     IN      VARCHAR2 := FND_API.G_MISS_CHAR
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download_Custom';
l_application_id     number;
l_buffer_tbl         AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
l_index              NUMBER;
l_index_out          NUMBER;
l_nls_language       VARCHAR2(30);
l_return_status      varchar2(1);
begin

-- Check verion number
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

savepoint Start_Custom_download;

if (AK_DOWNLOAD_GRP.G_WRITE_HEADER) then
-- Call private download procedure to verify parameters,
-- load application ID, and write header information such
-- as nls_language and codeset to data file.
AK_ON_OBJECTS_PVT.download_header(
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_nls_language => p_nls_language,
p_application_id => p_application_id,
p_application_short_name => p_application_short_name,
p_table_size => p_custom_pk_tbl.count,
p_download_by_object => AK_ON_OBJECTS_PVT.G_CUSTOM_REGION,
p_nls_language_out => l_nls_language,
p_application_id_out => l_application_id
);
else
l_application_id := p_application_id;
select userenv('LANG') into l_nls_language
from dual;
end if;

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(G_PKG_NAME || ' download_header failed');
RAISE FND_API.G_EXC_ERROR;
end if;

-- - call the download procedure for regions to retrieve the
--   selected regions and their referenced objects and attributes
--   from the database into a table of buffer.
AK_CUSTOM_PVT.DOWNLOAD_CUSTOM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_custom_pk_tbl => p_custom_pk_tbl,
p_nls_language => l_nls_language,
p_get_object_flag => 'Y',
p_level => p_level,
p_levelpk => p_levelpk
);

-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(G_PKG_NAME || 'download failed');
RAISE FND_API.G_EXC_ERROR;
end if;

--dbms_output.put_line('got ' || to_char(l_buffer_tbl.count) || ' lines');

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
rollback to Start_Custom_download;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to Start_Custom_download;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DOWNLOAD_CUSTOM;

--=======================================================
--  Procedure   UPDATE_CUSTOM
--
--  Usage       Group API for updating a region
--
--  Desc        This API calls the private API to update
--              a region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CUSTOM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id	     IN      NUMBER,
p_custom_appl_code	     IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code		     IN      VARCHAR2,
p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_localization_code	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_org_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_site_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id 	     IN      NUMBER := FND_API.G_MISS_NUM,
p_web_user_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_customization_flag   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_reference_path	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_name 		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description		     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Custom';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_update_custom;

-- Call private procedure to update a region
AK_CUSTOM_PVT.UPDATE_CUSTOM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_appl_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_verticalization_id => p_verticalization_id,
p_localization_code => p_localization_code,
p_org_id => p_org_id,
p_site_id => p_site_id,
p_responsibility_id => p_responsibility_id,
p_web_user_id => p_web_user_id,
p_default_customization_flag => p_default_customization_flag,
p_customization_level_id => p_customization_level_id,
p_developer_mode => p_developer_mode,
p_reference_path => p_reference_path,
p_function_name => p_function_name,
p_start_date_active => p_start_date_active,
p_end_date_active => p_end_date_active,
p_name => p_name,
p_description => p_description,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Custom failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_custom;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_custom;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_CUSTOM;

--=======================================================
--  Procedure   UPDATE_CUST_REGION
--
--  Usage       Group API for updating a region
--
--  Desc        This API calls the private API to update
--              a region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CUST_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_appl_code         IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_property_name	     IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Cust_Region';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_update_cust_region;

-- Call private procedure to update a region
AK_CUSTOM_PVT.UPDATE_CUST_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_appl_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_property_name => p_property_name,
p_property_varchar2_value => p_property_varchar2_value,
p_property_number_value => p_property_number_value,
p_criteria_join_condition => p_criteria_join_condition,
p_property_varchar2_value_tl => p_property_varchar2_value_tl,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Cust_Region failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_cust_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_cust_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_CUST_REGION;

--=======================================================
--  Procedure   UPDATE_CUST_REG_ITEM
--
--  Usage       Group API for updating a region
--
--  Desc        This API calls the private API to update
--              a region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CUST_REG_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_appl_code         IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_appl_id	     IN      NUMBER,
p_attribute_code	     IN      VARCHAR2,
p_property_name            IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Cust_Reg_Item';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_update_cust_reg_item;

-- Call private procedure to update a region
AK_CUSTOM_PVT.UPDATE_CUST_REG_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_appl_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_appl_id => p_attribute_appl_id,
p_attribute_code => p_attribute_code,
p_property_name => p_property_name,
p_property_varchar2_value => p_property_varchar2_value,
p_property_number_value => p_property_number_value,
p_property_date_value => p_property_date_value,
p_property_varchar2_value_tl => p_property_varchar2_value_tl,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Cust_Reg_Item failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_cust_reg_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_cust_reg_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_CUST_REG_ITEM;

--=======================================================
--  Procedure   UPDATE_CRITERIA
--
--  Usage       Group API for updating a region
--
--  Desc        This API calls the private API to update
--              a region using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_CRITERIA (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_appl_code         IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_appl_id        IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_sequence_number          IN      NUMBER,
p_operation		     IN      VARCHAR2,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active 	     IN      DATE := FND_API.G_MISS_DATE,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Criteria';
l_return_status      VARCHAR2(1);
l_pass               NUMBER := 2;
l_copy_redo_flag     BOOLEAN := FALSE;
begin
-- Check API version number
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

savepoint start_update_cust_reg_item;

-- Call private procedure to update a region
AK_CUSTOM_PVT.UPDATE_CRITERIA (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_custom_appl_id => p_custom_appl_id,
p_custom_code => p_custom_appl_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_appl_id => p_attribute_appl_id,
p_attribute_code => p_attribute_code,
p_sequence_number => p_sequence_number,
p_operation => p_operation,
p_value_varchar2 => p_value_varchar2,
p_value_number => p_value_number,
p_value_date => p_value_date,
p_start_date_active => p_start_date_active,
p_end_date_Active => p_end_date_active,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_last_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
--dbms_output.put_line(l_api_name || ' Update_Criteria failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_critieria;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_criteria;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_CRITERIA;

end AK_CUSTOM_GRP;

/
