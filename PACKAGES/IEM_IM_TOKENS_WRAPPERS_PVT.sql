--------------------------------------------------------
--  DDL for Package IEM_IM_TOKENS_WRAPPERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_IM_TOKENS_WRAPPERS_PVT" AUTHID CURRENT_USER as
/* $Header: iemtimws.pls 115.4 2002/12/22 01:07:34 sboorela shipped $*/
--SUBTYPE TOKEN_TABLE IS CTXSYS.CTX_DOC.TOKEN_TAB;
TYPE token_rec is RECORD(
token           varchar2(150),
weight          number);
TYPE token_tab IS TABLE OF token_rec
INDEX By BINARY_INTEGER;

FUNCTION GetTokens(p_msgid IN INTEGER, p_part IN INTEGER,
			p_flags IN INTEGER, p_link IN VARCHAR2,
			p_language IN VARCHAR2,
			p_token_tab OUT NOCOPY token_tab,
			p_errtext OUT NOCOPY VARCHAR2) RETURN INTEGER;


END IEM_IM_TOKENS_WRAPPERS_PVT;

 

/
