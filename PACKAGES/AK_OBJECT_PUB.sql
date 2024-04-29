--------------------------------------------------------
--  DDL for Package AK_OBJECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_OBJECT_PUB" AUTHID CURRENT_USER as
/* $Header: akdpobjs.pls 115.7 2002/09/27 17:58:03 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_OBJECTS_PUB';

-- Type definitions

-- Attribute Navigation Record

TYPE Attribute_Nav_Rec_Type IS RECORD (
database_object_name    VARCHAR2(30)              := NULL,
attribute_appl_id       NUMBER                    := NULL,
attribute_code          VARCHAR2(30)              := NULL,
value_varchar2          VARCHAR2(240)             := NULL,
value_date              DATE                      := NULL,
value_number            NUMBER                    := NULL,
to_region_appl_id       NUMBER                    := NULL,
to_region_code          VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
created_by		  NUMBER		    := NULL,
creation_date		  DATE			    := NULL,
last_updated_by         NUMBER                    := NULL,
last_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Attribute Value Record

TYPE Attribute_Value_Rec_Type IS RECORD (
database_object_name    VARCHAR2(30)              := NULL,
attribute_appl_id       NUMBER                    := NULL,
attribute_code          VARCHAR2(30)              := NULL,
key_value1              VARCHAR2(100)             := NULL,
key_value2              VARCHAR2(100)             := NULL,
key_value3              VARCHAR2(100)             := NULL,
key_value4              VARCHAR2(100)             := NULL,
key_value5              VARCHAR2(100)             := NULL,
key_value6              VARCHAR2(100)             := NULL,
key_value7              VARCHAR2(100)             := NULL,
key_value8              VARCHAR2(100)             := NULL,
key_value9              VARCHAR2(100)             := NULL,
key_value10             VARCHAR2(100)             := NULL,
value_varchar2          VARCHAR2(240)             := NULL,
value_date              DATE                      := NULL,
value_number            NUMBER                    := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
last_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Object Record

TYPE Object_Rec_Type IS RECORD (
database_object_name    VARCHAR2(30)              := NULL,
name                    VARCHAR2(30)              := NULL,
description             VARCHAR2(2000)            := NULL,
application_id          NUMBER                    := NULL,
primary_key_name        VARCHAR2(30)              := NULL,
defaulting_api_pkg      VARCHAR2(30)              := NULL,
defaulting_api_proc     VARCHAR2(30)              := NULL,
validation_api_pkg      VARCHAR2(30)              := NULL,
validation_api_proc     VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
last_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Object Attribute Record

TYPE Object_Attribute_Rec_Type IS RECORD (
database_object_name    VARCHAR2(30)              := NULL,
attribute_appl_id       NUMBER                    := NULL,
attribute_code          VARCHAR2(30)              := NULL,
column_name             VARCHAR2(30)              := NULL,
attribute_label_length  NUMBER                    := NULL,
display_value_length    NUMBER                    := NULL,
bold                    VARCHAR2(1)               := NULL,
italic                  VARCHAR2(1)               := NULL,
vertical_alignment      VARCHAR2(30)              := NULL,
horizontal_alignment    VARCHAR2(30)              := NULL,
data_source_type        VARCHAR2(30)              := NULL,
data_storage_type       VARCHAR2(30)              := NULL,
table_name              VARCHAR2(30)              := NULL,
base_table_column_name  VARCHAR2(30)              := NULL,
required_flag           VARCHAR2(1)               := NULL,
default_value_varchar2  VARCHAR2(240)             := NULL,
default_value_number    NUMBER                    := NULL,
default_value_date      DATE                      := NULL,
lov_region_application_id NUMBER                  := NULL,
lov_region_code         VARCHAR2(30)              := NULL,
lov_foreign_key_name    VARCHAR2(30)              := NULL,
lov_attribute_application_id NUMBER               := NULL,
lov_attribute_code      VARCHAR2(30)              := NULL,
defaulting_api_pkg      VARCHAR2(30)              := NULL,
defaulting_api_proc     VARCHAR2(30)              := NULL,
validation_api_pkg      VARCHAR2(30)              := NULL,
validation_api_proc     VARCHAR2(30)              := NULL,
attribute_category      VARCHAR2(30)              := NULL,
attribute1              VARCHAR2(150)             := NULL,
attribute2              VARCHAR2(150)             := NULL,
attribute3              VARCHAR2(150)             := NULL,
attribute4              VARCHAR2(150)             := NULL,
attribute5              VARCHAR2(150)             := NULL,
attribute6              VARCHAR2(150)             := NULL,
attribute7              VARCHAR2(150)             := NULL,
attribute8              VARCHAR2(150)             := NULL,
attribute9              VARCHAR2(150)             := NULL,
attribute10             VARCHAR2(150)             := NULL,
attribute11             VARCHAR2(150)             := NULL,
attribute12             VARCHAR2(150)             := NULL,
attribute13             VARCHAR2(150)             := NULL,
attribute14             VARCHAR2(150)             := NULL,
attribute15             VARCHAR2(150)             := NULL,
attribute_label_long    VARCHAR2(80)              := NULL,
attribute_label_short   VARCHAR2(40)              := NULL,
created_by              NUMBER                    := NULL,
creation_date           DATE                      := NULL,
last_updated_by         NUMBER                    := NULL,
last_update_date        DATE                      := NULL,
last_update_login       NUMBER                    := NULL
);

-- Data Types

TYPE Attribute_Nav_Tbl_Type IS TABLE OF Attribute_Nav_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Attribute_Value_Tbl_Type IS TABLE OF Attribute_Value_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Object_PK_Tbl_Type IS TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;

TYPE Object_Attribute_Tbl_Type IS TABLE OF Object_Attribute_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Object_Tbl_Type IS TABLE OF Object_Rec_Type
INDEX BY BINARY_INTEGER;

/* Constants for missing data types */
G_MISS_ATTRIBUTE_NAV_REC              Attribute_Nav_Rec_Type;
G_MISS_ATTRIBUTE_VALUE_REC            Attribute_Value_Rec_Type;
G_MISS_OBJECT_ATTRIBUTE_REC           Object_Attribute_Rec_Type;
G_MISS_OBJECT_REC                     Object_Rec_Type;

G_MISS_ATTRIBUTE_NAV_TBL              Attribute_Nav_Tbl_Type;
G_MISS_ATTRIBUTE_VALUE_TBL            Attribute_Value_Tbl_Type;
G_MISS_OBJECT_ATTRIBUTE_TBL           Object_Attribute_Tbl_Type;
G_MISS_OBJECT_PK_TBL                  Object_PK_Tbl_Type;
G_MISS_OBJECT_TBL                     Object_Tbl_Type;

end AK_OBJECT_PUB;

 

/
