--------------------------------------------------------
--  DDL for Package Body CUG_PREVENT_SR_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_PREVENT_SR_UPDATE_PKG" AS
/* $Header: CUGPREUB.pls 115.3.1159.2 2003/06/30 06:47:54 vmuruges ship $ */
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
--
-- vmuruges   30-06-03  Bug# 2802879 Ignored the condition when no workflow
--                      is associated with the Service Request.

   -- Enter procedure, function bodies as shown below

  PROCEDURE  Update_ServiceRequest_Prevent
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

    l_request_id NUMBER;
    l_type_id NUMBER;
    l_status_id NUMBER;
    l_severity_id NUMBER;
    l_urgency_id NUMBER;
    l_owner_id NUMBER;
    l_owner_group_id NUMBER;
    l_install_site_id NUMBER;

-- Begin of changes by ANEEMUCH date 20-May-2002
    l_incident_location_id  NUMBER;
    l_incident_address      VARCHAR2(960);
    l_incident_city         VARCHAR2(60);
    l_incident_state        VARCHAR2(60);
    l_incident_county       VARCHAR2(60);
    l_incident_province     VARCHAR2(60);
    l_incident_postal_code  VARCHAR2(60);
    l_incident_country      VARCHAR2(60);
-- End of changes by ANEEMUCH date 20-May-2002

    l_request_number VARCHAR2(64);
    l_workflow_process_id NUMBER;
    l_request_number_key VARCHAR2(100);
    l_end_date DATE;

    l_api_name_full CONSTANT VARCHAR2(61)    := 'CS_SERVICEREQUEST_VUHK'||'.'||'Update_ServiceRequest_Pre';

     CURSOR l_CurrentServiceRequest_csr IS
        SELECT * FROM CS_INCIDENTS_ALL_B WHERE
            incident_id = l_request_id;
    l_CurrentServiceRequest_rec l_CurrentServiceRequest_csr%ROWTYPE;


     CURSOR l_IncidentDetails_csr IS
        SELECT * FROM CUG_INCIDNT_ATTR_VALS_VL WHERE incident_id = l_request_id;
     l_IncidentDetails_rec  l_IncidentDetails_csr%ROWTYPE;


    CURSOR l_WFDetails_csr IS
        SELECT end_date from WF_ITEMS where
        item_type = 'SERVEREQ' AND
        root_activity = 'CUG_GENERIC_WORKFLOW' AND
        item_key = l_request_number_key;
    l_WFDetails_rec l_WFDetails_csr%ROWTYPE;

    CURSOR l_WFActivityDetails_csr IS
        SELECT activity_end_date from
            wf_item_activity_statuses_v where
            item_key = l_request_number_key AND
            activity_name = 'CLOSE_REQUEST';
    l_WFActivityDetails_rec l_WFActivityDetails_csr%ROWTYPE;

      BEGIN


        l_request_id := p_request_id;
        l_type_id := p_service_request_rec.type_id;
        l_status_id := p_service_request_rec.status_id;
        l_severity_id :=  p_service_request_rec.severity_id;
        l_urgency_id := p_service_request_rec.urgency_id;
        l_owner_id := p_service_request_rec.owner_id;
        l_owner_group_id := p_service_request_rec.owner_group_id;
        l_install_site_id := p_service_request_rec.install_site_id;

-- Begin changes by ANEEMUCH date 20-May-2002
-- added columns to check chgs to incident address
        l_incident_location_id := p_service_request_rec.incident_location_id;
        l_incident_address     := p_service_request_rec.incident_address;
        l_incident_city        := p_service_request_rec.incident_city;
        l_incident_state       := p_service_request_rec.incident_state;
        l_incident_county      := p_service_request_rec.incident_county;
        l_incident_province    := p_service_request_rec.incident_province;
        l_incident_postal_code := p_service_request_rec.incident_postal_code;
        l_incident_country     := p_service_request_rec.incident_country;
