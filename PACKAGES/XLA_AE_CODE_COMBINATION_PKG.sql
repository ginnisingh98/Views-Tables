--------------------------------------------------------
--  DDL for Package XLA_AE_CODE_COMBINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AE_CODE_COMBINATION_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajecci.pkh 120.11.12010000.2 2010/03/24 08:05:50 karamakr ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_code_combination_pkg                                            |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUL-2002 K.Boussema    Created                                      |
|     17-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     26-NOV-2003 K.Boussema    Added the cache of GL mapping information    |
|     28-NOV-2003 K.Boussema    Added cache_coa and refreshCcidCache procs   |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     25-MAR-2004 K.Boussema    Added the parameter cacheGLMapping to the    |
|                               cacheGLMapping procedure                     |
|     14-Mar-2005 K.Boussema Changed for ADR-enhancements.                   |
+===========================================================================*/



/*---------------------------------------------------------+
|                                                          |
| Public procedure                                         |
|                                                          |
|   cache_coa                                              |
|                                                          |
| caches the accounting flexfield structures, involved in  |
| the accounting process                                   |
+---------------------------------------------------------*/
g_error_exists   BOOLEAN;

PROCEDURE get_ccid_errors;

PROCEDURE cache_coa(
            p_coa_id                IN NUMBER
)
;

/*---------------------------------------------------------+
|                                                          |
| Public procedure                                         |
|                                                          |
|   cache_coa                                              |
|                                                          |
| caches the accounting flexfield structures, involved in  |
| the accounting process. It caches only the accounting    |
| chart of accounts                                        |
+---------------------------------------------------------*/

PROCEDURE cache_coa(
             p_coa_id                IN NUMBER
            ,p_target_coa            IN VARCHAR2
)
;

/*---------------------------------------------------------+
|                                                          |
| Public procedure                                         |
|                                                          |
|   cacheGLMapping                                         |
|                                                          |
| caches the GL chart of acounts mappings, i,volved in the |
| accounting process.                                      |
|                                                          |
+---------------------------------------------------------*/

PROCEDURE cacheGLMapping(
                         p_sla_coa_mapping_name IN VARCHAR2
                       , p_sla_coa_mapping_id   IN NUMBER
                       , p_dynamic_inserts_flag IN VARCHAR2
                        )
;




/*-------------------------------------------------------------+
|                                                              |
| Public function                                              |
|                                                              |
|     get_flex_segment_value                                   |
|                                                              |
|  retrieves the segment value from key flexfield combination  |
|                                                              |
+-------------------------------------------------------------*/
-- replaces get_flexfield_segment()
FUNCTION get_flex_segment_value(
           p_combination_id         IN NUMBER
          ,p_segment_code           IN VARCHAR2
          ,p_id_flex_code           IN VARCHAR2
          ,p_flex_application_id    IN NUMBER
          ,p_application_short_name IN VARCHAR2
          ,p_source_code            IN VARCHAR2 DEFAULT NULL
          ,p_source_type_code       IN VARCHAR2 DEFAULT NULL
          ,p_source_application_id  IN NUMBER   DEFAULT NULL
          ,p_component_type         IN VARCHAR2
          ,p_component_code         IN VARCHAR2
          ,p_component_type_code    IN VARCHAR2
          ,p_component_appl_id      IN INTEGER
          ,p_amb_context_code       IN VARCHAR2
          ,p_entity_code            IN VARCHAR2 DEFAULT NULL
          ,p_event_class_code       IN VARCHAR2 DEFAULT NULL
          ,p_ae_header_id           IN NUMBER   DEFAULT NULL
)
RETURN VARCHAR2
;

/*-------------------------------------------------------------+
|                                                              |
| Public function                                              |
|                                                              |
|     get_flex_segment_desc                                    |
|                                                              |
|  retrieves the segment description for a given segment code  |
|                                                              |
+--------------------------------------------------------------*/

