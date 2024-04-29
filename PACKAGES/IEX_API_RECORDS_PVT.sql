--------------------------------------------------------
--  DDL for Package IEX_API_RECORDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_API_RECORDS_PVT" AUTHID CURRENT_USER as
/* $Header: iexutirs.pls 120.1 2005/12/21 21:16:28 jypark noship $ */

 TYPE QUERY_PARAMETER_REC_TYPE           IS RECORD
 (
        QUERY_PARAM_ID                NUMBER          := 9.99E125,
        QUERY_ID                        NUMBER        := 9.99E125,
        PARAMETER_NAME                VARCHAR2(60)    := chr(0),
        PARAMETER_TYPE                VARCHAR2(30)    := chr(0),
        PARAMETER_VALUE        VARCHAR2(300)          := chr(0),
        PARAMETER_CONDITION        VARCHAR2(10)       := chr(0),
     PARAMETER_SEQUENCE NUMBER                        := 9.99E125
 );

 TYPE QUERY_PARAMETER_TBL_TYPE           IS TABLE OF QUERY_PARAMETER_REC_TYPE
                                INDEX BY BINARY_INTEGER;

 TYPE task_rsrc_req_rec IS RECORD (
     RESOURCE_TYPE_CODE   jtf_task_rsc_reqs.RESOURCE_TYPE_CODE%type ,
     REQUIRED_UNITS       jtf_task_rsc_reqs.required_units%type ,
     ENABLED_FLAG         jtf_task_rsc_reqs.enabled_flag%type := 'N'
 );

 TYPE task_rsrc_req_tbl IS TABLE OF task_rsrc_req_rec
        INDEX BY BINARY_INTEGER;

 g_miss_task_rsrc_req_tbl    task_rsrc_req_tbl;


 FUNCTION INIT_CASE_CONTACT_REC_TYPE      RETURN IEX_CASE_CONTACTS_PVT.case_contact_Rec_Type ;
 FUNCTION INIT_BANKRUPTCY_REC_TYPE        RETURN IEX_BANKRUPTCIES_PVT.BANKRUPTCY_REC_TYPE ;
 FUNCTION INIT_WRITEOFFS_REC_TYPE         RETURN IEX_WRITEOFFS_PVT.WRITEOFFS_REC_TYPE ;
 FUNCTION INIT_RPS_REC_TYPE               RETURN IEX_REPOSSESSION_PVT.RPS_REC_TYPE ;
 FUNCTION INIT_LTG_REC_TYPE               RETURN IEX_LITIGATION_PVT.LTG_REC_TYPE ;
 FUNCTION INIT_CASE_DEFINITION_REC_TYPE   RETURN IEX_CASE_DEFINITIONS_PVT.CASE_DEFINITION_REC_TYPE ;
 FUNCTION INIT_CASE_OBJECT_REC_TYPE       RETURN IEX_CASE_OBJECTS_PVT.CASE_OBJECT_REC_TYPE ;
 FUNCTION INIT_CAS_REC_TYPE               RETURN IEX_CASES_PVT.CAS_REC_TYPE  ;
 FUNCTION INIT_stry_work_rec
                          RETURN IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type;
 FUNCTION INIT_stry_rec
                          RETURN IEX_strategy_PVT.strategy_Rec_Type;

 FUNCTION INIT_DEL_REC_TYPE               RETURN IEX_DELINQUENCY_PUB.DELINQUENCY_REC_TYPE  ;

 --Begin fix bug #4867510-jypark-12/21/2005-fix for Developer 10g Upgrade

 PROCEDURE Save_Perz_Query
(       p_api_version_number        IN NUMBER,
        p_init_msg_list             IN VARCHAR2         := 'F',
        p_commit                                IN VARCHAR2        := 'F',
        p_application_id                IN NUMBER,
        p_profile_id                IN NUMBER,
        p_profile_name              IN VARCHAR2,
        p_profile_type              IN VARCHAR2,
        p_query_id                        IN NUMBER,
        p_query_name                 IN VARCHAR2,
        p_query_type                        IN VARCHAR2,
        p_query_desc                        IN VARCHAR2,
        p_query_data_source          IN VARCHAR2,

        p_query_param_tbl                IN IEX_API_RECORDS_PVT.QUERY_PARAMETER_TBL_TYPE,
        p_query_order_by_tbl   IN  Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
        p_query_raw_sql_rec    IN  Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,
        x_query_id                           OUT NOCOPY        NUMBER,
        x_return_status                OUT NOCOPY         VARCHAR2,
        x_msg_count                        OUT NOCOPY     NUMBER,
        x_msg_data                        OUT NOCOPY   VARCHAR2

);

