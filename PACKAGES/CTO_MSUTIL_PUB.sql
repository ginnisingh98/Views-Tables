--------------------------------------------------------
--  DDL for Package CTO_MSUTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_MSUTIL_PUB" AUTHID CURRENT_USER as
/* $Header: CTOMSUTS.pls 120.4.12010000.2 2009/03/11 12:46:56 rvalsan ship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOMSUTS.pls
|
|DESCRIPTION : Contains modules to :
|		1. Populate temporary tables bom_cto_order_lines and
|		bom_cto_src_orgs, used for intermediate CTO processing
|		2. Update these tables with the config_item_id
|		3. Copy sourcing rule assignments from model to config item
|
|HISTORY     : Created on 04-OCT-2003  by Sushant Sawant
|
|              Modified on 15-Sep-2005 by Renga Kannan
|                Added a new procedure get_master_orgs to get the
|                msater organizations where the config items will be enabled
|                This is done as part of ATG performance fix project for R12
+-----------------------------------------------------------------------------*/







 TYPE NUMTAB is TABLE of number(10) index by binary_integer;

 TYPE SOURCING_INFO is RECORD
 (
   source_organization_id NUMTAB ,
   sourcing_rule_id       NUMTAB ,
   source_type            NUMTAB ,
   rank                   NUMTAB ,
   assignment_id          NUMTAB ,
   assignment_type        NUMTAB
 );


TYPE Org_list IS TABLE OF NUMBER index by BINARY_INTEGER;

--Bugfix 8305535
type cfg_tbl is table of number index by binary_integer;
cfg_tbl_var cfg_tbl;
--Bugfix 8305535

-- rkaza. 11/03/2005. bug 4524248.
bom_batch_id number := 0;



/**************************************************************************
   Procedure:   get_other_orgs
   Parameters:  pModelLineId    IN      Model Line id
                xOrgLst         OUT NOCOPY     CTO_MSUTIL_PUB.Org_list,
                x_return_status OUT NOCOPY    Return Status
                x_msg_count     OUT NOCOPY    Msg Count
                x_msg_data      OUT NOCOPY    Msg data

   Description:
*****************************************************************************/


Procedure get_other_orgs (
        pModelLineId    IN      NUMBER,
	p_mode 		IN 	varchar2 default 'ACC',
        xOrgLst         OUT NOCOPY     CTO_MSUTIL_PUB.Org_list,
        x_return_status OUT NOCOPY     VARCHAR2,
        x_msg_count     OUT NOCOPY     NUMBER,
        x_msg_data      OUT NOCOPY     VARCHAR2
        ) ;





/*--------------------------------------------------------------------------+
This function identifies the model items for which configuration items need
to be created and populates the temporary table bom_cto_src_orgs with all the
organizations that each configuration item needs to be created in.
+-------------------------------------------------------------------------*/
FUNCTION Populate_Src_Orgs( pTopAtoLineId in number,
				x_return_status	OUT NOCOPY varchar2,
				x_msg_count	OUT NOCOPY number,
				x_msg_data	OUT NOCOPY varchar2)
RETURN integer;


/*--------------------------------------------------------------------------+
This function identifies the model items for which configuration items need
to be created and populates the temporary table bom_cto_src_orgs with all the
organizations that each configuration item needs to be created in.
It is called by the upgrade program.
+-------------------------------------------------------------------------*/
FUNCTION Populate_Src_Orgs_Upg(pTopAtoLineId in number,
				x_return_status	OUT	NOCOPY varchar2,
				x_msg_count	OUT	NOCOPY number,
				x_msg_data	OUT	NOCOPY varchar2)
RETURN integer;



/*--------------------------------------------------------------------------+
This function populates the table bom_cto_src_orgs with all the organizations
in which a configuration item needs to be created.
The organizations include all potential sourcing orgs, receiving orgs,
OE validation org and PO validation org.
The line_id, rcv_org_id, organization_id combination is unique.
It is called by Populate_Src_Orgs.
+-------------------------------------------------------------------------*/
FUNCTION Get_All_Item_Orgs( pLineId in number,
				pModelItemId in number,
				pRcvOrgId  in number,
				x_return_status	OUT NOCOPY varchar2,
				x_msg_count	OUT NOCOPY number,
				x_msg_data	OUT NOCOPY varchar2,
                                p_mode          in      varchar2 default 'AUTOCONFIG',
				p_config_item_id in number default null )

