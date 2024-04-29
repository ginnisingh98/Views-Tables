--------------------------------------------------------
--  DDL for Package AK_ATTRIBUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_ATTRIBUTE_PUB" AUTHID CURRENT_USER as
/* $Header: akdpatts.pls 115.6 2002/09/27 17:54:59 tshort ship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_ATTRIBUTE_PUB';

-- Type definitions

TYPE Attribute_PK_Rec_Type IS RECORD (
attribute_appl_id  NUMBER := FND_API.G_MISS_NUM,
attribute_code     VARCHAR2(30) := FND_API.G_MISS_CHAR
);

TYPE Attribute_LOV_Rec_Type IS RECORD (
attribute_appl_id  NUMBER := FND_API.G_MISS_NUM,
attrbute_code      VARCHAR2(30) := FND_API.G_MISS_CHAR,
lov_object         VARCHAR2(30) := FND_API.G_MISS_CHAR
);

TYPE Attribute_PK_Tbl_Type IS TABLE OF Attribute_PK_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Attribute_LOV_Tbl_Type IS TABLE OF Attribute_LOV_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Attribute_Tl_Rec_Type IS RECORD (
name                  VARCHAR2(80),
attribute_label_long	VARCHAR2(80),
attribute_label_short VARCHAR2(40),
description           VARCHAR2(2000)
);

TYPE Attribute_Tbl_Type IS TABLE OF AK_ATTRIBUTES%ROWTYPE
INDEX BY BINARY_INTEGER;
TYPE Attribute_Tl_Tbl_Type IS TABLE OF Attribute_Tl_Rec_Type
INDEX BY BINARY_INTEGER;

/* Constants for missing data types */
G_MISS_ATTRIBUTE_PK_TBL Attribute_PK_Tbl_Type;

end AK_ATTRIBUTE_PUB;

 

/
