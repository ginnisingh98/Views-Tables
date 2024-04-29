--------------------------------------------------------
--  DDL for Package XLA_CMP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpext.pkh 120.19 2006/08/25 20:46:56 weshen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_extract_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate extract from AMB specifcations                             |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     19-MAR-2003 K.Boussema    Added amb_context_code                       |
|     05-MAI-2003 K.Boussema    Modified to retrieve data base on ledger_id  |
|     13-MAI-2003 K.Boussema    Modified the Extract according to bug 2857548|
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     26-AUG-2003 K.Boussema    Reviewd the generation of the extract to     |
|                               handle the use of line_number as source      |
|     09-OCT-2003 K.Boussema    Changed to accept AADs differents Extract    |
|                               specifcations                                |
|     22-DEC-2003 K.Boussema    Replaced Extract Validations by a call to    |
|                               Extract Integrity Checker routine            |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     20-Sep-2004 S.Singhania   Made ffdg changes for the bulk performance:  |
|                                 - Added specs for GenerateHdrStructure,    |
|                                   GenerateCacheHdrSources                  |
|                                 - Modified specs for GenerateHdrVariables, |
|                                   GenerateHeaderCursor, GenerateLineCursor |
|     06-Oct-2004 K.Boussema    Made changes for the Accounting Event Extract|
|                               Diagnostics feature.                         |
|     06-Mar-2005 W. Shen       Ledger Currency Project. Remove ALC object   |
+===========================================================================*/
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC FUNCTION                                                          |
--|                                                                          |
--|   Call Extract Integrity Checker to validate the Extract Objects and     |
--|   sources specifications                                                 |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
FUNCTION CallExtractIntegrityChecker  (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
, p_amb_context_code             IN  VARCHAR2
, p_product_rule_type_code       IN  VARCHAR2
, p_product_rule_code            IN  VARCHAR2
--
, p_array_evt_source_index       IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_datatype_code          IN xla_cmp_source_pkg.t_array_VL1
, p_array_translated_flag        IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_evt_source_Level       OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
--
, p_array_object_name            OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_parent_object_index    OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_object_type            OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_object_hash_id         OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         OUT NOCOPY xla_cmp_source_pkg.t_array_VL2000
--
, p_array_h_source_index         OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_source_index     OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_source_index         OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_source_index     OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
)
RETURN BOOLEAN
;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|   Generate the declaration of the sturcture for the line variables       |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLineStructure  (
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
--
)
RETURN VARCHAR2
;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the Declaration of header variables                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateHdrVariables
       (p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num)
RETURN VARCHAR2;

--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|   Generate Fetch on header cursor into header variables                  |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateFetchHeaderCursor  (
  p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the Declaration of line variables                            |
--|                                                                          |
--+==========================================================================+
--
--
FUNCTION GenerateLineVariables(
  p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|   Generate Fetch on Line cursor into header variables                    |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateFetchLineCursor(
  p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;

--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the declaration of the header Cursor : The Extract of        |
--|    standard and MLS header sources from the Header Extract Object        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateHeaderCursor  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
, p_procedure                    IN VARCHAR2)
RETURN VARCHAR2
;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the declaration of the Line Cursor : The Extract of          |
--|    standard BC and MLS line sources from the Header Extract Object       |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLineCursor  (
  p_application_id               IN NUMBER
--
, p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
, p_procedure                    IN VARCHAR2)
RETURN VARCHAR2
;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
FUNCTION GenerateHdrStructure
       (p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt)
RETURN VARCHAR2;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
FUNCTION GenerateCacheHdrSources
       (p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
       ,p_array_datatype_code          IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL1)
RETURN VARCHAR2;
--

--
--===========================================================================
--
--
--
--
--
--
--
--
--
--
--                     Accounting Event Extract Diagnostics
--
--
--
--
--
--
--
--
--
--
--
--============================================================================
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC function                                                          |
--|                                                                          |
--|    Generate the INSERT SQL statement used by the Extract Source Values   |
--|    Dump to insert the header source values into xla_extract_sources      |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateInsertHdrSources  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_type             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
--
, p_procedure                    IN VARCHAR2
)
RETURN CLOB
;

--+==========================================================================+
--|                                                                          |
--| PUBLIC function                                                          |
--|                                                                          |
--|    Generate the INSERT SQL statement used by the Extract Source Values   |
--|    Dump to insert the line source values into xla_extract_sources        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateInsertLineSources  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_type             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
--
,p_procedure                     IN VARCHAR2
)
RETURN CLOB
;


END xla_cmp_extract_pkg; -- end of package spec
 

/
