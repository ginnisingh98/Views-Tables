--------------------------------------------------------
--  DDL for Package WSH_WF_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WF_STD" AUTHID CURRENT_USER AS
/* $Header: WSHWSTDS.pls 120.2 2005/10/26 02:04:22 rahujain noship $ */

-- This global determines whether we use the item attributes stored in the
-- wf item to reset application context.
G_RESET_APPS_CONTEXT BOOLEAN DEFAULT FALSE;

---------------------------------------------------------------------------------------
--
-- Procedure:       Start_Wf_Process
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--		            p_entity_id   - TRIP_ID or DELIVERY_ID
--                  p_organization_id - The Organization Id
--
--                  x_process_started - 'Y' Process started; 'N' Process not started
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:     This Procedure selects and starts a Tracking Workflow process
--                  for an entity - Trip/Delivery after checking if it is eligible.
--                  i.e.1) No Process exists already for the Entity
--                      2) Global and Shipping parameters for the entity admits
--                  Finally updates the WSH_NEW_DELIVERIES or WSH_TRIPS with the
--                  Process name that was launched.
--
---------------------------------------------------------------------------------------

PROCEDURE Start_Wf_Process(
		p_entity_type IN VARCHAR2,
		p_entity_id IN	NUMBER,
                p_organization_id IN NUMBER DEFAULT NULL,
                x_process_started OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------------------------
--
-- Procedure:       Start_Scpod_C_Process
-- Parameters:      p_entity_id   - DELIVERY_ID (Entity is always Delivery)
--                  p_organization_id - The Organization Id
--
--                  x_process_started - 'Y' Process started; 'N' Process not started
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure starts the 'Ship to Deliver' controlling
--                  Workflow process for the Delivery after checking
--                  if it is eligible.
--                  i.e.1) No Process exists already for the Delivery
--                      2) Global and Shipping parameters for the entity admits
--
--
---------------------------------------------------------------------------------------

PROCEDURE Start_Scpod_C_Process(
		p_entity_id IN	NUMBER,
                p_organization_id IN NUMBER,
                x_process_started OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) ;
---------------------------------------------------------------------------------------
--
-- Procedure:       process_selector
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--  		        p_entity_id   - TRIP_ID or DELIVERY_ID
--                  p_organization_id - The Organization Id
--
--                  x_wf_process - Returns the process selected for the Entity
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure selects the process for the entities based on the
--                  various criteria
--                  Delivery:
--                  1) FTE Installed
--                  2) Picking Required
--                  3) Export Screening Required
--                  4) TPW enabled organization
--                  5) Shipment direction (Inbound/Outbound)
--                  6) If Inbound - Buyer/Supplier Managed
--                  Trip:
--                  1) FTE Installed
---------------------------------------------------------------------------------------

PROCEDURE process_selector(
		p_entity_type IN VARCHAR2,
		p_entity_id IN	NUMBER,
		p_organization_id IN NUMBER,
		x_wf_process OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2) ;
---------------------------------------------------------------------------------------
--
-- Procedure:       Raise_Event
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--  		        p_entity_id   - TRIP_ID or DELIVERY_ID
--                  p_event       - The Event to be raised
--                  p_event_data  - Optional Event data to be sent while raising the event
--                  p_parameters  - Optional Parameters to be sent while raising the event
--                  p_send_date   - Optional date to indicate when the event should
--                                  become available for subscription processing.
--                  p_organization_id - The Organization Id
--
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure raises the event in the following scenario
--                  1) If a Process already exists for this Entity
--                  2) If no process exists, checks the Global and Shipping parameters
--                     for raising events and raises accordingly
---------------------------------------------------------------------------------------

PROCEDURE Raise_Event(
		p_entity_type IN VARCHAR2,
		p_entity_id IN VARCHAR2,
		p_event IN VARCHAR2,
                p_event_data IN CLOB DEFAULT NULL,
                p_parameters IN wf_parameter_list_t DEFAULT NULL,
                p_send_date IN DATE DEFAULT SYSDATE,
		p_organization_id IN NUMBER DEFAULT NULL,
		x_return_status OUT NOCOPY VARCHAR2) ;

