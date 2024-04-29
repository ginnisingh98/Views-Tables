--------------------------------------------------------
--  DDL for Package CSL_CSF_DEBRIEF_HDR_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSF_DEBRIEF_HDR_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csldhacs.pls 115.3 2003/08/28 10:07:54 vekrishn ship $ */

  /*** Function that checks if debrief line should be replicated.
       Returns TRUE if it should ***/
  FUNCTION Replicate_Record
    ( p_debrief_header_id NUMBER
    )
  RETURN BOOLEAN;


  /*** Public procedure that gets called when a user needs to be inserted
       into ACC table.  ***/
  PROCEDURE Insert_Debrief_Header
    ( p_debrief_header_id     IN NUMBER
     ,p_resource_id           IN NUMBER
    );


  /*** Public procedure that gets called when a user needs to be updated
       into ACC table.  ***/
  PROCEDURE Update_Debrief_Header
    ( p_debrief_header_id     IN NUMBER
     ,p_resource_id           IN NUMBER
    );


  /*** Public procedure that gets called when a user needs to be deleted
       from ACC table.  ***/
  PROCEDURE Delete_Debrief_Header
    ( p_debrief_header_id     IN NUMBER
     ,p_resource_id           IN NUMBER
    );


  /* Called before debrief_header Insert */
  PROCEDURE PRE_INSERT_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  );


  /* Called after debrief_header Insert */
  PROCEDURE POST_INSERT_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  );

  /* Called before debrief_header Update */
  PROCEDURE PRE_UPDATE_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  );

  /* Called after debrief_header Update */
  PROCEDURE POST_UPDATE_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  );

  /* Called before debrief_header delete */
  PROCEDURE PRE_DELETE_DEBRIEF_HEADER
  ( x_return_status out NOCOPY varchar2
  );


END CSL_CSF_DEBRIEF_HDR_ACC_PKG;

 

/
