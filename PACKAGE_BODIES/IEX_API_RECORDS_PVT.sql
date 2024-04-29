--------------------------------------------------------
--  DDL for Package Body IEX_API_RECORDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_API_RECORDS_PVT" as
/* $Header: iexutirb.pls 120.2 2006/04/07 09:52:02 lkkumar noship $ */
-- *****************************************************
FUNCTION  INIT_CASE_CONTACT_REC_TYPE
          RETURN  IEX_CASE_CONTACTS_PVT.CASE_CONTACT_REC_TYPE
IS
    l_return_rec IEX_CASE_CONTACTS_PVT.case_contact_Rec_Type ;
BEGIN
    RETURN   l_return_rec;
END INIT_CASE_CONTACT_REC_TYPE ;
-- *****************************************************

FUNCTION  INIT_WRITEOFFS_REC_TYPE
           RETURN  IEX_WRITEOFFS_PVT.WRITEOFFS_REC_TYPE
IS
    l_return_rec IEX_WRITEOFFS_PVT.WRITEOFFS_REC_TYPE;
BEGIN
    RETURN   l_return_rec;
END INIT_WRITEOFFS_REC_TYPE ;

-- *****************************************************

FUNCTION  INIT_LTG_REC_TYPE
   RETURN  IEX_LITIGATION_PVT.LTG_REC_TYPE
		 IS
		 l_return_rec IEX_LITIGATION_PVT.LTG_REC_TYPE;
  BEGIN
    RETURN   l_return_rec;
END INIT_LTG_REC_TYPE ;

-- *****************************************************

FUNCTION  INIT_RPS_REC_TYPE
		 RETURN  IEX_REPOSSESSION_PVT.RPS_REC_TYPE
IS
    l_return_rec IEX_REPOSSESSION_PVT.RPS_REC_TYPE;
BEGIN
    RETURN   l_return_rec;
END INIT_RPS_REC_TYPE ;
-- *****************************************************

FUNCTION  INIT_BANKRUPTCY_REC_TYPE
           RETURN  IEX_BANKRUPTCIES_PVT.BANKRUPTCY_REC_TYPE
IS
    l_return_rec IEX_BANKRUPTCIES_PVT.BANKRUPTCY_REC_TYPE;
BEGIN
    RETURN   l_return_rec;
END INIT_BANKRUPTCY_REC_TYPE ;
-- *****************************************************
FUNCTION  INIT_CAS_REC_TYPE
           RETURN  IEX_CASES_PVT.CAS_REC_TYPE
IS
    l_return_rec IEX_CASES_PVT.CAS_REC_TYPE;
BEGIN
    RETURN   l_return_rec;
END INIT_CAS_REC_TYPE  ;
-- *****************************************************
FUNCTION  INIT_CASE_OBJECT_REC_TYPE
           RETURN  IEX_CASE_OBJECTS_PVT.CASE_OBJECT_REC_TYPE
IS
    l_return_rec IEX_CASE_OBJECTS_PVT.CASE_OBJECT_REC_TYPE ;
BEGIN
    RETURN   l_return_rec;
END INIT_CASE_OBJECT_REC_TYPE ;
-- *****************************************************
FUNCTION  INIT_CASE_DEFINITION_REC_TYPE
           RETURN  IEX_CASE_DEFINITIONS_PVT.CASE_DEFINITION_REC_TYPE
IS
    l_return_rec IEX_CASE_DEFINITIONS_PVT.CASE_DEFINITION_REC_TYPE ;
BEGIN
    RETURN   l_return_rec;
END INIT_CASE_DEFINITION_REC_TYPE ;
-- *****************************************************

FUNCTION INIT_stry_work_rec
 RETURN IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type IS
	l_return_rec IEX_strategy_work_items_PVT.strategy_work_item_Rec_Type ;
	BEGIN
	    RETURN   l_return_rec;
 END INIT_stry_work_rec;

-- *****************************************************

FUNCTION INIT_stry_rec
 RETURN IEX_strategy_PVT.strategy_Rec_Type IS
	l_return_rec IEX_strategy_PVT.strategy_Rec_Type ;
	BEGIN
	    RETURN   l_return_rec;
 END INIT_stry_rec;

