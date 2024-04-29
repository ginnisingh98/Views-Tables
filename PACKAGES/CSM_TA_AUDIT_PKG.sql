--------------------------------------------------------
--  DDL for Package CSM_TA_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TA_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmutaas.pls 120.1.12010000.1 2009/08/06 05:12:14 trajasek noship $ */


  /*
   * The function to be called by CSM_TASK_ASSIGNMENT_PKG, for upward sync of
   * publication item CSM_TASK_ASSIGNMENTS_AUDIT
   */

-- Purpose: Update Task Assignments Audit changes on Handheld to Enterprise database
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_assignment_id IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

PROCEDURE DEFER_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_assignment_id IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_TA_AUDIT_PKG; -- Package spec

/
