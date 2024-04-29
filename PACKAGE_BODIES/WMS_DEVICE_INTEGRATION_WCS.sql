--------------------------------------------------------
--  DDL for Package Body WMS_DEVICE_INTEGRATION_WCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEVICE_INTEGRATION_WCS" AS
/* $Header: WMSDVPBB.pls 120.0 2005/05/24 19:11:37 appldev noship $ */
   PROCEDURE sync_device_request (
      p_request_id      IN          NUMBER,
      p_device_id       IN          NUMBER,
      p_resubmit_flag   IN          VARCHAR2,
      x_status_code     OUT NOCOPY  VARCHAR2,
      x_status_msg      OUT NOCOPY  VARCHAR2,
      x_device_status   OUT NOCOPY  VARCHAR2
   )
   IS
   BEGIN
      WMS_CAROUSEL_INTEGRATION_PKG.sync_device_request (p_request_id,
                                                        p_device_id,
                                                        p_resubmit_flag,
                                                        x_status_code,
                                                        x_status_msg,
                                                        x_device_status
                                                       );
   END;

--
--
   PROCEDURE update_request (
      p_request_id    IN   NUMBER,
      p_device_id     IN   NUMBER := NULL,
      p_status_code   IN   VARCHAR2,
      p_status_msg    IN   VARCHAR2 := NULL
   )
   IS
   BEGIN
      UPDATE wms_device_requests_hist
         SET status_code = p_status_code,
             status_msg = p_status_msg
       WHERE request_id = p_request_id
         AND device_id = NVL (p_device_id, device_id);
   END;

--
--
   PROCEDURE sync_device (
      p_organization_id   IN           NUMBER,
      p_device_id         IN           NUMBER,
      p_employee_id       IN           NUMBER,
      p_sign_on_flag      IN           VARCHAR2,
      x_status_code       OUT NOCOPY   VARCHAR2,
      x_device_status     OUT NOCOPY   VARCHAR2
   )
   IS
   BEGIN
      WMS_CAROUSEL_INTEGRATION_PKG.sync_device (p_organization_id,
                                                p_device_id,
                                                p_employee_id,
                                                p_sign_on_flag,
                                                x_status_code,
                                                x_device_status
                                               );
   END;

   PROCEDURE signoff_msg_to_out_pipe (
      p_device_id          IN           VARCHAR2,
      p_message            IN           VARCHAR2,
      x_pipe_name          OUT NOCOPY   VARCHAR2,
      x_message_code       OUT NOCOPY   NUMBER,
      x_return_status      OUT NOCOPY   VARCHAR2,
      x_msg_count          OUT NOCOPY   NUMBER,
      x_msg_data           OUT NOCOPY   VARCHAR2
   )
   IS
      l_pipe_created NUMBER; --0 no error
      l_message_sent NUMBER;
      /*
      0 - no error
      1 - pipe timed out
      3 - interrupt occurred
      ORA-23322 - insufficient privileges to write to the pipe
      */
      l_writing_pipe    VARCHAR2(40);
      v_addr VARCHAR2(64);
   BEGIN
      x_return_status    := fnd_api.g_ret_sts_success;
         -- Get pipe NAME
         l_writing_pipe :=
            NVL (wms_carousel_integration_pvt.get_config_parameter
                                      (p_name      => 'PIPE_NAME',
                                       p_sequence_id => p_device_id),
                 'PIPE_NAME_' || p_device_id
                );
         l_writing_pipe := 'OUT_' || l_writing_pipe;

         -- Get task addr
         v_addr :=
            wms_carousel_integration_pvt.get_config_parameter
                                 (p_name                => 'TASK_ADDR',
                                  p_device_type_id      => wms_carousel_integration_pvt.get_device_type_id(p_device_id)
                                 );

      dbms_pipe.pack_message(NVL (v_addr, '1'));
      dbms_pipe.pack_message(p_message);

      l_message_sent := dbms_pipe.send_message(l_writing_pipe);
      x_pipe_name := l_writing_pipe;
      x_message_code := l_message_sent;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.G_RET_STS_ERROR;
         x_msg_data := SQLERRM;
   END signoff_msg_to_out_pipe;

END WMS_DEVICE_INTEGRATION_WCS;

/
