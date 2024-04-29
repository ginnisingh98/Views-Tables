--------------------------------------------------------
--  DDL for Package JTF_TASK_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_ASSIGNMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkas.pls 120.9 2006/07/27 11:22:35 sbarat ship $ */
/*#
 * A public interface for Tasks that can be used to create, update, and delete task assignments.
 *
 * @rep:scope public
 * @rep:product CAC
 * @rep:displayname Task Assignment Management
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */


---------------------------------------------------------------------------
--Define Global Variables
---------------------------------------------------------------------------
G_PKG_NAME	CONSTANT	VARCHAR2(30):='JTF_TASK_ASSIGNMENT_PUB';
G_USER		CONSTANT	VARCHAR2(30):=FND_GLOBAL.USER_ID;
---------------------------------------------------------------------------


  TYPE task_assignments_rec IS RECORD (
   task_assignment_id      NUMBER,
   object_version_number     NUMBER,
   task_id            NUMBER,
   resource_type_code      VARCHAR2(30),
   resource_id          NUMBER,
   assignment_status_id     NUMBER,
   actual_effort         NUMBER,
   resource_territory_id     NUMBER,
   actual_effort_uom       VARCHAR2(3),
   schedule_flag         VARCHAR2(1),
   alarm_type_code        VARCHAR2(30),
   alarm_contact         VARCHAR2(200),
   shift_construct_id      NUMBER,
   sched_travel_distance     NUMBER,
   sched_travel_duration     NUMBER,
   sched_travel_duration_uom   VARCHAR2(3),
   actual_travel_distance    NUMBER,
   actual_travel_duration    NUMBER,
   actual_travel_duration_uom  VARCHAR2(3),
   actual_start_date       DATE,
   actual_end_date        DATE,
   palm_flag           VARCHAR2(1),
   wince_flag          VARCHAR2(1),
   laptop_flag          VARCHAR2(1),
   device1_flag         VARCHAR2(1),
   device2_flag         VARCHAR2(1),
   device3_flag         VARCHAR2(1),
   attribute1          VARCHAR2(150),
   attribute2          VARCHAR2(150),
   attribute3          VARCHAR2(150),
   attribute4          VARCHAR2(150),
   attribute5          VARCHAR2(150),
   attribute6          VARCHAR2(150),
   attribute7          VARCHAR2(150),
   attribute8          VARCHAR2(150),
   attribute9          VARCHAR2(150),
   attribute10          VARCHAR2(150),
   attribute11          VARCHAR2(150),
   attribute12          VARCHAR2(150),
   attribute13          VARCHAR2(150),
   attribute14          VARCHAR2(150),
   attribute15          VARCHAR2(150),
   attribute_category      VARCHAR2(30),
   SHOW_ON_CALENDAR       VARCHAR2(1),
   CATEGORY_ID          NUMBER
  );

  p_task_assignments_rec    task_assignments_rec;

  type task_assignments_user_hooks is Record
  (
task_assignment_id        NUMBER,
task_id              NUMBER ,
task_number            VARCHAR2(30) ,
resource_type_code        VARCHAR2(30),
resource_id            NUMBER,
actual_effort           NUMBER ,
actual_effort_uom         VARCHAR2(3) ,
schedule_flag           VARCHAR2(1) ,
alarm_type_code          VARCHAR2(30) ,
alarm_contact           VARCHAR2(200) ,
sched_travel_distance       NUMBER ,
sched_travel_duration       NUMBER ,
sched_travel_duration_uom     VARCHAR2(3) ,
actual_travel_distance      NUMBER ,
actual_travel_duration      NUMBER ,
actual_travel_duration_uom    VARCHAR2(3) ,
actual_start_date         DATE ,
actual_end_date          DATE ,
palm_flag             VARCHAR2(1) ,
wince_flag            VARCHAR2(1) ,
laptop_flag            VARCHAR2(1) ,
device1_flag           VARCHAR2(1) ,
device2_flag           VARCHAR2(1) ,
device3_flag           VARCHAR2(1) ,
resource_territory_id       NUMBER ,
assignment_status_id       NUMBER,
shift_construct_id        NUMBER,
SHOW_ON_CALENDAR         VARCHAR2(1),
CATEGORY_ID            NUMBER,
assignee_role           VARCHAR2(10),
booking_start_date      DATE,
booking_end_date        DATE
);

p_task_assignments_user_hooks task_assignments_user_hooks ;



