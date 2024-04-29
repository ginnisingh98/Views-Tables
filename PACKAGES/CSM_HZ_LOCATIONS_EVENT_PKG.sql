--------------------------------------------------------
--  DDL for Package CSM_HZ_LOCATIONS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_HZ_LOCATIONS_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmehzls.pls 120.1 2005/11/16 11:36 trajasek noship $ */
-- Purpose: TO Download locations for SR on Locations


/*** Globals ***/
PROCEDURE INSERT_LOCATION( p_location_id IN NUMBER, p_user_id IN NUMBER );

PROCEDURE DELETE_LOCATION( p_location_id IN NUMBER, p_user_id IN NUMBER );

END CSM_HZ_LOCATIONS_EVENT_PKG;


 

/
