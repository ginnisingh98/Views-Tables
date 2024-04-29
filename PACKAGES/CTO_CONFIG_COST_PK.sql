--------------------------------------------------------
--  DDL for Package CTO_CONFIG_COST_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CONFIG_COST_PK" AUTHID CURRENT_USER as
/* $Header: CTOCSTRS.pls 115.13 2003/11/12 03:36:53 ksarkar ship $ */

gUserID         number       ;
gLoginId        number       ;

FUNCTION Cost_Rollup_ML(pTopAtoLineId	in	number,
			x_msg_count	out NOCOPY number,
			x_msg_data	out NOCOPY varchar2)
RETURN integer;


FUNCTION Cost_Roll_Up_ML( p_cfg_itm_tbl   in     CTO_COST_ROLLUP_CONC_PK.t_cfg_item
                       , x_msg_count     out     NOCOPY number
                       , x_msg_data      out     NOCOPY varchar2
 			)
RETURN integer;


end CTO_CONFIG_COST_PK;

 

/
