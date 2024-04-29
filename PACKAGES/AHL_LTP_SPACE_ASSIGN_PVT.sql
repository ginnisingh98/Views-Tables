--------------------------------------------------------
--  DDL for Package AHL_LTP_SPACE_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_SPACE_ASSIGN_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSANS.pls 115.8 2003/08/04 16:37:37 ssurapan noship $ */
--
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

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Create_Space_Assignment
--  Type        : Private
--  Function    : Creates space assignments for a visit
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
--  Create_Space_Assignment Parameters :
--      p_x_space_assign_rec      IN   OUT NOCOPY ahl_ltp_space_assign_pub.Space_Assignment_Rec, Required
--         List of space assignemnts for a visit
--

PROCEDURE Create_Space_Assignment (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_space_assign_rec      IN   OUT NOCOPY ahl_ltp_space_assign_pub.Space_Assignment_Rec,
   p_reschedule_flag         IN      VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Update_Space_Assignment
--  Type        : Private
--  Function    : Update space assignments for a visit
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
--  Update_Space_Assignment Parameters :
--      p_space_assign_rec      IN   ahl_ltp_space_assign_pub.Space_Assignment_Rec, Required
--         List of space assignemnts for a visit
--
PROCEDURE Update_Space_Assignment (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',
   p_space_assign_rec        IN  ahl_ltp_space_assign_pub.Space_Assignment_Rec,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : Delete_Space_Assignment
--  Type        : Private
--  Function    : Delete space assignments for a visit
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
--  Delete_Space_Assignment Parameters :
--      p_space_assign_rec      IN    ahl_ltp_space_assign_pub.Space_Assignment_Rec, Required
--         List of space assignemnts for a visit
--
PROCEDURE Delete_Space_assignment (
   p_api_version                IN    NUMBER,
   p_init_msg_list              IN    VARCHAR2  := FND_API.g_false,
   p_commit                     IN    VARCHAR2  := FND_API.g_false,
   p_validation_level           IN    NUMBER    := FND_API.g_valid_level_full,
   p_space_assign_rec           IN    ahl_ltp_space_assign_pub.Space_Assignment_Rec,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2

);

-- Start of Comments --
--  Procedure name    : Schedule_Visit
--  Type        : Private
--  Function    : Schedule visit defines Organization , Department , Start_date
--                and Schedule designator
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
--        p_x_schedule_visit_rec    IN  OUT NOCOPY ahl_ltp_space_assign_pub.Schedule_Visit_Rec, Required,
--         List of space assignemnts for a visit
--
PROCEDURE Schedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY ahl_ltp_space_assign_pub.Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

-- Start of Comments --
--  Procedure name    : UnSchedule_Visit
--  Type        : Private
--  Function    : UnSchedule visit removes Organization , Department , Start_date
--                and Schedule designator. If there are any space assignments should be removed
--                as well
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
--        p_x_schedule_visit_rec    IN  OUT NOCOPY ahl_ltp_space_assign_pub.Schedule_Visit_Rec, Required,
--         List of space assignemnts for a visit
--
PROCEDURE Unschedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY ahl_ltp_space_assign_pub.Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


END AHL_LTP_SPACE_ASSIGN_PVT;

 

/
