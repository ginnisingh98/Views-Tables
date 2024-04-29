--------------------------------------------------------
--  DDL for Package JTF_TASK_TEMP_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_TEMP_GROUP_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkgs.pls 120.1 2005/07/02 01:45:48 appldev ship $ */

  G_PKG_NAME    CONSTANT        VARCHAR2(30):='JTF_TASK_TEMP_GROUP_PVT';

  procedure create_task_template_group
    (
    P_COMMIT                  IN  VARCHAR2,
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
    p_application_id	      in  NUMBER default null
    );

  procedure update_task_template_group
    (
    P_COMMIT                  IN  VARCHAR2,
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
    X_OBJECT_VERSION_NUMBER   IN  OUT NOCOPY NUMBER,
    p_application_id	      in  NUMBER  default null
    );

  procedure delete_task_template_group
    (
    P_COMMIT                   IN  VARCHAR2,
    P_TASK_TEMPLATE_GROUP_ID   IN  NUMBER,
    X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                OUT NOCOPY NUMBER,
    X_MSG_DATA                 OUT NOCOPY VARCHAR2
    );

Procedure  GET_TASK_TEMPLATE_GROUP
 (
 P_COMMIT                   IN  VARCHAR2    default fnd_api.g_false,
 P_TASK_TEMPLATE_GROUP_ID   IN  NUMBER,
 P_TEMPLATE_GROUP_NAME      IN  VARCHAR2,
 P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2,
 P_START_DATE_ACTIVE        IN  DATE,
 P_END_DATE_ACTIVE          IN  DATE,
 P_SORT_DATA                IN  jtf_task_temp_group_pub.SORT_DATA,
 P_QUERY_OR_NEXT_CODE       IN  VARCHAR2    default 'Q',
 P_START_POINTER            IN  NUMBER,
 P_REC_WANTED               IN  NUMBER,
 P_SHOW_ALL                 IN  VARCHAR2     default 'Y',
 X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
 X_MSG_COUNT                OUT NOCOPY NUMBER,
 X_MSG_DATA                 OUT NOCOPY VARCHAR2,
 X_TASK_TEMPLATE_GROUP      OUT NOCOPY jtf_task_temp_group_pub.TASK_TEMP_GROUP_TBL,
 X_TOTAL_RETRIEVED          OUT NOCOPY NUMBER,
 X_TOTAL_RETURNED           OUT NOCOPY NUMBER,
 p_application_id           IN  NUMBER  default null
 );


END;

 

/
