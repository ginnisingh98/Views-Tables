--------------------------------------------------------
--  DDL for Package CST_PENDINGTXNSREPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PENDINGTXNSREPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVPTRS.pls 120.1.12010000.2 2008/11/10 14:34:15 mpuranik ship $ */

-- Start of comments
--	API name 	: generateXML
--	Type		: Private
--	Function	: Generate XML data for Period Close Pending transactions
--                        Report.
--	Pre-reqs	: None
--	Parameters	:
--	IN		:       p_org_id 		IN  NUMBER  Required
--				p_period_id 		IN  NUMBER  Required
--				p_resolution_type 	IN  NUMBER  Required
--				p_transaction_type 	IN  NUMBER  Required
--
--	OUT		:	errcode  OUT NOCOPY 	VARCHAR2
-- 				errno 	 OUT NOCOPY 	NUMBER
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by the Period Close Pending
--                        Transactions report. This is the wrapper procedure that
--                        calls the other procedures to generate XML data
--                        according to report parameters.
-- End of comments
PROCEDURE generateXML
                (errcode		OUT NOCOPY 	VARCHAR2,
                errno			OUT NOCOPY 	NUMBER,
                p_org_id 		IN		NUMBER,
                p_period_id 		IN		NUMBER,
                p_resolution_type 	IN		NUMBER,
                p_transaction_type 	IN		NUMBER);

-- Start of comments
--	API name 	: add_parameters
--	Type		: Private
--	Function	: Generate XML data for Parameters and append it to output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_org_id 	     NUMBER      Required
--                        i_period_id        NUMBER      Required
--                        i_resolution_type  NUMBER      Required
--                        i_transaction_type NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for the report parameters
--                        and appends it to the report output
-- End of comments
PROCEDURE add_parameters
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_org_id 		IN 		NUMBER,
                i_period_id 		IN 		NUMBER,
                i_resolution_type 	IN 		NUMBER,
                i_transaction_type 	IN 		NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: unprocessed_mtl_trx
--	Type		: Private
--	Function	: Generate XML data for unprocessed material transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for unprocessed
--                        material transactions (MTL_MATERIAL_TRANSACTIONS_TEMP)
--                        and appends it to the report output
-- End of comments
PROCEDURE unprocessed_mtl_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: uncosted_mtl_trx
--	Type		: Private
--	Function	: Generate XML data for uncosted material transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for uncosted
--                        material transactions (MTL_MATERIAL_TRANSACTIONS)
--                        and appends it to the report output
-- End of comments
PROCEDURE uncosted_mtl_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT 		NOCOPY CLOB);

-- Start of comments
--	API name 	: uncosted_wip_trx
--	Type		: Private
--	Function	: Generate XML data for uncosted wip transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for uncosted
--                        wip transactions (WIP_COST_TXN_INTERFACE)
--                        and appends it to the report output
-- End of comments
PROCEDURE uncosted_wip_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: pending_wsm_trx
--	Type		: Private
--	Function	: Generate XML data for pending WSM interface transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for pending WSM
--                        interface transactions (WSM_SPLIT_MERGE_TXN_INTERFACE,
--                        WSM_LOT_MOVE_TXN_INTERFACE, WSM_LOT_SPLIT_MERGES_INTERFACE)
--                        and appends it to the report output
-- End of comments
PROCEDURE pending_wsm_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: pending_mtl_interface_trx
--	Type		: Private
--	Function	: Generate XML data for pending material interface transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for pending material
--                        interface transactions (MTL_TRANSACTIONS_INTERFACE_V)
--                        and appends it to the report output
-- End of comments
PROCEDURE pending_mtl_interface_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY	CLOB);

-- Start of comments
--	API name 	: pending_rcv_trx
--	Type		: Private
--	Function	: Generate XML data for pending receiving transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for pending receiving
--                        transactions (RCV_TRANSACTIONS_INTERFACE)and appends
--                        it to the report output
-- End of comments
PROCEDURE pending_rcv_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: pending_wip_move_trx
--	Type		: Private
--	Function	: Generate XML data for pending wip move transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for pending wip move
--                        material (WIP_MOVE_TXN_INTERFACE)and appends it to the
--                        report output
-- End of comments
PROCEDURE pending_wip_move_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: pending_shipping_trx
--	Type		: Private
--	Function	: Generate XML data for pending shipping transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_start_date  DATE        Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for pending shipping
--                        transactions (WSH_DELIVERY_DETAILS) and appends it to
--                        the report output
-- End of comments
PROCEDURE pending_shipping_trx
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_start_date 	IN 		DATE,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: incomplete_eam_wo
--	Type		: Private
--	Function	: Generate XML data for incomplete eam workorders
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for incomplete eam
--                        workorders (EAM_WORK_ORDERS_V) and appends it to
--                        the report output
-- End of comments
PROCEDURE incomplete_eam_wo
                (p_api_version         	IN		NUMBER,
                p_init_msg_list		IN		VARCHAR2,
                p_validation_level	IN  		NUMBER,
                x_return_status		OUT NOCOPY	VARCHAR2,
                x_msg_count		OUT NOCOPY	NUMBER,
                x_msg_data		OUT NOCOPY	VARCHAR2,
                i_period_end_date 	IN 		DATE,
                i_org_id 		IN 		NUMBER,
                x_record_count          OUT NOCOPY      NUMBER,
                x_xml_doc 		IN OUT NOCOPY 	CLOB);

-- Start of comments
--	API name 	: pending_lcm_trx
--	Type		: Private
--	Function	: Generate XML data for unprocessed lcm transactions
--                        and append it to report output
--	Pre-reqs	: None
--	Parameters	:
--	IN		: p_api_version      NUMBER      Required
--                        p_init_msg_list    VARCHAR2    Required
--                        p_validation_level NUMBER      Required
--                        i_period_end_date  DATE        Required
--                        i_org_id 	     NUMBER      Required
--                        x_xml_doc          CLOB        Required
--
--	OUT		: x_return_status  VARCHAR2
--                        x_msg_count      NUMBER
--                        x_record_count   NUMBER
--                        x_xml_doc        CLOB
--                        x_msg_data       VARCHAR2
--
--	Version	        : Current version	1.0
--				Initial Creation
--
--	Notes		: This Procedure is called by generateXML procedure.
--                        The procedure generates XML data for unprocessed lcm
--                        transactions (CST_LC_ADJ_INTERFACE) and appends it to
--                        the report output
-- End of comments
PROCEDURE pending_lcm_trx
          (p_api_version        IN		NUMBER,
          p_init_msg_list	IN		VARCHAR2,
          p_validation_level	IN  		NUMBER,
          x_return_status	OUT NOCOPY	VARCHAR2,
          x_msg_count		OUT NOCOPY	NUMBER,
          x_msg_data		OUT NOCOPY	VARCHAR2,
          i_period_end_date 	IN 		DATE,
          i_org_id 		IN 		NUMBER,
          x_record_count        OUT NOCOPY      NUMBER,
          x_xml_doc 		IN OUT NOCOPY 	CLOB);

END CST_PendingTxnsReport_PVT;


/
