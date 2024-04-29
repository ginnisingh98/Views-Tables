--------------------------------------------------------
--  DDL for Package BOMPCEDC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCEDC" AUTHID CURRENT_USER as
/* $Header: BOMCEDCS.pls 115.0 99/07/16 05:11:03 porting ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : BOMCEDCS.pls						      |
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
	demand_id		number,     /* Demand ID of MTL_DEMAND */
	config_item_id	out	number,	    /* Item ID of Configuration */
        error_message   out     VARCHAR2,   /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2,   /* 30 bytes to hold returned name */
        table_name      out     VARCHAR2    /* 30 bytes to hold returned tbl */
	)
return integer;					/* 1 = OK
						   0 = Error */
end BOMPCEDC;

 

/
