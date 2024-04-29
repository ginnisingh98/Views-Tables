--------------------------------------------------------
--  DDL for Package AHL_APPR_SPACE_UNAVL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_APPR_SPACE_UNAVL_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPSUAS.pls 115.6 2003/11/04 10:43:13 rroy noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AHL_SPACE_UNAVL_PUB
--
-- PURPOSE
--    This package is a Public API for managing Space Unavailable information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SPACE_UNAVIALABLE_VL:
--    Process_Space_Restriction (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 17-Apr-2002    ssurapan      Created.
-----------------------------------------------------------

-------------------------------------
-----          SPACE UNAVAILABILITY            -----
-------------------------------------
-- Record for AHL_SPACE_UNAVAILABLE_VL
TYPE Space_Restriction_Rec IS RECORD (
   space_unavailability_id      NUMBER,
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
   space_id                     NUMBER,
   space_name                   VARCHAR2(30),
   start_date                   DATE,
   end_date                     DATE,
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

--Declare table type
TYPE space_restriction_tbl IS TABLE OF Space_Restriction_Rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
-- PROCEDURE
--    Process_Space_Restriction
--
-- PURPOSE
--    Process Space Restriction Record
--
-- PARAMETERS
--    p_x_space_restriction_tbl: the table representing space_restriction_tbl
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Process_Space_Restriction (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_space_restriction_tbl IN  OUT NOCOPY Space_Restriction_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


END AHL_APPR_SPACE_UNAVL_PUB;

 

/
