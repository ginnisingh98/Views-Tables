--------------------------------------------------------
--  DDL for Package CST_EAM_WORKORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_EAM_WORKORDERS_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTPEEAS.pls 120.1 2005/07/12 06:46 skayitha noship $ */

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Generate_XMLData
--   Type            : Private
--   Function        : The procedure is called from concurrent request
--                     " Concurrent Request Name "
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_legal_entity_id        NUMBER       Legal Entity Id
--     p_cost_group_id          NUMBER       PAC Cost Group Id
--     p_cost_type_id           NUMBER       PAC Cost Type Id
--     p_pac_period_id          NUMBER       PAC Period id
--     p_range                  NUMBER       1 All
--                                           2 Specific
--					     3 Range
--     p_dummy1               NUMBER         Default NULL,
--     p_dummy2               NUMBER         Default NULL,
--     p_from_workorder         VARCHAR2     From WorkOrder
--     p_to_workorder           VARCHAR2     To WorkOrder
--     p_specific_workorder     VARCHAR2     Optional
--
--   OUT             :
--     errbuf         VARCHAR2
--     retcode        NUMBER
--
--   Version : Current version       1.0
--
-- End of comments
-------------------------------------------------------------------------------

PROCEDURE Generate_XMLData
        (errcode 		OUT NOCOPY 	VARCHAR2,
         errno 			OUT NOCOPY 	NUMBER,
         p_legal_entity_id      IN 		NUMBER,
         p_cost_type_id 	IN 		NUMBER,
	 p_cost_group_id 	IN 		NUMBER,
	 p_range                IN              NUMBER,
	 p_dummy1               IN              NUMBER := NULL,
	 p_dummy2               IN              NUMBER := NULL,
	 p_from_workorder       IN              VARCHAR2 := NULL,
	 p_to_workorder         IN              VARCHAR2 := NULL,
	 p_specific_workorder   IN              NUMBER := NULL);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Display_Parameters
--   Type            : Private
--   Function        : The procedure is called from Generate_XMLData
--
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version            NUMBER       Required
--     p_init_msg_list          VARCHAR2     Required
--     p_validation_level       NUMBER       Required
--     p_legal_entity_id        NUMBER       Legal Entity Id
--     p_cost_group_id          NUMBER       PAC Cost Group Id
--     p_cost_type_id           NUMBER       PAC Cost Type Id
--     p_pac_period_id          NUMBER       PAC Period id
--     p_range                  NUMBER       1 All
--                                           2 Specific
--					     3 Range
--     p_from_workorder         VARCHAR2     From WorkOrder
--     p_to_workorder           VARCHAR2     To WorkOrder
--     p_specific_workorder     VARCHAR2     Optional
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     x_xml_doc          CLOB
--
--   Version : Current version       1.0
--
-- End of comments
-------------------------------------------------------------------------------

PROCEDURE  Display_Parameters (p_api_version          IN	      NUMBER,
                              p_init_msg_list         IN              VARCHAR2,
                              p_validation_level      IN              NUMBER,
                              x_return_status         OUT NOCOPY      VARCHAR2,
                              x_msg_count             OUT NOCOPY      NUMBER,
                              x_msg_data              OUT NOCOPY      VARCHAR2,
                              p_legal_entity_id       IN              NUMBER,
                              p_cost_group_id         IN              NUMBER,
                              p_cost_type_id          IN              NUMBER,
                              p_range                 IN              NUMBER,
                              p_from_workorder        IN              VARCHAR2,
                              p_to_workorder          IN              VARCHAR2,
                              p_specific_workorder    IN              NUMBER,
                              x_xml_doc               IN OUT NOCOPY   CLOB);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : eAM_Est_Actual_details
--   Type            : Private
--   Function        : The procedure is called from Generate_XMLData
--
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version            NUMBER       Required
--     p_init_msg_list          VARCHAR2     Required
--     p_validation_level       NUMBER       Required
--     p_legal_entity_id        NUMBER       Legal Entity Id
--     p_cost_group_id          NUMBER       PAC Cost Group Id
--     p_cost_type_id           NUMBER       PAC Cost Type Id
--     p_pac_period_id          NUMBER       PAC Period id
--     p_range                  NUMBER       1 All
--                                           2 Specific
--					     3 Range
--     p_from_workorder         VARCHAR2     From WorkOrder
--     p_to_workorder           VARCHAR2     To WorkOrder
--     p_specific_workorder      VARCHAR2     Optional
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     x_xml_doc          CLOB
--
--   Version : Current version       1.0
--
-- End of comments
-------------------------------------------------------------------------------


PROCEDURE eAM_Est_Actual_details(p_api_version	       IN         NUMBER,
                                 p_init_msg_list      IN         VARCHAR2,
                                 p_validation_level   IN         NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_msg_count          OUT NOCOPY NUMBER,
                                 x_msg_data           OUT NOCOPY VARCHAR2,
                                 p_legal_entity_id    IN         NUMBER,
                                 p_cost_group_id      IN         NUMBER,
	                         p_cost_type_id       IN         NUMBER,
				 p_range              IN         NUMBER,
	                         p_from_workorder     IN         VARCHAR2,
		                 p_to_workorder       IN         VARCHAR2,
	                         p_specific_workorder IN         NUMBER,
                                 x_xml_doc            IN OUT NOCOPY   CLOB);

END CST_eAM_WorkOrders_PVT;

 

/
