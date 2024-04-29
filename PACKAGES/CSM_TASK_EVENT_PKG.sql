--------------------------------------------------------
--  DDL for Package CSM_TASK_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TASK_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmetsks.pls 120.1 2005/07/25 00:27:45 trajasek noship $ */

-- Generated 6/13/2002 7:56:38 PM from APPS@MOBSVC01.US.ORACLE.COM

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE ACC_INSERT (p_user_id in fnd_user.user_id%TYPE,
                      p_task_id jtf_tasks_b.task_id%TYPE);

PROCEDURE ACC_DELETE (p_user_id in fnd_user.user_id%TYPE,
                      p_task_id jtf_tasks_b.task_id%TYPE);

PROCEDURE PURGE_TASKS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE CHECK_ESCALATION_TASKS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE TASK_MAKE_DIRTY_U_FOREACHUSER(p_task_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE TASK_INS_INIT(p_task_id IN NUMBER);

PROCEDURE TASK_DEL_INIT(p_task_id IN NUMBER);

END; -- Package spec

 

/