PROCEDURE Get_Perz_Query
(       p_api_version_number   IN NUMBER,
        p_init_msg_list        IN VARCHAR2         := Fnd_Api.G_FALSE,

        p_application_id       IN NUMBER,
        p_profile_id           IN NUMBER,
        p_profile_name         IN VARCHAR2,

        p_query_id             IN NUMBER,
        p_query_name           IN VARCHAR2,
        p_query_type           IN VARCHAR2,

        x_query_id             OUT NOCOPY  NUMBER,
        x_query_name           OUT NOCOPY  VARCHAR2,
        x_query_type           OUT NOCOPY  VARCHAR2,
        x_query_desc           OUT NOCOPY  VARCHAR2,
        x_query_data_source    OUT NOCOPY  VARCHAR2,

        x_query_param_tbl      OUT NOCOPY  IEX_API_RECORDS_PVT.QUERY_PARAMETER_TBL_TYPE,
        x_query_order_by_tbl   OUT NOCOPY  Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
        x_query_raw_sql_rec    OUT NOCOPY  Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

        x_return_status        OUT NOCOPY         VARCHAR2,
        x_msg_count            OUT NOCOPY         NUMBER,
        x_msg_data             OUT NOCOPY         VARCHAR2
);
PROCEDURE create_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_name               IN       VARCHAR2,
        p_task_type_name          IN       VARCHAR2 DEFAULT NULL,
        p_task_type_id            IN       NUMBER DEFAULT NULL,
        p_description             IN       VARCHAR2 DEFAULT NULL,
        p_task_status_name        IN       VARCHAR2 DEFAULT NULL,
        p_task_status_id          IN       NUMBER DEFAULT NULL,
        p_task_priority_name      IN       VARCHAR2 DEFAULT NULL,
        p_task_priority_id        IN       NUMBER DEFAULT NULL,
        p_owner_type_name         IN       VARCHAR2 DEFAULT NULL,
        p_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
        p_owner_id                IN       NUMBER DEFAULT NULL,
        p_owner_territory_id      IN       NUMBER DEFAULT NULL,
        p_assigned_by_name        IN       VARCHAR2 DEFAULT NULL,
        p_assigned_by_id          IN       NUMBER DEFAULT NULL,
        p_customer_number         IN       VARCHAR2 DEFAULT NULL,   -- from hz_parties
        p_customer_id             IN       NUMBER DEFAULT NULL,
        p_cust_account_number     IN       VARCHAR2 DEFAULT NULL,
        p_cust_account_id         IN       NUMBER DEFAULT NULL,
        p_address_id              IN       NUMBER DEFAULT NULL,   ---- hz_party_sites
        p_address_number          IN       VARCHAR2 DEFAULT NULL,
        p_planned_start_date      IN       DATE DEFAULT NULL,
        p_planned_end_date        IN       DATE DEFAULT NULL,
        p_scheduled_start_date    IN       DATE DEFAULT NULL,
        p_scheduled_end_date      IN       DATE DEFAULT NULL,
        p_actual_start_date       IN       DATE DEFAULT NULL,
        p_actual_end_date         IN       DATE DEFAULT NULL,
        p_timezone_id             IN       NUMBER DEFAULT NULL,
        p_timezone_name           IN       VARCHAR2 DEFAULT NULL,
        p_source_object_type_code IN       VARCHAR2 DEFAULT NULL,
        p_source_object_id        IN       NUMBER DEFAULT NULL,
        p_source_object_name      IN       VARCHAR2 DEFAULT NULL,
        p_duration                IN       NUMBER DEFAULT NULL,
        p_duration_uom            IN       VARCHAR2 DEFAULT NULL,
        p_planned_effort          IN       NUMBER DEFAULT NULL,
        p_planned_effort_uom      IN       VARCHAR2 DEFAULT NULL,
        p_actual_effort           IN       NUMBER DEFAULT NULL,
        p_actual_effort_uom       IN       VARCHAR2 DEFAULT NULL,
        p_percentage_complete     IN       NUMBER DEFAULT NULL,
        p_reason_code             IN       VARCHAR2 DEFAULT NULL,
        p_private_flag            IN       VARCHAR2 DEFAULT NULL,
        p_publish_flag            IN       VARCHAR2 DEFAULT NULL,
        p_restrict_closure_flag   IN       VARCHAR2 DEFAULT NULL,
        p_multi_booked_flag       IN       VARCHAR2 DEFAULT NULL,
        p_milestone_flag          IN       VARCHAR2 DEFAULT NULL,
        p_holiday_flag            IN       VARCHAR2 DEFAULT NULL,
        p_billable_flag           IN       VARCHAR2 DEFAULT NULL,
        p_bound_mode_code         IN       VARCHAR2 DEFAULT NULL,
        p_soft_bound_flag         IN       VARCHAR2 DEFAULT NULL,
        p_workflow_process_id     IN       NUMBER DEFAULT NULL,
        p_notification_flag       IN       VARCHAR2 DEFAULT NULL,
        p_notification_period     IN       NUMBER DEFAULT NULL,
        p_notification_period_uom IN       VARCHAR2 DEFAULT NULL,
        p_parent_task_number      IN       VARCHAR2 DEFAULT NULL,
        p_parent_task_id          IN       NUMBER DEFAULT NULL,
        p_alarm_start             IN       NUMBER DEFAULT NULL,
        p_alarm_start_uom         IN       VARCHAR2 DEFAULT NULL,
        p_alarm_on                IN       VARCHAR2 DEFAULT NULL,
        p_alarm_count             IN       NUMBER DEFAULT NULL,
        p_alarm_interval          IN       NUMBER DEFAULT NULL,
        p_alarm_interval_uom      IN       VARCHAR2 DEFAULT NULL,
        p_palm_flag               IN       VARCHAR2 DEFAULT NULL,
        p_wince_flag              IN       VARCHAR2 DEFAULT NULL,
        p_laptop_flag             IN       VARCHAR2 DEFAULT NULL,
        p_device1_flag            IN       VARCHAR2 DEFAULT NULL,
        p_device2_flag            IN       VARCHAR2 DEFAULT NULL,
        p_device3_flag            IN       VARCHAR2 DEFAULT NULL,
        p_costs                   IN       NUMBER DEFAULT NULL,
        p_currency_code           IN       VARCHAR2 DEFAULT NULL,
        p_escalation_level        IN       VARCHAR2 DEFAULT NULL,
        p_task_assign_tbl         IN       jtf_tasks_pub.task_assign_tbl DEFAULT jtf_tasks_pub.g_miss_task_assign_tbl,
        p_task_depends_tbl        IN       jtf_tasks_pub.task_depends_tbl DEFAULT jtf_tasks_pub.g_miss_task_depends_tbl,
        p_task_rsrc_req_tbl       IN       IEX_API_RECORDS_PVT.task_rsrc_req_tbl DEFAULT IEX_API_RECORDS_PVT.g_miss_task_rsrc_req_tbl,
        p_task_refer_tbl          IN       jtf_tasks_pub.task_refer_tbl DEFAULT jtf_tasks_pub.g_miss_task_refer_tbl,
        p_task_dates_tbl          IN       jtf_tasks_pub.task_dates_tbl DEFAULT jtf_tasks_pub.g_miss_task_dates_tbl,
        p_task_notes_tbl          IN       jtf_tasks_pub.task_notes_tbl DEFAULT jtf_tasks_pub.g_miss_task_notes_tbl,
        p_task_recur_rec          IN       jtf_tasks_pub.task_recur_rec DEFAULT jtf_tasks_pub.g_miss_task_recur_rec,
        p_task_contacts_tbl       IN       jtf_tasks_pub.task_contacts_tbl DEFAULT jtf_tasks_pub.g_miss_task_contacts_tbl,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_task_id                 OUT NOCOPY      NUMBER,
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
        p_attribute_category      IN       VARCHAR2 DEFAULT null,
        p_date_selected           IN       VARCHAR2 DEFAULT null,
        p_category_id             IN       NUMBER DEFAULT null,
        p_show_on_calendar        IN       VARCHAR2 DEFAULT null,
        p_owner_status_id         IN       NUMBER DEFAULT null,
        p_template_id             IN       NUMBER DEFAULT null,
        p_template_group_id       IN       NUMBER DEFAULT null
    );
 --End fix bug #4867510-jypark-12/21/2005-fix for Developer 10g Upgrade



END IEX_API_RECORDS_PVT;

 

/
