--------------------------------------------------------
--  DDL for Package WMS_DOCK_APPOINTMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DOCK_APPOINTMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSDKAPS.pls 120.2 2007/12/21 10:58:24 shikapoo ship $ */

  /*Added new API get_dock_appointment_range which accepts dock appointment attributes
   and returns a pl/sql table populated with the list of appointments for the
   given query criteria
  */
  --Record used in get_dock_appointment_range procedure
  --to hold the appointments fetched from wms_dock_appointments_b
  TYPE dock_appt_rec_tp IS RECORD
  (    dock_appointment_id  NUMBER
     , start_time           DATE
     , end_time             DATE
  );

  TYPE dock_appt_tb_tp is TABLE OF dock_appt_rec_tp INDEX BY BINARY_INTEGER;

   TYPE DockApptRecType IS RECORD
  (	Dock_Name	VARCHAR2(40),	-- OTM will pass this as 'DOCK-inventory_location_id'
	Trip_Stop_id	NUMBER,		-- Stop_id for the Pickup Stop from wsh_trip_stops table
	Organization_id	NUMBER,		-- Organization_id of the Pickup Stop
	Start_Time	DATE,		-- Appointment Start Date and Time
	End_Time	DATE);		-- Appointment End Date and Time

  TYPE DockApptTabType IS TABLE OF DockApptRecType INDEX BY BINARY_INTEGER;

/*
** -------------------------------------------------------------------------
** Fuction:    get_trip_stop
** Description: returns trip_stop that is occupying a dock door at a given time
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_dock_locator_id
**
** Returns:
**	number
** --------------------------------------------------------------------------
*/

  g_dock_appointments_b_rec wms_dock_appointments_b%ROWTYPE;
  g_dock_appointments_tl_rec wms_dock_appointments_tl%ROWTYPE;

  FUNCTION get_trip_stop
  (
   x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
   , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , p_dock_locator_id           IN  NUMBER)
  RETURN NUMBER;


  PROCEDURE update_dock_appointment
    (
     x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
     , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , p_dock_appointments_v_rec   IN wms_dock_appointments_v%ROWTYPE
     );

  PROCEDURE update_rep_appointments
    (
      x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
      x_msg_count                   OUT NOCOPY /* file.sql.39 change */ NUMBER,
      x_msg_data                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
      p_orig_id                     IN NUMBER,
      p_dock_appointments_v_rec     IN wms_dock_appointments_v%ROWTYPE
      );

  PROCEDURE insert_dock_appointment
    (
     x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
     , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , p_dock_appointments_v_rec   IN wms_dock_appointments_v%ROWTYPE
     );

  PROCEDURE insert_rep_dock_appointments
    (
     x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
     , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , p_rep_orig_id                   IN NUMBER
     , p_dock_appointments_v_rec   IN wms_dock_appointments_v%ROWTYPE
     );

  PROCEDURE delete_dock_appointment
    (
     x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
     , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , p_dock_appointment_id       IN NUMBER
     );

  PROCEDURE delete_rep_dock_appointment
    (
     x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
     , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     , p_rep_orig_id               IN NUMBER
     );
  PROCEDURE LOCK_ROW
    (
     x_dock_appointment_id IN NUMBER,
     x_carrier_code IN VARCHAR2,
     x_staging_lane_id IN NUMBER,
     x_trip_stop IN NUMBER,
     x_rep_start_date IN DATE,
     x_rep_end_date IN DATE,
     x_rep_origin IN NUMBER,
     x_rep_frequency IN NUMBER,
     x_appointment_status IN NUMBER,
     x_appointment_type IN NUMBER,
     x_dock_id IN NUMBER,
     x_organization_id IN NUMBER,
     x_start_time IN DATE,
     x_end_time IN DATE,
     x_source_type IN NUMBER,
     x_source_header_id IN NUMBER,
     x_source_line_id IN NUMBER,
     x_subject IN VARCHAR2,
     x_description IN VARCHAR2
     );
  PROCEDURE ADD_LANGUAGE;

  /*-----------------------------------------------------------------------------------*
  API Name            :GET_DOCK_APPOINTMENT_RANGE
  Type                :Public
  Pre-reqs            :None
  Description         :Given appointment attributes and time window
                      fetches a list of dock appointments
  Output Parameters   :
                      x_return_status    -  Retun Status Indicator
                                            1.Success          -S
                                            2.Error            -E
                                            3.Unexpected Error -U
                                            sets the return status as S(success),E(Error),U(Unexpected Error)
                      x_msg_count        -  Indicates the no of messages in the message list
                      x_msg_data         -  Stacked messages text
                      x_dock_appt_list   -  List of all the appointments selected
  Input Parameters    :
                      p_api_version      -  Current Version of API
                      p_init_msg_list    -  Indicates if error message list needs to be initialized or not
                                            Valid values are FND_API.G_TRUE and FND_API.G_FALSE
                      p_organization_id  -  Organization Id
                      p_start_date       -  Start date and time to query dock appointments
                      p_end_date         -  End date and time to query dock appointments
                      p_appointment_type -  Appointment types
                                            1. Inbound
                                            2. Outbound
                                            3. Others
                      p_supplier_id      -  Supplier Identifier
                      p_supplier_site_id -  Supplier site Identifier
                      p_customer_id      -  Cutomer Identifier
                      p_customer_site_id -  Customer site Identifier
                      p_carrier_code     -  Carrier code for the shipment
                      p_carrier_id       -  Carrier id for the shipment
                      p_trip_stop_id     -  Trip stop id of the shipment
                      p_waybill_number   -  Waybill number of the delivery/ shipment
                      p_bill_of_lading   -  Bill of lading of the delivery/shipment
                      p_master_bol       -  Master Bill of Lading of the delivery/shipment

  *-------------------------------------------------------------------------------------*/
   PROCEDURE get_dock_appointment_range
    (
       x_return_status    OUT NOCOPY  VARCHAR2
     , x_msg_count        OUT NOCOPY  NUMBER
     , x_msg_data         OUT NOCOPY  VARCHAR2
     , x_dock_appt_list   OUT NOCOPY  WMS_DOCK_APPOINTMENTS_PUB.dock_appt_tb_tp
     , p_api_version      IN          NUMBER    DEFAULT 1.0
     , p_init_msg_list    IN          VARCHAR2  DEFAULT FND_API.G_FALSE
     , p_organization_id  IN          NUMBER
     , p_start_date       IN          DATE
     , p_end_date         IN          DATE
     , p_appointment_type IN          NUMBER    DEFAULT NULL
     , p_supplier_id      IN          NUMBER    DEFAULT NULL
     , p_supplier_site_id IN          NUMBER    DEFAULT NULL
     , p_customer_id      IN          NUMBER    DEFAULT NULL
     , p_customer_site_id IN          NUMBER    DEFAULT NULL
     , p_carrier_code     IN          VARCHAR2  DEFAULT NULL
     , p_carrier_id       IN          VARCHAR2  DEFAULT NULL
     , p_trip_stop_id     IN          NUMBER    DEFAULT NULL
     , p_waybill_number   IN          VARCHAR2  DEFAULT NULL
     ,  p_bill_of_lading  IN          VARCHAR2  DEFAULT NULL
     , p_master_bol       IN          VARCHAR2  DEFAULT NULL
   );

   PROCEDURE OTM_Dock_Appointment
   (
	p_dock_appt_tab	IN DockApptTabType,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count     OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2
   );

END WMS_DOCK_APPOINTMENTS_PUB;

/
