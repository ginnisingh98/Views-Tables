--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMP_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMP_GROUP_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkgs.pls 115.24 2002/12/06 01:35:46 sachoudh ship $ */

---------------------------------------------------------------------------
--Define Global Variables--
---------------------------------------------------------------------------

G_PKG_NAME      CONSTANT        VARCHAR2(30):='JTF_TASK_TEMP_GROUP_PUB';
G_USER          CONSTANT        VARCHAR2(30):=FND_GLOBAL.USER_ID;
G_FALSE         CONSTANT        VARCHAR2(30):=FND_API.G_FALSE;
G_TRUE          CONSTANT        VARCHAR2(30):=FND_API.G_TRUE;
---------------------------------------------------------------------------

Type TASK_TEMPLATE_GROUP_REC  is RECORD
  (
  TASK_TEMPLATE_GROUP_ID   jtf_task_temp_groups_vl.task_template_group_id%type,
  TEMPLATE_GROUP_NAME      jtf_task_temp_groups_vl.template_group_name%type,
  SOURCE_OBJECT_TYPE_CODE  jtf_task_temp_groups_vl.source_object_type_code%type,
  START_DATE_ACTIVE        jtf_task_temp_groups_vl.start_date_active%type,
  END_DATE_ACTIVE          jtf_task_temp_groups_vl.end_date_active%type,
  DESCRIPTION              jtf_task_temp_groups_vl.description%type,
  ATTRIBUTE1               jtf_task_temp_groups_vl.attribute1%type,
  ATTRIBUTE2               jtf_task_temp_groups_vl.attribute2%type,
  ATTRIBUTE3               jtf_task_temp_groups_vl.attribute3%type,
  ATTRIBUTE4               jtf_task_temp_groups_vl.attribute4%type,
  ATTRIBUTE5               jtf_task_temp_groups_vl.attribute5%type,
  ATTRIBUTE6               jtf_task_temp_groups_vl.attribute6%type,
  ATTRIBUTE7               jtf_task_temp_groups_vl.attribute7%type,
  ATTRIBUTE8               jtf_task_temp_groups_vl.attribute8%type,
  ATTRIBUTE9               jtf_task_temp_groups_vl.attribute9%type,
  ATTRIBUTE10              jtf_task_temp_groups_vl.attribute10%type,
  ATTRIBUTE11              jtf_task_temp_groups_vl.attribute11%type,
  ATTRIBUTE12              jtf_task_temp_groups_vl.attribute12%type,
  ATTRIBUTE13              jtf_task_temp_groups_vl.attribute13%type,
  ATTRIBUTE14              jtf_task_temp_groups_vl.attribute14%type,
  ATTRIBUTE15              jtf_task_temp_groups_vl.attribute15%type,
  ATTRIBUTE_CATEGORY       jtf_task_temp_groups_vl.attribute_category%type,
  object_version_number    jtf_task_temp_groups_vl.object_version_number%type,
  application_id 	   jtf_task_temp_groups_vl.application_id%type
  );


Type task_temp_group_tbl is table of task_template_group_rec
  index by binary_integer;

type sort_rec is record
  (
  field_name      varchar2(30),
  asc_dsc_flag    char(1)        default 'A'
  );

type sort_data is table of sort_rec
  index by binary_integer;

--Procedure to Create Task Template Group

