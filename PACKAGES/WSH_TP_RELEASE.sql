--------------------------------------------------------
--  DDL for Package WSH_TP_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TP_RELEASE" AUTHID CURRENT_USER as
/* $Header: WSHTPRLS.pls 120.1.12000000.1 2007/01/16 05:51:25 appldev ship $ */

--Package  for TP specific code

/*
Delivery's Ignore status changes :

All delivery details of the delivery must change to the same Ignore status
as the delivery. If the trip (that the delivery is associated with) is of
a different Ignore status, the user should be asked to manually unassign
the delivery and then perform the action, unless the trip is Load Firm,
in which case the trip has to be unfirmed, delivery has to be unassigned
and then change the status

If the trip's ignore_for_planning is changed, All deliveries of the trip
must change to the same Ignore status as the trip. If there are other trips
associated with the deliveries with a different ignore for planning, error.
TPW, Carrier Manifest lines, dels have to be always marked as ignore_for_plan
*/



procedure change_ignoreplan_status
                   (p_entity  IN VARCHAR2,               --'DLVY', 'DLVB', 'TRIP' dep on place from which it is called
                    p_in_ids  IN wsh_util_core.id_tab_type,               -- table of ids of above entity
                    p_action_code IN VARCHAR2,     -- either 'IGNORE_PLAN', 'INCLUDE_PLAN'
                    x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE firm_entity( p_entity IN VARCHAR2,
                       p_entity_id IN NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

--unfirming trip will unfirm CM as well (if CM is firm)
procedure unfirm_entity(
                       p_entity IN VARCHAR2,
                       p_entity_id IN NUMBER,
                       p_action IN VARCHAR2,         --either 'PLAN' or 'UNPLAN'
                       x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE calculate_tp_dates(
                        p_request_date_type IN VARCHAR2,
                        p_latest_acceptable_date IN DATE,
                        p_promise_date IN DATE,
                        p_schedule_arrival_date IN DATE,
                        p_schedule_ship_date IN DATE,
                        p_earliest_acceptable_date IN DATE,
                        p_demand_satisfaction_date IN DATE,
                        p_source_line_id IN NUMBER DEFAULT NULL,
                        p_source_code IN     VARCHAR2 DEFAULT NULL,
                        p_organization_id IN NUMBER DEFAULT NULL,
                        p_inventory_item_id IN NUMBER DEFAULT NULL,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_earliest_pickup_date OUT NOCOPY DATE,
                        x_latest_pickup_date OUT NOCOPY DATE,
                        x_earliest_dropoff_date OUT NOCOPY DATE,
                        x_latest_dropoff_date OUT NOCOPY DATE);
PROCEDURE calculate_cont_del_tpdates(
                       p_entity IN VARCHAR2,
                       p_entity_ids IN wsh_util_core.id_tab_type,
                       x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE log_tpdate_exception(p_entity VARCHAR2,
                               p_entity_id NUMBER,
                               p_pick_up BOOLEAN,
                               early_date DATE,
                               latest_date DATE
                              );

/**
*  Check_Shipset_Ignoreflag Checks if the p_delivery_detail_id ignore_for_planning
*  is different from other lines ignore_for_palnning which are in same ship set.
*  If so exception is logged if p_logexcep is True otherwise warinig message is thrown.
*/
PROCEDURE Check_Shipset_Ignoreflag(p_delivery_detail_ids wsh_util_core.id_tab_type,
                                    p_ignore_for_planning VARCHAR2,
                                    p_logexcep boolean,
                                    x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Check_Shipset_Ignoreflag(p_delivery_detail_id NUMBER,
                                    p_ignore_for_planning VARCHAR2,
                                    p_logexcep boolean,
                                    x_return_status OUT NOCOPY VARCHAR2);

END WSH_TP_RELEASE;



 

/
