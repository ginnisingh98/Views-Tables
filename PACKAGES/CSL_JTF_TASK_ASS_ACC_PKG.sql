--------------------------------------------------------
--  DDL for Package CSL_JTF_TASK_ASS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_JTF_TASK_ASS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csltaacs.pls 120.0 2005/05/25 10:59:37 appldev noship $ */

FUNCTION Replicate_Record
  ( p_task_assignment_id IN NUMBER
  , p_flow_type          IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  )
RETURN BOOLEAN;
/*** Function that checks if assignment record should be replicated. Returns TRUE if it should ***/

FUNCTION Pre_Insert_Child
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_flow_type          IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  )
RETURN BOOLEAN;
/***
  Public function that gets called when an assignment needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

PROCEDURE Post_Delete_Child
  ( p_task_assignment_id IN NUMBER
   ,p_resource_id        IN NUMBER
   ,p_flow_type          IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
  );
/***
  Public procedure that gets called when an assignment needs to be deleted from ACC table.
***/

PROCEDURE INSERT_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 );
/*Procedure that gets called when a user gets created*/
PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 );
/*Procedure that gets called when a user gets deleted*/

PROCEDURE PRE_INSERT_TASK_ASSIGNMENT ( x_return_status OUT NOCOPY varchar2);
/* Called before assignment Insert */

PROCEDURE POST_INSERT_TASK_ASSIGNMENT ( x_return_status OUT NOCOPY varchar2);
/* Called after assignment Insert */

PROCEDURE PRE_UPDATE_TASK_ASSIGNMENT ( x_return_status OUT NOCOPY varchar2);
/* Called before assignment Update */

PROCEDURE POST_UPDATE_TASK_ASSIGNMENT ( x_return_status OUT NOCOPY varchar2);
/* Called after assignment Update */

PROCEDURE PRE_DELETE_TASK_ASSIGNMENT ( x_return_status OUT NOCOPY varchar2);
/* Called before assignment Delete */

PROCEDURE POST_DELETE_TASK_ASSIGNMENT ( x_return_status OUT NOCOPY varchar2);
/* Called after assignment Delete */

/*Added by UTEKUMAL - Procedure to purge completed/expired Tasks Assignments*/
--Bug 3475657
PROCEDURE PURGE_TASK_ASSIGNMENTS(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);
END CSL_JTF_TASK_ASS_ACC_PKG;

 

/
