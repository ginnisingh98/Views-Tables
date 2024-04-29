--------------------------------------------------------
--  DDL for Package XLA_AE_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AE_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajescs.pkh 120.7 2004/02/27 16:13:39 kboussem ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_sources_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     26-JUN-2003 K.Boussema    Included Error messages                      |
|     17-JUL-2003 K.Boussema    Updated the call to accounting cache, 3055039|
|     15-DEC-2003 K.Boussema    Removed get_flex_value_meaning function      |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
+===========================================================================*/
--
/*======================================================================+
|                                                                       |
|   cache defined for Value set sources                                 |
|                                                                       |
+======================================================================*/


--
-- Flex value meaning cache
--
TYPE t_rec_meaning IS RECORD (
  array_flex_value               xla_ae_journal_entry_pkg.t_array_V4000L
, array_meaning                  xla_ae_journal_entry_pkg.t_array_V4000L
)
;
--
TYPE t_array_meaning IS TABLE OF t_rec_meaning INDEX BY BINARY_INTEGER
;
--
g_array_meaning                    t_array_meaning;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    GetSystemSourceNum                                                 |
|                                                                       |
+======================================================================*/
FUNCTION GetSystemSourceNum(
  p_source_code         IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
)
RETURN NUMBER;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION GetSystemSourceDate(
  p_source_code         IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
)
RETURN DATE;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    GetSystemSourceChar                                                |
|                                                                       |
+======================================================================*/

FUNCTION GetSystemSourceChar(
   p_source_code      IN VARCHAR2
 , p_source_type_code      IN VARCHAR2
 , p_source_application_id IN NUMBER
 )
RETURN VARCHAR2;
--
--
--

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|      GetLookupMeaning                                                 |
|                                                                       |
+======================================================================*/
FUNCTION GetLookupMeaning(
  p_lookup_code            IN VARCHAR2
, p_lookup_type            IN VARCHAR2
, p_view_application_id    IN NUMBER
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN INTEGER
)
RETURN VARCHAR2
;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_mapping_flexfield_number (
   p_component_type      IN VARCHAR2
 , p_component_code      IN VARCHAR2
 , p_component_type_code IN VARCHAR2
 , p_component_appl_id   IN INTEGER
 , p_amb_context_code    IN VARCHAR2
 , p_mapping_set_code    IN VARCHAR2
 , p_input_constant      IN VARCHAR2
 , p_ae_header_id        IN NUMBER   DEFAULT NULL
 )
 RETURN NUMBER;
--
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION get_mapping_flexfield_char (
   p_component_type      IN VARCHAR2
 , p_component_code      IN VARCHAR2
 , p_component_type_code IN VARCHAR2
 , p_component_appl_id   IN INTEGER
 , p_amb_context_code    IN VARCHAR2
 , p_mapping_set_code    IN VARCHAR2
 , p_input_constant      IN VARCHAR2
 , p_ae_header_id        IN NUMBER   DEFAULT NULL
 )
 RETURN VARCHAR2;

--
--

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|      Convert date into varchar according to the description language  |
|                                                                       |
+======================================================================*/
FUNCTION DATE_TO_CHAR (
   p_date               IN DATE
  ,p_nls_desc_language  IN VARCHAR2
 )
 RETURN VARCHAR2;
--
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC   function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetApplicationName (p_application_id   IN NUMBER)
RETURN VARCHAR2
;

--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    GetSourceName                                                      |
|                                                                       |
+======================================================================*/
FUNCTION GetSourceName(
  p_source_code           IN VARCHAR2
, p_source_type_code      IN VARCHAR2
, p_source_application_id IN NUMBER
)
RETURN VARCHAR2
;
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC  function                                                         |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetAccountingSourceName (p_accounting_source_code   IN VARCHAR2)
RETURN VARCHAR2
;
--
--+==========================================================================+
--|                                                                          |
--| Public  function                                                        |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetComponentName (
  p_component_type        IN VARCHAR2
, p_component_code        IN VARCHAR2
, p_component_type_code   IN VARCHAR2
, p_component_appl_id     IN INTEGER
, p_amb_context_code      IN VARCHAR2
, p_entity_code           IN VARCHAR2 DEFAULT NULL
, p_event_class_code      IN VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
;

END xla_ae_sources_pkg; -- end of package spec
 

/
