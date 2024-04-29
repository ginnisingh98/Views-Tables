--------------------------------------------------------
--  DDL for Package BOMPMCFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPMCFG" AUTHID CURRENT_USER as
/* $Header: BOMMCFGS.pls 115.1 99/07/16 05:13:36 porting sh $ */

function atodupl_check(
	model_line_id  number,
	sch_sesion_id  number,
	sch_grp_id     number,
        error_message   out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2 /* 30 bytes to hold returned name */
	)
return integer;

function insert_mtl_dem_interface (
	configuration_item_id	in	number,/* Item ID of Configuration */
	org_id		in      number,    /* Org id of the config item */
	sch_session_id  in      number,   /* Session Id passed in by form/OI */
	sch_grp_id      in 	number,   /* Schedule Group id */
	model_line_id 	in 	number,   /* Model line id */
	model_detail_id in 	number,	  /* Model line detail id */
	uom_code	in	varchar2,
	line_qty	in	number,
	order_number	in	number,
	order_type	in 	varchar2,
        error_message   out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2 /* 30 bytes to hold returned name */
	)
return integer;					/* 1 = OK
						   0 = Error */
function existing_dupl_match (
        error_message   out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2, /* 30 bytes to hold returned name */
        table_name      out     VARCHAR2  /* 30 bytes to hold returned tbl */
	)
return integer;					/* 1 = OK
						   0 = Error */
function can_configurations(
	prg_appid in number,
	prg_id in number,
	req_id in number,
	user_id in number,
	login_id in number,
	error_message out  varchar2,
	message_name  out  varchar2,
	table_name    out  varchar2
	)
return integer;

end BOMPMCFG;

 

/
