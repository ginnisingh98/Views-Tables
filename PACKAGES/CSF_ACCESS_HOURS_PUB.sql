--------------------------------------------------------
--  DDL for Package CSF_ACCESS_HOURS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_ACCESS_HOURS_PUB" AUTHID CURRENT_USER as
/* $Header: CSFPACHS.pls 120.1.12010000.2 2009/09/25 08:12:21 vakulkar ship $ */
-- Start of Comments
--
-- Package name     : CSF_ACCESS_HOURS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
/*TYPE Param_Rec_Type IS RECORD
(

MONDAY_FIRST_START                  DATE          :=      FND_API.G_MISS_DATE,
MONDAY_FIRST_END                    DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_FIRST_START                 DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_FIRST_END                   DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_FIRST_START               DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_FIRST_END                 DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_FIRST_START                DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_FIRST_END                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_FIRST_START                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_FIRST_END                    DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_FIRST_START                DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_FIRST_END                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_FIRST_START                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_FIRST_END                    DATE          :=      FND_API.G_MISS_DATE,
MONDAY_SECOND_START                  DATE          :=      FND_API.G_MISS_DATE,
MONDAY_SECOND_END                    DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_SECOND_START                 DATE          :=      FND_API.G_MISS_DATE,
TUESDAY_SECOND_END                   DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_SECOND_START               DATE          :=      FND_API.G_MISS_DATE,
WEDNESDAY_SECOND_END                 DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_SECOND_START                DATE          :=      FND_API.G_MISS_DATE,
THURSDAY_SECOND_END                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_SECOND_START                  DATE          :=      FND_API.G_MISS_DATE,
FRIDAY_SECOND_END                    DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_SECOND_START                DATE          :=      FND_API.G_MISS_DATE,
SATURDAY_SECOND_END                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_SECOND_START                  DATE          :=      FND_API.G_MISS_DATE,
SUNDAY_SECOND_END                    DATE          :=      FND_API.G_MISS_DATE
);

TYPE PARAM_REC_TBL_TYPE is table of Param_Rec_Type;

*/


-- This procedure is for creating the access hour record for a task .
-- Please note that access hours record can be created only for records that in IN PLANNING or PLANNED status
-- When the task is in PLANNED STATUS,the only possibility is to add the description field
-- Parameter related info

-- param p_api_version the standard API version number eg. 1.0

-- param p_init_msg_list the standard API flag allows API callers to request
-- that the API does the initialization of the message list on their behalf.
-- By default, the message list will not be initialized.

-- All date related parameters such as MONDAY_FIRST_START should be entered as to_date('10:30','hh24:mi:ss')
-- By default a value of NULL would be passed to the date fields

-- After_hours_flag and access_hours_reqd can be set to value Y or N but both cant be Y together
-- When  access_hours_reqd is set as Y ,atleast one time slot has to be entered

-- param p_CREATED_BY need not be entered a default value of -1 is finally inserted in the table
-- param p_CREATION_DATE need not be entered a default value of sysdate is finally inserted in the table
-- param p_LAST_UPDATED_BY need not be entered a default value of -1 is finally inserted in the table
-- param p_LAST_UPDATE_DATE  need not be entered a default value of sysdate is finally inserted in the table
-- param p_LAST_UPDATE_LOGIN  need not be entered a default value of -1 is finally inserted in the table

PROCEDURE CREATE_ACCESS_HOURS(
          x_ACCESS_HOUR_ID  OUT NOCOPY NUMBER,
	  p_API_VERSION NUMBER ,
	  p_init_msg_list varchar2 default NULL,
          p_TASK_ID    NUMBER,
          p_ACCESS_HOUR_REQD VARCHAR2 default null,
          p_AFTER_HOURS_FLAG VARCHAR2 default null,
          p_MONDAY_FIRST_START DATE default TO_DATE(NULL) ,
          p_MONDAY_FIRST_END DATE default  TO_DATE(NULL),
          p_MONDAY_SECOND_START DATE default TO_DATE(NULL) ,
          p_MONDAY_SECOND_END DATE default  TO_DATE(NULL),
          p_TUESDAY_FIRST_START DATE default TO_DATE(NULL),
          p_TUESDAY_FIRST_END DATE default TO_DATE(NULL) ,
          p_TUESDAY_SECOND_START DATE default TO_DATE(NULL),
          p_TUESDAY_SECOND_END DATE default TO_DATE(NULL) ,
          p_WEDNESDAY_FIRST_START DATE default TO_DATE(NULL),
          p_WEDNESDAY_FIRST_END DATE default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_START DATE default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_END DATE default TO_DATE(NULL),
          p_THURSDAY_FIRST_START DATE default TO_DATE(NULL),
          p_THURSDAY_FIRST_END DATE default TO_DATE(NULL),
          p_THURSDAY_SECOND_START DATE default TO_DATE(NULL),
          p_THURSDAY_SECOND_END DATE default TO_DATE(NULL),
          p_FRIDAY_FIRST_START DATE default TO_DATE(NULL),
          p_FRIDAY_FIRST_END DATE default TO_DATE(NULL),
          p_FRIDAY_SECOND_START DATE default TO_DATE(NULL),
          p_FRIDAY_SECOND_END DATE default TO_DATE(NULL),
          p_SATURDAY_FIRST_START DATE default TO_DATE(NULL),
          p_SATURDAY_FIRST_END DATE default TO_DATE(NULL),
          p_SATURDAY_SECOND_START DATE default TO_DATE(NULL),
          p_SATURDAY_SECOND_END DATE default TO_DATE(NULL),
          p_SUNDAY_FIRST_START DATE default TO_DATE(NULL),
          p_SUNDAY_FIRST_END DATE default TO_DATE(NULL),
          p_SUNDAY_SECOND_START DATE default TO_DATE(NULL),
          p_SUNDAY_SECOND_END DATE default TO_DATE(NULL),
          p_DESCRIPTION VARCHAR2 DEFAULT null,
          px_object_version_number in out nocopy number,
          p_CREATED_BY    NUMBER default null,
          p_CREATION_DATE    DATE default null,
          p_LAST_UPDATED_BY    NUMBER default null,
          p_LAST_UPDATE_DATE    DATE default null,
          p_LAST_UPDATE_LOGIN    NUMBER default null,
          x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER


);


