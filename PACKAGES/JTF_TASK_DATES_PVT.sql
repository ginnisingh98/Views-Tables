--------------------------------------------------------
--  DDL for Package JTF_TASK_DATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DATES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkds.pls 115.19 2002/12/04 23:58:57 cjang ship $ */
   PROCEDURE create_task_dates (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id         IN       VARCHAR2,
      p_date_type_id    IN       VARCHAR2,
      p_date_value      IN       DATE,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_task_date_id    OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null
   );

   PROCEDURE update_task_dates (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN   OUT NOCOPY NUMBER,
      p_task_date_id    IN       NUMBER,
      p_date_type_id    IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_date_value      IN       DATE DEFAULT fnd_api.g_miss_date,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   );

   PROCEDURE delete_task_dates (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN  NUMBER,
      p_task_date_id    IN       NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   );
END;   -- CREATE OR REPLACE PACKAGE spec

 

/
