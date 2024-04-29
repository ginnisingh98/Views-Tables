--------------------------------------------------------
--  DDL for Package WSH_TRIP_STOPS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_STOPS_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHSTACS.pls 120.0.12000000.1 2007/01/16 05:50:40 appldev ship $ */


--
-- Procedure:   Confirm_Stop
-- Parameters:  p_stop_id, p_action_flag, p_intransit_flag,
--              p_close_flag, p_stage_del_flag, p_report_set_id, p_ship_method,
--              p_actual_dep_date, p_bol_flag, p_defer_interface_flag,
--              x_return_status
-- Description: If there are any Open en Pickup Deliveries for the Stop, then these
--              deliveries are selected and these are passed to Confirm_Delivery API
--              After this, the Change_Status API is called to Close the Stop.


PROCEDURE Confirm_Stop (
                           p_stop_id    IN NUMBER,
                           p_action_flag    IN  VARCHAR2,
                           p_intransit_flag IN  VARCHAR2,
                           p_close_flag    IN   VARCHAR2,
                           p_stage_del_flag   IN   VARCHAR2,
                           p_report_set_id  IN   NUMBER,
                           p_ship_method    IN   VARCHAR2,
                           p_actual_dep_date  IN   DATE,
                           p_bol_flag    IN   VARCHAR2,
                           p_defer_interface_flag  IN VARCHAR2,
                           x_return_status   OUT   NOCOPY VARCHAR2 ) ;



--
-- Procedure:		Check_Update_Stops
-- Parameters:		p_stop_rows, x_return_status
-- Description:	Checks if the stops selected do not belong to the same
--                  trip and if there are any Open or Packed deliveries on the stop
--				p_stop_rows - a table of stop_ids
--                  p_action    - 'CLOSE', 'ARRIVE'

PROCEDURE Check_Update_Stops (
		p_stop_rows 		IN 	wsh_util_core.id_tab_type,
    p_action				IN	VARCHAR2,
    p_caller                IN      VARCHAR2 DEFAULT NULL,
		x_return_status		OUT NOCOPY 	VARCHAR2);


--
-- Procedure:		Change_Status
-- Parameters:		p_stop_rows, p_action, p_actual_date,
--                      p_defer_interface_flag (bug 1578251)
--                      x_return_status
-- Description:	Sets the status code of the trip to p_action after
--				performing status code checks.
--				p_stop_rows - a table of stop_ids

PROCEDURE Change_Status (
		p_stop_rows 			IN 	wsh_util_core.id_tab_type,
		p_action				IN	VARCHAR2,
		p_actual_date            IN   DATE,
		p_defer_interface_flag	IN     VARCHAR2,
		x_return_status		OUT NOCOPY 	VARCHAR2,
                p_caller IN VARCHAR2 DEFAULT NULL);



--
-- Procedure:		Plan
-- Parameters:		p_stop_rows, x_return_status
-- Description:	Plans deliveries on stops
--				p_stop_rows - a table of stop_ids

PROCEDURE Plan (
		p_stop_rows 			IN 	wsh_util_core.id_tab_type,
		p_action				IN	VARCHAR2,
                p_caller                IN      VARCHAR2 DEFAULT NULL,
		x_return_status		OUT NOCOPY 	VARCHAR2);

--
-- Procedure:		Calc_Stop_Weight_Volume
-- Parameters:		p_trip_id,p_override_flag, x_return_status
-- Description:		Finds the trip,
--			calculates weight/vol.of stop recursively

PROCEDURE calc_stop_weight_volume( p_stop_rows IN wsh_util_core.id_tab_type,
  				   p_override_flag IN VARCHAR2,
                                   p_calc_wv_if_frozen IN VARCHAR2 DEFAULT 'Y',
				   x_return_status OUT NOCOPY  VARCHAR2,
                                   p_caller        IN      VARCHAR2 DEFAULT NULL);


-- J-IB-NPARIKH-{
--
--
PROCEDURE autoCloseOpen
    (
        p_in_rec                IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type,
        p_reopenStop            IN          BOOLEAN DEFAULT FALSE,
        x_stop_processed        OUT NOCOPY  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2
    );
--
--
PROCEDURE setClose
    (
        p_in_rec               IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type,
        p_in_rec1              IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_out_rec_type,
        p_defer_interface_Flag IN          VARCHAR2,
        x_return_status        OUT NOCOPY  VARCHAR2
    );
--
--
PROCEDURE setOpen
    (
        p_in_rec               IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_in_rec_type,
        p_in_rec1              IN          WSH_TRIP_STOPS_VALIDATIONS.chkClose_out_rec_type,
        x_return_status        OUT NOCOPY  VARCHAR2
    );
--
--
-- J-IB-NPARIKH-}

PROCEDURE RESET_STOP_SEQ_NUMBERS
    (   p_stop_details_rec     IN  OUT NOCOPY  WSH_TRIP_STOPS_VALIDATIONS.stop_details,
        x_return_status        OUT NOCOPY  VARCHAR2
    );

END WSH_TRIP_STOPS_ACTIONS;

 

/
