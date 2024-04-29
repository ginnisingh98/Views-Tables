--------------------------------------------------------
--  DDL for Package CTO_GOP_INTERFACE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_GOP_INTERFACE_PK" AUTHID CURRENT_USER as
/* $Header: CTOGOPIS.pls 115.2 2004/02/24 01:24:35 kkonada noship $*/
 /*----------------------------------------------------------------------------+
| Copyright (c) 2003 Oracle Corporation    RedwoodShores, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOGOPIS.pls
|DESCRIPTION : Contains :
|		Wrapper which wil be called by ATP team or (GOP)
|               from patchset_J during atp inquiry or scheduling
|               This will provide match information or r-use configuration
|               information and option specific sourcing org list
|HISTORY     :
|		09-05-2003  Created By Kiran Konada
|                            Initial checkin
|
|             02-23-2004   Kiran Konada
|                          bugfix 3259017
|-----------------------------------------------------------------------------------
*/
PROCEDURE CTO_GOP_WRAPPER_API (
	p_Action		IN		VARCHAR2,
	p_Source		IN		VARCHAR2,
	p_match_rec_of_tab IN OUT NOCOPY       CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
	X_oss_orgs_list	OUT       NOCOPY	CTO_OSS_SOURCE_PK.Oss_orgs_list_rec_type,
	x_return_status	OUT	  NOCOPY 		VARCHAR2,
	X_msg_count	OUT	  NOCOPY		number,
	X_msg_data	OUT	  NOCOPY		Varchar2
 );
END CTO_GOP_INTERFACE_PK;

 

/
