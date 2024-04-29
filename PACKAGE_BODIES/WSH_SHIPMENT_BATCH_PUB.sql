--------------------------------------------------------
--  DDL for Package Body WSH_SHIPMENT_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPMENT_BATCH_PUB" as
/* $Header: WSHSBPBB.pls 120.0.12010000.1 2010/02/25 17:21:19 sankarun noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIPMENT_BATCH_PUB';

--========================================================================
-- PROCEDURE : Create_Shipment_Batch         PUBLIC
--
-- PARAMETERS: p_api_version_number    version number of the API
--             p_init_msg_list         messages will be initialized if set as true
--             p_process_mode          'ONLINE' or 'CONCURRENT', Default Value 'CONCURRENT'
--             p_organization_id       Organization Id
--             p_customer_id           Customer Id
--             p_ship_to_location_id   Ship From Location
--             p_transaction_type_id   Sales Order Type Id
--             p_from_order_number     From Sales Order Number
--             p_to_order_number       To Sales Order Number
--             p_from_request_date     From Request Date
--             p_to_request_date       To Request Date
--             p_from_schedule_date    From Schedule Date
--             p_to_schedule_date      To Schedule Date
--             p_shipment_priority     Shipment Priority Code
--             p_include_internal_so   Include Internal Sales Order
--             p_log_level             0 or 1 to control the log messages, Default Value 0
--             p_commit                Commit Flag
--             x_request_id            Concurrent Request Id submitted for 'Create Shipment Batches' program
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Public API to create shipment batches.
--
--========================================================================

/*#
 * Creates Shipment Batches
 * @param p_api_version_number    version number of the API
 * @param p_init_msg_list         messages will be initialized if set as true
 * @param p_process_mode          ONLINE or CONCURRENT mode to create shipment batches. Default value 'CONCURRENT'
 * @param p_organization_id       Organization Id
 * @param p_customer_id           Customer Id
 * @param p_ship_to_location_id   Ship From Location
 * @param p_transaction_type_id   Sales Order Type Id
 * @param p_from_order_number     From Sales Order Number
 * @param p_to_order_number       To Sales Order Number
 * @param p_from_request_date     From Request Date
 * @param p_to_request_date       To Request Date
 * @param p_from_schedule_date    From Schedule Date
 * @param p_to_schedule_date      To Schedule Date
 * @param p_shipment_priority     Shipment Priority Code
 * @param p_include_internal_so   Include Internal Sales Order
 * @param p_log_level             Controls the log messages generated, Default Value 0
 * @param p_commit                commit flag
 * @param x_request_id            Concurrent request Id of the 'Create Shipment Batches' program
 * @param x_return_status         return status of the API
 * @param x_msg_count             number of messages, if any
 * @param x_msg_data              message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Shipment Batches
 */
  PROCEDURE Create_Shipment_Batch(
            p_api_version_number   IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2,
            p_process_mode         IN  VARCHAR2,
            p_organization_id      IN  NUMBER,
            p_customer_id          IN  NUMBER,
            p_ship_to_location_id  IN  NUMBER,
            p_transaction_type_id  IN  NUMBER,
            p_from_order_number    IN  VARCHAR2,
            p_to_order_number      IN  VARCHAR2,
            p_from_request_date    IN  DATE,
            p_to_request_date      IN  DATE,
            p_from_schedule_date   IN  DATE,
            p_to_schedule_date     IN  DATE,
            p_shipment_priority    IN  VARCHAR,
            p_include_internal_so  IN  VARCHAR,
            p_log_level            IN  NUMBER,
            p_commit               IN  VARCHAR2,
            x_request_id           OUT NOCOPY  NUMBER,
            x_return_status        OUT NOCOPY  VARCHAR2,
            x_msg_count            OUT NOCOPY  NUMBER,
            x_msg_data             OUT NOCOPY  VARCHAR2 )