-- *****************************************************

 FUNCTION INIT_DEL_REC_TYPE
   RETURN IEX_DELINQUENCY_PUB.DELINQUENCY_REC_TYPE IS
    l_return_rec IEX_DELINQUENCY_PUB.DELINQUENCY_REC_TYPE ;
 BEGIN
    return l_return_rec;
 END INIT_DEL_REC_TYPE;

-- *****************************************************
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

) IS
   l_profile_attrib_tbl JTF_PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE;
   l_query_param_tbl        JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_TBL_TYPE;

BEGIN
  FOR i IN p_query_param_tbl.FIRST..p_query_param_tbl.LAST LOOP

      l_query_param_tbl(i).parameter_name      := p_query_param_tbl(i).parameter_name;
      l_query_param_tbl(i).parameter_type      := p_query_param_tbl(i).parameter_type;
      l_query_param_tbl(i).parameter_value     := p_query_param_tbl(i).parameter_value;
      l_query_param_tbl(i).parameter_sequence  := p_query_param_tbl(i).parameter_sequence;

  END LOOP;

  JTF_PERZ_QUERY_PUB.Save_Perz_Query
  (       p_api_version_number    => p_api_version_number,
          p_init_msg_list         => p_init_msg_list,
          p_commit                =>  p_commit,
	      p_application_id        =>  p_application_id,
	      p_profile_id        	=>  p_profile_id,
	      p_profile_name      	=>  p_profile_name,
	      p_profile_type      	=>  p_profile_type,
	      p_Profile_Attrib    	=>  l_profile_attrib_tbl,
	      p_query_id              =>  p_query_id,
          p_query_name            =>  p_query_name,
	      p_query_type            =>  p_query_type,
          p_query_desc            =>  p_query_desc,
	      p_query_data_source     =>  p_query_data_source,
	      p_query_param_tbl       =>  l_query_param_tbl,
          p_query_order_by_tbl    =>   p_query_order_by_tbl,
	      p_query_raw_sql_rec      =>  p_query_raw_sql_rec,
		  x_query_id              =>   x_query_id,
	      x_return_status         =>   x_return_status,
          x_msg_count             =>   x_msg_count,
	      x_msg_data              =>   x_msg_data
	);
END SAVE_PERZ_QUERY;

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
) IS
  l_query_param_tbl      Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE;
BEGIN
	-- select all the parameters for the given query_id from jtf_perz_query_param into pl/sql table
    JTF_PERZ_QUERY_PVT.Get_Perz_Query
   	(
    	  p_api_version_number  => p_api_version_number,
    	  p_init_msg_list       => p_init_msg_list,
      p_application_id      => p_application_id,
      p_profile_id          => p_profile_id,
      p_profile_name        => p_profile_name,
      p_query_id            => p_query_id,
      p_query_name          => p_query_name,
      p_query_type          => p_query_type,
      x_query_id            => x_query_id,
      x_query_name          => x_query_name,
      x_query_type          => x_query_type,
      x_query_desc          => x_query_desc,
      x_query_data_source   => x_query_data_source,
      x_query_param_tbl     => l_query_param_tbl,
      x_query_order_by_tbl  => x_query_order_by_tbl,
      x_query_raw_sql_rec   => x_query_raw_sql_rec,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
   );

  FOR i IN l_query_param_tbl.FIRST..l_query_param_tbl.LAST LOOP

      x_query_param_tbl(i).parameter_name      := l_query_param_tbl(i).parameter_name;
      x_query_param_tbl(i).parameter_type      := l_query_param_tbl(i).parameter_type;
      x_query_param_tbl(i).parameter_value     := l_query_param_tbl(i).parameter_value;
      x_query_param_tbl(i).parameter_sequence  := l_query_param_tbl(i).parameter_sequence;

  END LOOP;

END GET_PERZ_QUERY;

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
    )
IS
  l_task_rsrc_req_tbl   JTF_TASKS_PUB.TASK_RSRC_REQ_TBL;

