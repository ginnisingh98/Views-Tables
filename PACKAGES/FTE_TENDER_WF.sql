--------------------------------------------------------
--  DDL for Package FTE_TENDER_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TENDER_WF" AUTHID CURRENT_USER AS
/* $Header: FTETEWFS.pls 120.2 2005/08/16 16:29:15 hbhagava noship $ */

PROCEDURE GET_DOCK_CLOSE_DATE (p_loc_id          IN NUMBER,
	                       p_tender_date     IN DATE,
                               x_dock_close_date OUT NOCOPY DATE,
                               x_return_status   OUT NOCOPY VARCHAR2);

PROCEDURE INITIALIZE_TENDER_REQUEST(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);


PROCEDURE FINALIZE_TENDER_REQUEST(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE FINALIZE_UPDATE_TENDER(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);


PROCEDURE IS_TENDER_MODIFIED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE IS_REMINDER_ENABLED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE CALCULATE_WAIT_TIME(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE FINALIZE_NORESPONSE(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE FINALIZE_AUTO_ACCEPT(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE IS_AUTO_ACCEPT_ENABLED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2);

PROCEDURE GET_TENDER_INFO(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
	        	x_return_status           out NOCOPY     VARCHAR2,
	        	x_msg_count               out NOCOPY     NUMBER,
	        	x_msg_data                out NOCOPY     VARCHAR2,
	        	x_response_by		  out NOCOPY	 DATE,
			x_shipper_wait_time	  OUT NOCOPY     VARCHAR2,
	        	x_remaining_time	  OUT NOCOPY	 VARCHAR2,
	        	x_routing_inst		  out NOCOPY	 VARCHAR2,
	        	x_tendered_date		  out NOCOPY	 DATE,
	        	x_carrier_remarks	  out NOCOPY 	 VARCHAR2,
			x_mode_of_transport       OUT   NOCOPY VARCHAR2);

PROCEDURE RAISE_TENDER_ACCEPT( itemtype  in  varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE RAISE_TENDER_REJECT( itemtype  in  varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE UPDATE_CARRIER_RESPONSE(
		p_init_msg_list  IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_tender_id               IN          NUMBER,
		p_tender_status		  IN          VARCHAR2,
	        p_wf_item_key		  IN	      VARCHAR2,
		p_remarks                 IN          VARCHAR2,
	        p_initial_pickup_date     IN          DATE,
	        p_ultimate_dropoff_date   IN          DATE,
		p_vehicle_number	  IN	      VARCHAR2,
		p_operator		  IN	      VARCHAR2,
		p_carrier_ref_number      IN	      VARCHAR2,
		p_call_source		  IN	      VARCHAR2,
	        x_return_status           OUT NOCOPY  VARCHAR2,
		x_msg_count               OUT NOCOPY  NUMBER,
		x_msg_data                OUT NOCOPY  VARCHAR2);

PROCEDURE   GET_ITEM_INFO(
			P_ITEM_TYPE		IN		VARCHAR2,
			P_ITEM_KEY		IN		VARCHAR2,
			X_SHIPPER_NAME		OUT  NOCOPY	VARCHAR2,
			X_TENDERED_DATE		OUT  NOCOPY	DATE,
			X_RESPOND_BY_DATE	OUT  NOCOPY	DATE,
			X_VEHICLE_TYPE		OUT  NOCOPY 	VARCHAR2,
			X_VEHICLE_CLASS		OUT  NOCOPY 	VARCHAR2);

PROCEDURE   VALIDATE_XML_INFO(
			P_TENDER_NUMBER		IN		NUMBER,
			P_TENDER_STATUS		IN		VARCHAR2,
			P_WF_ITEM_KEY		IN		VARCHAR2,
			P_SHIPMENT_STATUS_ID	IN		NUMBER,
			X_RETURN_STATUS         OUT NOCOPY      VARCHAR2);


--Rel 12 HBHAGAVA
--{

PROCEDURE  GET_NOTIF_TYPE(itemtype  in  varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE  LOG_HISTORY(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE  RAISE_XML_OUTBOUND(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);


PROCEDURE  EXPAND_RANK_LIST(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE  IS_RANK_LIST_EXHAUSTED(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);


PROCEDURE  REMOVE_SERVICE_APPLY_NEXT(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE  AUTO_TENDER_SERVICE(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);

PROCEDURE  FTETENDER_SELECTOR(itemtype	in varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2);


--}


END FTE_TENDER_WF;

 

/
