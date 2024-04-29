--------------------------------------------------------
--  DDL for Package AK_FLOW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_FLOW_GRP" AUTHID CURRENT_USER as
/* $Header: akdgflos.pls 120.2 2005/09/15 22:26:34 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_FLOW_GRP';

/* Procedure specs */

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
);


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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
);

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
--  Parameters
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
);

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
);

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
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_set_primary_page         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

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
p_region_style             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
);

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
);

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
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM
);

end AK_FLOW_GRP;

 

/
