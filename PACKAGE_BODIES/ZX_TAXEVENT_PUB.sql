--------------------------------------------------------
--  DDL for Package Body ZX_TAXEVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAXEVENT_PUB" AS
/* $Header: zxifvaldevntpubb.pls 120.6 2006/03/01 20:01:49 appradha ship $ */

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
 RETURN BOOLEAN IS
     dummy NUMBER;
 BEGIN
     SELECT 1
     INTO dummy
     FROM zx_evnt_typ_mappings
     WHERE application_id = p_application_id
       AND entity_code = p_entity_code
       AND event_class_code = p_event_class_code
       AND event_type_code = p_event_type_code;

     RETURN TRUE;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN FALSE;

 END is_event_type_valid;
END zx_taxevent_pub;

/
