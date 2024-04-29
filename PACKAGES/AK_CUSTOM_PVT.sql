--------------------------------------------------------
--  DDL for Package AK_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOM_PVT" AUTHID CURRENT_USER as
/* $Header: akdvcres.pls 120.2 2005/09/15 22:26:48 tshort noship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_CUSTOM_PVT';

-- Procedure specs

--=======================================================
--  Procedure   WRITE_CUSTOM_TO_BUFFER (local procedure)
--
--  TEMPORARY
--=======================================================
procedure WRITE_CUSTOM_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
);

--=======================================================
--  Procedure   WRITE_CUST_REGION_TO_BUFFER (local procedure)
--
--  TEMPORARY
--=======================================================
procedure WRITE_CUST_REGION_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
);

--=======================================================
--  Procedure   WRITE_CUST_REG_ITEM_TO_BUFFER (local procedure)
--
--  TEMPORARY
--=======================================================
procedure WRITE_CUST_REG_ITEM_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
);

--=======================================================
--  Procedure   WRITE_CRITERIA_TO_BUFFER (local procedure)
--
--  TEMPORARY
--=======================================================
procedure WRITE_CRITERIA_TO_BUFFER (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_nls_language             IN      VARCHAR2
);

--=======================================================
--  Procedure   CREATE_CUSTOM
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_custom_code              IN      VARCHAR2,
p_region_appl_id           IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_localization_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_org_id                   IN      NUMBER := FND_API.G_MISS_NUM,
p_site_id                  IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_web_user_id              IN      NUMBER := FND_API.G_MISS_NUM,
p_default_customization_flag  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_reference_path           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
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
--  Procedure   CREATE_CUST_REGION
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_property_name            IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_criteria_join_condition    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Procedure   CREATE_CUST_REG_ITEM
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_attr_appl_id             IN      NUMBER,
p_attr_code                IN      VARCHAR2,
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
);

--=======================================================
--  Procedure   CREATE_CRITERIA
--
--  Usage       Private API for creating a region graph. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Item columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_attr_appl_id             IN      NUMBER,
p_attr_code                IN      VARCHAR2,
p_sequence_number          IN      NUMBER,
p_operation                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_start_date_Active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
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
--  Function    CUSTOM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CUSTOM_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Function    CUST_REGION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CUST_REGION_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_property_name            IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Function    CUST_REG_ITEM_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CUST_REG_ITEM_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_appl_id        IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_property_name            IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Function    CRITERIA_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function CRITERIA_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_appl_id        IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_sequence_number          IN      NUMBER
) return BOOLEAN;

--=======================================================
--  Procedure   UPDATE_CUSTOM
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_custom_appl_id           IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_localization_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_org_id                   IN      NUMBER := FND_API.G_MISS_NUM,
p_site_id                  IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_web_user_id              IN      NUMBER := FND_API.G_MISS_NUM,
p_default_customization_flag   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_level_id   IN      NUMBER := FND_API.G_MISS_NUM,
p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_reference_path           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_start_date_active	    IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
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
--  Procedure   UPDATE_CUST_REGION
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_property_name            IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Procedure   UPDATE_CUST_REG_ITEM
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_appl_id        IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_property_name            IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Procedure   UPDATE_CRITERIA
--
--  Usage       Private API for updating a region graph.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region Graph columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
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
p_custom_code              IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_attribute_appl_id        IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_sequence_number          IN      NUMBER,
p_operation                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
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
--  Procedure   DOWNLOAD_CUSTOM
--
--  Usage       Private API for downloading customizations. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the customizations selected
--              by application ID or by key values from the
--              database to the output file.
--              If a customization is selected for writing to the loader
--              file, all its children records (including criteria)
--              will also be written.
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
--              p_get_object_flag : IN required
--                  Call DOWNLOAD_OBJECT API to extract objects that
--                  are referenced by the regions that will be extracted
--                  by this API if this parameter is 'Y'.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_region_pk_tbl.
--              p_region_pk_tbl : IN optional
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
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_custom_pk_tbl	     IN      AK_CUSTOM_PUB.Custom_PK_Tbl_Type                    			   := AK_CUSTOM_PUB.G_MISS_CUSTOM_PK_TBL,
p_nls_language             IN      VARCHAR2,
p_get_object_flag          IN      VARCHAR2,
p_level		     IN	     VARCHAR2 := FND_API.G_MISS_CHAR,
p_levelpk		     IN      VARCHAR2 := FND_API.G_MISS_CHAR
);

--=======================================================
--  Procedure   INSERT_CUSTOM_PK_TABLE
--
--  Usage       Private API for inserting the given region's
--              primary key value into the given object
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given region's primary
--              key value into a given region table
--              (of type Object_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_region_application_id : IN required
--              p_region_code : IN required
--                  Key value of the region to be inserted to the
--                  table.
--              p_custom_pk_tbl : IN OUT
--                  Region table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_CUSTOM_PK_TABLE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
  p_custom_appl_id           IN      NUMBER,
  p_custom_code              IN      VARCHAR2,
p_custom_pk_tbl            IN OUT NOCOPY  AK_CUSTOM_PUB.Custom_PK_Tbl_Type
);

--=======================================================
--  Function    VALIDATE_CUSTOM
--
--  Usage       Private API for validating a customization. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a customization record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Customizations columns
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
function VALIDATE_CUSTOM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_custom_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_custom_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_verticalization_id     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_localization_code      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_org_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_site_id		     IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id      IN      NUMBER := FND_API.G_MISS_NUM,
p_web_user_id	     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_custom_flag    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_customization_level_id IN      NUMBER := FND_API.G_MISS_NUM,
p_developer_mode	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_reference_path	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_function_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_Active	     IN      DATE := FND_API.G_MISS_DATE,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return boolean;

--=======================================================
--  Function    VALIDATE_CUST_REGION
--
--  Usage       Private API for validating a custom region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a custom region record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region graph columns
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
function VALIDATE_CUST_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_property_name            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_CUST_REGION_ITEM
--
--  Usage       Private API for validating a custom region item. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a custom region item record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Custom region item columns
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
function VALIDATE_CUST_REGION_ITEM (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_attr_appl_id             IN      NUMBER := FND_API.G_MISS_NUM,
p_attr_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_name            IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_property_date_value      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_CRITERIA
--
--  Usage       Private API for validating a custom criteria. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a custom criteria record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Criteria columns
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
function VALIDATE_CRITERIA (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_custom_application_id    IN      NUMBER,
p_custom_code              IN      VARCHAR2,
p_attr_appl_id             IN      NUMBER := FND_API.G_MISS_NUM,
p_attr_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_sequence_number          IN      NUMBER := FND_API.G_MISS_NUM,
p_operation                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_start_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;
end AK_CUSTOM_PVT;

 

/
