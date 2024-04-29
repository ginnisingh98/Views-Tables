--------------------------------------------------------
--  DDL for Package IEX_WF_REP_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WF_REP_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: iexwfres.pls 115.1 2002/03/01 09:43:45 pkm ship     $ */

-- PROCEDURE start workflow
-- DESCRIPTION	This procedure is called to collections workflow to notify a Third Party for repossession */
-- AUTHOR	chewang 2/26/2002 created

PROCEDURE start_workflow
           (p_api_version     	IN NUMBER := 1.0,
            p_init_msg_list    	IN VARCHAR2 := FND_API.G_FALSE,
            p_commit         	  IN VARCHAR2 := FND_API.G_FALSE,
            p_delinquency_id    IN NUMBER,
	          p_repossession_id 	IN NUMBER,
            p_third_party_id    IN NUMBER,
            p_third_party_name  IN NUMBER,
            p_status_yn         IN NUMBER,
            x_return_status   	OUT VARCHAR2,
            x_msg_count      	  OUT NUMBER,
            x_msg_data      	  OUT VARCHAR2);

PROCEDURE select_notice(
            itemtype            IN VARCHAR2,
            itemkey             IN VARCHAR2,
            actid               IN NUMBER,
            funcmode            IN VARCHAR2,
            result              OUT VARCHAR2);

END IEX_WF_REP_STATUS_PUB;

 

/
