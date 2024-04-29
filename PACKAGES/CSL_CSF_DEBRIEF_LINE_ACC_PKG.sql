--------------------------------------------------------
--  DDL for Package CSL_CSF_DEBRIEF_LINE_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSF_DEBRIEF_LINE_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csldbacs.pls 120.0 2005/05/25 11:06:50 appldev noship $ */

FUNCTION Get_Debrief_Header_Id( p_debrief_line_id NUMBER)
RETURN NUMBER;
/*** Function that returns a debrief line id given a debrief line id ***/

FUNCTION Replicate_Record
  ( p_debrief_line_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if debrief line should be replicated. Returns TRUE if it should ***/

FUNCTION Pre_Insert_Child
  ( p_debrief_line_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  )
RETURN BOOLEAN;
/***
  Public function that gets called when a debrief line needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

PROCEDURE Pre_Insert_Children
  ( p_task_assignment_id  IN NUMBER
   ,p_resource_id         IN NUMBER
  );
/***
  Public function that gets called when debrief lines need to be inserted into ACC table.
***/

PROCEDURE Post_Delete_Child
  ( p_debrief_line_id     IN NUMBER
   ,p_resource_id         IN NUMBER
  );
/***
  Public procedure that gets called when a debrief line needs to be deleted from ACC table.
***/

PROCEDURE Post_Delete_Children
  ( p_task_assignment_id  IN NUMBER
   ,p_resource_id         IN NUMBER
  );
/***
  Public procedure that gets called when debrief lines need to be deleted from ACC table.
***/

PROCEDURE PRE_INSERT_DEBRIEF_LINE ( x_return_status OUT NOCOPY varchar2);
/* Called before debrief Insert */

PROCEDURE POST_INSERT_DEBRIEF_LINE ( x_return_status OUT NOCOPY varchar2);
/* Called after debrief Insert */

PROCEDURE PRE_UPDATE_DEBRIEF_LINE ( x_return_status OUT NOCOPY varchar2);
/* Called before debrief Update */

PROCEDURE POST_UPDATE_DEBRIEF_LINE ( x_return_status OUT NOCOPY varchar2);
/* Called after debrief Update */

PROCEDURE PRE_DELETE_DEBRIEF_LINE ( x_return_status OUT NOCOPY varchar2);
/* Called before debrief Delete */

PROCEDURE POST_DELETE_DEBRIEF_LINE ( x_return_status OUT NOCOPY varchar2);
/* Called after debrief Delete */

END CSL_CSF_DEBRIEF_LINE_ACC_PKG;

 

/
