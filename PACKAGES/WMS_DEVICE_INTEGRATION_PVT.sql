--------------------------------------------------------
--  DDL for Package WMS_DEVICE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEVICE_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSDEVPS.pls 120.2.12010000.4 2009/09/25 13:25:39 pbonthu ship $ */


---------------------------------------------------------------------
-- Global constants for Business Events
--   These constants defined in MFG_LOOKUP for type WMS_BUS_EVENT_TYPE
---------------------------------------------------------------------
WMS_BE_DIRECT_RECEIPT     CONSTANT NUMBER := 1;
WMS_BE_INSPECTION         CONSTANT NUMBER := 2;
WMS_BE_PUTAWAY_DROP       CONSTANT NUMBER := 3;
WMS_BE_CYCLE_COUNT        CONSTANT NUMBER := 4;
WMS_BE_RECEIPT            CONSTANT NUMBER := 5;
WMS_BE_ISSUE              CONSTANT NUMBER := 6;
WMS_BE_SUB_XFR            CONSTANT NUMBER := 7;
WMS_BE_ORG_XFR            CONSTANT NUMBER := 8;
WMS_BE_PICK_DROP          CONSTANT NUMBER := 9;
WMS_BE_PICK_LOAD          CONSTANT NUMBER := 10;
WMS_BE_PICK_RELEASE       CONSTANT NUMBER := 11;
WMS_BE_WIP_PICK_RELEASE   CONSTANT NUMBER := 12;
WMS_BE_SHIP_CONFIRM       CONSTANT NUMBER := 13;
wms_be_mo_task_alloc      CONSTANT NUMBER := 17;

-- Following 4 numbers have been changed in patch set I
WMS_BE_TASK_COMPLETE      CONSTANT NUMBER := 51;
WMS_BE_TASK_SKIP          CONSTANT NUMBER := 52;
WMS_BE_TASK_CANCEL        CONSTANT NUMBER := 53;
WMS_BE_TASK_CONFIRM       CONSTANT NUMBER := 54;
wms_be_load_confirm       CONSTANT NUMBER := 56;

-- Following 4 numbers have been added in patch set J
WMS_BE_TRUCK_LOAD	CONSTANT NUMBER := 14;
WMS_BE_TRUCK_LOAD_SHIP 	CONSTANT NUMBER := 15;
WMS_BE_STD_INSP_RECEIPT	CONSTANT NUMBER := 16;

WMS_BE_RFID_ERROR	CONSTANT NUMBER := 55;



---------------------------------------------------------------------
-- Global constants for WMS IO Types
--   These constants defined in MFG_LOOKUP for type WMS_DEVICE_IO_TYPES
---------------------------------------------------------------------
WMS_DEV_IO_XML       CONSTANT NUMBER := 1;
WMS_DEV_IO_API       CONSTANT NUMBER := 2;
WMS_DEV_IO_TABLE     CONSTANT NUMBER := 3;
WMS_DEV_IO_CSV       CONSTANT NUMBER := 4;


---------------------------------------------------------------------
-- Global constants for Device Level Types for mapping to Business Events
--
---------------------------------------------------------------------
DEVICE_LEVEL_NONE      CONSTANT NUMBER := 0;
DEVICE_LEVEL_ORG       CONSTANT NUMBER := 100;
DEVICE_LEVEL_SUB       CONSTANT NUMBER := 200;
DEVICE_LEVEL_LOCATOR   CONSTANT NUMBER := 300;
DEVICE_LEVEL_USER      CONSTANT NUMBER := 400;

--Global variable to indicate whether to take any device_request specific
--action, OR to call DEVICE_REQUEST api
wms_call_device_request NUMBER; -- 0 = No, 1 = Yes
--Global variable for pick_release only, to stamp request_id for the
--complete batch inside allocation engine
wms_pkRel_dev_req_id NUMBER;
--Global variable
wms_insert_lotSer_rec_WDR NUMBER :=0;-- 0 = No, 1 = Yes


