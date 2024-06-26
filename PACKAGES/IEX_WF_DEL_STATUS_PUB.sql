--------------------------------------------------------
--  DDL for Package IEX_WF_DEL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WF_DEL_STATUS_PUB" AUTHID CURRENT_USER AS
/* $Header: iexwfdus.pls 120.0 2004/01/24 03:31:21 appldev noship $ */

-- PROCEDURE start workflow
-- DESCRIPTION This procedure is called to start collections Delinquent Status Approval workflow*/
-- AUTHOR	chewang 2/26/2002 	created

PROCEDURE start_workflow(
            p_api_version     IN NUMBER := 1.0,
            p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
            p_commit         	IN VARCHAR2 := FND_API.G_FALSE,
 	    			p_delinquency_id 	IN NUMBER,
 	    			p_repossession_id IN NUMBER,
 	    			p_litigation_id 	IN NUMBER,
 	    			p_writeoff_id 		IN NUMBER,
					  p_requester_id    IN NUMBER,
					  p_requester_name  IN VARCHAR2,
					  p_approver_id     IN NUMBER,
					  p_approver_name   IN VARCHAR2,
 	    			x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count      	OUT NOCOPY NUMBER,
            x_msg_data      	OUT NOCOPY VARCHAR2);

PROCEDURE update_approval_status(
 						itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid        		IN NUMBER,
            funcmode        IN VARCHAR2,
            result          OUT NOCOPY VARCHAR2);


procedure update_rejection_status(
  					itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid     			IN NUMBER,
            funcmode        IN VARCHAR2,
            result          OUT NOCOPY VARCHAR2);
END IEX_WF_DEL_STATUS_PUB;

 

/
