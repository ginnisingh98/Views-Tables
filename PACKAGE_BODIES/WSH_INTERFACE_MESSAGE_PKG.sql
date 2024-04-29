--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE_MESSAGE_PKG" AS
/* $Header: WSHINMSB.pls 120.0.12010000.1 2009/03/26 06:00:08 brana noship $ */

/*==============================================================================
-- PROCEDURE:         lock_record
-- Purpose:           Locking records in wsh_del_details_interface and wsh_new_del_interface
-- Description:       This procedure  is called from Interface Message Correction Form
--                    for locking the record in table wsh_del_details_interface
--                    and wsh_new_del_interface
 * ==============================================================================*/

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INTERFACE_MESSAGE_PKG';
   --
PROCEDURE lock_record(
                      p_delivery_interface_id        IN NUMBER,
                      p_delivery_detail_interface_id IN NUMBER,
                      x_return_status                OUT NOCOPY VARCHAR2) is


 CURSOR l_lock_del_interface is
  SELECT 1
  FROM wsh_new_del_interface
  WHERE delivery_interface_id  = p_delivery_interface_id
  FOR UPDATE NOWAIT;


 CURSOR l_lock_del_details_interface is
  SELECT 1
  FROM wsh_del_details_interface
  WHERE delivery_detail_interface_id  = p_delivery_detail_interface_id
  FOR UPDATE NOWAIT;

 l_id       NUMBER :=0;
 l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_RECORD';
 RECORD_LOCKED          EXCEPTION;
 PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

BEGIN

 x_return_status := wsh_util_core.G_RET_STS_SUCCESS;
 l_debug_on := wsh_debug_interface.g_debug;
 --
 IF l_debug_on IS NULL THEN
    l_debug_on := wsh_debug_sv.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
  wsh_debug_sv.push(l_module_name);
 END IF;
 --
 IF p_delivery_interface_id IS NOT NULL THEN

    OPEN  l_lock_del_interface;
    FETCH l_lock_del_interface INTO l_id ;
    CLOSE l_lock_del_interface;

  ELSIF p_delivery_detail_interface_id IS NOT NULL THEN

  OPEN  l_lock_del_details_interface;
  FETCH l_lock_del_details_interface INTO l_id ;
  CLOSE l_lock_del_details_interface;

 END IF;
 --
 IF l_id = 0  THEN
   x_return_status := wsh_util_core.G_RET_STS_ERROR;
   fnd_message.set_name('FND', 'FND_RECORD_DELETED_ERROR');
    --
    IF p_delivery_interface_id IS NOT NULL THEN
      --
      IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,'Record does not exists for the Delivery Interface ID ',p_delivery_interface_id);
      END IF;
      --
     ELSIF p_delivery_detail_interface_id IS NOT NULL THEN
       --
       IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'Record does not exists for the Delivery Detail Interface ID',p_delivery_detail_interface_id);
       END IF;
       --
     END IF;
     --
     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,'Value of L_ID = ',l_id);
     END IF;
     --
 END IF;
 --
 IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name,'x_return_status  ',x_return_status);
    wsh_debug_sv.pop(l_module_name);
 END IF;
 --
EXCEPTION

   WHEN RECORD_LOCKED THEN
       fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
       x_return_status := wsh_util_core.G_RET_STS_UNEXP_ERROR;
       --
       IF l_debug_on THEN
         --
         IF p_delivery_interface_id IS NOT NULL THEN
          wsh_debug_sv.log(l_module_name,'Delivery Interface ID is locked by another user',p_delivery_interface_id);
         ELSIF p_delivery_detail_interface_id IS NOT NULL THEN
          wsh_debug_sv.log(l_module_name,'Delivery Detail Interface ID is Locked by another user',p_delivery_detail_interface_id);
         END IF;
         --
          wsh_debug_sv.log(l_module_name,'SQLERRM = ', SQLERRM );
          wsh_debug_sv.log(l_module_name,'x_return_status  ',x_return_status);
          wsh_debug_sv.pop(l_module_name);
       END IF;
     --
      WHEN OTHERS THEN
       x_return_status := wsh_util_core.g_ret_sts_error;
       --
       IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'SQLERRM : ',sqlerrm);
          wsh_debug_sv.log(l_module_name,'x_return_status : ',x_return_status);
          wsh_debug_sv.pop(l_module_name);
       END IF;
       --

 End lock_record;

END wsh_interface_message_pkg;

/