/*#
 * Creates a Task Assignment.
 *
 * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_task_assignment_id Unique task assignment id. It will be generated from the sequence <code>jtf_task_assignments_s</code> when not passed.
 * @param p_task_id Unique Identifier for the task to be used for assignment creation. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
 * @rep:paraminfo {@rep:required}
 * @param p_task_number Unique task number to be used for assignment creation. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
 * @rep:paraminfo {@rep:required}
 * @param p_task_name No longer in use.
 * @param p_resource_type_code Resource type code for assignment creation. A task assignment resource is identified with the resource type code and resource identifier therefore this should be used along with <code>p_resource_id</code>.
 * @rep:paraminfo {@rep:required}
 * @param p_resource_id Resource identifier for assignment creation. Should be used along with <code>p_resource_type_code</code>.
 * @rep:paraminfo {@rep:required}
 * @param p_resource_name No longer in use.
 * @param p_actual_effort Actual effort exerted by the resource. Should be used along with <code>p_actual_effort_uom</code>.
 * @param p_actual_effort_uom Unit of Measure for the actual effort. Should be used along with <code>p_actual_effort</code>.
 * @param p_schedule_flag Flag to denote if the assignment needs to be scheduled - Not currently used.
 * @param p_alarm_type_code Alarm type code for assignment creation - Reserved for future use.
 * @param p_alarm_contact Alarm contact for assignment creation - Reserved for future use.
 * @param p_sched_travel_distance Scheduled travel distance for this assignment.
 * @param p_sched_travel_duration Scheduled travel duration for this assignment. Should be passed along with <code>p_sched_travel_duration_uom</code>.
 * @param p_sched_travel_duration_uom Unit of measure for scheduled travel duration. Should be passed along with <code>p_sched_travel_duration</code>.
 * @param p_actual_travel_distance Actual distance traveled, logged by the resource.
 * @param p_actual_travel_duration Actual travel duration, logged by the resource. Should be used along with <code>p_actual_travel_duration_uom</code>.
 * @param p_actual_travel_duration_uom Unit of measure for the actual travel duration. Should be used along with <code>p_actual_travel_duration</code>.
 * @param p_actual_start_date Actual start date and time for this assignment.
 * @param p_actual_end_date Actual end date and time for this assignment.
 * @param p_palm_flag Reserved for internal use only.
 * @param p_wince_flag Reserved for internal use only.
 * @param p_laptop_flag Reserved for internal use only.
 * @param p_device1_flag Reserved for internal use only.
 * @param p_device2_flag Reserved for internal use only.
 * @param p_device3_flag Reserved for internal use only.
 * @param p_resource_territory_id Unique territory identifier for the task assignment resource.
 * @param p_assignment_status_id Unique assignment status identifier for this assignment.
 * @rep:paraminfo {@rep:required}
 * @param p_shift_construct_id Unique identifier for the shift used to schedule this assignment - Reserved for internal use only.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param x_task_assignment_id The unique identifier returned for the task assignment record created.
 * @param p_attribute1 Attribute1 of customer flex fields.
 * @param p_attribute2 Attribute2 of customer flex fields.
 * @param p_attribute3 Attribute3 of customer flex fields.
 * @param p_attribute4 Attribute4 of customer flex fields.
 * @param p_attribute5 Attribute5 of customer flex fields.
 * @param p_attribute6 Attribute6 of customer flex fields.
 * @param p_attribute7 Attribute7 of customer flex fields.
 * @param p_attribute8 Attribute8 of customer flex fields.
 * @param p_attribute9 Attribute9 of customer flex fields.
 * @param p_attribute10 Attribute10 of customer flex fields.
 * @param p_attribute11 Attribute11 of customer flex fields.
 * @param p_attribute12 Attribute12 of customer flex fields.
 * @param p_attribute13 Attribute13 of customer flex fields.
 * @param p_attribute14 Attribute14 of customer flex fields.
 * @param p_attribute15 Attribute15 of customer flex fields.
 * @param p_attribute_category Attribute category for the customer flex fields.
 * @param p_show_on_calendar Flag to show task on resource's calendar. The task will only show up on Resource's calendar if this flag is set to <code>'Y'</code> and there is a set of date with time present on task level.
 * This flag is defaulted to <code>'Y'</code> if not passed.
 * @param p_category_id Reserved unique identifier for personal category defined by resource in their calendar. This is a foreign key to <code>jtf_perz_data.perz_date_id</code>.
 * @param p_enable_workflow Flag to enable workflow passed as-is to <code>oracle.apps.jtf.cac.task.createTaskAssignment</code> business event.
 * @rep:paraminfo {@rep:required}
 * @param p_abort_workflow Flag to abort workflow passed as-is to <code>oracle.apps.jtf.cac.task.createTaskAssignment</code> business event.
 * @rep:paraminfo {@rep:required}
 * @param p_object_capacity_id Unique identifier for the object capacity for this assignment. This is a foreign key to <code>cac_object_capacity.object_capacity_id</code>.
 * @rep:paraminfo {@rep:required}
 * @param p_free_busy_type Unique identifier for the free_busy_type for this assignment.
 * @rep:paraminfo {@rep:required}
 *
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Task Assignment
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.jtf.cac.task.createTaskAssignment
 */
 procedure create_task_assignment(
    P_API_VERSION		    IN  NUMBER,
	P_INIT_MSG_LIST		    IN  VARCHAR2 	DEFAULT FND_API.G_FALSE,
	P_COMMIT		    IN  VARCHAR2	DEFAULT FND_API.G_FALSE,
    P_TASK_ASSIGNMENT_ID      IN  NUMBER  DEFAULT NULL,
	P_TASK_ID            IN  NUMBER	DEFAULT NULL,
	P_TASK_NUMBER		    IN  VARCHAR2 DEFAULT NULL,
    P_TASK_NAME           IN  VARCHAR2 DEFAULT NULL,
	P_RESOURCE_TYPE_CODE      IN  VARCHAR2,
	P_RESOURCE_ID          IN  NUMBER,
    P_RESOURCE_NAME         IN  NUMBER  DEFAULT NULL,
	P_ACTUAL_EFFORT         IN  NUMBER	DEFAULT NULL,
	P_ACTUAL_EFFORT_UOM       IN  VARCHAR2	DEFAULT NULL,
	P_SCHEDULE_FLAG         IN  VARCHAR2	DEFAULT NULL,
	P_ALARM_TYPE_CODE        IN  VARCHAR2	DEFAULT NULL,
	P_ALARM_CONTACT         IN  VARCHAR2	DEFAULT NULL,
	P_SCHED_TRAVEL_DISTANCE     IN  NUMBER	DEFAULT NULL,
	P_SCHED_TRAVEL_DURATION     IN  NUMBER	DEFAULT NULL,
	P_SCHED_TRAVEL_DURATION_UOM   IN  VARCHAR2	DEFAULT NULL,
	P_ACTUAL_TRAVEL_DISTANCE    IN  NUMBER	DEFAULT NULL,
	P_ACTUAL_TRAVEL_DURATION    IN  NUMBER	DEFAULT NULL,
	P_ACTUAL_TRAVEL_DURATION_UOM  IN  VARCHAR2	DEFAULT NULL,
	P_ACTUAL_START_DATE       IN  DATE	DEFAULT NULL,
	P_ACTUAL_END_DATE        IN  DATE	DEFAULT NULL,
	P_PALM_FLAG           IN  VARCHAR2	DEFAULT NULL,
	P_WINCE_FLAG          IN  VARCHAR2	DEFAULT NULL,
	P_LAPTOP_FLAG          IN  VARCHAR2	DEFAULT NULL,
	P_DEVICE1_FLAG         IN  VARCHAR2	DEFAULT NULL,
	P_DEVICE2_FLAG         IN  VARCHAR2	DEFAULT NULL,
	P_DEVICE3_FLAG         IN  VARCHAR2	DEFAULT NULL,
    P_RESOURCE_TERRITORY_ID     IN  NUMBER  DEFAULT NULL,
    P_ASSIGNMENT_STATUS_ID     IN  NUMBER,
    P_SHIFT_CONSTRUCT_ID      IN  NUMBER  DEFAULT NULL,
	X_RETURN_STATUS		    OUT  NOCOPY	VARCHAR2,
	X_MSG_COUNT           OUT  NOCOPY  NUMBER,
	X_MSG_DATA			OUT  NOCOPY  VARCHAR2,
	X_TASK_ASSIGNMENT_ID		OUT  NOCOPY  NUMBER,
    p_attribute1          IN  VARCHAR2 DEFAULT null,
    p_attribute2          IN  VARCHAR2 DEFAULT null,
    p_attribute3          IN  VARCHAR2 DEFAULT null,
    p_attribute4          IN  VARCHAR2 DEFAULT null,
    p_attribute5          IN  VARCHAR2 DEFAULT null,
    p_attribute6          IN  VARCHAR2 DEFAULT null,
    p_attribute7          IN  VARCHAR2 DEFAULT null,
    p_attribute8          IN  VARCHAR2 DEFAULT null,
    p_attribute9          IN  VARCHAR2 DEFAULT null,
    p_attribute10          IN  VARCHAR2 DEFAULT null,
    p_attribute11          IN  VARCHAR2 DEFAULT null,
    p_attribute12          IN  VARCHAR2 DEFAULT null,
    p_attribute13          IN  VARCHAR2 DEFAULT null,
    p_attribute14          IN  VARCHAR2 DEFAULT null,
    p_attribute15          IN  VARCHAR2 DEFAULT null,
    p_attribute_category      IN  VARCHAR2 DEFAULT null,
    P_SHOW_ON_CALENDAR       IN  VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
    P_CATEGORY_ID          IN  NUMBER  DEFAULT null,
    p_enable_workflow        IN  VARCHAR2,
    p_abort_workflow        IN  VARCHAR2,
    p_object_capacity_id      IN  NUMBER ,
    p_free_busy_type         IN VARCHAR2
);



 procedure create_task_assignment(
    P_API_VERSION		    IN  NUMBER,
	P_INIT_MSG_LIST		    IN  VARCHAR2 	DEFAULT FND_API.G_FALSE,
	P_COMMIT		    IN  VARCHAR2	DEFAULT FND_API.G_FALSE,
    P_TASK_ASSIGNMENT_ID      IN  NUMBER  DEFAULT NULL,
	P_TASK_ID            IN  NUMBER	DEFAULT NULL,
	P_TASK_NUMBER		    IN  VARCHAR2 DEFAULT NULL,
    P_TASK_NAME           IN  VARCHAR2 DEFAULT NULL,
	P_RESOURCE_TYPE_CODE      IN  VARCHAR2,
	P_RESOURCE_ID          IN  NUMBER,
    P_RESOURCE_NAME         IN  NUMBER  DEFAULT NULL,
	P_ACTUAL_EFFORT         IN  NUMBER	DEFAULT NULL,
	P_ACTUAL_EFFORT_UOM       IN  VARCHAR2	DEFAULT NULL,
	P_SCHEDULE_FLAG         IN  VARCHAR2	DEFAULT NULL,
	P_ALARM_TYPE_CODE        IN  VARCHAR2	DEFAULT NULL,
	P_ALARM_CONTACT         IN  VARCHAR2	DEFAULT NULL,
	P_SCHED_TRAVEL_DISTANCE     IN  NUMBER	DEFAULT NULL,
	P_SCHED_TRAVEL_DURATION     IN  NUMBER	DEFAULT NULL,
	P_SCHED_TRAVEL_DURATION_UOM   IN  VARCHAR2	DEFAULT NULL,
	P_ACTUAL_TRAVEL_DISTANCE    IN  NUMBER	DEFAULT NULL,
	P_ACTUAL_TRAVEL_DURATION    IN  NUMBER	DEFAULT NULL,
	P_ACTUAL_TRAVEL_DURATION_UOM  IN  VARCHAR2	DEFAULT NULL,
	P_ACTUAL_START_DATE       IN  DATE	DEFAULT NULL,
	P_ACTUAL_END_DATE        IN  DATE	DEFAULT NULL,
	P_PALM_FLAG           IN  VARCHAR2	DEFAULT NULL,
	P_WINCE_FLAG          IN  VARCHAR2	DEFAULT NULL,
	P_LAPTOP_FLAG          IN  VARCHAR2	DEFAULT NULL,
	P_DEVICE1_FLAG         IN  VARCHAR2	DEFAULT NULL,
	P_DEVICE2_FLAG         IN  VARCHAR2	DEFAULT NULL,
	P_DEVICE3_FLAG         IN  VARCHAR2	DEFAULT NULL,
    P_RESOURCE_TERRITORY_ID     IN  NUMBER  DEFAULT NULL,
    P_ASSIGNMENT_STATUS_ID     IN  NUMBER,
    P_SHIFT_CONSTRUCT_ID      IN  NUMBER  DEFAULT NULL,
	X_RETURN_STATUS		    OUT  NOCOPY	VARCHAR2,
	X_MSG_COUNT           OUT  NOCOPY  NUMBER,
	X_MSG_DATA			OUT  NOCOPY  VARCHAR2,
	X_TASK_ASSIGNMENT_ID		OUT  NOCOPY  NUMBER,
    p_attribute1          IN  VARCHAR2 DEFAULT null,
    p_attribute2          IN  VARCHAR2 DEFAULT null,
    p_attribute3          IN  VARCHAR2 DEFAULT null,
    p_attribute4          IN  VARCHAR2 DEFAULT null,
    p_attribute5          IN  VARCHAR2 DEFAULT null,
    p_attribute6          IN  VARCHAR2 DEFAULT null,
    p_attribute7          IN  VARCHAR2 DEFAULT null,
    p_attribute8          IN  VARCHAR2 DEFAULT null,
    p_attribute9          IN  VARCHAR2 DEFAULT null,
    p_attribute10          IN  VARCHAR2 DEFAULT null,
    p_attribute11          IN  VARCHAR2 DEFAULT null,
    p_attribute12          IN  VARCHAR2 DEFAULT null,
    p_attribute13          IN  VARCHAR2 DEFAULT null,
    p_attribute14          IN  VARCHAR2 DEFAULT null,
    p_attribute15          IN  VARCHAR2 DEFAULT null,
    p_attribute_category      IN  VARCHAR2 DEFAULT null,
    P_SHOW_ON_CALENDAR       IN  VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
    P_CATEGORY_ID          IN  NUMBER  DEFAULT null,
    p_enable_workflow        IN  VARCHAR2,
    p_abort_workflow        IN  VARCHAR2,
    p_object_capacity_id      IN  NUMBER
);



