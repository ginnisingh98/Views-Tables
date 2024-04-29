--------------------------------------------------------
--  DDL for Package JTF_TASK_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RESOURCES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkrs.pls 120.2 2006/09/29 22:22:12 twan ship $ */
/*#
 * This is the public package to crete, update, and delete task resources.
 *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task Resource
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */



---------------------------------------------------------------------------
--Define Global Variables
---------------------------------------------------------------------------
    G_PKG_NAME	CONSTANT	VARCHAR2(30):='JTF_TASK_RESOURCES_PUB';
    G_USER		CONSTANT	VARCHAR2(30):=FND_GLOBAL.USER_ID;
    G_FALSE		CONSTANT	VARCHAR2(30):=FND_API.G_FALSE;
    G_TRUE		CONSTANT	VARCHAR2(30):=FND_API.G_TRUE;
---------------------------------------------------------------------------

--Define RECORD and TABLE types

Type TASK_RSC_REQ_REC  is RECORD(
    RESOURCE_REQ_ID      jtf_task_rsc_reqs.resource_req_id%type,
    TASK_TYPE_ID         jtf_task_rsc_reqs.task_type_id%type,
    TASK_ID              jtf_task_rsc_reqs.task_id%type,
    TASK_TEMPLATE_ID     jtf_task_rsc_reqs.task_template_id%type,
    RESOURCE_TYPE_CODE   jtf_task_rsc_reqs.resource_type_code%type,
    REQUIRED_UNITS       jtf_task_rsc_reqs.required_units%type,
    ENABLED_FLAG         jtf_task_rsc_reqs.enabled_flag%type,
    ATTRIBUTE1           jtf_task_rsc_reqs.attribute1%type,
    ATTRIBUTE2           jtf_task_rsc_reqs.attribute2%type,
    ATTRIBUTE3           jtf_task_rsc_reqs.attribute3%type,
    ATTRIBUTE4           jtf_task_rsc_reqs.attribute4%type,
    ATTRIBUTE5           jtf_task_rsc_reqs.attribute5%type,
    ATTRIBUTE6           jtf_task_rsc_reqs.attribute6%type,
    ATTRIBUTE7           jtf_task_rsc_reqs.attribute7%type,
    ATTRIBUTE8           jtf_task_rsc_reqs.attribute8%type,
    ATTRIBUTE9           jtf_task_rsc_reqs.attribute9%type,
    ATTRIBUTE10          jtf_task_rsc_reqs.attribute10%type,
    ATTRIBUTE11          jtf_task_rsc_reqs.attribute11%type,
    ATTRIBUTE12          jtf_task_rsc_reqs.attribute12%type,
    ATTRIBUTE13          jtf_task_rsc_reqs.attribute13%type,
    ATTRIBUTE14          jtf_task_rsc_reqs.attribute14%type,
    ATTRIBUTE15          jtf_task_rsc_reqs.attribute15%type,
    ATTRIBUTE_CATEGORY   jtf_task_rsc_reqs.attribute_category%type
);

Type task_rsc_req_tbl is table of TASK_RSC_REQ_REC
index by binary_integer;

type sort_rec is record(
    field_name      varchar2(30),
    asc_dsc_flag    char(1)        default 'A'
);

Type sort_data is table of sort_rec
index by binary_integer;


TYPE  TASK_RSRC_REQ_REC is RECORD(
    RESOURCE_REQ_ID      NUMBER,
    TASK_ID              NUMBER,
    TASK_NAME            VARCHAR2(80),
    TASK_TYPE_ID         NUMBER,
    TASK_TYPE_NAME       VARCHAR2(30),
    TASK_TEMPLATE_ID     NUMBER,
    TASK_TEMPLATE_NAME   VARCHAR2(80),
    RESOURCE_TYPE_CODE   VARCHAR2(30),
    REQUIRED_UNITS       NUMBER,
    ENABLED_FLAG         VARCHAR2(1)
);

/*#
 * Procedure to create task resource requirements.
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_id the task id to create the resource requirements
 * @param p_task_name the task name to create the resource requirements
 * @param p_task_number the task number to create the resource requirements
 * @param p_task_type_id the task type id to create the resource requirements
 * @param p_task_type_name the task type name to create the resource requirements
 * @param p_task_template_id the task template id to create the resource requirements
 * @param p_task_template_name the task template name to create the resource requirements
 * @param p_resource_type_code the resource type code to create the resource requirements
 * @param p_required_units the required units to create the resource requirements
 * @param p_enabled_flag the enabled flag to create the resource requirements
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_resource_req_id returns the resource requirements id
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
 * @rep:displayname Create Task Resource Requirement
 * @rep:compatibility S
 */