-- End of changes by ANEEMUCH date 20-May-2002


        OPEN l_CurrentServiceRequest_csr;
        FETCH l_CurrentServiceRequest_csr INTO l_CurrentServiceRequest_rec;


        IF (l_CurrentServiceRequest_csr%NOTFOUND) THEN
            	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        CLOSE l_CurrentServiceRequest_csr;

     l_request_number := l_CurrentServiceRequest_rec.incident_number;
     l_workflow_process_id := l_CurrentServiceRequest_rec.workflow_process_id;
     l_request_number_key := l_request_number||'-'||l_workflow_process_id;

      OPEN l_WFDetails_csr;
      FETCH l_WFDetails_csr into l_WFDetails_rec;
      IF (l_WFDetails_csr%NOTFOUND) THEN
       -- start for bug 2802879 ignoring the situation when no workflow is associated
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      return;
      --end for bug 2802879
      ELSE
              l_end_date :=   l_WFDetails_rec.end_date;
              IF(l_end_date is null and l_status_id = 2) THEN
                     OPEN l_WFActivityDetails_csr;
                     FETCH l_WFActivityDetails_csr into l_WFActivityDetails_rec;
                     IF (l_WFActivityDetails_csr%NOTFOUND) THEN
                    	 null;
                     ELSE
                        IF( l_WFActivityDetails_rec.activity_end_date is null) THEN
                             x_return_status := FND_API.G_RET_STS_SUCCESS;
                             return;
                         END IF;
                     END IF;
              END IF;
      END IF;
      CLOSE     l_WFDetails_csr;

      l_end_date :=   l_WFDetails_rec.end_date;

       IF (l_type_id <> l_CurrentServiceRequest_rec.incident_type_id OR
            l_status_id <> l_CurrentServiceRequest_rec.incident_status_id OR
            l_severity_id <> l_CurrentServiceRequest_rec.incident_severity_id OR
            l_urgency_id <> l_CurrentServiceRequest_rec.incident_urgency_id OR
            l_owner_id <> l_CurrentServiceRequest_rec.incident_owner_id
        )
        THEN
          FND_MESSAGE.Set_Name('CUG', 'CUG_SR_UPDATE_NOT_ALLOWED');
--          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

-- Begin of changes by ANEEMUCH date 20-May-2002
-- removed check from install_site_use_id as incident address is part of service request
/*
        ELSIF (l_install_site_use_id <> l_CurrentServiceRequest_rec.install_site_use_id) THEN
            OPEN l_IncidentDetails_csr;
            FETCH l_IncidentDetails_csr INTO l_IncidentDetails_rec;

            IF (l_IncidentDetails_csr%NOTFOUND) THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('CUG', 'CUG_SR_UPDATE_NOT_ALLOWED');
--               FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE l_IncidentDetails_csr;
*/

        ELSIF ( l_incident_location_id <> l_CurrentServiceRequest_rec.incident_location_id or
                l_incident_address     <> l_CurrentServiceRequest_rec.incident_address or
                l_incident_city        <> l_CurrentServiceRequest_rec.incident_city or
                l_incident_state       <> l_CurrentServiceRequest_rec.incident_state or
                l_incident_county      <> l_CurrentServiceRequest_rec.incident_county or
                l_incident_province    <> l_CurrentServiceRequest_rec.incident_province or
                l_incident_postal_code <> l_CurrentServiceRequest_rec.incident_postal_code or
                l_incident_country     <> l_CurrentServiceRequest_rec.incident_country) THEN

               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.Set_Name('CUG', 'CUG_INC_ADDR_UPD_NOT_ALLOWED');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;

-- End of changes by ANEEMUCH date 20-May-2002

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

 END Update_ServiceRequest_Prevent;


   -- Enter further code below as specified in the Package spec.
END; -- Package Body CUG_PREVENT_SR_UPDATE_PKG

/