---------------------------------------------------------------------
--  Global constants for XML tag for DEVICE and TASK
---------------------------------------------------------------------
XML_HEADER CONSTANT VARCHAR2(100) := '<?xml version = ''1.0''?>';
TAG_E     CONSTANT VARCHAR2(1) := '>';
DEVICEH_TB CONSTANT VARCHAR2(15) := '<DEVICE';
DEVICE_TE CONSTANT VARCHAR2(15) := '</DEVICE>';
TASK_TB   CONSTANT VARCHAR2(15) := ' <TASK>';
TASK_TE   CONSTANT VARCHAR2(15) := ' </TASK>';
DEVICE_TB CONSTANT VARCHAR2(15) := '  <DEVICE>';
REQUESTID_TB	CONSTANT VARCHAR2(15) := '  <REQUESTID>';
REQUESTID_TE CONSTANT VARCHAR2(15) := '</REQUESTID>';
RELATIONID_TB	CONSTANT VARCHAR2(15) := '  <RELATIONID>';
RELATIONID_TE CONSTANT VARCHAR2(15) := '</RELATIONID>';
TASKTYPE_TB	CONSTANT VARCHAR2(15) := '  <TASKTYPE>';
TASKTYPE_TE CONSTANT VARCHAR2(15) := '</TASKTYPE>';
BUSINESSEVENT_TB	CONSTANT VARCHAR2(20) := '  <BUSINESSEVENT>';
BUSINESSEVENT_TE CONSTANT VARCHAR2(20) := '</BUSINESSEVENT>';
TASKID_TB	CONSTANT VARCHAR2(15) := '  <TASKID>';
TASKID_TE CONSTANT VARCHAR2(15) := '</TASKID>';
SEQUENCEID_TB	CONSTANT VARCHAR2(15) := '  <SEQUENCEID>';
SEQUENCEID_TE CONSTANT VARCHAR2(15) := '</SEQUENCEID>';
ORG_TB	CONSTANT VARCHAR2(15) := '  <ORG>';
ORG_TE CONSTANT VARCHAR2(15) := '</ORG>';
SUB_TB	CONSTANT VARCHAR2(15) := '  <SUB>';
SUB_TE CONSTANT VARCHAR2(15) := '</SUB>';
LOC_TB	CONSTANT VARCHAR2(15) := '  <LOC>';
LOC_TE CONSTANT VARCHAR2(15) := '</LOC>';
TRANSFERORG_TB	CONSTANT VARCHAR2(15) := '  <TRANSFERORG>';
TRANSFERORG_TE CONSTANT VARCHAR2(15) := '</TRANSFERORG>';
TRANSFERSUB_TB	CONSTANT VARCHAR2(15) := '  <TRANSFERSUB>';
TRANSFERSUB_TE CONSTANT VARCHAR2(15) := '</TRANSFERSUB>';
TRANSFERLOC_TB	CONSTANT VARCHAR2(15) := '  <TRANSFERLOC>';
TRANSFERLOC_TE CONSTANT VARCHAR2(15) := '</TRANSFERLOC>';
LPN_TB	CONSTANT VARCHAR2(15) := '  <LPN>';
LPN_TE CONSTANT VARCHAR2(15) := '</LPN>';
XFERLPN_TB	CONSTANT VARCHAR2(15) := '  <XFERLPN>';   --Added for Bug#8512121
XFERLPN_TE CONSTANT VARCHAR2(15) := '</XFERLPN>';   --Added for Bug#8512121
ITEM_TB	CONSTANT VARCHAR2(15) := '  <ITEM>';
ITEM_TE CONSTANT VARCHAR2(15) := '</ITEM>';
REVISION_TB	CONSTANT VARCHAR2(15) := '  <REVISION>';
REVISION_TE CONSTANT VARCHAR2(15) := '</REVISION>';
QUANTITY_TB	CONSTANT VARCHAR2(15) := '  <QUANTITY>';
QUANTITY_TE CONSTANT VARCHAR2(15) := '</QUANTITY>';
UOM_TB	CONSTANT VARCHAR2(15) := '  <UOM>';
UOM_TE CONSTANT VARCHAR2(15) := '</UOM>';
LOT_TB	CONSTANT VARCHAR2(15) := '  <LOT>';
LOT_TE CONSTANT VARCHAR2(15) := '</LOT>';
LOTQTY_TB	CONSTANT VARCHAR2(15) := '  <LOTQTY>';
LOTQTY_TE CONSTANT VARCHAR2(15) := '</LOTQTY>';
SERIAL_TB	CONSTANT VARCHAR2(15) := '  <SERIAL>';
SERIAL_TE CONSTANT VARCHAR2(15) := '</SERIAL>';
SO_TB	CONSTANT VARCHAR2(15) := '  <ORDERNUMBER>';
SO_TE   CONSTANT VARCHAR2(15) := '</ORDERNUMBER>';

--For RFID
TIMESTAMP_TB  CONSTANT VARCHAR2(15) := '<TIMESTAMP>';
TIMESTAMP_TE  CONSTANT VARCHAR2(15) := '</TIMESTAMP>';
ERRORCODE_TB  CONSTANT VARCHAR2(15) := '<ERRORCODE>';
ERRORCODE_TE  CONSTANT VARCHAR2(15) := '</ERRORCODE>';