RETURN integer;


PROCEDURE insert_val_into_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
                    , p_t_org_list            in CTO_MSUTIL_PUB.org_list
		    , p_config_item_id in number default null );


procedure insert_all_into_bcso( p_top_ato_line_id       in NUMBER
                    , p_model_line_id in NUMBER
                    , p_model_item_id in NUMBER
		    , p_config_item_id in number default null) ;

PROCEDURE query_sourcing_org_ms(
  p_inventory_item_id    NUMBER
, p_organization_id      NUMBER
, p_sourcing_rule_exists OUT NOCOPY varchar2
, p_source_type          OUT NOCOPY NUMBER    -- Added by Renga Kannan on 08/21/01
, p_t_sourcing_info      OUT NOCOPY SOURCING_INFO
, x_exp_error_code       OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY varchar2
) ;

PROCEDURE initialize_assignment_set ( x_return_status OUT NOCOPY varchar2 );


PROCEDURE Create_Sourcing_Rules(pModelItemId    in      number,
                                pConfigId       in      number,
                                pRcvOrgId       in      number,
                                x_return_status OUT     NOCOPY varchar2,
                                x_msg_count     OUT     NOCOPY number,
                                x_msg_data      OUT     NOCOPY varchar2,
                                p_mode          in      varchar2 default 'AUTOCONFIG' );


PROCEDURE Create_TYPE3_Sourcing_Rules(pModelItemId      in      number,
                                pConfigId       in      number,
                                pRcvOrgId       in      number,
                                x_return_status OUT     NOCOPY varchar2,
                                x_msg_count     OUT     NOCOPY number,
                                x_msg_data      OUT     NOCOPY varchar2,
                                p_mode          in      varchar2 default 'AUTOCONFIG' );



--- Added by Renga Kannan on 15-Sep-2005
--- Added for R12 ATG Performance Project


/*--------------------------------------------------------------------------+
This procedure will get the model line id as input to give the list of
master orgs where the item needs to be enabled.
This will look the bcso tables to identify the list of orgs where the config
item needs to be enabled due to sourcing and derive the master orgs for these organization
and return them in pl/sql record struct.
+-------------------------------------------------------------------------*/

PROCEDURE Get_Master_Orgs(
			  p_model_line_id       IN  Number,
			  x_orgs_list           OUT NOCOPY CTO_MSUTIL_PUB.org_list,
			  x_msg_count           OUT NOCOPY Number,
			  x_msg_data            OUT NOCOPY varchar2,
			  x_return_status       OUT NOCOPY varchar2);





-- rkaza. 11/03/2005. 11/03/2005. bug 4524248
-- bom structure import enhancements
-- Start of comments
-- API name : get_bom_batch_id
-- Type	    : Public
-- Pre-reqs : wrapper around bom_import_pub.get_batchid
-- Function : Returns a new batch id from its sequence.
-- Parameters:
-- IN	    : None
-- Version  :
--	      Initial version 	115.1
-- End of comment

Procedure set_bom_batch_id(x_return_status	OUT	NOCOPY varchar2);

-- Added by Renga Kannan 03/30/06
-- This is a wrapper API to call PLM team's to sync up item media index
-- With out this sync up the item cannot be searched in Simple item search page
-- This is fixed for bug 4656048
Procedure syncup_item_media_index;


-- Added by Renga Kannan on 04/28/06
-- Utility API to Switch CONTEXT TO ORDER LINE CONTEXT
-- For Bug Fix 5122923

Procedure Switch_to_oe_Context(
                         p_oe_org_id    IN               Number,
			 x_current_mode  OUT NOCOPY       Varchar2,
			 x_current_org   OUT NOCOPY       Number,
			 x_context_switch_flag OUT NOCOPY Varchar2);

-- Added by Renga Kannan on 04/28/06
-- For bug fix 5122923

Procedure Switch_context_back(
                              p_old_mode  IN  Varchar2,
			      p_old_org   IN  varchar2);

--Bug 8305535
Procedure Raise_event_for_seibel;

END CTO_MSUTIL_PUB;

/
