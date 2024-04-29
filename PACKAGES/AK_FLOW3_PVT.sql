--------------------------------------------------------
--  DDL for Package AK_FLOW3_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_FLOW3_PVT" AUTHID CURRENT_USER as
/* $Header: akdvfl3s.pls 120.2 2005/09/15 22:26:52 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_FLOW3_PVT';

-- Procedure specs

--=======================================================
--  Function    VALIDATE_FLOW
--
--  Usage       Private API for validating a flow. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow columns
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
function VALIDATE_FLOW (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_primary_page_appl_id     IN      NUMBER := FND_API.G_MISS_NUM,
  p_primary_page_code        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_PAGE
--
--  Usage       Private API for validating a flow page. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow page record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Page columns
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
function VALIDATE_PAGE (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_page_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_page_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_primary_region_appl_id   IN      NUMBER := FND_API.G_MISS_NUM,
  p_primary_region_code      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_PAGE_REGION
--
--  Usage       Private API for validating a flow page region. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow page region record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Page Region columns
--              p_foreign_key_name : IN optional
--                  The foreign key name used in the flow region
--                  relation record connecting this flow page region
--                  and its parent region, if there is one.
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
function VALIDATE_PAGE_REGION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_page_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_page_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_display_sequence         IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_style             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_num_columns              IN      NUMBER := FND_API.G_MISS_NUM,
  p_icx_custom_call          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_parent_region_application_id IN  NUMBER := FND_API.G_MISS_NUM,
  p_parent_region_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_set_primary_region       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_PAGE_REGION_ITEM
--
--  Usage       Private API for validating a flow page region item.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow page region item record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Page Region Item columns
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
function VALIDATE_PAGE_REGION_ITEM (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_page_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_page_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
  p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_page_appl_id          IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_page_code             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_url_attribute_appl_id IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_url_attribute_code    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Function    VALIDATE_REGION_RELATION
--
--  Usage       Private API for validating a flow region relation.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a flow region relation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Flow Region Relation columns
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
function VALIDATE_REGION_RELATION (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY    VARCHAR2,
  p_flow_application_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_flow_code                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_foreign_key_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_from_page_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_from_page_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_from_region_appl_id      IN      NUMBER := FND_API.G_MISS_NUM,
  p_from_region_code         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_page_appl_id          IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_page_code             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_to_region_appl_id        IN      NUMBER := FND_API.G_MISS_NUM,
  p_to_region_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_caller                   IN      VARCHAR2,
  p_pass                     IN      NUMBER := 2
) return BOOLEAN;

end AK_FLOW3_PVT;

 

/
