--------------------------------------------------------
--  DDL for Package Body EGO_UTIL_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_UTIL_PK" AS
/* $Header: EGOUTILB.pls 120.0.12010000.1 2009/05/19 22:30:45 chulhale noship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EGO_UTIL_PK';

-- ********************** Publication Framework
  PROCEDURE put_fnd_stack_msg (
			p_appln_short_name 	IN VARCHAR2,
			p_message 		IN VARCHAR2,
 			p_token       IN EGO_UTIL_PK.token_tbl default EGO_UTIL_PK.G_MISS_TOKEN_TBL) is

    i 	number;

  BEGIN
    -- First set the message for FND's message stack

    fnd_message.set_name(p_appln_short_name, p_message);

    -- set the token if any
    --
    i := p_token.first;
    while i is not null
    loop
      fnd_message.set_token(p_token(i).token_name, p_token(i).token_value);
      i := p_token.next(i);
    end loop;
    fnd_msg_pub.add;

  END put_fnd_stack_msg;


  PROCEDURE count_and_get ( p_msg_count  OUT NOCOPY NUMBER,
			  p_msg_data     OUT NOCOPY VARCHAR2 ) is
  BEGIN

    fnd_msg_pub.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

  END count_and_get;

-- ********************** Publication Framework

END EGO_UTIL_PK;


/
