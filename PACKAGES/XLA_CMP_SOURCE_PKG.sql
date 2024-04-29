--------------------------------------------------------
--  DDL for Package XLA_CMP_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_SOURCE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpscs.pkh 120.16.12010000.2 2010/01/31 14:51:47 vkasina ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_source_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to cache the sources and entities/objects defined in the AMB           |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     13-JAN-2003 K.Boussema    Added the structure t_array_VL240            |
|     14-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     02-JUN-2004 A.Quaglia     Added get_obj_parm_for_tab                   |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
|     11-Jul-2005 A.Wan         Changed for MPA.  4262811                    |
+===========================================================================*/
--
--+==========================================================================+
--|                                                                          |
--| Global constants: AMB object type                                        |
--|                                                                          |
--+==========================================================================+

C_DESC                             CONSTANT    VARCHAR2(1)  :='D';  -- description
C_ADR                              CONSTANT    VARCHAR2(1)  :='A';  -- account derivation rule
C_ANC                              CONSTANT    VARCHAR2(1)  :='R';  -- analytical criteria
C_ALT                              CONSTANT    VARCHAR2(1)  :='L';  -- journal entry line
C_EVT                              CONSTANT    VARCHAR2(1)  :='E';  -- event type
C_CLASS                            CONSTANT    VARCHAR2(1)  :='C';  -- event class

C_RECOG_JLT                        CONSTANT    VARCHAR2(1)  :='G';  -- 4262811 recongnition JLT
--
--+==========================================================================+
--|                                                                          |
--| Public structures/types                                                  |
--|                                                                          |
--+==========================================================================+
--
--
TYPE t_array_VL1          IS TABLE OF VARCHAR2(1)       INDEX BY BINARY_INTEGER;
TYPE t_array_VL30         IS TABLE OF VARCHAR2(30)      INDEX BY BINARY_INTEGER;
TYPE t_array_VL50         IS TABLE OF VARCHAR2(50)      INDEX BY BINARY_INTEGER;
TYPE t_array_VL80         IS TABLE OF VARCHAR2(160)      INDEX BY BINARY_INTEGER;
TYPE t_array_VL240        IS TABLE OF VARCHAR2(240)     INDEX BY BINARY_INTEGER;
TYPE t_array_VL2000       IS TABLE OF VARCHAR2(2000)    INDEX BY BINARY_INTEGER;
TYPE t_array_Num          IS TABLE OF NUMBER            INDEX BY BINARY_INTEGER;
TYPE t_array_Int          IS TABLE OF INTEGER           INDEX BY BINARY_INTEGER;
TYPE t_array_Date         IS TABLE OF DATE              INDEX BY BINARY_INTEGER;

TYPE t_array_ByInt        IS TABLE OF BINARY_INTEGER    INDEX BY BINARY_INTEGER;
TYPE t_array_array_ByInt  IS TABLE OF t_array_ByInt     INDEX BY BINARY_INTEGER;
TYPE t_array_array_VL1    IS TABLE OF t_array_VL1       INDEX BY BINARY_INTEGER;
--
-- structure of source cache
--
TYPE t_rec_sources IS RECORD (
 array_application_id              t_array_Num ,
 array_source_code                 t_array_VL30,
 array_source_type_code            t_array_VL1 ,
 array_source_name                 t_array_VL80,
 array_datatype_code               t_array_VL1 ,
 array_plsql_function              t_array_VL80,
 array_flex_value_set_id           t_array_Num ,
 array_translated_flag             t_array_VL1 ,
 array_lookup_type                 t_array_VL30,
 array_view_application_id         t_array_Num ,
 array_key_flexfield_flag          t_array_VL1 ,
 array_flexfield_appl_id           t_array_Num ,
 array_appl_short_name             t_array_VL80,
 array_id_flex_code                t_array_VL30,
 array_segment_code                t_array_VL30
);
--
-- structure of AMB object cache
--
TYPE t_rec_aad_objects IS RECORD (
  array_object                     t_array_VL1,
  array_object_code                t_array_VL30,
  array_object_type_code           t_array_VL1,
  array_object_appl_id             t_array_Num,
  array_object_class               t_array_VL30,
  array_object_event               t_array_VL30,
  array_object_jld_code            t_array_VL30,
  array_object_jld_type_code       t_array_VL1,
  array_array_object               t_array_array_ByInt
);

/*----------------------------------------------------------+
| Public function                                           |
|                                                           |
|   GenerateSource                                          |
|                                                           |
|  It drives the generation of the sources in the AAD       |
|  packages.                                                |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GenerateSource(
       p_Index                        IN BINARY_INTEGER
     , p_rec_sources                  IN OUT NOCOPY t_rec_sources
     , p_variable                     IN VARCHAR2 DEFAULT NULL
     , p_translated_flag              IN VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2
;


/*----------------------------------------------------------+
| Public function                                           |
|                                                           |
|   GenerateParameters                                      |
|                                                           |
|  It generates the AAD procedures/functions parameters:    |
|  p_sourc_1 IN VARCHAR2, p_source_2 IN NUMBER, .....       |
|                                                           |
+----------------------------------------------------------*/

