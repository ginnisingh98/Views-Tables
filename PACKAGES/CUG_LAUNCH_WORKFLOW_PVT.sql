--------------------------------------------------------
--  DDL for Package CUG_LAUNCH_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_LAUNCH_WORKFLOW_PVT" AUTHID CURRENT_USER  AS
/* $Header: CUGWFLNS.pls 120.2 2006/03/27 14:36:49 appldev noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


  PROCEDURE launch_workflow 	  (
    				   p_api_version        IN      NUMBER                                      ,
    				   p_init_msg_list      IN      VARCHAR2    := FND_API.G_FALSE              ,
    				   p_commit             IN      VARCHAR2    := FND_API.G_FALSE              ,
    				   p_validation_level   IN      NUMBER      := FND_API.G_VALID_LEVEL_FULL   ,
    				   x_return_status      OUT     NOCOPY VARCHAR2                                    ,
    				   x_msg_count          OUT     NOCOPY NUMBER                                      ,
    				   x_msg_data           OUT     NOCOPY VARCHAR2                                    ,
    				   p_incident_id        IN      NUMBER                                      ,
                       p_source             IN      VARCHAR2 DEFAULT NULL                       ,
                       p_incident_status_id IN      NUMBER                                      ,
                       p_initiator_user_id  IN      NUMBER DEFAULT NULL                         ,
                       p_initiator_resp_id  IN      NUMBER DEFAULT NULL                         ,
                       p_initiator_resp_appl_id IN  NUMBER DEFAULT NULL
    				   );

END; -- Package spec

/