Procedure Create_Task_Assignment
	(P_API_VERSION			    IN	  NUMBER						     ,
	P_INIT_MSG_LIST			    IN 	  VARCHAR2 	DEFAULT FND_API.G_FALSE ,
	P_COMMIT			      IN	  VARCHAR2	DEFAULT FND_API.G_FALSE ,
  p_task_assignment_id      IN    NUMBER DEFAULT NULL,
	P_TASK_ID			      IN	  NUMBER		DEFAULT NULL       ,
	P_TASK_NUMBER			    IN	  VARCHAR2  DEFAULT NULL			 ,
  p_task_name          IN    varchar2 DEFAULT NULL,
	P_RESOURCE_TYPE_CODE      IN	  VARCHAR2					     ,
	P_RESOURCE_ID          IN	  NUMBER,
  p_resource_name         IN    NUMBER DEFAULT NULL,
	P_ACTUAL_EFFORT         IN   NUMBER		DEFAULT NULL			 ,
	P_ACTUAL_EFFORT_UOM       IN   VARCHAR2	DEFAULT NULL			 ,
	P_SCHEDULE_FLAG         IN   VARCHAR2	DEFAULT NULL       ,
	P_ALARM_TYPE_CODE        IN   VARCHAR2	DEFAULT NULL			 ,
	P_ALARM_CONTACT         IN   VARCHAR2	DEFAULT NULL			 ,
	P_SCHED_TRAVEL_DISTANCE     IN   NUMBER		DEFAULT NULL			 ,
	P_SCHED_TRAVEL_DURATION     IN   NUMBER		DEFAULT NULL			 ,
	P_SCHED_TRAVEL_DURATION_UOM   IN   VARCHAR2	DEFAULT NULL			 ,
	P_ACTUAL_TRAVEL_DISTANCE    IN   NUMBER		DEFAULT NULL			 ,
	P_ACTUAL_TRAVEL_DURATION    IN   NUMBER		DEFAULT NULL			 ,
	P_ACTUAL_TRAVEL_DURATION_UOM  IN   VARCHAR2	DEFAULT NULL			 ,
	P_ACTUAL_START_DATE       IN   DATE		DEFAULT NULL			 ,
	P_ACTUAL_END_DATE        IN   DATE		DEFAULT NULL			 ,
	P_PALM_FLAG           IN   VARCHAR2	DEFAULT NULL,
	P_WINCE_FLAG          IN   VARCHAR2	DEFAULT NULL,
	P_LAPTOP_FLAG          IN   VARCHAR2	DEFAULT NULL,
	P_DEVICE1_FLAG         IN   VARCHAR2	DEFAULT NULL,
	P_DEVICE2_FLAG         IN   VARCHAR2	DEFAULT NULL,
	P_DEVICE3_FLAG         IN   VARCHAR2	DEFAULT NULL,
  P_RESOURCE_TERRITORY_ID     IN   NUMBER   DEFAULT NULL       ,
  P_ASSIGNMENT_STATUS_ID     IN   NUMBER                ,
  P_SHIFT_CONSTRUCT_ID      IN   NUMBER   DEFAULT NULL      ,
	X_RETURN_STATUS			    OUT NOCOPY	  VARCHAR2					     ,
	X_MSG_COUNT			      OUT NOCOPY	  NUMBER 						     ,
	X_MSG_DATA			      OUT NOCOPY	  VARCHAR2 					     ,
	X_TASK_ASSIGNMENT_ID		  OUT NOCOPY	  NUMBER						    ,
      p_attribute1       IN    VARCHAR2 DEFAULT null ,
    p_attribute2       IN    VARCHAR2 DEFAULT null ,
    p_attribute3       IN    VARCHAR2 DEFAULT null ,
    p_attribute4       IN    VARCHAR2 DEFAULT null ,
    p_attribute5       IN    VARCHAR2 DEFAULT null ,
    p_attribute6       IN    VARCHAR2 DEFAULT null ,
    p_attribute7       IN    VARCHAR2 DEFAULT null ,
    p_attribute8       IN    VARCHAR2 DEFAULT null ,
    p_attribute9       IN    VARCHAR2 DEFAULT null ,
    p_attribute10       IN    VARCHAR2 DEFAULT null ,
    p_attribute11       IN    VARCHAR2 DEFAULT null ,
    p_attribute12       IN    VARCHAR2 DEFAULT null ,
    p_attribute13       IN    VARCHAR2 DEFAULT null ,
    p_attribute14       IN    VARCHAR2 DEFAULT null ,
    p_attribute15       IN    VARCHAR2 DEFAULT null ,
    p_attribute_category   IN    VARCHAR2 DEFAULT null ,
    P_SHOW_ON_CALENDAR    in    VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
    P_CATEGORY_ID       in    NUMBER  DEFAULT null,
    p_enable_workflow     IN    VARCHAR2,
    p_abort_workflow     IN    VARCHAR2  ) ;



