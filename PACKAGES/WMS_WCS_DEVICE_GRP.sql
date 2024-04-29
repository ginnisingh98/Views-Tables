--------------------------------------------------------
--  DDL for Package WMS_WCS_DEVICE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WCS_DEVICE_GRP" AUTHID CURRENT_USER AS
/* $Header: WMSWCSS.pls 120.6 2005/10/09 03:48:26 simran noship $ */

   --MHP
   TYPE msg_component_lookup_type IS RECORD (
      organization                     VARCHAR2 (200),
      order_number                     NUMBER,
      item                             VARCHAR2 (200),
      business_event                   NUMBER,
      action                           VARCHAR2 (4000),
      device_id                        NUMBER,
      host_id                          VARCHAR2 (400),
      subinventory                     VARCHAR2 (400),
      LOCATOR                          VARCHAR2 (400),
      lpn                              VARCHAR2 (400),
      lot                              VARCHAR2 (400),
      uom                              VARCHAR2 (400),
      cycle_count_id                   NUMBER,
      quantity                         NUMBER,
      requested_quantity               NUMBER,
      weight                           NUMBER,
      weight_uom_code                  VARCHAR2 (400),
      volume                           NUMBER,
      volume_uom_code                  VARCHAR2 (400),
      LENGTH                           NUMBER,
      width                            NUMBER,
      height                           NUMBER,
      dimensional_weight               NUMBER,
      dimensional_weight_factor        NUMBER,
      net_weight                       NUMBER,
      received_request_date_and_time   DATE,
      measurement_date_and_time        DATE,
      response_date_and_time           DATE,
      temperature                      NUMBER,
      temperature_uom                  VARCHAR2 (400),
      reason_id                        NUMBER,
      reason_type                      VARCHAR2 (400),
      sensor_measurement_type          VARCHAR2 (400),
      VALUE                            VARCHAR2 (400),
      quality                          NUMBER,
      opc_variant_code                 NUMBER,
      epc                              VARCHAR2 (4000),
      UNUSED                           VARCHAR2 (4000),
      batch                            VARCHAR2 (400),
      device_component_1               VARCHAR2 (4000),
      device_component_2               VARCHAR2 (4000),
      device_component_3               VARCHAR2 (4000),
      device_component_4               VARCHAR2 (4000),
      device_component_5               VARCHAR2 (4000),
      device_component_6               VARCHAR2 (4000),
      device_component_7               VARCHAR2 (4000),
      device_component_8               VARCHAR2 (4000),
      device_component_9               VARCHAR2 (4000),
      device_component_10              VARCHAR2 (4000),
      relation_id                      NUMBER,
      task_id                          NUMBER,
      task_summary                     VARCHAR2 (1),
      organization_id                  NUMBER,
      inventory_item_id                NUMBER,
      device_status                    VARCHAR2 (1),
      transfer_lpn_id                  NUMBER,
      destination_subinventory         VARCHAR2 (400),
      destination_locator_id           NUMBER,
      source_locator_id                NUMBER
	   );
   /*
   * Call WMS_Task_Dispatch_Device.get_device_info
   * And if the return status is "A" then it means that this device is already signed on.
   * Throw an error WMS_DEVICE_ALREADY_SIGNED. And make the x_return_status of the Open API "E"
   *
   * If the return status is "S" then this device is valid.
   * Call WMS_Task_Dispatch_Device. PROCEDURE insert_device
   * And make the x_return_status of the Open API "S"
   */
   PROCEDURE DEVICE_SIGN_ON
                 (p_device_id       IN         NUMBER,
                  p_device_name     IN         VARCHAR2,
                  p_employee_id     IN         NUMBER,
                  p_organization_id IN         NUMBER,
                  x_device_type     OUT NOCOPY VARCHAR2,
                  x_device_desc     OUT NOCOPY VARCHAR2,
                  x_subinventory    OUT NOCOPY VARCHAR2,
                  x_signon_wrk_stn  OUT NOCOPY VARCHAR2,
                  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2);

   --Wrapper call on WMS_Task_Dispatch_Device.cleanup_device_and_tasks
   PROCEDURE DEVICE_SIGN_OFF
                  (p_Employee_Id     IN          NUMBER,
                   p_org_id          IN          NUMBER,
                   x_return_status   OUT  NOCOPY VARCHAR2,
                   x_msg_count       OUT  NOCOPY NUMBER,
                   x_msg_data        OUT  NOCOPY VARCHAR2);


   --Wrapper call on overloaded WMS_Task_Dispatch_Device.cleanup_device_and_tasks
   PROCEDURE SINGLE_DEVICE_SIGN_OFF
                  (p_Employee_Id     IN          NUMBER,
                   p_org_id          IN          NUMBER,
                   p_device_id       IN          NUMBER,
                   x_return_status   OUT  NOCOPY VARCHAR2,
                   x_msg_count       OUT  NOCOPY NUMBER,
                   x_msg_data        OUT  NOCOPY VARCHAR2);


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

   --Wrapper call on FUNCTION WMS_DEVICES_PKG.is_wcs_enabled
   FUNCTION IS_WCS_ENABLED(p_org_id IN NUMBER)
      RETURN VARCHAR2;

   --API to process the parsed device response for WMS specific business events
   PROCEDURE PROCESS_RESPONSE
                   (p_device_id           IN NUMBER,
                    p_request_id          IN NUMBER,
                    p_param_values_record IN  MSG_COMPONENT_LOOKUP_TYPE,
                    x_return_status       OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_msg_data            OUT NOCOPY VARCHAR2);


END WMS_WCS_DEVICE_GRP;

 

/
