--------------------------------------------------------
--  DDL for Package AHL_LTP_SPACE_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_SPACE_ASSIGN_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPSANS.pls 115.8 2003/06/04 00:25:53 ssurapan noship $ */

---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------

TYPE Space_Assignment_Rec IS RECORD (
         SPACE_ASSIGNMENT_ID      NUMBER          ,
         LAST_UPDATE_DATE         DATE            ,
         LAST_UPDATED_BY          NUMBER          ,
         CREATION_DATE            DATE            ,
         CREATED_BY               NUMBER          ,
         LAST_UPDATE_LOGIN        NUMBER          ,
         VISIT_ID                 NUMBER          ,
         VISIT_NUMBER             NUMBER          ,
         SPACE_NAME               VARCHAR2(30)    ,
         SPACE_ID                 NUMBER          ,
         OBJECT_VERSION_NUMBER    NUMBER          ,
         ATTRIBUTE_CATEGORY       VARCHAR2(30)    ,
         ATTRIBUTE1               VARCHAR2(150)   ,
         ATTRIBUTE2               VARCHAR2(150)   ,
         ATTRIBUTE3               VARCHAR2(150)   ,
         ATTRIBUTE4               VARCHAR2(150)   ,
         ATTRIBUTE5               VARCHAR2(150)   ,
         ATTRIBUTE6               VARCHAR2(150)   ,
         ATTRIBUTE7               VARCHAR2(150)   ,
         ATTRIBUTE8               VARCHAR2(150)   ,
         ATTRIBUTE9               VARCHAR2(150)   ,
         ATTRIBUTE10              VARCHAR2(150)   ,
         ATTRIBUTE11              VARCHAR2(150)   ,
         ATTRIBUTE12              VARCHAR2(150)   ,
         ATTRIBUTE13              VARCHAR2(150)   ,
         ATTRIBUTE14              VARCHAR2(150)   ,
         ATTRIBUTE15              VARCHAR2(150)   ,
         OPERATION_FLAG           VARCHAR2(1)
         );

TYPE Schedule_Visit_Rec IS RECORD (
         VISIT_ID                 NUMBER          ,
         VISIT_NUMBER             NUMBER          ,
         LAST_UPDATE_DATE         DATE            ,
         LAST_UPDATED_BY          NUMBER          ,
         CREATION_DATE            DATE            ,
         CREATED_BY               NUMBER          ,
         LAST_UPDATE_LOGIN        NUMBER          ,
         ORG_ID                   NUMBER          ,
         ORG_NAME                 VARCHAR2(240)    ,
         DEPT_ID                  NUMBER          ,
         DEPT_NAME                VARCHAR2(80)    ,
         START_DATE               DATE            ,
         START_HOUR               NUMBER          ,
         PLANNED_END_DATE         DATE            ,
         PLANNED_END_HOUR         NUMBER          ,
         VISIT_TYPE_CODE          VARCHAR2(30)    ,
         VISIT_TYPE_MEAN          VARCHAR2(80)    ,
         SPACE_CATEGORY_CODE      VARCHAR2(30)    ,
         SPACE_CATEGORY_MEAN      VARCHAR2(80)    ,
         SCHEDULE_DESIGNATOR      VARCHAR2(10)    ,
         OBJECT_VERSION_NUMBER    NUMBER          ,
         ATTRIBUTE_CATEGORY       VARCHAR2(30)    ,
         ATTRIBUTE1               VARCHAR2(150)   ,
         ATTRIBUTE2               VARCHAR2(150)   ,
         ATTRIBUTE3               VARCHAR2(150)   ,
         ATTRIBUTE4               VARCHAR2(150)   ,
         ATTRIBUTE5               VARCHAR2(150)   ,
         ATTRIBUTE6               VARCHAR2(150)   ,
         ATTRIBUTE7               VARCHAR2(150)   ,
         ATTRIBUTE8               VARCHAR2(150)   ,
         ATTRIBUTE9               VARCHAR2(150)   ,
         ATTRIBUTE10              VARCHAR2(150)   ,
         ATTRIBUTE11              VARCHAR2(150)   ,
         ATTRIBUTE12              VARCHAR2(150)   ,
         ATTRIBUTE13              VARCHAR2(150)   ,
         ATTRIBUTE14              VARCHAR2(150)   ,
         ATTRIBUTE15              VARCHAR2(150)   ,
         SCHEDULE_FLAG            VARCHAR2(1)
         );
----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Space_Assignment_Tbl IS TABLE OF Space_Assignment_Rec INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Assign_Sch_Visit_Spaces
--  Type        : Public
--  Function    : Manages Create/Modify/Delete space assignments for a visit
--                Schedule a visit
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Space_Assignment Parameters :
--     p_x_space_assignment_tbl  IN  OUT NOCOPY Space_Assignment_Tbl,Required
--     p_x_schedule_visit_rec    IN  out Schedule_visits_rec
--         List of space assignemnts, Schedule a visit
--

PROCEDURE Assign_Sch_Visit_Spaces (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_space_assignment_tbl  IN  OUT NOCOPY Space_Assignment_Tbl,
   p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Schedule_Visit
--  Type        : Public
--  Function    : Defines organization,department,start_date and schedule designator
--                for a visit
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Schedule_Visit Parameters :
--        p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,Required
--         Assigns visit attributes
--

PROCEDURE Schedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Unschedule_Visit
--  Type        : Public
--  Function    : Removes organization,department,start_date and schedule designator
--                and any associated space assignments for a visit
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Unschedule_Visit Parameters :
--        p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,Required
--         List of visit attributes
--
PROCEDURE Unschedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN      VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN      NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


END AHL_LTP_SPACE_ASSIGN_PUB;

 

/
