--------------------------------------------------------
--  DDL for Package ONT_PRT_MARGIN_ANA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_PRT_MARGIN_ANA_PKG" AUTHID CURRENT_USER as
/* $Header: ONTCSMAS.pls 120.0 2005/05/31 23:20:26 appldev noship $ */
	PROCEDURE BUILD_ONT_PRT_MARGIN_TABLE;

	FUNCTION GET_TOTAL_MARGIN (IN_PERIOD IN VARCHAR2) return NUMBER;
		pragma restrict_references (GET_TOTAL_MARGIN, WNDS, RNPS, WNPS);

	FUNCTION GET_TOTAL_SALES (IN_PERIOD IN VARCHAR2) return NUMBER;
		pragma restrict_references (GET_TOTAL_SALES, WNDS, RNPS, WNPS);

	FUNCTION GET_ITEM_NUMBER (in_ITEM_ID in number) return VARCHAR2;
		pragma restrict_references (GET_ITEM_NUMBER, WNDS, RNPS, WNPS);

end ONT_PRT_MARGIN_ANA_PKG;

 

/
