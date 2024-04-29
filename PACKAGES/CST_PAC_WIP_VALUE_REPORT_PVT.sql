--------------------------------------------------------
--  DDL for Package CST_PAC_WIP_VALUE_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PAC_WIP_VALUE_REPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTPWVRS.pls 120.2 2005/10/17 03:40 skayitha noship $ */
-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Generate_XMLData
--   Type            : Group
--   Function        : The procedure is called from concurrent request
--                     "Periodic WIP Value Report"
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_report_type            VARCHAR2       Required
--                                             1 for Period To Date and
--                                             2 for Cumulative
--     p_legal_entity_id        VARCHAR2       Legal Entity Id
--     p_cost_group_id          VARCHAR2       PAC Cost Group Id
--     p_cost_type_id           VARCHAR2       PAC Cost Type Id
--     p_pac_period_id          NUMBER         PAC Period id
--     p_set_of_books           VARCHAR2
--     p_class_type             VARCHAR2     Optional default NULL
--     p_from_job               VARCHAR2     Optional         default NULL
--                                           Job From
--     p_to_job                 VARCHAR2     Optional         default NULL
--                                           Job To
--     p_from_assembly          VARCHAR2     Optional         default NULL
--                                           Assembly From
--     p_to_assembly            VARCHAR2     Optional         default NULL
--                                           Assembly To
--     p_currency_code          VARCHAR2     The amounts are displayed in specified
--                                           currency code.
--     p_exchange_rate_char     VARCHAR2
--     p_disp_inv_rate          VARCHAR2
--     p_exchange_rate_type     NUMBER
--     p_exchange_rate_char     VARCHAR2
--     p_stuct_number	        NUMBER
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
                      (errbuf                 OUT     NOCOPY VARCHAR2,
                       retcode                OUT     NOCOPY NUMBER,
                       p_report_type          IN      VARCHAR2,
                       p_legal_entity_id      IN      VARCHAR2,
                       p_cost_type_id         IN      VARCHAR2,
                       p_pac_period_id        IN      NUMBER,
		       p_cost_group_id        IN      VARCHAR2,
		       p_set_of_books         IN      VARCHAR2,
                       p_class_type           IN      VARCHAR2,
                       p_from_job             IN      VARCHAR2,
                       p_to_job               IN      VARCHAR2,
                       p_from_assembly        IN      VARCHAR2,
                       p_to_assembly          IN      VARCHAR2,
		       p_currency_code        IN      VARCHAR2,
		       p_disp_inv_rate        IN      VARCHAR2,
		       p_exchange_rate_type   IN      NUMBER,
                       p_exchange_rate_char   IN      VARCHAR2,
		       p_stuct_number	      IN      NUMBER
                      );
-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Display_Parameters
--   Type            : Group
--   Function        : The procedure is called from Generate_XMLData
--
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version            NUMBER       Required
--     p_init_msg_list          VARCHAR2     Required
--     p_validation_level       NUMBER       Required
--     p_report_type            NUMBER       Required
--                                           1 for Period To Date and
--                                           2 for Cumulative
--     p_legal_entity_id        NUMBER       Legal Entity Id
--     p_cost_group_id          NUMBER       PAC Cost Group Id
--     p_cost_type_id           NUMBER       PAC Cost Type Id
--     p_pac_period_id          NUMBER       PAC Period id
--     p_class_type             VARCHAR2     Optional default NULL
--     p_from_job               VARCHAR2     Optional         default NULL
--                                           Job From
--     p_to_job                 VARCHAR2     Optional         default NULL
--                                           Job To
--     p_from_assembly          VARCHAR2     Optional         default NULL
--                                           Assembly From
--     p_to_assembly            VARCHAR2     Optional         default NULL
--                                           Assembly To
--     p_exchange_rate_char     VARCHAR2
--     p_currency_code          VARCHAR2   The amounts are displayed in specified
--                                         currency code.
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

