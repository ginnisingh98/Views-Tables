--------------------------------------------------------
--  DDL for Package EAM_PMDEF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PMDEF_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPPMDS.pls 120.8 2007/11/26 12:11:24 rnandyal ship $*/
/*#
 * This package is used for the INSERT / UPDATE of PM Schedules.
 * It defines 2 key procedures create_pm_def, update_pm_def
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Preventive Maintenance Schedule
 * @rep:category BUSINESS_ENTITY EAM_PM_SCHEDULE
 */


Type PM_Scheduling_Rec_Type is RECORD
(
 PM_SCHEDULE_ID                      NUMBER,
 ACTIVITY_ASSOCIATION_ID             NUMBER,
 NON_SCHEDULED_FLAG                     VARCHAR2(1),
 FROM_EFFECTIVE_DATE                      DATE,
 TO_EFFECTIVE_DATE                        DATE,
 RESCHEDULING_POINT                  NUMBER,
 LEAD_TIME                                NUMBER,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30),
 ATTRIBUTE1                               VARCHAR2(150),
 ATTRIBUTE2                               VARCHAR2(150),
 ATTRIBUTE3                               VARCHAR2(150),
 ATTRIBUTE4                               VARCHAR2(150),
 ATTRIBUTE5                               VARCHAR2(150),
 ATTRIBUTE6                               VARCHAR2(150),
 ATTRIBUTE7                               VARCHAR2(150),
 ATTRIBUTE8                               VARCHAR2(150),
 ATTRIBUTE9                               VARCHAR2(150),
 ATTRIBUTE10                              VARCHAR2(150),
 ATTRIBUTE11                              VARCHAR2(150),
 ATTRIBUTE12                              VARCHAR2(150),
 ATTRIBUTE13                              VARCHAR2(150),
 ATTRIBUTE14                              VARCHAR2(150),
 ATTRIBUTE15                              VARCHAR2(150),
 DAY_TOLERANCE                         NUMBER,
 SOURCE_CODE                           VARCHAR2(30),
 SOURCE_LINE                           VARCHAR2(30),
 DEFAULT_IMPLEMENT                        VARCHAR2(1),
 WHICHEVER_FIRST                          VARCHAR2(1),
 INCLUDE_MANUAL                           VARCHAR2(1),
 SET_NAME_ID                              NUMBER,
 SCHEDULING_METHOD_CODE                        NUMBER ,
 TYPE_CODE                NUMBER,
 NEXT_SERVICE_START_DATE            date,
 NEXT_SERVICE_END_DATE                date,
 SOURCE_TMPL_ID                           NUMBER,
 AUTO_INSTANTIATION_FLAG                  VARCHAR2(1),
 NAME                                     VARCHAR2(50),
 TMPL_FLAG                           VARCHAR2(1),
 GENERATE_WO_STATUS                       NUMBER,
 INTERVAL_PER_CYCLE                       NUMBER,
 CURRENT_CYCLE                            NUMBER,
 CURRENT_SEQ                              NUMBER,
 CURRENT_WO_SEQ                           NUMBER,
 BASE_DATE                                DATE,
 BASE_READING                             NUMBER,
 EAM_LAST_CYCLIC_ACT                      NUMBER,
 MAINTENANCE_OBJECT_ID                    NUMBER,
 MAINTENANCE_OBJECT_TYPE                  NUMBER,
 LAST_REVIEWED_DATE              Date,
 Last_reviewed_by              NUMBER,
 GENERATE_NEXT_WORK_ORDER    VARCHAR2(1)
);

TYPE pm_activities_grp_rec_type is RECORD
(
 PM_SCHEDULE_ID                  NUMBER,
 ACTIVITY_ASSOCIATION_ID         NUMBER,
 INTERVAL_MULTIPLE               NUMBER,
 ALLOW_REPEAT_IN_CYCLE           VARCHAR2(1),
 DAY_TOLERANCE                   NUMBER,
 NEXT_SERVICE_START_DATE         DATE,
 NEXT_SERVICE_END_DATE           DATE
);

TYPE pm_activities_grp_tbl_type IS TABLE OF pm_activities_grp_rec_type index by binary_integer;

