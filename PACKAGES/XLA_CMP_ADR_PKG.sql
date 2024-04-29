--------------------------------------------------------
--  DDL for Package XLA_CMP_ADR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_ADR_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpadr.pkh 120.12 2005/03/29 14:35:09 kboussem ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_adr_pkg                                                        |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate ADR procedures from AMB specifcations                      |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     25-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     17-APR-2003 K.Boussema    Included error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     01-JUN-2004 A.Quaglia     Added build_adrs_for_tab.                    |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
+===========================================================================*/

--Public record types
   --This is for mapping the source name to parameter names
   TYPE gt_table_of_adr_sources IS TABLE OF VARCHAR2(30)
                                INDEX BY BINARY_INTEGER;

   --public procedures in this package may receive a list of ADRs to compile
   TYPE gt_rec_adr_in IS RECORD
   (
      application_id             NUMBER
     ,segment_rule_type_code     VARCHAR2(1)
     ,segment_rule_code          VARCHAR2(30)
     ,amb_context_code           VARCHAR2(30)
   );
   TYPE gt_table_of_adrs_in     IS TABLE OF gt_rec_adr_in
                                INDEX BY BINARY_INTEGER;

   --public procedures in this package might need to return additional
   --information about the compiled ADRs
   TYPE gt_rec_adr_out IS RECORD
   (
      adr_function_name          VARCHAR2(30)
     ,adr_hash_id                NUMBER
     ,table_of_sources           gt_table_of_adr_sources
   );
   TYPE gt_table_of_adrs_out    IS TABLE OF gt_rec_adr_out
                                INDEX BY BINARY_INTEGER;


/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateADR                                           |
|                                                             |
|  Generates the ADR functions AcctDerRule_XXX()from the AMB  |
|  Account Derivation Rules assigned to the AAD.              |
|  It returns TRUE if all the ADR are generated successfully, |
|  FALSE otherwise                                            |
|                                                             |
+------------------------------------------------------------*/

FUNCTION GenerateADR(
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


/*------------------------------------------------------------+
|                                                             |
|  Public TAB Function                                        |
|                                                             |
|       build_adrs_for_tab                                    |
|                                                             |
|                                                             |
+------------------------------------------------------------*/

FUNCTION build_adrs_for_tab
   (
     p_table_of_adrs_in     IN           gt_table_of_adrs_in
    ,x_table_of_adrs_out    OUT   NOCOPY gt_table_of_adrs_out
    ,x_adr_specs_text       OUT   NOCOPY CLOB
    ,x_adr_bodies_text      OUT   NOCOPY CLOB
  )
RETURN BOOLEAN
;


END xla_cmp_adr_pkg; -- end of package spec
 

/
