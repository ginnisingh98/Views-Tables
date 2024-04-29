--------------------------------------------------------
--  DDL for Package Body BOMPCEDC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCEDC" as
/* $Header: BOMCEDCB.pls 115.0 99/07/16 05:11:00 porting ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : BOMCEDCB.pls						      |
| DESCRIPTION :								      |
|               This file creates packaged functions that check for 	      |
|               exsisting matching configurations.			      |
|									      |
|		BOMPCEDC.bomfcdec_ch_du_ext_config - Searches for a matching  |
|		configuration in the Item/BOM/Rtg tables.		      |
|               							      |
|               It is called by BOMPCHDU.bomfchdu_check_dupl_config.	      |
|									      |
| HISTORY     :  							      |
|               2/21/94       Manish Modi 				      |
|                             Transfered the code from BOMPCHDU.sql	      |
|									      |
*============================================================================*/

function bomfcdec_ch_du_ext_config (
        demand_id               number,
        config_item_id  out     number,
        error_message   out     VARCHAR2,
        message_name    out     VARCHAR2,
        table_name      out     VARCHAR2
        )
return integer
is
begin
	/*
	** This function can be replaced by custom code that will search
        ** for an existing configuration that meets the requirements
	** specified by the demand for a new configuration.
	** This function should search through existing items, bills
	** and routings to find a matching configuration item.
	*/
	config_item_id := NULL;
	return (1);
end;

end BOMPCEDC;

/
