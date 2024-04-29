--------------------------------------------------------
--  DDL for Package AK_CUSTOM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOM_GRP" AUTHID CURRENT_USER as
/* $Header: akdgcres.pls 120.2 2005/09/15 22:26:32 tshort noship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_CUSTOM_GRP';

/* Procedure specs */

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
p_property_name            IN      VARCHAR2,
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
);

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
p_attr_appl_id             IN      NUMBER,
p_attr_code                IN      VARCHAR2,
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
--  Usage       Group API for downloading customized regions
--
--  Desc        This API first write out standard loader
--              file header for customized regions to a flat file.
--              Then it calls the private API to extract the
--              regions selected by application ID or by
--              key values from the database to the output file.
--              If a region is selected for writing to the loader
--              file, all its children records will also be written.
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
);

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
p_custom_appl_id           IN      NUMBER,
p_custom_appl_code         IN      VARCHAR2,
p_region_application_id    IN      NUMBER,
p_region_code              IN      VARCHAR2,
p_verticalization_id       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_localization_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_org_id                   IN      NUMBER := FND_API.G_MISS_NUM,
p_site_id                  IN      NUMBER := FND_API.G_MISS_NUM,
p_responsibility_id        IN      NUMBER := FND_API.G_MISS_NUM,
p_web_user_id              IN      NUMBER := FND_API.G_MISS_NUM,
p_default_customization_flag   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

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
p_property_name            IN      VARCHAR2,
p_property_varchar2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_number_value    IN      NUMBER := FND_API.G_MISS_NUM,
p_criteria_join_condition  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_property_varchar2_value_tl  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

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
p_attribute_appl_id        IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
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
);

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
p_operation                IN      VARCHAR2,
p_value_varchar2           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_value_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_value_date               IN      DATE := FND_API.G_MISS_DATE,
p_start_date_Active	     IN      DATE := FND_API.G_MISS_DATE,
p_end_date_active	     IN      DATE := FND_API.G_MISS_DATE,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

end AK_CUSTOM_GRP;

 

/
