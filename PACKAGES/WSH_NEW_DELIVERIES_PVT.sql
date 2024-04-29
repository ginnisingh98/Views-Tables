--------------------------------------------------------
--  DDL for Package WSH_NEW_DELIVERIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_NEW_DELIVERIES_PVT" AUTHID CURRENT_USER as
/* $Header: WSHDETHS.pls 120.1.12010000.3 2009/12/03 14:30:28 mvudugul ship $ */

-- CONSTANTS declaration --
--
-- OTM R12, glog project
-- Declare Constants for the possible values of tms_interface_flag
-- at Delivery Level
-- The Code and Description are
--      NS -- Not to be Sent
--      CR -- Creation required
--      CP -- Creation in Process
--      UR -- Update required
--      UP -- Update in Process
--      DR -- Delete required
--      DP -- Delete in Process
--      AW -- Awaiting Answer
--      AR -- Answer Received
--     CMP -- Completed
  C_TMS_NOT_TO_BE_SENT    CONSTANT VARCHAR2(2) := 'NS';
  C_TMS_CREATE_REQUIRED   CONSTANT VARCHAR2(2) := 'CR';
  C_TMS_CREATE_IN_PROCESS CONSTANT VARCHAR2(2) := 'CP';
  C_TMS_UPDATE_REQUIRED   CONSTANT VARCHAR2(2) := 'UR';
  C_TMS_UPDATE_IN_PROCESS CONSTANT VARCHAR2(2) := 'UP';
  C_TMS_DELETE_REQUIRED   CONSTANT VARCHAR2(2) := 'DR';
  C_TMS_DELETE_IN_PROCESS CONSTANT VARCHAR2(2) := 'DP';
  C_TMS_AWAITING_ANSWER   CONSTANT VARCHAR2(2) := 'AW';
  C_TMS_ANSWER_RECEIVED   CONSTANT VARCHAR2(2) := 'AR';
  C_TMS_COMPLETED         CONSTANT VARCHAR2(3) := 'CMP';

-- end of OTM R12, glog proj
--

--
--
-- Package type declarations
--