---------------------------------------------------------------------
--  Global constants for Calling Context
---------------------------------------------------------------------
DEV_REQ_AUTO CONSTANT VARCHAR2(10) := 'A';   -- Auto
DEV_REQ_USER CONSTANT VARCHAR2(10) := 'U';   -- User Initiated




---------------------------------------------------------------------
--   PROCEDURE DEVICE_REQUEST
--
-- Purpose
--  To initiate a request to a device, in the context of processing
--  a transaction. The details of the transactions can be passed
--  either directly or with reference to a transaction table. If Lot or
--  Serial details have to be passed, then the Transaction-reference
--  HAS to be used.
--  The context of the transaction is specified by the BusinessEvent
--  and the Calling-Context. BusinessEvent roughly specified the
--  transaction type. Calling-Context indicates whether this request
--  is being made in response to the user explicitly pressing some
--  control-key or automatically from the Mobile page.
--
-- Input Parameters
--  p_bus_event   : Business Event in the context of which this request
--                   is initiated  (Globals defined above )
--	p_call_ctx    : Calling Context :Automatic, User-Initiated
--                                  (Globals defined above)
--  p_task_trx_id : Reference to Transaction
--   DELIVERY_DETAIL_ID of WSH_DELIVERY_DETAILS for BusEvent:Ship-Confirm
--   HEADER_ID of MTL_TXN_REQUEST_LINES for BusEvent:PickRelease, WIPPickRelease
--   TRANSACTION_TEMP_ID of MTL_MATERIAL_TRANSACTIONS_TEMP: for all other BusEvnts
--  p_org_id      : Orgainzation Id
--  p_item_id     : Inventory Item Id
--  p_subinv      : Subinventory Code
--  p_locator_id  : Locator Id
--  p_lpn_id      : LPN Id
--  p_xfr_org_id  : Transfer Organization Id
--  p_xfr_subinv  : Transfer Subinventory Code
--  p_xfr_locator_id : Transfer Locator Id
--  p_trx_qty     : Transaction Quantity
--  p_trx_uom     : Transaction UOM
--  p_rev         : Revision
--
-- Input/Output Parameter
--  p_request_id    : For business event 'Task Complete', it is an input parameter
--                     indicating the parent request ID
--                    For other busniess event, it is an output parameter
--                     indicating the request ID of the new device request
--
-- Output Parameters
--  x_return_status : Return status: FND_API.G_RET_STS_SUCCESS, .G_RET_STS_FAILURE
--  x_request_msg   : Any informational message from device
--  x_msg_count     : Error Message Count
--  x_msg_data      : Error Message
--
--
---------------------------------------------------------------------
PROCEDURE DEVICE_REQUEST(
	p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false,
	p_bus_event             IN   NUMBER,
	p_call_ctx              IN   VARCHAR2 ,
	p_task_trx_id           IN   NUMBER := NULL,
	p_org_id                IN   NUMBER := NULL,
	p_item_id               IN   NUMBER := NULL,
	p_subinv                IN   VARCHAR2 := NULL,
	p_locator_id            IN   NUMBER := NULL,
	p_lpn_id                IN   NUMBER := NULL,
	p_xfer_lpn_id           IN   NUMBER := NULL,  --Added for Bug#8778050
	p_xfr_org_id            IN   NUMBER := NULL,
	p_xfr_subinv            IN   VARCHAR2 := NULL,
	p_xfr_locator_id        IN   NUMBER := NULL,
	p_trx_qty               IN   NUMBER := NULL,
	p_trx_uom	        IN   VARCHAR2 := NULL,
	p_rev                   IN   VARCHAR2 := NULL,
	x_request_msg           OUT  NOCOPY VARCHAR2,
	x_return_status         OUT  NOCOPY VARCHAR2,
	x_msg_count             OUT  NOCOPY NUMBER,
	x_msg_data              OUT  NOCOPY VARCHAR2,
	p_request_id            IN OUT NOCOPY NUMBER
);

PROCEDURE DEVICE_REQUEST(
	p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false,
	p_bus_event             IN   NUMBER,
	p_call_ctx              IN   VARCHAR2 ,
	p_task_trx_id           IN   NUMBER := NULL,
	p_org_id                IN   NUMBER := NULL,
	p_item_id               IN   NUMBER := NULL,
	p_subinv                IN   VARCHAR2 := NULL,
	p_locator_id            IN   NUMBER := NULL,
	p_lpn_id                IN   NUMBER := NULL,
	p_xfr_org_id            IN   NUMBER := NULL,
	p_xfr_subinv            IN   VARCHAR2 := NULL,
	p_xfr_locator_id        IN   NUMBER := NULL,
	p_trx_qty               IN   NUMBER := NULL,
	p_trx_uom	        IN   VARCHAR2 := NULL,
	p_rev                   IN   VARCHAR2 := NULL,
	x_request_msg           OUT  NOCOPY VARCHAR2,
	x_return_status         OUT  NOCOPY VARCHAR2,
	x_msg_count             OUT  NOCOPY NUMBER,
	x_msg_data              OUT  NOCOPY VARCHAR2
);

