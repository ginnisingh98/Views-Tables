--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_LEGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_LEGS_PVT" AUTHID CURRENT_USER as
/* $Header: WSHDGTHS.pls 120.1.12000000.1 2007/01/16 05:44:48 appldev ship $ */

--
-- Package type declarations
--

TYPE Delivery_Leg_Rec_Type IS RECORD (
	DELIVERY_LEG_ID         NUMBER,
 	DELIVERY_ID             NUMBER,
 	SEQUENCE_NUMBER         NUMBER,
 	LOADING_ORDER_FLAG      VARCHAR2(2),
 	PICK_UP_STOP_ID         NUMBER,
 	DROP_OFF_STOP_ID        NUMBER,
 	GROSS_WEIGHT            NUMBER,
 	NET_WEIGHT              NUMBER,
 	WEIGHT_UOM_CODE         VARCHAR2(3),
 	VOLUME                  NUMBER,
 	VOLUME_UOM_CODE         VARCHAR2(3),
 	CREATION_DATE           DATE,
 	CREATED_BY              NUMBER,
 	LAST_UPDATE_DATE        DATE,
 	LAST_UPDATED_BY         NUMBER,
 	LAST_UPDATE_LOGIN       NUMBER,
 	PROGRAM_APPLICATION_ID  NUMBER,
 	PROGRAM_ID              NUMBER,
	PROGRAM_UPDATE_DATE	DATE,
 	REQUEST_ID		NUMBER,
	LOAD_TENDER_STATUS 	VARCHAR2(1),
/* Changes for the Shipping Data Model Bug#1918342*/
	SHIPPER_TITLE           VARCHAR2(20),
	SHIPPER_PHONE           VARCHAR2(20),
	POD_FLAG                VARCHAR2(1),
	POD_BY                  VARCHAR2(150),
	POD_DATE                DATE,
	EXPECTED_POD_DATE       DATE,
	BOOKING_OFFICE          VARCHAR2(50),
	SHIPPER_EXPORT_REF      VARCHAR2(30),
	CARRIER_EXPORT_REF      VARCHAR2(30),
	DOC_NOTIFY_PARTY        VARCHAR2(30),
	AETC_NUMBER             VARCHAR2(30),
	SHIPPER_SIGNED_BY       VARCHAR2(150),
	SHIPPER_DATE            DATE,
	CARRIER_SIGNED_BY       VARCHAR2(150),
	CARRIER_DATE            DATE,
	DOC_ISSUE_OFFICE        VARCHAR2(150),
	DOC_ISSUED_BY           VARCHAR2(150),
	DOC_DATE_ISSUED         DATE,
	SHIPPER_HM_BY           VARCHAR2(150),
	SHIPPER_HM_DATE         DATE,
	CARRIER_HM_BY           VARCHAR2(150),
	CARRIER_HM_DATE         DATE,
	BOOKING_NUMBER          VARCHAR2(30),
	PORT_OF_LOADING         VARCHAR2(150),
	PORT_OF_DISCHARGE       VARCHAR2(150),
	SERVICE_CONTRACT        VARCHAR2(30),
	BILL_FREIGHT_TO         VARCHAR2(1000),
/* H Integration: datamodel changes wrudge */
	FTE_TRIP_ID			NUMBER,
	REPRICE_REQUIRED		VARCHAR2(1),
	ACTUAL_ARRIVAL_DATE		DATE,
	ACTUAL_DEPARTURE_DATE		DATE,
	ACTUAL_RECEIPT_DATE		DATE,
	TRACKING_DRILLDOWN_FLAG		VARCHAR2(1),
	STATUS_CODE			VARCHAR2(30),
	TRACKING_REMARKS		VARCHAR2(4000),
	CARRIER_EST_DEPARTURE_DATE	DATE,
	CARRIER_EST_ARRIVAL_DATE	DATE,
	LOADING_START_DATETIME		DATE,
	LOADING_END_DATETIME		DATE,
	UNLOADING_START_DATETIME	DATE,
	UNLOADING_END_DATETIME		DATE,
	DELIVERED_QUANTITY		NUMBER,
	LOADED_QUANTITY			NUMBER,
	RECEIVED_QUANTITY		NUMBER,
	ORIGIN_STOP_ID			NUMBER,
	DESTINATION_STOP_ID		NUMBER,
/* Harmonizination project **heali */
        ROWID				VARCHAR2(4000),
/* K: MDC: sperera */
        PARENT_DELIVERY_LEG_ID  	NUMBER

	);

