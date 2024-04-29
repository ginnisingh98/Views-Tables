--------------------------------------------------------
--  DDL for Package JTF_TASK_DEPENDENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DEPENDENCY_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkes.pls 120.1 2005/07/02 00:58:56 appldev ship $ */
/*#
 * This is the public package to validate, crete, update, and delete task dependencies.
 *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task Dependency
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */

    TYPE task_dependency_rec IS RECORD (
        dependency_id                 NUMBER,
        task_id                       NUMBER,
        task_name                     VARCHAR2(30),
        task_number                   NUMBER,
        dependenct_on_task_id         NUMBER,
        dependenct_on_task_name       NUMBER,
        dependenct_on_task_number     NUMBER,
        dependency_type_code          VARCHAR2(30),
        dependency_type_code_desc     VARCHAR2(80),
        adjustment_time               NUMBER,
        adjustment_time_uom           VARCHAR2(30)
    );

/*#
 * Task dependency creation API.  Many validations will be performed before
 * creating task dependency.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_validation_level the validation level for dependency creation
 * @param p_task_id the task id for dependency creation
 * @param p_task_number the task number for dependency creation
 * @param p_dependent_on_task_id the master task id for dependency creation
 * @param p_dependent_on_task_number the dependent on task number
 * @param p_dependency_type_code the dependency type code of the dependency
 * @param p_template_flag the template flag to be applied
 * @param p_adjustment_time the time offset to be applied to re-calculate the master tasks scheduled start date or end date
 * @param p_adjustment_time_uom  the unit of measure of the time offset to be applied for date re-calculation
 * @param p_validated_flag the validated flag
 * @param x_dependency_id the dependency id being created
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 * @param p_attribute1 attribute1 for flexfield
 * @param p_attribute2 attribute2 for flexfield
 * @param p_attribute3 attribute3 for flexfield
 * @param p_attribute4 attribute4 for flexfield
 * @param p_attribute5 attribute5 for flexfield
 * @param p_attribute6 attribute6 for flexfield
 * @param p_attribute7 attribute7 for flexfield
 * @param p_attribute8 attribute8 for flexfield
 * @param p_attribute9 attribute9 for flexfield
 * @param p_attribute10 attribute10 for flexfield
 * @param p_attribute11 attribute11 for flexfield
 * @param p_attribute12 attribute12 for flexfield
 * @param p_attribute13 attribute13 for flexfield
 * @param p_attribute14 attribute14 for flexfield
 * @param p_attribute15 attribute15 for flexfield
 * @param p_attribute_category attribute category
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Task Dependency
 * @rep:compatibility S
 */
    PROCEDURE create_task_dependency (
        p_api_version                IN       NUMBER,
        p_init_msg_list              IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                     IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_validation_level           IN       VARCHAR2
                DEFAULT fnd_api.g_valid_level_full,
        p_task_id                    IN       NUMBER DEFAULT NULL,
        p_task_number                IN       VARCHAR2 DEFAULT NULL,
        p_dependent_on_task_id       IN       NUMBER DEFAULT NULL,
        p_dependent_on_task_number   IN       VARCHAR2 DEFAULT NULL,
        p_dependency_type_code       IN       VARCHAR2,
        p_template_flag              IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
        p_adjustment_time            IN       NUMBER DEFAULT NULL,
        p_adjustment_time_uom        IN       VARCHAR2 DEFAULT NULL,
        p_validated_flag             IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
        x_dependency_id              OUT NOCOPY      NUMBER,
        x_return_status              OUT NOCOPY      VARCHAR2,
        x_msg_count                  OUT NOCOPY      NUMBER,
        x_msg_data                   OUT NOCOPY      VARCHAR2,
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

/*#
 * Task dependency row locking API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_dependency_id the dependency id being locked
 * @param p_object_version_number the object version number for lock
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 * @paraminfo {@rep:precision 6000}
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Lock Task Dependency
 * @rep:compatibility S
 */
   PROCEDURE lock_task_dependency (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_dependency_id     IN       NUMBER,
      p_object_version_number   IN NUMBER ,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   );

/*#
 * Task dependency update API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for dependency update
 * @param p_dependency_id the dependency id for dependency update
 * @param p_task_id the sub task id for dependency update
 * @param p_dependent_on_task_id the master task id for dependency update
 * @param p_dependent_on_task_number the master task number for dependency update
 * @param p_dependency_type_code the dependency type code of the dependency
 * @param p_adjustment_time the time offset to be applied to re-calculate the master tasks scheduled start date or end date
 * @param p_adjustment_time_uom  the unit of measure of the time offset to be applied for date re-calculation
 * @param p_validated_flag the validated flag
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_data returns the message in an encoded format if
 * @param p_attribute1 attribute1 for flexfield
 * @param p_attribute2 attribute2 for flexfield
 * @param p_attribute3 attribute3 for flexfield
 * @param p_attribute4 attribute4 for flexfield
 * @param p_attribute5 attribute5 for flexfield
 * @param p_attribute6 attribute6 for flexfield
 * @param p_attribute7 attribute7 for flexfield
 * @param p_attribute8 attribute8 for flexfield
 * @param p_attribute9 attribute9 for flexfield
 * @param p_attribute10 attribute10 for flexfield
 * @param p_attribute11 attribute11 for flexfield
 * @param p_attribute12 attribute12 for flexfield
 * @param p_attribute13 attribute13 for flexfield
 * @param p_attribute14 attribute14 for flexfield
 * @param p_attribute15 attribute15 for flexfield
 * @param p_attribute_category attribute category
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Task Dependency
 * @rep:compatibility S
 */
    PROCEDURE update_task_dependency (
        p_api_version                IN       NUMBER,
        p_init_msg_list              IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                     IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number      IN   OUT NOCOPY NUMBER ,
        p_dependency_id              IN       NUMBER,
        p_task_id                    IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_dependent_on_task_id       IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_dependent_on_task_number   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_dependency_type_code       IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_adjustment_time            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_adjustment_time_uom        IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_validated_flag             IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
        x_return_status              OUT NOCOPY      VARCHAR2,
        x_msg_count                  OUT NOCOPY      NUMBER,
        x_msg_data                   OUT NOCOPY      VARCHAR2,
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

/*#
 * Task dependency delete API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for delete
 * @param p_dependency_id the dependency id being deleted
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Task Dependency
 * @rep:compatibility S
 */
    PROCEDURE delete_task_dependency (
        p_api_version     IN       NUMBER,
        p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN     NUMBER ,
        p_dependency_id   IN       NUMBER,
        x_return_status   OUT NOCOPY      VARCHAR2,
        x_msg_count       OUT NOCOPY      NUMBER,
        x_msg_data        OUT NOCOPY      VARCHAR2
    );

END;

 

/
