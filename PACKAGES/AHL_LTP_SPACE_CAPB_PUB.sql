--------------------------------------------------------
--  DDL for Package AHL_LTP_SPACE_CAPB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_SPACE_CAPB_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPSPCS.pls 115.5 2002/12/04 19:10:34 ssurapan noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AHL_LTP_SPACE_CAPB_PUB
--
-- PURPOSE
--    This package is a Public API for managing Space and Space capabilities information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SPACE_CAPBLTS_VL:
--    Process_Space_Capb (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 19-Apr-2002    ssurapan      Created.
-----------------------------------------------------------

-------------------------------------
-----          SPACES AND SPACE CAPABILITIES            -----
-------------------------------------
-- Record for AHL_SPACES_VL
TYPE Space_Rec IS RECORD (
   space_id                     NUMBER,
   space_name                   VARCHAR2(30),
   last_update_date             DATE,
   last_updated_by              NUMBER,
   creation_date                DATE,
   created_by                   NUMBER,
   last_update_login            NUMBER,
   object_version_number        NUMBER,
   organization_id              NUMBER,
   org_name                     VARCHAR2(240),
   department_id                NUMBER,
   dept_description             VARCHAR2(240),
   space_category_code          VARCHAR2(30),
   space_category_mean          VARCHAR2(80),
   inactive_flag_code           VARCHAR2(1),
   inactive_flag_mean           VARCHAR2(30),
   description                  VARCHAR2(2000),
   attribute_category           VARCHAR2(30),
   attribute1                   VARCHAR2(150),
   attribute2                   VARCHAR2(150),
   attribute3                   VARCHAR2(150),
   attribute4                   VARCHAR2(150),
   attribute5                   VARCHAR2(150),
   attribute6                   VARCHAR2(150),
   attribute7                   VARCHAR2(150),
   attribute8                   VARCHAR2(150),
   attribute9                   VARCHAR2(150),
   attribute10                  VARCHAR2(150),
   attribute11                  VARCHAR2(150),
   attribute12                  VARCHAR2(150),
   attribute13                  VARCHAR2(150),
   attribute14                  VARCHAR2(150),
   attribute15                  VARCHAR2(150),
   operation_flag               VARCHAR2(1)
);

-- Record for AHL_SPACE_CAPABILITIES
TYPE Space_Capbl_Rec IS RECORD (
   space_capability_id          NUMBER,
   last_update_date             DATE,
   last_updated_by              NUMBER,
   creation_date                DATE,
   created_by                   NUMBER,
   last_update_login            NUMBER,
   object_version_number        NUMBER,
   visit_type_code              VARCHAR2(30),
   visit_type_mean              VARCHAR2(80),
   inventory_item_id            NUMBER,
   item_description             varchar2(240),
   organization_id              NUMBER,
   org_name                     VARCHAR2(240),
   space_id                     NUMBER,
   space_name                   VARCHAR2(30),
   attribute_category           VARCHAR2(30),
   attribute1                   VARCHAR2(150),
   attribute2                   VARCHAR2(150),
   attribute3                   VARCHAR2(150),
   attribute4                   VARCHAR2(150),
   attribute5                   VARCHAR2(150),
   attribute6                   VARCHAR2(150),
   attribute7                   VARCHAR2(150),
   attribute8                   VARCHAR2(150),
   attribute9                   VARCHAR2(150),
   attribute10                  VARCHAR2(150),
   attribute11                  VARCHAR2(150),
   attribute12                  VARCHAR2(150),
   attribute13                  VARCHAR2(150),
   attribute14                  VARCHAR2(150),
   attribute15                  VARCHAR2(150),
   operation_flag               VARCHAR2(1)
);

--Declare Space table type
TYPE space_tbl IS TABLE OF Space_Rec
INDEX BY BINARY_INTEGER;

--Declare Space Capabilities table type
TYPE space_Capbl_tbl IS TABLE OF Space_Capbl_Rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Space_Capbl
--
-- PURPOSE
--    Process Space and space capabilities Records
--
-- PARAMETERS
--    p_x_space_rec: the record representing space_rec
--    p_x_space_capbl_tbl : the table representing space_capbl_tbl
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Process_Space_Capbl (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_space_rec             IN  OUT NOCOPY Space_Rec,
   p_x_space_capbl_tbl       IN  OUT NOCOPY Space_Capbl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


END AHL_LTP_SPACE_CAPB_PUB;

 

/
