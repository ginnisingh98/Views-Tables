--------------------------------------------------------
--  DDL for Package Body WMS_CAROUSEL_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CAROUSEL_INTEGRATION_PVT" AS
/* $Header: WMSCSPVB.pls 120.22 2005/12/06 07:06:53 simran noship $ */

--
-- Private Procedure to slow down the application if the hardware is not able to keep pace
-- The duration of the wait will be controlled by a configurable paramter 'DIRECTIVE_PAUSE_DELAY'
--
   PROCEDURE pause_directive(
      p_device_id          IN NUMBER,
      p_delay_in_seconds   IN NUMBER
   );

   FUNCTION get_config_parameter (
      p_name             IN   VARCHAR2,
      p_device_type_id   IN   NUMBER DEFAULT NULL,
      p_business_event_id  IN   NUMBER DEFAULT NULL,
      p_sequence_id      IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      -- Cursor for selecting the parameter value
      CURSOR c_config_parameter (
         p_device_type_id   IN   NUMBER,
         p_business_event_id  IN   NUMBER,
         p_sequence_id      IN   NUMBER,
         p_name             IN   VARCHAR2
      )
      IS
         SELECT   CONFIG_VALUE
             FROM wms_carousel_configuration
            WHERE CONFIG_NAME = p_name
              AND NVL (NVL (device_type_id, p_device_type_id), 0) = NVL (p_device_type_id, 0)
              AND NVL (NVL (business_event_id, p_business_event_id), 0) = NVL (p_business_event_id, 0)
              AND NVL (NVL (sequence_id, p_sequence_id), 0) = NVL (p_sequence_id, 0)
              AND active_ind = 'Y'
         ORDER BY device_type_id, business_event_id, sequence_id;

      v_value   VARCHAR2 (4000) := NULL;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      -- Get it out of the configuration table
      OPEN c_config_parameter (p_device_type_id,
                               p_business_event_id,
                               p_sequence_id,
                               p_name
                              );

      FETCH c_config_parameter
       INTO v_value;

      IF (C_CONFIG_PARAMETER%NOTFOUND) THEN
	IF (l_debug > 0) THEN
          LOG (NULL, 'Warning: Configuration not found for (' || P_NAME || ')');
	END IF;
      END IF;

      CLOSE c_config_parameter;

      RETURN v_value;
   END;


   FUNCTION GET_CONFIG_PARAMETER_INT (
      P_NAME             IN   VARCHAR2,
      P_DEVICE_TYPE_ID   IN   NUMBER DEFAULT NULL,
      P_BUSINESS_EVENT_ID  IN   NUMBER DEFAULT NULL,
      P_SEQUENCE_ID      IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      -- CURSOR FOR SELECTING THE PARAMETER VALUE
      CURSOR C_CONFIG_PARAMETER (
         P_DEVICE_TYPE_ID   IN   NUMBER,
         P_BUSINESS_EVENT_ID  IN   NUMBER,
         P_SEQUENCE_ID      IN   NUMBER,
         P_NAME             IN   VARCHAR2
      )
      IS
         SELECT   CONFIG_VALUE
             FROM WMS_CAROUSEL_CONFIGURATION
            WHERE CONFIG_NAME = P_NAME
              AND DEVICE_TYPE_ID = P_DEVICE_TYPE_ID
              AND BUSINESS_EVENT_ID = P_BUSINESS_EVENT_ID
              AND SEQUENCE_ID = P_SEQUENCE_ID
              AND ACTIVE_IND = 'Y'
         ORDER BY DEVICE_TYPE_ID, BUSINESS_EVENT_ID, SEQUENCE_ID;

      V_VALUE   VARCHAR2 (4000) := NULL;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      -- GET IT OUT OF THE CONFIGURATION TABLE
      OPEN C_CONFIG_PARAMETER (P_DEVICE_TYPE_ID,
                               P_BUSINESS_EVENT_ID,
                               P_SEQUENCE_ID,
                               P_NAME
                              );

      FETCH C_CONFIG_PARAMETER
       INTO V_VALUE;

      IF (C_CONFIG_PARAMETER%NOTFOUND) THEN
	IF (l_debug > 0) THEN
          LOG (NULL, 'Warning: Configuration not found for (' || P_NAME || ')');
	END IF;
      END IF;
      CLOSE C_CONFIG_PARAMETER;

      RETURN V_VALUE;
   END;

   --
   --
   PROCEDURE process_request (
      p_request_id      IN              NUMBER,
      x_status_code     OUT NOCOPY      VARCHAR2,
      x_status_msg      OUT NOCOPY      VARCHAR2,
      x_device_status   OUT NOCOPY      VARCHAR2
   )
   IS
      v_task_group         VARCHAR2 (128);
      v_group_skip         BOOLEAN;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      COMMIT;
      -- Process request tasks
      v_group_skip := FALSE;

      FOR v_task IN c_request_tasks (p_request_id)
      LOOP
	IF (l_debug > 0) THEN
          LOG (v_task.device_id, 'Processing request: request_id=' || p_request_id);
	END IF;
        BEGIN
         -- Skip ?
         -- because the task is a member of a task group already processed
         IF NOT v_group_skip
         THEN
            -- Is it a task complete ?
            IF v_task.business_event_id = WMS_DEVICE_INTEGRATION_PVT.WMS_BE_TASK_COMPLETE
            THEN
               complete_task (v_task.relation_id, v_task.device_id, null);
            -- Is it a task skip ?
            ELSIF v_task.business_event_id = WMS_DEVICE_INTEGRATION_PVT.WMS_BE_TASK_SKIP
            THEN
               skip_task (v_task.relation_id, v_task.device_id, null);
            -- Is it a task cancel ?
            ELSIF v_task.business_event_id = WMS_DEVICE_INTEGRATION_PVT.WMS_BE_TASK_CANCEL
            THEN
               cancel_task (v_task.relation_id, v_task.device_id, null);
            END IF;
               -- Add task directives to the directive queue
               add_task_directives (p_task => v_task);
               -- Get TASK_GROUP parameter
               v_task_group :=
                  NVL
                     (get_config_parameter
                                    (p_name                => 'TASK_GROUP',
                                     p_device_type_id      => v_task.device_type_id,
                                     p_business_event_id      => v_task.business_event_id
                                    ),
                      'F'
                     );

               -- Are the tasks groupped ?
               IF UPPER (SUBSTR (v_task_group, 1, 1)) = 'T'
               THEN
                  -- Skip the other tasks of the request
                  v_group_skip := TRUE;
               END IF;

         END IF;
         EXCEPTION WHEN OTHERS THEN
	    IF (l_debug > 0) THEN
              LOG (v_task.device_id, 'Error Processing request: request_id=' || p_request_id || ', Error=' || sqlerrm);
	    END IF;
         END;
      END LOOP;

      -- Process the directive queue for the new tasks
      process_directive_queue;
      -- Status
      x_status_code := 'S';
      x_status_msg := 'S';
      x_device_status := 'S';
   END process_request;
   --
   -- Bug# 4666748
   PROCEDURE response_event_handler (
      p_device_id          IN           VARCHAR2,
      p_message            IN           VARCHAR2,
      x_message_code       OUT NOCOPY   NUMBER,
      x_return_status      OUT NOCOPY   VARCHAR2,
      x_msg_count          OUT NOCOPY   NUMBER,
      x_msg_data           OUT NOCOPY   VARCHAR2
   )
   IS
      v_response       VARCHAR2 (4000);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
        if l_debug > 0 then
           LOG(p_device_id, 'Reached response_event_handler with p_message='||p_message);
        end if;
        v_response := p_message;

	-- Process the response
	process_response (
		      p_device_id     => p_device_id,
		      p_response      => v_response
		     );
	-- Process the directive queue for any new directives to send
	process_directive_queue;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF (l_debug > 0) THEN
           LOG (p_device_id,'Error in receive_listener: ' || SQLERRM);
         END IF;
   END response_event_handler;
   -- Bug# 4666748
   -- API without the pipe name
   PROCEDURE process_response (
      p_device_id  IN   NUMBER,
      p_response   IN   VARCHAR2
   )
   IS
      -- Cursor for ERROR/FULL directives
      CURSOR c_error_directive (
         p_device_id       IN   NUMBER,
         p_response   IN   VARCHAR2
      )
      IS
         SELECT     *
               FROM wms_carousel_directive_queue
              WHERE status = 'C'
                AND NVL (NVL (device_id, p_device_id), -1) = NVL (p_device_id, -1)
                AND NVL (p_response, 'null') LIKE NVL (response, 'null')
         FOR UPDATE;

      -- Cursor for corresponding directive
      CURSOR c_corresponding_directive (
         p_device_id       IN   NUMBER,
         p_response   IN   VARCHAR2
      )
      IS
         SELECT     *
               FROM wms_carousel_directive_queue
              WHERE status = 'C'
                AND NVL (NVL (device_id, p_device_id), -1) = NVL (p_device_id, -1)
                AND NVL (p_response, 'null') LIKE NVL (response, 'null')
         FOR UPDATE;

      v_response   VARCHAR2 (4000);
      v_replace_response   VARCHAR2 (4000);
      v_stx   VARCHAR2 (3);
      v_etx   VARCHAR2 (3);
      l_pos   NUMBER;
      l_msg_template_id NUMBER;
      l_return_status   VARCHAR2(10);
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(4000);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_directive_cnt number := 0;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      v_response := p_response;
      IF (l_debug > 0) THEN
        LOG ( p_device_id,  'Reached process_response with p_response='||p_response);
      END IF;

      IF ((INSTR(p_response, 'ERROR') > 0) OR (INSTR(p_response, 'FULL') > 0)) THEN
         IF (l_debug > 0) THEN
           LOG ( p_device_id,  'Found an ERROR or FULL in the response '||p_response);
         END IF;

         v_replace_response := v_response;
         --v_replace_response := replace(v_replace_response,'ERROR','DONE');
         v_replace_response := replace(v_replace_response,'ERROR','DONE0');
         v_replace_response := replace(v_replace_response,'FULL','DONE');

         -- Mark the status of the corresponding directive as failure
         FOR v_error_directive IN c_error_directive   (
                                                       p_device_id     => p_device_id,
                                                       p_response      => v_replace_response
                                                      )
         LOOP
            BEGIN
               IF (l_debug > 0) THEN
                 LOG (v_error_directive.device_id,  'Marking directive as failure, id='
                    || v_error_directive.CAROUSEL_DIRECTIVE_QUEUE_ID
                    || ', request_id='
                    || v_error_directive.request_id
                    || ', task_id='
                    || v_error_directive.task_id
                    || ', directive='
                    || v_error_directive.directive
                    || ', request='
                    || v_error_directive.request
                    || ', zone='
                    || v_error_directive.subinventory
                    || ', attempt='
                    || (NVL (v_error_directive.attempts, 0) + 1)
                    || ', send_pipe='
                    || v_error_directive.send_pipe
                    || ', v_response='
                    || v_response
                    || ', v_replace_response='
                    || v_replace_response
                   );
               END IF;
               UPDATE wms_carousel_directive_queue
                  SET status = 'F'
                WHERE CURRENT OF c_error_directive;

               IF l_debug > 0 THEN
                  LOG (v_error_directive.device_id,  'After updating to Failure, CAROUSEL_DIRECTIVE_QUEUE_ID='
                       || v_error_directive.CAROUSEL_DIRECTIVE_QUEUE_ID
                       || ', request_id='
                       || v_error_directive.request_id
                       || ', task_id='
                       || v_error_directive.task_id
                       || ', directive='
                       || v_error_directive.directive
                       || ', v_response ='
                       || v_response
                       || ', zone='
                       || v_error_directive.subinventory
                       || ', send_pipe='
                       || v_error_directive.send_pipe
                      );
               END IF;

               --
               IF (INSTR(p_response, 'ERROR') > 0) THEN
                  --Mark the dependent directives as 'Cancelled'
                  UPDATE  WMS_CAROUSEL_DIRECTIVE_QUEUE Q
                     SET  STATUS = 'X', LAST_UPDATE_DATE = SYSDATE
                   WHERE  REQUEST_ID  = NVL(v_error_directive.REQUEST_ID,0)
                     AND  SEQUENCE_ID > NVL(v_error_directive.SEQUENCE_ID,SEQUENCE_ID);
               ELSIF (INSTR(p_response, 'FULL') > 0) THEN
                  --Mark the dependent directives as 'Pending' for PAUSE processing
                  UPDATE  WMS_CAROUSEL_DIRECTIVE_QUEUE Q
                     SET  STATUS = 'P', LAST_UPDATE_DATE = SYSDATE
                   WHERE  REQUEST_ID  = NVL(v_error_directive.REQUEST_ID,0)
                     AND  SEQUENCE_ID > NVL(v_error_directive.SEQUENCE_ID,SEQUENCE_ID);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                 IF (l_debug > 0) THEN
                  LOG (p_device_id, 'Error Processing response: '
                       || ', v_replace_response='
                       || v_replace_response
                       || ', v_response'
                       || v_response
                       || ', Error='
                       || sqlerrm);
                 END IF;
            END;
         END LOOP;

         COMMIT;
         RETURN;
      END IF;

      IF (l_debug > 0) THEN
        LOG ( p_device_id,  'There was no ERROR/FULL in the response:'
              ||p_response);
      END IF;

      --Resolve the message template id from the device id
      BEGIN
            SELECT message_template_id
              INTO l_msg_template_id
              FROM wms_devices_b
             WHERE device_id = p_device_id;
            IF l_debug > 0 THEN
                LOG(p_device_id, 'Message template ID for device ID '
                    ||p_device_id
                    ||' is '
                    ||l_msg_template_id);
            END IF;
      EXCEPTION
             WHEN NO_DATA_FOUND THEN
                IF l_debug > 0 THEN
                   LOG(p_device_id, 'No message template defined for device id '
                       ||p_device_id
                       ||'. '
                       ||SQLERRM);
                END IF;
             WHEN OTHERS THEN
                IF l_debug > 0 THEN
                   LOG(p_device_id, SQLERRM);
                END IF;
      END;


      -- Mark the status of the corresponding directive as success
      FOR v_directive IN c_corresponding_directive (
                                                    p_device_id     => p_device_id,
                                                    p_response      => v_response
                                                   )
      LOOP
         l_directive_cnt := l_directive_cnt + 1;
         IF l_debug > 0 THEN
            LOG(v_directive.device_id, 'Calling parse Device Response with params device_id='
                ||v_directive.device_id
                ||', p_request_id='
                ||v_directive.request_id
                ||', msg_template_id='
                ||l_msg_template_id
                ||', response='
                ||v_directive.response);
         END IF;
         parse_device_response (
            p_device_id      => v_directive.device_id,
            p_request_id     => v_directive.request_id,
            p_msg            => v_directive.response,
            p_template_id    => l_msg_template_id,
            x_return_status  => l_return_status,
            x_msg_count      => l_msg_count,
            x_msg_data       => l_msg_data
         );

        IF (l_debug > 0) THEN
          LOG(v_directive.device_id, 'After calling parse_device_response. l_return_status is '||l_return_status);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug > 0) THEN
            LOG(v_directive.device_id, 'Error calling parse_device_response. '||SQLERRM);
          END IF;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug > 0) THEN
            LOG(v_directive.device_id, 'Error calling parse_device_response. '||SQLERRM);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

         IF (l_debug > 0) THEN
           LOG (v_directive.device_id,  'Marking directive as success, id='
              || v_directive.CAROUSEL_DIRECTIVE_QUEUE_ID
              || ', request_id='
              || v_directive.request_id
              || ', task_id='
              || v_directive.task_id
              || ', directive='
              || v_directive.directive
              || ', request='
              || v_directive.request
              || ', zone='
              || v_directive.subinventory
              || ', attempt='
              || (NVL (v_directive.attempts, 0) + 1)
              || ', send_pipe='
              || v_directive.send_pipe
             );
         END IF;
         UPDATE wms_carousel_directive_queue
            SET status = 'S'
          WHERE CURRENT OF c_corresponding_directive;
      END LOOP;

      -- If no corresponding directives were found, we still need to process the response
      IF l_directive_cnt = 0 THEN
         IF l_debug > 0 THEN
            LOG(v_directive.device_id, 'No matching directives. Calling parse Dev Resp with params dev_id='
                ||p_device_id
                ||', msg_template_id='
                ||l_msg_template_id
                ||', v_response='
                ||v_response
                ||', p_response='
                ||p_response);
         END IF;

         parse_device_response (
            p_device_id      => p_device_id,
            p_request_id     => null,
            p_msg            => v_response,
            p_template_id    => l_msg_template_id,
            x_return_status  => l_return_status,
            x_msg_count      => l_msg_count,
            x_msg_data       => l_msg_data
         );

      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug > 0) THEN
         LOG (p_device_id, '*Error in process_response: '
              || SQLERRM);
        END IF;
   END process_response;
   --
   --
   PROCEDURE add_task_directives (p_task IN c_request_tasks%ROWTYPE)
   IS
      -- Cursor for sequence id's
      CURSOR c_sequence_ids (p_device_type_id IN NUMBER, P_BUSINESS_EVENT_ID IN NUMBER)
      IS
         SELECT sequence_id, config_value
                    FROM wms_carousel_configuration
                   WHERE CONFIG_NAME = 'DIRECTIVE'
                     AND device_type_id = p_device_type_id
                     AND BUSINESS_EVENT_ID = P_BUSINESS_EVENT_ID
                     AND active_ind = 'Y'
                ORDER BY sequence_id;

      v_directive        wms_carousel_directive_queue%ROWTYPE;
      v_dir_dep_seg_id   VARCHAR2 (64)                          := NULL;
      v_dir_dep_seq_id   NUMBER                                 := NULL;
      v_query            VARCHAR2 (1024);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_directive_count NUMBER := 0;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF (l_debug > 0) THEN
      LOG (p_task.device_id,   'Adding task to directive queue: request_id='
           || p_task.request_id
           || ', task_id='
           || p_task.task_id
           || ', device_type_id='
           || p_task.device_type_id
           || ', device_id='
           || p_task.device_id
           || ', BUSINESS_EVENT_ID='
           || p_task.BUSINESS_EVENT_ID
           || ', sequence_id='
           || p_task.sequence_id
           || ', Sub='
           || p_task.SUBINVENTORY_CODE
           || ', Loc='
           || p_task.LOCATOR
           || ', quantity='
           || p_task.quantity
          );
      END IF;
      -- Get task zone
      v_query :=
         get_config_parameter (p_name                => 'TASK_ZONE',
                               p_device_type_id      => p_task.device_type_id,
                               p_business_event_id      => p_task.business_event_id
                              );
      build_directive_string                       -- We can use this function
                                                 (p_task        => p_task,
                                                  p_query       => v_query,
                                                  p_result      => v_directive.SUBINVENTORY
                                                 );
      -- Get task addr
      v_query :=
         get_config_parameter (p_name                => 'TASK_ADDR',
                               p_device_type_id      => p_task.device_type_id,
                               p_business_event_id      => p_task.business_event_id
                              );
      build_directive_string                       -- We can use this function
                                                 (p_task        => p_task,
                                                  p_query       => v_query,
                                                  p_result      => v_directive.addr
                                                 );
      v_directive.addr := NVL (v_directive.addr, '1');
      -- Assign segments
      v_directive.segment1 := p_task.segment1;
      v_directive.segment2 := p_task.segment2;
      v_directive.segment3 := p_task.segment3;
      v_directive.segment4 := p_task.segment4;
      v_directive.segment5 := p_task.segment5;
      v_directive.segment6 := p_task.segment6;
      v_directive.segment7 := p_task.segment7;
      v_directive.segment8 := p_task.segment8;
      v_directive.segment9 := p_task.segment9;
      v_directive.segment10 := p_task.segment10;
      -- Loop for directives in the configuration table
      v_directive.sequence_id := 0;
      v_directive.device_id := p_task.device_id;
      v_directive.subinventory := p_task.subinventory_code;
      v_directive.device_type_id := p_task.device_type_id;
      v_directive.business_event_id := p_task.business_event_id;

      FOR v_seq_id IN c_sequence_ids (v_directive.device_type_id,
                                      v_directive.business_event_id
                                     )
      LOOP
	 l_directive_count := l_directive_count + 1;
         v_directive.sequence_id := v_seq_id.sequence_id;
         -- Get next directive

         v_directive.directive := v_seq_id.config_value;

         /*
         v_directive.directive :=
            get_config_parameter (p_name                => 'DIRECTIVE',
                                  p_device_type_id      => p_task.device_type_id,
                                  p_zone                => v_directive.subinventory,
                                  p_sequence_id         => v_directive.sequence_id
                                 );
         */

         -- Get directive configuration parameters
         get_directive_config (p_task                => p_task,
                               p_directive           => v_directive,
                               p_dir_dep_seg_id      => v_dir_dep_seg_id,
                               p_dir_dep_seq_id      => v_dir_dep_seq_id
                              );
         -- Add the directive to the queue
         add_directive_to_queue (p_task                => p_task,
                                 p_directive           => v_directive,
                                 p_dir_dep_seg_id      => v_dir_dep_seg_id,
                                 p_dir_dep_seq_id      => v_dir_dep_seq_id
                                );
      END LOOP;
      IF (l_debug > 0 AND l_directive_count = 0) THEN
        LOG (p_task.device_id, 'Warning: No directives defined for Device Type ID=' || v_directive.device_type_id || ', Buss Event ID='
           || v_directive.business_event_id);
      END IF;
      COMMIT;
   END;

   --
   --
   PROCEDURE get_directive_config (
      p_task             IN              wms_device_requests_wcsv%ROWTYPE,
      p_directive        IN OUT NOCOPY   wms_carousel_directive_queue%ROWTYPE,
      p_dir_dep_seg_id   OUT NOCOPY      VARCHAR2,
      p_dir_dep_seq_id   OUT NOCOPY      NUMBER
   )
   IS
    v_pipe varchar2(40);
   BEGIN
      -- Get directive dependency segment id
      p_dir_dep_seg_id :=
         get_config_parameter_int (p_name                => 'DIRECTIVE_DEPENDENCY_SEG_ID',
                               p_device_type_id      => p_task.device_type_id,
                               p_business_event_id   => p_task.business_event_id,
                               p_sequence_id         => p_directive.sequence_id
                              );
      -- Get directive dependency sequence id
      p_dir_dep_seq_id :=
         get_config_parameter_int (p_name                => 'DIRECTIVE_DEPENDENCY_SEQ_ID',
                               p_device_type_id      => p_task.device_type_id,
                               p_business_event_id   => p_task.business_event_id,
                               p_sequence_id         => p_directive.sequence_id
                              );
      -- Get directive request query
      p_directive.request :=
         get_config_parameter_int (p_name                => 'DIRECTIVE_REQUEST_QUERY',
                               p_device_type_id      => p_task.device_type_id,
                               p_business_event_id   => p_task.business_event_id,
                               p_sequence_id         => p_directive.sequence_id
                              );
      -- Get directive response query
      p_directive.response :=
         get_config_parameter_int (p_name                => 'DIRECTIVE_RESPONSE_QUERY',
                               p_device_type_id      => p_task.device_type_id,
                               p_business_event_id   => p_task.business_event_id,
                               p_sequence_id         => p_directive.sequence_id
                              );
      -- Get directive response timeout
      p_directive.response_timeout :=
         NVL
            (get_config_parameter_int (p_name                => 'DIRECTIVE_RESPONSE_TIMEOUT',
                                   p_device_type_id      => p_task.device_type_id,
                                   p_business_event_id   => p_task.business_event_id,
                                   p_sequence_id         => p_directive.sequence_id
                                  ),
             20
            );
      -- Get directive attempts
      p_directive.max_attempts :=
         NVL
            (get_config_parameter_int (p_name                => 'DIRECTIVE_MAX_ATTEMPTS',
                                   p_device_type_id      => p_task.device_type_id,
                                   p_business_event_id   => p_task.business_event_id,
                                   p_sequence_id         => p_directive.sequence_id
                                  ),
             3
            );

