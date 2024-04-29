--------------------------------------------------------
--  DDL for Package JTF_TASK_REFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_REFERENCES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkns.pls 120.1 2005/07/02 01:46:04 appldev ship $ */

    PROCEDURE create_references (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_object_type_code        IN       VARCHAR2 DEFAULT NULL,
        p_object_name             IN       VARCHAR2 DEFAULT NULL,
        p_object_id               IN       NUMBER DEFAULT NULL,
        p_object_details          IN       VARCHAR2 DEFAULT NULL,
        p_reference_code          IN       VARCHAR2 DEFAULT NULL,
        p_usage                   IN       VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_task_reference_id       OUT NOCOPY      NUMBER,
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
    )
 ;


    PROCEDURE update_references(
        p_api_version         IN       NUMBER,
        p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   in OUT NOCOPY   number,
        p_task_reference_id   IN       NUMBER,
        p_object_type_code    IN       VARCHAR2 DEFAULT NULL,
        p_object_name         IN       VARCHAR2 DEFAULT NULL,
        p_object_id           IN       NUMBER DEFAULT NULL,
        p_object_details      IN       VARCHAR2 DEFAULT NULL,
        p_reference_code      IN       VARCHAR2 DEFAULT NULL,
        p_usage               IN       VARCHAR2 DEFAULT NULL,
        x_return_status       OUT NOCOPY      VARCHAR2 ,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
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
    ) ;

    PROCEDURE delete_references (
        p_api_version         IN       NUMBER,
        p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   in       number,
        p_task_reference_id   IN       NUMBER,
        x_return_status       OUT NOCOPY      VARCHAR2,
        x_msg_data            OUT NOCOPY      VARCHAR2,
        x_msg_count            OUT NOCOPY     NUMBER,
        p_from_task_api      IN VARCHAR2  DEFAULT 'N'
    );



END;

 

/