TYPE Delivery_Rec_Type IS RECORD (
	DELIVERY_ID                     NUMBER,
	NAME                            VARCHAR2(30),
	PLANNED_FLAG                    VARCHAR2(1),
	STATUS_CODE                     VARCHAR2(2),
	DELIVERY_TYPE                   VARCHAR2(30),
	LOADING_SEQUENCE                NUMBER,
	LOADING_ORDER_FLAG              VARCHAR2(2),
	INITIAL_PICKUP_DATE             DATE,
	INITIAL_PICKUP_LOCATION_ID      NUMBER,
	ORGANIZATION_ID			NUMBER,
	ULTIMATE_DROPOFF_LOCATION_ID    NUMBER,
	ULTIMATE_DROPOFF_DATE           DATE,
	CUSTOMER_ID                     NUMBER,
	INTMED_SHIP_TO_LOCATION_ID      NUMBER,
	POOLED_SHIP_TO_LOCATION_ID      NUMBER,
	CARRIER_ID                      NUMBER,
	SHIP_METHOD_CODE                VARCHAR2(30),
	FREIGHT_TERMS_CODE              VARCHAR2(30),
	FOB_CODE                        VARCHAR2(30),
	FOB_LOCATION_ID                 NUMBER,
	WAYBILL                         VARCHAR2(30),
	DOCK_CODE                       VARCHAR2(30),
	ACCEPTANCE_FLAG                 VARCHAR2(1),
	ACCEPTED_BY                     VARCHAR2(150),
	ACCEPTED_DATE                   DATE,
	ACKNOWLEDGED_BY                 VARCHAR2(150),
	CONFIRMED_BY                    VARCHAR2(150),
	CONFIRM_DATE                    DATE,
	ASN_DATE_SENT                   DATE,
	ASN_STATUS_CODE                 VARCHAR2(15),
	ASN_SEQ_NUMBER                  NUMBER,
	GROSS_WEIGHT                    NUMBER,
	NET_WEIGHT                      NUMBER,
	WEIGHT_UOM_CODE                 VARCHAR2(3),
	VOLUME                          NUMBER,
	VOLUME_UOM_CODE                 VARCHAR2(3),
	ADDITIONAL_SHIPMENT_INFO        VARCHAR2(500),
	CURRENCY_CODE                   VARCHAR2(15),
	ATTRIBUTE_CATEGORY              VARCHAR2(150),
	ATTRIBUTE1                      VARCHAR2(150),
	ATTRIBUTE2                      VARCHAR2(150),
	ATTRIBUTE3                      VARCHAR2(150),
	ATTRIBUTE4                      VARCHAR2(150),
	ATTRIBUTE5                      VARCHAR2(150),
	ATTRIBUTE6                      VARCHAR2(150),
	ATTRIBUTE7                      VARCHAR2(150),
	ATTRIBUTE8                      VARCHAR2(150),
	ATTRIBUTE9                      VARCHAR2(150),
	ATTRIBUTE10                     VARCHAR2(150),
	ATTRIBUTE11                     VARCHAR2(150),
	ATTRIBUTE12                     VARCHAR2(150),
	ATTRIBUTE13                     VARCHAR2(150),
	ATTRIBUTE14                     VARCHAR2(150),
	ATTRIBUTE15                     VARCHAR2(150),
	TP_ATTRIBUTE_CATEGORY           VARCHAR2(150),
	TP_ATTRIBUTE1                   VARCHAR2(150),
	TP_ATTRIBUTE2                   VARCHAR2(150),
	TP_ATTRIBUTE3                   VARCHAR2(150),
	TP_ATTRIBUTE4                   VARCHAR2(150),
	TP_ATTRIBUTE5                   VARCHAR2(150),
	TP_ATTRIBUTE6                   VARCHAR2(150),
	TP_ATTRIBUTE7                   VARCHAR2(150),
	TP_ATTRIBUTE8                   VARCHAR2(150),
	TP_ATTRIBUTE9                   VARCHAR2(150),
	TP_ATTRIBUTE10                  VARCHAR2(150),
	TP_ATTRIBUTE11                  VARCHAR2(150),
	TP_ATTRIBUTE12                  VARCHAR2(150),
	TP_ATTRIBUTE13                  VARCHAR2(150),
	TP_ATTRIBUTE14                  VARCHAR2(150),
	TP_ATTRIBUTE15                  VARCHAR2(150),
	GLOBAL_ATTRIBUTE_CATEGORY       VARCHAR2(30),
	GLOBAL_ATTRIBUTE1               VARCHAR2(150),
	GLOBAL_ATTRIBUTE2               VARCHAR2(150),
	GLOBAL_ATTRIBUTE3               VARCHAR2(150),
	GLOBAL_ATTRIBUTE4               VARCHAR2(150),
	GLOBAL_ATTRIBUTE5               VARCHAR2(150),
	GLOBAL_ATTRIBUTE6               VARCHAR2(150),
	GLOBAL_ATTRIBUTE7               VARCHAR2(150),
	GLOBAL_ATTRIBUTE8               VARCHAR2(150),
	GLOBAL_ATTRIBUTE9               VARCHAR2(150),
	GLOBAL_ATTRIBUTE10              VARCHAR2(150),
	GLOBAL_ATTRIBUTE11              VARCHAR2(150),
	GLOBAL_ATTRIBUTE12              VARCHAR2(150),
	GLOBAL_ATTRIBUTE13              VARCHAR2(150),
	GLOBAL_ATTRIBUTE14              VARCHAR2(150),
	GLOBAL_ATTRIBUTE15              VARCHAR2(150),
	GLOBAL_ATTRIBUTE16              VARCHAR2(150),
	GLOBAL_ATTRIBUTE17              VARCHAR2(150),
	GLOBAL_ATTRIBUTE18              VARCHAR2(150),
	GLOBAL_ATTRIBUTE19              VARCHAR2(150),
	GLOBAL_ATTRIBUTE20              VARCHAR2(150),
	CREATION_DATE                   DATE,
	CREATED_BY                      NUMBER,
	LAST_UPDATE_DATE                DATE,
	LAST_UPDATED_BY                 NUMBER,
	LAST_UPDATE_LOGIN               NUMBER,
	PROGRAM_APPLICATION_ID          NUMBER,
	PROGRAM_ID                      NUMBER,
	PROGRAM_UPDATE_DATE             DATE,
	REQUEST_ID                      NUMBER,
        BATCH_ID                        NUMBER,
        HASH_VALUE                      NUMBER,
        SOURCE_HEADER_ID                NUMBER,
	NUMBER_OF_LPN	                NUMBER,--bugfix 1426086: added number_of_lpn
/* Changes for the Shipping Data Model Bug#1918342*/
        COD_AMOUNT                      NUMBER,
        COD_CURRENCY_CODE               VARCHAR2(15),
        COD_REMIT_TO                    VARCHAR2(150),
        COD_CHARGE_PAID_BY              VARCHAR2(150),
        PROBLEM_CONTACT_REFERENCE       VARCHAR2(500),
        PORT_OF_LOADING                 VARCHAR2(150),
        PORT_OF_DISCHARGE               VARCHAR2(150),
        FTZ_NUMBER                      VARCHAR2(35),
        ROUTED_EXPORT_TXN               VARCHAR2(1),
        ENTRY_NUMBER                    VARCHAR2(35),
        ROUTING_INSTRUCTIONS            VARCHAR2(120),
        IN_BOND_CODE                    VARCHAR2(35),
        SHIPPING_MARKS                  VARCHAR2(100),
/* H Integration: datamodel changes wrudge */
	SERVICE_LEVEL			VARCHAR2(30),
	MODE_OF_TRANSPORT		VARCHAR2(30),
	ASSIGNED_TO_FTE_TRIPS		VARCHAR2(1),
/* I Quickship : datamodel changes sperera */
        AUTO_SC_EXCLUDE_FLAG            VARCHAR2(1),
        AUTO_AP_EXCLUDE_FLAG            VARCHAR2(1),
        AP_BATCH_ID                     NUMBER,
/* I Harmonization: Non database Columns added rvishnuv */
        ROWID				VARCHAR2(4000),
	LOADING_ORDER_DESC              VARCHAR2(80),
        ORGANIZATION_CODE               VARCHAR2(3),
        ULTIMATE_DROPOFF_LOCATION_CODE  VARCHAR2(500),
        INITIAL_PICKUP_LOCATION_CODE    VARCHAR2(500),
        CUSTOMER_NUMBER                 VARCHAR2(30),
        INTMED_SHIP_TO_LOCATION_CODE    VARCHAR2(500),
        POOLED_SHIP_TO_LOCATION_CODE    VARCHAR2(500),
        CARRIER_CODE                    VARCHAR2(360),
        SHIP_METHOD_NAME                VARCHAR2(240),
        FREIGHT_TERMS_NAME              VARCHAR2(80),
        FOB_NAME                        VARCHAR2(80),
        FOB_LOCATION_CODE               VARCHAR2(500),
        WEIGHT_UOM_DESC                 VARCHAR2(25),
        VOLUME_UOM_DESC                 VARCHAR2(25),
        CURRENCY_NAME                   VARCHAR2(80),
/*  J  Inbound Logistics: New columns jckwok */
        SHIPMENT_DIRECTION              VARCHAR2(30),
        VENDOR_ID                       NUMBER,
        PARTY_ID                        NUMBER,
        ROUTING_RESPONSE_ID             NUMBER,
        RCV_SHIPMENT_HEADER_ID          NUMBER,
        ASN_SHIPMENT_HEADER_ID          NUMBER,
        SHIPPING_CONTROL                VARCHAR2(30),
/* J TP Release : ttrichy */
        TP_DELIVERY_NUMBER              NUMBER,
        EARLIEST_PICKUP_DATE            DATE,
        LATEST_PICKUP_DATE              DATE,
        EARLIEST_DROPOFF_DATE           DATE,
        LATEST_DROPOFF_DATE             DATE,
        IGNORE_FOR_PLANNING             VARCHAR2(1),
        TP_PLAN_NAME                    VARCHAR2(10),
-- J: W/V Changes
        wv_frozen_flag                  VARCHAR2(1),
        hash_string                     varchar2(1000),
        delivered_date                  date,
/* J : Non database Columns added */
        packing_slip                    varchar2(50),
--bug 3667348
        REASON_OF_TRANSPORT             VARCHAR2(30),
        DESCRIPTION                     VARCHAR2(30),
 --Non Database field added for "Proration of weight from Delivery to delivery lines" Project(Bug#4254552).
        PRORATE_WT_FLAG	                VARCHAR2(1),
 --OTM R12
        TMS_INTERFACE_FLAG              WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE,
        TMS_VERSION_NUMBER              WSH_NEW_DELIVERIES.TMS_VERSION_NUMBER%TYPE,
 --
 --R12.1.1 STANDALONE PROJECT
        PENDING_ADVICE_FLAG              WSH_NEW_DELIVERIES.PENDING_ADVICE_FLAG%TYPE,
        CLIENT_ID                       NUMBER, -- LSP PROJECT Modified R12.1.1 LSP PROJECT
        CLIENT_CODE                     VARCHAR2(10) -- LSP PROJECT
	);

TYPE Delivery_Attr_Tbl_Type is TABLE of Delivery_Rec_Type index by binary_integer;

--
--  Procedure:		Create_Delivery
--  Parameters:		p_delivery_info - All Attributes of a Delivery Record
--			x_rowid - Rowid of delivery created
--			x_delivery_id - Delivery_Id of delivery created
--			x_name - Name of delivery created
--			x_return_status - Status of procedure call
--  Description:	This procedure will create a delivery. It will
--			return to the use the delivery_id and name (if
--			not provided as a parameter.
--

  PROCEDURE Create_Delivery
		(p_delivery_info	IN   Delivery_Rec_Type,
		 x_rowid		OUT NOCOPY   VARCHAR2,
		 x_delivery_id		OUT NOCOPY   NUMBER,
		 x_name			OUT NOCOPY   VARCHAR2,
		 x_return_status	OUT NOCOPY   VARCHAR2
		);


--
--  Procedure:		Update_Delivery
--  Parameters:		p_rowid - Rowid for delivery to be updated
--			p_delivery_info - All Attributes of a Delivery Record
--			x_return_status - Status of procedure call
--  Description:	This procedure will update attributes of a delivery.
--

  PROCEDURE Update_Delivery
		(p_rowid		IN	VARCHAR2,
		 p_delivery_info	IN	Delivery_Rec_Type,
		 x_return_status	OUT NOCOPY 	VARCHAR2
		);

--
--  Procedure:		Delete_Delivery
--  Parameters:		p_rowid - Rowid for delivery to be deleted
--			p_delivery_id - Delivery_id of delivery to be deleted
--			x_return_status - Status of procedure call
--             p_validate_flag - calls validate procedure if 'Y'
--  Description:	This procedure will delete a delivery.
--                      The order in which it looks at the parameters
--                      are:
--                      - p_rowid
--                      - p_delivery_id
--

  PROCEDURE Delete_Delivery
		(p_rowid		IN	VARCHAR2 := NULL,
		 p_delivery_id		IN	NUMBER := NULL,
		 x_return_status	OUT NOCOPY 	VARCHAR2,
		 p_validate_flag    IN   VARCHAR2 DEFAULT 'Y'
		);

--
--  Procedure:		Lock_Delivery
--  Parameters:		p_rowid - Rowid for delivery to be locked
--			p_delivery_info - All Attributes of a Delivery Record
--			x_return_status - Status of procedure call
--  Description:	This procedure will lock a delivery record. It is
--			specifically designed for use by the form.
--

  PROCEDURE Lock_Delivery
		(p_rowid		IN	VARCHAR2,
		 p_delivery_info	IN	Delivery_Rec_Type
		 );


--
--  Procedure:		Populate_Record
--  Parameters:		p_delivery_id - Id for delivery
--			x_delivery_info - All Attributes of a Delivery Record
--			x_return_status - Status of procedure call
--  Description:	This procedure will populate a delivery record.
--

  PROCEDURE Populate_Record
		(p_delivery_id		IN	VARCHAR2,
		 x_delivery_info	OUT NOCOPY 	Delivery_Rec_Type,
		 x_return_status	OUT NOCOPY 	VARCHAR2
		 );

--
--  Function:		Get_Name
--  Parameters:		p_delivery_id - Id for delivery
--  Description:	This procedure will return Delivery Name for a Delivery Id
--

  FUNCTION Get_Name
		(p_delivery_id		IN	NUMBER
		 ) RETURN VARCHAR2;


--
--  Procedure:   Lock_Delivery Wrapper
--  Parameters:  A table of all attributes of a Delivery Record,
--               Caller in
--               Return_Status,Valid_index_id_tab out
--  Description: This procedure will lock multiple Deliveries.

procedure Lock_Delivery(
        p_rec_attr_tab          IN              Delivery_Attr_Tbl_Type,
        p_caller                IN              VARCHAR2,
        p_valid_index_tab       IN              wsh_util_core.id_tab_type,
        x_valid_ids_tab         OUT             NOCOPY wsh_util_core.id_tab_type,
        x_return_status         OUT             NOCOPY VARCHAR2,
        p_action                IN              VARCHAR2 DEFAULT NULL -- Added for bug fix 2657182
);

/*    ---------------------------------------------------------------------
     Procedure:	Lock_Dlvy_No_Compare

     Parameters:	Delivery Id.

     Description:  This procedure is used for obtaining locks of deliveries
                    using only the delivery id. This is called by the
                   wrapper lock API ,when the p_caller is NOT WSHFSTRX.
                    This procedure does not compare the attributes. It just
                    does a SELECT using FOR UPDATE NOWAIT
     Created:   Harmonization Project. Patchset I
     ----------------------------------------------------------------------- */


Procedure Lock_Dlvy_No_Compare(
        p_delivery_id     IN NUMBER);

PROCEDURE clone
    (
        p_delivery_rec   IN Delivery_Rec_Type,
        p_delivery_id    IN NUMBER,
        p_copy_legs      IN VARCHAR2 DEFAULT 'N',
        x_delivery_id   OUT NOCOPY NUMBER,
        x_rowid         OUT NOCOPY VARCHAR2,
        x_leg_id_tab    OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
        x_return_status OUT NOCOPY  VARCHAR2
    ) ;

--  Bug 3292364
--  Procedure:   Table_To_Record
--  Parameters:  x_delivery_rec: A record of all attributes of a Delivery Record
--               p_delivery_id : delivery_id of the delivery that is to be copied
--  Description: This procedure will copy the attributes of a delivery in wsh_new_deliveries
--               and copy it to a record.

PROCEDURE Table_to_Record (p_delivery_id IN NUMBER,
                           x_delivery_rec OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
                           x_return_status OUT NOCOPY VARCHAR2);

--OTM R12
PROCEDURE UPDATE_TMS_INTERFACE_FLAG (p_delivery_id_tab        IN         WSH_UTIL_CORE.ID_TAB_TYPE,
                                     p_tms_interface_flag_tab IN         WSH_UTIL_CORE.COLUMN_TAB_TYPE,
                                     x_return_status          OUT NOCOPY VARCHAR2);

--

END WSH_NEW_DELIVERIES_PVT;

/
