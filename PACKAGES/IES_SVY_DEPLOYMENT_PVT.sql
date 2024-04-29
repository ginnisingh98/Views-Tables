--------------------------------------------------------
--  DDL for Package IES_SVY_DEPLOYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_SVY_DEPLOYMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: iesdpyps.pls 120.1 2005/06/16 11:15:33 appldev  $ */
----------------------------------------------------------------------------------------------------------
-- Procedure
--   Submit_Deployment

-- PURPOSE
--   Submit Deployment to Concurrent Manager at the specified_time.
--
-- PARAMETERS

-- NOTES
-- created rrsundar 05/03/2000
---------------------------------------------------------------------------------------------------------


Procedure  Submit_Deployment
(
    p_api_version              IN  NUMBER                                  ,
    p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE             ,
    p_commit                   IN  VARCHAR2 := FND_API.G_FALSE             ,
    p_validation_level         IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL  ,
    x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
    x_msg_count                OUT NOCOPY /* file.sql.39 change */ NUMBER                                  ,
    x_msg_data                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
    x_message                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
    p_user_id  	               IN  NUMBER                                  ,
    p_resp_id                  IN  NUMBER                                  ,
    p_deployment_id            IN  NUMBER    := NULL                       ,
    p_list_entry_id            IN  NUMBER    := NULL                       ,
    p_template_id              IN  NUMBER    := NULL                       ,
    p_start_time               IN  DATE      := NULL                       ,
    p_reminder_type            IN  VARCHAR2  := NULL
);
---------------------------------------------------------------------------------------------------------
-- Procedure
--   FM_Single_Request
-- PURPOSE  Wrapper API to select the appropriate template details and submit a request to the
--          fulfillment engine.
--
--
-- PARAMETERS
-- NOTES
-- created kpandey 05/02/2000
---------------------------------------------------------------------------------------------------------
PROCEDURE FM_Single_Request
(
    p_api_version         	IN  NUMBER                                       ,
    p_init_msg_list       	IN  VARCHAR2     := FND_API.G_FALSE              ,
    p_commit              	IN  VARCHAR2     := FND_API.G_FALSE              ,
    p_validation_level  	IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER                                       ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
    x_message               OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
--	errbuf 				    OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
--	retcode				    OUT NOCOPY /* file.sql.39 change */ NUMBER                                       ,
    p_list_entry_id         IN  NUMBER                                       ,
    p_template_id           IN  NUMBER                                       ,
    p_deployment_id         IN  NUMBER                                       ,
	p_user_id               IN  NUMBER
);

----------------------------------------------------------------------------------------------------------
-- Procedure
--   FM_Group_Request
-- PURPOSE  Wrapper API to select the appropriate template details and submit a
--  group request (mass e-mail invitation) to the  fulfillment engine.
--
--
-- PARAMETERS
-- NOTES
-- created kpandey 06/07/2000
---------------------------------------------------------------------------------------------------------
PROCEDURE FM_Group_Request
(
	errbuf 				    OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
	retcode				    OUT NOCOPY /* file.sql.39 change */ NUMBER                                       ,
    p_api_version         	IN  NUMBER                                       ,
    p_init_msg_list       	IN  VARCHAR2     := FND_API.G_FALSE              ,
    p_commit              	IN  VARCHAR2     := FND_API.G_FALSE              ,
    p_validation_level  	IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL   ,
    p_deployment_id         IN  NUMBER                                       ,
    p_template_id           IN  NUMBER                                       ,
    p_reminder_type         IN  VARCHAR2                                     ,
	p_user_id               IN  NUMBER                                       ,
    p_reminder_hst_id       IN  NUMBER
-- no other out params are allowed here since its called from concurrent manager
--    x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
--    x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER                                       ,
--    x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                     ,
--    x_message               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Populate_Survey_List_Entries
-- PURPOSE  Wrapper API to populate IEY_SUREVY_LIST_ENTRIES based on the list_header_id and .
--           deployment_id
--
-- PARAMETERS
-- NOTES
-- created kpandey 06/07/2000
---------------------------------------------------------------------------------------------------------
PROCEDURE Populate_Survey_List_Entries
(
   p_api_version         	IN  NUMBER                                        ,
   p_init_msg_list       	IN  VARCHAR2      := FND_API.G_FALSE              ,
   p_commit              	IN  VARCHAR2      := FND_API.G_FALSE              ,
   p_validation_level  	    IN  NUMBER        := FND_API.G_VALID_LEVEL_FULL   ,
   x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                      ,
   x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER                                        ,
   x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                      ,
   x_message                OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                      ,
   p_survey_deployment_id   IN  NUMBER
);

Procedure Update_Dep_Status (p_dep_id NUMBER,
			    p_status VARCHAR2,
			    p_reminder_type VARCHAR2,
			    p_update_flag VARCHAR2);

END; -- Package spec


 

/
