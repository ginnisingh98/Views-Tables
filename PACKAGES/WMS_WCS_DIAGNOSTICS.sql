--------------------------------------------------------
--  DDL for Package WMS_WCS_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WCS_DIAGNOSTICS" AUTHID CURRENT_USER AS
   /* $Header: WMSDIAGS.pls 120.0 2005/05/24 19:11:42 appldev noship $ */

   v_row               wms_carousel_configuration%ROWTYPE;

   PROCEDURE run;

   --PROCEDURE check_objects;

   --PROCEDURE check_privileges;

   PROCEDURE check_wms_integration;

   PROCEDURE check_configuration;

   PROCEDURE check_jobs;

   PROCEDURE update_hash_value;

   /*
   PROCEDURE export_configuration (
      p_device_type_ids   IN   VARCHAR2,
      p_zones             IN   VARCHAR2
   );
   */

   PROCEDURE test_task (
      p_zone                IN   VARCHAR2,
      p_device_type_id      IN   NUMBER,
      p_locator             IN   VARCHAR2,
      p_directive           IN   VARCHAR2 DEFAULT 'GO',
      p_task_type_id        IN   NUMBER DEFAULT 10,
      p_quantity            IN   NUMBER DEFAULT 123,
      p_device_id           IN   NUMBER DEFAULT 0,
      p_business_event_id   IN   NUMBER DEFAULT 10,
      p_lpn                 IN   VARCHAR2 DEFAULT 'TestLPN'
   );
END wms_wcs_diagnostics;

 

/
