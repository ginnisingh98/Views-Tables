--------------------------------------------------------
--  DDL for Package AK_KEY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_KEY_PUB" AUTHID CURRENT_USER as
/* $Header: akdpkeys.pls 115.7 2002/09/27 17:57:16 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_KEY_PUB';

-- Type definitions

-- Foreign Key Record

TYPE Foreign_Key_Rec_Type IS RECORD (
foreign_key_name        VARCHAR2(30)              := NULL,
database_object_name    VARCHAR2(30)              := NULL,
unique_key_name         VARCHAR2(30)              := NULL,
application_id          NUMBER                    := NULL,
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
from_to_name            VARCHAR2(45)              := NULL,
from_to_description     VARCHAR2(1500)            := NULL,
to_from_name            VARCHAR2(45)              := NULL,
to_from_description     VARCHAR2(1500)            := NULL,
created_by		  NUMBER		    := NULL,
creation_date		  DATE			    := NULL,
last_updated_by	  NUMBER		    := NULL,
last_update_date	  DATE                      := NULL,
last_update_login	  NUMBER                    := NULL
);

-- Foreign Key Column Record

TYPE Foreign_Key_Column_Rec_Type IS RECORD (
foreign_key_name        VARCHAR2(30)              := NULL,
attribute_application_id NUMBER                   := NULL,
attribute_code          VARCHAR2(30)              := NULL,
foreign_key_sequence    NUMBER                    := NULL,
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

-- Unique Key Record

TYPE Unique_Key_Rec_Type IS RECORD (
unique_key_name         VARCHAR2(30)              := NULL,
database_object_name    VARCHAR2(30)              := NULL,
application_id          NUMBER                    := NULL,
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

-- Unique Key Column Record

TYPE Unique_Key_Column_Rec_Type IS RECORD (
unique_key_name         VARCHAR2(30)              := NULL,
attribute_application_id NUMBER                   := NULL,
attribute_code          VARCHAR2(30)              := NULL,
unique_key_sequence     NUMBER                    := NULL,
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

-- Data Types

TYPE Foreign_Key_Tbl_Type IS TABLE OF Foreign_Key_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Foreign_Key_Column_Tbl_Type IS TABLE OF Foreign_Key_Column_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Unique_Key_Tbl_Type IS TABLE OF Unique_Key_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Unique_Key_Column_Tbl_Type IS TABLE OF Unique_Key_Column_Rec_Type
INDEX BY BINARY_INTEGER;

/* Constants for missing data types */
G_MISS_FOREIGN_KEY_REC                Foreign_Key_Rec_Type;
G_MISS_FOREIGN_KEY_COLUMN_REC         Foreign_Key_Column_Rec_Type;
G_MISS_UNIQUE_KEY_REC                 Unique_Key_Rec_Type;
G_MISS_UNIQUE_KEY_COLUMN_REC          Unique_Key_Column_Rec_Type;

G_MISS_FOREIGN_KEY_TBL                Foreign_Key_Tbl_Type;
G_MISS_FOREIGN_KEY_COLUMN_TBL         Foreign_Key_Column_Tbl_Type;
G_MISS_UNIQUE_KEY_TBL                 Unique_Key_Tbl_Type;
G_MISS_UNIQUE_KEY_COLUMN_TBL          Unique_Key_Column_Tbl_Type;

end AK_KEY_PUB;

 

/
