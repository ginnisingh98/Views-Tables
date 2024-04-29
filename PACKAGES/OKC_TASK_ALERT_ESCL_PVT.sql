--------------------------------------------------------
--  DDL for Package OKC_TASK_ALERT_ESCL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TASK_ALERT_ESCL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCPALTS.pls 120.0 2005/05/25 22:29:59 appldev noship $ */
	G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_TASK_ALERT_ESCALATE';
 	G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
	G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  	G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  	G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
	G_LEVEL	       	       CONSTANT VARCHAR2(4)   := '_PVT';
	G_WORKFLOW_ACTIVE      CONSTANT VARCHAR2(200) := 'OKC_WORKFLOW_ACTIVE';
  	G_WF_NAME_TOKEN        CONSTANT VARCHAR2(200) := 'WF_ITEM';
  	G_WF_P_NAME_TOKEN      CONSTANT VARCHAR2(200) := 'WF_PROCESS';
  	G_PROCESS_NOTFOUND     CONSTANT VARCHAR2(200) := 'OKC_PROCESS_NOT_FOUND';
  	G_INVALID_VALUE	       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;

	g_api_version			NUMBER := 1.0;
	g_msg_count			NUMBER;
	g_msg_data			VARCHAR2(240);
	g_return_status			VARCHAR2(3);

	--Procedure to send notifications to all the task owners before the due date
	PROCEDURE task_alert( errbuf   	OUT NOCOPY VARCHAR2,
			      retcode    	OUT NOCOPY VARCHAR2,
			      p_api_version	IN NUMBER,
			      p_init_msg_list	IN VARCHAR2 default OKC_API.G_FALSE,
			      p_wf_name		IN VARCHAR2,
			      p_wf_process	IN VARCHAR2);

	--Procedure to escalate the task (Level 1)
	PROCEDURE task_escalation1(errbuf   		OUT NOCOPY VARCHAR2,
			      	   retcode    		OUT NOCOPY VARCHAR2,
				   p_api_version	IN NUMBER,
				   p_init_msg_list	IN VARCHAR2 default OKC_API.G_FALSE,
				   p_wf_name		IN VARCHAR2,
				   p_wf_process		IN VARCHAR2);

	--Procedure to escalate the task (level 2)
	PROCEDURE task_escalation2(errbuf   		OUT NOCOPY VARCHAR2,
			           retcode    		OUT NOCOPY VARCHAR2,
				   p_api_version	IN NUMBER,
				   p_init_msg_list	IN VARCHAR2 default OKC_API.G_FALSE,
				   p_wf_name		IN VARCHAR2,
				   p_wf_process		IN VARCHAR2);

	--Procedure to trigger the action assembler when the scheduled planned date is reached
	PROCEDURE okc_pdate_reach_pvt(errbuf   		OUT NOCOPY VARCHAR2,
			      	      retcode    	OUT NOCOPY VARCHAR2,
				      p_api_version	IN NUMBER,
				      p_init_msg_list	IN VARCHAR2 default OKC_API.G_FALSE);

END OKC_TASK_ALERT_ESCL_PVT;

 

/
