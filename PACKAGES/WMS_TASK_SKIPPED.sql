--------------------------------------------------------
--  DDL for Package WMS_TASK_SKIPPED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_SKIPPED" AUTHID CURRENT_USER AS
--/* $Header: WMSSKIPS.pls 120.1 2005/06/17 15:37:07 appldev  $ */

PROCEDURE skip_task_adjustments
  (x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count          OUT   NOCOPY NUMBER,
   x_msg_data           OUT   NOCOPY VARCHAR2,
   p_sign_on_emp_id     IN NUMBER,
   p_sign_on_org_id     IN NUMBER,
   p_task_id            IN NUMBER,
   p_wms_task_type      IN NUMBER);

END wms_task_skipped;

 

/
