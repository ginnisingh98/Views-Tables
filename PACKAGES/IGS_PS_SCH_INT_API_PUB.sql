--------------------------------------------------------
--  DDL for Package IGS_PS_SCH_INT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_SCH_INT_API_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPS80S.pls 120.2 2006/01/17 05:53:04 sommukhe noship $ */
/*#
 * A public API to import data into Scheduling Occurrence Interface Table.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Schedule
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_UNIT
 */
-- Start of Comments
-- API Name               : Insert_Schedule
-- Type                   : Public
-- Pre-reqs               : None
-- Function               : Inserts data into the Schedule Interface Tables
-- Parameters             :
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- IN                       p_transaction_type
--                          This parameter contains the type of transaction
--                          i.e.REQUEST,COMPLETE,UPDATE OR CANCEL
-- IN                       p_cal_type
--                          This contains the Calendar Type of the Unit Section Record
-- IN                       p_sequence_number
--                          This contains the Sequence number of the Calendar Instance of the
--                          Unit Section Record
-- IN                       p_cal_start_dt
--                          This parameter contains the Start Date of the Calendar
--                          Instance of the Unit Section Record
-- IN                       p_cal_end_dt
--                          This parameter contains the End Date of the Calendar
--                          Instance of the Unit Section Record
-- IN                       p_uoo_id
--                          This parameter contains the Unit Section Id of the
--                          Unit Section Record
-- IN                       p_unit_section_occurrence_id
--                          This parameter contains the Unit Section Occurrence ID of the
--                          Unit Section Occurrence record
-- IN                       p_start_time
--                          This parameter contains the Scheduled Start Time
--                          of the Unit Section Occurrence
-- IN                       p_end_time
--                          This parameter contains the Scheduled End Time
--                          of the Unit Section Occurrence
-- IN                       p_building_id
--                          This parameter contains the Scheduled Building id
--                          of the Unit Section Occurrence
-- IN                       p_room_id
--                          This parameter contains the Scheduled Room id
--                          of the Unit Section Occurrence
-- IN                       p_schedule_status
--                          This parameter contains the schedule status of the
--                          Unit Section Occurrence
-- IN                       p_error_text
--                          This parameter contains the error text, in case of Scheduling Error of the
--                          Unit Section Occurrence
-- IN                       p_org_id
--                          This parameter contains the Operating Unit Identifier
-- IN                       p_uso_start_date
--                          This parameter contains unit section occurrence start date
-- IN                       p_uso_end_date
--                          This parameter contains unit section occurrence end date
-- IN                       p_sunday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on sunday
-- IN                       p_monday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on monday
-- IN                       p_tuesday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on tuesday
-- IN                       p_wednesday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on wednesday
-- IN                       p_thursday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on thursday
-- IN                       p_friday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on friday
-- IN                       p_saturday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on saturday
-- OUT NOCOPY               x_return_status
--                          returns the status of the charges API - S if Successful,
--                          E if Expected Error and U if Unexpected Error
-- OUT NOCOPY               x_msg_count
-- OUT NOCOPY               x_msg_data
-- Version                  Current Version 1.0
-- End of Comments

-- Enh bug#2833850
-- Added following parameters
-- p_uso_start_date,p_uso_end_date,p_sunday,p_monday,p_tuesday,p_wednesday,p_thursday,p_friday,p_saturday
/*#
 * A public API to import(insert) data into Scheduling Occurrence Interface Table.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_TRANSACTION_TYPE Transaction type
 * @param p_CAL_TYPE Calendar Type
 * @param p_SEQUENCE_NUMBER Calendar Sequence Number
 * @param p_CAL_START_DT Unit Section Start Date
 * @param p_CAL_END_DT Unit Section End Date
 * @param p_UOO_ID Unit Section Identifier
 * @param p_UNIT_SECTION_OCCURRENCE_ID Unit Section Occurrence Identifier
 * @param p_START_TIME Start Time
 * @param p_END_TIME End Time
 * @param p_BUILDING_ID Building Identifier
 * @param p_ROOM_ID Room Identifier
 * @param p_SCHEDULE_STATUS Schedule Status
 * @param p_ERROR_TEXT Error Text
 * @param p_ORG_ID Operation Unit Identifier
 * @param p_USO_START_DATE Occurrence Start Date
 * @param p_USO_END_DATE Occurrence End Date
 * @param p_SUNDAY Sunday
 * @param p_MONDAY Monday
 * @param p_TUESDAY Tuesday
 * @param p_WEDNESDAY Wednesday
 * @param p_THURSDAY Thursday
 * @param p_FRIDAY Friday
 * @param p_SATURDAY Saturday
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Schedule
 */
  PROCEDURE Insert_schedule(p_api_version                IN               NUMBER,
                            p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
                            p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level           IN               NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status              OUT NOCOPY       VARCHAR2,
                            x_msg_count                  OUT NOCOPY       NUMBER,
                            x_msg_data                   OUT NOCOPY       VARCHAR2,
                            p_transaction_type           IN               VARCHAR2,
                            p_cal_type                   IN               VARCHAR2,
                            p_sequence_number            IN               NUMBER,
                            p_cal_start_dt               IN               DATE,
                            p_cal_end_dt                 IN               DATE,
                            p_uoo_id                     IN               NUMBER,
                            p_unit_section_occurrence_id IN               NUMBER,
                            p_start_time                 IN               DATE,
                            p_end_time                   IN               DATE,
                            p_building_id                IN               NUMBER,
                            p_room_id                    IN               NUMBER,
                            p_schedule_status            IN               VARCHAR2,
                            p_error_text                 IN               VARCHAR2,
                            p_org_id                     IN               NUMBER,
                            p_uso_start_date             IN               DATE DEFAULT NULL,
                            p_uso_end_date               IN               DATE DEFAULT NULL,
                            p_sunday                     IN               VARCHAR2 DEFAULT NULL,
                            p_monday                     IN               VARCHAR2 DEFAULT NULL,
                            p_tuesday                    IN               VARCHAR2 DEFAULT NULL,
                            p_wednesday                  IN               VARCHAR2 DEFAULT NULL,
                            p_thursday                   IN               VARCHAR2 DEFAULT NULL,
                            p_friday                     IN               VARCHAR2 DEFAULT NULL,
                            p_saturday                   IN               VARCHAR2 DEFAULT NULL
                            );

