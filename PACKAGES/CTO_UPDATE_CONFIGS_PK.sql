--------------------------------------------------------
--  DDL for Package CTO_UPDATE_CONFIGS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_UPDATE_CONFIGS_PK" AUTHID CURRENT_USER as
/* $Header: CTOUCFGS.pls 120.0.12010000.3 2012/04/05 09:45:26 abhissri ship $*/
/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOUCFGS.pls
|
|DESCRIPTION : Contains modules to :
|
|HISTORY     : Created on 9-SEP-2003  by Sajani Sheth
|
|              01/27/04    Kiran Konada
|                          bugfix 3397123
|                          Changed the signature of Update_Configs
|                          To take in new parameters
|                          p_category_set_id
|                          p_dummy3
|                           The above two parameters are NOt used in the code,
|                          they had to be in teh signature as they are in Conc
|                          program definition
|
|
+-----------------------------------------------------------------------------*/

BAC_PROGRAM_ID	NUMBER := 99;
G_BATCH_SIZE NUMBER := 100;
TYPE BCOL_TAB is TABLE of bom_cto_order_lines%rowtype index by binary_integer;
gDebugLevel NUMBER :=  to_number(nvl(FND_PROFILE.value('ONT_DEBUG_LEVEL'),0));

/***********************************************************************
This procedure is called by the Update Existing Configurations batch
progam.
***********************************************************************/
PROCEDURE update_configs
(
errbuf OUT NOCOPY varchar2,
retcode OUT NOCOPY varchar2,
p_item IN number,
p_dummy IN varchar2,
p_dummy2 IN varchar2,
p_category_set_id IN number, --bugfix 3397123
p_dummy3 IN number, --bugfix 3397123
p_cat_id IN number,
p_config_id IN number,
p_changed_src IN varchar2,
p_open_lines IN varchar2,
p_upgrade_mode In Number
);


PROCEDURE populate_all_models(
p_changed_src IN varchar2,
p_open_lines IN varchar2,
x_return_status	out NOCOPY varchar2,
x_msg_count out NOCOPY number,
x_msg_data out NOCOPY varchar2);

PROCEDURE populate_cat_models(
p_cat_id IN number,
p_changed_src IN varchar2,
p_open_lines IN varchar2,
-- bug 13876670
p_category_set_id IN NUMBER,
x_return_status	out NOCOPY varchar2,
x_msg_count out NOCOPY number,
x_msg_data out NOCOPY varchar2);

PROCEDURE populate_config(
p_changed_src IN varchar2,
p_open_lines IN varchar2,
p_config_id IN number,
x_return_status	out NOCOPY varchar2,
x_msg_count out NOCOPY number,
x_msg_data out NOCOPY varchar2);

PROCEDURE populate_bcolu_from_bac(
	p_config_id IN number,
	x_return_status out NOCOPY varchar2,
	x_msg_count out NOCOPY number,
	x_msg_data out NOCOPY varchar2);


PROCEDURE populate_child_config(
	t_bcol IN OUT NOCOPY bcol_tab,
	p_parent_index IN NUMBER,
	p_child_config_id IN NUMBER,
	x_return_status out NOCOPY varchar2,
	x_msg_count out NOCOPY number,
	x_msg_data out NOCOPY varchar2);


PROCEDURE populate_link_to_line_id(
p_bcol_tab IN OUT NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2);


PROCEDURE populate_plan_level(
p_t_bcol IN OUT NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2);


PROCEDURE populate_wip_supply_type(
p_t_bcol IN OUT NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2);


PROCEDURE populate_parent_ato(
p_t_bcol in out NOCOPY bcol_tab,
p_bcol_line_id in bom_cto_order_lines.line_id%type,
x_return_status	OUT NOCOPY varchar2);


PROCEDURE contiguous_to_sparse_bcol(
p_t_bcol in out NOCOPY bcol_tab,
x_return_status	OUT NOCOPY varchar2);


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0);


PROCEDURE Write_Config_Status(
x_return_status	out NOCOPY varchar2,
--Bugfix 13362916
x_return_code   out NOCOPY number);

--bugfix 3259017
--added no copy to out variables
Procedure update_atp_attributes(
                          p_item          IN  Number,
                          p_cat_id        IN  Number,
                          p_config_id     IN  Number,
                          x_return_status OUT NOCOPY varchar2,
                          x_msg_data      OUT NOCOPY Varchar2,
                          x_msg_count     OUT NOCOPY Number);



END CTO_UPDATE_CONFIGS_PK;

/