--
--  Procedure:		Create_Delivery_Leg
--  Parameters:		All Attributes of a Delivery Leg Record
--  Description:	This procedure will create a delivery leg. It will
--			return to the user the delivery_leg_id.
--			This is a table handler style procedure and no additional
--			validations are provided.
--

  PROCEDURE Create_Delivery_Leg (
		 p_delivery_leg_info		IN	Delivery_Leg_Rec_Type,
		 x_rowid					OUT NOCOPY 	VARCHAR2,
		 x_delivery_leg_id			OUT NOCOPY 	NUMBER,
		 x_return_status			OUT NOCOPY  	VARCHAR2);


--
--  Procedure:		Update_Delivery_Leg
--  Parameters:	All Attributes of a Delivery Leg Record
--  Description:	This procedure will update attributes of a delivery leg.
--			This is a table handler style procedure and no additional
--			validations are provided.
--

  PROCEDURE Update_Delivery_Leg(
		 p_rowid					IN	VARCHAR2 := NULL,
		 p_delivery_leg_info		IN	Delivery_Leg_Rec_Type,
		 x_return_status			OUT NOCOPY  	VARCHAR2);



--
--  Procedure:		Delete_Delivery_Leg
--  Parameters:	All Attributes of a Delivery Leg Record
--  Description:	This procedure will delete a delivery Leg.
--                      The order in which it looks at the parameters
--                      are:
--                      - p_rowid
--                      - p_delivery_leg_id
--			This is a table handler style procedure and no additional
--			validations are provided.
--

  PROCEDURE Delete_Delivery_Leg (
		 p_rowid					IN	VARCHAR2 := NULL,
		 p_delivery_leg_id			IN	NUMBER := NULL,
		 x_return_status			OUT NOCOPY 	VARCHAR2
	);



--
--  Procedure:          Lock_Delivery_Leg
--  Parameters:         Delivery_Leg rowid, Delivery Leg Record and return_status
--  Description:        This procedure will lock a delivery leg row.
--

  PROCEDURE Lock_Delivery_Leg(
	p_rowid             IN   VARCHAR2,
		p_delivery_leg_info         IN   delivery_leg_rec_type
			);


--
--  Procedure:		Populate_Record
--  Parameters:	Delivery_leg_id as IN, Delivery Leg record and status as OUT
--  Description:	This procedure will populate a stop record
--

  PROCEDURE Populate_Record (
		 p_delivery_leg_id			IN	NUMBER,
		 x_delivery_leg_info		OUT NOCOPY 	Delivery_Leg_Rec_Type,
		 x_return_status			OUT NOCOPY 	VARCHAR2);

-----------------------------------------------------------------------------
--
-- Procedure:     Get_Disabled_List
-- Parameters:    stop_id, x_return_status, p_trip_flag
-- Description:   Get the disabled columns/fields in a delivery leg
--
-----------------------------------------------------------------------------

PROCEDURE Get_Disabled_List (
						p_delivery_leg_id        IN  NUMBER,
						p_parent_entity_id IN NUMBER ,
						p_list_type		  IN  VARCHAR2,
						x_return_status  OUT NOCOPY  VARCHAR2,
						x_disabled_list  OUT NOCOPY  wsh_util_core.column_tab_type,
						x_msg_count             OUT NOCOPY      NUMBER,
						x_msg_data              OUT NOCOPY      VARCHAR2
						);

/*    ---------------------------------------------------------------------
     Procedure:	Lock_Dlvy_Leg_no_compare

     Parameters:	Delivery_Leg Id DEFAULT NULL
                         Delivery Id        DEFAULT NULL

     Description:  This procedure is used for obtaining locks of delivery legs
                    using the delivery_leg_id or the delivery_id.
                   It is called by delivery's wrapper lock API when the
                   action is CONFIRM.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:   Harmonization Project. Patchset I
     ----------------------------------------------------------------------- */


PROCEDURE lock_dlvy_leg_no_compare(
          p_dlvy_leg_id   IN NUMBER DEFAULT NULL,
          p_delivery_id   IN NUMBER DEFAULT NULL);


END WSH_DELIVERY_LEGS_PVT;

 

/
