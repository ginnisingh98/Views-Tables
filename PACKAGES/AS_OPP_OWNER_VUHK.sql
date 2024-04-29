--------------------------------------------------------
--  DDL for Package AS_OPP_OWNER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPP_OWNER_VUHK" AUTHID CURRENT_USER as
/* $Header: asxvhows.pls 115.0 2002/12/18 07:31:00 xding noship $ */
-- Start of Comments
-- Package name     : AS_OPP_OWNER_VUHK
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Opportunity_Owner
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN:
--      p_lead_id 	     IN NUMBER   Required
--
--   OUT:
--      x_owner_access_id    OUT  NUMBER
--      x_return_status      OUT  VARCHAR2
--
--
--   End of Comments

PROCEDURE Get_Opportunity_Owner(
    P_Lead_Id             	 IN   NUMBER,
    X_OWNER_ACCESS_ID            OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2
    );


End AS_OPP_OWNER_VUHK;

 

/
