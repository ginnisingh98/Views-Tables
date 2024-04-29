--------------------------------------------------------
--  DDL for Package XLA_CMP_DESCRIPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_DESCRIPTION_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpdes.pkh 120.11 2005/03/29 14:32:48 kboussem ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_description_pkg                                                |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate description procedures from AMB specifcations              |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     25-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     22-APR-2003 K.Boussema    Included Error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
+===========================================================================*/

/*---------------------------------------------------------------------------+
| Public function                                                            |
|                                                                            |
|       GenerateDescriptions                                                 |
|                                                                            |
| Translates the AMB descriptions assigned to an AAD into PL/SQL functions   |
| Description_XXX(). It returns True if the generation succeeds, False       |
| otherwise.                                                                 |
|                                                                            |
+---------------------------------------------------------------------------*/

FUNCTION GenerateDescriptions(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_package_name                 IN VARCHAR2
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
;

END xla_cmp_description_pkg; -- end of package spec
 

/