--WMS-OPM
PROCEDURE DEVICE_REQUEST(
	p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false,
	p_bus_event             IN   NUMBER,
	p_call_ctx              IN   VARCHAR2 ,
	p_task_trx_id           IN   NUMBER := NULL,
	p_org_id                IN   NUMBER := NULL,
	p_item_id               IN   NUMBER := NULL,
	p_subinv                IN   VARCHAR2 := NULL,
	p_locator_id            IN   NUMBER := NULL,
	p_lpn_id                IN   NUMBER := NULL,
	p_xfr_org_id            IN   NUMBER := NULL,
	p_xfr_subinv            IN   VARCHAR2 := NULL,
	p_xfr_locator_id        IN   NUMBER := NULL,
	p_trx_qty               IN   NUMBER := NULL,
	p_trx_uom	        IN   VARCHAR2 := NULL,
	p_rev                   IN   VARCHAR2 := NULL,
	x_request_msg           OUT  NOCOPY VARCHAR2,
	x_return_status         OUT  NOCOPY VARCHAR2,
	x_msg_count             OUT  NOCOPY NUMBER,
	x_msg_data              OUT  NOCOPY VARCHAR2,
	p_request_id            IN OUT NOCOPY NUMBER,
	p_device_id             IN   NUMBER
);

---------------------------------------------------------------------
--   PROCEDURE RESUBMIT_REQUEST
--
-- Purpose: To resubmit a device request .
--   It is used by concurrent program WMSDEVRR
--
-- Input Parameters
--	p_request_id, p_task_trx_id, p_sequence_id to identify the request line
-- Output Parameters
--	return status and error messages
---------------------------------------------------------------------
PROCEDURE RESUBMIT_REQUEST(
	x_retcode       OUT   NOCOPY VARCHAR2,
	x_errbuf        OUT   NOCOPY VARCHAR2,
	p_request_id    IN    NUMBER,
	p_device_id     IN    NUMBER := null,
	p_task_trx_id   IN    NUMBER := null,
        p_sequence_id   IN    NUMBER := NULL,
        P_business_event_id   IN   NUMBER
);



/* OBSOLETED :this procedure has been moved to WMSPURGS.pls/WMSPURGB.pls */
-------------------------------------------------------------------------
-- PROCEDURE TO purge wms TABLES
--
--  Purpose: Concurrent Program to puge obsolete data from WMS tables
--   The following tables are obsoleted
--    * wms_device_requests_hist
--    * wms_lpn_histories
--    * wms_dispatched_tasks_history
--    * wms_exceptions
--    * wms_lpn_process_temp
--
--------------------------------------------------------------------------
/*PROCEDURE purge_wms(
	x_errbuf        OUT     NOCOPY VARCHAR2,
	x_retcode       OUT     NOCOPY NUMBER,
	p_purge_date    IN      DATE,
	p_orgid         IN      NUMBER,
	p_purge_name    IN      VARCHAR2
	  );
 */

-------------------------------------------------------------------------
-- PROCEDURE populate_history
--
--  Purpose:  to populate the history table from wms_device_request table
-------------------------------------------------------------------------
PROCEDURE populate_history(
                           p_call_ctx              IN   VARCHAR2 := NULL,
			   p_bus_event             IN   NUMBER := NULL,
			   x_device_records_exist OUT NOCOPY VARCHAR2
			   );

PROCEDURE trace(p_msg IN VARCHAR2
		, p_level IN NUMBER DEFAULT 1);


PROCEDURE is_device_set_up(p_org_id NUMBER,
			   p_bus_event_id NUMBER DEFAULT NULL,
			   x_return_status OUT NOCOPY VARCHAR2 );


FUNCTION select_Device(wdrrec WMS_DEVICE_REQUESTS%ROWTYPE,
		       p_autoenable VARCHAR2,
		       p_parent_request_id NUMBER
		       ) return NUMBER;


FUNCTION generate_xml_csv(p_device_id NUMBER,
			  p_iotype NUMBER
			  ) return NUMBER;

END WMS_Device_Integration_PVT;





/
