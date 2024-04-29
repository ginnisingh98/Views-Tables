--------------------------------------------------------
--  DDL for Package FTE_SS_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_SS_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: FTESSITS.pls 120.2 2005/07/14 08:19:38 nltan noship $ */

S_CALLER_WF	CONSTANT	VARCHAR2(30)	:= 'WF';
S_CALLER_UI	CONSTANT	VARCHAR2(30)	:= 'UI';

G_SEQ_DEBUG	VARCHAR2(30) := 'OFF';
G_RG_DEBUG	VARCHAR2(30) := 'OFF';

G_ROUTING_GUIDE_RESULTS	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
G_SS_RATE_SORT_RESULTS	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;


PROCEDURE SEARCH_SERVICES(
	P_INIT_MSG_LIST			IN	VARCHAR2,
	P_API_VERSION_NUMBER		IN	NUMBER,
	P_COMMIT			IN	VARCHAR2,
	P_CALLER			IN	VARCHAR2,
	P_FTE_SS_ATTR_REC		IN	FTE_SS_ATTR_REC,
	X_RATING_REQUEST_ID		OUT NOCOPY	NUMBER,
	X_LIST_CREATE_TYPE		OUT NOCOPY	VARCHAR2,
	X_SS_RATE_SORT_TAB		OUT NOCOPY	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	NUMBER,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2);


PROCEDURE SEARCH_SERVICES_UIWRAPPER(
	P_INIT_MSG_LIST			IN	VARCHAR2,
	P_API_VERSION_NUMBER		IN	NUMBER,
	P_COMMIT			IN	VARCHAR2,
	P_CALLER			IN	VARCHAR2,
	P_FTE_SS_ATTR_REC		IN	FTE_SS_ATTR_REC,
	X_RATING_REQUEST_ID		OUT NOCOPY	NUMBER,
	X_LIST_CREATE_TYPE		OUT NOCOPY	VARCHAR2,
	X_SS_RATE_SORT_TAB		OUT NOCOPY	FTE_SS_RATE_SORT_TAB_TYPE,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	NUMBER,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2);


  PROCEDURE GET_RANKED_RESULTS_WRAPPER
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2,
    x_routing_guide	     OUT NOCOPY		FTE_SS_RATE_SORT_TAB_TYPE,
    p_routing_rule_id		     IN			NUMBER);


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

END FTE_SS_INTERFACE;

 

/