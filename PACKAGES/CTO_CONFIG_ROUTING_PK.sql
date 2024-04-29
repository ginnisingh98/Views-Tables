--------------------------------------------------------
--  DDL for Package CTO_CONFIG_ROUTING_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CONFIG_ROUTING_PK" AUTHID CURRENT_USER as
/* $Header: CTOCRTGS.pls 120.1 2005/06/21 16:20:12 appldev ship $ */

gUserID         number       ;
gLoginId        number       ;


function check_routing (
        pItemId        in      number,
        pOrgId         in      number,
        xRtgId         out NOCOPY     number,
        xRtgType       out NOCOPY    number)
return integer;

function create_routing_ml (
         pModelId        in       number,
         pConfigId       in       number,
         pCfgBillId      in       number,
         pOrgId          in       number,
         pLineId         in       number,
         pFlowCalc       in       number,
         xRtgID          out NOCOPY      number,
         xErrorMessage   out NOCOPY     varchar2,
         xMessageName    out NOCOPY     varchar2,
         xTableName      out NOCOPY     varchar2)
return integer;


end cto_config_routing_pk;

 

/
