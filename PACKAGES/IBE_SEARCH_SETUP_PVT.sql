--------------------------------------------------------
--  DDL for Package IBE_SEARCH_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SEARCH_SETUP_PVT" AUTHID CURRENT_USER AS
 /* $Header: IBEVCSIS.pls 120.0.12010000.2 2015/01/05 08:57:20 amaheshw ship $ */

FUNCTION WriteToLob(param1    IN   VARCHAR2,
          		param2    IN   VARCHAR2,
				param3    IN   VARCHAR2)
RETURN CLOB;


procedure Search_Move_Data(
	errbuf	OUT	NOCOPY VARCHAR2,
	retcode OUT	NOCOPY NUMBER
);
procedure Test_Search_Move_Data(
	testno  IN  NUMBER,
	errbuf	OUT	NOCOPY VARCHAR2,
	retcode OUT	NOCOPY NUMBER
);


end ibe_search_setup_pvt;

/
