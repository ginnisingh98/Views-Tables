--------------------------------------------------------
--  DDL for Package CSL_HZ_LOCATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_HZ_LOCATIONS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslhlacs.pls 115.3 2003/07/23 23:53:17 yliao ship $ */

PROCEDURE INSERT_LOCATION( p_location_id IN NUMBER
                         , p_resource_id IN NUMBER );

PROCEDURE UPDATE_LOCATION( p_location_id IN NUMBER );

PROCEDURE DELETE_LOCATION( p_location_id IN NUMBER
                         , p_resource_id IN NUMBER );

PROCEDURE CHANGE_LOCATION( p_old_location_id IN NUMBER
                         , p_new_location_id IN NUMBER
		         , p_resource_id IN NUMBER );

FUNCTION UPDATE_LOCATION_WFSUB( p_subscription_guid   in     raw
               , p_event               in out NOCOPY wf_event_t)
return varchar2;

END CSL_HZ_LOCATIONS_ACC_PKG;

 

/
