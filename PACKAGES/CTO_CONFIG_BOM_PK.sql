--------------------------------------------------------
--  DDL for Package CTO_CONFIG_BOM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CONFIG_BOM_PK" AUTHID CURRENT_USER as
/* $Header: CTOCBOMS.pls 120.1 2005/06/21 16:10:33 appldev ship $ */

gUserID         number       ;
gLoginId        number       ;


TYPE DROPPED_ITEM_TYPE is record (
                            PROCESS              varchar2(100)
                           ,LINE_ID              number
                           ,SALES_ORDER_NUM      number
                           ,ERROR_MESSAGE        varchar2(1000)
                           ,TOP_MODEL_NAME       varchar2(1000)
                           ,TOP_MODEL_LINE_NUM   varchar2(100)
                           ,TOP_CONFIG_NAME      varchar2(1000)
                           ,TOP_CONFIG_LINE_NUM  varchar2(100)
                           ,PROBLEM_MODEL        varchar2(100)
                           ,PROBLEM_MODEL_LINE_NUM varchar2(100)
                           ,PROBLEM_CONFIG        varchar2(1000)
                           ,ERROR_ORG             varchar2(100)
                           ,ERROR_ORG_ID          number
                           ,REQUEST_ID            varchar2(100)
                           ,MFG_REL_DATE          DATE
                           , NOTIFY_USER          varchar2(1000) ) ;


TYPE t_dropped_item_type  IS TABLE OF dropped_item_type INDEX BY BINARY_INTEGER;


g_t_dropped_item_type   t_dropped_item_type ;




/* Add a new global variable as a part of bugfix 2524562
Initialized to 1 . Set to 0 inside package body if items
are dropped from config bill. bmccci ends with warning
if gDropItem = 0 */

gDropItem	number	     := 1;

/* Added a new global variable as part of bugfix 2840801.
   This variable has a default value of 'N'. This will be
   set to 'Y' if any optional components are 'dropped' while
   creating bill for config item (in CTOCBOMB.pls)
   The var will be reset in bmccci.opp */

gApplyHold	varchar2(1)  := 'N';




function get_dit_count
return number ;



procedure get_dropped_components( x_t_dropped_items out NOCOPY t_dropped_item_type ) ;



procedure reset_dropped_components ;

/*-----------------------------------------------------------------+

  These "_ml" functions are temporary for the testing of multilevel.
  After system testing, they will be renamed to the names of the
  original modules (without "_ml").

+------------------------------------------------------------------*/
function create_bom_ml(
        pModelId        in       number,
        pConfigId       in       number,
        pOrgId          in       number,
        pLineId         in       number,
        xBillId         out NOCOPY     number,
        xErrorMessage   out NOCOPY    varchar2 ,
        xMessageName    out NOCOPY    varchar2 ,
        xTableName      out NOCOPY    varchar2 )
return integer;

function create_bom_data_ml (
    pModelId        in       number,
    pConfigId       in       number,
    pOrgId          in       number,
    pConfigBillId   in       number,
    xErrorMessage   out NOCOPY      VARCHAR2,
    xMessageName    out NOCOPY      VARCHAR2,
    xTableName      out NOCOPY      VARCHAR2)
return integer;

function get_model_lead_time
(       pModelId in number,
        pOrgId   in number,
        pQty     in number,
        pLeadTime out NOCOPY number,
        pErrBuf  out NOCOPY varchar2
)
return integer;


-- Start 2307936

function inherit_op_seq_ml (
  pLineId        in   oe_order_lines.line_id%TYPE := NULL,
  pOrgId         in   oe_order_lines.ship_from_org_id%TYPE := NULL,
  PModelId	 in   bom_bill_of_materials.assembly_item_id%TYPE := NULL,
  pConfigBillId  in   bom_inventory_components.bill_sequence_id%TYPE := NULL,
  xErrorMessage  out NOCOPY  VARCHAR2,
  xMessageName   out NOCOPY  VARCHAR2)
return integer;

-- End 2307936

function bmlupid_update_item_desc
(
        item_id                 NUMBER,
        org_id                  NUMBER,
        err_buf         out NOCOPY    VARCHAR2
)
return integer;


/*-------------------------------------------------------------------
  Name        : check_bom

  Description : This function checks for existence of BOM for an
                item an the specified Org.

  Requires    : Item's Inventory_item_id,
                Organization Id

  Returns     : TRUE  if the BOM exists
                FALSE if BOM does not exist.
-----------------------------------------------------------------------*/
function check_bom(
        pItemId        in      number,
        pOrgId         in      number,
        xBillID        out NOCOPY    number)
return integer;

END CTO_CONFIG_BOM_PK;

 

/
