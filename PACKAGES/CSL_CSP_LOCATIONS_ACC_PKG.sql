--------------------------------------------------------
--  DDL for Package CSL_CSP_LOCATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSP_LOCATIONS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslsaacs.pls 115.5 2002/11/08 14:01:39 asiegers ship $ */

FUNCTION Replicate_Record
  ( p_location_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if (shipment) location record should be replicated. Returns TRUE if it should ***/

PROCEDURE PRE_INSERT_SHIP_LOCATION ( x_return_status OUT NOCOPY varchar2);
/* Called before location Insert */

PROCEDURE POST_INSERT_SHIP_LOCATION ( x_return_status OUT NOCOPY varchar2);
/* Called after location Insert */

PROCEDURE PRE_UPDATE_SHIP_LOCATION ( x_return_status OUT NOCOPY varchar2);
/* Called before location Update */

PROCEDURE POST_UPDATE_SHIP_LOCATION ( x_return_status OUT NOCOPY varchar2);
/* Called after location Update */

PROCEDURE PRE_DELETE_SHIP_LOCATION ( x_return_status OUT NOCOPY varchar2);
/* Called before location Delete */

PROCEDURE POST_DELETE_SHIP_LOCATION ( x_return_status OUT NOCOPY varchar2);
/* Called after location Delete */

PROCEDURE Delete_All_ACC_Records ( p_resource_id in NUMBER, x_return_status OUT NOCOPY varchar2);
/* Remove all ACC resords of a mobile user */

PROCEDURE Insert_All_ACC_Records( p_resource_id in NUMBER, x_return_status OUT NOCOPY varchar2);
/* Full synch for a mobile user */

END CSL_CSP_LOCATIONS_ACC_PKG;

 

/