AS
   --
   l_return_status          VARCHAR2(100);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(1000);

   l_from_request_date      VARCHAR2(30);
   l_to_request_date        VARCHAR2(30);
   l_from_schedule_date     VARCHAR2(30);
   l_to_schedule_date       VARCHAR2(30);

   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30):= 'Create_Shipment_Batch';
   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || l_api_name;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name, 'p_commit',p_commit);
      WSH_DEBUG_SV.log(l_module_name, 'p_log_level',p_log_level);
      WSH_DEBUG_SV.log(l_module_name, 'p_process_mode',p_process_mode);
      WSH_DEBUG_SV.log(l_module_name, 'p_api_version_number', p_api_version_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_customer_id', p_customer_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_ship_to_location_id', p_ship_to_location_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_transaction_type_id', p_transaction_type_id);
      WSH_DEBUG_SV.log(l_module_name, 'p_from_order_number', p_from_order_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_to_order_number', p_to_order_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_from_request_date', p_from_request_date);
      WSH_DEBUG_SV.log(l_module_name, 'p_to_request_date', p_to_request_date);
      WSH_DEBUG_SV.log(l_module_name, 'p_from_schedule_date', p_from_schedule_date);
      WSH_DEBUG_SV.log(l_module_name, 'p_to_schedule_date', p_to_schedule_date);
      WSH_DEBUG_SV.log(l_module_name, 'p_shipment_priority', p_shipment_priority);
      WSH_DEBUG_SV.log(l_module_name, 'p_include_internal_so', p_include_internal_so);
   END IF;
   --

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   -- Initialize Message List
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call (
              l_api_version_number,
              p_api_version_number,
              l_api_name,
              G_PKG_NAME )
   THEN
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   BEGIN
      select to_char(p_from_request_date, 'YYYY/MM/DD HH24:MI:SS'),
             to_char(p_to_request_date, 'YYYY/MM/DD HH24:MI:SS'),
             to_char(p_from_schedule_date, 'YYYY/MM/DD HH24:MI:SS'),
             to_char(p_to_schedule_date, 'YYYY/MM/DD HH24:MI:SS')
      into   l_from_request_date,
             l_to_request_date,
             l_from_schedule_date,
             l_to_schedule_date
      from dual;
   EXCEPTION
      WHEN OTHERS THEN
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error: Invalid date format', sqlerrm);
         END IF;
         --
         RAISE FND_API.G_EXC_ERROR;
   END;

   IF p_process_mode = 'ONLINE' THEN
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_SHIPMENT_BATCH_PKG.Create_Shipment_Batch', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_SHIPMENT_BATCH_PKG.Create_Shipment_Batch (
                p_organization_id      => p_organization_id,
                p_customer_id          => p_customer_id,
                p_ship_to_location_id  => p_ship_to_location_id,
                p_transaction_type_id  => p_transaction_type_id,
                p_from_order_number    => p_from_order_number,
                p_to_order_number      => p_to_order_number,
                p_from_request_date    => l_from_request_date,
                p_to_request_date      => l_to_request_date,
                p_from_schedule_date   => l_from_schedule_date,
                p_to_schedule_date     => l_to_schedule_date,
                p_shipment_priority    => p_shipment_priority,
                p_include_internal_so  => p_include_internal_so,
                x_return_status        => l_return_status );

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Return Status of WSH_SHIPMENT_BATCH_PKG.Create_Shipment_Batch', l_return_status);
      END IF;
      --
      IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         FND_MESSAGE.Set_Name('WSH', 'WSH_SUCCESS_PROCESS');
         WSH_UTIL_CORE.Add_Message(x_return_status);
      ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
         x_return_status := l_return_status;
      -- Raise error, if return status is not Success/Warning
      ELSE
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSIF p_process_mode = 'CONCURRENT' THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Calling FND_REQUEST.SUBMIT_REQUEST', WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      x_request_id :=  FND_REQUEST.SUBMIT_REQUEST(
                           application   =>  'WSH',
                           program       =>  'WSHSHBAT',
                           description   =>  'Create Shipment Batches',
                           start_time    =>   NULL,
                           sub_request   =>   FALSE,
                           argument1     =>   p_organization_id,
                           argument2     =>   p_customer_id,
                           argument3     =>   p_ship_to_location_id,
                           argument4     =>   p_transaction_type_id,
                           argument5     =>   p_from_order_number,
                           argument6     =>   p_to_order_number,
                           argument7     =>   l_from_request_date,
                           argument8     =>   l_to_request_date,
                           argument9     =>   l_from_schedule_date,
                           argument10    =>   l_to_schedule_date,
                           argument11    =>   p_shipment_priority,
                           argument12    =>   p_include_internal_so,
                           argument13    =>   p_log_level );

      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Request Id returned from FND_REQUEST.SUBMIT_REQUEST', x_request_id);
      END IF;
      --
      IF (nvl(x_request_id,0) <= 0) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         FND_MESSAGE.Set_Name('WSH', 'WSH_REQUEST_SUBMITTED');
         FND_MESSAGE.Set_Token('REQUEST_ID', x_request_id);
         WSH_UTIL_CORE.Add_Message(x_return_status);
      END IF;
   ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_OI_INVALID_ATTRIBUTE');
      FND_MESSAGE.Set_Token('ATTRIBUTE', 'PROCESS_MODE');
      WSH_UTIL_CORE.Add_Message(x_return_status);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'p_process_mode should be ONLINE/CONCURRENT');
      END IF;
      --
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
   END IF;

   --Set Msg. Count and Data from Msg. Stack
   FND_MSG_PUB.Count_And_Get(
                  p_count   => x_msg_count,
                  p_data    => x_msg_data,
                  p_encoded => fnd_api.g_false);

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      ROLLBACK;
      FND_MSG_PUB.Count_And_Get(
                  p_count   => x_msg_count,
                  p_data    => x_msg_data,
                  p_encoded => fnd_api.g_false);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured while creating Shipment Batch');
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      ROLLBACK;
      FND_MSG_PUB.Count_And_Get(
                  p_count   => x_msg_count,
                  p_data    => x_msg_data,
                  p_encoded => fnd_api.g_false);
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Create_Shipment_Batch;
--
--========================================================================
-- PROCEDURE : Cancel_Line         PUBLIC
--
-- PARAMETERS: p_api_version_number    version number of the API
--             p_init_msg_list         messages will be initialized if set as true
--             p_commit                commit Flag
--             p_document_number       document number
--             p_line_number           line number
--             p_cancel_quantity       quantity to unassign from Shipment batch
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Public API to unassign delivery line from a Shipment Batch.
--
--========================================================================

