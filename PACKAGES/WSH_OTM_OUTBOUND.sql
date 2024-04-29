--------------------------------------------------------
--  DDL for Package WSH_OTM_OUTBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_OUTBOUND" AUTHID CURRENT_USER as
/* $Header: WSHOTOIS.pls 120.0.12010000.4 2009/04/23 14:16:37 anvarshn ship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_OTM_OUTBOUND';

-- +==================================================================================================+
--   Procedure : Get_Delivery_objects
--   Description:
--     	Procedure to get the delivery,delivery details and Lpn info
--      in the form of objects (WSH_OTM_DLV_TAB)

--   Inputs/Outputs:
--            p_dlv_id_tab - id table (list of delivery Ids)
--            p_user_id  - User Id to set the context
--            p_resp_id  - Resp Id to set the context
--            p_resp_appl_id  - Resp Appl Id to set the context
--            p_caller   - When passed from GET_TRIP_OBJECTS this will have a
--				value of 'T' else default 'D'
--            p_trip_id  -  When passed from GET_TRIP_OBJECTS this will have trip_id else dafault -1
--
--   Output:
--            x_domain_name - domain name
--            x_otm_user_name - otm User Name
-- 	      x_otm_pwd    - otm Password
-- 	      x_otm_pwd    - otm Password
-- 	      x_dlv_tab    - Nested Table which contains the delivery info
-- 	      x_error_dlv_id_tab - List of ids for which the data could not be retrieved
--            x_return_status

PROCEDURE GET_DELIVERY_OBJECTS(p_dlv_id_tab 		IN OUT NOCOPY	WSH_OTM_ID_TAB,
			       p_user_id		IN		NUMBER,
			       p_resp_id		IN		NUMBER,
			       p_resp_appl_id		IN		NUMBER,
			       p_caller			IN		VARCHAR2 DEFAULT 'D',
                               p_trip_id		IN		NUMBER DEFAULT -1, --Bug 7408338
			       x_domain_name    	OUT NOCOPY	VARCHAR2,
			       x_otm_user_name 		OUT NOCOPY	VARCHAR2,
			       x_otm_pwd		OUT NOCOPY	VARCHAR2,
			       x_server_tz_code		OUT NOCOPY	VARCHAR2,
			       x_dlv_tab 		OUT NOCOPY 	WSH_OTM_DLV_TAB,
			       x_error_dlv_id_tab	OUT NOCOPY 	WSH_OTM_ID_TAB	,
			       x_return_status 		OUT NOCOPY 	VARCHAR2);




-- +==========================================================================================+
--   Procedure : GET_TRIP_OBJECTS
--   Description:
--     	Procedure to get the Trip, Trip Stop, delivery,delivery details and Lpn info
--      in the form of objects (WSH_OTM_TRIP_TAB)

--   Inputs/Outputs:
--            p_trip_id_tab - id table (list of Trip Ids)
--            p_user_id  - User Id to set the context
--            p_resp_id  - Resp Id to set the context
--            p_resp_appl_id  - Resp Appl Id to set the context
--   Output:
--            x_domain_name - domain name
--            x_otm_user_name - otm User Name
-- 	      x_otm_pwd    - otm Password
-- 	      x_otm_pwd    - otm Password
-- 	      x_trip_tab    - Nested Table which contains the trip info
-- 	      x_error_trip_id_tab - List of ids for which the data could not be retrieved
--            x_return_status

PROCEDURE GET_TRIP_OBJECTS(p_trip_id_tab 		IN OUT NOCOPY	WSH_OTM_ID_TAB,
			       p_user_id		IN		NUMBER,
			       p_resp_id		IN		NUMBER,
			       p_resp_appl_id		IN		NUMBER,
			       x_domain_name    	OUT NOCOPY	VARCHAR2,
			       x_otm_user_name 		OUT NOCOPY	VARCHAR2,
			       x_otm_pwd		OUT NOCOPY	VARCHAR2,
			       x_server_tz_code		OUT NOCOPY	VARCHAR2,
			       x_trip_tab 		OUT NOCOPY 	WSH_OTM_TRIP_TAB,
			       x_dlv_tab		OUT NOCOPY	WSH_OTM_DLV_TAB,
			       x_error_trip_id_tab	OUT NOCOPY 	WSH_OTM_ID_TAB,
			       x_return_status 		OUT NOCOPY 	VARCHAR2);


-- +======================================================================+
--   Procedure : UPDATE_ENTITY_INTF_STATUS
--   Description:
--     	Procedure to upate the interface flag status on the delivery or stop.
--      Calling API should pass in the StopIds as not all Stops are picked up per trip.
--
--   Inputs/Outputs:
--            p_entity_type - Values are DELIVERY  TRIP
--            p_entity_id_tab  - id table  (IN / OUT)
--            p_new_intf_status - Delivery or Trip Stop Status
--                       Trip Stop Interface Flag values:
--                       ASR - ACTUAL_SHIP_REQUIRED
--                       ASP - ACTUAL_IN_PROCESS
--                       CMP - COMPLETE

--                       Delivery Interface Flag values:
--                       NS - NOT TO BE SENT
--                       CR - CREATE_REQUIRED
--                       UR - UPDATE_REQUIRED
--                       DR - DELETE_REQUIRED
--                       CP - CREATE_IN_PROCESS
--                       UP- UPDATE_IN_PROCESS
--                       DP - DELETE_IN_PROCESS
--                       AW - AWAITING_ANSWER
--                       AR - ANSWER_RECEIVED
--                       CMP - COMPLETE
--            p_user_Id  - user id
--            p_resp_Id - responsibility id
--            p_resp_appl_Id - resp application id
--   Output:
--            p_error_id_tab - erred entity id table
--            x_return_status
--   API is called from the following
/*
1.Concurrent Request --TripStop and Delivery TMS_INTERFACE_FLAG is updated to newStatus = X_IN_PROCESS.
2.WSH_GLOG_OUTBOUND.GET_TRIP_OBJECTS - TripStop and Delivery TMS_INTERFACE_FLAG is updated to newStatus = AWAITING_ANSWER.
3.WSH_GLOG_OUTBOUND.GET_DELIVERY_OBJECTS - TripStop and Delivery TMS_INTERFACE_FLAG is updated to newStatus = AWAITING_ANSWER.
*/
-- +======================================================================+
PROCEDURE UPDATE_ENTITY_INTF_STATUS(
           x_return_status   OUT NOCOPY   VARCHAR2,
           p_entity_type     IN VARCHAR2,
           p_new_intf_status IN VARCHAR2,
           p_userId          IN    NUMBER DEFAULT NULL,
           p_respId          IN    NUMBER DEFAULT NULL,
           p_resp_appl_Id    IN    NUMBER DEFAULT NULL,
           p_entity_id_tab   IN OUT NOCOPY WSH_OTM_ID_TAB,
           p_error_id_tab    IN OUT NOCOPY WSH_OTM_ID_TAB
      );

-- +======================================================================+
--   Procedure : WSH_OTM_APPS_INITIALIZE
--   Description:
--      This procedure may be called to initialize the global security
--      context for a database session in an Autonomus transaction. This should
--      only be done when the session is established outside of a normal forms or
--      concurrent program connection
--
--   Inputs:
--            p_user_id  - FND User ID
--            p_resp_id  - FND Responsibility ID
--            p_resp_appl_id - FND Responsibility Application ID
--   API is called from the following
/*
1.WSH_OTM_OUTBOUND.GET_TRIP_OBJECTS
2.WSH_GLOG_OUTBOUND.GET_DELIVERY_OBJECTS
3.GET_TRIP_OBJECTS.UPDATE_ENTITY_INTF_STATUS
*/
-- +======================================================================+
PROCEDURE WSH_OTM_APPS_INITIALIZE(
           p_user_id      IN NUMBER,
           p_resp_id      IN NUMBER,
           p_resp_appl_id IN NUMBER
         );

END WSH_otm_OUTBOUND;

/
