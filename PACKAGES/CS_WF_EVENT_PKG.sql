--------------------------------------------------------
--  DDL for Package CS_WF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WF_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: cswfevts.pls 115.5 2003/02/14 00:48:26 rhungund noship $ */

/******
  TYPE link_rec IS RECORD (
      INCIDENT_NUMBER	VARCHAR2(64),
      SUBJECT_ID	NUMBER,
      --LINK_TYPE		VARCHAR2(90)
      LINK_TYPE_ID		NUMBER
  );
***/
   G_CONTACTS_TABLE         CS_SERVICEREQUEST_PVT.contacts_table;

  FUNCTION CS_Custom_Rule_Func(p_subscription_guid in raw,
                                     p_event in out nocopy WF_EVENT_T) RETURN varchar2;

  PROCEDURE Raise_ServiceRequest_Event(
      p_api_version            IN    NUMBER,
      p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
      p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
        p_Event_Code            IN VARCHAR2,
        p_Incident_Number       IN VARCHAR2,
        p_USER_ID               IN NUMBER DEFAULT FND_GLOBAL.USER_ID,      /** p_last_updated_by from Update_ServiceREquest() **/
        p_RESP_ID               IN NUMBER,      /** p_resp_id from Update_ServiceREquest() **/
        p_RESP_APPL_ID          IN NUMBER,      /** p_resp_appl_id from Update_ServiceREquest() **/
        p_Old_SR_Rec            IN CS_ServiceRequest_PVT.service_request_rec_type := NULL,
        p_New_SR_Rec            IN CS_ServiceRequest_PVT.service_request_rec_type := NULL,
        p_Contacts_Table        IN CS_ServiceRequest_PVT.contacts_table := G_CONTACTS_TABLE,
        p_Link_Rec              IN CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE := NULL,
        p_wf_process_id         IN NUMBER       DEFAULT NULL,
        p_owner_id              IN NUMBER       DEFAULT NULL, /** passed by CIC **/
	p_wf_manual_launch      IN VARCHAR2 DEFAULT 'N',
        x_wf_process_id         OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);


END CS_WF_EVENT_PKG;

 

/
