--------------------------------------------------------
--  DDL for Package ZX_TAXEVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAXEVENT_PUB" AUTHID CURRENT_USER AS
/* $Header: zxifvaldevntpubs.pls 120.1 2005/05/25 15:55:08 vsidhart ship $ */


 /* ==============================================================================*
 | FUNCTION is_event_type_valid : Returns true if event type is mapped in TSRM |
 * ==============================================================================*/
 FUNCTION is_event_type_valid
   (
     p_application_id     IN  NUMBER,
     p_entity_code        IN  VARCHAR2,
     p_event_class_code   IN  VARCHAR2,
     p_event_type_code    IN  VARCHAR2
   )
 RETURN BOOLEAN ;

END zx_taxevent_pub;


 

/
