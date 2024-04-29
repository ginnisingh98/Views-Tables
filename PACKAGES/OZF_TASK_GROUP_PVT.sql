--------------------------------------------------------
--  DDL for Package OZF_TASK_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TASK_GROUP_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvttgs.pls 115.3 2003/11/19 08:44:21 upoluri noship $ */
TYPE task_group_rec_type IS RECORD
(
  task_template_group_id                   NUMBER
 ,last_update_date                         DATE
 ,last_updated_by                          NUMBER
 ,creation_date                            DATE
 ,created_by                               NUMBER
 ,last_update_login                        NUMBER
 ,start_date_active                        DATE
 ,end_date_active                          DATE
 ,source_object_type_code                  VARCHAR2(30)
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
 ,reason_type                              VARCHAR2(30)
 ,template_group_name                      VARCHAR2(80)
 ,description                              VARCHAR2(4000)
);

TYPE task_group_tbl_type IS TABLE OF task_group_rec_type;

TYPE ozf_return_rec_type IS RECORD(
      returned_record_count           NUMBER,
      next_record_position            NUMBER,
      total_record_count              NUMBER
);

TYPE ozf_request_rec_type IS RECORD(
      records_requested               NUMBER,
      start_record_position           NUMBER,
      return_total_count_flag         VARCHAR2(1)
);

TYPE ozf_sort_rec IS RECORD
  (
  field_name      varchar2(30),
  asc_dsc_flag    char(1)        default 'A'
  );

TYPE ozf_sort_data IS TABLE OF ozf_sort_rec;
---------------------------------------------------------------------
-- PROCEDURE
--    Create_task_group
--
-- PURPOSE
--    Create a task group code.
--
-- PARAMETERS
--    p_task_group   : the new record to be inserted
--    x_task_template_group_id  : return the task_template_group_id
--
-- NOTES
--    1. object_version_number will be set to 1.
--    5. If a flag column is not passed in, default it to 'Y'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE  Create_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_group             IN     task_group_rec_type
   ,x_task_template_group_id OUT NOCOPY   NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    Update_task_group
--
-- PURPOSE
--    Update a task_group code.
--
-- PARAMETERS
--    p_task_group   : the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE  Update_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_group          	     IN    task_group_rec_type
   ,x_object_version_number  OUT NOCOPY   NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    Delete_task_group
--
-- PURPOSE
--    Update a task_group code.
--
-- PARAMETERS
--    p_task_group   : the record with new items.
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Delete_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_template_group_id IN    NUMBER
   ,p_object_version_number  IN    NUMBER
   );
---------------------------------------------------------------------
-- PROCEDURE
--    Get_task_group
--
-- PURPOSE
--    Get task_group code.
--
-- PARAMETERS
--    p_task_group   : the record with new items.
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Get_task_group (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_task_template_group_id IN    NUMBER
   ,p_template_group_name    IN    VARCHAR2
   ,p_source_object_type_code IN   VARCHAR2
   ,p_start_date_active	     IN    DATE
   ,p_end_date_active	     IN    DATE
   ,p_sort_data		     IN    ozf_sort_data
   ,p_request_rec	     IN    ozf_request_rec_type
   ,x_return_rec	     OUT NOCOPY   ozf_return_rec_type
   ,x_task_group  	    	     OUT NOCOPY   task_group_tbl_type
   );
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_task_group
--
-- PURPOSE
--    Validate a task group code record.
--
-- PARAMETERS
--    p_task_group : the task group code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_task_group (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_task_group        	    IN  task_group_rec_type
   );
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, , flag items, domain constraints.
--
-- PARAMETERS
--    p_task_group_rec      : the record to be validated
---------------------------------------------------------------------
PROCEDURE Check_task_group_Items(
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,p_task_group_rec        IN  task_group_rec_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Check_task_group_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_task_group_rec  : the record to be validated; may contain attributes
--                    as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items have
--                    been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_task_group_Record(
   p_task_group_rec        IN   task_group_rec_type
  ,p_complete_rec      IN   task_group_rec_type := NULL
  ,x_return_status     OUT NOCOPY  VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    Init_task_group_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_task_group_Rec (
   x_task_group_rec        OUT NOCOPY  task_group_rec_type
);
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_task_group_Rec
--
-- PURPOSE
--    For Update_task_group, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_task_group_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_task_group_Rec (
   p_task_group_rec        IN   task_group_rec_type
  ,x_complete_rec      OUT NOCOPY  task_group_rec_type
);

END OZF_TASK_GROUP_PVT;


 

/
