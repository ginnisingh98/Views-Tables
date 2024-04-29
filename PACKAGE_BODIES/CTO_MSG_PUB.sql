--------------------------------------------------------
--  DDL for Package Body CTO_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_MSG_PUB" as
/* $Header: CTOUMSGB.pls 120.1 2005/06/02 12:55:40 appldev  $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOUMSGB.pls
|
|DESCRIPTION : Contains APIs to :
|		control the error message handling
|
|HISTORY     : Created on 18-JAN-2002  by Shashi Bhaskaran
|              Modified   25-MAR-2002  by Shashi Bhaskaran
|                         Added p_token as a new argument to cto_message to
|                         handle tokens.
|
|
+-----------------------------------------------------------------------------*/



  PROCEDURE cto_message (
			p_appln_short_name 	IN VARCHAR2,
			p_message 		IN VARCHAR2,
 			p_token                 IN CTO_MSG_PUB.token_tbl default CTO_MSG_PUB.G_MISS_TOKEN_TBL) is

    i 	number;

  BEGIN

    --
    -- First set the message for FND's message stack
    --

    fnd_message.set_name(p_appln_short_name, p_message);

    --
    -- set the token if any
    --
    i := p_token.first;

    --oe_debug_pub.add ('p_token(1).token_name  = '||p_token(1).token_name);
    --oe_debug_pub.add ('p_token(1).token_value = '||p_token(1).token_value);

    while i is not null
    loop
        --oe_debug_pub.add ('p_token('||i||').token_name  = '||p_token(i).token_name);
        --oe_debug_pub.add ('p_token('||i||').token_value = '||p_token(i).token_value);

	fnd_message.set_token(p_token(i).token_name, p_token(i).token_value);
	i := p_token.next(i);
    end loop;
    fnd_msg_pub.add;




    --
    -- We need to do the same to put the details in OM's message stack
    --

    fnd_message.set_name(p_appln_short_name, p_message);


    --
    -- set the token if any
    --

    i := p_token.first;

    while i is not null
    loop
        --oe_debug_pub.add ('p_token('||i||').token_name  = '||p_token(i).token_name);
        --oe_debug_pub.add ('p_token('||i||').token_value = '||p_token(i).token_value);

        fnd_message.set_token(p_token(i).token_name,p_token(i).token_value);
        i := p_token.next(i);
    end loop;
    oe_msg_pub.add;

  END cto_message;




  PROCEDURE count_and_get ( p_msg_count  OUT NOCOPY NUMBER,
			  p_msg_data     OUT NOCOPY VARCHAR2 ) is
  BEGIN

    fnd_msg_pub.Count_And_Get (p_count => p_msg_count,
        		       p_data  => p_msg_data);
    oe_msg_pub.Count_And_Get(p_count=> p_msg_count,
                             p_data => p_msg_data);

  END count_and_get;


END CTO_MSG_PUB;

/
