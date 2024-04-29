--------------------------------------------------------
--  DDL for Package CS_ASSIGN_RESOURCE_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_ASSIGN_RESOURCE_CON_PKG" AUTHID CURRENT_USER as
/* $Header: csvconas.pls 120.2 2006/04/05 01:33:03 brajasek noship $ */

/* Record and Tables used in proc */

-- All the parameters are initialized to null for Bug# 2657149
TYPE LoadBalance_rec_type      IS RECORD
   (
      resource_id                NUMBER       DEFAULT   NULL,
      resource_type              VARCHAR2(30) DEFAULT   NULL,
      support_site_id            NUMBER       DEFAULT   NULL,
      product_skill_level        NUMBER       DEFAULT   NULL,
      platform_skill_level       NUMBER       DEFAULT   NULL,
      pbm_code_skill_level       NUMBER       DEFAULT   NULL,
      category_skill_level       NUMBER       DEFAULT   NULL,
      time_since_last_login      NUMBER       DEFAULT   NULL,
      backlog_sev1		 NUMBER       DEFAULT   NULL,
      backlog_sev2		 NUMBER       DEFAULT   NULL,
      backlog_sev3		 NUMBER       DEFAULT   NULL,
      backlog_sev4		 NUMBER       DEFAULT   NULL,
      time_zone_lag		 NUMBER       DEFAULT   NULL,
      total_load	         NUMBER       DEFAULT   NULL,
      territory_id           NUMBER       DEFAULT NULL
   );

TYPE LoadBalance_tbl_type      IS TABLE OF LoadBalance_rec_type
                                     INDEX BY BINARY_INTEGER;
PROCEDURE MAIN_PROCEDURE
     (X_ERRBUF                  OUT  NOCOPY  VARCHAR2,
      X_RETCODE                 OUT  NOCOPY  NUMBER,
      P_GROUP1_ID               IN  NUMBER,
      P_GROUP2_ID               IN  NUMBER,
      P_GROUP3_ID               IN  NUMBER,
      P_GROUP4_ID               IN  NUMBER,
      P_GROUP5_ID               IN  NUMBER,
      P_INCIDENT_TYPE1_ID       IN  NUMBER,
      P_INCIDENT_TYPE2_ID       IN  NUMBER,
      P_INCIDENT_TYPE3_ID       IN  NUMBER,
      P_INCIDENT_TYPE4_ID       IN  NUMBER,
      P_INCIDENT_TYPE5_ID       IN  NUMBER,
      P_INCIDENT_SEVERITY1_ID   IN  NUMBER,
      P_INCIDENT_SEVERITY2_ID   IN  NUMBER,
      P_INCIDENT_SEVERITY3_ID   IN  NUMBER,
      P_INCIDENT_SEVERITY4_ID   IN  NUMBER,
      P_INCIDENT_SEVERITY5_ID   IN  NUMBER
     );


PROCEDURE Assign_ServiceRequest_Main
   (p_api_name               IN    VARCHAR2,
    p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_incident_id            IN    NUMBER,
    p_object_version_number  IN    NUMBER,
    p_last_updated_by        IN    VARCHAR2,
    p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
    x_owner_group_id         OUT   NOCOPY   NUMBER,
    x_owner_id               OUT   NOCOPY   NUMBER,
    x_owner_type             OUT   NOCOPY   VARCHAR2,
    x_return_status          OUT   NOCOPY   VARCHAR2,
    x_msg_count              OUT   NOCOPY   NUMBER,
    x_msg_data               OUT   NOCOPY   VARCHAR2
   );

PROCEDURE Assign_Resources
   (p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_incident_id            IN    NUMBER,
    p_object_version_number  IN    NUMBER,
    p_last_updated_by        IN    VARCHAR2,
    p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
    x_owner_group_id         OUT   NOCOPY   NUMBER,
    x_owner_type             OUT   NOCOPY   VARCHAR2,
    x_owner_id               OUT   NOCOPY   NUMBER,
    x_return_status          OUT   NOCOPY   VARCHAR2,
    x_msg_count              OUT   NOCOPY   NUMBER,
    x_msg_data               OUT   NOCOPY   VARCHAR2
  );

PROCEDURE Assign_Group
        (p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
         p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
         p_incident_id            IN    NUMBER,
         p_group_type             IN    VARCHAR2,
         p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
         x_return_status          OUT   NOCOPY   VARCHAR2,
         x_resource_id            OUT   NOCOPY   NUMBER,
         x_territory_id           OUT   NOCOPY   NUMBER,
         x_msg_count              OUT   NOCOPY   NUMBER,
         x_msg_data               OUT   NOCOPY   VARCHAR2
        );

 PROCEDURE Assign_Owner
        (p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    	 p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
         p_incident_id            IN    NUMBER,
         p_param_resource_type    IN    VARCHAR2,
         p_group_id               IN    NUMBER,
         p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
         x_return_status          OUT   NOCOPY   VARCHAR2,
         x_resource_id            OUT   NOCOPY   NUMBER,
         x_resource_type          OUT   NOCOPY   VARCHAR2,
         x_territory_id           OUT   NOCOPY   NUMBER,
         x_msg_count              OUT   NOCOPY   NUMBER,
         x_msg_data               OUT   NOCOPY   VARCHAR2
        );

-- Added parameter p_inv_cat_id by pnkalari on 06/11/2002.
PROCEDURE Calculate_Load
        (p_init_msg_list  	  IN    VARCHAR2  := fnd_api.g_false,
         p_incident_id    	  IN    NUMBER,
         p_incident_type_id 	  IN    NUMBER,
         p_incident_severity_id   IN    NUMBER,
         p_inv_item_id    	  IN    NUMBER,
         p_inv_org_id     	  IN    NUMBER,
         p_inv_cat_id             IN    NUMBER,
         p_platform_org_id 	  IN    NUMBER,
         p_platform_id     	  IN    NUMBER,
         p_problem_code    	  IN    VARCHAR2,
         p_contact_timezone_id 	  IN    NUMBER,
         p_res_load_table  	  IN OUT   NOCOPY   CS_ASSIGN_RESOURCE_CON_PKG.LoadBalance_tbl_type,
         x_return_status  	  OUT   NOCOPY   VARCHAR2,
         x_resource_id  	  OUT   NOCOPY   NUMBER,
         x_resource_type  	  OUT   NOCOPY   VARCHAR2,
         x_msg_count    	  OUT   NOCOPY   NUMBER,
         x_msg_data       	  OUT   NOCOPY   VARCHAR2,
	 x_territory_id           OUT  NOCOPY   NUMBER
        );

END CS_ASSIGN_RESOURCE_CON_PKG;
 

/