Procedure CREATE_TASK_RSRC_REQ(
    P_API_VERSION            IN	NUMBER,
    P_INIT_MSG_LIST          IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_COMMIT                 IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    P_TASK_ID                IN	NUMBER	  DEFAULT fnd_api.g_miss_num,
    P_TASK_NAME              IN	VARCHAR2  DEFAULT fnd_api.g_miss_char,
    P_TASK_NUMBER            IN	VARCHAR2  DEFAULT fnd_api.g_miss_char,
    P_TASK_TYPE_ID           IN	NUMBER 	  DEFAULT fnd_api.g_miss_num,
    P_TASK_TYPE_NAME         IN	VARCHAR2  DEFAULT fnd_api.g_miss_char,
    P_TASK_TEMPLATE_ID       IN	NUMBER	  DEFAULT fnd_api.g_miss_num,
    P_TASK_TEMPLATE_NAME     IN	VARCHAR2  DEFAULT fnd_api.g_miss_char,
    P_RESOURCE_TYPE_CODE     IN	VARCHAR2,
    P_REQUIRED_UNITS         IN	NUMBER,
    P_ENABLED_FLAG           IN	VARCHAR2  DEFAULT jtf_task_utl.g_no,
    X_RETURN_STATUS          OUT NOCOPY	VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY	NUMBER,
    X_MSG_DATA               OUT NOCOPY	VARCHAR2,
    X_RESOURCE_REQ_ID        OUT NOCOPY	NUMBER,
    p_attribute1             IN VARCHAR2 DEFAULT null,
    p_attribute2             IN VARCHAR2 DEFAULT null,
    p_attribute3             IN VARCHAR2 DEFAULT null,
    p_attribute4             IN VARCHAR2 DEFAULT null,
    p_attribute5             IN VARCHAR2 DEFAULT null,
    p_attribute6             IN VARCHAR2 DEFAULT null,
    p_attribute7             IN VARCHAR2 DEFAULT null,
    p_attribute8             IN VARCHAR2 DEFAULT null,
    p_attribute9             IN VARCHAR2 DEFAULT null,
    p_attribute10            IN VARCHAR2 DEFAULT null,
    p_attribute11            IN VARCHAR2 DEFAULT null,
    p_attribute12            IN VARCHAR2 DEFAULT null,
    p_attribute13            IN VARCHAR2 DEFAULT null,
    p_attribute14            IN VARCHAR2 DEFAULT null,
    p_attribute15            IN VARCHAR2 DEFAULT null,
    p_attribute_category     IN VARCHAR2 DEFAULT null
);




/*#
 * Procedure to update task resource requirements.
 * @param p_api_version the standard API version number
 * @param p_object_version_number the object version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_resource_req_id the resource request id to update the resource requirements
 * @param p_task_id the task id to update the resource requirements
 * @param p_task_name the task name to update the resource requirements
 * @param p_task_number the task number to update the resource requirements
 * @param p_task_type_id the task type id to update the resource requirements
 * @param p_task_type_name the task type name to update the resource requirements
 * @param p_task_template_id the task template id to update the resource requirements
 * @param p_task_template_name the task template name to update the resource requirements
 * @param p_resource_type_code the resource type code to update the resource requirements
 * @param p_required_units the required units to update the resource requirements
 * @param p_enabled_flag the enabled flag to update the resource requirements
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
 * @rep:displayname Update Task Resource Requirement
 * @rep:compatibility S
 */
Procedure UPDATE_TASK_RSCR_REQ(
    P_API_VERSION            IN	NUMBER,
    P_OBJECT_VERSION_NUMBER  IN OUT NOCOPY	NUMBER,
    P_INIT_MSG_LIST          IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                 IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_RESOURCE_REQ_ID        IN	NUMBER,
    P_TASK_ID                IN	NUMBER 	 default fnd_api.g_miss_num,
    P_TASK_NAME	             IN	VARCHAR2 default null,
    P_TASK_NUMBER            IN	VARCHAR2 default null,
    P_TASK_TYPE_ID           IN	NUMBER 	 default fnd_api.g_miss_num,
    P_TASK_TYPE_NAME         IN	VARCHAR2 default null,
    P_TASK_TEMPLATE_ID       IN	NUMBER   default fnd_api.g_miss_num,
    P_TASK_TEMPLATE_NAME     IN	VARCHAR2 default null,
    P_RESOURCE_TYPE_CODE     IN	VARCHAR2,
    P_REQUIRED_UNITS         IN	NUMBER,
    P_ENABLED_FLAG           IN	VARCHAR2 DEFAULT jtf_task_utl.g_no,
    X_RETURN_STATUS          OUT NOCOPY	VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY	NUMBER,
    X_MSG_DATA               OUT NOCOPY	VARCHAR2,
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
    p_attribute_category     IN VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
);


/*#
 * Procedure to delete task resource requirements.
 * @param p_api_version the standard API version number
 * @param p_object_version_number the object version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * @param p_resource_req_id the resource requirements id for delete
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
 * @rep:displayname Delete Task Resource Requirement
 * @rep:compatibility S
 */
