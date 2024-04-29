--------------------------------------------------------
--  DDL for Package CSL_JTF_TASKS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_JTF_TASKS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csltkacs.pls 120.0 2005/05/24 17:34:57 appldev noship $ */

FUNCTION Replicate_Record
  ( p_task_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if task record should be replicated. Returns TRUE if it should ***/

FUNCTION Pre_Insert_Child
  ( p_task_id     IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL)
RETURN BOOLEAN;
/***
  Public function that gets called when a task needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

PROCEDURE Post_Delete_Child
  ( p_task_id     IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  );
/***
  Public procedure that gets called when a task needs to be deleted from ACC table.
***/

PROCEDURE PRE_INSERT_TASK ( x_return_status OUT NOCOPY varchar2);
/* Called before task Insert */

PROCEDURE POST_INSERT_TASK ( x_return_status OUT NOCOPY varchar2);
/* Called after task Insert */

PROCEDURE PRE_UPDATE_TASK ( x_return_status OUT NOCOPY varchar2);
/* Called before task Update */

PROCEDURE POST_UPDATE_TASK ( x_return_status OUT NOCOPY varchar2);
/* Called after task Update */

PROCEDURE PRE_DELETE_TASK ( x_return_status OUT NOCOPY varchar2);
/* Called before task Delete */

PROCEDURE POST_DELETE_TASK ( x_return_status OUT NOCOPY varchar2);
/* Called after task Delete */

PROCEDURE INSERT_ALL_ACC_RECORDS
  ( p_resource_id   IN  NUMBER
  , x_return_status OUT NOCOPY VARCHAR2 );
/* Called during user creation */

/*Procedure to purge completed/expired Tasks Assignments*/
--Bug 3475657
PROCEDURE PURGE_TASKS;

END CSL_JTF_TASKS_ACC_PKG;

 

/