BEGIN

 --Bug5122929. Fix by LKKUMAR on 07-Apr-2006. Start.
 IF ( p_task_rsrc_req_tbl.COUNT > 0 ) THEN
  FOR i IN p_task_rsrc_req_tbl.FIRST..p_task_rsrc_req_tbl.LAST LOOP
     l_task_rsrc_req_tbl(i).RESOURCE_TYPE_CODE := p_task_rsrc_req_tbl(i).RESOURCE_TYPE_CODE;
     l_task_rsrc_req_tbl(i).REQUIRED_UNITS := p_task_rsrc_req_tbl(i).REQUIRED_UNITS;
     l_task_rsrc_req_tbl(i).ENABLED_FLAG := p_task_rsrc_req_tbl(i).ENABLED_FLAG;
  END LOOP;
 END IF;
 --Bug5122929. Fix by LKKUMAR on 07-Apr-2006. End.

  JTF_TASKS_PUB.CREATE_TASK(
	P_API_VERSION 			=> P_API_VERSION,
	P_INIT_MSG_LIST		=> P_INIT_MSG_LIST,
	P_COMMIT				=> P_COMMIT,
	P_TASK_ID 			=> P_TASK_ID,
	P_TASK_NAME			=> P_TASK_NAME,
	P_TASK_TYPE_NAME		=> P_TASK_TYPE_NAME,
	P_TASK_TYPE_ID 		=> P_TASK_TYPE_ID,
	P_DESCRIPTION           	=> P_DESCRIPTION,
	P_TASK_STATUS_NAME		=> P_TASK_STATUS_NAME,
	P_TASK_STATUS_ID        	=> P_TASK_STATUS_ID,
	P_TASK_PRIORITY_NAME	=> P_TASK_PRIORITY_NAME,
	P_TASK_PRIORITY_ID      	=> P_TASK_PRIORITY_ID,
	p_owner_type_name		=> p_owner_type_name,
	P_OWNER_TYPE_CODE       	=> P_OWNER_TYPE_CODE,
	P_OWNER_ID              	=> P_OWNER_ID,
	P_OWNER_TERRITORY_ID    	=> P_OWNER_TERRITORY_ID,
	p_assigned_by_name		=> p_assigned_by_name,
	P_ASSIGNED_BY_ID        	=> P_ASSIGNED_BY_ID,
	p_customer_number 		=> p_customer_number,
	P_CUSTOMER_ID           	=> P_CUSTOMER_ID,
	p_cust_account_number	=> p_cust_account_number,
	P_CUST_ACCOUNT_ID       	=> P_CUST_ACCOUNT_ID,
	P_ADDRESS_ID            	=> P_ADDRESS_ID,
	p_address_number		=> P_ADDRESS_NUMBER,
	P_PLANNED_START_DATE     => P_PLANNED_START_DATE,
	P_PLANNED_END_DATE      	=> P_PLANNED_END_DATE,
	P_SCHEDULED_START_DATE  	=> P_SCHEDULED_START_DATE,
	P_SCHEDULED_END_DATE    	=> P_SCHEDULED_END_DATE,
	P_ACTUAL_START_DATE     	=> P_ACTUAL_START_DATE,
	P_ACTUAL_END_DATE       	=> P_ACTUAL_END_DATE,
	P_TIMEZONE_ID           	=> P_TIMEZONE_ID,
	p_timezone_name		=> P_TIMEZONE_NAME,
	P_SOURCE_OBJECT_TYPE_CODE      	=> P_SOURCE_OBJECT_TYPE_CODE,
	P_SOURCE_OBJECT_ID             	=> P_SOURCE_OBJECT_ID,
	P_SOURCE_OBJECT_NAME           	=> P_SOURCE_OBJECT_NAME,
	P_DURATION                     	=> P_DURATION,
	P_DURATION_UOM                 	=> P_DURATION_UOM,
	P_PLANNED_EFFORT               	=> P_PLANNED_EFFORT,
	P_PLANNED_EFFORT_UOM           	=> P_PLANNED_EFFORT_UOM,
	P_ACTUAL_EFFORT                	=> P_ACTUAL_EFFORT,
	P_ACTUAL_EFFORT_UOM            	=> P_ACTUAL_EFFORT_UOM,
	P_PERCENTAGE_COMPLETE          	=> P_PERCENTAGE_COMPLETE,
	P_REASON_CODE                  	=> P_REASON_CODE,
	P_PRIVATE_FLAG                 	=> P_PRIVATE_FLAG,
	P_PUBLISH_FLAG                 	=> P_PUBLISH_FLAG,
	P_RESTRICT_CLOSURE_FLAG        	=> P_RESTRICT_CLOSURE_FLAG,
	P_MULTI_BOOKED_FLAG            	=> P_MULTI_BOOKED_FLAG,
	P_MILESTONE_FLAG               	=> P_MILESTONE_FLAG,
	P_HOLIDAY_FLAG                 	=> P_HOLIDAY_FLAG,
	P_BILLABLE_FLAG                	=> P_BILLABLE_FLAG,
	P_BOUND_MODE_CODE              	=> P_BOUND_MODE_CODE,
	P_SOFT_BOUND_FLAG              	=> P_SOFT_BOUND_FLAG,
	P_WORKFLOW_PROCESS_ID          	=> P_WORKFLOW_PROCESS_ID,
	P_NOTIFICATION_FLAG            	=> P_NOTIFICATION_FLAG,
	P_NOTIFICATION_PERIOD          	=> P_NOTIFICATION_PERIOD,
	P_NOTIFICATION_PERIOD_UOM      	=> P_NOTIFICATION_PERIOD_UOM,
	p_parent_task_number			=> P_parent_task_number,
	P_PARENT_TASK_ID               	=> P_PARENT_TASK_ID,
	P_ALARM_START                  	=> P_ALARM_START,
	P_ALARM_START_UOM              	=> P_ALARM_START_UOM,
	P_ALARM_ON                     	=> P_ALARM_ON,
	P_ALARM_COUNT                  	=> P_ALARM_COUNT,
	P_ALARM_INTERVAL               	=> P_ALARM_INTERVAL,
	P_ALARM_INTERVAL_UOM           	=> P_ALARM_INTERVAL_UOM,
	P_PALM_FLAG                    	=> P_PALM_FLAG,
	P_WINCE_FLAG                   	=> P_WINCE_FLAG,
	P_LAPTOP_FLAG                  	=> P_LAPTOP_FLAG,
	P_DEVICE1_FLAG                 	=> P_DEVICE1_FLAG,
	P_DEVICE2_FLAG                 	=> P_DEVICE2_FLAG,
	P_DEVICE3_FLAG                 	=> P_DEVICE3_FLAG,
	P_COSTS                        	=> P_COSTS,
	P_CURRENCY_CODE                	=> P_CURRENCY_CODE,
	P_ESCALATION_LEVEL             	=> P_ESCALATION_LEVEL,
	p_task_assign_tbl		=> p_task_assign_tbl,
	p_task_depends_tbl		=> p_task_depends_tbl,
	p_task_rsrc_req_tbl		=> l_task_rsrc_req_tbl,
	p_task_refer_tbl		=> p_task_refer_tbl,
	p_task_dates_tbl		=> p_task_dates_tbl,
	p_task_notes_tbl		=> p_task_notes_tbl,
	p_task_recur_rec		=> p_task_recur_rec,
	p_task_contacts_tbl		=> p_task_contacts_tbl,
	x_return_status		=> x_return_status,
	x_msg_count			=> x_msg_count,
	x_msg_data			=> x_msg_data,
	x_task_id				=> x_task_id,
	P_ATTRIBUTE1            	=> P_ATTRIBUTE1,
	P_ATTRIBUTE2            	=> P_ATTRIBUTE2,
	P_ATTRIBUTE3            	=> P_ATTRIBUTE3,
	P_ATTRIBUTE4 			=> P_ATTRIBUTE4,
	P_ATTRIBUTE5 			=> P_ATTRIBUTE5,
	P_ATTRIBUTE6 			=> P_ATTRIBUTE6,
	P_ATTRIBUTE7 			=> P_ATTRIBUTE7,
	P_ATTRIBUTE8 			=> P_ATTRIBUTE8,
	P_ATTRIBUTE9 			=> P_ATTRIBUTE9,
	P_ATTRIBUTE10 			=> P_ATTRIBUTE10,
	P_ATTRIBUTE11 			=> P_ATTRIBUTE11,
	P_ATTRIBUTE12 			=> P_ATTRIBUTE12,
	P_ATTRIBUTE13 			=> P_ATTRIBUTE13,
	P_ATTRIBUTE14 			=> P_ATTRIBUTE14,
	P_ATTRIBUTE15 			=> P_ATTRIBUTE15,
	P_ATTRIBUTE_CATEGORY 	=> P_ATTRIBUTE_CATEGORY
	);



END CREATE_TASK;
--End fix bug #4867510-jypark-12/21/2005-fix for Developer 10g Upgrade

END IEX_API_RECORDS_PVT;

/
