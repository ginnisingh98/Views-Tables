--------------------------------------------------------
--  DDL for Package CS_AUTOGEN_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_AUTOGEN_TASK_PVT" AUTHID CURRENT_USER AS
/* $Header: csvatsks.pls 120.0.12010000.2 2009/05/05 10:19:26 vpremach ship $*/


TYPE TASK_TEMPLATE_SEARCH_REC_TYPE IS RECORD
(
 incident_type_id     NUMBER,
 organization_id      NUMBER,
 inventory_item_id    NUMBER,
 category_id          NUMBER,
 problem_code         VARCHAR2(50));

TYPE Auto_Task_Gen_Rec_Type IS RECORD
(
 -- Commented out the first three attributes -- anmukher -- 08/21/03
 -- task_template_group_id       NUMBER,
 -- location_id                  NUMBER,
 -- party_site_id                NUMBER,
 auto_task_gen_attempted      BOOLEAN,
 field_service_task_created   BOOLEAN );

TYPE task_template_group_tbl_type IS TABLE OF
     JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info
     INDEX BY BINARY_INTEGER;

-- 12.1.2 SR Task Enhancement project
-- Calculate the Planned End date based on the profile.
PROCEDURE Default_Planned_End_Date(p_respond_by IN DATE,
				   p_resolve_by IN DATE,
				   p_uom_code IN varchar2 DEFAULT fnd_api.g_miss_char,
				   p_planned_effort IN Number DEFAULT fnd_api.g_miss_num,
				   x_planned_end_date OUT NOCOPY DATE);


PROCEDURE  Auto_Generate_Tasks
(
 p_api_version                    IN NUMBER,
 p_init_msg_list                  IN VARCHAR2  DEFAULT fnd_api.g_false,
 p_commit                         IN VARCHAR2  DEFAULT fnd_api.g_false,
 p_validation_level               IN NUMBER    DEFAULT fnd_api.g_valid_level_full,
 p_incident_id                    IN NUMBER ,
 p_service_request_rec            IN Cs_ServiceRequest_PVT.Service_Request_rec_type,
 p_task_template_group_owner      IN NUMBER,
 p_task_tmpl_group_owner_type     IN VARCHAR2,
 p_task_template_group_rec        IN JTF_TASK_INST_TEMPLATES_PUB.task_template_group_info,
 p_task_template_table            IN JTF_TASK_INST_TEMPLATES_PUB.task_template_info_tbl,
 x_auto_task_gen_rec              OUT NOCOPY  Cs_AutoGen_Task_PVT.auto_task_gen_rec_type,
 x_return_status                  OUT NOCOPY  VARCHAR2,
 x_msg_count                      OUT NOCOPY  NUMBER,
 x_msg_data                       OUT NOCOPY  VARCHAR2 );


PROCEDURE  Get_Task_Template_Group
(
 p_api_version              IN NUMBER,
 p_init_msg_list            IN VARCHAR2 DEFAULT fnd_api.g_false,
 p_commit                   IN VARCHAR2 DEFAULT fnd_api.g_false,
 p_validation_level         IN NUMBER   DEFAULT fnd_api.g_valid_level_full,
 p_task_template_search_rec IN Cs_AutoGen_Task_PVT.TASK_TEMPLATE_SEARCH_REC_TYPE,
 x_task_template_group_tbl  OUT  NOCOPY Cs_AutoGen_Task_PVT.TASK_TEMPLATE_GROUP_TBL_TYPE,
 x_return_status            OUT  NOCOPY VARCHAR2,
 x_msg_count                OUT  NOCOPY NUMBER,
 x_msg_data                 OUT  NOCOPY VARCHAR2 );

FUNCTION Get_Task_Template_Status
 (
  p_start_date     IN DATE ,
  p_end_date       IN DATE ) RETURN VARCHAR2 ;

END CS_AutoGen_Task_PVT;

/
