--------------------------------------------------------
--  DDL for Package BOMPCHDU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCHDU" AUTHID CURRENT_USER as
/* $Header: BOMCHDUS.pls 115.0 99/07/16 05:11:42 porting ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : BOMCHDUS.pls						      |
| DESCRIPTION :								      |
|               This file creates packaged functions that check for matching  |
|		configurations.						      |
|									      |
|		BOMPCHDU.is_base_demand_row -- Checks whether a given row in  |
|		mtl_demand has already been found to be a duplicate.	      |
|									      |
|		BOMPCHDU.bomfchdu_check_dupl_config -- Checks through each    |
|		row in mtl_demand which has been marked to be processed.      |
|		Depending on profile settings, it may call a custom function  |
|		for pre-existing configurations or use the matching function  |
|		from match and reserve.  Then, it does an in batch match on   |
|		the configurations.					      |
|									      |
|		BOMPCHDU.existing_dupl_match -- for a given demand_id, it     |
|		searches BOM ATO Configurations for a matching configuration. |
|									      |
|		BOMPCHDU.check_dupl_batch_match -- for a given demand_id, it  |
|		checks the other rows to be processed whether any has an      |
|		identical configuration.  If any of the other rows are 	      |
|		identical, their dupl_config_demand_id or dupl_config_item_id |
|		is updated accordingly.					      |
| HISTORY     :  							      |
|               06/13/93  Chung Wei Lee  Initial version		      |
|		08/16/93  Chung Wei Lee	 Added more comments		      |
|		08/23/93  Chung Wei Lee  Added codes to check dup new config  |
|		11/08/93  Randy Roupp    Added sql_stmt_num logic             |
|		11/09/93  Randy Roupp    Changed is_base_demand_row function  |
|		01/14/94  Nagaraj        Handle the case if d1.primary_uom_   |
|					 quantity is zero		      |
|               02/21/94  Manish Modi    Moved bomfcdec_ch_du_ext_config to   |
|                                        BOMPCEDC.			      |
|		11/01/95  Edward Lee	 Re-wrote package to use a matching   |
|					 function similar to the one in       |
|					 BOMPMCFG which drives off of so_lines|
|					 Also added a check for existing      |
|					 configurations in BOM ATO Configs.   |
=============================================================================*/

function is_base_demand_row(
	input_demand_id	in	number,
        error_message   out     VARCHAR2,   /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2,   /* 30 bytes to hold returned nme */
        table_name      out     VARCHAR2    /* 30 bytes to hold returned tbl */
	)
return integer;				    /*  1=Continue
						0=Already Matched */


function bomfchdu_check_dupl_config (
        error_message   out     VARCHAR2,   /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2,   /* 30 bytes to hold returned nme */
        table_name      out     VARCHAR2,   /* 30 bytes to hold returned tbl */
	nobatch		in	number	default 0
			    /* 1=only 1 line, 0=2+ lines */
        )
return integer;					/* 1 = OK
                                                   0 = Error */

function existing_dupl_match (
	input_demand_id in	number,
	dupl_item_id  	out	number,
        error_message  	out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2, /* 30 bytes to hold returned name */
        table_name      out     VARCHAR2  /* 30 bytes to hold returned tbl */
	)
return integer;					/* 1 = OK
						   0 = Error */

function check_dupl_batch_match (
	input_demand_id in	number,
	dupl_item_id  		number,
	copy_line_id	in	number,
        error_message   out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2, /* 30 bytes to hold returned name */
        table_name      out     VARCHAR2  /* 30 bytes to hold returned tbl */
	)
return integer;					/* 1 = OK
						   0 = Error */

end BOMPCHDU;

 

/
