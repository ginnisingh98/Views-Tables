--------------------------------------------------------
--  DDL for Package WMS_DEVICE_INTEGRATION_WCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DEVICE_INTEGRATION_WCS" AUTHID CURRENT_USER AS
/* $Header: WMSDVPBS.pls 120.0 2005/05/24 18:06:40 appldev noship $ */

   --
-- Name
--   PROCEDURE SYNC_DEVICE_REQUEST
--
-- Purpose
--    This procedure is meant to initiate a request to a WMS Device.
--    It is expected that 3rd party device vendors would extend this
--    package to implement the actual logic required to interface with
--    the device.
--      The primary source of input to this package would be the Temporary
--    table WMS_DEVICE_REQUEST. Depending on the level of details desired,
--     the records in this table will be 'join'ed with other tables.
--
--         MTL_SYSTEM_ITEMS           -  Item
--         MTL_ITEM_LOCATIONS         -  Location
--         MTL_PARAMETERS             -  Organization
--         WMS_LICENSE_PLATE_NUMBERS  -  LPN
--
-- Input Parameters
--   p_request_id    : Request Id
--   p_device_id     : Device ID of the device this request is initiated for
--   p_resubmit_flag : N - Invoked in conjunction with processing transaction
--                     Y - Invoked to resubmit a request to device
--
-- Output Parameters
--   x_status_code  :  Status of request. ( S = Success, E = Error)
--   x_status_msg   :  Optional status message related to this specific request
--   x_device_status: Optional status message related to the device
--
-- Implementation Example
--     A short example of an implementation of this Stub API is given below.
--   This example procedure opens a cursor to WMS_DEVIVE_REQUESTS and join
--    of other tables to retrieve details of the request. Each request
--     record is then packed and send across a database-pipe. A receiving
--     program could then wait on this Pipe and pass the data to
--     the actual device.
--
--  PROCEDURE SYNC_DEVICE_REQUEST(
--    p_request_id            IN   NUMBER,
--    p_device_id             IN   NUMBER,
--    p_resubmit_flag         IN   VARCHAR2,
--    x_status_code          OUT  VARCHAR2,
--    x_status_msg           OUT  VARCHAR2,
--    x_device_status        OUT  VARCHAR2 ) IS
-- cursor crs_wdr is
--    select  wd.name,
--                ml1.meaning business_event,
--                wdr.subinventory_code ,
--                mil.CONCATENATED_SEGMENTS locator,
--                WLPN.license_plate_number lpn,
--                msi.segment1 item,
--                wdr.transaction_quantity   quantity
--    from wms_devices wd,
--        mfg_lookups ml1,
--          wms_device_requests wdr,
--          mtl_item_locations_kfv mil, WMS_license_plate_numbers WLPN,
--          mtl_system_items msi
--    where
--            ml1.LOOKUP_TYPE = 'WMS_BUS_EVENT_TYPES'
--       and ml1.LOOKUP_CODE = wdr.business_event_id
--       and wd.device_id  = wdr.device_id
--       and mil.ORGANIZATION_ID (+) = wdr.organization_id
--       and mil.SUBINVENTORY_CODE(+) = wdr.SUBINVENTORY_CODE
--       and mil.INVENTORY_LOCATION_ID(+) = wdr.LOCATOR_ID
--       and WLPN.lpn_id(+) = wdr.lpn_id
--       and msi.organization_id(+) = wdr.organization_id
--       and msi.inventory_item_id(+) = wdr.inventory_item_id
--       and wdr.device_id = p_device_id;
-- l_stat number;
-- l_pipename varchar2(32) := 'devoutpipe';
-- l_packedonce boolean := false;
--BEGIN
--  for curreq in crs_wdr loop
--    dbms_output.put_line('** start of  Line **');
--    if ( l_packedonce != true ) then
--       dbms_pipe.pack_message(curreq.name);
--       l_packedonce := true;
--    end if;
--    dbms_pipe.pack_message(curreq.business_event);
--    dbms_pipe.pack_message(curreq.subinventory_code);
--    dbms_pipe.pack_message(substr(curreq.locator, 1, 15));
--    dbms_pipe.pack_message(curreq.lpn);
--    dbms_pipe.pack_message(curreq.item);
--    dbms_pipe.pack_message(curreq.quantity);
-- end loop;
-- dbms_pipe.pack_message('_STOP_');
-- l_stat := dbms_pipe.send_message(l_pipename);
-- if l_stat != 0 then
--    inv_trx_util_pub.trace('Error in sending to pipe', 'DEVINT', 1);
--    x_status_code := 'E';
-- else
--    inv_trx_util_pub.trace('OK in sending to pipe', 'DEVINT', 6);
--    x_status_code := 'S';
-- end if;
--END;
--
---
------------------------------------------------------------------------
   PROCEDURE sync_device_request (
      p_request_id      IN              NUMBER,
      p_device_id       IN              NUMBER,
      p_resubmit_flag   IN              VARCHAR2,
      x_status_code     OUT NOCOPY      VARCHAR2,
      x_status_msg      OUT NOCOPY      VARCHAR2,
      x_device_status   OUT NOCOPY      VARCHAR2
   );

--
-- Name
--   UPDATE_REQUEST
--
-- Purpose
--    This procedure is provided to update the status of a request
--    from a transaction cycle seperate from the one in which the
--    request was initiated. This is meant to update a device request
--    in an asynchronous mode.
--
-- Input Parameters
--   p_request_id    : Request Id
--   p_device_id     : Device Identifier, if data comprising this request was
--                       directed to multiple devices
--   p_status_code  :  Status of request. ( S = Success, E = Error)
--   p_status_msg   :  Optional status message related to this specific request
--
--
   PROCEDURE update_request (
      p_request_id    IN   NUMBER,
      p_device_id     IN   NUMBER := NULL,
      p_status_code   IN   VARCHAR2,
      p_status_msg    IN   VARCHAR2 := NULL
   );

-- Name
--   PROCEDURE:  SYNC_DEVICE
--   Package Name: WMS_DEVICE_INTEGRATION_PUB
-- Purpose
--    This procedure is meant to invoke or terminate a WMS Device.
--    It is expected that 3rd party device vendors would extend this
--    package to implement the actual logic required to interface with
--    the device.
--
-- Input Parameters
--   p_organization_id : Request ID
--   p_device_id       : Device ID of the device
--   p_employee_id     : Employee ID of the employee who invokes or
--                       terminates the device.
--   p_sign_on_flag    : 'Y' when signing on
--                       'N' when signing off
--
-- Output Parameters
--   x_status_code  :  Return Status. ( S = Success, E = Error)
--   x_device_status:  Optional status message related to the device
--
--
   PROCEDURE sync_device (
      p_organization_id   IN              NUMBER,
      p_device_id         IN              NUMBER,
      p_employee_id       IN              NUMBER,
      p_sign_on_flag      IN              VARCHAR2,
      x_status_code       OUT NOCOPY      VARCHAR2,
      x_device_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE signoff_msg_to_out_pipe (
      p_device_id          IN           VARCHAR2,
      p_message            IN           VARCHAR2,
      x_pipe_name          OUT NOCOPY   VARCHAR2,
      x_message_code       OUT NOCOPY   NUMBER,
      x_return_status      OUT NOCOPY   VARCHAR2,
      x_msg_count          OUT NOCOPY   NUMBER,
      x_msg_data           OUT NOCOPY   VARCHAR2
   );

END WMS_DEVICE_INTEGRATION_WCS;

 

/
