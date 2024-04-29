--------------------------------------------------------
--  DDL for Package ICX_MARGIN_WEB_ANA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_MARGIN_WEB_ANA_PKG" AUTHID CURRENT_USER as
/* $Header: ICXCSMRS.pls 115.0 99/08/09 17:23:25 porting ship $ */
	procedure BUILD_ICX_CST_MARGIN_TABLE;
	function  ICX_GET_TOTAL_MARGIN (IN_PERIOD IN VARCHAR2) return NUMBER;
		pragma restrict_references (ICX_GET_TOTAL_MARGIN, WNDS, RNPS, WNPS);
	function  ICX_GET_TOTAL_SALES (IN_PERIOD IN VARCHAR2) return NUMBER;
		pragma restrict_references (ICX_GET_TOTAL_SALES, WNDS, RNPS, WNPS);
	function GET_ITEM_NUMBER (in_ITEM_ID in number) return VARCHAR2;
		pragma restrict_references (GET_ITEM_NUMBER, WNDS, RNPS, WNPS);
end ICX_MARGIN_WEB_ANA_PKG;

 

/
