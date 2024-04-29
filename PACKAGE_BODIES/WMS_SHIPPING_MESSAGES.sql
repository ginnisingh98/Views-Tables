--------------------------------------------------------
--  DDL for Package Body WMS_SHIPPING_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SHIPPING_MESSAGES" AS
/* $Header: WMSSHPMB.pls 120.0.12010000.2 2008/11/28 06:04:56 abasheer ship $ */

G_Debug BOOLEAN := TRUE;

PROCEDURE DEBUG(p_message	IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   if( G_Debug = TRUE ) then
      inv_mobile_helper_functions.tracelog
	(p_err_msg => p_message,
	 p_module => 'WMS_SHIPPING_MESSAGES',
	 p_level => 9);
   end if;
END;

PROCEDURE PROCESS_SHIPPING_WARNING_MSGS(x_return_status  OUT  NOCOPY VARCHAR2,
                                        x_msg_count      OUT  NOCOPY NUMBER,
                                        x_msg_data       OUT  NOCOPY VARCHAR2,
                                        p_commit         IN  VARCHAR2 := FND_API.g_false,
                                        p_api_version    IN  VARCHAR2 := 1.0,
                                        x_shipping_msg_tab  IN OUT  NOCOPY WSH_INTEGRATION.MSG_TABLE ) IS
l_api_version        CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30) := 'PROCESS_SHIPPING_WARNING_MSGS';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Initialize return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF NOT FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (x_shipping_msg_tab.COUNT <> 0) THEN
       FOR i IN 1..x_shipping_msg_tab.COUNT
           LOOP
               if (x_shipping_msg_tab(i).message_name = 'WSH_DEL_DETAILS_INV_CONTROLS'
                or x_shipping_msg_tab(i).message_name = 'WSH_DET_CREDIT_HOLD_ERROR'
           --     or x_shipping_msg_tab(i).message_name = 'WSH_DEL_SHIP_SET_INCOMPLETE'
                or x_shipping_msg_tab(i).message_name = 'WSH_DEL_SMC_INCOMPLETE'
                or x_shipping_msg_tab(i).message_name = 'WSH_INVALID_CATCHWEIGHT'
                or x_shipping_msg_tab(i).message_name = 'WSH_SHIP_LINE_HOLD_ERROR'
                or x_shipping_msg_tab(i).message_name = 'WSH_HEADER_HOLD_ERROR'
		or x_shipping_msg_tab(i).message_name = 'WSH_DETAILS_MATERIAL_STATUS' ) then
		  x_shipping_msg_tab(i).message_type  := 'E';
               end if;

	       IF x_shipping_msg_tab(i).message_name = 'WSH_DEL_SHIP_SET_INCOMPLETE' THEN
		  IF l_debug = 1 THEN
		     debug('WMS ship set global variable: ' || wms_shipping_transaction_pub.g_allow_ship_set_break);
		  END IF;
		  IF wms_shipping_transaction_pub.g_allow_ship_set_break = 'N' THEN
		     IF l_debug = 1 THEN
			debug('Do not allow ship set to break');
		     END IF;
		     x_shipping_msg_tab(i).message_type  := 'E';
		   ELSE
		     IF l_debug = 1 THEN
			debug('Leave ship set warning message as warning');
		     END IF;
		  END IF;
	       END IF;
	   END LOOP;
   END IF;
    -- Standard check of p_commit.
   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get
        ( p_encoded     => FND_API.G_FALSE,
          p_count       => x_msg_count,
          p_data        => x_msg_data
          );
      IF (l_debug = 1) THEN
         DEBUG('Error ! SQL Code : '||sqlcode);
      END IF;

   WHEN fnd_api.g_exc_unexpected_error  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get
        ( p_encoded     => FND_API.G_FALSE,
          p_count       => x_msg_count,
          p_data        => x_msg_data
          );
      IF (l_debug = 1) THEN
         DEBUG('Unknown Error ! SQL Code : '||sqlcode);
      END IF;
   WHEN others  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg
           (  'WMS_SHIPPING_MESSAGES',
              'PROCESS_SHIPPING_WARNING_MSGS'
              );
      END IF;
      fnd_msg_pub.count_and_get
        ( p_encoded     => FND_API.G_FALSE,
          p_count       => x_msg_count,
          p_data        => x_msg_data
          );
      IF (l_debug = 1) THEN
         DEBUG('Other Error ! SQL Code : '||sqlcode);
      END IF;
END PROCESS_SHIPPING_WARNING_MSGS;


END WMS_SHIPPING_MESSAGES;

/