--Bug# 4311016
      v_pipe :=
         NVL (get_config_parameter (p_name      => 'DIRECTIVE_PIPE_NAME',
                                    p_device_type_id      => p_task.device_type_id,
                                    p_business_event_id   => p_task.business_event_id,
                                    p_sequence_id         => p_directive.sequence_id),
                      NVL (get_config_parameter (p_name        => 'PIPE_NAME',
	                                          p_sequence_id => p_task.device_id ),
		           p_task.device_id )
	      );

      p_directive.send_pipe := 'OUT_' || v_pipe;
      p_directive.receive_pipe := 'IN_' || v_pipe;

--Bug# 4311016
 -- This allows for the directive_queue table to have a different Pipe_Name and Device_id in sequence.
 -- 'add_directive_to_queue' uses the device_id from the WDR record structure to insert into the queue table
 -- 'receive_pipe_listener' calls the 'process_response' procedure with the related device_id of the pipe
 -- which will find the current record in the queue table.

      p_directive.device_id := NVL (get_config_parameter (
                                      p_name      => 'DIRECTIVE_DEVICE_ID',
                                      p_device_type_id      => p_task.device_type_id,
                                      p_business_event_id   => p_task.business_event_id,
                                      p_sequence_id         => p_directive.sequence_id  ),
                                    p_task.device_id
                                   );

      -- Get pipe timeout
      p_directive.pipe_timeout :=
         NVL
            (get_config_parameter (p_name                => 'PIPE_TIMEOUT',
                                   p_device_type_id      => p_task.device_type_id
                                  ),
             5
            );
   END;

   PROCEDURE add_directive_to_queue (
      p_task             IN              wms_device_requests_wcsv%ROWTYPE,
      p_directive        IN OUT NOCOPY   wms_carousel_directive_queue%ROWTYPE,
      p_dir_dep_seg_id   IN              VARCHAR2,
      p_dir_dep_seq_id   IN              NUMBER
   )
   IS
      v_query VARCHAR2(4000);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_directive_queue_status VARCHAR2 (3);
   BEGIN
      IF (l_debug > 0) THEN
        LOG (p_task.device_id,   'Building directive strings: request_id='
           || p_task.request_id
           || ', task_id='
           || p_task.task_id
           || ', directive='
           || p_directive.directive
          );
      END IF;
      -- Build request and response strings
      v_query := p_directive.request;
      build_directive_string (p_task        => p_task,
                              p_query       => v_query,
                              p_result      => p_directive.request
                             );
      v_query := p_directive.response;
      build_directive_string (p_task        => p_task,
                              p_query       => v_query,
                              p_result      => p_directive.response
                             );
      -- Get dependency id
      p_directive.prev_id :=
         get_dependency_id (p_directive           => p_directive,
                            p_dir_dep_seg_id      => p_dir_dep_seg_id,
                            p_dir_dep_seq_id      => p_dir_dep_seq_id
                           );
      l_directive_queue_status :=
		NVL
		(get_config_parameter(
		       p_name                => 'DIRECTIVE_QUEUE_STATUS',
		       p_device_type_id      => p_directive.device_type_id,
		       p_business_event_id   => p_directive.business_event_id,
		       p_sequence_id         => p_directive.sequence_id
		      ),
		'P'
		);

      IF (l_debug > 0) THEN
        LOG ( p_task.device_id, 'Adding directive to queue: request_id='
           || p_task.request_id
           || ', task_id='
           || p_task.task_id
           || ', directive='
           || p_directive.directive
           || ', request='
           || p_directive.request
           || ', response='
           || p_directive.response
	   || ', l_directive_queue_status='
	   || l_directive_queue_status
          );
      END IF;
      INSERT INTO wms_carousel_directive_queue
                  (CAROUSEL_DIRECTIVE_QUEUE_ID , request_id, task_id,
                   sequence_id, SUBINVENTORY,
                   directive, prev_id,
                   request, response,
                   response_timeout, max_attempts,
                   status, send_pipe, pipe_timeout,
                   receive_pipe, device_id,
                   device_type_id, addr,
                   segment1, segment2,
                   segment3, segment4,
                   segment5, segment6,
                   segment7, segment8,
                   segment9, segment10
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,CREATION_DATE
                   ,CREATED_BY
                   ,LAST_UPDATE_LOGIN
                   ,business_event_id
                  )
           VALUES (WMS_CAROUSEL_DIRECTIVE_QUEUE_S.NEXTVAL, p_task.request_id, p_task.task_id,
                   p_directive.sequence_id, p_directive.subinventory,
                   p_directive.directive, p_directive.prev_id,
                   p_directive.request, p_directive.response,
                   p_directive.response_timeout, p_directive.max_attempts,
                   l_directive_queue_status, p_directive.send_pipe, p_directive.pipe_timeout,
                   p_directive.receive_pipe, p_directive.device_id,
                   p_directive.device_type_id, p_directive.addr,
                   p_directive.segment1, p_directive.segment2,
                   p_directive.segment3, p_directive.segment4,
                   p_directive.segment5, p_directive.segment6,
                   p_directive.segment7, p_directive.segment8,
                   p_directive.segment9, p_directive.segment10
                   ,SYSDATE
                   ,fnd_global.user_id
                   ,SYSDATE
                   ,fnd_global.user_id
                   ,fnd_global.login_id
                   ,p_directive.business_event_id
                  );
   END;

   --
   --
   PROCEDURE build_directive_string (
      p_task     IN              wms_device_requests_wcsv%ROWTYPE,
      p_query    IN              VARCHAR2,
      p_result   OUT NOCOPY      VARCHAR2
   )
   IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      -- Do nothing if empty
      IF (p_query is NULL) --NVL (p_query, 'null') = 'null'
      THEN
         IF (l_debug > 0) THEN
	   LOG (p_task.device_id, 'NULL Query and hence doing nothing');
	 END IF;
         p_result := NULL;
         RETURN;
      END IF;
      IF (UPPER(SUBSTR(LTRIM(P_QUERY),1,6)) = 'SELECT') THEN
	      IF (l_debug > 0) THEN
	        LOG (p_task.device_id, 'Executing dynamic query: ' || p_query || ',using: ' || p_task.request_id ||','|| p_task.task_id);
	      END IF;
	      EXECUTE IMMEDIATE p_query
			   INTO p_result
			  USING p_task.request_id, p_task.task_id;
      ELSE
	      IF (l_debug > 0) THEN
	        LOG (p_task.device_id, '(' || p_query || ') is not a query, hence returning the same.');
              END IF;
	      p_result := p_query;
      END IF;
      -- Execute the dynamic SQL query
   EXCEPTION
      WHEN OTHERS
      THEN
         IF (l_debug > 0) THEN
           LOG (p_task.device_id, 'Error executing query: ' || SQLERRM);
         END IF;
   END;

   --
   --
   FUNCTION get_dependency_id (
      p_directive        IN   wms_carousel_directive_queue%ROWTYPE,
      p_dir_dep_seg_id   IN   VARCHAR2,
      p_dir_dep_seq_id   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_segment           VARCHAR2 (64);
      v_segment_formula   VARCHAR2 (128);
      v_seg_id            NUMBER;
      v_query             VARCHAR2 (1024);
      v_dep_id            NUMBER;
      i                   NUMBER;
      v_pos1              NUMBER;
      v_pos2              NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      -- Any dependency speficied ?
      IF    NVL (p_dir_dep_seg_id, 'null') = 'null'
         OR NVL (p_dir_dep_seq_id, 0) = 0
      THEN
         RETURN NULL;
      END IF;

      -- Build the padded segment value
      i := 0;
      v_pos1 := 0;
      v_segment := '';
      v_segment_formula := '';

      LOOP
         -- Get a single segment id
         v_pos2 := INSTR (p_dir_dep_seg_id || ',', ',', v_pos1 + 1);
         EXIT WHEN NVL (v_pos2, 0) = 0;
         v_seg_id :=
                   SUBSTR (p_dir_dep_seg_id, v_pos1 + 1, v_pos2 - v_pos1 - 1);
         v_pos1 := v_pos2;
         i := i + 1;
         -- Pad segment value
         v_segment_formula :=
                          v_segment_formula || '||''.''||segment' || v_seg_id;

         IF v_seg_id = 1
         THEN
            v_segment := v_segment || '.' || p_directive.segment1;
         ELSIF v_seg_id = 2
         THEN
            v_segment := v_segment || '.' || p_directive.segment2;
         ELSIF v_seg_id = 3
         THEN
            v_segment := v_segment || '.' || p_directive.segment3;
         ELSIF v_seg_id = 4
         THEN
            v_segment := v_segment || '.' || p_directive.segment4;
         ELSIF v_seg_id = 5
         THEN
            v_segment := v_segment || '.' || p_directive.segment5;
         ELSIF v_seg_id = 6
         THEN
            v_segment := v_segment || '.' || p_directive.segment6;
         ELSIF v_seg_id = 7
         THEN
            v_segment := v_segment || '.' || p_directive.segment7;
         ELSIF v_seg_id = 8
         THEN
            v_segment := v_segment || '.' || p_directive.segment8;
         ELSIF v_seg_id = 9
         THEN
            v_segment := v_segment || '.' || p_directive.segment9;
         ELSIF v_seg_id = 10
         THEN
            v_segment := v_segment || '.' || p_directive.segment10;
         END IF;
      END LOOP;

      -- No segment value - no dependency
      IF    NVL (v_segment, 'null') = 'null'
         OR NVL (v_segment_formula, 'null') = 'null'
      THEN
         RETURN NULL;
      END IF;

      -- Remove extra || from the formula and . from segment
      v_segment_formula := SUBSTR (v_segment_formula, 8);
      v_segment := SUBSTR (v_segment, 2);
      -- Obtain dependency id
      IF (l_debug > 0) THEN
      LOG (p_directive.device_id, 'Dependency lookup, dep_seg_id='
           || p_dir_dep_seg_id
           || ', dep_seq_id='
           || p_dir_dep_seq_id
           || ', padded segment='
           || v_segment
           || ', segment formula='
           || v_segment_formula
          );
      END IF;
      v_query :=
            'select max(CAROUSEL_DIRECTIVE_QUEUE_ID) '
         || ' from wms_carousel_directive_queue'
         || ' where sequence_id='
         || ':dir_dep_seq_id'
         || '  and '
         || ':seg_formula'
         || '='
         || ':seg';
      IF (l_debug > 0) THEN
        LOG (p_directive.device_id, 'Executing dynamic query: ' || v_query);
      END IF;

      EXECUTE IMMEDIATE v_query
                   INTO v_dep_id
		   USING p_dir_dep_seq_id, v_segment_formula, v_segment;

      IF (l_debug > 0) THEN
        LOG (p_directive.device_id, 'Dependency lookup, dependency_id=' || v_dep_id);
      END IF;
      RETURN v_dep_id;
   END;

   --
   --
   PROCEDURE process_directive_queue
   IS
      -- Cursor for directives to process
      CURSOR c_directives_to_process
      IS
         SELECT     *
               FROM wms_carousel_directive_queue a
              WHERE (      -- this set of clauses is for timed-out directives
                     status = 'C'                     -- has to be current
                     AND (SYSDATE - last_attempt) * 24 * 60 * 60 >= response_timeout
                    )
                 OR (     -- this set of clauses is for independent directives
                     NVL(status,'P') = 'P'           -- has to be a new directive
                     AND CAROUSEL_DIRECTIVE_QUEUE_ID  =       -- has to be the first of such by sequence
                            (SELECT MIN (CAROUSEL_DIRECTIVE_QUEUE_ID)
                               FROM wms_carousel_directive_queue b
                              WHERE b.request_id = a.request_id
                                -- same request
                                AND b.task_id = a.task_id         -- same task
                                AND NVL (b.status, 'P') in ('P','C')
                                                             -- include current ones
                            )
                     AND (                            -- has to be independent
                             prev_id IS NULL   -- either independent by itself
                          OR NOT EXISTS      -- or the predecessor is finished
                                       (
                                SELECT *
                                  FROM wms_carousel_directive_queue c
                                 WHERE c.CAROUSEL_DIRECTIVE_QUEUE_ID = a.prev_id          -- dependency
                                   AND NVL (c.status, 'P') in ('P','C')
                                                                -- include current ones
                             )
                         )
                    )
           ORDER BY CAROUSEL_DIRECTIVE_QUEUE_ID
         FOR UPDATE;

      v_status   wms_carousel_directive_queue.status%TYPE;
      v_count    NUMBER                                     := 1;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_exec_action VARCHAR2 (4000);
      l_directive_pause_delay NUMBER;
      l_directive_cascade_failure VARCHAR2 (4000);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      WHILE v_count > 0
      LOOP
         v_count := 0;

         -- Process all independent directives
         FOR v_directive IN c_directives_to_process
         LOOP
            v_count := v_count + 1;

            -- Check the number of attempts
            IF NVL (v_directive.attempts, 0) >= v_directive.max_attempts
            THEN
               --
               --
               --
               l_directive_cascade_failure :=
                  NVL
                  (get_config_parameter(
                    p_name                => 'DIRECTIVE_CASCADE_FAILURE',
                    p_device_type_id      => v_directive.device_type_id,
                    p_business_event_id   => v_directive.business_event_id,
                    p_sequence_id         => v_directive.sequence_id
                   ),
                  'N'
                  );

               IF l_directive_cascade_failure = 'Y' THEN
                  -- Mark as Failure
                  -- The current directive as well as all the rest of them in sequence
                  UPDATE wms_carousel_directive_queue
                     SET status = 'F', last_attempt = SYSDATE
                   WHERE request_id = v_directive.request_id
                     AND task_id = v_directive.task_id
                     AND sequence_id >= v_directive.sequence_id;
               ELSE
                  -- Mark as Failure
                  -- Only the current directive
                  UPDATE wms_carousel_directive_queue
                     SET status = 'F', last_attempt = SYSDATE
                   WHERE request_id = v_directive.request_id
                     AND task_id = v_directive.task_id
                  AND directive = v_directive.directive;
               END IF;

               -- Notify the WMS of the failure
               notify_failure_to_wms (v_directive.request_id,
                                      v_directive.task_id
                                     );
               IF (l_debug > 0) THEN
      	         LOG
                        (v_directive.device_id, 'Maximum timeout attempts reached, marking as failure, id='
                         || v_directive.CAROUSEL_DIRECTIVE_QUEUE_ID
                         || ', request_id='
                         || v_directive.request_id
                         || ', task_id='
                         || v_directive.task_id
                         || ', directive='
                         || v_directive.directive
                         || ', zone='
                         || v_directive.subinventory
                         || ', attempt='
                         || (NVL (v_directive.attempts, 0) + 1)
                        );
               END IF;
            ELSE
               -- Empty request = no request to send
               IF NVL (v_directive.request, 'null') = 'null'
               THEN
                  IF (l_debug > 0) THEN
		    LOG (v_directive.device_id, 'No request to be sent, id='
                       || v_directive.CAROUSEL_DIRECTIVE_QUEUE_ID
                       || ', request_id='
                       || v_directive.request_id
                       || ', task_id='
                       || v_directive.task_id
                       || ', directive='
                       || v_directive.directive
                       || ', zone='
                       || v_directive.subinventory
                      );
		  END IF;
               ELSE
	   -- Bug# 4311016
      -- Query if the directive has a pause delay associated in the config table
      -- If yes then call a private method to wait for the specified duration
      -- If there is no directive then the default value is 0 (no delay)
      l_directive_pause_delay :=
         NVL
         (get_config_parameter_int(
                p_name                => 'DIRECTIVE_PAUSE_DELAY',
                p_device_type_id      => v_directive.device_type_id,
                p_business_event_id   => v_directive.business_event_id,
                p_sequence_id         => v_directive.sequence_id
               ),
         0
         );

      IF (l_debug > 0) THEN
         LOG (v_directive.device_id, 'DIRECTIVE_PAUSE_DELAY set to: '
              ||l_directive_pause_delay
              || ' seconds');
      END IF;

      IF l_directive_pause_delay > 0 THEN
         IF (l_debug > 0) THEN
            LOG (v_directive.device_id, 'Calling pause_directive to wait for '
                 ||l_directive_pause_delay
                 ||' seconds');
         END IF;
         pause_directive(
               p_device_id        => v_directive.device_id,
               p_delay_in_seconds => l_directive_pause_delay
         );
      END IF;

		-- place the 'DIRECTIVE_EXECUTE_ACTION'
		-- we have an entry in the request column, however, since there is an associated ACTION
		-- we DO NOT send to the PIPE, we execute
		l_exec_action :=
			NVL
			(get_config_parameter(
			       p_name                => 'DIRECTIVE_EXECUTE_ACTION',
			       p_device_type_id      => v_directive.device_type_id,
			       p_business_event_id   => v_directive.business_event_id,
			       p_sequence_id         => v_directive.sequence_id
			      ),
			'N'
			);
		 IF (l_exec_action = 'Y')
		    THEN
		       IF (l_debug > 0) THEN
			 LOG (v_directive.device_id, 'EXECUTE ACTION enabled, executing: '
			      ||v_directive.request
			      || 'USING request_id='
			      || v_directive.request_id
			      || ', task_id='
			      || v_directive.task_id);
		      END IF;
		      EXECUTE IMMEDIATE v_directive.request
				  USING v_directive.request_id, v_directive.task_id;
		 ELSE
                    IF (l_debug > 0) THEN
	               LOG (v_directive.device_id, 'Sending current directive, id='
                       || v_directive.CAROUSEL_DIRECTIVE_QUEUE_ID
                       || ', request_id='
                       || v_directive.request_id
                       || ', task_id='
                       || v_directive.task_id
                       || ', directive='
                       || v_directive.directive
                       || ', request='
                       || v_directive.request
                       || ', zone='
                       || v_directive.subinventory
                       || ', attempt='
                       || (NVL (v_directive.attempts, 0) + 1)
                       || ', send_pipe='
                       || v_directive.send_pipe
                      );
                    END IF;
		  -- Push the directive into the pipe
                  send_directive (v_directive.device_id,
                  v_directive.send_pipe,
                                  v_directive.addr,
                                  v_directive.request,
                                  v_directive.pipe_timeout
                                 );
                 END IF;
               END IF;

               -- Empty response = no need to wait for response
               IF NVL (v_directive.response, 'null') = 'null'
               THEN
                  -- Mark as success right away
                  v_status := 'S';
               ELSE
                  -- Current, wait for response
                  v_status := 'C';
               END IF;

               -- Update the directive status, set attempts and last_attempt
               UPDATE wms_carousel_directive_queue
                  SET status = v_status,
                      attempts = NVL (v_directive.attempts, 0) + 1,
                      last_attempt = SYSDATE
                WHERE CURRENT OF c_directives_to_process;
            END IF;
         END LOOP;
      END LOOP;

      -- Commit the changes
      COMMIT;
      -- Purge the directive queue
      purge_queue;

    EXCEPTION
      WHEN OTHERS
      THEN
         IF (l_debug > 0) THEN
           LOG (v_directive.device_id, 'Error executing query: ' || SQLERRM);
         END IF;
   END;

   --
   --
   PROCEDURE send_directive (
      p_device_id   IN   NUMBER,
      p_pipe_name   IN   VARCHAR2,
      p_addr        IN   VARCHAR2,
      p_directive   IN   VARCHAR2,
      p_time_out    IN   NUMBER
   )
   IS
      v_pipe_size   INTEGER := 1048576;          -- size of the pipe in bytes
   BEGIN
      -- pack the data
      DBMS_PIPE.reset_buffer;
      DBMS_PIPE.pack_message (NVL (p_addr, '1'));
      DBMS_PIPE.pack_message (NVL (p_directive, 'empty'));

      -- push it into the pipe
      IF (DBMS_PIPE.send_message (p_pipe_name, p_time_out, v_pipe_size) <> 0)
      THEN
         RAISE send_pipe_exception;
      END IF;
   END;

   --
   --
   FUNCTION checksum (p_data IN VARCHAR2)
      RETURN NUMBER
   IS
      v_csum   NUMBER := 0;
   BEGIN
      -- Sum up ascii values
      FOR i IN 1 .. LENGTH (p_data)
      LOOP
         v_csum := v_csum + ASCII (SUBSTR (p_data, i, 1));
      END LOOP;

      -- Modulus (same as double amp 0x7F, the spec has redundant steps)
      -- v_csum := MOD (v_csum, 128);

      -- Or 0x40, means set the 2^6 bit
      -- At this point means add 64, if it is less then 64
      IF v_csum < 64
      THEN
         v_csum := v_csum + 64;
      END IF;

      -- Return it
      RETURN v_csum;
   END;

   --
   --
   FUNCTION hex (p_data IN NUMBER)
      RETURN VARCHAR2
   IS
      TYPE hex_map IS VARRAY (16) OF VARCHAR2 (1);

      v_map   hex_map
         := hex_map ('0',
                     '1',
                     '2',
                     '3',
                     '4',
                     '5',
                     '6',
                     '7',
                     '8',
                     '9',
                     'A',
                     'B',
                     'C',
                     'D',
                     'E',
                     'F'
                    );
      v_hex   VARCHAR2 (8) := '';
      v_dgt   NUMBER;
      v_pow   NUMBER       := 1;
   BEGIN
      -- Translate by digit
      LOOP
         EXIT WHEN v_pow > p_data;
         v_dgt := MOD (TRUNC (p_data / v_pow), 16);
         v_hex := v_map (v_dgt + 1) || v_hex;
         v_pow := v_pow * 16;
      END LOOP;

      -- Return it
      RETURN v_hex;
   END;

   --
   --
   PROCEDURE LOG (p_device_id in number, p_data IN VARCHAR2)
   IS
      cnt   NUMBER;
--      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      inv_log_util.trace('MHP:Device='
                           || p_device_id
                           || ':'
                           || p_data, 'WMS_CAROUSEL_INTEGRATION_PVT', 9);
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
   END;

   --
   --
   FUNCTION get_carousel_number (p_locator IN VARCHAR2)
      RETURN NUMBER
   IS
      v_pos1   NUMBER;
      v_pos2   NUMBER;
   BEGIN
      --  Retrieve carousel from the locator (...carousel.bin.v_pos.h_pos.depth)
      v_pos1 := NVL (INSTR (p_locator, '.', -1, 5), 0);
      v_pos2 := NVL (INSTR (p_locator, '.', -1, 4), 0);

      IF v_pos2 = 0
      THEN
         RETURN NULL;
      END IF;

      RETURN SUBSTR (p_locator, v_pos1 + 1, v_pos2 - v_pos1 - 1);
   END;
   --
   --
   PROCEDURE notify_failure_to_wms (p_request_id IN NUMBER, p_task_id IN NUMBER)
   IS
   BEGIN
      NULL;
   END;

   --
   --
   PROCEDURE update_queue (p_request_id IN NUMBER, p_device_id IN NUMBER, P_STATUS IN VARCHAR2, p_config_name IN VARCHAR2, p_task_id IN NUMBER DEFAULT NULL)
   IS
      CURSOR c_current_msg (p_request_id  IN NUMBER,
		                      p_config_name IN VARCHAR2,
		                      p_task_id     IN NUMBER)
      IS
		SELECT *
		FROM WMS_CAROUSEL_DIRECTIVE_QUEUE  q
		WHERE q.REQUEST_ID = P_REQUEST_ID
		AND  NVL(q.TASK_ID,0) = NVL(P_TASK_ID,NVL(q.TASK_ID,0))
		AND  NVL (q.STATUS, 'P') IN ('C', 'P')
		AND q.DIRECTIVE IN
          (SELECT CONFIG_VALUE
		       FROM WMS_CAROUSEL_CONFIGURATION
		      WHERE CONFIG_NAME = NVL(p_config_name,'DIRECTIVE_QUEUE_UPDATE')
		        AND DEVICE_TYPE_ID = q.DEVICE_TYPE_ID
			     AND BUSINESS_EVENT_ID = q.BUSINESS_EVENT_ID
			     AND SEQUENCE_ID = q.SEQUENCE_ID
			     AND ACTIVE_IND = 'Y')
		ORDER BY q.REQUEST_ID, q.DEVICE_TYPE_ID, q.BUSINESS_EVENT_ID, q.SEQUENCE_ID
		FOR UPDATE;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
         -- Update the queue table and mark the corresponding directive status
    FOR v_current_msg IN c_current_msg (p_request_id  => p_request_id,
	                                     p_config_name => p_config_name,
                                        p_task_id     => p_task_id)
       LOOP
	      UPDATE WMS_CAROUSEL_DIRECTIVE_QUEUE Q
              SET STATUS = P_STATUS,
              LAST_UPDATE_DATE = SYSDATE
              WHERE CURRENT OF c_current_msg;
       END LOOP;
     COMMIT;
   END;

   --
   PROCEDURE cancel_task (p_request_id IN NUMBER, p_device_id IN NUMBER, p_task_id IN NUMBER DEFAULT NULL)
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug > 0) THEN
        LOG (p_device_id,   'Cancelling task at WMS request, request_id='
           || p_request_id
           || ', task_id='
           || p_task_id
          );
      END IF;
      update_queue (p_request_id, p_device_id, 'X', 'DIRECTIVE_CANCEL_TASK', p_task_id);
   END;

   --
   PROCEDURE skip_task (p_request_id IN NUMBER, p_device_id IN NUMBER, p_task_id IN NUMBER DEFAULT NULL)
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug > 0) THEN
        LOG (p_device_id,   'Skipping task at WMS request, request_id='
           || p_request_id
           || ', task_id='
           || p_task_id
          );
      END IF;
      update_queue (p_request_id, p_device_id, 'X', 'DIRECTIVE_SKIP_TASK', p_task_id);
   END;

   --
   --
   PROCEDURE complete_task (p_request_id IN NUMBER, p_device_id IN NUMBER, p_task_id IN NUMBER DEFAULT NULL)
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug > 0) THEN
        LOG (p_device_id,   'Completing task at WMS request, request_id='
           || p_request_id
           || ', task_id='
           || p_task_id
          );
      END IF;
      update_queue (p_request_id, p_device_id, 'S', 'DIRECTIVE_COMPLETE_TASK', p_task_id);
   END;

   --
   --
   PROCEDURE purge_queue
   IS
      v_purge_interval   NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      v_purge_interval :=
                    NVL (get_config_parameter ('QUEUE_PURGE_INTERVAL'), 3600);

      DELETE FROM wms_carousel_directive_queue
            WHERE status IN ('S', 'F', 'X') -- Success, failure, or cancelled
              AND (SYSDATE - nvl(last_attempt,LAST_UPDATE_DATE)) * 24 * 60 * 60 >= v_purge_interval;

      /*
      Commented out for Bug# 4624894

      DELETE FROM wms_carousel_log
            WHERE SYSDATE - LAST_UPDATE_DATE  > 1;
      */

      COMMIT;
   END;

   --
   --
   FUNCTION get_device_type_id (p_device_id IN NUMBER)
      RETURN NUMBER
   IS
      v_device_type_id   NUMBER := NULL;
   BEGIN
      -- Obtain device_type_id
      SELECT device_type_id
        INTO v_device_type_id
        FROM wms_devices_b
       WHERE device_id = p_device_id;

      RETURN v_device_type_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

