--------------------------------------------------------
--  DDL for Package RCV_NORMALIZE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_NORMALIZE_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVNRMDS.pls 120.2.12010000.1 2008/07/24 14:36:01 appldev ship $*/
   /* Make these global so that everyone can access them */
   g_fail_all CONSTANT VARCHAR2(1) := NVL(fnd_profile.VALUE('RCV_FAIL_ALL_ROWS'), 'N');   /*WDK - TODO: LOOKUP */
   g_multiple_groups   BOOLEAN;
   g_group_id          NUMBER;
   g_request_id        NUMBER;   /* WDK - TODO: LOOKUP */
   g_processing_mode   VARCHAR2(25); -- Bug 6311798

   PROCEDURE process_pending_rows(
      p_processing_mode IN VARCHAR2,
      p_group_id        IN NUMBER,
      p_request_id      IN NUMBER,
      p_org_id          IN NUMBER DEFAULT NULL
   );
END rcv_normalize_data_pkg;

/
