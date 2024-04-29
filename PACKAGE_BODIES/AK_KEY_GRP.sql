--------------------------------------------------------
--  DDL for Package Body AK_KEY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_KEY_GRP" as
/* $Header: akdgkeyb.pls 120.2 2005/09/15 22:26:34 tshort ship $ */

--=======================================================
--  Procedure   CREATE_FOREIGN_KEY
--
--  Usage       Group API for creating a foreign key
--
--  Desc        Calls the private API to creates a foreign key
--              using the given info
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
p_from_to_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_from_to_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Foreign_Key';
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

savepoint start_create_foreign_key;

-- Call private procedure to create a foreign key
AK_KEY_PVT.CREATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_database_object_name => p_database_object_name,
p_unique_key_name => p_unique_key_name,
p_application_id => p_application_id,
p_from_to_name => p_from_to_name,
p_from_to_description => p_from_to_description,
p_to_from_name => p_to_from_name,
p_to_from_description => p_to_from_description,
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
--dbms_output.put_line(l_api_name || ' Create_Foreign_Key failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_foreign_key;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_foreign_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_FOREIGN_KEY;

--=======================================================
--  Procedure   CREATE_FOREIGN_KEY_COLUMN
--
--  Usage       Group API for creating a foreign key column record
--
--  Desc        Calls the private API to creates a foreign key
--              column record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key Column columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Foreign_Key_Column';
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

savepoint start_create_key_column;

-- Call private procedure to create an foreign key column
AK_KEY_PVT.CREATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_foreign_key_sequence => p_foreign_key_sequence,
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
--dbms_output.put_line(l_api_name || ' Create_Foreign_Key_Column failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_key_column;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_FOREIGN_KEY_COLUMN;

--=======================================================
--  Procedure   CREATE_UNIQUE_KEY
--
--  Usage       Group API for creating a unique key
--
--  Desc        Calls the private API to creates a unique key
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Unique_Key';
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

savepoint start_create_unique_key;

-- Call private procedure to create a primary key
AK_KEY_PVT.CREATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_database_object_name => p_database_object_name,
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
--dbms_output.put_line(l_api_name || ' Create_Unique_Key failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_unique_key;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_create_unique_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end CREATE_UNIQUE_KEY;

--=======================================================
--  Procedure   CREATE_UNIQUE_KEY_COLUMN
--
--  Usage       Group API for creating a unique key column record
--
--  Desc        Calls the private API to creates a unique key
--              column record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key Column columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Create_Unique_Key_Column';
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

savepoint start_create_key_column;

-- Call private procedure to create a primary key column
AK_KEY_PVT.CREATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_unique_key_sequence => p_unique_key_sequence,
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
--dbms_output.put_line(l_api_name || ' Create_Unique_Key_Column failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_create_key_column;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
rollback to start_create_key_column;
end CREATE_UNIQUE_KEY_COLUMN;

--=======================================================
--  Procedure   DELETE_FOREIGN_KEY
--
--  Usage       Group API for deleting a foreign key record
--
--  Desc        Calls the private API to deletes a foreign key
--              record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_foreign_key_name : IN required
--                  Name of the Foreign Key to be deleted.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Foreign_Key';
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

savepoint start_delete_foreign_key;

-- Call private procedure to create a foreign key
AK_KEY_PVT.DELETE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
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
rollback to start_delete_foreign_key;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_foreign_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_FOREIGN_KEY;

--=======================================================
--  Procedure   DELETE_FOREIGN_KEY_COLUMN
--
--  Usage       Group API for deleting a foreign key column record
--
--  Desc        Calls the private API to deletes a foreign key
--              column record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_foreign_key_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key for the Foreign Key Column record to be deleted.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Foreign_Key_Column';
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

savepoint start_delete_key_column;

-- Call private procedure to create a foreign key
AK_KEY_PVT.DELETE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
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
rollback to start_delete_key_column;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_FOREIGN_KEY_COLUMN;

--=======================================================
--  Procedure   DELETE_UNIQUE_KEY
--
--  Usage       Group API for deleting a unique key record
--
--  Desc        Calls the private API to deletes a unique key
--              record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_unique_key_name : IN required
--                  Name of the Unique Key to be deleted.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Unique_Key';
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

savepoint start_delete_unique_key;

-- Call private procedure to create a foreign key
AK_KEY_PVT.DELETE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
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
rollback to start_delete_unique_key;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_unique_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_UNIQUE_KEY;

--=======================================================
--  Procedure   DELETE_UNIQUE_KEY_COLUMN
--
--  Usage       Group API for deleting a Unique key column record
--
--  Desc        Calls the private API to deletes a unique key
--              column record with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_unique_key_name : IN required
--              p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key for the Unique Key Column record to be deleted.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Delete_Unique_Key_Column';
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

savepoint start_delete_key_column;

-- Call private procedure to create a foreign key
AK_KEY_PVT.DELETE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
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
rollback to start_delete_key_column;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_delete_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end DELETE_UNIQUE_KEY_COLUMN;

--=======================================================
--  Procedure   UPDATE_FOREIGN_KEY
--
--  Usage       Group API for updating a foreign key record
--
--  Desc        This API calls the private API to update
--              a foreign key record using the given info
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
p_from_to_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_from_to_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_name             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_to_from_description      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Foreign_Key';
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

savepoint start_update_foreign_key;

-- Call private procedure to update a foreign key
AK_KEY_PVT.UPDATE_FOREIGN_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_database_object_name => p_database_object_name,
p_unique_key_name => p_unique_key_name,
p_application_id => p_application_id,
p_from_to_name => p_from_to_name,
p_from_to_description => p_from_to_description,
p_to_from_name => p_to_from_name,
p_to_from_description => p_to_from_description,
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
--dbms_output.put_line(l_api_name || ' Update_Foreign_Key failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_foreign_key;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_foreign_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_FOREIGN_KEY;

--=======================================================
--  Procedure   UPDATE_FOREIGN_KEY_COLUMN
--
--  Usage       Group API for updating a foreign key column record
--
--  Desc        This API calls the private API to update
--              a foreign key column record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Foreign Key Column columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Foreign_Key_Column';
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

savepoint start_update_key_column;

-- Call private procedure to update an foreign key column
AK_KEY_PVT.UPDATE_FOREIGN_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_foreign_key_name => p_foreign_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_foreign_key_sequence => p_foreign_key_sequence,
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
--dbms_output.put_line(l_api_name || ' Update_Foreign_Key_Column failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_key_column;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_FOREIGN_KEY_COLUMN;

--=======================================================
--  Procedure   UPDATE_UNIQUE_KEY
--
--  Usage       Group API for updating a unique key record
--
--  Desc        This API calls the private API to update
--              a unique key record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Unique_Key';
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

savepoint start_update_unique_key;

-- Call private procedure to update a primary key
AK_KEY_PVT.UPDATE_UNIQUE_KEY (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_database_object_name => p_database_object_name,
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
--dbms_output.put_line(l_api_name || ' Update_Unique_Key failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_unique_key;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_unique_key;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_UNIQUE_KEY;

--=======================================================
--  Procedure   UPDATE_UNIQUE_KEY_COLUMN
--
--  Usage       Group API for updating a unique key column record
--
--  Desc        This API calls the private API to update
--              a uniquekey column record using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Unique Key Column columns
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
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
) is
l_api_version_number CONSTANT number := 1.0;
l_api_name           CONSTANT varchar2(30) := 'Update_Unique_Key_Column';
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

savepoint start_update_key_column;

-- Call private procedure to update a primary key column
AK_KEY_PVT.UPDATE_UNIQUE_KEY_COLUMN (
p_validation_level => p_validation_level,
p_api_version_number => 1.0,
p_msg_count => p_msg_count,
p_msg_data => p_msg_data,
p_return_status => l_return_status,
p_unique_key_name => p_unique_key_name,
p_attribute_application_id => p_attribute_application_id,
p_attribute_code => p_attribute_code,
p_unique_key_sequence => p_unique_key_sequence,
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
--dbms_output.put_line(l_api_name || ' Update_Unique_Key_Column failed');
RAISE FND_API.G_EXC_ERROR;
end if;

p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
p_return_status := FND_API.G_RET_STS_ERROR;
rollback to start_update_key_column;
WHEN OTHERS THEN
p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
rollback to start_update_key_column;
FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
SUBSTR (SQLERRM, 1, 240) );
FND_MSG_PUB.Add;
end UPDATE_UNIQUE_KEY_COLUMN;

end AK_KEY_GRP;

/