-- Start of Comments
-- API Name               : Update_Sch
-- Type                   : Public
-- Pre-reqs               : None
-- Function               : Updates data in the Schedule Interface Tables
-- Parameters             :
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- IN                       p_start_time
--                          This parameter contains the Scheduled Start Time
--                          of the Unit Section Occurrence
-- IN                       p_end_time
--                          This parameter contains the Scheduled End Time
--                          of the Unit Section Occurrence
-- IN                       p_building_id
--                          This parameter contains the Scheduled Building ID
--                          of the Unit Section Occurrence
-- IN                       p_room_id
--                          This parameter contains the Scheduled Room ID
--                          of the Unit Section Occurrence
-- IN                       p_schedule_status
--                          This parameter contains the schedule status of the
--                          Unit Section Occurrence
-- IN                       p_error_text
--                          This parameter contains the error text, in case of Scheduling Error of the
--                          Unit Section Occurrence
-- IN                       p_org_id
--                          This parameter contains the Operating Unit Identifier
-- IN                       p_uso_start_date
--                          This parameter contains unit section occurrence start date
-- IN                       p_uso_end_date
--                          This parameter contains unit section occurrence end date
-- IN                       p_sunday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on sunday
-- IN                       p_monday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on monday
-- IN                       p_tuesday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on tuesday
-- IN                       p_wednesday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on wednesday
-- IN                       p_thursday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on thursday
-- IN                       p_friday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on friday
-- IN                       p_saturday
--                          This parameter indicates whether a Unit Section Occurrence has been scheduled
--                          on saturday
-- OUT NOCOPY               x_return_status
--                          returns the status of the charges API - S if Successful,
--                          E if Expected Error and U if Unexpected Error
-- OUT NOCOPY               x_msg_count
-- OUT NOCOPY               x_msg_data
-- Version                  Current Version 1.0
-- End of Comments

-- Enh bug#2833850
-- Added following parameters
-- p_uso_start_date,p_uso_end_date,p_sunday,p_monday,p_tuesday,p_wednesday,p_thursday,p_friday,p_saturday
/*#
 * A public API to import(update) data into Scheduling Occurrence Interface Table.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_INT_OCCURS_ID Interface Occurrence Identifier
 * @param p_START_TIME Start Time
 * @param p_END_TIME End Time
 * @param p_BUILDING_ID Building Identifier
 * @param p_ROOM_ID Room Identifier
 * @param p_SCHEDULE_STATUS Schedule Status
 * @param p_ERROR_TEXT Error Text
 * @param p_ORG_ID Operation Unit Identifier
 * @param p_USO_START_DATE Occurrence Start Date
 * @param p_USO_END_DATE Occurrence End Date
 * @param p_SUNDAY Sunday
 * @param p_MONDAY Monday
 * @param p_TUESDAY Tuesday
 * @param p_WEDNESDAY Wednesday
 * @param p_THURSDAY Thursday
 * @param p_FRIDAY Friday
 * @param p_SATURDAY Saturday
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Schedule
 */
  PROCEDURE update_schedule(p_api_version             IN               NUMBER,
                            p_init_msg_list           IN               VARCHAR2 := FND_API.G_FALSE,
                            p_commit                  IN               VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level        IN               NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status           OUT NOCOPY       VARCHAR2,
                            x_msg_count               OUT NOCOPY       NUMBER,
                            x_msg_data                OUT NOCOPY       VARCHAR2,
                            p_int_occurs_id           IN               NUMBER,
                            p_start_time              IN               DATE DEFAULT NULL,
                            p_end_time                IN               DATE DEFAULT NULL,
                            p_building_id             IN               NUMBER DEFAULT NULL,
                            p_room_id                 IN               NUMBER DEFAULT NULL,
                            p_schedule_status         IN               VARCHAR2,
                            p_error_text              IN               VARCHAR2 DEFAULT NULL,
                            p_org_id                  IN               NUMBER,
                            p_uso_start_date          IN               DATE DEFAULT NULL,
                            p_uso_end_date            IN               DATE DEFAULT NULL,
                            p_sunday                  IN               VARCHAR2 DEFAULT NULL,
                            p_monday                  IN               VARCHAR2 DEFAULT NULL,
                            p_tuesday                 IN               VARCHAR2 DEFAULT NULL,
                            p_wednesday               IN               VARCHAR2 DEFAULT NULL,
                            p_thursday                IN               VARCHAR2 DEFAULT NULL,
                            p_friday                  IN               VARCHAR2 DEFAULT NULL,
                            p_saturday                IN               VARCHAR2 DEFAULT NULL
                            );

END IGS_PS_SCH_INT_API_PUB;

 

/
