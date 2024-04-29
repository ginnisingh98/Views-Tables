--------------------------------------------------------
--  DDL for Package CTO_UPDATE_ITEMS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_UPDATE_ITEMS_PK" AUTHID CURRENT_USER as
/* $Header: CTOUITMS.pls 120.0.12010000.2 2010/11/11 11:55:30 abhissri ship $ */

/*-----------------------------------------------------------------------------
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                        All rights reserved.
|                        Oracle Manufacturing
|-----------------------------------------------------------------------------
|
| File name   : CTOITSCS.pls
| Description :
|
| History     : Created On : 11-OCT-2003 by Sajani Sheth
|
+------------------------------------------------------------------------------*/
gDebugLevel NUMBER :=  to_number(nvl(FND_PROFILE.value('ONT_DEBUG_LEVEL'),0));


PROCEDURE Update_Items_And_Sourcing(
	p_changed_src IN varchar2,
	p_cat_id IN number,
	p_upgrade_mode IN Number,
	--Bugfix 10240482: Adding new parameter p_max_seq
	p_max_seq IN number,
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData  OUT NOCOPY varchar2);


PROCEDURE Update_Bcso(
	p_ato_line_id IN number,
	l_return_status OUT NOCOPY varchar2,
	l_msg_count OUT NOCOPY number,
	l_msg_data OUT NOCOPY varchar2);


PROCEDURE Update_Acc_Items(
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2);

function get_attribute_control( p_attribute_name in varchar2)
return number;

function get_cost_group( pOrgId  in number,
                         pLineID in number)
return integer;


PROCEDURE Update_Item_Data(
	p_cat_id IN number,
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2);


PROCEDURE Update_Pc_Items(
	xReturnStatus OUT NOCOPY varchar2,
	xMsgCount OUT NOCOPY number,
	xMsgData OUT NOCOPY varchar2);


PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0);


end CTO_UPDATE_ITEMS_PK;

/