TYPE pm_rule_rec_type is RECORD
(
 rule_id            number,
 PM_SCHEDULE_ID                  NUMBER,
 RULE_TYPE                       NUMBER,
 DAY_INTERVAL                             NUMBER,
 METER_ID                                 NUMBER,
 RUNTIME_INTERVAL                         NUMBER,
 LAST_SERVICE_READING                     NUMBER,
 EFFECTIVE_READING_FROM                   NUMBER,
 EFFECTIVE_READING_TO                     NUMBER,
 EFFECTIVE_DATE_FROM                      DATE,
 EFFECTIVE_DATE_TO                        DATE,
 LIST_DATE                                DATE,
 LIST_DATE_DESC                           VARCHAR2(50)

);


TYPE pm_rule_tbl_type IS TABLE OF pm_rule_rec_type index by binary_integer;

TYPE pm_date_rec_type is RECORD
(
 index1        number,
 date1        date,
 other        number
);



TYPE pm_date_tbl_type is TABLE of pm_date_rec_type index by binary_integer;

TYPE pm_num_rec_type is RECORD
(
 index1         number,
 num1       number,
 other         number
);


TYPE pm_num_tbl_type is TABLE of pm_num_rec_type index by binary_integer;


/* This method copies an existing PM definition, including the header and all the rules. */

PROCEDURE instantiate_PM_def
(
    p_pm_schedule_id         IN      NUMBER,
    p_activity_assoc_id        IN     NUMBER,
     x_new_pm_schedule_id       OUT NOCOPY     NUMBER,     -- this is the pm_schedule_id of the newly copied pm schedule
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
);


/* This procedure instantiates a set of PM definitions for all asset_association_id's in the activity_assoc_id_tbl table. */

PROCEDURE instantiate_PM_Defs
(
        p_api_version                   IN      NUMBER                          ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_validation_level              IN      NUMBER  :=
                                                FND_API.G_VALID_LEVEL_FULL      ,
        x_return_status                 OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER                          ,
        x_msg_data                      OUT NOCOPY     VARCHAR2                        ,
        p_activity_assoc_id_tbl         IN      EAM_ObjectInstantiation_PUB.Association_Id_Tbl_Type

);



/* This procedure creates a new PM definition, including the header and all rules. */
/*#
 * This procedure is used to insert records in EAM_PM_SCHEDULINGS
 * It is used to create Preventive Maintenance Schedule.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_pm_schedule_rec This is a PL QL record type, which holds the master level data of Preventive Maintenance schedule definition
* @param p_pm_day_interval_rules_tbl This is PL SQL record type, which holds the child level data of Day Interval Rules of a Preventive Maintenance schedule definition
* @param p_pm_runtime_rules_tbl This is PL SQL record type, which holds the child level data of Runtime Interval Rules of a Preventive Maintenance schedule definition
* @param p_pm_list_date_rules_tbl This is PL SQL record type, which holds the child level data of the simple list date based rules of a Preventive Maintenance schedule definition
* @param x_new_pm_schedule_id The unique identifier of newly created Preventive Maintenance Schedule
 * @rep:scope public
 * @rep:displayname Create Preventive Maintenance Schedule
 */


PROCEDURE create_PM_def
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status             OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
        p_pm_schedule_rec        IN      pm_scheduling_rec_type,
    p_pm_activities_tbl        IN      pm_activities_grp_tbl_type,
        p_pm_day_interval_rules_tbl    IN     pm_rule_tbl_type ,
        p_pm_runtime_rules_tbl        IN     pm_rule_tbl_type ,
        p_pm_list_date_rules_tbl    IN     pm_rule_tbl_type ,
     x_new_pm_schedule_id            OUT NOCOPY     NUMBER     -- this is the pm_schedule_id of the newly created pm schedule
);



/*#
 * This procedure is used to update the existing records in EAM_PM_SCHEDULINGS.
 * It is used to update Preventive Maintenance Schedule.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_pm_schedule_rec This is a PL QL record type, which holds the master level data of Preventive Maintenance schedule definition
* @param p_pm_day_interval_rules_tbl This is PL SQL record type, which holds the child level data of Day Interval Rules of a Preventive Maintenance schedule definition
* @param p_pm_runtime_rules_tbl This is PL SQL record type, which holds the child level data of Runtime Interval Rules of a Preventive Maintenance schedule definition
* @param p_pm_list_date_rules_tbl This is PL SQL record type, which holds the child level data of the simple list date based rules of a Preventive Maintenance schedule definition
 * @rep:scope public
 * @rep:displayname Update Preventive Maintenance Schedule
 */

procedure update_pm_def
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status             OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
    --p_pm_schedule_id        IN     NUMBER,
        p_pm_schedule_rec               IN      pm_scheduling_rec_type:=null,
        p_pm_activities_tbl        IN      pm_activities_grp_tbl_type,
        p_pm_day_interval_rules_tbl     IN      pm_rule_tbl_type,
        p_pm_runtime_rules_tbl          IN      pm_rule_tbl_type,
        p_pm_list_date_rules_tbl        IN      pm_rule_tbl_type
);