PROCEDURE read_pipe_content(
   p_device_id       IN   VARCHAR2,
   x_pipe_name       OUT NOCOPY   VARCHAR2,
   x_message_code   OUT NOCOPY   NUMBER,
   x_message            OUT NOCOPY   VARCHAR2,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
)
IS
   l_message_received   NUMBER;
   /*
   0 - no error
   1 - pipe timed out
   2 - record in pipe too large for buffer
   3 - interrupt occurred
   ORA-23322 - insufficient privileges to write to the pipe
   */
      v_addr           VARCHAR2 (64);
   l_got_msg            VARCHAR2 (2000);
   l_pipe_removed       NUMBER;
   l_reading_pipe       VARCHAR2(40);
   l_device_pause_delay NUMBER;
   --4311016
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   x_return_status    := fnd_api.g_ret_sts_success;
      -- Get pipe NAME
      l_reading_pipe :=
         NVL (get_config_parameter (p_name => 'PIPE_NAME',
                                    p_sequence_id => p_device_id),
              p_device_id
             );
      l_reading_pipe := 'OUT_' || l_reading_pipe;

   --Receive the message from the SGA into the local buffer of session 2
   l_message_received := DBMS_PIPE.receive_message (l_reading_pipe);
   DBMS_PIPE.unpack_message (v_addr);
   DBMS_PIPE.unpack_message (l_got_msg);
   ---4311016
         IF (l_debug > 0) THEN
           LOG ( p_device_id, 'In read_pipe_content. l_reading_pipe='
              || l_reading_pipe
              || ', l_got_msg='
              || l_got_msg
             );
         END IF;
   x_pipe_name := l_reading_pipe;
   x_message_code := l_message_received;
   x_message := l_got_msg;

     -- Query if the device has a pause delay associated in the config table
      -- If yes then call a private method to wait for the specified duration
      -- If there is no directive then the default value is 0 (no delay)
         l_device_pause_delay :=
                      NVL(get_config_parameter(p_name        => 'DEVICE_SEND_DELAY',
                                               p_sequence_id => p_device_id),0);
         IF l_device_pause_delay > 0 THEN
            IF (l_debug > 0) THEN
               LOG (p_device_id, 'DEVICE_SEND_DELAY set to: '
                 ||l_device_pause_delay
                 || ' seconds');
               LOG (p_device_id, 'Calling pause_directive to wait for '
                    ||l_device_pause_delay
                    ||' seconds');
            END IF;
            pause_directive(p_device_id        => p_device_id,
                            p_delay_in_seconds => l_device_pause_delay);
         END IF;

   COMMIT;
   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := fnd_api.G_RET_STS_ERROR;
      x_msg_data := SQLERRM;
