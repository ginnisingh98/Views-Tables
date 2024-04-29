--------------------------------------------------------
--  DDL for Package MSC_E1_APS_PDP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_E1_APS_PDP" AUTHID CURRENT_USER AS
--# $Header: MSCE1PDS.pls 120.0.12010000.4 2009/07/09 11:07:40 nyellank noship $
	PROCEDURE MSC_E1APS_SCR_LIST(ERRBUF OUT NOCOPY VARCHAR2,
		RETCODE OUT NOCOPY VARCHAR2,
		parInstanceID IN VARCHAR2,
		parBaseDate IN INTEGER,
		parCalendars IN  NUMBER ,
		parTradingPtnrs  IN NUMBER ,
		parPlanners IN NUMBER ,
		parUOMs IN NUMBER ,
		parItems IN NUMBER ,
		parResrcs IN NUMBER ,
		parRtng IN NUMBER ,
		parOprns IN NUMBER ,
		parBOMs IN NUMBER ,
		parDmdClasses IN NUMBER ,
		parSalesChannels IN NUMBER ,
		parPriceLists IN NUMBER ,
		parShippingMethods IN NUMBER ,
		parItemSupp IN NUMBER ,
		parItemSrcing IN NUMBER ,
		parOnhandSupp IN NUMBER ,
		parSS IN NUMBER,
		parPOSupp IN NUMBER ,
		parReqSupp IN NUMBER,
		parInstrSupp IN NUMBER ,
		parExtFcst IN NUMBER ,
		parSO IN NUMBER,
		parWO IN NUMBER);

END MSC_E1_APS_PDP;


/
