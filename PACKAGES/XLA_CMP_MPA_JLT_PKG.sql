--------------------------------------------------------
--  DDL for Package XLA_CMP_MPA_JLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_MPA_JLT_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpmlt.pkh 120.0.12000000.1 2007/01/16 21:07:13 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_mpa_jlt_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate Recognition Accounting line type procedures from AMB       |
|     specifications.                                                        |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|      4-MAY-2005 A.Wan       Created for MPA 4262811                        |
+===========================================================================*/


/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateMpaJLT                                        |
|                                                             |
|  Generates the RecognitionJLT_xx() functions from the AMB   |
|  Recognition Journal line types assigned to the AAD.        |
|  It returns TRUE if generation succeeds, FALSE otherwise    |
|                                                             |
+------------------------------------------------------------*/

FUNCTION GenerateMpaJLT(
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



END xla_cmp_mpa_jlt_pkg; -- end of package spec
 

/
