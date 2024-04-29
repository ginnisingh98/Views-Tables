--------------------------------------------------------
--  DDL for Package AK_ATTRIBUTE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_ATTRIBUTE_GRP" AUTHID CURRENT_USER as
/* $Header: akdgatts.pls 120.2 2005/09/15 22:26:31 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_ATTRIBUTE_GRP';

--
-- Procedure specs
--
--=======================================================
--  Procedure   CREATE_ATTRIBUTE
--
--  Usage       Group API for creating an attribute
--
--  Desc        Calls the private API to creates an attribute
--              using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
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
p_data_type                IN      VARCHAR2,
p_upper_case_flag          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_varchar2   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_default_value_number     IN      NUMBER := FND_API.G_MISS_NUM,
p_default_value_date       IN      DATE := FND_API.G_MISS_DATE,
p_lov_region_application_id IN     NUMBER := FND_API.G_MISS_NUM,
p_lov_region_code          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_item_style		     IN      VARCHAR2,
p_display_height           IN      NUMBER := FND_API.G_MISS_NUM,
p_css_class_name	     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_precision		     IN      NUMBER := FND_API.G_MISS_NUM,
p_expansion		     IN      NUMBER := FND_API.G_MISS_NUM,
p_als_max_length	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_name                     IN      VARCHAR2,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
);

--=======================================================
--  Procedure   DELETE_ATTRIBUTE
--
--  Usage       Group API for deleting an attribute
--
--  Desc        Calls the private API to deletes an attribute
--              with the given key value.
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
p_delete_cascade           IN      VARCHAR2 := 'N'
);

--=======================================================
--  Procedure   DOWNLOAD_ATTRIBUTE
--
--  Usage       Group API for downloading attributes
--
--  Desc        This API first write out standard loader
--              file header for attributes to a flat file.
--              Then it calls the private API to extract the
--              attributes selected by application ID or by
--              key values from the database to the output file.
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
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--              p_application_short_name : IN optional
--                  If given, all attributes for this application short
--                  name will be written to the output file.
--                  Application short name will be ignored if an
--                  application ID is given.
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
p_init_msg_tbl             IN      BOOLEAN := FALSE,
p_msg_count                OUT NOCOPY     NUMBER,
p_msg_data                 OUT NOCOPY     VARCHAR2,
p_return_status            OUT NOCOPY     VARCHAR2,
p_nls_language             IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
p_application_short_name   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_pk_tbl         IN      AK_ATTRIBUTE_PUB.Attribute_PK_Tbl_Type :=
AK_ATTRIBUTE_PUB.G_MISS_ATTRIBUTE_PK_TBL
);

--=======================================================
--  Procedure   UPDATE_ATTRIBUTE
--
--  Usage       Group API for updating an attribute
--
--  Desc        This API calls the private API to update
--              an attribute using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Attribute columns
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
p_item_style               IN      VARCHAR2,
p_display_height           IN      NUMBER := FND_API.G_MISS_NUM,
p_css_class_name           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_viewobject       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_display_attr     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_poplist_value_attr       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_css_label_class_name     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_precision		     IN      NUMBER := FND_API.G_MISS_NUM,
p_expansion		     IN	     NUMBER := FND_API.G_MISS_NUM,
p_als_max_length	     IN	     NUMBER := FND_API.G_MISS_NUM,
p_name                     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_long     IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_attribute_label_short    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
p_description              IN      VARCHAR2 := FND_API.G_MISS_CHAR
);

end AK_ATTRIBUTE_GRP;

 

/
