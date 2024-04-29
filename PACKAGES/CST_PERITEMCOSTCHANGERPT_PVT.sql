--------------------------------------------------------
--  DDL for Package CST_PERITEMCOSTCHANGERPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERITEMCOSTCHANGERPT_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVPICS.pls 120.0 2005/06/28 05:28 cmuthu noship $ */

-- Start of comments
--	API name 	: generateXML
--	Type		: Private
--	Function	: Generate XML data for Periodic Item Cost Change
--                        Report.
--	Pre-reqs	: None
--	Parameters	:
--	IN		:       p_legal_entity_id	IN  NUMBER    Required
--				p_cost_type_id  	IN  NUMBER    Required
--				p_pac_period_id		IN  NUMBER    Required
--                              p_cost_group_id  	IN  NUMBER    Required
--                              p_category_set_id       IN  NUMBER    Required
--                              p_item_master_org_id    IN  NUMBER    Required
--                              p_category_number       IN  NUMBER,   Required /* Dummy */
--                              p_category_from         IN  VARCHAR2  Optional
--                              p_category_to           IN  VARCHAR2  Optional
--                              p_item_from             IN  VARCHAR2  Optional
--                              p_item_to               IN  VARCHAR2  Optional
--                              p_qty_precision         IN  NUMBER    Required
--
--	OUT		:	errcode  OUT NOCOPY 	VARCHAR2
-- 				errno 	 OUT NOCOPY 	NUMBER
--
--	Version	        :       Current version	        1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by the Periodic Item Cost
--                        Change report. The procedure generates XML data and
--                        writes it to the report output file, which is used by
--                        XML Report Publisher program to publish the output.
-- End of comments

PROCEDURE generateXML (
                errcode 		OUT NOCOPY 	VARCHAR2,
                errno			OUT NOCOPY 	NUMBER,
                p_legal_entity_id	IN		NUMBER,
                p_cost_type_id  	IN		NUMBER,
                p_pac_period_id		IN		NUMBER,
                p_cost_group_id  	IN		NUMBER,
                p_category_set_id       IN              NUMBER,
                p_item_master_org_id    IN              NUMBER,
                p_category_number       IN              NUMBER,    /* Dummy */
                p_category_from         IN              VARCHAR2,
                p_category_to           IN              VARCHAR2,
                p_item_from             IN		VARCHAR2,
                p_item_to               IN		VARCHAR2,
                p_qty_precision         IN              NUMBER
        );

-- Start of comments
--	API name 	: generateXML
--	Type		: Private
--	Function	: Adds the parameters to the XML output of Periodic Item
--                        Cost Change Report.
--	Pre-reqs	: None
--	Parameters	:
--	IN		:       p_api_version           IN  NUMBER    Required
--                              p_init_msg_list	        IN  VARCHAR2  Required
--                              p_validation_level      IN  NUMBER    Required
--                              i_legal_entity_id	IN  NUMBER    Required
--				i_cost_type_id  	IN  NUMBER    Required
--				i_pac_period_id		IN  NUMBER    Required
--                              i_cost_group_id  	IN  NUMBER    Required
--                              i_category_set_id       IN  NUMBER    Required
--                              i_item_master_org_id    IN  NUMBER    Required
--                              i_category_from         IN  VARCHAR2  Optional
--                              i_category_to           IN  VARCHAR2  Optional
--                              i_item_from             IN  VARCHAR2  Optional
--                              i_item_to               IN  VARCHAR2  Optional
--
--	OUT		:	x_return_status	 OUT NOCOPY 	VARCHAR2
-- 				x_msg_count	 OUT NOCOPY 	NUMBER
--                              x_msg_data	 OUT NOCOPY     VARCHAR2
--                              x_xml_doc        OUT NOCOPY     CLOB
--
--	Version	        :       Current version	        1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generate XML to add the
--                        parameters of the report to the XML output.
-- End of comments

PROCEDURE add_parameters (
                p_api_version        	IN		NUMBER,
                p_init_msg_list	        IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status	        OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_legal_entity_id	IN		NUMBER,
                i_cost_type_id  	IN		NUMBER,
                i_pac_period_id		IN		NUMBER,
                i_cost_group_id  	IN		NUMBER,
                i_category_set_id       IN              NUMBER,
                i_item_master_org_id    IN              NUMBER,
                i_category_from         IN              VARCHAR2,
                i_category_to           IN              VARCHAR2,
                i_item_from             IN		VARCHAR2,
                i_item_to               IN		VARCHAR2,
                x_xml_doc 		IN OUT NOCOPY 	CLOB
        );
END CST_PerItemCostChangeRpt_PVT;

 

/