function validate_pm_header
(
        p_pm_schedule_rec               IN      pm_scheduling_rec_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_day_interval_rule
(
        p_pm_rule_rec                   IN      pm_rule_rec_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_runtime_rule
(
        p_pm_rule_rec                   IN      pm_rule_rec_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_list_date
(
     p_pm_rule_rec            IN      pm_rule_rec_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_day_interval_rules
(
        p_pm_rules_tbl                  IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_runtime_rules
(
        p_pm_rules_tbl                  IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_list_date_rules
(
        p_pm_rules_tbl                  IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;


function validate_pm_header_and_rules
(
        p_pm_schedule_rec               IN      pm_scheduling_rec_type,
        p_pm_day_interval_rules_tbl     IN      pm_rule_tbl_type,
        p_pm_runtime_rules_tbl         IN      pm_rule_tbl_type,
        p_pm_list_date_rules_tbl         IN      pm_rule_tbl_type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;

function validate_pm_activity
(
        p_pm_activity_grp_rec                   IN      pm_activities_grp_rec_type,
    p_pm_runtime_rules_tbl             IN      pm_rule_tbl_type,
    p_pm_schedule_rec            IN    PM_Scheduling_Rec_Type,
    x_reason_failed            OUT NOCOPY     varchar2,
    x_message            OUT NOCOPY     varchar2,
    x_activities                    OUT NOCOPY     varchar2

) return BOOLEAN;

function validate_pm_activity
(
        p_pm_activity_grp_rec                   IN      pm_activities_grp_rec_type,
    p_pm_schedule_rec            IN    PM_Scheduling_Rec_Type,
    x_reason_failed            OUT NOCOPY     varchar2
) return BOOLEAN;

function validate_pm_activities
(
       p_pm_activities_grp_tbl        IN     pm_activities_grp_tbl_type,
       p_pm_runtime_rules_tbl         IN      pm_rule_tbl_type,
       p_pm_schedule_rec               IN      pm_scheduling_rec_type,
       x_reason_failed            OUT NOCOPY varchar2,
       x_message                   OUT NOCOPY varchar2,
       x_activities                OUT NOCOPY varchar2
 ) return BOOLEAN;

procedure sort_table_by_date
(
        p_date_table                    IN      pm_date_tbl_type,
        p_num_rows                      IN      number,
        x_sorted_date_table             OUT NOCOPY     pm_date_tbl_type
);


procedure sort_table_by_number
(
        p_num_table                    IN      pm_num_tbl_type,
        p_num_rows                      IN      number,
        x_sorted_num_table             OUT NOCOPY     pm_num_tbl_type
);


procedure merge_rules
(p_rules_tbl1         IN     pm_rule_tbl_type,
p_rules_tbl2         IN    pm_rule_tbl_type,
x_merged_rules_tbl    OUT NOCOPY    pm_rule_tbl_type);

procedure get_pm_last_activity
(    p_pm_schedule_id        IN     NUMBER,
     p_activity_association_id  OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_msg_count                     OUT NOCOPY     NUMBER ,
     x_msg_data                      OUT NOCOPY     VARCHAR2
 );

/*#
 * This procedure is used to update the eam_last_cyclic_act in the eam_pm_schedulings table. This is called from PM schedule form and Work Order completion
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_pm_schedule_id This is a number parameter, which is the pm schedule id for which the eam_last_cyclic_act should be updated
 * @rep:scope public
 * @rep:displayname Update Preventive Maintenance Schedule
 */

procedure update_pm_last_cyclic_act
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status             OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
    p_pm_schedule_id        IN     NUMBER
 );

/*#
 * This procedure is used to update the last service reading in eam_pm_scheduling_rules table. The last service reading is of the last cyclic activity.
 * This procedure is called from PM Schedule form and from Work Order completion
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_pm_schedule_id This is a number parameter, which is the pm schedule id for which the last service reading should be updated
 * @rep:scope public
 * @rep:displayname Update Preventive Maintenance Schedule
 */

procedure update_pm_last_service_reading
(       p_api_version                   IN      NUMBER ,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE ,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
        x_return_status             OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER ,
        x_msg_data                      OUT NOCOPY     VARCHAR2 ,
    p_pm_schedule_id        IN     NUMBER
 );

END;


/
