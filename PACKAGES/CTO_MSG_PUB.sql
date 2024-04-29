--------------------------------------------------------
--  DDL for Package CTO_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_MSG_PUB" AUTHID CURRENT_USER as
/* $Header: CTOUMSGS.pls 120.2 2006/03/17 12:07:08 rekannan noship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOUMSGS.pls
|
|DESCRIPTION : Contains APIs to :
|		control the error message handling
|
|HISTORY     : Created on 18-JAN-2002  by Shashi Bhaskaran
|              Modified   25-MAR-2002  by Shashi Bhaskaran
|                         Added p_token as a new argument to cto_message to
|                         handle tokens.
|
+-----------------------------------------------------------------------------*/

  -- Modified by Renga Kannnan on 03/17/06
  -- Increased the varchar2 length form token_value from 250 to 2000
  -- Bug fix for bug 5086585

  TYPE token_rec is record (
			token_name 	varchar2(30),
			token_value 	varchar2(2000));


  TYPE token_tbl is table of token_rec index by binary_integer;

  G_MISS_TOKEN_TBL token_tbl;

  PROCEDURE cto_message ( p_appln_short_name 	IN VARCHAR2,
			  p_message 		IN VARCHAR2,
			  p_token		IN CTO_MSG_PUB.token_tbl default CTO_MSG_PUB.G_MISS_TOKEN_TBL);


  PROCEDURE count_and_get ( p_msg_count  OUT NOCOPY NUMBER,
			    p_msg_data   OUT NOCOPY VARCHAR2 );


END CTO_MSG_PUB;

 

/
