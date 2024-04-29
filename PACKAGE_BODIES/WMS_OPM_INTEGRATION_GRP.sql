--------------------------------------------------------
--  DDL for Package Body WMS_OPM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OPM_INTEGRATION_GRP" AS
/* $Header: WMSOPMB.pls 120.4 2005/10/07 05:35:57 simran noship $ */

   --
   --
   PROCEDURE LOG (p_device_id IN NUMBER, p_data IN VARCHAR2);

   PROCEDURE PROCESS_RESPONSE
                   (p_device_id           IN  NUMBER,
                    p_request_id          IN  NUMBER,
                    p_param_values_record IN  WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE,
                    x_return_status       OUT NOCOPY VARCHAR2,
                    x_msg_count           OUT NOCOPY NUMBER,
                    x_msg_data            OUT NOCOPY VARCHAR2)
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_api_version NUMBER := 1;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF l_debug >= 1 THEN
         LOG (p_device_id, 'Reached WMS_OPM_INTEGRATION_GRP.PROCESS_RESPONSE for p_request_id='
              ||p_request_id);
      END IF;

      --This is the OPM Open API to be called
      --GMO does not have a source control area yet
      --Will uncomment the API call once they are done
      GMO_WMS_INTEGRATION_GRP.PROCESS_DEVICE_RESPONSE
         (P_API_VERSION         => l_api_version,
          X_RETURN_STATUS       => x_return_status,
          X_MSG_COUNT           => x_msg_count,
          X_MSG_DATA            => x_msg_data,
          P_REQUEST_ID          => p_request_id,
          P_DEVICE_ID           => p_device_id,
          P_PARAM_VALUES_RECORD => p_param_values_record
         );

      IF (l_debug = 1) THEN
         log
         (p_device_id,   'Done calling GMO_WMS_INTEGRATION_GRP.process_response');
         log
         (p_device_id,   'x_return_status='
          ||x_return_status
          ||', x_msg_count='
          ||x_msg_count
          ||', x_msg_data='
          ||x_msg_data);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 1) THEN
            log
            (p_device_id,   'Unexpected error in WMS_OPM_INTEGRATION_GRP.PROCESS_RESPONSE : '||SQLERRM);
         END IF;
   END PROCESS_RESPONSE;

   --
   --
   PROCEDURE LOG (p_device_id in number, p_data IN VARCHAR2)
   IS
      cnt   NUMBER;
      --PRAGMA AUTONOMOUS_TRANSACTION;
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

END WMS_OPM_INTEGRATION_GRP;


/
