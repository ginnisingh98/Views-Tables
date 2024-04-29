--------------------------------------------------------
--  DDL for Package CTO_CONFIG_ITEM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CONFIG_ITEM_PK" AUTHID CURRENT_USER as
/* $Header: CTOCITMS.pls 120.1.12010000.2 2010/03/03 08:08:32 abhissri ship $ */

gUserID         number       ;
gLoginId        number       ;

--
-- bugfix 2301167: Added the following 2 global variables for wt/vol calculation.
-- we shouldn't calculate the wt/vol for the upper level config if lower level
-- config has errored out. For this, the following 2 globals are used.
-- 0 means success. -1 means error.
--

--Commenting these variables as part of bugfix 9223554
--gWtStatus	number := 0  ;
--gVolStatus	number := 0  ;

--Bugfix 9223554
type g_wt_vol_tbl_type is table of number index by binary_integer;
g_wt_tbl g_wt_vol_tbl_type;
g_vol_tbl g_wt_vol_tbl_type;


type smc_rec is record (
     item_id    oe_order_lines.inventory_item_id%type,
     sequence_id oe_order_lines.component_sequence_id%type,
     quantity   oe_order_lines.ordered_quantity%type ,
     check_atp  bom_explosions.check_atp%type
  );

type SmcTab is table of smc_rec index by binary_integer;


/*---------------------------------------------------------------------+
   Name        : create_item

   Description : This function creates a new inventory_item for the
                 ordered configuration. It also validates the setup
                 and profile options. It generates new item number
                 and then stores the item in mtl_system_items.

   Returns     :  TRUE - If the function completes succesfully
                  FALSE - If the function completes with error

                  Inventory_item_id of the newly generated item is
                  returned in pConfigId
+---------------------------------------------------------------------*/
FUNCTION Create_Item(
        pModelId        in      number,
        pLineId         in      number,
        pConfigId       in out NOCOPY     number,  /* NOCOPY Project */
	xMsgCount	out  NOCOPY   number,
        xMsgData        out NOCOPY    varchar2,
        p_mode          in     varchar2 default 'AUTOCONFIG' )
RETURN integer;


/*---------------------------------------------------------------------+
   Name        : create_item_data

   Description : This function populates the additional item data
                 for the newly created configuration item.
                 All necessary inventory and cost tables are populated

   Returns     :  TRUE  - If the function completes succesfully
                  FALSE - If the function completes with error

+----------------------------------------------------------------------*/
FUNCTION Create_Item_Data(
        pModelId         in     number,
        pConfigId        in     number,
        pLineId          in     number,
        p_mode          in     varchar2 default 'AUTOCONFIG' )
return integer;


/*---------------------------------------------------------------------+
   Name        : link_item

   Description : This function links a newly created or a matching
                 config item to the order line. It calls OE's
                 process_order API to insert config line in oe_order_lines

   Returns     :  TRUE  - If the function completes succesfully
                  FALSE - If the function completes with error

+----------------------------------------------------------------------*/
FUNCTION link_item(
         pOrgId          in     number   ,
         pModelId        in     number   ,
         pConfigId       in     number   ,
         pLineId         in     number   ,
         xMsgCount	 out NOCOPY    number,
         xMsgData        out NOCOPY   varchar2)
RETURN integer;


function delink_item (
         pModelLineId          in     number    ,
	 pConfigId        in     number    ,
         xErrorMessage    out NOCOPY    varchar2  ,
         xMessageName     out NOCOPY   varchar2  ,
         xTableName       out NOCOPY   varchar2  )
return integer;

function  Get_Mandatory_Components(
         p_ship_set            in           MRP_ATP_PUB.ATP_Rec_Typ,
	 p_organization_id     in           number default null,
	 p_inventory_item_id   in           number default null,
         x_smc_rec             out NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
         xErrorMessage         out NOCOPY         varchar2,
         xMessageName          out NOCOPY         varchar2,
         xTableName            out NOCOPY         varchar2  )
return integer;

function evaluate_order( p_atp_flag mtl_system_items.atp_flag%type
                       , p_atp_comp mtl_system_items.atp_components_flag%type
                       , p_item_type mtl_system_items.bom_item_type%type )
return number ;

FUNCTION chk_model_in_bcod(
                            pLineId in number)
return integer;

-- begin bugfix 1811007 : added new procedure ato_weight_volume
PROCEDURE ato_weight_volume(
                p_ato_line_id   IN      NUMBER,
                p_orgn_id       IN      NUMBER,
                weight_uom      IN OUT NOCOPY  VARCHAR2, /* NOCOPY Project */
                weight          OUT NOCOPY     NUMBER,
                volume_uom      IN OUT NOCOPY  VARCHAR2, /* NOCOPY Project */
                volume          OUT NOCOPY     NUMBER,
                status          IN OUT NOCOPY  NUMBER,
		pConfigId       IN      NUMBER); ----3737772 (FP 3473737)

-- end bugfix 1811007



function get_attribute_control( p_attribute_name varchar2)
return number;


function evaluate_atp_attributes( p_atp_flag in mtl_system_items_b.atp_flag%type
                      , p_atp_components_flag in mtl_system_items_b.atp_components_flag%type )
return char ;


function get_atp_flag
return char ;


end CTO_CONFIG_ITEM_PK;


/
