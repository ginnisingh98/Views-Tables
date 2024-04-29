--------------------------------------------------------
--  DDL for Package AMS_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_FORMULA_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvfmls.pls 115.7 2002/11/22 01:52:55 yzhao ship $*/
-- Start of Comments
--
-- NAME
--   AMS_FORMULA_PVT
--
-- PURPOSE
--   This Package provides procedures to allow  Insertion, Deletion,
--   Update and Locking of Marketing On-Line formulas and formula entries.
--
--   This Package also stores the seeded Functions which can be executed as
--   part of a formula entry.
--
--   This Package also provides functions to execute a formula.
--
--   Procedures:
--
--   Create_Formula.
--   Update_Formula.
--   Delete_Formula.
--   Lock_Formula.
--   Execute_Formula.

--   Create_Formula_Entry.
--   Update_Formula_Entry.
--   Delete_Formula_Entry.
--   Lock_Formula_Entry.

-- NOTES
--
--
-- HISTORY
--   31-May-2000        tdonohoe            created
-- End of Comments

TYPE ams_formula_rec_type
IS RECORD (  formula_id             number
            ,activity_metric_id     number
            ,level_depth            number
            ,parent_formula_id      number
            ,last_update_date       date
            ,last_updated_by        number
            ,creation_date          date
            ,created_by             number
            ,last_update_login      number
            ,object_version_number  number
            ,formula_type           varchar2(30));

TYPE ams_formula_entry_rec_type
IS RECORD ( formula_entry_id       number
           ,formula_id             number
           ,order_number           number
           ,formula_entry_type     varchar2(30)
           ,formula_entry_value    varchar2(150)
           ,metric_column_value    varchar2(30)
           ,formula_entry_operator varchar2(30)
           ,last_update_date       date
           ,last_updated_by        number
           ,creation_date          date
           ,created_by             number
           ,last_update_login      number
           ,object_version_number  number);

---------------------------------------------------------------------
-- Start of comments
-- API Name       Execute_Formula
-- Type           Private
-- Pre-reqs       None.
-- Function       Executes an Acttivity Metric Formula and stores the
--                result in the the Ams_Act_Metric_Facts table.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_fornula_id                IN NUMBER     Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
--                x_result                    OUT NUMBER
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
---------------------------------------------------------------------
PROCEDURE Execute_Formula (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_result                     OUT NOCOPY NUMBER,

   p_formula_id                 IN NUMBER,
   p_hierarchy_id               IN NUMBER,
   p_parent_node_id             IN NUMBER,
   p_node_id                    IN NUMBER
);

---------------------------------------------------------------------
-- Start of comments
-- API Name       Create_Formula
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates an Activity Metric Formula.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_forecast_rec          IN ams_formula_rec_type  Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
---------------------------------------------------------------------

PROCEDURE Create_Formula (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ams_formula_rec_type,
   x_formula_id                 OUT NOCOPY NUMBER
);



-- Start of comments
-- API Name       Update_Formula
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates the activity metric formula.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_formula_rec               IN ams_formula_rec_type Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Update_Formula (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN 	ams_formula_rec_type
);


-- Start of comments
-- API Name       Delete_Formula
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes the Activity Metric Formula.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_forecast_id               IN NUMBER  Required
--                p_object_version_number     IN NUMBER
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_Formula (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_formula_id               IN  NUMBER ,
   p_object_version_number    IN  NUMBER
);



-- Start of comments
-- API Name       Lock_Formula
-- Type           Private
-- Pre-reqs       None.
-- Function       Lock the given row in AMS_ACT_METRIC_FORMULAS table.
-- Parameters
--    IN          p_api_version             IN NUMBER     Required
--                p_init_msg_list           IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                  IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_formula_id              IN NUMBER  Required
--		  p_object_version_number   IN NUMBER	 Required
--    OUT         x_return_status           OUT VARCHAR2
--                x_msg_count               OUT NUMBER
--                x_msg_data                OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Lock_Formula (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_formula_id              IN  NUMBER,
   p_object_version_number   IN  NUMBER
);



-- Start of comments
-- API Name       Validate_Formula
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate items in the activity metric forecast table.

-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level      IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_formula_rec           IN ams_formula_rec_type  Required
--    OUT         x_return_status         OUT VARCHAR2
--                x_msg_count             OUT NUMBER
--                x_msg_data              OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Validate_Formula (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ams_formula_rec_type
);


