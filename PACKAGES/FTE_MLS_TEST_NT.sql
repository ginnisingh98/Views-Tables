--------------------------------------------------------
--  DDL for Package FTE_MLS_TEST_NT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_MLS_TEST_NT" AUTHID CURRENT_USER AS
/* $Header: FTEMLTES.pls 120.2 2005/07/06 07:51:43 nltan noship $ */

--========================================================================
-- PROCEDURE : ASSIGN_SERVICE_TENDER        FTE wrapper
--
-- COMMENT   : Procedure assigns service, creates/updates ranked list,
--             tenders, and deletes rates. If the FTE_TENDER_ATTR_REC is
--	       populated, then
-- CALLER    : FTE UI: TripWB, DeliveryWB, ManageItinerary
--========================================================================
--
PROCEDURE ASSIGN_SERVICE_TENDER
(
	p_API_VERSION_NUMBER	IN	NUMBER,
	p_INIT_MSG_LIST		IN	VARCHAR2,
	p_COMMIT		IN	VARCHAR2,
	p_SS_ATTR_REC		IN	FTE_SS_ATTR_REC,
	p_SS_RATE_SORT_TAB	IN OUT NOCOPY FTE_SS_RATE_SORT_TAB_TYPE,
	p_TENDER_ATTR_REC	IN	FTE_TENDER_ATTR_REC,
	p_REQUEST_ID		IN	NUMBER,
	p_SERVICE_ACTION	IN	VARCHAR2,
	p_LIST_ACTION		IN	VARCHAR2,
	x_RETURN_STATUS		OUT NOCOPY VARCHAR2,
	x_MSG_COUNT		OUT NOCOPY NUMBER,
	x_MSG_DATA		OUT NOCOPY VARCHAR2
);
--
PROCEDURE SEARCH_SERVICES
(
	p_API_VERSION_NUMBER	IN	NUMBER,
	p_INIT_MSG_LIST		IN	VARCHAR2,
	p_COMMIT		IN	VARCHAR2,
	p_CALLER		IN	VARCHAR2,
	p_FTE_SS_ATTR_REC	IN	FTE_SS_ATTR_REC,
	x_LIST_CREATE_TYPE	OUT NOCOPY VARCHAR2,
	x_SS_RATE_SORT_TAB	OUT NOCOPY FTE_SS_RATE_SORT_TAB_TYPE,
	x_PRICING_REQUEST_ID	OUT NOCOPY NUMBER,
	x_RETURN_STATUS		OUT NOCOPY VARCHAR2,
	x_MSG_COUNT		OUT NOCOPY NUMBER,
	x_MSG_DATA		OUT NOCOPY VARCHAR2
);
--
END FTE_MLS_TEST_NT;

 

/
