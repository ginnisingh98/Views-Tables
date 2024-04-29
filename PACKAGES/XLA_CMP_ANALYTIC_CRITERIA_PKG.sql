--------------------------------------------------------
--  DDL for Package XLA_CMP_ANALYTIC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_ANALYTIC_CRITERIA_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpanc.pkh 120.5 2005/07/12 22:25:17 awan ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_analytic_criteria_pkg                                          |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate anlytical criteria from AMB specifcations                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     10-JAN-2003 K.Boussema    Created                                      |
|     14-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     01-APR-2003 K.Boussema    Included amb_context_code                    |
|                               update according to the new datamodel        |
|     22-APR-2003 K.Boussema    Included Error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
|     11-Jul-2005 A.Wan         Changed for MPA bug 4262811                  |
+===========================================================================*/

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Function                                                          |
|                                                                            |
|     GetAnalyticalCriteriaSources                                           |
|                                                                            |
|   Returns the list of sources defined the AMB header analytical criteria.  |
|                                                                            |
+---------------------------------------------------------------------------*/

PROCEDURE GetAnalyticalCriteriaSources (
    p_entity                       IN VARCHAR2
  , p_event_class                  IN VARCHAR2
  , p_event_type                   IN VARCHAR2
  , p_application_id               IN NUMBER
  , p_product_rule_code            IN VARCHAR2
  , p_product_rule_type_code       IN VARCHAR2
  , p_amb_context_code             IN VARCHAR2
  , p_array_evt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
  , p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Function                                                          |
|                                                                            |
|     GenerateHdrAnalyticCriteria                                            |
|                                                                            |
|   Translates the AMB header analytical criteria into PL/SQL code.          |
|                                                                            |
+---------------------------------------------------------------------------*/


FUNCTION GenerateHdrAnalyticCriteria(
  p_application_id               IN NUMBER
, p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_entity                       IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
 , p_rec_sources                 IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;

/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GenerateMpaHeaderAC - 4262811                                          |
|                                                                            |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateMpaHeaderAC(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accrual_jlt_owner_code       IN VARCHAR2
, p_accrual_jlt_code             IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;


/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GenerateMpaLineAC   - 4262811                                          |
|                                                                            |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateMpaLineAC(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accrual_jlt_owner_code       IN VARCHAR2
, p_accrual_jlt_code             IN VARCHAR2
, p_mpa_jlt_owner_code           IN VARCHAR2
, p_mpa_jlt_code                 IN VARCHAR2
, p_array_mpa_jlt_source_index   IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;
/*---------------------------------------------------------------------------+
|                                                                            |
|                                                                            |
|   Public Procedure                                                         |
|                                                                            |
|     GenerateLineAnalyticCriteria                                           |
|                                                                            |
|   Translates the AMB line analytical criteria into PL/SQL code.            |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateLineAnalyticCriteria(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_code         IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;
--
END xla_cmp_analytic_criteria_pkg; -- end of package spec
 

/
