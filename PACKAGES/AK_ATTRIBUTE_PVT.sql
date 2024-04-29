--------------------------------------------------------
--  DDL for Package AK_ATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_ATTRIBUTE_PVT" AUTHID CURRENT_USER as
/* $Header: akdvatrs.pls 120.3 2005/09/15 22:26:45 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_ATTRIBUTE_PVT';

-- PL/SQL table for holding records that need to be processed
-- the second time in UPLOAD
G_ATTRIBUTE_REDO_TBL        AK_ATTRIBUTE_PUB.Attribute_Tbl_Type;
G_ATTRIBUTE_TL_REDO_TBL     AK_ATTRIBUTE_PUB.Attribute_Tl_Tbl_Type;
--
-- Pointer to redo table
G_ATTRIBUTE_REDO_INDEX      NUMBER := 0;

-- Procedure specs

--=======================================================
--  Function    ATTRIBUTE_EXISTS
--
--  Usage       Private API for checking for the existence of
--              an attribute with the given key values. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API check to see if an attribute record
--              exists with the given key values.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              This function will return TRUE if such an attribute
--              exists, or FALSE otherwise.
--  Parameters  Attribute key columns
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
function ATTRIBUTE_EXISTS (
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2
) return BOOLEAN;

--=======================================================
--  Procedure   CREATE_ATTRIBUTE
--
--  Usage       Private API for creating an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates an attribute using the given info. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure CREATE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2,
p_italic                   IN      VARCHAR2,
p_vertical_alignment       IN      VARCHAR2,
p_horizontal_alignment     IN      VARCHAR2,
p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_height			 IN		 NUMBER := FND_API.G_MISS_NUM,
p_css_class_name			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name  	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_precision			IN      NUMBER := FND_API.G_MISS_NUM,
p_expansion			IN	NUMBER := FND_API.G_MISS_NUM,
p_als_max_length		IN	NUMBER := FND_API.G_MISS_NUM,
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
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Procedure   DELETE_ATTRIBUTE
--
--  Usage       Private API for deleting an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Deletes an attribute with the given key value.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_attribute_application_id : IN required
--              p_attribute_code : IN required
--                  Key value of the attribute to be deleted.
--              p_delete_cascade : IN required
--                  If p_delete_cascade flag is 'Y', also delete all
--                  rows in other tables that references this attribute.
--                  Otherwise, this attribute will not be deleted if there
--                  are any other rows referencing it.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DELETE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_delete_cascade           IN      VARCHAR2
);


--=======================================================
--  Procedure   DOWNLOAD_ATTRIBUTE
--
--  Usage       Private API for downloading attributes. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the attributes selected
--              by application ID or by key values from the
--              database to the output file.
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
--                  p_application_id will be ignored if a table is
--                  given in p_attribute_pk_tbl.
--              p_attribute_pk_tbl : IN optional
--                  If given, only attributes whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_pk_tbl         IN      AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
:= AK_ATTRIBUTE_PUB.G_MISS_ATTRIBUTE_PK_TBL,
p_nls_language             IN      VARCHAR2
);

--=======================================================
--  Procedure   INSERT_ATTRIBUTE_PK_TABLE
--
--  Usage       Private API for inserting the given attribute's
--              primary key value into the given attribute
--              table.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API inserts the given attribute primary
--              key value into a given attribute table
--              (of type Attribute_PK_Tbl_Type) only if the
--              primary key does not already exist in the table.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute key columns: IN required
--              p_attribute_pk_tbl : IN OUT
--                  Attribute table to be updated.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure INSERT_ATTRIBUTE_PK_TABLE (
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_pk_tbl         IN OUT NOCOPY  AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type
);

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE
--
--  Usage       Private API for updating an attribute.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates an attribute using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPDATE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER,
p_attribute_code           IN      VARCHAR2,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style				 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_display_height			 IN		 NUMBER := FND_API.G_MISS_NUM,
p_css_class_name 			 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr		 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name   	 IN		 VARCHAR2 := FND_API.G_MISS_CHAR,
p_precision			IN      NUMBER := FND_API.G_MISS_NUM,
p_expansion			IN	NUMBER := FND_API.G_MISS_NUM,
p_als_max_length		IN	NUMBER := FND_API.G_MISS_NUM,
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
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
--  Procedure   UPLOAD_ATTRIBUTE
--
--  Usage       Private API for loading attributes from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the attribute data stored in
--              the loader file currently being processed, parses
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
procedure UPLOAD_ATTRIBUTE (
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
--  Function    VALIDATE_ATTRIBUTE
--
--  Usage       Private API for validating an attribute. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Perform validation on an attribute record.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--              In addition, this function returns TRUE if all
--              validation tests are passed, or FALSE otherwise.
--  Parameters  Attribute columns
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
function VALIDATE_ATTRIBUTE (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_api_version_number       IN      NUMBER,
p_return_status            OUT NOCOPY     VARCHAR2,
p_attribute_application_id IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_code           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_attribute_value_length   IN      NUMBER := FND_API.G_MISS_NUM,
p_bold                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_italic                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_vertical_alignment       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_horizontal_alignment     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_data_type                IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_caller                   IN      VARCHAR2,
p_pass                     IN      NUMBER := 2
) return BOOLEAN;

--=======================================================
--  Procedure   UPLOAD_ATTRIBUTE_SECOND
--
--  Usage       Private API for loading attributes that were
--              failed during its first pass
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the attribute data from PL/SQL table
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
procedure UPLOAD_ATTRIBUTE_SECOND (
p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_return_status            OUT NOCOPY     VARCHAR2,
p_loader_timestamp         IN      DATE := FND_API.G_MISS_DATE,
p_pass                     IN      NUMBER := 2
);

end AK_Attribute_pvt;

 

/
