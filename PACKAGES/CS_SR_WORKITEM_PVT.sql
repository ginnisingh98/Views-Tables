--------------------------------------------------------
--  DDL for Package CS_SR_WORKITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_WORKITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: csvsrwis.pls 120.1 2006/01/10 12:51:59 spusegao noship $ */


  /******************************************************
   Create_Workitem() -
  ******************************************************/

  PROCEDURE Create_Workitem(
		p_api_version		IN NUMBER,
		p_init_msg_list		IN VARCHAR2	DEFAULT fnd_api.g_false,
		p_commit		IN VARCHAR2	DEFAULT fnd_api.g_false,
		p_incident_id		IN NUMBER,
		p_incident_number	IN VARCHAR2,
		p_sr_rec	IN CS_ServiceRequest_PVT.service_request_rec_type,
		p_user_id		IN NUMBER,	-- Required
		p_resp_appl_id		IN NUMBER,	-- Required
		p_login_id		IN NUMBER DEFAULT NULL,
		x_work_item_id		OUT	NOCOPY NUMBER,
		x_return_status		OUT	NOCOPY VARCHAR2,
		x_msg_count		OUT	NOCOPY NUMBER,
		x_msg_data		OUT	NOCOPY VARCHAR2);


  /******************************************************
   Update_Workitem() -
  ******************************************************/

  PROCEDURE Update_Workitem(
		p_api_version		IN NUMBER,
		p_init_msg_list		IN VARCHAR2 DEFAULT fnd_api.g_false,
		p_commit		IN VARCHAR2 DEFAULT fnd_api.g_false,
		p_incident_id		IN NUMBER,
		p_old_sr_rec IN CS_ServiceRequest_PVT.sr_oldvalues_rec_type,
		p_new_sr_rec IN CS_ServiceRequest_PVT.service_request_rec_type,
		p_user_id		IN NUMBER,	-- Required
		p_resp_appl_id		IN NUMBER,	-- Required
		p_login_id		IN NUMBER DEFAULT NULL,
		x_return_status		OUT	NOCOPY VARCHAR2,
		x_msg_count		OUT	NOCOPY NUMBER,
		x_msg_data		OUT	NOCOPY VARCHAR2);


  /******************************************************
   FUNCTION Is_Value_Changed()
  ******************************************************/

  FUNCTION Is_Value_Changed(
		p_old_val	IN VARCHAR2,
		p_new_val	IN VARCHAR2) RETURN BOOLEAN;

  /******************************************************
   FUNCTION Is_Value_Changed()
  ******************************************************/

  FUNCTION Is_Value_Changed(
		p_old_val	IN NUMBER,
		p_new_val	IN NUMBER) RETURN BOOLEAN;

  /******************************************************
   FUNCTION Is_Value_Changed()
  ******************************************************/

  FUNCTION Is_Value_Changed(
		p_old_val	IN DATE,
		p_new_val	IN DATE) RETURN BOOLEAN;

  /******************************************************
   Procedure Apply_Priority_Rule
  ******************************************************/

 PROCEDURE Apply_Priority_Rule
           (P_New_Inc_Responded_By_Date     IN        DATE,
            P_New_Obligation_Date           IN        DATE,
            P_New_Exp_Resolution_Date       IN        DATE,
            P_New_Severity_Id               IN        NUMBER,
            P_Old_Inc_Responded_By_Date     IN        DATE,
            P_Old_Obligation_Date           IN        DATE,
            P_Old_Exp_Resolution_Date       IN        DATE,
            P_Old_Severity_Id               IN        NUMBER,
            P_Operation_mode                IN        VARCHAR2,
            X_Change_WI_Flag               OUT NOCOPY VARCHAR2,
            X_Due_Date                     OUT NOCOPY DATE,
            X_Priority_Code                OUT NOCOPY VARCHAR2,
            X_Return_Status                OUT NOCOPY VARCHAR2,
            X_Msg_Count                    OUT NOCOPY NUMBER,
            X_Msg_Data                     OUT NOCOPY VARCHAR2);

END CS_SR_WORKITEM_PVT;

 

/
