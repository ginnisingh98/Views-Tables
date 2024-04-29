--------------------------------------------------------
--  DDL for Package AML_MONITOR_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_MONITOR_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: amlvlmls.pls 115.1 2003/01/20 18:37:54 swkhanna ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AML_Monitor_Log_PVT
-- Purpose
--
-- History
-- 11-27-2002 sujrama created
-- ===============================================================
-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--    monitor_log_rec_type
--   -------------------------------------------------------
--   Parameters:
--       monitor_log_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       request_id
--       program_application_id
--       program_id
--       program_update_date
--       monitor_condition_id
--       recipient_role
--	 monitor_action
--       recipient_resource_id
--       sales_lead_id
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
--
--    Required
--
--    Defaults
--
--   End of Comments
--===================================================================
TYPE monitor_log_rec_type IS RECORD
(
       monitor_log_id                  NUMBER  --  := FND_API.G_MISS_NUM
       ,last_update_date                DATE   --	:= FND_API.G_MISS_DATE
       ,last_updated_by                 NUMBER --	:= FND_API.G_MISS_NUM
       ,creation_date                   DATE   --	:= FND_API.G_MISS_DATE
       ,created_by                      NUMBER --	:= FND_API.G_MISS_NUM
       ,last_update_login               NUMBER --	:= FND_API.G_MISS_NUM
       ,object_version_number           NUMBER --	:= FND_API.G_MISS_NUM
       ,request_id                      NUMBER --	:= FND_API.G_MISS_NUM
       ,program_application_id          NUMBER --	:= FND_API.G_MISS_NUM
       ,program_id                      NUMBER --	:= FND_API.G_MISS_NUM
       ,program_update_date             DATE   --	:= FND_API.G_MISS_DATE
       ,monitor_condition_id            NUMBER --	:= FND_API.G_MISS_NUM
       ,recipient_role                  VARCHAR2(30) --	 := FND_API.G_MISS_CHAR
       ,monitor_action                  VARCHAR2(30) --	:=  FND_API.G_MISS_CHAR
       ,recipient_resource_id           NUMBER --	:= FND_API.G_MISS_NUM
       ,sales_lead_id                   NUMBER --	:= FND_API.G_MISS_NUM
       ,attribute_category              VARCHAR2(30)--	 :=  FND_API.G_MISS_CHAR
       ,attribute1                      VARCHAR2(150)--	 :=  FND_API.G_MISS_CHAR
       ,attribute2                      VARCHAR2(150)--	 :=  FND_API.G_MISS_CHAR
       ,attribute3                      VARCHAR2(150)--	 :=  FND_API.G_MISS_CHAR
       ,attribute4                      VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute5                      VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute6                      VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute7                      VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute8                      VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute9                      VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute10                     VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute11                     VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute12                     VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute13                     VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute14                     VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
       ,attribute15                     VARCHAR2(150)--	:=  FND_API.G_MISS_CHAR
);
g_miss_monitor_log_rec          monitor_log_rec_type ;
TYPE  monitor_log_tbl_type      IS TABLE OF monitor_log_rec_type INDEX BY BINARY_INTEGER;
g_miss_monitor_log_tbl          monitor_log_tbl_type;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Monitor_Log
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_monitor_log_rec         IN   MONITOR_LOG_REC_TYPE Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================
PROCEDURE Create_Monitor_Log(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_monitor_log_rec            IN   monitor_log_rec_type  := g_miss_monitor_log_rec
    ,x_monitor_log_id             OUT NOCOPY  NUMBER
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
     );
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Monitor_Log
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_monitor_log_rec            IN   monitor_log_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--   ==============================================================================
PROCEDURE Update_Monitor_Log(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_monitor_log_rec            IN   monitor_log_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Monitor_Log
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_monitor_log_id          IN   NUMBER     Required
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================
PROCEDURE Delete_Monitor_Log(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_monitor_log_id             IN   NUMBER
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );
--   ==============================================================================
END AML_Monitor_Log_PVT;

 

/
