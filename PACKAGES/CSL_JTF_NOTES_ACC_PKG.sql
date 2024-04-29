--------------------------------------------------------
--  DDL for Package CSL_JTF_NOTES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_JTF_NOTES_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslntacs.pls 115.4 2002/11/08 14:02:06 asiegers ship $ */

FUNCTION Replicate_Record
  ( p_jtf_note_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if note should be replicated. Returns TRUE if it should ***/

FUNCTION Pre_Insert_Child
  ( p_jtf_note_id     IN NUMBER
   ,p_resource_id     IN NUMBER
  )
RETURN BOOLEAN;
/***
  Public function that gets called when a note needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

FUNCTION Pre_Insert_Children
  ( p_source_obj_id    IN NUMBER
   ,p_source_obj_code  IN VARCHAR2
   ,p_resource_id      IN NUMBER
  )
RETURN BOOLEAN;
/***
  Public function that gets called when notes needs to be inserted into ACC table.
  Returns TRUE when record already were or have been inserted into ACC table.
***/

PROCEDURE Post_Delete_Child
  ( p_jtf_note_id     IN NUMBER
   ,p_resource_id     IN NUMBER
  );
/***
  Public procedure that gets called when a note needs to be deleted from the ACC table.
***/

PROCEDURE Post_Delete_Children
  ( p_source_obj_id    IN NUMBER
   ,p_source_obj_code  IN VARCHAR2
   ,p_resource_id      IN NUMBER
  );
/***
  Public procedure that gets called when notes needs to be deleted from the ACC table.
***/

PROCEDURE PRE_INSERT_NOTES ( x_return_status OUT NOCOPY varchar2);
/* Called before note Insert */

PROCEDURE POST_INSERT_NOTES ( p_api_version      IN  NUMBER
                            , p_init_msg_list    IN  VARCHAR2
                            , p_commit           IN  VARCHAR2
                            , p_validation_level IN  NUMBER
                            , x_msg_count        OUT NOCOPY NUMBER
                            , x_msg_data         OUT NOCOPY VARCHAR2
                            , x_return_status    OUT NOCOPY VARCHAR2
                            , p_jtf_note_id      IN  NUMBER );
/* Called after note Insert */

PROCEDURE PRE_UPDATE_NOTES ( x_return_status OUT NOCOPY varchar2);
/* Called before note Update */

PROCEDURE POST_UPDATE_NOTES ( p_api_version      IN  NUMBER
                            , p_init_msg_list    IN  VARCHAR2
                            , p_commit           IN  VARCHAR2
                            , p_validation_level IN  NUMBER
                            , x_msg_count        OUT NOCOPY NUMBER
                            , x_msg_data         OUT NOCOPY VARCHAR2
                            , x_return_status    OUT NOCOPY VARCHAR2
                            , p_jtf_note_id      IN  NUMBER );
/* Called after note Update */

PROCEDURE PRE_DELETE_NOTES ( x_return_status OUT NOCOPY varchar2);
/* Called before note Delete */

PROCEDURE POST_DELETE_NOTES ( x_return_status OUT NOCOPY varchar2);
/* Called after note Delete */

END CSL_JTF_NOTES_ACC_PKG;

 

/