Procedure Create_Task_Assignment
	(P_API_VERSION			    IN	  NUMBER						     ,
	P_INIT_MSG_LIST			    IN 	  VARCHAR2 	DEFAULT FND_API.G_FALSE ,
	P_COMMIT			      IN	  VARCHAR2	DEFAULT FND_API.G_FALSE ,
  p_task_assignment_id      IN    NUMBER DEFAULT NULL,
	P_TASK_ID			      IN	  NUMBER		DEFAULT NULL       ,
	P_TASK_NUMBER			    IN	  VARCHAR2  DEFAULT NULL			 ,
  p_task_name          IN    varchar2 DEFAULT NULL,
	P_RESOURCE_TYPE_CODE      IN	  VARCHAR2					     ,
	P_RESOURCE_ID          IN	  NUMBER,
  p_resource_name         IN    NUMBER DEFAULT NULL,
	P_ACTUAL_EFFORT         IN   NUMBER		DEFAULT NULL			 ,
	P_ACTUAL_EFFORT_UOM       IN   VARCHAR2	DEFAULT NULL			 ,
	P_SCHEDULE_FLAG         IN   VARCHAR2	DEFAULT NULL       ,
	P_ALARM_TYPE_CODE        IN   VARCHAR2	DEFAULT NULL			 ,
	P_ALARM_CONTACT         IN   VARCHAR2	DEFAULT NULL			 ,
	P_SCHED_TRAVEL_DISTANCE     IN   NUMBER		DEFAULT NULL			 ,
	P_SCHED_TRAVEL_DURATION     IN   NUMBER		DEFAULT NULL			 ,
	P_SCHED_TRAVEL_DURATION_UOM   IN   VARCHAR2	DEFAULT NULL			 ,
	P_ACTUAL_TRAVEL_DISTANCE    IN   NUMBER		DEFAULT NULL			 ,
	P_ACTUAL_TRAVEL_DURATION    IN   NUMBER		DEFAULT NULL			 ,
	P_ACTUAL_TRAVEL_DURATION_UOM  IN   VARCHAR2	DEFAULT NULL			 ,
	P_ACTUAL_START_DATE       IN   DATE		DEFAULT NULL			 ,
	P_ACTUAL_END_DATE        IN   DATE		DEFAULT NULL			 ,
	P_PALM_FLAG           IN   VARCHAR2	DEFAULT NULL,
	P_WINCE_FLAG          IN   VARCHAR2	DEFAULT NULL,
	P_LAPTOP_FLAG          IN   VARCHAR2	DEFAULT NULL,
	P_DEVICE1_FLAG         IN   VARCHAR2	DEFAULT NULL,
	P_DEVICE2_FLAG         IN   VARCHAR2	DEFAULT NULL,
	P_DEVICE3_FLAG         IN   VARCHAR2	DEFAULT NULL,
  P_RESOURCE_TERRITORY_ID     IN   NUMBER   DEFAULT NULL       ,
  P_ASSIGNMENT_STATUS_ID     IN   NUMBER                ,
  P_SHIFT_CONSTRUCT_ID      IN   NUMBER   DEFAULT NULL      ,
	X_RETURN_STATUS			    OUT NOCOPY	  VARCHAR2					     ,
	X_MSG_COUNT			      OUT NOCOPY	  NUMBER 						     ,
	X_MSG_DATA			      OUT NOCOPY	  VARCHAR2 					     ,
	X_TASK_ASSIGNMENT_ID		  OUT NOCOPY	  NUMBER						    ,
      p_attribute1       IN    VARCHAR2 DEFAULT null ,
    p_attribute2       IN    VARCHAR2 DEFAULT null ,
    p_attribute3       IN    VARCHAR2 DEFAULT null ,
    p_attribute4       IN    VARCHAR2 DEFAULT null ,
    p_attribute5       IN    VARCHAR2 DEFAULT null ,
    p_attribute6       IN    VARCHAR2 DEFAULT null ,
    p_attribute7       IN    VARCHAR2 DEFAULT null ,
    p_attribute8       IN    VARCHAR2 DEFAULT null ,
    p_attribute9       IN    VARCHAR2 DEFAULT null ,
    p_attribute10       IN    VARCHAR2 DEFAULT null ,
    p_attribute11       IN    VARCHAR2 DEFAULT null ,
    p_attribute12       IN    VARCHAR2 DEFAULT null ,
    p_attribute13       IN    VARCHAR2 DEFAULT null ,
    p_attribute14       IN    VARCHAR2 DEFAULT null ,
    p_attribute15       IN    VARCHAR2 DEFAULT null ,
    p_attribute_category   IN    VARCHAR2 DEFAULT null ,
    P_SHOW_ON_CALENDAR    in    VARCHAR2 DEFAULT jtf_task_utl.g_yes_char,
    P_CATEGORY_ID       in    NUMBER  DEFAULT null  ) ;

