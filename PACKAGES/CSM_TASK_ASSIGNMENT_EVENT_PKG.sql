--------------------------------------------------------
--  DDL for Package CSM_TASK_ASSIGNMENT_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TASK_ASSIGNMENT_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmetas.pls 120.1 2005/07/25 00:26:36 trajasek noship $ */

-- Generated 6/13/2002 7:56:05 PM from APPS@MOBSVC01.US.ORACLE.COM

-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE PURGE_TASK_ASSIGNMENTS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE TASK_ASSIGNMENT_INITIALIZER (p_task_assignment_id IN NUMBER,
                                       p_error_msg     OUT NOCOPY    VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE SPAWN_DEBRIEF_HEADER_INS (p_task_assignment_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_DEBRIEF_LINE_INS (p_task_assignment_id IN NUMBER,
                                  p_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_REQUIREMENT_HEADER_INS(p_task_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_REQUIREMENT_LINES_INS(p_task_assignment_id IN NUMBER,
                                      p_user_id IN NUMBER,
                                      p_flow_type IN VARCHAR2);

PROCEDURE TASK_ASSIGNMENTS_ACC_PROCESSOR(p_task_assignment_id IN NUMBER,
                                         p_incident_id IN NUMBER,
                                         p_task_id IN NUMBER,
                                         p_source_object_type_code IN VARCHAR2,
                                         p_flow_type IN VARCHAR2,
                                         p_user_id IN NUMBER);

PROCEDURE ACC_INSERT(p_task_assignment_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE LOBS_MDIRTY_I(p_task_assignment_id IN NUMBER, p_resource_id IN NUMBER);

PROCEDURE TASK_ASSIGNMENT_HIST_INIT(p_task_assignment_id IN NUMBER,
                                    p_parent_incident_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_error_msg  OUT NOCOPY VARCHAR2,
                                    x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE TASK_ASSIGNMENT_PURGE_INIT (p_task_assignment_id IN NUMBER,
                                      p_error_msg     OUT NOCOPY    VARCHAR2,
                                      x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE LOBS_MDIRTY_D(p_task_assignment_id IN NUMBER, p_resource_id IN NUMBER);

PROCEDURE SPAWN_DEBRIEF_LINE_DEL (p_task_assignment_id IN NUMBER,
                                  p_user_id IN NUMBER,
                                  p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_DEBRIEF_HEADER_DEL (p_task_assignment_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_REQUIREMENT_HEADER_DEL(p_task_assignment_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flow_type IN VARCHAR2);

PROCEDURE SPAWN_REQUIREMENT_LINES_DEL(p_task_assignment_id IN NUMBER,
                                      p_user_id IN NUMBER,
                                      p_flow_type IN VARCHAR2);

PROCEDURE TASK_ASSIGNMENTS_ACC_D(p_task_assignment_id IN NUMBER,
                                 p_incident_id IN NUMBER,
                                 p_task_id IN NUMBER,
                                 p_source_object_type_code IN VARCHAR2,
                                 p_flow_type IN VARCHAR2,
                                 p_user_id IN NUMBER);

PROCEDURE ACC_DELETE(p_task_assignment_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE TASK_ASSIGNMENT_HIST_DEL_INIT(p_task_assignment_id IN NUMBER,
                                    p_parent_incident_id IN NUMBER,
                                    p_user_id IN NUMBER,
                                    p_error_msg  OUT NOCOPY VARCHAR2,
                                    x_return_status IN OUT NOCOPY VARCHAR2);

END CSM_TASK_ASSIGNMENT_EVENT_PKG;
-- Package spec

 

/
