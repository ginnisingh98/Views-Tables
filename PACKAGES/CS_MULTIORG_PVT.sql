--------------------------------------------------------
--  DDL for Package CS_MULTIORG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_MULTIORG_PVT" AUTHID CURRENT_USER as
/* $Header: csxvmois.pls 120.2 2005/09/29 10:26:58 talex noship $ */
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_OrgId
--   Type    :  Private
--   Purpose :  This private API is to get the MutliOrg id.
--   Pre-Req :
--   Parameters:
--       p_api_version          IN                  NUMBER      Required
--       p_init_msg_list        IN                  VARCHAR2
--       p_commit               IN                  VARCHAR2
--       p_validation_level     IN                  NUMBER
--       x_return_status        OUT     NOCOPY      VARCHAR2
--       x_msg_count            OUT     NOCOPY      NUMBER
--       x_msg_data             OUT     NOCOPY      VARCHAR2
--       p_incident_id          IN                  NUMBER      Required
--       x_org_id			    OUT	    NOCOPY	    NUMBER,
--       x_profile			    OUT 	NOCOPY	    VARCHAR2

--   Version : Current version 1.0
--   End of Comments
--

PROCEDURE Get_OrgId (
    p_api_version		IN              NUMBER,
    p_init_msg_list		IN 	            VARCHAR2,
    p_commit			IN			    VARCHAR2,
    p_validation_level	IN	            NUMBER,
    x_return_status		OUT     NOCOPY 	VARCHAR2,
    x_msg_count			OUT 	NOCOPY 	NUMBER,
    x_msg_data			OUT 	NOCOPY 	VARCHAR2,
    p_incident_id		IN	            NUMBER,
    x_org_id			OUT	    NOCOPY	NUMBER,
    x_profile			OUT 	NOCOPY	VARCHAR2
);

End CS_MultiOrg_PVT;

 

/
