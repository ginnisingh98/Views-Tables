--------------------------------------------------------
--  DDL for Package CSL_CS_INCIDENTS_ALL_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CS_INCIDENTS_ALL_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslinacs.pls 115.5 2002/11/08 14:02:35 asiegers ship $ */

/*Normal create sr flow*/
G_FLOW_NORMAL    CONSTANT NUMBER := 0;
/*Flow to create history service request*/
G_FLOW_HISTORY   CONSTANT NUMBER := 1;
/*Flow to create sr created on mobile appl*/
G_FLOW_MOBILE_SR CONSTANT NUMBER := 2;


FUNCTION Replicate_Record
  ( p_incident_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if incident record should be replicated. Returns TRUE if it should ***/

FUNCTION Pre_Insert_Child
  ( p_incident_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER DEFAULT G_FLOW_NORMAL
  )
RETURN BOOLEAN;
/***
  Public function that gets called when an incident needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

PROCEDURE Post_Delete_Child
  ( p_incident_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER DEFAULT G_FLOW_NORMAL
  );
/***
  Public procedure that gets called when an incident needs to be deleted from ACC table.
***/

PROCEDURE PRE_INSERT_INCIDENT ( x_return_status OUT NOCOPY varchar2);
/* Called before incident Insert */

PROCEDURE POST_INSERT_INCIDENT ( x_return_status OUT NOCOPY varchar2);
/* Called after incident Insert */

PROCEDURE PRE_UPDATE_INCIDENT ( x_return_status OUT NOCOPY varchar2);
/* Called before incident Update */

PROCEDURE POST_UPDATE_INCIDENT ( x_return_status OUT NOCOPY varchar2);
/* Called after incident Update */

PROCEDURE PRE_DELETE_INCIDENT ( x_return_status OUT NOCOPY varchar2);
/* Called before incident Delete */

PROCEDURE POST_DELETE_INCIDENT ( x_return_status OUT NOCOPY varchar2);
/* Called after incident Delete */

PROCEDURE INSERT_ALL_ACC_RECORDS
  ( p_resource_id   IN  NUMBER
  , x_return_status OUT NOCOPY VARCHAR2 );
/* Called during user creation */

END CSL_CS_INCIDENTS_ALL_ACC_PKG;

 

/
