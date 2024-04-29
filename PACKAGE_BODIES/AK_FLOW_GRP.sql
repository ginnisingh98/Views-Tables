--------------------------------------------------------
--  DDL for Package Body AK_FLOW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_FLOW_GRP" as
/* $Header: akdgflob.pls 120.2 2005/09/15 22:26:33 tshort ship $ */

--=======================================================
--  Procedure   CREATE_FLOW
--
--  Usage       Group API for creating a flow
--
--  Desc        Calls the private API to create a flow
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow columns except primary_page_appl_id and
--              primary_page_code since there are no
--              flow pages for this flow at this time.
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Flow';
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

savepoint start_create_flow;

-- Call private procedure to create a flow
AK_FLOW_PVT.CREATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_name => p_name,
p_description => p_description,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_flow;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_flow;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_FLOW;

--=======================================================
--  Procedure   CREATE_PAGE
--
--  Usage       Group API for creating a flow page
--
--  Desc        Calls the private API to create a flow page
--              using the given info
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_page         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Page';
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

savepoint start_create_page;

-- Call private procedure to create a page
AK_FLOW_PVT.CREATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_name => p_name,
p_description => p_description,
p_set_primary_page => p_set_primary_page,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_page;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_page;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_PAGE;

--=======================================================
--  Procedure   CREATE_PAGE_REGION
--
--  Usage       Group API for creating a flow page region
--
--  Desc        Calls the private API to create a flow page region
--              using the given info
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Page_Region';
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

savepoint start_create_page_region;

-- Call private procedure to create a page region
AK_FLOW_PVT.CREATE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_page_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_page_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_PAGE_REGION;

--=======================================================
--  Procedure   CREATE_PAGE_REGION_ITEM
--
--  Usage       Group API for creating a page region item
--
--  Desc        Calls the private API to create a page region
--              item using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Page Region Item columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Page_Region_Item';
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

savepoint start_create_item;

-- Call private procedure to create a page region item
AK_FLOW_PVT.CREATE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_PAGE_REGION_ITEM;

--=======================================================
--  Procedure   CREATE_REGION_RELATION
--
--  Usage       Group API for creating a flow region relation
--
--  Desc        Calls the private API to create a flow region
--              relation using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Region Relation columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Region_Relation';
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

savepoint start_create_relation;

-- Call private procedure to create a flow region relation
AK_FLOW_PVT.CREATE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_relation;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_relation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_REGION_RELATION;

--=======================================================
--  Procedure   DELETE_FLOW
--
--  Usage       Group API for deleting a flow
--
--  Desc        Calls the private API to delete a flow
--              with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Flow';
l_return_status      VARCHAR2(1);
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

savepoint start_delete_flow;

-- Call private procedure to delete a flow
AK_FLOW_PVT.DELETE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_flow;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_flow;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_FLOW;

--=======================================================
--  Procedure   DELETE_PAGE
--
--  Usage       Group API for deleting a flow page
--
--  Desc        Calls the private API to delete a flow page
--              with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Page';
l_return_status      VARCHAR2(1);
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

savepoint start_delete_page;

-- Call private procedure to delete a page
AK_FLOW_PVT.DELETE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_page;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_page;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_PAGE;

--=======================================================
--  Procedure   DELETE_PAGE_REGION
--
--  Usage       Group API for deleting a flow page region
--
--  Desc        Calls the private API to delete a flow page
--              region with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Page_Region';
l_return_status      VARCHAR2(1);
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

savepoint start_delete_page_region;

-- Call private procedure to create a page region
AK_FLOW_PVT.DELETE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_page_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_page_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_PAGE_REGION;

--=======================================================
--  Procedure   DELETE_PAGE_REGION_ITEM
--
--  Usage       Group API for deleting a flow page region item
--
--  Desc        Calls the private API to delete a flow page
--              region item with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Page_Region_Item';
l_return_status      VARCHAR2(1);
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

savepoint start_delete_item;

-- Call private procedure to delete a page region item
AK_FLOW_PVT.DELETE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_region_application_id => p_region_application_id,
p_region_code => p_region_code,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_PAGE_REGION_ITEM;

--=======================================================
--  Procedure   DELETE_REGION_RELATION
--
--  Usage       Group API for deleting a flow region relation
--
--  Desc        Calls the private API to delete a flow region
--              relation with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Region_Relation';
l_return_status      VARCHAR2(1);
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

savepoint start_delete_relation;

-- Call private procedure to delete a flow region relation
AK_FLOW_PVT.DELETE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_delete_cascade => p_delete_cascade
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_delete_relation;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_relation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_REGION_RELATION;