-- Start of comments
-- API Name       Validate_Formula_Items
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Formula Items
-- Parameters
--    IN          p_formula_rec            IN ams_formula_rec_type  Required
--                p_validate_mode 	   IN VARCHAR2
--    OUT         x_return_status          OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_Formula_Items(
   p_formula_rec         IN  ams_formula_rec_type,
   p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Validate_Formula_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Formula Records
-- Parameters
--    IN          p_formula_rec           IN ams_formula_rec_type  Required
--                p_complete_formula_rec  IN ams_formula_rec_type  Required
--    OUT         x_return_status         OUT VARCHAR2
-- Version        Current version:  1.0
--                Previous version: 1.0
--                Initial version:  1.0
-- End of comments

PROCEDURE Validate_Formula_Rec(
   p_formula_rec            IN  ams_formula_rec_type ,
   p_complete_formula_rec   IN  ams_formula_rec_type ,
   x_return_status          OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Complete_Formula_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       This Process returns the details for the Activity Metric Formula record.
--
-- Parameters
--    IN          p_formula_rec            IN  ams_formula_rec_type  Required
--    OUT         x_complete_formula_rec   OUT ams_formula_rec_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Complete_Formula_Rec(
   p_formula_rec             IN   ams_formula_rec_type,
   x_complete_formula_rec    OUT NOCOPY  ams_formula_rec_type
);





---------------------------------------------------------------------
-- Start of comments
-- API Name       Create_Formula_Entry
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates an Activity Metric Formula_Entry.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_formula_entry_rec         IN ams_formula_entry_rec_type  Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
---------------------------------------------------------------------

PROCEDURE Create_Formula_Entry (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ams_formula_entry_rec_type,
   x_formula_entry_id           OUT NOCOPY NUMBER
);



-- Start of comments
-- API Name       Update_formula_entry
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates the activity metric formula_entry.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_formula_entry_rec         IN ams_formula_entry_rec_type Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Update_formula_entry (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ams_formula_entry_rec_type
);


-- Start of comments
-- API Name       Delete_formula_entry
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes the Activity Metric formula_entry.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_forecast_id               IN NUMBER  Required
--                p_object_version_number     IN NUMBER
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_formula_entry (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_formula_entry_id               IN  NUMBER ,
   p_object_version_number    IN  NUMBER
);



-- Start of comments
-- API Name       Lock_formula_entry
-- Type           Private
-- Pre-reqs       None.
-- Function       Lock the given row in AMS_ACT_METRIC_formula_entries table.
-- Parameters
--    IN          p_api_version             IN NUMBER     Required
--                p_init_msg_list           IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                  IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_formula_entry_id              IN NUMBER  Required
--		  p_object_version_number   IN NUMBER	 Required
--    OUT         x_return_status           OUT VARCHAR2
--                x_msg_count               OUT NUMBER
--                x_msg_data                OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Lock_formula_entry (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_formula_entry_id              IN  NUMBER,
   p_object_version_number   IN  NUMBER
);



-- Start of comments
-- API Name       Validate_formula_entry
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate items in the activity metric forecast table.

-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level      IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_formula_entry_rec           IN ams_formula_entry_rec_type  Required
--    OUT         x_return_status         OUT VARCHAR2
--                x_msg_count             OUT NUMBER
--                x_msg_data              OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Validate_formula_entry (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec                IN  ams_formula_entry_rec_type
);


-- Start of comments
-- API Name       Validate_form_ent_Items
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric formula_entry Items
-- Parameters
--    IN          p_formula_entry_rec            IN ams_formula_entry_rec_type  Required
--                p_validate_mode 	   IN VARCHAR2
--    OUT         x_return_status          OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_form_ent_Items(
   p_formula_entry_rec         IN  ams_formula_entry_rec_type,
   p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Validate_form_ent_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric formula_entry Records
-- Parameters
--    IN          p_formula_entry_rec           IN ams_formula_entry_rec_type  Required
--                p_complete_formula_entry_rec  IN ams_formula_entry_rec_type  Required
--    OUT         x_return_status         OUT VARCHAR2
-- Version        Current version:  1.0
--                Previous version: 1.0
--                Initial version:  1.0
-- End of comments

PROCEDURE Validate_form_ent_Rec(
   p_formula_entry_rec            IN  ams_formula_entry_rec_type ,
   p_complete_formula_entry_rec   IN  ams_formula_entry_rec_type ,
   x_return_status          OUT NOCOPY VARCHAR2
) ;



-- Start of comments
-- API Name       Complete_form_ent_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       This Process returns the details for the Activity Metric formula_entry record.
--
-- Parameters
--    IN          p_formula_entry_rec            IN  ams_formula_entry_rec_type  Required
--    OUT         x_complete_formula_entry_rec   OUT ams_formula_entry_rec_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Complete_form_ent_Rec(
   p_formula_entry_rec             IN   ams_formula_entry_rec_type,
   x_complete_formula_entry_rec    OUT NOCOPY  ams_formula_entry_rec_type
);



END AMS_FORMULA_PVT;

 

/
