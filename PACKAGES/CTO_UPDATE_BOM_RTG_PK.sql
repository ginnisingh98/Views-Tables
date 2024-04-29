--------------------------------------------------------
--  DDL for Package CTO_UPDATE_BOM_RTG_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_UPDATE_BOM_RTG_PK" AUTHID CURRENT_USER as
/* $Header: CTOUBOMS.pls 115.3 2004/01/22 19:45:57 ssawant noship $ */

gDebugLevel NUMBER :=  to_number(nvl(FND_PROFILE.value('ONT_DEBUG_LEVEL'),0));
gDropItem	number	     := 1;
--gApplyHold	varchar2(1)  := 'N';
G_SUB_BATCH_SIZE NUMBER := 10;

PROCEDURE Update_Boms_Rtgs(
	errbuf OUT NOCOPY varchar2,
	retcode OUT NOCOPY varchar2,
	p_seq IN number,
	p_changed_src IN varchar2);


PROCEDURE Update_In_Src_Orgs(
        pLineId         in  number, -- Current Model Line ID
        pModelId        in  number,
        pConfigId       in  number,
        pFlowCalc       in  number,
        xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2
        );


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0);


FUNCTION Update_Bom_Rtg_Loop(
        pModelId        in       number,
        pConfigId       in       number,
        pOrgId          in       number,
        pLineId         in       number,
	pLeadTime       in       number,
	pFlowCalc	in	 number,
        xBillId         out NOCOPY   number,
    	xRtgId	    	out NOCOPY   number,
        xErrorMessage   out NOCOPY   varchar2 ,
        xMessageName    out NOCOPY   varchar2 ,
        xTableName      out NOCOPY   varchar2 )
return integer;


PROCEDURE Update_Bom_Rtg_Bulk(
	p_seq in number,
	xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2);


function get_model_lead_time
(       pModelId in number,
        pOrgId   in number,
        pQty     in number,
        pLeadTime out NOCOPY number,
        pErrBuf  out NOCOPY varchar2
)
return integer;


function inherit_op_seq_ml (
  pLineId        in   oe_order_lines.line_id%TYPE := NULL,
  pOrgId         in   oe_order_lines.ship_from_org_id%TYPE := NULL,
  PModelId	 in   bom_bill_of_materials.assembly_item_id%TYPE := NULL,
  pConfigBillId  in   bom_inventory_components.bill_sequence_id%TYPE := NULL,
  xErrorMessage  out  NOCOPY VARCHAR2,
  xMessageName   out  NOCOPY VARCHAR2)
return integer;


function bmlupid_update_item_desc
(
        item_id                 NUMBER,
        org_id                  NUMBER,
        err_buf         out   NOCOPY VARCHAR2
)
return integer;

function check_routing (
        pItemId        in      number,
        pOrgId         in      number,
        xRtgId         out     NOCOPY number,
        xRtgType       out     NOCOPY number)
return integer;

function check_bom(
        pItemId        in      number,
        pOrgId         in      number,
        xBillID        out     NOCOPY number)
return integer;

END CTO_UPDATE_BOM_RTG_PK;

 

/
