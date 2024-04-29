--------------------------------------------------------
--  DDL for Package WMS_CAROUSEL_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CAROUSEL_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSCSPVS.pls 120.4 2005/10/17 04:38:37 simran noship $ */

   send_pipe_exception   EXCEPTION;
   directive_exception   EXCEPTION;
   v_row               wms_carousel_configuration%ROWTYPE;
   v_directive         wms_carousel_directive_queue%ROWTYPE;
   v_msg_components    wms_msg_components%ROWTYPE;
   v_xml_msg               NUMBER := 1;
   v_msg_with_delimiter    NUMBER := 2;
   v_msg_without_delimiter NUMBER := 3;
   v_vocollect_msg         NUMBER := 4;

   --
   -- Cursor for all tasks of the request
   CURSOR c_request_tasks (p_request_id IN NUMBER)
   IS
      SELECT   *
          FROM wms_device_requests_wcsv
         WHERE request_id = p_request_id
      ORDER BY sequence_id;

   --
   --
   FUNCTION get_config_parameter (
      p_name             IN   VARCHAR2,
      p_device_type_id   IN   NUMBER DEFAULT NULL,
      p_business_event_id IN   NUMBER DEFAULT NULL,
      p_sequence_id      IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2;

   --
   --
   PROCEDURE process_request (
      p_request_id      IN              NUMBER,
      x_status_code     OUT NOCOPY      VARCHAR2,
      x_status_msg      OUT NOCOPY      VARCHAR2,
      x_device_status   OUT NOCOPY      VARCHAR2
   );

   FUNCTION get_device_type_id (p_device_id IN NUMBER)
      RETURN NUMBER;

   --
   --
   PROCEDURE add_task_directives (p_task IN c_request_tasks%ROWTYPE);

   --
   --
   PROCEDURE get_directive_config (
      p_task             IN              wms_device_requests_wcsv%ROWTYPE,
      p_directive        IN OUT NOCOPY   wms_carousel_directive_queue%ROWTYPE,
      p_dir_dep_seg_id   OUT NOCOPY      VARCHAR2,
      p_dir_dep_seq_id   OUT NOCOPY      NUMBER
   );

   --
   --
   PROCEDURE add_directive_to_queue (
      p_task             IN              wms_device_requests_wcsv%ROWTYPE,
      p_directive        IN OUT NOCOPY   wms_carousel_directive_queue%ROWTYPE,
      p_dir_dep_seg_id   IN              VARCHAR2,
      p_dir_dep_seq_id   IN              NUMBER
   );

   --
   --
   PROCEDURE build_directive_string (
      p_task     IN              wms_device_requests_wcsv%ROWTYPE,
      p_query    IN              VARCHAR2,
      p_result   OUT NOCOPY      VARCHAR2
   );

   --
   --
   FUNCTION get_dependency_id (
      p_directive        IN   wms_carousel_directive_queue%ROWTYPE,
      p_dir_dep_seg_id   IN   VARCHAR2,
      p_dir_dep_seq_id   IN   NUMBER
   )
      RETURN NUMBER;

   --
   --
   PROCEDURE process_directive_queue;

   --
   --
   PROCEDURE send_directive (
      p_device_id   IN   NUMBER,
      p_pipe_name   IN   VARCHAR2,
      p_addr        IN   VARCHAR2,
      p_directive   IN   VARCHAR2,
      p_time_out    IN   NUMBER
   );

   --
   --
   FUNCTION checksum (p_data IN VARCHAR2)
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (checksum, WNDS, WNPS);

   --
   --
   FUNCTION hex (p_data IN NUMBER)
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (hex, WNDS, WNPS);

   --
   --
   PROCEDURE LOG (p_device_id IN NUMBER, p_data IN VARCHAR2);

   --
   --
   PROCEDURE notify_failure_to_wms (
      p_request_id   IN   NUMBER,
      p_task_id      IN   NUMBER
   );

   --
   -- Bug# 4666748
   PROCEDURE response_event_handler (
      p_device_id          IN           VARCHAR2,
      p_message            IN           VARCHAR2,
      x_message_code       OUT NOCOPY   NUMBER,
      x_return_status      OUT NOCOPY   VARCHAR2,
      x_msg_count          OUT NOCOPY   NUMBER,
      x_msg_data           OUT NOCOPY   VARCHAR2
   );

   --
   -- Bug# 4666748
   PROCEDURE process_response (
      p_device_id  IN   NUMBER,
      p_response   IN   VARCHAR2
   );

   --
   --
   PROCEDURE cancel_task (
      p_request_id   IN   NUMBER,
      p_device_id    IN   NUMBER,
      p_task_id      IN   NUMBER DEFAULT NULL
   );

   --
   --
   PROCEDURE skip_task (
      p_request_id   IN   NUMBER,
      p_device_id    IN   NUMBER,
      p_task_id      IN   NUMBER DEFAULT NULL
   );

   --
   --
   PROCEDURE complete_task (
      p_request_id   IN   NUMBER,
      p_device_id    IN   NUMBER,
      p_task_id      IN   NUMBER DEFAULT NULL
   );

   --
   --
   PROCEDURE purge_queue;

PROCEDURE read_pipe_content(
   p_device_id       IN   VARCHAR2,
   x_pipe_name       OUT NOCOPY   VARCHAR2,
   x_message_code   OUT NOCOPY   NUMBER,
   x_message            OUT NOCOPY   VARCHAR2,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
);

--
--
FUNCTION ascii_csv_to_string (
   p_ascii_csv         IN   VARCHAR2
)
   RETURN VARCHAR2;
--
--
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
);
--
--
PROCEDURE parse_device_response (
   p_device_id       IN              NUMBER,
   p_request_id      IN              NUMBER,
   p_msg             IN              VARCHAR2,
   p_template_id     IN              NUMBER,
   x_return_status   OUT NOCOPY      VARCHAR2,
   x_msg_count       OUT NOCOPY      NUMBER,
   x_msg_data        OUT NOCOPY      VARCHAR2
);
--
--
PROCEDURE populate_response_record (
   p_device_id       IN              NUMBER,
   p_component_code  IN              NUMBER,
   p_msg_component   IN              VARCHAR2,
   p_response_record IN OUT NOCOPY   WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE
);
--
--
PROCEDURE log_response_record (
   p_device_id       IN NUMBER DEFAULT NULL,
   p_response_record IN WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE
);
--
--
END wms_carousel_integration_pvt;

 

/
