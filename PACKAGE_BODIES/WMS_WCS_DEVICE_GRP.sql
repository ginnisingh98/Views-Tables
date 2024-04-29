--------------------------------------------------------
--  DDL for Package Body WMS_WCS_DEVICE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WCS_DEVICE_GRP" AS
/* $Header: WMSWCSB.pls 120.10 2005/10/20 09:28:24 simran noship $ */

   --
   --
   PROCEDURE LOG (p_device_id IN NUMBER, p_data IN VARCHAR2);

   /*
   * Call WMS_Task_Dispatch_Device.get_device_info
   * And if the return status is "A" then it means that this device is already signed on.
   * Throw an error WMS_DEVICE_ALREADY_SIGNED. And make the x_return_status of the Open API "E"
   *
   * If the return status is "S" then this device is valid.
   * Call WMS_Task_Dispatch_Device. PROCEDURE insert_device
   * And make the x_return_status of the Open API "S"
   */
   PROCEDURE call_workflow
      (
             p_device_id        IN NUMBER,
             p_response_record  IN MSG_COMPONENT_LOOKUP_TYPE
       );

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
                  x_msg_data        OUT NOCOPY VARCHAR2)
   IS
      l_device_id NUMBER := -1; -- Returned by get_device_info API
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (l_debug = 1) THEN
         log
         (p_device_id,   'In DEVICE_SIGN_ON. Calling WMS_Task_Dispatch_Device.get_device_info with params...');
         log
         (p_device_id,   'p_organization_id='
          || p_organization_id
          || ', p_device_name='
          || p_device_name
          || ', p_employee_id='
          || p_employee_id
          );
      END IF;

   	--Call WMS_Task_Dispatch_Device.get_device_info
   	WMS_Task_Dispatch_Device.get_device_info
   	(p_organization_id     =>  p_organization_id,
   	 p_device_name         =>  p_device_name,
   	 x_return_status       =>  x_return_status,
   	 x_device_id           =>  l_device_id,
   	 x_device_type         =>  x_device_type,
   	 x_device_desc         =>  x_device_desc,
   	 x_subinventory        =>  x_subinventory,
   	 p_emp_id              =>  p_employee_id,
   	 x_signed_onto_wrk_stn =>  x_signon_wrk_stn);

      IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      	RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      	RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = 'A' THEN
         IF (l_debug = 1) THEN
           log
           (p_device_id,   'Device already signed on. l_device_id='
            || l_device_id
            || ', p_device_name='
            || p_device_name
            || ', p_employee_id='
            || p_employee_id
            || ', p_organization_id='
            || p_organization_id
            || ', x_device_type='
            || x_device_type
            || ', x_device_desc='
            || x_device_desc
            || ', x_subinventory='
            || x_subinventory
            || ', x_signon_wrk_stn='
            || x_signon_wrk_stn
           );
         END IF;

         fnd_message.set_name('WMS', 'WMS_DEVICE_ALREADY_SIGNED');
         fnd_message.set_token('DEVICE_DESC', x_device_desc);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
         RAISE fnd_api.G_EXC_ERROR;

      END IF;

      IF (l_debug = 1) THEN
         log
         (p_device_id,   'Device is not signed on. Calling WMS_Task_Dispatch_Device.insert_device.');
      END IF;

      WMS_Task_Dispatch_Device.insert_device
      (p_Employee_Id     =>  p_employee_id,
      p_device_id        =>  p_device_id,
      p_org_id           =>  p_organization_id,
      x_return_status    =>  x_return_status);

      IF (l_debug = 1) THEN
       log
       (p_device_id,   'Done inserting into temp table. p_employee_id='
        || p_employee_id
        || ', p_device_id='
        || p_device_id
        || ', p_organization_id='
        || p_organization_id
        || ', x_return_status='
        || x_return_status);
      END IF;

      --Commit for Autonmous transaction
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
            log
            (p_device_id,   'Unexpected error in DEVICE_SIGN_ON : '||SQLERRM);
         END IF;
   END DEVICE_SIGN_ON;

   --Wrapper call on WMS_Task_Dispatch_Device.cleanup_device_and_tasks
   PROCEDURE DEVICE_SIGN_OFF
                  (p_Employee_Id     IN          NUMBER,
                   p_org_id          IN          NUMBER,
                   x_return_status   OUT  NOCOPY VARCHAR2,
                   x_msg_count       OUT  NOCOPY NUMBER,
                   x_msg_data        OUT  NOCOPY VARCHAR2)
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (l_debug = 1) THEN
         log
         (NULL,   'In DEVICE_SIGN_OFF. Calling WMS_Task_Dispatch_Device.cleanup_device_and_tasks with params...');
         log
         (NULL,   'p_Employee_Id='
          || p_Employee_Id
          || ', p_org_id='
          || p_org_id);
      END IF;

      --Call WMS_Task_Dispatch_Device.cleanup_device_and_tasks
      WMS_Task_Dispatch_Device.cleanup_device_and_tasks
      (p_Employee_Id     =>  p_Employee_Id,
       p_org_id          =>  p_org_id,
       x_return_status   =>  x_return_status,
       x_msg_count       =>  x_msg_count,
       x_msg_data        =>  x_msg_data);

      IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      	RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      	RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
         log
         (NULL,   'Done cleaning up the temp table. x_return_status='
          || x_return_status
          );
      END IF;
      --Autonomous transaction commit
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
            log
            (NULL,   'Unexpected error in DEVICE_SIGN_OFF : '||SQLERRM);
         END IF;
   END DEVICE_SIGN_OFF;


   --Wrapper call on overloaded WMS_Task_Dispatch_Device.cleanup_device_and_tasks
   PROCEDURE SINGLE_DEVICE_SIGN_OFF
                  (p_Employee_Id     IN          NUMBER,
                   p_org_id          IN          NUMBER,
                   p_device_id       IN          NUMBER,
                   x_return_status   OUT  NOCOPY VARCHAR2,
                   x_msg_count       OUT  NOCOPY NUMBER,
                   x_msg_data        OUT  NOCOPY VARCHAR2)
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (l_debug = 1) THEN
         log
         (NULL,   'In SINGLE_DEVICE_SIGN_OFF. Calling overloaded WMS_Task_Dispatch_Device.cleanup_device_and_tasks with params...');
         log
         (NULL,   'p_Employee_Id='
          || p_Employee_Id
          || ', p_org_id='
          || p_org_id
          || ', p_device_id='
          || p_device_id);
      END IF;

      --Call overloaded WMS_Task_Dispatch_Device.cleanup_device_and_tasks
      WMS_Task_Dispatch_Device.cleanup_device_and_tasks
      (p_Employee_Id     =>  p_Employee_Id,
       p_org_id          =>  p_org_id,
       p_device_id       =>  p_device_id,
       x_return_status   =>  x_return_status,
       x_msg_count       =>  x_msg_count,
       x_msg_data        =>  x_msg_data);

      IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      	RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      	RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
         log
         (NULL,   'Done cleaning up the temp table. x_return_status='
          || x_return_status
          );
      END IF;
      --Autonomous transaction commit
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
            log
            (NULL,   'Unexpected error in SINGLE_DEVICE_SIGN_OFF : '||SQLERRM);
         END IF;
   END SINGLE_DEVICE_SIGN_OFF;


   --Wrapper call on WMS_Device_Integration_PVT.device_request - overloaded
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
   	p_trx_uom	            IN   VARCHAR2 := NULL,
   	p_rev                   IN   VARCHAR2 := NULL,
   	x_request_msg           OUT  NOCOPY VARCHAR2,
   	x_return_status         OUT  NOCOPY VARCHAR2,
   	x_msg_count             OUT  NOCOPY NUMBER,
   	x_msg_data              OUT  NOCOPY VARCHAR2,
   	p_request_id            IN OUT NOCOPY NUMBER,
   	p_device_id             IN   NUMBER
   )
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (l_debug = 1) THEN
         log
         (p_device_id,   'In DEVICE_REQUEST. Calling WMS_Device_Integration_PVT.DEVICE_REQUEST with params...');
         log
         (p_device_id,  'p_init_msg_list='
          || p_init_msg_list
          || ', p_bus_event='
          || p_bus_event
          || ', p_call_ctx='
          || p_call_ctx
          || ', p_task_trx_id='
          || p_task_trx_id
          || ', p_org_id='
          || p_org_id
          || ', p_item_id='
          || p_item_id
          || ', p_subinv='
          || p_subinv
          || ', p_locator_id='
          || p_locator_id
          || ', p_lpn_id='
          || p_lpn_id
          || ', p_xfr_org_id='
          || p_xfr_org_id
          || ', p_xfr_subinv='
          || p_xfr_subinv
          || ', p_xfr_locator_id='
          || p_xfr_locator_id
          || ', p_trx_qty='
          || p_trx_qty
          || ', p_trx_uom='
          || p_trx_uom
          || ', p_rev='
          || p_rev
          || ', p_request_id='
          || p_request_id);
       END IF;

       wms_device_integration_pvt.device_request(p_init_msg_list  => p_init_msg_list,
                                                 p_bus_event      => p_bus_event,
                                                 p_call_ctx       => p_call_ctx,
                                                 p_task_trx_id    => p_task_trx_id,
                                                 p_org_id         => p_org_id,
                                                 p_item_id        => p_item_id,
                                                 p_subinv         => p_subinv,
                                                 p_locator_id     => p_locator_id,
                                                 p_lpn_id         => p_lpn_id,
                                                 p_xfr_org_id     => p_xfr_org_id,
                                                 p_xfr_subinv     => p_xfr_subinv,
                                                 p_xfr_locator_id => p_xfr_locator_id,
                                                 p_trx_qty        => p_trx_qty,
                                                 p_trx_uom        => p_trx_uom,
                                                 p_rev            => p_rev,
                                                 x_request_msg    => x_request_msg,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_request_id     => p_request_id,
                                                 p_device_id      => p_device_id);

       IF (x_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;

       IF (l_debug = 1) THEN
          log
          (p_device_id,   'Done with wms_device_integration_pvt.device_request. x_return_status='
           || x_return_status
           || ', x_request_msg='
           || x_request_msg
           || ', x_msg_count'
           || x_msg_count
           || ', x_msg_data'
           || x_msg_data
           );
       END IF;

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
            log
            (p_device_id,   'Unexpected error in wms_device_integration_pvt.device_request : '||SQLERRM);
         END IF;
   END device_request;

   --Wrapper call on FUNCTION WMS_DEVICES_PKG.is_wcs_enabled
   FUNCTION IS_WCS_ENABLED(p_org_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_is_wcs_enabled VARCHAR2(1);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      l_is_wcs_enabled := (WMS_DEVICES_PKG.is_wcs_enabled(p_org_id => p_org_id));
      IF (l_debug = 1) THEN
         log
         (NULL,   'Done calling WMS_DEVICES_PKG.is_wcs_enabled. p_org_id='
          || p_org_id
          || ', l_is_wcs_enabled='
          || l_is_wcs_enabled);
      END IF;
      --Autonomous transaction commit
      COMMIT;
      RETURN l_is_wcs_enabled;
   EXCEPTION
      WHEN OTHERS THEN
         IF (l_debug = 1) THEN
            log
            (NULL,   'Unexpected error in IS_WCS_ENABLED : '||SQLERRM);
         END IF;
   END IS_WCS_ENABLED;

   --API to process the parsed device response for WMS specific business events
   PROCEDURE PROCESS_RESPONSE
                   (p_device_id           IN  NUMBER,
                    p_request_id          IN  NUMBER,
                    p_param_values_record IN  MSG_COMPONENT_LOOKUP_TYPE,
                    x_return_status       OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_msg_data            OUT NOCOPY VARCHAR2)
   IS
      l_successful_row_cnt NUMBER;
      l_request_id         NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      x_return_status    := fnd_api.g_ret_sts_success;
      IF l_debug >= 1 THEN
         LOG(p_device_id, 'In WMS_WCS_DEVICE_GRP.PROCESS_RESPONSE for p_request_id='
             ||p_request_id);
      END IF;

      --Check if the reason_id is populated. If it is then call the workflow wrapper API
      IF p_param_values_record.reason_id IS NOT NULL THEN
         IF l_debug > 0 THEN
            log(p_device_id, 'Reason Id in response is '
                                             ||p_param_values_record.reason_id);
            log(p_device_id, 'Call workflow wrapper API');
         END IF;
         call_workflow(
                      p_device_id        =>  p_device_id,
                      p_response_record  =>  p_param_values_record
                       );
      END IF;

      --If the business event is 18 or 19
      --(These are OPM business events 'Process Parameter Event' and 'Process Dispensing Event')
      --then call the OPM response API
      IF p_param_values_record.business_event IN (18,19) THEN
         IF l_debug >= 1 THEN
            log(p_device_id, 'Found an OPM business event:'
                                             || p_param_values_record.business_event);
            log(p_device_id, 'Calling the OPM response API');
         END IF;
         WMS_OPM_INTEGRATION_GRP.process_response
            (
               p_device_id           => p_device_id,
               p_request_id          => p_request_id,
               p_param_values_record => p_param_values_record,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data
            );
      ELSIF p_param_values_record.business_event = 54 THEN   --This if for TASK CONFIRM
         --This is for backward compatibility
         --INSERT into WDR
         INSERT INTO wms_device_requests
                     (relation_id,
                      task_id,
                      task_summary,
                      business_event_id,
                      organization_id,
                      device_status,
                      xfer_lpn_id,
                      last_update_date,
                      last_updated_by,
                      last_update_login
                     )
              VALUES (p_param_values_record.relation_id,
                      p_param_values_record.task_id,
                      p_param_values_record.task_summary,
                      p_param_values_record.business_event,
                      p_param_values_record.organization_id,
                      p_param_values_record.device_status,
                      p_param_values_record.transfer_lpn_id,
                      SYSDATE,
                      fnd_global.user_id,
                      fnd_global.login_id );

         --Pass the relation_id as the request id of the parent WDRH record
         l_request_id := to_number(p_param_values_record.relation_id);

         --Call the 11.5.10 OPEN API
         IF l_debug > 0 THEN
            log(p_device_id, 'Calling TC OPEN API wms_device_confirmation_pub.device_confirmation');            log(p_device_id, 'with param: l_request_id='||l_request_id);
         END IF;
         wms_device_confirmation_pub.device_confirmation
              (x_return_status       => x_return_status,
			       x_msg_count          => x_msg_count,
			       x_msg_data           => x_msg_data,
			       p_request_id         => l_request_id,
			       x_successful_row_cnt => l_successful_row_cnt
			      );
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
END PROCESS_RESPONSE;

PROCEDURE call_workflow
   (
          p_device_id        IN NUMBER,
          p_response_record  IN MSG_COMPONENT_LOOKUP_TYPE
    )
   IS
      l_wf    NUMBER;
      l_return_status VARCHAR2 (10);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2 (4000);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   BEGIN
     SELECT 1
       INTO l_wf
       FROM mtl_transaction_reasons
      WHERE reason_id = p_response_record.reason_id
        AND workflow_name IS NOT NULL
        AND workflow_name <> ' '
        AND workflow_process IS NOT NULL
        AND workflow_process <> ' ';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_wf  := 0;
   END;
   IF l_wf > 0 THEN
      IF l_debug > 0 THEN
          LOG(p_device_id, 'WF exists for this reason ID: '
                                           || p_response_record.reason_id);
          LOG(p_device_id, 'Calling wms_workflow_wrappers.wf_wrapper');
      END IF;

      wms_workflow_wrappers.wf_wrapper(
       p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_org_id                     => p_response_record.organization_id
      , p_rsn_id                     => p_response_record.reason_id
      , p_calling_program            => 'MHP: call_workflow'
      , p_tmp_id                     => p_response_record.task_id
      , p_quantity_picked            => p_response_record.quantity
      , p_dest_sub                   => p_response_record.destination_subinventory
      , p_dest_loc                   => p_response_record.destination_locator_id
      );

      IF (l_debug > 0) THEN
       LOG(p_device_id ,'After Calling wf_wrapper. l_return_status is '
                                        ||l_return_status);
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       IF (l_debug > 0) THEN
         LOG(p_device_id ,'Error calling wf_wrapper');
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
       IF (l_debug > 0) THEN
         LOG(p_device_id ,'Error calling wf_wrapper');
       END IF;
       fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
      END IF;
   END IF;
   --Autonomous transaction commit
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      l_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF (l_debug > 0) THEN
        LOG(p_device_id ,'Call_Workflow failed'||SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_count => l_msg_count,
                                p_data  => l_msg_data);
END call_workflow;

   --
   --
   PROCEDURE LOG (p_device_id in number, p_data IN VARCHAR2)
   IS
      cnt   NUMBER;
--      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      wms_carousel_integration_pvt.LOG(p_device_id,p_data);
      /*
      Commented out for Bug# 4624894

      INSERT INTO wms_carousel_log
                  (CAROUSEL_LOG_ID
                   ,text
                   ,device_id
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,CREATION_DATE
                   ,CREATED_BY
                   ,LAST_UPDATE_LOGIN
                  )
           VALUES (wms_carousel_log_s.NEXTVAL
                   ,p_data
                   ,p_device_id
                   ,SYSDATE
                   ,fnd_global.user_id
                   ,SYSDATE
                   ,fnd_global.user_id
                   ,fnd_global.login_id
                  );

      COMMIT;
      */
   END LOG;

END WMS_WCS_DEVICE_GRP;


/
