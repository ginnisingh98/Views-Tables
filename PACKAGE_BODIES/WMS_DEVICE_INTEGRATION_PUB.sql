--------------------------------------------------------
--  DDL for Package Body WMS_DEVICE_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEVICE_INTEGRATION_PUB" AS
/* $Header: WMSDEVIB.pls 120.1 2005/06/03 09:59:16 appldev  $ */

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
--    table WMS_DEVICE_REQUEST.
--
-- Input Parameters
--   p_request_id    : Request ID
--   p_device_id     : Device ID of the device this request is initiated for
--   p_resubmit_flag : N - Invoked in conjunction with processing transaction
--                     Y - Invoked to resubmit a request to device
--
-- Output Parameters
--   x_status_code  :  Status of request. ( S = Success, E = Error)
--   x_status_msg   :  Optional status message related to this specific request
--   x_device_status: Optional status message related to the device
--
--
  PROCEDURE SYNC_DEVICE_REQUEST(
     p_request_id            IN  NUMBER,
     p_device_id             IN  NUMBER,
     p_resubmit_flag         IN  VARCHAR2,
     x_status_code          OUT NOCOPY VARCHAR2,
     x_status_msg           OUT NOCOPY VARCHAR2,
     x_device_status        OUT NOCOPY VARCHAR2 ) IS
	BEGIN
   x_status_msg := 'Success';
   x_device_status := 'Success';
   x_status_code := FND_API.g_ret_sts_success;
	END;


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
	PROCEDURE UPDATE_REQUEST(
			p_request_id           IN   NUMBER,
			p_device_id            IN   NUMBER := NULL,
			p_status_code          IN   VARCHAR2,
			p_status_msg           IN   VARCHAR2 := NULL
		) IS
	BEGIN
		UPDATE WMS_DEVICE_REQUESTS_HIST
			SET STATUS_CODE = p_status_code,
					STATUS_MSG  = p_status_msg
			WHERE
						REQUEST_ID  = p_request_id
				AND DEVICE_ID   = NVL(p_device_id, DEVICE_ID);
	END;


	--
-- Name
--   PROCEDURE SYNC_DEVICE
--
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
--	                 terminates the device.
--   p_sign_on_flag    : 'Y' when signing on
--                       'N' when signing off
--
-- Output Parameters
--   x_status_code  :  Status of request. ( S = Success, E = Error)
--   x_device_status:  Optional status message related to the device
--
--
  PROCEDURE SYNC_DEVICE(
			p_organization_id      IN  NUMBER,
			p_device_id            IN  NUMBER,
			p_employee_id          IN  NUMBER,
			p_sign_on_flag         IN  VARCHAR2,
			x_status_code          OUT NOCOPY VARCHAR2,
			x_device_status        OUT NOCOPY VARCHAR2 ) IS
  BEGIN
     x_device_status := 'Success';
     x_status_code := FND_API.g_ret_sts_success;
  END;


END WMS_Device_Integration_PUB;

/