END read_pipe_content;
--
--
FUNCTION ascii_csv_to_string (
   p_ascii_csv         IN   VARCHAR2
)
   RETURN VARCHAR2 IS
   l_string           VARCHAR2 (4000) := '';
   l_start_position   NUMBER          := 1;
   l_instr_output     NUMBER          := 1;
   l_char_count       NUMBER          := 0;
   l_ascii_value      NUMBER;
   l_begin            VARCHAR2 (4000);
   l_end              VARCHAR2 (4000);
   l_output           VARCHAR2 (4000) := '';
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   l_string := p_ascii_csv;
   /*
	Check if the first and last character of the input string is '
	If yes then trim the ' from either side of the input string and return that as output
	With this change, at the time of setting up the message template start and end delimiters
	the WCS administrator can enter comma separated ASCII values like 65,66 OR just enclose
	a literal string like 'START' or 'END' for the runtime message parsing to happen correctly
   */
   SELECT SUBSTR (l_string, 1, 1), SUBSTR (l_string, -1, 1)
     INTO l_begin, l_end
     FROM DUAL;
   IF (l_begin = '''' AND l_end = '''')
   THEN
      l_output := RTRIM (LTRIM (l_string, ''''), '''');
      --DBMS_OUTPUT.put_line ('l_output=' || l_output);
	  RETURN l_output;
   END IF;
   l_string := REPLACE (l_string, ' ', '');
   WHILE l_instr_output <> 0
   LOOP
      l_char_count := l_char_count + 1;
      --We assume that , will be the delimiter always here
      SELECT INSTR (l_string, ',', 1, l_char_count)
        INTO l_instr_output
        FROM DUAL;
      SELECT SUBSTR (l_string,
                     l_start_position,
                     (  DECODE (l_instr_output,
                                0, LENGTH (l_string)+1,
                                l_instr_output
                               )
                      - l_start_position
                     )
                    )
        INTO l_ascii_value
        FROM DUAL;
      l_output := l_output || fnd_global.local_chr (l_ascii_value);
      l_start_position := l_instr_output + 1;
   END LOOP;
   RETURN l_output;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END ascii_csv_to_string;

PROCEDURE get_component_details (
   p_device_id             IN              NUMBER,
   p_template_id           IN              NUMBER,
   p_component_no          IN              NUMBER,
   x_component_code        OUT NOCOPY      NUMBER,
   x_component_meaning     OUT NOCOPY      VARCHAR2,
   x_start_comp_delimiter  OUT NOCOPY      VARCHAR2,
   x_end_comp_delimiter    OUT NOCOPY      VARCHAR2,
   x_return_status         OUT NOCOPY      VARCHAR2,
   x_msg_count             OUT NOCOPY      NUMBER,
   x_msg_data              OUT NOCOPY      VARCHAR2
)
IS
   CURSOR msg_components (p_templ_id NUMBER, p_comp_no NUMBER)
   IS
   	SELECT template_id, sequence_id, component, component_length,
   	       left_or_right_padded, padding_character, start_component_delimiter,
   	       end_component_delimiter
   	  FROM (SELECT wmc.*, ROWNUM rnum
   		  FROM (SELECT   *
   			    FROM wms_msg_components
   			   WHERE template_id = p_templ_id
   			ORDER BY sequence_id) wmc
   		 WHERE ROWNUM <= p_comp_no)
   	 WHERE rnum >= p_comp_no;
   l_msg_component   msg_components%ROWTYPE;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   OPEN msg_components (p_template_id, p_component_no);
   FETCH msg_components
    INTO l_msg_component;

   SELECT lookup_code, meaning
     INTO x_component_code, x_component_meaning
     FROM mfg_lookups
    WHERE lookup_type = 'WMS_DEVICE_MSG_COMPONENTS'
      AND lookup_code = l_msg_component.component;

   /*
   SELECT lookup_code, meaning
     INTO x_datatype_code, x_datatype_meaning
     FROM mfg_lookups
    WHERE lookup_type = 'WMS_DATA_TYPE'
      AND lookup_code = l_msg_component.datatype;
      */

   x_start_comp_delimiter := l_msg_component.start_component_delimiter;
   x_end_comp_delimiter   := l_msg_component.end_component_delimiter;
   CLOSE msg_components;
EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := SQLERRM;
END get_component_details;

/*
API name parse_device_response
*/

PROCEDURE parse_device_response (
   p_device_id       IN              NUMBER,
   p_request_id      IN              NUMBER,
   p_msg             IN              VARCHAR2,
   p_template_id     IN              NUMBER,
   x_return_status   OUT NOCOPY      VARCHAR2,
   x_msg_count       OUT NOCOPY      NUMBER,
   x_msg_data        OUT NOCOPY      VARCHAR2
)
IS
   --  The following is a typical test data set, 1 for each message type
   --
   /*
   p_device_id               NUMBER                        := 441;
   p_msg                     VARCHAR2 (4000)  := 'ABCERROR:PLT102:W1:BULKDEF';
   p_template_id             NUMBER                        := 1;
   */
   /*
   p_device_id               NUMBER                        := 442;
   p_msg                     VARCHAR2 (4000)  := 'MNprTaskLUTPicked(WCS,PLT101M,54,"25-JAN-2005")PQ';
   p_template_id             NUMBER                        := 2;
   */
   /*
   p_device_id               NUMBER                        := 443;
   p_msg                     VARCHAR2 (4000)
                               := 'GHIW1PLT100    0000005600DOZEN LPN128A  PQ';
   p_template_id             NUMBER                        := 3;
   */
   /*
   p_device_id               NUMBER                        := 444;
   p_msg                     VARCHAR2 (4000)
      := 'GHI<?xml version="1.0" ?><MESSAGE><ORG>W1</ORG><ITEM>EMM100</ITEM><QTY>500</QTY><ACTION>SUCCESS</ACTION><LPN>LPN1023A</LPN></MESSAGE>PQ';
   p_template_id             NUMBER                        := 4;
   */
   l_msg                     VARCHAR2 (4000);
   l_param_delimiter         VARCHAR2 (1);
   --l_msg_delimiter             VARCHAR2 (1);
   l_start_delimiter         VARCHAR2 (4000);
   l_end_delimiter           VARCHAR2 (4000);
   l_msg_type                NUMBER;
   --Assumption: This is different from the param_delimiter
   l_no_of_msg_comps         NUMBER                        := 0;
   l_instr_output            NUMBER                        := 1;
   l_substr_output           VARCHAR2 (4000);
   l_start_position          NUMBER                        := 1;
   --Assumption: First character is msg_delimiter
   l_end_position            NUMBER;
   l_msg_component           VARCHAR2 (200);
   TYPE output_record IS RECORD (
      component_no           NUMBER,
      component_meaning      VARCHAR2 (80),
      component_value        VARCHAR2 (240),
      start_comp_delimiter   VARCHAR2 (80),
      end_comp_delimiter     VARCHAR2 (80)
   );
   TYPE output_type IS TABLE OF output_record
      INDEX BY BINARY_INTEGER;
   output_table              output_type;
   l_template_id             NUMBER                        := 1;
   l_index                   NUMBER;
   CURSOR msg_template_record (p_templ_id NUMBER)
   IS
      SELECT *
        FROM wms_msg_templates
       WHERE template_id = p_templ_id;
   CURSOR msg_component_records (p_templ_id NUMBER)
   IS
      SELECT *
        FROM wms_msg_components
       WHERE template_id = p_templ_id
    ORDER BY sequence_id;
   l_template_record         msg_template_record%ROWTYPE;
   l_component_record        wms_msg_components%ROWTYPE;
   l_return_status           VARCHAR2 (1);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2 (240);
   l_device_id               NUMBER;
   l_delimiter               VARCHAR2 (1)                  := '(';
   l_occurrence              NUMBER                        := 1;
   msg_component_exception   EXCEPTION;
   -- Variables for xml message parsing
   l_parser                  xmlparser.parser;
   l_doc                     xmldom.domdocument;
   l_named_node_map          xmldom.domnamednodemap;
   l_attribute_name          VARCHAR2 (100);
   l_actual_attribute_name   VARCHAR2 (100);
   l_attribute_value         VARCHAR2 (100);
   l_nodelist_length         NUMBER;
   l_dom_node                xmldom.domnode;
   l_nodelist                xmldom.domnodelist;
   l_attributes_buffer       VARCHAR2 (4000);
   l_response_record         WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE;
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   l_template_id := p_template_id;
   l_device_id := p_device_id;
   OPEN msg_template_record (l_template_id);
   FETCH msg_template_record
    INTO l_template_record;
   l_param_delimiter :=
                 fnd_global.local_chr (l_template_record.parameter_delimiter);
   --Convert the ascii csv to a string representation
   l_start_delimiter :=
      wms_carousel_integration_pvt.ascii_csv_to_string
                                   (l_template_record.start_message_delimiter);
   l_end_delimiter :=
      wms_carousel_integration_pvt.ascii_csv_to_string
                                     (l_template_record.end_message_delimiter);

   --l_start_delimiter := l_template_record.start_message_delimiter;
   --l_end_delimiter := l_template_record.end_message_delimiter;

   l_msg_type := l_template_record.wms_msg_template_type;
   l_msg := p_msg;
   IF l_debug > 0 THEN
      LOG (p_device_id, '****************************Start****************************');
      LOG (p_device_id, 'Device id       is ' || p_device_id);
      LOG (p_device_id, 'Request id      is ' || p_request_id);
      LOG (p_device_id, 'Template id     is ' || p_template_id);
      LOG (p_device_id, 'Message         is ' || l_msg);
      LOG (p_device_id, 'Message type    is ' || l_msg_type);
      LOG (p_device_id, 'Start delimiter is ''' || l_start_delimiter||'''');
      LOG (p_device_id, 'End   delimiter is ''' || l_end_delimiter||'''');
      LOG (p_device_id, 'Param delimiter is ' || l_param_delimiter);
   END IF;

   l_msg := LTRIM (l_msg, l_start_delimiter);
   l_msg := RTRIM (l_msg);
   l_msg := RTRIM (l_msg, l_end_delimiter);

   IF l_debug > 0 THEN
      LOG
                      (p_device_id,    'Message after stripping start and end delimiters is '
                       || l_msg
                      );
   END IF;
   IF l_msg_type = wms_carousel_integration_pvt.v_xml_msg
   THEN
      FOR l_comp_record IN msg_component_records (l_template_id)
      LOOP
         --l_no_of_msg_comps := l_no_of_msg_comps + 1;
         l_attributes_buffer :=
                            l_attributes_buffer || l_comp_record.xml_tag_name;
      END LOOP;
      --LOG (p_device_id, 'l_attributes_buffer = '||l_attributes_buffer);
      l_parser := xmlparser.newparser;
      xmlparser.parsebuffer (l_parser, l_msg);
      l_doc := xmlparser.getdocument (l_parser);
      -- get all elements
      l_nodelist := xmldom.getelementsbytagname (l_doc, '*');
      l_nodelist_length := xmldom.getlength (l_nodelist);
      -- loop through elements
      FOR i IN 0 .. l_nodelist_length - 1
      LOOP
         l_dom_node := xmldom.item (l_nodelist, i);
         --LOG (p_device_id, xmldom.getnodename (l_dom_node) || ' ');
         --LOG (p_device_id, '--------------');
         l_actual_attribute_name := xmldom.getnodename (l_dom_node);
         --This will come from the new component table
         /*
         IF l_actual_attribute_name IN
                            ('ORG', 'ITEM', 'QTY', 'ACTION', 'LPN', 'DEVCOMP1')
                            */
         IF (INSTR (l_attributes_buffer, l_actual_attribute_name) IS NOT NULL
            )
         THEN
            --LOG (p_device_id, 'i=' || TO_CHAR (i));
            -- get all attributes of element
            l_named_node_map := xmldom.getattributes (l_dom_node);
            l_dom_node := xmldom.getfirstchild (l_dom_node);
            IF xmldom.isnull (l_dom_node) = FALSE
            THEN
               l_attribute_name := xmldom.getnodename (l_dom_node);
               IF xmldom.getnodetype (l_dom_node) = xmldom.text_node
               THEN
                  l_no_of_msg_comps := l_no_of_msg_comps + 1;
                  --LOG(p_device_id, 'l_no_of_msg_comps'||l_no_of_msg_comps);
                  l_attribute_value := xmldom.getnodevalue (l_dom_node);
                  IF l_debug > 0 THEN
                     LOG (p_device_id,    'l_attribute_name= '
                                           || l_actual_attribute_name
                                           || ' val= '
                                           || l_attribute_value
                                          );
                  END IF;
                  --
                  --
                  DECLARE
                  BEGIN
                     wms_carousel_integration_pvt.get_component_details
                        (p_device_id                 => l_device_id,
                         p_template_id               => l_template_id,
                         p_component_no              => l_no_of_msg_comps,
                         x_component_code            => output_table
                                                            (l_no_of_msg_comps).component_no,
                         x_component_meaning         => output_table
                                                            (l_no_of_msg_comps).component_meaning,
                         x_start_comp_delimiter      => output_table
                                                            (l_no_of_msg_comps).start_comp_delimiter,
                         x_end_comp_delimiter        => output_table
                                                            (l_no_of_msg_comps).end_comp_delimiter,
                         x_return_status             => l_return_status,
                         x_msg_count                 => l_msg_count,
                         x_msg_data                  => l_msg_data
                        );
                     IF l_return_status <> fnd_api.g_ret_sts_success
                     THEN
                        RAISE msg_component_exception;
                     END IF;
                  --output_table (l_no_of_msg_comps).component_value := l_attribute_value;
                  EXCEPTION
                     WHEN msg_component_exception
                     THEN
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                                   p_data       => x_msg_data
                                                  );
                     WHEN OTHERS
                     THEN
                        x_return_status := fnd_api.g_ret_sts_unexp_error;
                        fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                                   p_data       => x_msg_data
                                                  );
                  END;
                  --
                  --
                  output_table (l_no_of_msg_comps).component_value :=
                                                             l_attribute_value;
                  wms_carousel_integration_pvt.populate_response_record
      			   (
                    p_device_id         =>   p_device_id,
      			     p_component_code    =>   output_table (l_no_of_msg_comps).component_no,
                    p_msg_component     =>   l_attribute_value,
                    p_response_record   =>   l_response_record
      			   );
               END IF;
            ELSE
               IF l_debug > 0 THEN
                  LOG (p_device_id,    'l_attribute_name= '
                                        || l_actual_attribute_name
                                        || ' val= '
                                        || NULL
                                       );
               END IF;
            END IF;
         END IF;
      END LOOP;
      xmlparser.freeparser (l_parser);
      xmldom.freedocument (l_doc);
   ELSIF l_msg_type = wms_carousel_integration_pvt.v_msg_with_delimiter
   THEN
      --This is the start of parsing logic for message of type 2
      --Message with delimiter
      WHILE l_instr_output <> 0
      LOOP
         l_no_of_msg_comps := l_no_of_msg_comps + 1;
         SELECT INSTR (l_msg, l_param_delimiter, 1, l_no_of_msg_comps)
           INTO l_instr_output
           FROM DUAL;
         SELECT SUBSTR (l_msg,
                        l_start_position,
                        (  DECODE (l_instr_output,
                                   0, LENGTH (l_msg) + 1,
                                   l_instr_output
                                  )
                         - l_start_position
                        )
                       )
           INTO l_msg_component
           FROM DUAL;
         DECLARE
         BEGIN
            wms_carousel_integration_pvt.get_component_details
               (p_device_id                 => l_device_id,
                p_template_id               => l_template_id,
                p_component_no              => l_no_of_msg_comps,
                x_component_code            => output_table (l_no_of_msg_comps).component_no,
                x_component_meaning         => output_table (l_no_of_msg_comps).component_meaning,
                x_start_comp_delimiter      => output_table (l_no_of_msg_comps).start_comp_delimiter,
                x_end_comp_delimiter        => output_table (l_no_of_msg_comps).end_comp_delimiter,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data
               );
            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               RAISE msg_component_exception;
            END IF;
            output_table (l_no_of_msg_comps).component_value :=
                                                               l_msg_component;
            wms_carousel_integration_pvt.populate_response_record
			   (
                p_device_id         =>   p_device_id,
    			    p_component_code    =>   output_table (l_no_of_msg_comps).component_no,
                p_msg_component     =>   l_msg_component,
                p_response_record   =>   l_response_record
			   );
         EXCEPTION
            WHEN msg_component_exception
            THEN
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                          p_data       => x_msg_data
                                         );
            WHEN OTHERS
            THEN
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                          p_data       => x_msg_data
                                         );
         END;
         l_start_position := l_instr_output + 1;
         IF l_debug > 0 THEN
            LOG (p_device_id,    'Msg Component '
                                  || l_no_of_msg_comps
                                  || ' ---> '
                                  || l_msg_component
                                 );
         END IF;
      END LOOP;
   ELSIF l_msg_type = wms_carousel_integration_pvt.v_msg_without_delimiter
   THEN
      FOR l_comp_record IN msg_component_records (l_template_id)
      LOOP
         l_no_of_msg_comps := l_no_of_msg_comps + 1;
         SELECT SUBSTR (l_msg,
                        l_start_position,
                        l_comp_record.component_length
                       )
           INTO l_substr_output
           FROM DUAL;
         /*
         LOG (p_device_id, 'l_substr_output: ''' || l_substr_output
                               || ''''
                              );
         LOG (p_device_id,    'left_or_right_padded: '
                               || l_comp_record.left_or_right_padded
                              );
         */
         IF l_comp_record.left_or_right_padded = 'L'
         THEN
            l_msg_component :=
               LTRIM (l_substr_output,
                      fnd_global.local_chr (l_comp_record.padding_character)
                     );
         ELSIF l_comp_record.left_or_right_padded = 'R'
         THEN
            l_msg_component :=
               RTRIM (l_substr_output,
                      fnd_global.local_chr (l_comp_record.padding_character)
                     );
         END IF;
         BEGIN
            wms_carousel_integration_pvt.get_component_details
               (p_device_id                 => l_device_id,
                p_template_id               => l_template_id,
                p_component_no              => l_no_of_msg_comps,
                x_component_code            => output_table (l_no_of_msg_comps).component_no,
                x_component_meaning         => output_table (l_no_of_msg_comps).component_meaning,
                x_start_comp_delimiter      => output_table (l_no_of_msg_comps).start_comp_delimiter,
                x_end_comp_delimiter        => output_table (l_no_of_msg_comps).end_comp_delimiter,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data
               );
            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               RAISE msg_component_exception;
            END IF;
            output_table (l_no_of_msg_comps).component_value :=
                                                               l_msg_component;
            wms_carousel_integration_pvt.populate_response_record
			   (
                p_device_id         =>   p_device_id,
			       p_component_code    =>   output_table (l_no_of_msg_comps).component_no,
                p_msg_component     =>   l_msg_component,
                p_response_record   =>   l_response_record
			   );
         EXCEPTION
            WHEN msg_component_exception
            THEN
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                          p_data       => x_msg_data
                                         );
            WHEN OTHERS
            THEN
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                          p_data       => x_msg_data
                                         );
         END;
         --
         --
         l_start_position := l_start_position + l_comp_record.component_length;
      END LOOP;
   ELSIF l_msg_type = wms_carousel_integration_pvt.v_vocollect_msg
   THEN
      WHILE l_instr_output <> 0
      LOOP
         l_no_of_msg_comps := l_no_of_msg_comps + 1;
         --LOG(p_device_id, 'l_no_of_msg_comps: '||l_no_of_msg_comps);
         --LOG(p_device_id, 'l_start_position: '||l_start_position);
         --Treat the first component as a special case
         IF l_no_of_msg_comps <> 1
         THEN
            l_delimiter := ',';
            l_occurrence := l_no_of_msg_comps - 1;
         END IF;
         --LOG(p_device_id, 'l_delimiter: '||l_delimiter);
         --LOG(p_device_id, 'l_occurrence: '||l_occurrence);
         SELECT INSTR (l_msg, l_delimiter, 1, l_occurrence)
           INTO l_instr_output
           FROM DUAL;
         --LOG(p_device_id, 'l_instr_output: '||l_instr_output);
         SELECT SUBSTR (l_msg,
                        l_start_position,
                        (  DECODE (l_instr_output,
                                   0, LENGTH (l_msg),
                                   l_instr_output
                                  )
                         - l_start_position
                        )
                       )
           INTO l_msg_component
           FROM DUAL;
         --LOG('p_device_id, l_msg_component: '||l_msg_component);
         BEGIN
            wms_carousel_integration_pvt.get_component_details
               (p_device_id                 => l_device_id,
                p_template_id               => l_template_id,
                p_component_no              => l_no_of_msg_comps,
                x_component_code            => output_table (l_no_of_msg_comps).component_no,
                x_component_meaning         => output_table (l_no_of_msg_comps).component_meaning,
                x_start_comp_delimiter      => output_table (l_no_of_msg_comps).start_comp_delimiter,
                x_end_comp_delimiter        => output_table (l_no_of_msg_comps).end_comp_delimiter,
                x_return_status             => l_return_status,
                x_msg_count                 => l_msg_count,
                x_msg_data                  => l_msg_data
               );
            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               RAISE msg_component_exception;
            END IF;
            --LOG(p_device_id, 'output_table (l_no_of_msg_comps).start_comp_delimiter: '||output_table (l_no_of_msg_comps).start_comp_delimiter);
            --LOG(p_device_id, 'output_table (l_no_of_msg_comps).end_comp_delimiter: '||output_table (l_no_of_msg_comps).end_comp_delimiter);
            IF output_table (l_no_of_msg_comps).start_comp_delimiter IS NOT NULL
            THEN
               l_msg_component :=
                  LTRIM (l_msg_component,
                         output_table (l_no_of_msg_comps).start_comp_delimiter
                        );
            END IF;
            IF output_table (l_no_of_msg_comps).end_comp_delimiter IS NOT NULL
            THEN
               l_msg_component :=
                  RTRIM (l_msg_component,
                         output_table (l_no_of_msg_comps).end_comp_delimiter
                        );
            END IF;
            output_table (l_no_of_msg_comps).component_value :=
                                                               l_msg_component;
            wms_carousel_integration_pvt.populate_response_record
			   (
                p_device_id         =>   p_device_id,
			       p_component_code    =>   output_table (l_no_of_msg_comps).component_no,
                p_msg_component     =>   l_msg_component,
                p_response_record   =>   l_response_record
			   );
         EXCEPTION
            WHEN msg_component_exception
            THEN
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                          p_data       => x_msg_data
                                         );
            WHEN OTHERS
            THEN
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                          p_data       => x_msg_data
                                         );
         END;
         --l_msg := LTRIM(l_msg, l_msg_component);
         --LOG(p_device_id, 'Message after stripping API: '||l_msg);
         --Now remove the parantheses
         --l_msg := RTRIM(LTRIM (l_msg, '('), ')');
         l_start_position := l_instr_output + 1;
      --LOG(p_device_id, 'Message after stripping ( ): '||l_msg);
      END LOOP;
   END IF;

   IF l_debug > 0 THEN
      LOG (p_device_id,    'There are '
                            || l_no_of_msg_comps
                            || ' components in msg '
                            || l_msg
                           );
      LOG
         (p_device_id, '---------------------------------------------------------------------------------------------'
         );
      LOG
         (p_device_id, 'CompCode| Component Meaning        |     ComponentValue      | CStrtDelim | CEndDelim'
         );
      LOG
         (p_device_id, '---------------------------------------------------------------------------------------------'
         );
   END IF;

   FOR i IN output_table.FIRST .. output_table.LAST
   LOOP
      IF l_debug > 0 THEN
         LOG (p_device_id,    LPAD (output_table (i).component_no, 4)
                               || '    |'
                               || LPAD (output_table (i).component_meaning, 26)
                               || '|'
                               || LPAD (output_table (i).component_value, 25)
                               || '|'
                               || LPAD (output_table (i).start_comp_delimiter,
                                        12)
                               || '|'
                               || LPAD (output_table (i).end_comp_delimiter, 12)
                              );
      END IF;
   END LOOP;

   IF l_debug > 0 THEN
      LOG (p_device_id, '---------------------------------------------------------------------------------------------'
          );
      LOG (p_device_id, 'Calling log_response_record... l_debug is '
           || l_debug
           );
   END IF;

   wms_carousel_integration_pvt.log_response_record
      (
       p_device_id       =>   p_device_id,
	    p_response_record =>   l_response_record
	   );

   IF l_debug > 0 THEN
      LOG (p_device_id, 'Calling wms_wcs_device_grp.process_response '
           || l_debug
           );
   END IF;
   wms_wcs_device_grp.process_response
      (
         p_device_id           => p_device_id,
         p_request_id          => p_request_id,
         p_param_values_record => l_response_record,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data
      );
   LOG (p_device_id, '****************************End****************************');
   CLOSE msg_template_record;
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      IF l_debug > 0 THEN
         LOG (p_device_id, 'Unexpected error in parse_device_response for p_request_id='
              || p_request_id
              );
      END IF;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);
END parse_device_response;
--
--
PROCEDURE populate_response_record (
   p_device_id         IN              NUMBER,
   p_component_code    IN              NUMBER,
   p_msg_component     IN              VARCHAR2,
   p_response_record   IN OUT NOCOPY   WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE
)
   IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF l_debug > 0 THEN
      log (p_device_id, 'In Populate_response_record. p_component_code='
           || p_component_code
           || ', p_msg_component='
           || p_msg_component);
   END IF;
   IF p_component_code = 1
   THEN
      p_response_record.ORGANIZATION := p_msg_component;
   ELSIF p_component_code = 2
   THEN
      p_response_record.order_number := p_msg_component;
   ELSIF p_component_code = 3
   THEN
      p_response_record.item := p_msg_component;
   ELSIF p_component_code = 4
   THEN
      p_response_record.business_event := p_msg_component;
   ELSIF p_component_code = 5
   THEN
      p_response_record.action := p_msg_component;
   ELSIF p_component_code = 6
   THEN
      p_response_record.device_id := p_msg_component;
   ELSIF p_component_code = 7
   THEN
      p_response_record.host_id := p_msg_component;
   ELSIF p_component_code = 8
   THEN
      p_response_record.subinventory := p_msg_component;
   ELSIF p_component_code = 9
   THEN
      p_response_record.LOCATOR := p_msg_component;
   ELSIF p_component_code = 10
   THEN
      p_response_record.lpn := p_msg_component;
   ELSIF p_component_code = 11
   THEN
      p_response_record.lot := p_msg_component;
   ELSIF p_component_code = 12
   THEN
      p_response_record.uom := p_msg_component;
   ELSIF p_component_code = 13
   THEN
      p_response_record.cycle_count_id := p_msg_component;
   ELSIF p_component_code = 14
   THEN
      p_response_record.quantity := p_msg_component;
   ELSIF p_component_code = 15
   THEN
      p_response_record.requested_quantity := p_msg_component;
   ELSIF p_component_code = 16
   THEN
      p_response_record.weight := p_msg_component;
   ELSIF p_component_code = 17
   THEN
      p_response_record.weight_uom_code := p_msg_component;
   ELSIF p_component_code = 18
   THEN
      p_response_record.volume := p_msg_component;
   ELSIF p_component_code = 19
   THEN
      p_response_record.volume_uom_code := p_msg_component;
   ELSIF p_component_code = 20
   THEN
      p_response_record.LENGTH := p_msg_component;
   ELSIF p_component_code = 21
   THEN
      p_response_record.width := p_msg_component;
   ELSIF p_component_code = 22
   THEN
      p_response_record.height := p_msg_component;
   ELSIF p_component_code = 23
   THEN
      p_response_record.dimensional_weight := p_msg_component;
   ELSIF p_component_code = 24
   THEN
      p_response_record.dimensional_weight_factor := p_msg_component;
   ELSIF p_component_code = 25
   THEN
      p_response_record.net_weight := p_msg_component;
   ELSIF p_component_code = 26
   THEN
      p_response_record.received_request_date_and_time := p_msg_component;
   ELSIF p_component_code = 27
   THEN
      p_response_record.measurement_date_and_time := p_msg_component;
   ELSIF p_component_code = 28
   THEN
      p_response_record.response_date_and_time := p_msg_component;
   ELSIF p_component_code = 29
   THEN
      p_response_record.temperature := p_msg_component;
   ELSIF p_component_code = 30
   THEN
      p_response_record.temperature_uom := p_msg_component;
   ELSIF p_component_code = 31
   THEN
      p_response_record.reason_id := p_msg_component;
   ELSIF p_component_code = 32
   THEN
      p_response_record.reason_type := p_msg_component;
   ELSIF p_component_code = 33
   THEN
      p_response_record.sensor_measurement_type := p_msg_component;
   ELSIF p_component_code = 34
   THEN
      p_response_record.VALUE := p_msg_component;
   ELSIF p_component_code = 35
   THEN
      p_response_record.quality := p_msg_component;
   ELSIF p_component_code = 36
   THEN
      p_response_record.opc_variant_code := p_msg_component;
   ELSIF p_component_code = 37
   THEN
      p_response_record.epc := p_msg_component;
   ELSIF p_component_code = 38
   THEN
      p_response_record.UNUSED := p_msg_component;
   ELSIF p_component_code = 39
   THEN
      p_response_record.batch := p_msg_component;
   ELSIF p_component_code = 40
   THEN
      p_response_record.device_component_1 := p_msg_component;
   ELSIF p_component_code = 41
   THEN
      p_response_record.device_component_2 := p_msg_component;
   ELSIF p_component_code = 42
   THEN
      p_response_record.device_component_3 := p_msg_component;
   ELSIF p_component_code = 43
   THEN
      p_response_record.device_component_4 := p_msg_component;
   ELSIF p_component_code = 44
   THEN
      p_response_record.device_component_5 := p_msg_component;
   ELSIF p_component_code = 45
   THEN
      p_response_record.device_component_6 := p_msg_component;
   ELSIF p_component_code = 46
   THEN
      p_response_record.device_component_7 := p_msg_component;
   ELSIF p_component_code = 47
   THEN
      p_response_record.device_component_8 := p_msg_component;
   ELSIF p_component_code = 48
   THEN
      p_response_record.device_component_9 := p_msg_component;
   ELSIF p_component_code = 49
   THEN
      p_response_record.device_component_10 := p_msg_component;
   ELSIF p_component_code = 50
   THEN
      p_response_record.relation_id := p_msg_component;
   ELSIF p_component_code = 51
   THEN
      p_response_record.task_id := p_msg_component;
   ELSIF p_component_code = 52
   THEN
      p_response_record.task_summary := p_msg_component;
   ELSIF p_component_code = 53
   THEN
      p_response_record.organization_id := p_msg_component;
   ELSIF p_component_code = 54
   THEN
      p_response_record.inventory_item_id := p_msg_component;
   ELSIF p_component_code = 55
   THEN
      p_response_record.device_status := p_msg_component;
   ELSIF p_component_code = 56
   THEN
      p_response_record.transfer_lpn_id := p_msg_component;
   ELSIF p_component_code = 57
   THEN
      p_response_record.destination_subinventory := p_msg_component;
   ELSIF p_component_code = 58
   THEN
      p_response_record.destination_locator_id := p_msg_component;
   ELSIF p_component_code = 59
   THEN
   p_response_record.source_locator_id := p_msg_component;
   ELSIF  (l_debug > 0)
   THEN
      log (p_device_id, 'In populate_response_record. Invalid p_component_code:'
           ||p_component_code);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      IF (l_debug > 0)
      THEN
         LOG (p_device_id, 'Exception in populate_response_record:' || SQLERRM);
      END IF;
END populate_response_record;
--
--
PROCEDURE log_response_record (
   p_device_id       IN NUMBER,
   p_response_record IN WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE
)
   IS
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      IF (l_debug > 0) THEN
         log
         (p_device_id,   'In log_response_record. Contents of the response record are--->');
         log (p_device_id, 'organization=' || p_response_record.organization);
         log (p_device_id, ', order_number=' || p_response_record.order_number);
         log (p_device_id, ', item=' || p_response_record.item);
         log (p_device_id, ', business_event=' || p_response_record.business_event);
         log (p_device_id, ', action=' || p_response_record.action);
         log (p_device_id, ', device_id=' || p_response_record.device_id);
         log (p_device_id, ', host_id=' || p_response_record.host_id);
         log (p_device_id, ', subinventory=' || p_response_record.subinventory);
         log (p_device_id, ', LOCATOR=' || p_response_record.LOCATOR);
         log (p_device_id, ', lpn=' || p_response_record.lpn);
         log (p_device_id, ', lot=' || p_response_record.lot);
         log (p_device_id, ', uom=' || p_response_record.uom);
         log (p_device_id, ', cycle_count_id=' || p_response_record.cycle_count_id);
         log (p_device_id, ', quantity=' || p_response_record.quantity);
         log (p_device_id, ', requested_quantity=' || p_response_record.requested_quantity);
         log (p_device_id, ', weight=' || p_response_record.weight);
         log (p_device_id, ', weight_uom_code=' || p_response_record.weight_uom_code);
         log (p_device_id, ', volume=' || p_response_record.volume);
         log (p_device_id, ', volume_uom_code=' || p_response_record.volume_uom_code);
         log (p_device_id, ', LENGTH=' || p_response_record.LENGTH);
         log (p_device_id, ', width=' || p_response_record.width);
         log (p_device_id, ', height=' || p_response_record.height);
         log (p_device_id, ', dimensional_weight=' || p_response_record.dimensional_weight);
         log (p_device_id, ', dimensional_weight_factor=' || p_response_record.dimensional_weight_factor);
         log (p_device_id, ', net_weight=' || p_response_record.net_weight);
         log (p_device_id, ', received_request_date_and_time=' || p_response_record.received_request_date_and_time);
         log (p_device_id, ', measurement_date_and_time=' || p_response_record.measurement_date_and_time);
         log (p_device_id, ', response_date_and_time=' || p_response_record.response_date_and_time);
         log (p_device_id, ', temperature=' || p_response_record.temperature);
         log (p_device_id, ', temperature_uom=' || p_response_record.temperature_uom);
         log (p_device_id, ', reason_id=' || p_response_record.reason_id);
         log (p_device_id, ', reason_type=' || p_response_record.reason_type);
         log (p_device_id, ', sensor_measurement_type=' || p_response_record.sensor_measurement_type);
         log (p_device_id, ', VALUE=' || p_response_record.VALUE);
         log (p_device_id, ', quality=' || p_response_record.quality);
         log (p_device_id, ', opc_variant_code=' || p_response_record.opc_variant_code);
         log (p_device_id, ', epc=' || p_response_record.epc);
         log (p_device_id, ', UNUSED=' || p_response_record.UNUSED);
         log (p_device_id, ', batch=' || p_response_record.batch);
         log (p_device_id, ', device_component_1=' || p_response_record.device_component_1);
         log (p_device_id, ', device_component_2=' || p_response_record.device_component_2);
         log (p_device_id, ', device_component_3=' || p_response_record.device_component_3);
         log (p_device_id, ', device_component_4=' || p_response_record.device_component_4);
         log (p_device_id, ', device_component_5=' || p_response_record.device_component_5);
         log (p_device_id, ', device_component_6=' || p_response_record.device_component_6);
         log (p_device_id, ', device_component_7=' || p_response_record.device_component_7);
         log (p_device_id, ', device_component_8=' || p_response_record.device_component_8);
         log (p_device_id, ', device_component_9=' || p_response_record.device_component_9);
         log (p_device_id, ', device_component_10=' || p_response_record.device_component_10);
         log (p_device_id, ', relation_id=' || p_response_record.relation_id);
         log (p_device_id, ', task_id=' || p_response_record.task_id);
         log (p_device_id, ', task_summary=' || p_response_record.task_summary);
         log (p_device_id, ', organization_id=' || p_response_record.organization_id);
         log (p_device_id, ', inventory_item_id=' || p_response_record.inventory_item_id);
         log (p_device_id, ', device_status=' || p_response_record.device_status);
         log (p_device_id, ', transfer_lpn_id=' || p_response_record.transfer_lpn_id);
         log (p_device_id, ', destination_subinventory=' || p_response_record.destination_subinventory);
         log (p_device_id, ', destination_locator_id=' || p_response_record.destination_locator_id);
         log (p_device_id, ', source_locator_id=' || p_response_record.source_locator_id);
      END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      IF (l_debug > 0)
      THEN
         LOG (p_device_id, 'Exception in log_response_record:' || SQLERRM);
      END IF;
END log_response_record;

--
-- Private Procedure to slow down the application if the hardware is not able to keep pace
-- The duration of the wait will be controlled by a configurable paramter 'DIRECTIVE_PAUSE_DELAY'
--
PROCEDURE pause_directive(
   p_device_id          IN NUMBER,
   p_delay_in_seconds   IN NUMBER
)
   IS
   l_count NUMBER := 0;
   l_time  DATE;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_time := SYSDATE + (p_delay_in_seconds/(86400));
   WHILE l_time > SYSDATE LOOP
      l_count := l_count + 1;
   END LOOP ;
   IF (l_debug > 0) THEN
     LOG(p_device_id, 'In pause_directive. Done waiting for '
         || p_delay_in_seconds
         || 'seconds. l_count='
         || l_count);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug > 0) THEN
        LOG(p_device_id, 'Exception in pause_directive:'||SQLERRM);
      END IF;
END pause_directive;

END wms_carousel_integration_pvt;

/
