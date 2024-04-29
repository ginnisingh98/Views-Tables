--------------------------------------------------------
--  DDL for Package OZF_TASK_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TASK_TEMPLATE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvttes.pls 115.3 2003/11/19 08:43:54 upoluri noship $ */
TYPE ozf_task_template_rec_type IS RECORD
(
  task_template_id                         NUMBER
 ,task_name                                VARCHAR2(80)
 ,description                              VARCHAR2(4000)
 ,reason_code_id                  	   NUMBER
 ,reason_code			   	   VARCHAR2(80)
 ,task_number                  	           VARCHAR2(30)
 ,task_type_id                  	   NUMBER
 ,task_type_name			   VARCHAR2(30)
 ,task_status_id                  	   NUMBER
 ,task_status_name			   VARCHAR2(30)
 ,task_priority_id                  	   NUMBER
 ,task_priority_name			   VARCHAR2(30)
 ,duration                        	   NUMBER
 ,duration_uom                             VARCHAR2(3)
 ,object_version_number                    NUMBER
 ,attribute_category                       VARCHAR2(30)
 ,attribute1                               VARCHAR2(150)
 ,attribute2                               VARCHAR2(150)
 ,attribute3                               VARCHAR2(150)
 ,attribute4                               VARCHAR2(150)
 ,attribute5                               VARCHAR2(150)
 ,attribute6                               VARCHAR2(150)
 ,attribute7                               VARCHAR2(150)
 ,attribute8                               VARCHAR2(150)
 ,attribute9                               VARCHAR2(150)
 ,attribute10                              VARCHAR2(150)
 ,attribute11                              VARCHAR2(150)
 ,attribute12                              VARCHAR2(150)
 ,attribute13                              VARCHAR2(150)
 ,attribute14                              VARCHAR2(150)
 ,attribute15                              VARCHAR2(150)
);

TYPE ozf_task_template_tbl_type IS TABLE OF ozf_task_template_rec_type;

TYPE ozf_number_tbl_type IS TABLE OF NUMBER;
---------------------------------------------------------------------
-- PROCEDURE
--    Create_TaskTemplate
--
-- PURPOSE
--    Create a task  template.
--
-- PARAMETERS
--    p_insert_reason   : the new record to be inserted
--    x_reason_code_id  : return the reason_code_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE  Create_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_template          IN    ozf_task_template_tbl_type
   ,x_task_template_id       OUT NOCOPY   ozf_number_tbl_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Update_TaskTemplate
--
-- PURPOSE
--    Update task template.
--
-- PARAMETERS
--    p_task_template   : the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE  Update_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_template          IN    ozf_task_template_tbl_type
   ,x_object_version_number  OUT NOCOPY   ozf_number_tbl_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Delete_TaskTemplate
--
-- PURPOSE
--    Delete a task template.
--
-- PARAMETERS
--    p_task_template_id   :  template to be deleted
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Delete_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_template_id       IN    ozf_number_tbl_type
   ,p_object_version_number  IN    ozf_number_tbl_type
   );
---------------------------------------------------------------------
-- PROCEDURE
--    Get_TaskTemplate
--
-- PURPOSE
--    Get task template.
--
-- PARAMETERS
--    p_task_group_id   :  template to be deleted
--
-- NOTES
--    1. Raise exception if the task group id doesn't exist.
----------------------------------------------------------------------
PROCEDURE  Get_TaskTemplate (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_reason_code_id         IN    NUMBER
   ,x_task_template  	     OUT NOCOPY   ozf_task_template_tbl_type
   );
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_TaskTemplate
--
-- PURPOSE
--    Validate a reason code record.
--
-- PARAMETERS
--    p_validate_reason : the reason code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_TaskTemplate (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_task_template          IN  ozf_task_template_rec_type
   );
---------------------------------------------------------------------
-- PROCEDURE
--    Check_TaskTemplate_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, , flag items, domain constraints.
--
-- PARAMETERS
--    p_task_template_rec      : the record to be validated
---------------------------------------------------------------------
PROCEDURE Check_TaskTemplate_Items(
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,p_task_template_rec IN  ozf_task_template_rec_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Check_TaskTemplate_Record
--
-- PURPOSE
--    Check the task template level business rules.
--
-- PARAMETERS
--    p_task_template_rec  : the record to be validated; may contain attributes
--                    as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items have
--                    been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_TaskTemplate_Record(
   p_task_template_rec IN   ozf_task_template_rec_type
  ,p_complete_rec      IN   ozf_task_template_rec_type := NULL
  ,x_return_status     OUT NOCOPY  VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    Init_TaskTemplate_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Reason_Rec (
   x_task_template_rec      OUT NOCOPY  ozf_task_template_rec_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_TaskTemplate_Rec
--
-- PURPOSE
--    For Update_Reason, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_task_template_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_TaskTemplate_Rec (
   p_task_template_rec IN   ozf_task_template_rec_type
  ,x_complete_rec      OUT NOCOPY  ozf_task_template_rec_type
);


END OZF_TASK_TEMPLATE_PVT;


 

/
