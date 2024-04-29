--------------------------------------------------------
--  DDL for Package XLA_EVENT_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENT_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamess.pkh 120.5 2004/06/04 18:24:42 weshen ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_sources_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Sources Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    20-May-04 W. Shen        add function event_source_details_exist   |
|                             remove the other 2 procedures:            |
|                             insert_accounting_source                  |
|                             and delete_accounting_source              |
|                                                                       |
+======================================================================*/

/*======================================================================+
   p_event: UPDATE or DELETE. If it is UPDATE, which means the form is
            calling this function for updating, no out parameter need
            to be populated since the field will be disabled. If the
            function is called in DELETE mode, then the out parameters
            are needed for the error messege
   p_assignment_level: whether the source is assigned at CLASS level or
            JLT level or AAD level. error message will be different
            for different level
   p_name: the name of the AAD(if the p_assignment_level is AAD) or JLT
            (if the p_assignment_level is JLT), used in the error msg
   p_type: the type of the AAD(if the p_assignment_level is AAD) or JLT
            (if the p_assignment_level is JLT), used in the error msg
+======================================================================*/

FUNCTION event_source_details_exist
(p_application_id                   IN NUMBER
  ,p_entity_code                    IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_source_application_id            IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_event                            IN VARCHAR2
  ,p_assignment_level                 OUT NOCOPY VARCHAR2
  ,p_name                             OUT NOCOPY VARCHAR2
  ,p_type                             OUT NOCOPY VARCHAR2)
 RETURN boolean;

END xla_event_sources_pkg;
 

/
