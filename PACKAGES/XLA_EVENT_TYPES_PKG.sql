--------------------------------------------------------
--  DDL for Package XLA_EVENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENT_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdet.pkh 120.4 2005/06/23 20:14:28 ksvenkat ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_types_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Types Package                                            |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| type_details_exist                                                    |
|                                                                       |
| Returns true if details of the event type exist                       |
|                                                                       |
+======================================================================*/
FUNCTION type_details_exist
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_accounting_flag                  IN VARCHAR2
  ,p_tax_flag                         IN VARCHAR2
  ,p_message                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_event_types_pkg;
 

/