Procedure  CREATE_TASK_TEMPLATE_GROUP
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_TEMPLATE_GROUP_NAME     IN  VARCHAR2,
  P_SOURCE_OBJECT_TYPE_CODE IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE,
  P_DESCRIPTION             IN  VARCHAR2,
  P_ATTRIBUTE1              IN  VARCHAR2,
  P_ATTRIBUTE2              IN  VARCHAR2,
  P_ATTRIBUTE3              IN  VARCHAR2,
  P_ATTRIBUTE4              IN  VARCHAR2,
  P_ATTRIBUTE5              IN  VARCHAR2,
  P_ATTRIBUTE6              IN  VARCHAR2,
  P_ATTRIBUTE7              IN  VARCHAR2,
  P_ATTRIBUTE8              IN  VARCHAR2,
  P_ATTRIBUTE9              IN  VARCHAR2,
  P_ATTRIBUTE10             IN  VARCHAR2,
  P_ATTRIBUTE11             IN  VARCHAR2,
  P_ATTRIBUTE12             IN  VARCHAR2,
  P_ATTRIBUTE13             IN  VARCHAR2,
  P_ATTRIBUTE14             IN  VARCHAR2,
  P_ATTRIBUTE15             IN  VARCHAR2,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_TASK_TEMPLATE_GROUP_ID  OUT NOCOPY NUMBER,
  p_APPLICATION_ID 	    IN  NUMBER default null
  );

--Procedure to Upate Task Template Group

Procedure  UPDATE_TASK_TEMPLATE_GROUP
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_TASK_TEMPLATE_GROUP_ID  IN  NUMBER,
  P_TEMPLATE_GROUP_NAME     IN  VARCHAR2,
  P_SOURCE_OBJECT_TYPE_CODE IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE,
  P_DESCRIPTION             IN  VARCHAR2,
  P_ATTRIBUTE1              IN  VARCHAR2,
  P_ATTRIBUTE2              IN  VARCHAR2,
  P_ATTRIBUTE3              IN  VARCHAR2,
  P_ATTRIBUTE4              IN  VARCHAR2,
  P_ATTRIBUTE5              IN  VARCHAR2,
  P_ATTRIBUTE6              IN  VARCHAR2,
  P_ATTRIBUTE7              IN  VARCHAR2,
  P_ATTRIBUTE8              IN  VARCHAR2,
  P_ATTRIBUTE9              IN  VARCHAR2,
  P_ATTRIBUTE10             IN  VARCHAR2,
  P_ATTRIBUTE11             IN  VARCHAR2,
  P_ATTRIBUTE12             IN  VARCHAR2,
  P_ATTRIBUTE13             IN  VARCHAR2,
  P_ATTRIBUTE14             IN  VARCHAR2,
  P_ATTRIBUTE15             IN  VARCHAR2,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
  p_application_id 	    IN NUMBER default null
  );


--Procedure to Delete Task Template Group

Procedure  DELETE_TASK_TEMPLATE_GROUP
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_TASK_TEMPLATE_GROUP_ID  IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2,
 X_OBJECT_VERSION_NUMBER   IN  NUMBER
 );

   PROCEDURE LOCK_TASK_TEMPLATE_GROUP (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      P_TASK_TEMPLATE_GROUP_ID   IN       NUMBER,
      p_object_version_number   IN NUMBER ,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   );

Procedure  GET_TASK_TEMPLATE_GROUP
 (
 P_API_VERSION              IN  NUMBER,
 P_INIT_MSG_LIST            IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                   IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL           IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_TASK_TEMPLATE_GROUP_ID   IN  NUMBER,
 P_TEMPLATE_GROUP_NAME      IN  VARCHAR2,
 P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2,
 P_START_DATE_ACTIVE        IN  DATE,
 P_END_DATE_ACTIVE          IN  DATE,
 P_SORT_DATA                IN  SORT_DATA,
 P_QUERY_OR_NEXT_CODE       IN  VARCHAR2    default 'Q',
 P_START_POINTER            IN  NUMBER,
 P_REC_WANTED               IN  NUMBER,
 P_SHOW_ALL                 IN  VARCHAR2,
 X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
 X_MSG_COUNT                OUT NOCOPY NUMBER,
 X_MSG_DATA                 OUT NOCOPY VARCHAR2,
 X_TASK_TEMPLATE_GROUP      OUT NOCOPY TASK_TEMP_GROUP_TBL,
 X_TOTAL_RETRIEVED          OUT NOCOPY NUMBER,
 X_TOTAL_RETURNED           OUT NOCOPY NUMBER,
 p_APPLICATION_ID 	    IN  NUMBER default null
 );

END JTF_TASK_TEMP_GROUP_PUB;

 

/