FUNCTION GenerateParameters   (
    p_array_source_index  IN t_array_ByInt
  , p_rec_sources         IN t_rec_sources
 )
RETURN VARCHAR2
;

-----------------------------------------------
--  Added for the Transaction Account Builder
-----------------------------------------------
FUNCTION get_obj_parm_for_tab   (
   p_array_source_index           IN t_array_ByInt
 , p_rec_sources                  IN t_rec_sources
 )
RETURN VARCHAR2
;

--
/*----------------------------------------------------------------------------+
|                                                                             |
|                        AMB source Dico/cache                                |
|                                                                             |
+-----------------------------------------------------------------------------*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| CacheSource                                                           |
|                                                                       |
|    It caches the source in the global source cache p_rec_sources.     |
|    It returns the position/index of the source in the cache           |
|                                                                       |
+======================================================================*/

FUNCTION CacheSource (
    p_source_code                  IN VARCHAR2
  , p_source_type_code             IN VARCHAR2
  , p_source_application_id        IN NUMBER
  , p_rec_sources                  IN OUT NOCOPY t_rec_sources
  )
RETURN BINARY_INTEGER
;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| StackSource                                                           |
|                                                                       |
|    It caches the source in the list of sources defined in the AMB     |
|    object. It stack up the source in the p_array_source_index.        |
|    It returns the position/index of the source in the cache           |
|                                                                       |
+======================================================================*/

FUNCTION StackSource(
    p_source_code                  IN VARCHAR2
  , p_source_type_code             IN VARCHAR2
  , p_source_application_id        IN NUMBER
  , p_array_source_index           IN OUT NOCOPY t_array_ByInt
  , p_rec_sources                  IN OUT NOCOPY t_rec_sources
  )
RETURN BINARY_INTEGER
;

--
/*----------------------------------------------------------------------------+
|                                                                             |
|                    AMB Object/Entity Dico/cache                             |
|                                                                             |
+-----------------------------------------------------------------------------*/
--

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| CacheAADObject                                                        |
|                                                                       |
|  It caches the AMB object in the global source cache p_rec_aad_objects|
|  It returns the position/index of the AMB object in the cache         |
|                                                                       |
+======================================================================*/
FUNCTION CacheAADObject (
    p_object                       IN VARCHAR2
  , p_object_code                  IN VARCHAR2
  , p_object_type_code             IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_event_class_code             IN VARCHAR2        DEFAULT NULL
  , p_event_type_code              IN VARCHAR2        DEFAULT NULL
  , p_line_definition_code         IN VARCHAR2        DEFAULT NULL
  , p_line_definition_owner_code   IN VARCHAR2        DEFAULT NULL
  , p_array_source_index           IN t_array_ByInt
  , p_rec_aad_objects              IN OUT NOCOPY t_rec_aad_objects
)
RETURN BINARY_INTEGER
;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| GetAADObjectPosition                                                  |
|                                                                       |
|  It returns the position/index of the AMB object in the cache         |
|                                                                       |
+======================================================================*/

FUNCTION GetAADObjectPosition (
    p_object                       IN VARCHAR2
  , p_object_code                  IN VARCHAR2
  , p_object_type_code             IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_event_class_code             IN VARCHAR2        DEFAULT NULL
  , p_event_type_code              IN VARCHAR2        DEFAULT NULL
  , p_line_definition_code         IN VARCHAR2        DEFAULT NULL
  , p_line_definition_owner_code   IN VARCHAR2        DEFAULT NULL
  , p_rec_aad_objects              IN t_rec_aad_objects
)
RETURN BINARY_INTEGER
;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| GetAADObjectPosition                                                  |
|                                                                       |
|  It returns the list of sources defined in  the AMB object.           |
|  It retrieves the list from the objects cache p_rec_aad_objects       |
|                                                                       |
+======================================================================*/

PROCEDURE GetSourcesInAADObject (
  p_object                       IN VARCHAR2
, p_object_code                  IN VARCHAR2
, p_object_type_code             IN VARCHAR2
, p_application_id               IN NUMBER
, p_event_class_code             IN VARCHAR2        DEFAULT NULL
, p_event_type_code              IN VARCHAR2        DEFAULT NULL
, p_line_definition_code         IN VARCHAR2        DEFAULT NULL
, p_line_definition_owner_code   IN VARCHAR2        DEFAULT NULL
, p_array_source_Index           IN OUT NOCOPY t_array_ByInt
, p_rec_aad_objects              IN t_rec_aad_objects
)
;
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|    Generate GetMeaning API for the source associated to value set        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|   flex_values_exist                                                   |
|                                                                       |
| Returns true if source associated to flex value set exist             |
|                                                                       |
+======================================================================*/
FUNCTION  flex_values_exist
  (p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num)
RETURN BOOLEAN
;
--+==========================================================================+
--|                                                                          |
--| Public Function                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateGetMeaningAPI(
  p_package_name                 IN VARCHAR2
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
;
--
END xla_cmp_source_pkg; -- end of package spec

/
