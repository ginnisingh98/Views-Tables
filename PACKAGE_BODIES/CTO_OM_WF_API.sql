--------------------------------------------------------
--  DDL for Package Body CTO_OM_WF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_OM_WF_API" as
/* $Header: CTOOMWFB.pls 115.2 2003/11/06 02:40:49 ssawant noship $ */


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
        )
is
BEGIN

  oe_debug_pub.add( 'CTO_OM_WF_API.reservation_exists: ' || ' going to call cto_workflow_api_pk.reservation_exists ' , 1 ) ;
  x_result := 0 ;

  CTO_WORKFLOW_API_PK.reservation_exists( p_application_id => p_application_id
                                        , p_entity_short_name => p_entity_short_name
                                        , p_validation_entity_short_name => p_validation_entity_short_name
                                        , p_validation_tmplt_short_name => p_validation_tmplt_short_name
                                        , p_record_set_short_name => p_record_set_short_name
                                        , p_scope => p_scope
                                        , x_result => x_result ) ;



  oe_debug_pub.add( 'CTO_OM_WF_API.reservation_exists: ' || ' result returned is ' || x_result , 1 ) ;

END ;



end CTO_OM_WF_API ;

/
