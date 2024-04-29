--------------------------------------------------------
--  DDL for Package CSL_FND_USER_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_FND_USER_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslusacs.pls 115.2 2002/08/21 07:49:24 rrademak ship $ */

FUNCTION Replicate_Record
  ( p_user_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if user should be replicated. Returns TRUE if it should ***/

PROCEDURE Insert_User
  ( p_user_id     IN NUMBER
   ,p_resource_id IN NUMBER
  );
/***
  Public procedure that gets called when a user needs to be inserted into ACC table.
***/

PROCEDURE Update_User
  ( p_user_id     IN NUMBER
   ,p_resource_id IN NUMBER
  );
/***
  Public procedure that gets called when a user needs to be updated into ACC table.
***/

PROCEDURE Delete_User
  ( p_user_id     IN NUMBER
   ,p_resource_id IN NUMBER
  );
/***
  Public procedure that gets called when a user needs to be deleted from ACC table.
***/

END CSL_FND_USER_ACC_PKG;

 

/
