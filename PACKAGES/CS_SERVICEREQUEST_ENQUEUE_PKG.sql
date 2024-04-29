--------------------------------------------------------
--  DDL for Package CS_SERVICEREQUEST_ENQUEUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICEREQUEST_ENQUEUE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSXSREQS.pls 120.0 2006/02/09 16:58:58 spusegao noship $ */


	PROCEDURE EnqueueSR( p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_api_version IN NUMBER,
                             p_commit IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_validation_level IN  NUMBER   DEFAULT fnd_api.g_valid_level_full,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_Request_Id IN NUMBER,
                             p_request_number IN VARCHAR2 DEFAULT NULL,
                             p_audit_id IN NUMBER,
                             p_resp_appl_id  IN NUMBER,
                             p_resp_id    IN NUMBER,
                             p_user_id    IN NUMBER,
                             p_login_id   IN NUMBER,
                             p_org_id     IN NUMBER,
                             p_update_desc_flex IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_object_version_number IN NUMBER DEFAULT NULL,
			     p_Transaction_type IN VARCHAR2,
                             p_message_rev IN NUMBER,
		             p_ServiceRequest IN CS_ServiceRequest_PVT.SERVICE_REQUEST_REC_TYPE,
			     p_Notes          IN CS_ServiceRequest_PVT.NOTES_TABLE,
			     p_Contacts       IN CS_ServiceRequest_PVT.CONTACTS_TABLE ) ;

	PROCEDURE EnqueueSR( p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_api_version IN NUMBER,
                             p_commit IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_validation_level IN  NUMBER   DEFAULT fnd_api.g_valid_level_full,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_Request_Id IN NUMBER,
                             p_request_number IN VARCHAR2  DEFAULT NULL,
                             p_audit_id IN NUMBER,
                             p_resp_appl_id  IN NUMBER,
                             p_resp_id    IN NUMBER,
                             p_user_id    IN NUMBER,
                             p_login_id   IN NUMBER,
                             p_org_id     IN NUMBER,
                             p_update_desc_flex IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_object_version_number IN NUMBER DEFAULT NULL,
			     p_Transaction_type IN VARCHAR2,
                             p_message_rev IN NUMBER,
			     p_ServiceRequest IN CS_ServiceRequest_PVT.SERVICE_REQUEST_REC_TYPE,
			     p_Contacts       IN CS_ServiceRequest_PVT.CONTACTS_TABLE ) ;

	PROCEDURE EnqueueSR( p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_api_version IN NUMBER,
                             p_commit IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_validation_level IN  NUMBER   DEFAULT fnd_api.g_valid_level_full,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2,
                             p_Request_Id IN NUMBER,
                             p_request_number IN VARCHAR2 DEFAULT NULL,
                             p_audit_id IN NUMBER,
                             p_resp_appl_id  IN NUMBER,
                             p_resp_id    IN NUMBER,
                             p_user_id    IN NUMBER,
                             p_login_id   IN NUMBER,
                             p_org_id     IN NUMBER,
                             p_update_desc_flex IN VARCHAR2 DEFAULT fnd_api.g_false,
                             p_object_version_number IN NUMBER DEFAULT NULL,
			     p_Transaction_type IN VARCHAR2,
                             p_message_rev IN NUMBER,
                             p_Notes          IN CS_ServiceRequest_PVT.NOTES_TABLE);

END CS_ServiceRequest_ENQUEUE_PKG;


 

/
