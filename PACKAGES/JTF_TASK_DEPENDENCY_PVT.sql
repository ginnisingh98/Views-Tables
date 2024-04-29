--------------------------------------------------------
--  DDL for Package JTF_TASK_DEPENDENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DEPENDENCY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkes.pls 120.4 2006/09/29 22:24:46 twan ship $ */
/*#
 * This is the private package to validate, crete, update, and delete task dependencies.
 *
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Jtf Task Dependency
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */

Type TASK_DEPENDENCY_REC is RECORD
(
    DEPENDENCY_ID            NUMBER,
    TASK_ID                  NUMBER,
    TASK_NAME                VARCHAR2(30),
    TASK_NUMBER	             NUMBER,
    DEPENDENT_ON_TASK_ID     NUMBER,
    DEPENDENT_ON_TASK_NAME   NUMBER,
    DEPENDENT_ON_TASK_NUMBER NUMBER,
    DEPENDENCY_TYPE_CODE     VARCHAR2(30),
    DEPENDENCY_TYPE_CODE_DESC VARCHAR2(80),
    ADJUSTMENT_TIME          NUMBER,
    ADJUSTMENT_TIME_UOM	     VARCHAR2(30)
);

/**
 * Validate task dependency based on task dependency type code.
 * There are four task dependency types need to be checked for validation, they are:
 *<li>S2S: The successor task start date can't be less than the predecessor start date.</li>
 *<li>S2F: The successor task end date can't be less than the predecessor start date.</li>
 *<li>F2S: The successor task start date can't be less than the predecessor end date.</li>
 *<li>F2F: The successor task end date can't be less than the predecessor end date.</li>
 * The parent's scheduled_start_date or scheduled_end_date will be re-calculated based on
 * the adjustment_time and adjustment_time_uom for different dependency type code.
 *
 * @param p_task_id              the task id to be queried
 * @param p_dependent_on_task_id the master task id of the task to be queried
 * @param p_dependency_id        the dependency id of the task to be queried
 * @param p_dependency_type_code the dependency type code to be queried from
 * @param p_template_flag        the template flag to be applied to the query
 * @param p_adjustment_time      the time offset to be applied to re-calculate the master tasks scheduled start date or end date
 * @param p_adjustment_time_uom  the unit of measure of the time offset to be applied for date re-calculation
 * @return status of the validation
 * @paraminfo {@rep:precision 6000}
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Validate Dependency
 * @rep:compatibility S
 */
function validate_dependency(
    p_task_id                in number,
    p_dependent_on_task_id   in number,
    p_dependency_type_code   in varchar2,
    p_adjustment_time        in number,
    p_adjustment_time_uom    in varchar2,
    p_validated_flag         in varchar2 default 'N'
) return varchar2;

/**
 * Validate task dependency whether it violates the dependency rules.
 * There are rules such as:
 *    Task should depend only once on another task
 *    Task can not have reverse dependency with other dependent task
 *    Task can not self depend
 *    Tasks cannot make dependency with other task in a cyclic manner
 * The metadata are coming from the table <code>JTF_OBJECTS_B<code>.
 * The parent's scheduled_start_date or scheduled_end_date will be re-calculated based on
 * the adjustment_time and adjustment_time_uom for different dependency type code.
 *
 * @param p_task_id              the task id to be queried
 * @param p_dependent_on_task_id the master task id of the task to be queried
 * @param p_dependency_id        the dependency id of the task to be queried
 * @return status of the validation
 * @paraminfo {@rep:precision 6000}
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Validate Task Dependency
 * @rep:compatibility S
 */
FUNCTION validate_task_dependency (
    p_task_id                IN       NUMBER,
    p_dependent_on_task_id   IN       NUMBER,
    p_dependency_id          IN       NUMBER,
    p_template_flag          IN       VARCHAR2
) return varchar2;

/**
 * This method provides capability of reconnecting the dependencies of a task after it is deleted.
 * Rules for reconnecting task dependencies, all three are required:
 * <li>The dependency type code of the parent task dependencies and the child task dependencies must be the same.</li>
 * <li>The adjustment time of the parent task dependency and the child task dependency must be the same.</li>
 * <li>The adjustment time uom of the parent task dependency and the child task dependency must be the same.</li>
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 *
 * @param p_task_id the task id to be queried
 * @param p_template_flag the template flag to be queried
 * @paraminfo {@rep:precision 6000}
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Reconnect Dependency
 * @rep:compatibility S
 */
PROCEDURE reconnect_dependency (
    p_api_version            IN       NUMBER,
    p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status          OUT NOCOPY      VARCHAR2,
    x_msg_data               OUT NOCOPY      VARCHAR2,
    x_msg_count              OUT NOCOPY      NUMBER,
    p_task_id                IN       NUMBER,
    p_template_flag          IN       VARCHAR2 DEFAULT 'N'
);


/**
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
 * @param p_task_id the task id for dependency creation
 * @param p_dependent_on_task_id the master task id for dependency creation
 * @param p_dependency_type_code the dependency type code of the dependency
 * @param p_template_flag the template flag to be applied
 * @param p_adjustment_time the time offset to be applied to re-calculate the master tasks scheduled start date or end date
 * @param p_adjustment_time_uom  the unit of measure of the time offset to be applied for date re-calculation
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
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Create Task Dependency
 * @rep:compatibility S
 */
