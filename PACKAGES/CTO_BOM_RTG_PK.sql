--------------------------------------------------------
--  DDL for Package CTO_BOM_RTG_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_BOM_RTG_PK" AUTHID CURRENT_USER as
/* $Header: CTOBMRTS.pls 115.16 2002/12/15 21:20:14 ssawant ship $ */

gUserID         number       ;
gLoginId        number       ;

/*-------------------------------------------------------------+
  Name : Create_all_boms_and_routings
         This procedure loops through all the configuration
         items in bom_cto_order_lines and calls create_in_src_orgs
         for each item.
+-------------------------------------------------------------*/

procedure create_all_boms_and_routings(
        pAtoLineId         in  number, -- top ATO line id
        pFlowCalc          in  number,
        xReturnStatus      out NOCOPY varchar2,
        xMsgCount          out NOCOPY number,
        xMsgData           out NOCOPY varchar2
        );

/*-------------------------------------------------------------+
  Name : create_in_src_orgs
         This procedure creates a config item's bom and routing
         in all of the proper sourcing orgs based on the base
         model's sourcing rules.
+-------------------------------------------------------------*/

procedure create_in_src_orgs(
        pLineId         in  number, -- Model Line ID
        pModelId        in  number,
        pConfigId       in  number,
        pFlowCalc       in  number,
        xReturnStatus   out NOCOPY varchar2,
        xMsgCount       out NOCOPY number,
        xMsgData        out NOCOPY varchar2
        );


/*-------------------------------------------------------------+
  Name : update_atp
         This function Obtains and passes the ATPable Mandatory
         components for the config bom to ATP engine. lete successfully, it
         calls re-scheduling API to reschedule order line if
         needed.
+-------------------------------------------------------------*/
function update_atp( pLineId       in   number,
                     xErrorMessage out   NOCOPY varchar2,
                     xMessageName  out   NOCOPY varchar2,
                     xTableName    out   NOCOPY varchar2)
return integer;

END CTO_BOM_RTG_PK;

 

/