/*#
 * Deletes an existing Task Assignment.
 *
 * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_task_assignment_id Unique task assignment identifier of the assignment to be deleted.
 * @rep:paraminfo {@rep:required}
 * @param p_object_version_number Object version number of the current assignment record.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param p_enable_workflow Flag to enable workflow passed as-is to <code>oracle.apps.jtf.cac.task.deleteTaskAssignment</code> business event.
 * @rep:paraminfo {@rep:required}
 * @param p_abort_workflow Flag to abort workflow passed as-is to <code>oracle.apps.jtf.cac.task.deleteTaskAssignment</code> business event.
 * @rep:paraminfo {@rep:required}
 *
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Task Assignment
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.jtf.cac.task.deleteTaskAssignment
 */
 Procedure Delete_Task_Assignment(
  P_API_VERSION		  IN	   NUMBER						      ,
  P_OBJECT_VERSION_NUMBER     IN    NUMBER                 ,
  P_INIT_MSG_LIST		  IN	   VARCHAR2 	DEFAULT FND_API.G_FALSE		,
  P_COMMIT			  IN	   VARCHAR2	DEFAULT FND_API.G_FALSE		,
  P_TASK_ASSIGNMENT_ID	  IN	   NUMBER 						    ,
  X_RETURN_STATUS		  OUT NOCOPY	   VARCHAR2					      ,
  X_MSG_COUNT			  OUT NOCOPY	   NUMBER 						    ,
  X_MSG_DATA			  OUT NOCOPY	   VARCHAR2,
  p_enable_workflow     	  IN    VARCHAR2,
  p_abort_workflow        IN    VARCHAR2
 );


