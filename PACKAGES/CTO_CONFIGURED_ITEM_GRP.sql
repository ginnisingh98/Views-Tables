--------------------------------------------------------
--  DDL for Package CTO_CONFIGURED_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CONFIGURED_ITEM_GRP" AUTHID CURRENT_USER AS
/* $Header: CTOGCFGS.pls 115.5 2004/04/27 20:04:11 kkonada noship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    RedwoodShores, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOGCFGS.pls
|
|DESCRIPTION : Contains modules to :
|
|
|HISTORY     :
|
|	      09-05-2003   Created by KKONADA
|	      Group API to be used by other products
|	      and internally for matching
|
|             10-10-2003   KKONADA
|             Match_item_id
|             gop_index          are removed
|
|             10-21-2002   KKONADA
|             removing parameter x_match_found as
|             mutiple thsi result for multiple order lines doesnot make
|             sense
|--------------------------------------------------------------------------------
*/


TYPE number_arr_tbl_type	 IS TABLE OF number		index by binary_integer;
TYPE char1_arr_tbl_type		 IS TABLE of varchar2(1)	index by binary_integer;
TYPE char3_arr_tbl_type		 IS TABLE OF varchar2(3)	index by binary_integer;
TYPE char30_arr_tbl_type	 IS TABLE OF varchar2(30)	index by binary_integer;
TYPE char1000_arr_tbl_type	 IS TABLE of varchar2(1000)	index by binary_integer;
TYPE char2000_arr_tbl_type	 IS TABLE of varchar2(2000)	index by binary_integer;
TYPE date_arr_tbl_type           IS TABLE OF date;

TYPE CTO_MATCH_REC_TYPE IS RECORD
(
CONFIG_ITEM_ID          number_arr_tbl_type,
LINE_ID	            	number_arr_tbl_type,
LINK_TO_LINE_ID		number_arr_tbl_type,
ATO_LINE_ID		number_arr_tbl_type,
TOP_MODEL_LINE_ID	number_arr_tbl_type,
INVENTORY_ITEM_ID	number_arr_tbl_type,
COMPONENT_CODE	        char1000_arr_tbl_type,
COMPONENT_SEQUENCE_ID	number_arr_tbl_type	,
VALIDATION_ORG		number_arr_tbl_type	,
QTY_PER_PARENT_MODEL    number_arr_tbl_type	, -- ordered qty per unit ,
                                                  --CTO passes and calcuated for GOp
ORDERED_QUANTITY	number_arr_tbl_type	,--order qty passed by GOP
ORDER_QUANTITY_UOM	char3_arr_tbl_type	,
PARENT_ATO_LINE_ID	number_arr_tbl_type	,
GOP_PARENT_ATO_LINE_ID	number_arr_tbl_type	,
PERFORM_MATCH		char1_arr_tbl_type	,
PLAN_LEVEL		number_arr_tbl_type	,
BOM_ITEM_TYPE		number_arr_tbl_type	,
WIP_SUPPLY_TYPE		char30_arr_tbl_type	,
OSS_ERROR_CODE          number_arr_tbl_type	,
SHIP_FROM_ORG_ID        number_arr_tbl_type	,--3503764, to get ship_from_org_id from ATP
Attribute_1		number_arr_tbl_type	,
Attribute_2		number_arr_tbl_type	,
Attribute_3		char2000_arr_tbl_type	,
Attribute_4		char2000_arr_tbl_type	,
Attribute_5		char2000_arr_tbl_type	,
Attribute_6		date_arr_tbl_type	,
Attribute_7		date_arr_tbl_type	,
Attribute_8		date_arr_tbl_type	,
Attribute_9		number_arr_tbl_type

);

TYPE TEMP_REC_TYPE IS RECORD
(
  l_index		number,
  line_id		number,
  link_to_line_id	number,
  ato_line_id		number,
  top_model_line_id	number,
  parent_ato_line_id	number,
  gop_parent_ato_line_id number,
  plan_level		number,
  bom_item_type		number,
  wip_supply_type	number


);

TYPE TEMP_TAB_OF_REC_TYPE IS TABLE OF  TEMP_REC_TYPE INDEX BY BINARY_INTEGER ;




-- Start of comments
--	API name 	: MATCH_CONFIGURED_ITEM
--	Type		: Group
--	Function	:To match configured items
--	Pre-reqs	:1. table BOMC_TO_ORDER_LINES_TEMP
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					                Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					                 Default = FND_API.G_FALSE
--				Action                  IN    VARCHAR2(30)
-- 			        Source    		IN     VARCHAR2(30)
--		                p_cto_match_rec  	IN OUT  CTO_MATCH_REC_TYPE                         			.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--				x_match_found  		OUT      Varchar2(1)          Y/N
--				.
--	Version	: Current version	1.0
--				Changed....
--
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments
PROCEDURE MATCH_CONFIGURED_ITEM
(
	    --std parameters
	   p_api_version 	             		IN NUMBER,
	   p_init_msg_list 				IN VARCHAR2 default FND_API.G_FALSE,
	   p_commit       				IN VARCHAR2 default FND_API.G_FALSE,
	   p_validation_level                           IN NUMBER  default FND_API.G_VALID_LEVEL_FULL,
	   x_return_status 				OUT NOCOPY VARCHAR2,
	   x_msg_count     				OUT NOCOPY NUMBER,
	   x_msg_data      				OUT NOCOPY VARCHAR2,

	--program parameters
	   p_Action  		 			IN    VARCHAR2,
	   p_Source    					IN     VARCHAR2 ,

	   p_cto_match_rec  				IN OUT NOCOPY CTO_MATCH_REC_TYPE

);




END CTO_Configured_Item_GRP;

 

/
