--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_VUHK" AS
/* $Header: csisrb.pls 115.6 2003/10/15 20:51:57 aneemuch noship $ */


PROCEDURE Create_ServiceRequest_Pre
  ( p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_org_id                 IN    NUMBER   DEFAULT NULL,
    p_request_id             IN    NUMBER   DEFAULT NULL,
    p_request_number         IN    VARCHAR2 DEFAULT NULL,
    p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
    p_notes                  IN    CS_ServiceRequest_PVT.notes_table,
    p_contacts               IN    CS_ServiceRequest_PVT.contacts_table ,
    x_request_id             OUT   NOCOPY NUMBER,
    x_request_number         OUT   NOCOPY VARCHAR2,
    x_interaction_id         OUT   NOCOPY NUMBER,
    x_workflow_process_id    OUT   NOCOPY NUMBER
  ) IS
  BEGIN
    return;
  END;


  PROCEDURE  Create_ServiceRequest_Post
  ( p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_org_id                 IN    NUMBER   DEFAULT NULL,
    p_request_id             IN    NUMBER   DEFAULT NULL,
    p_request_number         IN    VARCHAR2 DEFAULT NULL,
    p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
    p_notes                  IN    CS_ServiceRequest_PVT.notes_table,
    p_contacts               IN    CS_ServiceRequest_PVT.contacts_table ,
    x_request_id             OUT   NOCOPY NUMBER,
    x_request_number         OUT   NOCOPY VARCHAR2,
    x_interaction_id         OUT   NOCOPY NUMBER,
    x_workflow_process_id    OUT   NOCOPY NUMBER
  ) IS
  BEGIN
    return;
  END;



  PROCEDURE  Update_ServiceRequest_Post
  ( p_api_version		    IN	NUMBER,
    p_init_msg_list		    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	    IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		    OUT	NOCOPY VARCHAR2,
    x_msg_count		    OUT	NOCOPY NUMBER,
    x_msg_data			    OUT	NOCOPY VARCHAR2,
    p_request_id		    IN	NUMBER,
    p_object_version_number  IN    NUMBER,
    p_resp_appl_id		    IN	NUMBER   DEFAULT NULL,
    p_resp_id			    IN	NUMBER   DEFAULT NULL,
    p_last_updated_by	    IN	NUMBER,
    p_last_update_login	    IN	NUMBER   DEFAULT NULL,
    p_last_update_date	    IN	DATE,
    p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
    p_update_desc_flex       IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_notes                  IN    CS_ServiceRequest_PVT.notes_table,
    p_contacts               IN    CS_ServiceRequest_PVT.contacts_table,
    p_audit_comments         IN    VARCHAR2 DEFAULT NULL,
    p_called_by_workflow	    IN 	VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id    IN	NUMBER   DEFAULT NULL,
    x_workflow_process_id    OUT   NOCOPY NUMBER,
    x_interaction_id	    OUT	NOCOPY NUMBER
    ) IS
    BEGIN
      return;
    END;


  PROCEDURE  Update_ServiceRequest_Pre
  ( p_api_version		    IN	NUMBER,
    p_init_msg_list		    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	    IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		    OUT	NOCOPY VARCHAR2,
    x_msg_count		    OUT	NOCOPY NUMBER,
    x_msg_data			    OUT	NOCOPY VARCHAR2,
    p_request_id		    IN	NUMBER,
    p_object_version_number  IN    NUMBER,
    p_resp_appl_id		    IN	NUMBER   DEFAULT NULL,
    p_resp_id			    IN	NUMBER   DEFAULT NULL,
    p_last_updated_by	    IN	NUMBER,
    p_last_update_login	    IN	NUMBER   DEFAULT NULL,
    p_last_update_date	    IN	DATE,
    p_service_request_rec    IN    CS_ServiceRequest_PVT.service_request_rec_type,
    p_update_desc_flex       IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_notes                  IN    CS_ServiceRequest_PVT.notes_table,
    p_contacts               IN    CS_ServiceRequest_PVT.contacts_table,
    p_audit_comments         IN    VARCHAR2 DEFAULT NULL,
    p_called_by_workflow	    IN 	VARCHAR2 DEFAULT fnd_api.g_false,
    p_workflow_process_id    IN	NUMBER   DEFAULT NULL,
    x_workflow_process_id    OUT   NOCOPY NUMBER,
    x_interaction_id	    OUT	NOCOPY NUMBER
    )
    IS
           l_return_status              VARCHAR2(1);
       l_msg_data      VARCHAR2(64);
       l_msg_count NUMBER;

       l_workflow_process_id NUMBER;
       l_interaction_id NUMBER;

     l_api_name_full CONSTANT VARCHAR2(61)    := 'CS_SERVICEREQUEST_VUHK'||'.'||'Update_ServiceRequest_Pre';
BEGIN
return;

-- Start of change by aneemuch, 15-Oct-2003
-- Removed vertical hook validation that use to prevent updation of CIC SR.
/*
      BEGIN
  CUG_PREVENT_SR_UPDATE_PKG.Update_ServiceRequest_Prevent
  ( p_api_version=>p_api_version,
    p_init_msg_list=>p_init_msg_list,
    p_commit=>p_commit,
    p_validation_level=>p_validation_level,
    x_return_status	=>l_return_status,
    x_msg_count=>l_msg_count,
    x_msg_data=>l_msg_data,
    p_request_id=>p_request_id,
    p_object_version_number=>p_object_version_number,
    p_resp_appl_id=>p_resp_appl_id,
    p_resp_id=>p_resp_id,
    p_last_updated_by=>p_last_updated_by,
    p_last_update_login	=>p_last_update_login,
    p_last_update_date=>p_last_update_date,
    p_service_request_rec=>p_service_request_rec,
    p_update_desc_flex=>p_update_desc_flex,
    p_notes=>p_notes,
    p_contacts =>p_contacts,
    p_audit_comments=>p_audit_comments,
    p_called_by_workflow=>p_called_by_workflow,
    p_workflow_process_id=>p_workflow_process_id,
    x_workflow_process_id=>l_workflow_process_id,
    x_interaction_id=>l_interaction_id
    );


    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;


    EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;

        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;

        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
           );

*/
-- End of changes by aneemuch, 15-Oct-2003

 END Update_ServiceRequest_pre;


END CS_SERVICEREQUEST_VUHK;

/