Procedure Delete_Task_Assignment
  (P_API_VERSION			    IN	   NUMBER						      ,
  P_OBJECT_VERSION_NUMBER     IN    NUMBER                 ,
  P_INIT_MSG_LIST			    IN	   VARCHAR2 	DEFAULT FND_API.G_FALSE		,
  P_COMMIT			      IN	   VARCHAR2	DEFAULT FND_API.G_FALSE		,
  P_TASK_ASSIGNMENT_ID		  IN	   NUMBER 						    ,
  X_RETURN_STATUS			    OUT NOCOPY	   VARCHAR2					      ,
  X_MSG_COUNT			      OUT NOCOPY	   NUMBER 						    ,
  X_MSG_DATA			      OUT NOCOPY	   VARCHAR2 					      ) ;

  --Procedure to Lock Task Assignment

-- Removed '#', so that it is not considered by irep. Bug# 5406214

/*
 * Locks a Task assignment.
 *
 * @param p_api_version Standard API version number.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * @param p_task_assignment_id Unique task assignment identifier of the assignment to be locked.
 * @rep:paraminfo {@rep:required}
 * @param p_object_version_number Object version number of the current assignment record.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Lock Task Assignment
 * @rep:compatibility S
 */

  PROCEDURE LOCK_TASK_ASSIGNMENT (
   P_API_VERSION       IN    NUMBER,
   P_INIT_MSG_LIST      IN    VARCHAR2 DEFAULT fnd_api.g_false,
   P_COMMIT         IN    VARCHAR2 DEFAULT fnd_api.g_false,
   P_TASK_ASSIGNMENT_ID   IN    NUMBER,
   P_OBJECT_VERSION_NUMBER  IN    NUMBER ,
   X_RETURN_STATUS      OUT NOCOPY   VARCHAR2,
   X_MSG_DATA        OUT NOCOPY   VARCHAR2,
   X_MSG_COUNT        OUT NOCOPY   NUMBER
  );