-- THis is for updation of already existing access hour related record for a task
-- for a IN PLANNING task all fields are updatable
-- FOr a PLANNED status task,only the access hour and after hours flag can be set from a  value 'Y' to 'N' and the description can be modified

-- param info

-- param p_api_version the standard API version number e.g 1.0

-- param p_init_msg_list the standard API flag allows API callers to request
-- that the API does the initialization of the message list on their behalf.
-- By default, the message list will not be initialized.

-- All date related parameters such as MONDAY_FIRST_START should be entered as to_date('10:30','hh24:mi:ss')

-- After_hours_flag and access_hours_reqd can be set to value Y or N but both cant be Y together
-- When  access_hours_reqd is set as Y ,atleast one time slot has to be entered

-- param p_LAST_UPDATED_BY need not be entered a default value of -1 is finally inserted in the table
-- param p_LAST_UPDATE_DATE  need not be entered a default value of sysdate is finally inserted in the table
-- param p_LAST_UPDATE_LOGIN  need not be entered a default value of -1 is finally inserted in the table

PROCEDURE UPDATE_ACCESS_HOURS(
          p_ACCESS_HOUR_ID   IN  NUMBER,
          p_TASK_ID    NUMBER,
          p_API_VERSION NUMBER,
          p_init_msg_list varchar2 default NULL,
          p_commit        varchar2 default NULL,
          p_ACCESS_HOUR_REQD VARCHAR2 default NULL,
          p_AFTER_HOURS_FLAG VARCHAR2 default   NULL,
          p_MONDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_MONDAY_FIRST_END DATE, --default TO_DATE(NULL),
          p_MONDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_MONDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_TUESDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_TUESDAY_FIRST_END DATE, --default  TO_DATE(NULL) ,
          p_TUESDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_TUESDAY_SECOND_END DATE, --default TO_DATE(NULL) ,
          p_WEDNESDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_WEDNESDAY_FIRST_END DATE, -- default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_WEDNESDAY_SECOND_END DATE,-- default TO_DATE(NULL),
          p_THURSDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_THURSDAY_FIRST_END DATE, --default TO_DATE(NULL),
          p_THURSDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_THURSDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_FRIDAY_FIRST_START DATE,-- default TO_DATE(NULL),
          p_FRIDAY_FIRST_END DATE,-- default TO_DATE(NULL),
          p_FRIDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_FRIDAY_SECOND_END DATE,-- default TO_DATE(NULL),
          p_SATURDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_SATURDAY_FIRST_END DATE, --default TO_DATE(NULL),
          p_SATURDAY_SECOND_START DATE,-- default TO_DATE(NULL),
          p_SATURDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_SUNDAY_FIRST_START DATE, --default TO_DATE(NULL),
          p_SUNDAY_FIRST_END DATE, -- default TO_DATE(NULL),
          p_SUNDAY_SECOND_START DATE, --default TO_DATE(NULL),
          p_SUNDAY_SECOND_END DATE, --default TO_DATE(NULL),
          p_DESCRIPTION VARCHAR2 DEFAULT null,
          px_object_version_number in out nocopy number,
          p_CREATED_BY    NUMBER default null,
          p_CREATION_DATE    DATE default null,
          p_LAST_UPDATED_BY    NUMBER default null,
          p_LAST_UPDATE_DATE    DATE default null,
          p_LAST_UPDATE_LOGIN    NUMBER default null,
          x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER
          );



-- This is for deletion of access hour record for a task.
-- Possible only for In Planning task
-- param p_api_version the standard API version number e.g 1.0
-- param p_init_msg_list the standard API flag allows API callers to request
-- that the API does the initialization of the message list on their behalf.
-- By default, the message list will not be initialized.

PROCEDURE DELETE_ACCESS_HOURS(
    p_TASK_ID    NUMBER,
    p_ACCESS_HOUR_ID  NUMBER,
    p_API_VERSION NUMBER,
    p_init_msg_list varchar2 default null,
    x_return_status            OUT NOCOPY            VARCHAR2,
    x_msg_data                 OUT NOCOPY            VARCHAR2,
    x_msg_count                OUT NOCOPY            NUMBER);

-- Overloaded update_access_hours procedure for use in schedule advice logic

PROCEDURE UPDATE_ACCESS_HOURS(
    p_api_version           number
  , p_init_msg_list         varchar2 default null
  , p_commit                varchar2 default null
  , p_task_id               number
  , p_access_hour_reqd      varchar2
  , x_object_version_number in out nocopy number
  , x_return_status         out nocopy varchar2
  , x_msg_data              out nocopy varchar2
  , x_msg_count             out nocopy number
  );

PROCEDURE ADD_LANGUAGE;


function get_task_status_flag (p_task_id in number) return varchar2;

END CSF_ACCESS_HOURS_PUB;

/
