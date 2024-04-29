--------------------------------------------------------
--  DDL for Package QOT_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QOT_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: qotvutls.pls 120.0 2005/07/28 17:19:51 gkeshava noship $ */
-- Start of Comments
-- Package name     : QOT_UTILITY_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
	FUNCTION GET_CONTRACT_TERMS_ACCESS
	(
	 	P_QUOTE_HEADER_ID	IN	NUMBER,
		P_USER_ID		IN	NUMBER
	) RETURN VARCHAR2;

END QOT_UTILITY_PVT;

 

/