--Procedure to Update the Task Assignment
/*#
 * Updates an existing Task Assignment.
 *
 * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_object_version_number Object version number of the current assignment record.
 * @rep:paraminfo {@rep:required}
 * @param p_task_assignment_id Unique task assignment identifier of the assignment to be updated.
 * @rep:paraminfo {@rep:required}
 * @param p_task_id No longer in use.
 * @param p_task_number No longer in use.
 * @param p_task_name No longer in use.
 * @param p_resource_type_code Resource type code for resource reassignment. A task assignment resource is identified with the resource type code and resource identifier therefore this should be used along with <code>p_resource_id</code>.
 * @param p_resource_id Resource identifier for resource reassignment. Should be used along with <code>p_resource_type_code</code>.
 * @param p_resource_name No longer in use.
 * @param p_actual_effort Actual effort exerted by the resource. Should be used along with <code>p_actual_effort_uom</code>.
 * @param p_actual_effort_uom Unit of Measure for the actual effort. Should be used along with <code>p_actual_effort</code>.
 * @param p_schedule_flag Flag to denote if the assignment needs to be scheduled - Not currently used.
 * @param p_alarm_type_code Alarm type code - Reserved for future use.
 * @param p_alarm_contact Alarm contact - Reserved for future use.
 * @param p_sched_travel_distance Scheduled travel distance for this assignment.
 * @param p_sched_travel_duration Scheduled travel duration for this assignment. Should be passed along with <code>p_sched_travel_duration_uom</code>.
 * @param p_sched_travel_duration_uom Unit of measure for scheduled travel duration. Should be passed along with <code>p_sched_travel_duration</code>.
 * @param p_actual_travel_distance Actual distance traveled, logged by the resource.
 * @param p_actual_travel_duration Actual travel duration, logged by the resource. Should be used along with <code>p_actual_travel_duration_uom</code>.
 * @param p_actual_travel_duration_uom Unit of measure for the actual travel duration. Should be used along with <code>p_actual_travel_duration</code>.
 * @param p_actual_start_date Actual start date and time for this assignment.
 * @param p_actual_end_date Actual end date and time for this assignment.
 * @param p_palm_flag Reserved for internal use only.
 * @param p_wince_flag Reserved for internal use only.
 * @param p_laptop_flag Reserved for internal use only.
 * @param p_device1_flag Reserved for internal use only.
 * @param p_device2_flag Reserved for internal use only.
 * @param p_device3_flag Reserved for internal use only.
 * @param p_resource_territory_id Unique territory identifier for the task assignment resource.
 * @param p_assignment_status_id Unique assignment status identifier for this assignment.
 * @param p_shift_construct_id Unique identifier for the shift used to schedule this assignment - Reserved for internal use only.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param p_attribute1 Attribute1 of customer flex fields.
 * @param p_attribute2 Attribute2 of customer flex fields.
 * @param p_attribute3 Attribute3 of customer flex fields.
 * @param p_attribute4 Attribute4 of customer flex fields.
 * @param p_attribute5 Attribute5 of customer flex fields.
 * @param p_attribute6 Attribute6 of customer flex fields.
 * @param p_attribute7 Attribute7 of customer flex fields.
 * @param p_attribute8 Attribute8 of customer flex fields.
 * @param p_attribute9 Attribute9 of customer flex fields.
 * @param p_attribute10 Attribute10 of customer flex fields.
 * @param p_attribute11 Attribute11 of customer flex fields.
 * @param p_attribute12 Attribute12 of customer flex fields.
 * @param p_attribute13 Attribute13 of customer flex fields.
 * @param p_attribute14 Attribute14 of customer flex fields.
 * @param p_attribute15 Attribute15 of customer flex fields.
 * @param p_attribute_category Attribute category for the customer flex fields.
 * @param p_show_on_calendar Flag to show task on resource's calendar. The task will only show up on Resource's calendar if this flag is set to <code>'Y'</code> and there is a set of date with time present on task level.
 * This flag is defaulted to <code>'Y'</code> if not passed.
 * @param p_category_id Reserved unique identifier for personal category defined by resource in their calendar. This is a foreign key to <code>jtf_perz_data.perz_date_id</code>.
 * @param p_enable_workflow Flag to enable workflow; passed as-is to <code>oracle.apps.jtf.cac.task.updateTaskAssignment</code> business event.
 * @rep:paraminfo {@rep:required}
 * @param p_abort_workflow Flag to abort workflow; passed as-is to <code>oracle.apps.jtf.cac.task.updateTaskAssignment</code> business event.
 * @rep:paraminfo {@rep:required}
 * @param p_object_capacity_id Unique identifier for the object capacity for this assignment. This is a foreign key to <code>cac_object_capacity.object_capacity_id</code>.
 * @rep:paraminfo {@rep:required}
 *
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Task Assignment
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.jtf.cac.task.updateTaskAssignment
 */
  PROCEDURE update_task_assignment (
   p_api_version         IN    NUMBER,
   p_object_version_number    IN OUT NOCOPY  NUMBER,
   p_init_msg_list        IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit            IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_task_assignment_id      IN    NUMBER,
	P_TASK_ID			      IN	  NUMBER		DEFAULT fnd_api.g_miss_num,
	P_TASK_NUMBER			    IN	  varchar2		DEFAULT fnd_api.g_miss_char,
  p_task_name          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_type_code      IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_id         IN    NUMBER DEFAULT fnd_api.g_miss_num,
	P_RESOURCE_name         IN	  VARCHAR2	DEFAULT fnd_api.g_miss_char	,
   p_actual_effort        IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_effort_uom      IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_schedule_flag        IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_alarm_type_code       IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_alarm_contact        IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_sched_travel_distance    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_sched_travel_duration    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_sched_travel_duration_uom  IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_actual_travel_distance    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_travel_duration    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_travel_duration_uom  IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_actual_start_date      IN    DATE DEFAULT fnd_api.g_miss_date,
   p_actual_end_date       IN    DATE DEFAULT fnd_api.g_miss_date,
   p_palm_flag          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_wince_flag          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_laptop_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device1_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device2_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device3_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_territory_id    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_assignment_status_id     IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_shift_construct_id      IN    NUMBER DEFAULT fnd_api.g_miss_num,
   x_return_status        OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2,
       p_attribute1       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute2       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute3       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute4       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute5       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute6       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute7       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute8       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute9       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute10       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute11       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute12       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute13       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute14       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute15       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute_category   IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    P_SHOW_ON_CALENDAR    in    VARCHAR2 default jtf_task_utl.g_miss_char,
    P_CATEGORY_ID       in    NUMBER default jtf_task_utl.g_miss_number,
    p_enable_workflow     IN    VARCHAR2,
    p_abort_workflow     IN    VARCHAR2,
    p_object_capacity_id   IN    NUMBER
  ) ;


  PROCEDURE update_task_assignment (
   p_api_version         IN    NUMBER,
   p_object_version_number    IN OUT NOCOPY  NUMBER,
   p_init_msg_list        IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit            IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_task_assignment_id      IN    NUMBER,
	P_TASK_ID			      IN	  NUMBER		DEFAULT fnd_api.g_miss_num,
	P_TASK_NUMBER			    IN	  varchar2		DEFAULT fnd_api.g_miss_char,
  p_task_name          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_type_code      IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_id         IN    NUMBER DEFAULT fnd_api.g_miss_num,
	P_RESOURCE_name         IN	  VARCHAR2	DEFAULT fnd_api.g_miss_char	,
   p_actual_effort        IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_effort_uom      IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_schedule_flag        IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_alarm_type_code       IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_alarm_contact        IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_sched_travel_distance    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_sched_travel_duration    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_sched_travel_duration_uom  IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_actual_travel_distance    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_travel_duration    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_travel_duration_uom  IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_actual_start_date      IN    DATE DEFAULT fnd_api.g_miss_date,
   p_actual_end_date       IN    DATE DEFAULT fnd_api.g_miss_date,
   p_palm_flag          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_wince_flag          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_laptop_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device1_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device2_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device3_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_territory_id    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_assignment_status_id     IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_shift_construct_id      IN    NUMBER DEFAULT fnd_api.g_miss_num,
   x_return_status        OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2,
       p_attribute1       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute2       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute3       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute4       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute5       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute6       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute7       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute8       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute9       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute10       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute11       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute12       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute13       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute14       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute15       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute_category   IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    P_SHOW_ON_CALENDAR    in    VARCHAR2 default jtf_task_utl.g_miss_char,
    P_CATEGORY_ID       in    NUMBER default jtf_task_utl.g_miss_number,
    p_enable_workflow     IN    VARCHAR2,
    p_abort_workflow     IN    VARCHAR2
  ) ;


  PROCEDURE update_task_assignment (
   p_api_version         IN    NUMBER,
   p_object_version_number    IN OUT NOCOPY  NUMBER,
   p_init_msg_list        IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit            IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_task_assignment_id      IN    NUMBER,
	P_TASK_ID			      IN	  NUMBER		DEFAULT fnd_api.g_miss_num,
	P_TASK_NUMBER			    IN	  varchar2		DEFAULT fnd_api.g_miss_char,
  p_task_name          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_type_code      IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_id         IN    NUMBER DEFAULT fnd_api.g_miss_num,
	P_RESOURCE_name         IN	  VARCHAR2	DEFAULT fnd_api.g_miss_char	,
   p_actual_effort        IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_effort_uom      IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_schedule_flag        IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_alarm_type_code       IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_alarm_contact        IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_sched_travel_distance    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_sched_travel_duration    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_sched_travel_duration_uom  IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_actual_travel_distance    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_travel_duration    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_actual_travel_duration_uom  IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_actual_start_date      IN    DATE DEFAULT fnd_api.g_miss_date,
   p_actual_end_date       IN    DATE DEFAULT fnd_api.g_miss_date,
   p_palm_flag          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_wince_flag          IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_laptop_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device1_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device2_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_device3_flag         IN    VARCHAR2 DEFAULT fnd_api.g_miss_char,
   p_resource_territory_id    IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_assignment_status_id     IN    NUMBER DEFAULT fnd_api.g_miss_num,
   p_shift_construct_id      IN    NUMBER DEFAULT fnd_api.g_miss_num,
   x_return_status        OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2,
       p_attribute1       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute2       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute3       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute4       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute5       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute6       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute7       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute8       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute9       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute10       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute11       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute12       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute13       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute14       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute15       IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    p_attribute_category   IN    VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
    P_SHOW_ON_CALENDAR    in    VARCHAR2 default jtf_task_utl.g_miss_char,
    P_CATEGORY_ID       in    NUMBER default jtf_task_utl.g_miss_number
  ) ;

End ;

 

/