PROCEDURE create_task_dependency (
    p_api_version            IN       NUMBER,
    p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_task_id                IN       NUMBER,
    p_dependent_on_task_id   IN       NUMBER,
    p_dependency_type_code   IN       VARCHAR2,
    p_template_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no,
    p_adjustment_time        IN       NUMBER DEFAULT NULL,
    p_adjustment_time_uom    IN       VARCHAR2 DEFAULT NULL,
    x_dependency_id          OUT NOCOPY      NUMBER,
    x_return_status          OUT NOCOPY      VARCHAR2,
    x_msg_data               OUT NOCOPY      VARCHAR2,
    x_msg_count              OUT NOCOPY      NUMBER,
    p_attribute1             IN       VARCHAR2 DEFAULT null ,
    p_attribute2             IN       VARCHAR2 DEFAULT null ,
    p_attribute3             IN       VARCHAR2 DEFAULT null ,
    p_attribute4             IN       VARCHAR2 DEFAULT null ,
    p_attribute5             IN       VARCHAR2 DEFAULT null ,
    p_attribute6             IN       VARCHAR2 DEFAULT null ,
    p_attribute7             IN       VARCHAR2 DEFAULT null ,
    p_attribute8             IN       VARCHAR2 DEFAULT null ,
    p_attribute9             IN       VARCHAR2 DEFAULT null ,
    p_attribute10            IN       VARCHAR2 DEFAULT null ,
    p_attribute11            IN       VARCHAR2 DEFAULT null ,
    p_attribute12            IN       VARCHAR2 DEFAULT null ,
    p_attribute13            IN       VARCHAR2 DEFAULT null ,
    p_attribute14            IN       VARCHAR2 DEFAULT null ,
    p_attribute15            IN       VARCHAR2 DEFAULT null ,
    p_attribute_category     IN       VARCHAR2 DEFAULT null,
    p_validated_flag         in       varchar2 default 'N'
);


/**
 * Task dependency update API.  Many validations will be performed before
 * updating task dependency.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_id the task id for dependency creation
 * @param p_dependent_on_task_id the master task id for dependency creation
 * @param p_dependency_type_code the dependency type code of the dependency
 * @param p_template_flag the template flag to be applied
 * @param p_adjustment_time the time offset to be applied to re-calculate the master tasks scheduled start date or end date
 * @param p_adjustment_time_uom  the unit of measure of the time offset to be applied for date re-calculation
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
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Create Task Dependency
 * @rep:compatibility S
 */
PROCEDURE UPDATE_TASK_DEPENDENCY
(
    P_API_VERSION            IN NUMBER,
    P_INIT_MSG_LIST          IN VARCHAR2 DEFAULT     FND_API.G_FALSE,
    P_COMMIT                 IN VARCHAR2 DEFAULT     FND_API.G_FALSE ,
    P_OBJECT_VERSION_NUMBER  IN	out NOCOPY NUMBER,
    P_DEPENDENCY_ID	     IN	NUMBER,
    P_TASK_ID 	             IN	NUMBER DEFAULT 	fnd_api.g_miss_num ,
    P_DEPENDENT_ON_TASK_ID   IN	NUMBER DEFAULT 	fnd_api.g_miss_num ,
    P_DEPENDENCY_TYPE_CODE   IN	VARCHAR2 DEFAULT 	fnd_api.g_miss_char ,
    P_ADJUSTMENT_TIME	     IN	NUMBER 	DEFAULT 	fnd_api.g_miss_num ,
    P_ADJUSTMENT_TIME_UOM    IN	VARCHAR2 DEFAULT 	fnd_api.g_miss_char ,
    X_RETURN_STATUS	     OUT NOCOPY VARCHAR2 ,
    X_MSG_COUNT	             OUT NOCOPY NUMBER ,
    X_MSG_DATA	             OUT NOCOPY VARCHAR2,
    p_attribute1             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute2             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute3             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute4             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute5             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute6             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute7             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute8             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute9             IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute10            IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute11            IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute12            IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute13            IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute14            IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute15            IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute_category     IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_validated_flag         in varchar2 default 'N'
);


/**
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
 * @param x_dependency_id the dependency id being created
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @paraminfo {@rep:precision 6000}
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Delete Task Dependency
 * @rep:compatibility S
 */
PROCEDURE delete_TASK_DEPENDENCY
(
    P_API_VERSION            IN NUMBER ,
    P_INIT_MSG_LIST          IN VARCHAR2 	DEFAULT     FND_API.G_FALSE,
    P_COMMIT	             IN VARCHAR2	    DEFAULT     FND_API.G_FALSE ,
    P_OBJECT_VERSION_NUMBER  IN	NUMBER,
    P_DEPENDENCY_ID          IN	NUMBER		,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2 ,
    X_MSG_COUNT	             OUT NOCOPY NUMBER ,
    X_MSG_DATA	             OUT NOCOPY VARCHAR2) ;

END; -- CREATE OR REPLACE PACKAGE spec

 

/
