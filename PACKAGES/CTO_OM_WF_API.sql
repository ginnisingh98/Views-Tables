--------------------------------------------------------
--  DDL for Package CTO_OM_WF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_OM_WF_API" AUTHID CURRENT_USER as
/* $Header: CTOOMWFS.pls 115.1 2003/10/31 18:47:01 ssawant noship $ */


/**************************************************************************

   Procedure:   Reservation_Exists
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API is associated with the Reservation_Exists validation Template.

*****************************************************************************/


PROCEDURE Reservation_Exists(
        p_application_id        IN      NUMBER,
        p_entity_short_name     IN      VARCHAR2,
        p_validation_entity_short_name  IN      VARCHAR2,
        p_validation_tmplt_short_name   IN      VARCHAR2,
        p_record_set_short_name IN VARCHAR2,
        p_scope                 IN VARCHAR2,
        x_result                OUT NOCOPY NUMBER
        );




end CTO_OM_WF_API ;

 

/