/*#
 * Unassing delivery line from Shipment Batch
 * @param p_api_version_number    version number of the API
 * @param p_init_msg_list         messages will be initialized if set as true
 * @param p_commit                commit flag
 * @param p_document_number       document number
 * @param p_line_number           line number
 * @param p_cancel_quantity       quantity to unassign from Shipment batch
 * @param x_return_status         return status of the API
 * @param x_msg_count             number of messages, if any
 * @param x_msg_data              message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Unassign Delivery Line From Shipment Batch
 */
PROCEDURE Cancel_Line(
          p_api_version_number   IN  NUMBER,
          p_init_msg_list        IN  VARCHAR2,
          p_commit               IN  VARCHAR2,
          p_document_number      IN  VARCHAR2,
          p_line_number          IN  VARCHAR2,
          p_cancel_quantity      IN  NUMBER,
          x_return_status        OUT NOCOPY    VARCHAR2,
          x_msg_count            OUT NOCOPY    NUMBER,
          x_msg_data             OUT NOCOPY    VARCHAR2 )
AS

   l_msg_count              NUMBER;
   l_return_status          VARCHAR2(1);
   l_msg_data               VARCHAR2(1000);

   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30):= 'Cancel_Line';

   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || l_api_name;
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name, 'p_commit', p_commit);
      WSH_DEBUG_SV.log(l_module_name, 'p_api_version_number', p_api_version_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_document_number', p_document_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_line_number', p_line_number);
      WSH_DEBUG_SV.log(l_module_name, 'p_cancel_quantity', p_cancel_quantity);
   END IF;
   --
   x_return_status     := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   -- Initialize Message List
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call (
              l_api_version_number,
              p_api_version_number,
              l_api_name,
              G_PKG_NAME )
   THEN
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_SHIPMENT_BATCH_PKG.Cancel_Line', WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_SHIPMENT_BATCH_PKG.Cancel_Line(
            p_document_number  =>  p_document_number ,
            p_line_number      =>  p_line_number     ,
            p_cancel_quantity   =>  p_cancel_quantity  ,
            x_return_status    =>  l_return_status   );

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status of WSH_SHIPMENT_BATCH_PKG.Cancel_Line', l_return_status);
   END IF;
   --

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      ROLLBACK;
      FND_MSG_PUB.Count_And_Get(
                  p_count   => x_msg_count,
                  p_data    => x_msg_data,
                  p_encoded => fnd_api.g_false);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured while cancelling delivery line');
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rolling back the transactions');
      END IF;
      --
      ROLLBACK;
      FND_MSG_PUB.Count_And_Get(
                  p_count   => x_msg_count,
                  p_data    => x_msg_data,
                  p_encoded => fnd_api.g_false);
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Cancel_Line;

END WSH_SHIPMENT_BATCH_PUB;

/
