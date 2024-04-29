--------------------------------------------------------
--  DDL for Package EGO_UTIL_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_UTIL_PK" AUTHID CURRENT_USER AS
/* $Header: EGOUTILS.pls 120.0.12010000.1 2009/05/19 22:29:45 chulhale noship $ */

--************************* Publication Framwork
  TYPE token_rec is record (
			token_name 	varchar2(30),
			token_value 	varchar2(2000));


  TYPE token_tbl is table of token_rec index by binary_integer;

  G_MISS_TOKEN_TBL token_tbl;
--************************* Publication Framwork

--*************** Publicatoin Framework
PROCEDURE put_fnd_stack_msg  ( p_appln_short_name 	IN VARCHAR2,
			  p_message 		IN VARCHAR2,
			  p_token		IN EGO_UTIL_PK.token_tbl  default EGO_UTIL_PK.G_MISS_TOKEN_TBL);

PROCEDURE count_and_get ( p_msg_count  OUT NOCOPY NUMBER,
			    p_msg_data   OUT NOCOPY VARCHAR2 );

--*************** Publicatoin Framework

END EGO_UTIL_PK;


/
