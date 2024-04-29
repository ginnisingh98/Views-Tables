--------------------------------------------------------
--  DDL for Package AK_KEY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_KEY_PVT" AUTHID CURRENT_USER as
/* $Header: akdvkeys.pls 120.2 2005/09/15 22:26:54 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_KEY_PVT';

-- Procedure specs

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

);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
);

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
);

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
);

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
);

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
);

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
);

--=======================================================
--  Procedure   DELETE_RELATED_UNIQUE_KEY_COL
--
--  Usage       Private API for deleting unique key columns.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API deletes unique key columns from a
--              given unique_key_name.
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
);

end AK_KEY_PVT;

 

/