--replaces FUNCTION get_flexfield_description()
FUNCTION get_flex_segment_desc(
           p_combination_id         IN NUMBER
          ,p_segment_code           IN VARCHAR2
          ,p_id_flex_code           IN VARCHAR2
          ,p_flex_application_id    IN NUMBER
          ,p_application_short_name IN VARCHAR2
          ,p_source_code            IN VARCHAR2
          ,p_source_type_code       IN VARCHAR2
          ,p_source_application_id  IN NUMBER
          ,p_component_type         IN VARCHAR2
          ,p_component_code         IN VARCHAR2
          ,p_component_type_code    IN VARCHAR2
          ,p_component_appl_id      IN INTEGER
          ,p_amb_context_code       IN VARCHAR2
          ,p_ae_header_id           IN NUMBER
)
RETURN VARCHAR2
;

/*-----------------------------------------------------+
|                                                      |
| Public function                                      |
|                                                      |
|     get_segment_code                                 |
|                                                      |
|  Returns the segment code for a given key flexfield  |
|  attribute.                                          |
|                                                      |
+-----------------------------------------------------*/
-- replaces FUNCTION get_segment_qualifier()
FUNCTION get_segment_code(
   p_flex_application_id    IN NUMBER
 , p_application_short_name IN VARCHAR2
 , p_id_flex_code           IN VARCHAR2
 , p_id_flex_num            IN NUMBER
 , p_segment_qualifier      IN VARCHAR2
 , p_component_type         IN VARCHAR2
 , p_component_code         IN VARCHAR2
 , p_component_type_code    IN VARCHAR2
 , p_component_appl_id      IN INTEGER
 , p_amb_context_code       IN VARCHAR2
 , p_entity_code            IN VARCHAR2
 , p_event_class_code       IN VARCHAR2
)
RETURN VARCHAR2
;


/*---------------------------------------------------------------+
|                                                                |
|  Public procedure                                              |
|                                                                |
|    refreshCCID                                                 |
|                                                                |
| refresh key flexfield combination cache                        |
|                                                                |
+---------------------------------------------------------------*/

PROCEDURE refreshCCID
;

/*---------------------------------------------------------------+
|                                                                |
|  Public procedure                                              |
|                                                                |
|      refreshCcidCache                                          |
|                                                                |
| refresh the accounts cache                                     |
|                                                                |
+---------------------------------------------------------------*/

PROCEDURE refreshCcidCache
;

/*-------------------------------------------------------------+
|                                                              |
| Public function                                              |
|                                                              |
|     GetCcid                                                  |
|                                                              |
| Call AOL routine to create the new ccid, when the ccid does  |
| not exist in the gl_code_combinations table. It calls the    |
| AOL API FND_FLEX_EXT.get_combination_id.                     |
|                                                              |
+-------------------------------------------------------------*/

FUNCTION GetCcid(
        p_segment1              IN VARCHAR2
      , p_segment2              IN VARCHAR2
      , p_segment3              IN VARCHAR2
      , p_segment4              IN VARCHAR2
      , p_segment5              IN VARCHAR2
      , p_segment6              IN VARCHAR2
      , p_segment7              IN VARCHAR2
      , p_segment8              IN VARCHAR2
      , p_segment9              IN VARCHAR2
      , p_segment10             IN VARCHAR2
      , p_segment11             IN VARCHAR2
      , p_segment12             IN VARCHAR2
      , p_segment13             IN VARCHAR2
      , p_segment14             IN VARCHAR2
      , p_segment15             IN VARCHAR2
      , p_segment16             IN VARCHAR2
      , p_segment17             IN VARCHAR2
      , p_segment18             IN VARCHAR2
      , p_segment19             IN VARCHAR2
      , p_segment20             IN VARCHAR2
      , p_segment21             IN VARCHAR2
      , p_segment22             IN VARCHAR2
      , p_segment23             IN VARCHAR2
      , p_segment24             IN VARCHAR2
      , p_segment25             IN VARCHAR2
      , p_segment26             IN VARCHAR2
      , p_segment27             IN VARCHAR2
      , p_segment28             IN VARCHAR2
      , p_segment29             IN VARCHAR2
      , p_segment30             IN VARCHAR2
      , p_chart_of_accounts_id  IN NUMBER
  )
RETURN NUMBER
;


/*-----------------------------------------------------------------------+
|                                                                        |
| Public function                                                        |
|                                                                        |
|         BuildCcids                                                     |
|                                                                        |
| builds the new accounting ccids. It returns the number of rows updated |
|                                                                        |
+-----------------------------------------------------------------------*/
FUNCTION BuildCcids
RETURN NUMBER
;


END xla_ae_code_combination_pkg; -- end of package spec

/
