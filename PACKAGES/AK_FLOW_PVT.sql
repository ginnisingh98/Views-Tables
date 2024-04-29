--------------------------------------------------------
--  DDL for Package AK_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_FLOW_PVT" AUTHID CURRENT_USER as
/* $Header: akdvflos.pls 120.2 2005/09/15 22:26:53 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_FLOW_PVT';

-- Procedure specs

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
) return BOOLEAN;

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
);

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
);

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
);

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
);

procedure CHECK_DISPLAY_SEQUENCE (
p_validation_level        IN      NUMBER,
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
);

end AK_FLOW_PVT;

 

/
