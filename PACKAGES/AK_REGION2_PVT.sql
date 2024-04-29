--------------------------------------------------------
--  DDL for Package AK_REGION2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_REGION2_PVT" AUTHID CURRENT_USER as
/* $Header: akdvre2s.pls 120.3 2005/09/15 22:18:31 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_REGION2_PVT';

-- PL/SQL table for holding records that need to be processed
-- the second time in UPLOAD
G_REGION_REDO_TBL           AK_REGION_PUB.Region_Tbl_Type;
G_ITEM_REDO_TBL             AK_REGION_PUB.Item_Tbl_Type;
G_LOV_RELATION_REDO_TBL		AK_REGION_PUB.Lov_Relation_Tbl_Type;
--G_GRAPH_REDO_TBL		AK_REGION_PUB.Graph_Tbl_Type;
--G_GRAPH_COLUMN_REDO_TBL		AK_REGION_PUB.Graph_Column_Tbl_Type;
--
-- Pointer to redo tables
G_REGION_REDO_INDEX         NUMBER := 0;
G_ITEM_REDO_INDEX           NUMBER := 0;
G_LOV_RELATION_REDO_INDEX	NUMBER := 0;
--G_GRAPH_REDO_INDEX		NUMBER := 0;
--G_GRAPH_COLUMN_REDO_INDEX	NUMBER := 0;

--=======================================================
--  Procedure   UPLOAD_REGION
--
--  Usage       Private API for loading regions from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the region data (including region
--              items) stored in the loader file currently being
--              processed, parses the data, and loads them to the
--              database. The tables are updated with the timestamp
--              passed. This API will process the file until the
--              EOF is reached, a parse error is encountered, or when
--              data for a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_index : IN OUT required
--                  Index of PL/SQL file to be processed.
--              p_loader_timestamp : IN required
--                  The timestamp to be used when creating or updating
--                  records
--              p_line_num : IN optional
--                  The first line number in the file to be processed.
--                  It is used for keeping track of the line number
--                  read so that this info can be included in the
--                  error message when a parse error occurred.
--              p_buffer : IN required
--                  The content of the first line to be processed.
--                  The calling API has already read the first line
--                  that needs to be parsed by this API, so this
--                  line won't be read from the file again.
--              p_line_num_out : OUT
--                  The number of the last line in the loader file
--                  that is read by this API.
--              p_buffer_out : OUT
--                  The content of the last line read by this API.
--                  If an EOF has not reached, this line would
--                  contain the beginning of another business object
--                  that will need to be processed by another API.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_REGION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_index                    IN OUT NOCOPY  NUMBER,
p_loader_timestamp         IN      DATE,
p_line_num                 IN NUMBER := FND_API.G_MISS_NUM,
p_buffer                   IN AK_ON_OBJECTS_PUB.Buffer_Type,
p_line_num_out             OUT NOCOPY    NUMBER,
p_buffer_out               OUT NOCOPY    AK_ON_OBJECTS_PUB.Buffer_Type,
p_upl_loader_cur           IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp,
p_pass                     IN      NUMBER := 1
);

--=======================================================
--  Procedure   UPLOAD_REGION_SECOND
--
--  Usage       Private API for loading regions that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the region data from PL/SQL table
--              that was prepared during 1st pass, then processes
--              the data, and loads them to the database. The tables
--              are updated with the timestamp passed. This API
--              will process the file until the EOF is reached,
--              a parse error is encountered, or when data for
--              a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_validation_level : IN required
--                  validation level
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_REGION_SECOND (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER := 2
);

--=======================================================
--  Procedure   CHECK_DISPLAY_SEQUENCE
--
--  Usage       Private API for making sure that the
--              display sequence is unique for a given region
--              code.
--
--  Desc        This API updates a region item, if necessary
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
procedure CHECK_DISPLAY_SEQUENCE (
p_validation_level        IN      NUMBER,
p_region_code             IN      VARCHAR2,
p_region_application_id   IN      NUMBER,
p_attribute_code          IN      VARCHAR2,
p_attribute_application_id IN     NUMBER,
p_display_sequence        IN      NUMBER,
p_return_status           OUT NOCOPY     VARCHAR2,
p_msg_count               OUT NOCOPY     NUMBER,
p_msg_data                OUT NOCOPY     VARCHAR2,
p_pass                    IN      NUMBER,
p_copy_redo_flag          IN OUT NOCOPY  BOOLEAN
);

/*
--=======================================================
--  Function    GRAPH_COLUMN_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region graph column with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region graph column record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Graph Column key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
FUNCTION GRAPH_COLUMN_EXISTS (
p_api_version_number          IN      NUMBER,
p_return_status                       OUT NOCOPY             VARCHAR2,
p_region_application_id       IN              NUMBER,
p_region_code                         IN              VARCHAR2,
p_attribute_application_id IN         NUMBER,
p_attribute_code                      IN              VARCHAR2,
p_graph_number                        IN              NUMBER
) return boolean;
*/