PROCEDURE  Display_Parameters (p_api_version         IN         NUMBER,
                               p_init_msg_list       IN         VARCHAR2,
                               p_validation_level    IN         NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               p_report_type         IN         NUMBER,
                               p_legal_entity_id     IN         NUMBER,
                               p_cost_group_id       IN         NUMBER,
                               p_cost_type_id        IN         NUMBER,
                               p_pac_period_id       IN         NUMBER,
                               p_class_type          IN         VARCHAR2,
                               p_from_job            IN         VARCHAR2,
                               p_to_job              IN         VARCHAR2,
                               p_from_assembly       IN         VARCHAR2,
                               p_to_assembly         IN         VARCHAR2,
                               p_exchange_rate_char  IN         VARCHAR2,
                               p_currency_code       IN         VARCHAR2,
                               x_xml_doc             IN OUT NOCOPY  CLOB);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Periodic_WIP_Value_Rpt_Details
--   Type            : Group
--   Function        : The procedure is called from Generate_XMLData
--
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version            NUMBER       Required
--     p_init_msg_list          VARCHAR2     Required
--     p_validation_level       NUMBER       Required
--     p_report_type            NUMBER       Required
--                                           1 for Period To Date and
--                                           2 for Cumulative
--     p_legal_entity_id        NUMBER       Legal Entity Id
--     p_cost_group_id          NUMBER       PAC Cost Group Id
--     p_cost_type_id           NUMBER       PAC Cost Type Id
--     p_pac_period_id          NUMBER       PAC Period id
--     p_legal_entity_id        NUMBER       Legal Entity Id
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--
--   Version : Current version       1.0
--
-- End of comments
-------------------------------------------------------------------------------


 PROCEDURE Periodic_WIP_Value_Rpt_Details(p_api_version         IN         NUMBER,
                                          p_init_msg_list       IN         VARCHAR2,
                                          p_validation_level    IN         NUMBER,
                                          x_return_status       OUT NOCOPY VARCHAR2,
                                          x_msg_count           OUT NOCOPY NUMBER,
                                          x_msg_data            OUT NOCOPY VARCHAR2,
                                          p_report_type         IN         NUMBER,
                                          p_pac_period_id       IN         NUMBER,
                                          p_cost_group_id       IN         NUMBER,
                                          p_cost_type_id        IN         NUMBER,
                                          p_legal_entity_id     IN         NUMBER
                                         );
-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Get_XMLData
--   Type            : Group
--   Function        : The procedure is called from Generate_XMLData
--
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version            NUMBER       Required
--     p_init_msg_list          VARCHAR2     Required
--     p_validation_level       NUMBER       Required
--     p_report_type            NUMBER       Required
--                                           1 for Period To Date and
--                                           2 for Cumulative
--     p_legal_entity_id        NUMBER       Legal Entity Id
--     p_cost_group_id          NUMBER       PAC Cost Group Id
--     p_cost_type_id           NUMBER       PAC Cost Type Id
--     p_pac_period_id          NUMBER       PAC Period id
--     p_class_type             VARCHAR2     Optional default NULL
--     p_from_job               VARCHAR2     Optional         default NULL
--                                           Job From
--     p_to_job                 VARCHAR2     Optional         default NULL
--                                           Job To
--     p_from_assembly          VARCHAR2     Optional         default NULL
--                                           Assembly From
--     p_to_assembly            VARCHAR2     Optional         default NULL
--                                           Assembly To
--     p_exchange_rate_char     VARCHAR2
--     p_currency_code          VARCHAR2   The amounts are displayed in specified
--                                         currency code.
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


   PROCEDURE Get_XMLData (p_api_version         IN             NUMBER,
                          p_init_msg_list       IN             VARCHAR2,
                          p_validation_level    IN             NUMBER,
                          x_return_status       OUT NOCOPY     VARCHAR2,
                          x_msg_count           OUT NOCOPY     NUMBER,
                          x_msg_data            OUT NOCOPY     VARCHAR2,
                          p_legal_entity_id     IN             NUMBER,
                          p_cost_group_id       IN             NUMBER,
                          p_cost_type_id        IN             NUMBER,
                          p_pac_period_id       IN             NUMBER,
                          p_class_type          IN             VARCHAR2,
                          p_from_job            IN             VARCHAR2,
                          p_to_job              IN             VARCHAR2,
                          p_from_assembly       IN             VARCHAR2,
                          p_to_assembly         IN             VARCHAR2,
                          p_exchange_rate_char  IN             VARCHAR2,
                          p_currency_code       IN             VARCHAR2,
                          x_xml_doc             IN OUT NOCOPY  CLOB);

END CST_PAC_WIP_VALUE_REPORT_PVT;

 

/