--===========================================================
--  Procedure   DOWNLOAD_FLOW
--
--  Usage       Group API for downloading flows
--
--  Desc        This API first write out standard loader
--              file header for flows to a flat file.
--              Then it calls the private API to extract the
--              flows selected by application ID or by
--              key values from the database to the output file.
--              If a flow is selected for writing to the loader
--              file, all its children records (including flow
--              pages, flow page regions, flow page region items,
--              and flow region relations) will also be written.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_directory : IN optional
--                  Specifies to which directory the output file should
--                  be written to. Defaults to value of profile
--                  UTL_FILE_OUT if none is specified
--              p_filename : IN required
--                  The file name of the output file to be written.
--                  Existing file with same name will be overwritten.
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all attributes for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
--              p_flow_pk_tbl : IN optional
--                  If given, only flows whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--===========================================================
procedure DOWNLOAD_FLOW (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_flow_pk_tbl              IN      AK_FLOW_PUB.Flow_PK_Tbl_Type
:= AK_FLOW_PUB.G_MISS_FLOW_PK_TBL
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Download_Flow';
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

savepoint Start_download;

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
p_table_size => p_flow_pk_tbl.count,
p_download_by_object => AK_ON_OBJECTS_PVT.G_FLOW,
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

-- - call the download procedure for flows to retrieve the
--   selected flows from the database into a table of type
--   AK_ON_OBJECTS_PUB.Buffer_Tbl_Type.
AK_FLOW2_PVT.DOWNLOAD_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_return_status => l_return_status,
p_application_id => l_application_id,
p_flow_pk_tbl => p_flow_pk_tbl,
p_nls_language => l_nls_language
);

-- If download call returns with an error status or
-- download failed to retrieve any information from the database..
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
-- dbms_output.put_line(G_PKG_NAME || 'download flow returned error:' ||
--                     l_return_status);
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
rollback to Start_download;
p_return_status := FND_API.G_RET_STS_ERROR;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to Start_download;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
FND_MSG_PUB.Count_And_Get (
p_count => p_msg_count,
p_data => p_msg_data);

end DOWNLOAD_FLOW;

--=======================================================
--  Procedure   UPDATE_FLOW
--
--  Usage       Group API for updating a flow
--
--  Desc        This API calls the private API to update
--              a flow using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow columns
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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Flow';
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

savepoint start_update_flow;

-- Call private procedure to update a flow
AK_FLOW_PVT.UPDATE_FLOW (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_primary_page_appl_id => p_primary_page_appl_id,
p_primary_page_code => p_primary_page_code,
p_name => p_name,
p_description => p_description,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_flow;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_flow;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_FLOW;

--=======================================================
--  Procedure   UPDATE_PAGE
--
--  Usage       Group API for updating a flow page
--
--  Desc        This API calls the private API to update
--              a flow page using the given info
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
p_name                     IN      VARCHAR2,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_page         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Page';
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

savepoint start_update_page;

-- Call private procedure to update a page
AK_FLOW_PVT.UPDATE_PAGE (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_flow_application_id => p_flow_application_id,
p_flow_code => p_flow_code,
p_page_application_id => p_page_application_id,
p_page_code => p_page_code,
p_primary_region_appl_id => p_primary_region_appl_id,
p_primary_region_code => p_primary_region_code,
p_name => p_name,
p_description => p_description,
p_set_primary_page => p_set_primary_page,
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_page;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_page;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_PAGE;

--=======================================================
--  Procedure   UPDATE_PAGE_REGION
--
--  Usage       Group API for updating a flow page region
--
--  Desc        This API calls the private API to update
--              a flow page region using the given info
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
p_region_style             IN      VARCHAR2,
p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_parent_region_application_id IN  NUMBER := FND_API.G_MISS_NUM,
p_parent_region_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_region       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Page_Region';
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

savepoint start_update_page_region;

-- Call private procedure to update a page region
AK_FLOW_PVT.UPDATE_PAGE_REGION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_page_region;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_page_region;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_PAGE_REGION;

--=======================================================
--  Procedure   UPDATE_PAGE_REGION_ITEM
--
--  Usage       Group API for updating a flow page region item
--
--  Desc        This API calls the private API to update
--              a flow page region item using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Page Region Item columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Page_Region_Item';
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

savepoint start_update_item;

-- Call private procedure to update a page region item
AK_FLOW_PVT.UPDATE_PAGE_REGION_ITEM (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_item;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_item;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_PAGE_REGION_ITEM;

--=======================================================
--  Procedure   UPDATE_REGION_RELATION
--
--  Usage       Group API for updating a flow region relation
--
--  Desc        This API calls the private API to update
--              a flow region relation using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Flow Region Relation columns
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
p_application_id           IN      NUMBER,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Region_Relation';
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

savepoint start_update_relation;

-- Call private procedure to update a flow region relation
AK_FLOW_PVT.UPDATE_REGION_RELATION (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
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
p_created_by => p_created_by,
p_creation_date => p_creation_date,
p_last_updated_by => p_last_updated_by,
p_last_update_date => p_last_update_date,
p_last_update_login => p_lasT_update_login,
p_pass => l_pass,
p_copy_redo_flag => l_copy_redo_flag
);

-- If API call returns with an error status...
if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
(l_return_status = FND_API.G_RET_STS_ERROR) then
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_relation;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_relation;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_REGION_RELATION;

end AK_FLOW_GRP;

/
