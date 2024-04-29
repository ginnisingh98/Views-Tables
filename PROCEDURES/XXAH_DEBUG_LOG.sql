--------------------------------------------------------
--  DDL for Procedure XXAH_DEBUG_LOG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_DEBUG_LOG" (
   p_interface_header_id   IN VARCHAR2,
   p_flow_status           IN VARCHAR2,
   p_error_message         IN VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   i   INTEGER;
BEGIN
   --SELECT xx_event_log_tab_s.NEXTVAL INTO i FROM DUAL;

   UPDATE xxah_po_headers_interface
      SET flow_status = p_flow_status, error_message = p_error_message
    WHERE interface_header_id = p_interface_header_id;

   COMMIT;
END xxah_debug_log;

/
