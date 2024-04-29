--------------------------------------------------------
--  DDL for Package EAM_WORKORDERBILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDERBILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWOBS.pls 115.3 2003/01/31 22:08:49 lllin noship $ */

-- Start of comments
--	API name 	: insert_AR_Interface
--	Type		: Private.
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

Type WO_Billing_Rec_Type is RECORD
(
 organization_id	number,
 customer_id		number,
 bill_to_address_id	number,
 wip_entity_id		number,
 operation_seq_num	number,
 inventory_item_id	number,
 resource_id		number,
 billed_inventory_item_id	number,
 billed_uom_code 	varchar2(3),
 billed_quantity	number,
 price_list_header_id	number,
 cost_type_id		number,
 cost_or_listprice	number,
 costplus_percentage	number,
 billed_amount		number,
 invoice_trx_number	number,
 invoice_line_number	number,
 currency_code		varchar2(15),
 conversion_rate	number,
 conversion_type_code	varchar2(30),
 conversion_rate_date	date,
 project_id		number,
 task_id		number,
 work_request_id	number,
 pa_event_id		number,
 billing_basis		number,
 billing_method		number
);


Type WO_Billing_RA_Rec_Type is RECORD
(
 wip_entity_id		varchar2(30),
 wip_entity_name	varchar2(30),
 invoice_num		varchar2(30),
 line_num		varchar2(30),
 work_request		varchar2(30),
 project_id		varchar2(30),
 task_id		varchar2(30),
 currency_code		varchar2(15),
 billed_amount		number,
 customer_id		number,
 bill_to_address	number,
 conversion_type	varchar2(30),
 conversion_date	date,
 conversion_rate	number,
 quantity		number,
 billed_inventory_item_id	number,
 uom_code		varchar2(3),
 org_id			number,
 party_id		number,
 unit_selling_price 	number
);

Type WO_Billing_PA_Event_Rec_Type is RECORD
(
 task_id		number,
 event_num		number,
 project_id		number,
 organization_id	number,
 event_id		number,
 wip_entity_id		varchar2(240),
 wip_entity_name	varchar2(240),
 work_request_id	varchar2(240),
 service_request_id	varchar2(240),
 billing_currency_code 	varchar2(15),
 bill_trans_bill_amount number,
 bill_trans_rev_amount	number
);


PROCEDURE insert_AR_Interface
( 	p_api_version           	IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL	,
	x_return_status		OUT NOCOPY	VARCHAR2		  	,
	x_msg_count			OUT NOCOPY	NUMBER				,
	x_msg_data			OUT NOCOPY	VARCHAR2			,
	p_ra_line			IN	 WO_Billing_RA_Rec_Type
);


PROCEDURE insert_WOB_Table
(       p_api_version                   IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_validation_level              IN      NUMBER  :=
                                                FND_API.G_VALID_LEVEL_FULL      ,
        x_return_status         OUT NOCOPY    VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY    NUMBER                          ,
        x_msg_data                      OUT NOCOPY    VARCHAR2                        ,
        p_wob_rec                       IN      WO_Billing_Rec_Type
);


/*

PROCEDURE insert_PAEvent_Table
(       p_api_version                   IN      NUMBER
,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE
,
        p_validation_level              IN      NUMBER  :=
                                                FND_API.G_VALID_LEVEL_FULL
,
        x_return_status         OUT NOCOPY    VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY     NUMBER
,
        x_msg_data                      OUT NOCOPY    VARCHAR2
,
        p_pa_rec                       IN      WO_Billing_PA_Event_Rec_Type
);

*/

END;



 

/
