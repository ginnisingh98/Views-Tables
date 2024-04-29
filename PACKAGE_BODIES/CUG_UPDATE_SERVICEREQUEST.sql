--------------------------------------------------------
--  DDL for Package Body CUG_UPDATE_SERVICEREQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_UPDATE_SERVICEREQUEST" AS
/* $Header: CUGUPSRB.pls 115.5 2003/10/15 22:26:43 aneemuch ship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- dejoseph   12-05-02  Replaced reference to install_site_use_id with
--                      install_site_id. ER# 2695480.
-- aneemuch   15-Oct-03 Removed SR update validation code that was getting
--                      called from SR update vertical hook
--
   -- Enter procedure, function bodies as shown below

 PROCEDURE  Prevent_Update_ServiceRequest
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
    l_request_id NUMBER;
    l_type_id NUMBER;
    l_status_id NUMBER;
    l_severity_id NUMBER;
    l_urgency_id NUMBER;
    l_owner_id NUMBER;
    l_owner_group_id NUMBER;
    l_install_site_id NUMBER;

    l_api_name_full CONSTANT VARCHAR2(61)    := 'CS_SERVICEREQUEST_VUHK'||'.'||'Update_ServiceRequest_Pre';

/*
     CURSOR l_CurrentServiceRequest_csr IS
        SELECT * FROM CS_INCIDENTS_ALL_B WHERE
            incident_id = l_request_id;
    l_CurrentServiceRequest_rec l_CurrentServiceRequest_csr%ROWTYPE;


     CURSOR l_IncidentDetails_csr IS
        SELECT * FROM CUG_INCIDNT_ATTR_VALS_VL WHERE incident_id = l_request_id;
     l_IncidentDetails_rec  l_IncidentDetails_csr%ROWTYPE;
*/

      BEGIN
         RETURN;

-- Start of changes by aneemuch, 15-Oct-2003
/*
     BEGIN
        l_request_id := p_request_id;
        l_type_id := p_service_request_rec.type_id;
        l_status_id := p_service_request_rec.status_id;
        l_severity_id :=  p_service_request_rec.severity_id;
        l_urgency_id := p_service_request_rec.urgency_id;
        l_owner_id := p_service_request_rec.owner_id;
        l_owner_group_id := p_service_request_rec.owner_group_id;
        l_install_site_id := p_service_request_rec.install_site_id;


        OPEN l_CurrentServiceRequest_csr;
        FETCH l_CurrentServiceRequest_csr INTO l_CurrentServiceRequest_rec;

        IF (l_CurrentServiceRequest_csr%NOTFOUND) THEN
            	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        IF (l_type_id <> l_CurrentServiceRequest_rec.incident_type_id OR
            l_status_id <> l_CurrentServiceRequest_rec.incident_status_id OR
            l_severity_id <> l_CurrentServiceRequest_rec.incident_severity_id OR
            l_urgency_id <> l_CurrentServiceRequest_rec.incident_urgency_id OR
            l_owner_id <> l_CurrentServiceRequest_rec.incident_owner_id
        )
        THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_install_site_id <> l_CurrentServiceRequest_rec.install_site_id) THEN
            OPEN l_CurrentServiceRequest_csr;
            FETCH l_CurrentServiceRequest_csr INTO l_CurrentServiceRequest_rec;

            IF (l_CurrentServiceRequest_csr%NOTFOUND) THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
          );
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count,
            p_data  => x_msg_data
           );
*/
-- End of changes by aneemuch, 15-Oct-2003

    END  Prevent_Update_ServiceRequest;

END;

/