--=======================================================
--  Function    LOV_RELATION_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region lov relation with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region lov relation record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Lov Relation key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function LOV_RELATION_EXISTS (
p_api_version_number		IN      NUMBER,
p_return_status			OUT NOCOPY		VARCHAR2,
p_region_application_id	IN		NUMBER,
p_region_code				IN		VARCHAR2,
p_attribute_application_id IN		NUMBER,
p_attribute_code			IN		VARCHAR2,
p_lov_region_appl_id		IN		NUMBER,
p_lov_region_code			IN		VARCHAR2,
p_lov_attribute_appl_id	IN		NUMBER,
p_lov_attribute_code		IN		VARCHAR2,
p_base_attribute_appl_id	IN		NUMBER,
p_base_attribute_code		IN		VARCHAR2,
p_direction_flag			IN		VARCHAR2,
p_base_region_appl_id		IN		NUMBER,
p_base_region_code		IN		VARCHAR2
) return boolean;

/*
--=======================================================
--  Function    VALIDATE_GRAPH_COLUMN
--
--  Usage       Private API for validating a region graph column. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region graph column record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region graph column columns
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
--  Version     Initial version number  =   1.1
--=======================================================
FUNCTION VALIDATE_GRAPH_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_graph_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_pass                     IN      NUMBER := 2,
p_caller                   IN      VARCHAR2
) return boolean;
*/

--=======================================================
--  Function    VALIDATE_LOV_RELATION
--
--  Usage       Private API for validating a region lov relation. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region lov relation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region lov relation columns
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
--  Version     Initial version number  =   1.1
--=======================================================
FUNCTION VALIDATE_LOV_RELATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_region_appl_id    	 IN      NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
p_base_attribute_code		 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_direction_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_region_appl_id		IN	NUMBER := FND_API.G_MISS_NUM,
p_base_region_code		IN 	VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return boolean;

/*
--=======================================================
--  Procedure   CREATE_GRAPH_COLUMN
--
--  Usage       Private API for creating a region graph column. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region graph column using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.1
--=======================================================
PROCEDURE CREATE_GRAPH_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_graph_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);
*/

--=======================================================
--  Procedure   CREATE_LOV_RELATION
--
--  Usage       Private API for creating a region lov relation. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region lov relation using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.1
--=======================================================
PROCEDURE CREATE_LOV_RELATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_region_appl_id    	 IN      NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
p_base_attribute_code		 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_direction_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_region_appl_id		IN	NUMBER := FND_API.G_MISS_NUM,
p_base_region_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_required_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);

/*
--=======================================================
--  Procedure   UPDATE_GRAPH_COLUMN
--
--  Usage       Private API for updating a region graph column.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region graph column using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region graph column columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_GRAPH_COLUMN (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_graph_number             IN      NUMBER := FND_API.G_MISS_NUM,
p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);
*/

--=======================================================
--  Procedure   UPDATE_LOV_RELATION
--
--  Usage       Private API for updating a region lov relation.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region lov relation using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region lov relation columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_LOV_RELATION (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_region_appl_id    	 IN      NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_lov_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
p_lov_attribute_code       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_attribute_appl_id	 IN      NUMBER := FND_API.G_MISS_NUM,
p_base_attribute_code		 IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_direction_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_base_region_appl_id		IN	NUMBER := FND_API.G_MISS_NUM,
p_base_region_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
p_required_flag			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Function    VALIDATE_CATEGORY_USAGE
--
--  Usage       Private API for validating a region item category usage. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on a region lov relation record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Region lov relation columns
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
--  Version     Initial version number  =   1.1
--=======================================================
FUNCTION VALIDATE_CATEGORY_USAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_name    	         IN      VARCHAR2:= FND_API.G_MISS_CHAR,
p_category_id                 IN      NUMBER := FND_API.G_MISS_NUM,
p_application_id              IN      NUMBER := FND_API.G_MISS_NUM,
p_show_all			IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return boolean;

--=======================================================
--  Function    CATEGORY_USAGE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              a region item category usage with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if a region item category usage record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an object
--              attribute exists, or FALSE otherwise.
--  Parameters  Region Lov Relation key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
FUNCTION CATEGORY_USAGE_EXISTS (
p_api_version_number          IN      NUMBER,
p_return_status                       OUT NOCOPY             VARCHAR2,
p_region_application_id       IN              NUMBER,
p_region_code                         IN              VARCHAR2,
p_attribute_application_id IN         NUMBER,
p_attribute_code                      IN              VARCHAR2,
p_category_name                 IN             VARCHAR2
) return boolean;


--=======================================================
--  Procedure   CREATE_CATEGORY_USAGE
--
--  Usage       Private API for creating a region item category usage. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region item category usage using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Region columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.1
--=======================================================
PROCEDURE CREATE_CATEGORY_USAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_name		IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_id                  IN      NUMBER := FND_API.G_MISS_NUM,
p_application_id		IN      NUMBER := FND_API.G_MISS_NUM,
p_show_all			IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Procedure   UPDATE_CATEGORY_USAGE
--
--  Usage       Private API for updating category usage.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a region lov relation using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Category usage columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_CATEGORY_USAGE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_region_application_id    IN      NUMBER := FND_API.G_MISS_NUM,
p_region_code              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_name         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_category_id                  IN      NUMBER := FND_API.G_MISS_NUM,
p_application_id                IN      NUMBER := FND_API.G_MISS_NUM,
p_show_all                      IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_created_by			IN	NUMBER := FND_API.G_MISS_NUM,
p_creation_date		   IN      DATE := FND_API.G_MISS_DATE,
p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER,
p_copy_redo_flag           IN OUT NOCOPY  BOOLEAN
);

end AK_REGION2_PVT;

 

/