procedure DELETE_TASK_RSRC_REQ(
    P_API_VERSION            IN NUMBER,
    P_OBJECT_VERSION_NUMBER  IN NUMBER,
    P_INIT_MSG_LIST          IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT	 	     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_RESOURCE_REQ_ID	     IN	NUMBER,
    X_RETURN_STATUS	     OUT NOCOPY VARCHAR2,
    X_MSG_COUNT	             OUT NOCOPY NUMBER,
    X_MSG_DATA	             OUT NOCOPY VARCHAR2
);


/*#
 * Procedure to get the task resource requirements.
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_resource_req_id the resource request id to be queried
 * @param p_resource_req_name the resource request name to be queried
 * @param p_task_id the task id to be queried
 * @param p_task_name the task name to be queried
 * @param p_task_type_id the task type id to be queried
 * @param p_task_type_name the task type name to be queried
 * @param p_task_template_id the task template id to be queried
 * @param p_task_template_name the task template name to be queried
 * @param p_sort_data the sort data to be queried
 * @param p_query_or_next_code flag to build the sql query statement
 * @param p_start_pointer row data start pointer to be queried
 * @param p_rec_wanted row data end pointer to be queried
 * @param p_show_all flag to show all data to be queried
 * @param p_resource_type_code the resource type code to be queried
 * @param p_required_units the required units to be queried
 * @param p_enabled_flag the enabled flag to be queried
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_task_rsc_req_rec returns the task resource requirements
 * @param x_total_retrieved returns the total number of data retrieved
 * @param x_total_returned returns the total number of data
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Task Resource Requirement
 * @rep:compatibility S
 */
Procedure GET_TASK_RSRC_REQ(
    P_API_VERSION	     IN	NUMBER,
    P_INIT_MSG_LIST	     IN	VARCHAR2 DEFAULT G_FALSE,
    P_COMMIT		     IN	VARCHAR2 DEFAULT G_FALSE,
    P_RESOURCE_REQ_ID	     IN	NUMBER,
    P_RESOURCE_REQ_NAME	     IN	VARCHAR2 DEFAULT NULL,
    P_TASK_ID		     IN	NUMBER DEFAULT NULL,
    P_TASK_NAME		     IN	VARCHAR2 DEFAULT NULL,
    P_TASK_TYPE_ID	     IN	NUMBER DEFAULT NULL,
    P_TASK_TYPE_NAME	     IN	VARCHAR2 DEFAULT NULL,
    P_TASK_TEMPLATE_ID	     IN	NUMBER DEFAULT NULL,
    P_TASK_TEMPLATE_NAME     IN	VARCHAR2 DEFAULT NULL,
    P_SORT_DATA              IN JTF_TASK_RESOURCES_PUB.SORT_DATA,
    P_QUERY_OR_NEXT_CODE     IN	VARCHAR2 DEFAULT 'Q',
    P_START_POINTER          IN	NUMBER,
    P_REC_WANTED             IN	NUMBER,
    P_SHOW_ALL               IN VARCHAR2 DEFAULT 'Y',
    P_RESOURCE_TYPE_CODE     IN	VARCHAR2,
    P_REQUIRED_UNITS	     IN	NUMBER,
    P_ENABLED_FLAG	     IN	VARCHAR2 DEFAULT jtf_task_utl.g_no,
    X_RETURN_STATUS	     OUT NOCOPY	VARCHAR2,
    X_MSG_COUNT		     OUT NOCOPY	NUMBER,
    X_MSG_DATA		     OUT NOCOPY	VARCHAR2,
    X_TASK_RSC_REQ_REC	     OUT NOCOPY	JTF_TASK_RESOURCES_PUB.TASK_RSC_REQ_TBL,
    X_TOTAL_RETRIEVED        OUT NOCOPY NUMBER,
    X_TOTAL_RETURNED         OUT NOCOPY	NUMBER
);



/*#
 * Procedure to lock the row of task resource requirements.
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_resource_requirement_id the resource requirement id to be locked
 * @param p_object_version_number the object version number
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
 * @rep:lifecycle active
 * @rep:displayname Lock Task Resource
 * @rep:compatibility S
 */
PROCEDURE LOCK_TASK_RESOURCES(
     P_API_VERSION           IN NUMBER,
     P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT fnd_api.g_false,
     P_COMMIT                IN VARCHAR2 DEFAULT fnd_api.g_false,
     P_RESOURCE_REQUIREMENT_ID IN NUMBER,
     P_OBJECT_VERSION_NUMBER IN NUMBER,
     X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
     X_MSG_DATA              OUT NOCOPY VARCHAR2,
     X_MSG_COUNT             OUT NOCOPY NUMBER
);

End;

 

/
