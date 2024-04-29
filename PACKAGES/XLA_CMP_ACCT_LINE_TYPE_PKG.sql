--------------------------------------------------------
--  DDL for Package XLA_CMP_ACCT_LINE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_ACCT_LINE_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpalt.pkh 120.14.12000000.1 2007/01/16 21:06:22 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_acct_line_type_pkg                                             |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate Accounting line type procedures from AMB specifcations     |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     15-JUN-2002 K.Boussema  Created                                        |
|     18-FEB-2003 K.Boussema  Added 'dbdrv' command                          |
|     21-FEB-2003 K.Boussela  Changed GenerateAcctLineType function          |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
|     11-Jul-2005 A.Wan         Changed for MPA.  4262811                    |
|     31-Jan-2006 A.Wan         4655713 - inherit ADR for same entry         |
+===========================================================================*/

/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GetALTOption                                          |
|                                                             |
|  Bug 4262811 - existing function.  Make it public.          |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GetALTOption   (
  p_acct_entry_type_code         IN VARCHAR2
, p_gain_or_loss_flag            IN VARCHAR2
, p_natural_side_code            IN VARCHAR2
, p_transfer_mode_code           IN VARCHAR2
, p_switch_side_flag             IN VARCHAR2
, p_merge_duplicate_code         IN VARCHAR2
)
RETURN VARCHAR2
;

/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GetAcctClassCode                                      |
|                                                             |
|  Bug 4262811 - existing function.  Make it public.          |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GetAcctClassCode   (
  p_accounting_class_code        IN VARCHAR2
)
RETURN VARCHAR2
;

/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GetRoundingClassCode                                  |
|                                                             |
|  Bug 4262811 - existing function.  Make it public.          |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GetRoundingClassCode   (
  p_rounding_class_code        IN VARCHAR2
)
RETURN VARCHAR2
;

/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateCallDescription                               |
|                                                             |
|  Bug 4262811 - existing function.  Make it public.          |
|                                                             |
+------------------------------------------------------------*/
FUNCTION GenerateCallDescription  (
  p_application_id               IN NUMBER
, p_description_type_code        IN VARCHAR2
, p_description_code             IN VARCHAR2
, p_header_line                  IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;

/*---------------------------------------------------------+
|                                                          |
|  Public  Function                                        |
|                                                          |
|  GenerateADRCalls - 4262811                              |
|                                                          |
|                                                          |
+----------------------------------------------------------*/

FUNCTION GenerateADRCalls  (
  p_application_id               IN NUMBER
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_array_adr_type_code          IN xla_cmp_source_pkg.t_array_VL1
, p_array_adr_code               IN xla_cmp_source_pkg.t_array_VL30
, p_array_adr_segment_code       IN xla_cmp_source_pkg.t_array_VL30
, p_array_side_code              IN xla_cmp_source_pkg.t_array_VL30
, p_array_adr_appl_id            IN xla_cmp_source_pkg.t_array_NUM
, p_array_inherit_adr_flag       IN xla_cmp_source_pkg.t_array_VL1
, p_bflow_method_code            IN VARCHAR2  -- 4655713
, p_array_accounting_coa_id      IN xla_cmp_source_pkg.t_array_NUM
, p_array_transaction_coa_id     IN xla_cmp_source_pkg.t_array_NUM
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN            xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN  CLOB
;

/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateAcctLineType                                  |
|                                                             |
|  Generates the AcctLineType_XXX() functions from the AMB    |
|  Journal line types assigned to the AAD.                    |
|  It returns TRUE if generation succeeds, FALSE otherwise    |
|                                                             |
+------------------------------------------------------------*/

FUNCTION GenerateAcctLineType(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_package_name                 IN VARCHAR2
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
;



END xla_cmp_acct_line_type_pkg; -- end of package spec
 

/