---------------------------------------------------------------------------------------
-- Procedure:       confirm_start_wf_process
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--                  p_organization_id - The Organization Id
--
--                  x_start_wf_process - Returns 'Y' if process can be started, else 'N'
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure obtains the Global and Shipping parameter
--                  values for 'Enable Tracking Workflows' and determines
--                  if a process can be started by,
--                  Global-TW	Shipping-TW Eligible Workflow Entity
--                  ---------   ----------- -------------------------
--                  None	    Delivery	None
--                  None	    None	    None
--                  Trip	    Delivery	Trip
--                  Trip	    None	    Trip
--                  Delivery	Delivery	Delivery
--                  Delivery	None	    None
--                  Both	    Delivery	Both
--                  Both	    None	    Trip
---------------------------------------------------------------------------------------


PROCEDURE confirm_start_wf_process(
		p_entity_type IN VARCHAR2,
		p_organization_id IN NUMBER,
                x_start_wf_process OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) ;
---------------------------------------------------------------------------------------
-- Procedure:       Check_Wf_Exists
-- Parameters:      p_entity_type - 'TRIP','DELIVERY'
--  		        p_entity_id   - TRIP_ID or DELIVERY_ID
--
--                  x_wf_process_exists - Returns 'Y' if Wf exists, else 'N'
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure checks from WSH_NEW_DELIVERIES or WSH_TRIPS
--                  if a workflow process has been started for this entity.
---------------------------------------------------------------------------------------

PROCEDURE Check_Wf_Exists(
		p_entity_type IN VARCHAR2,
		p_entity_id IN NUMBER,
                x_wf_process_exists OUT NOCOPY VARCHAR2,
		x_return_status OUT NOCOPY VARCHAR2) ;

FUNCTION Wf_Exists(p_entity_type IN VARCHAR2,
                   p_entity_id IN NUMBER)
RETURN BOOLEAN ;

---------------------------------------------------------------------------------------
-- Procedure:       Get_Custom_Wf_Process
-- Parameters:      p_wf_process - The Process selected for the enity
--          		p_org_code - The organization code
--
--                  x_wf_process - Returns the custom process name specified
--                                 with the lookups else the orginial process
--                  x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success
--
-- Description:     This Procedure queries from the WSH_LOOKUPS for any custom
--                  process name specified by the User through the lookups for
--                  a particular process else returns the original process
---------------------------------------------------------------------------------------

PROCEDURE Get_Custom_Wf_Process(
		p_wf_process IN VARCHAR2,
		p_org_code IN VARCHAR2,
		x_wf_process OUT NOCOPY VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2) ;

Procedure Purge_Entity(
               p_entity_type IN VARCHAR2,
               p_entity_ids IN WSH_UTIL_CORE.column_tab_type,
               p_action IN VARCHAR2 DEFAULT 'PURGE',
               p_docommit IN BOOLEAN DEFAULT FALSE,
	       x_success_count OUT NOCOPY NUMBER,
               x_return_status OUT NOCOPY VARCHAR2) ;

PROCEDURE Log_Wf_Exception(p_entity_type IN VARCHAR2,
                           p_entity_id IN NUMBER,
                           p_ship_from_location_id IN NUMBER DEFAULT NULL,
			   p_logging_entity IN VARCHAR2,
                           p_exception_name IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2);

FUNCTION Instance_Default_Rule (p_subscription_guid IN RAW,
				p_event in OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2 ;

PROCEDURE RESET_APPS_CONTEXT_ON;

PROCEDURE RESET_APPS_CONTEXT_OFF;

/* CURRENTLY NOT IN USE
PROCEDURE Get_Carrier(p_del_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
                      x_del_old_carrier_ids OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
                      x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Handle_Trip_Carriers(p_trip_id IN NUMBER,
			       p_del_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
			       p_del_old_carrier_ids IN WSH_UTIL_CORE.ID_TAB_TYPE,
			       x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Assign_Unassign_Carrier(p_delivery_id IN NUMBER,
			          p_old_carrier_id IN NUMBER,
                                  p_new_carrier_id IN NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Get_Deliveries(p_trip_id IN NUMBER,
                         x_del_ids OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
			 x_return_status OUT NOCOPY VARCHAR2);
*/

END WSH_WF_STD;

 

/
