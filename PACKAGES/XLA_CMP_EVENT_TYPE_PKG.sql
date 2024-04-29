--------------------------------------------------------
--  DDL for Package XLA_CMP_EVENT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_EVENT_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpevt.pkh 120.16.12000000.1 2007/01/16 21:06:56 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_event_type_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate condition expressions from AMB specifcations               |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     25-FEB-2003 K.Boussema    Added 'dbdrv' command                        |
|     10-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code                       |
|     02-APR-2003 K.boussema    Added generation of analytical criteria      |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     05-MAI-2003 K.Boussema    Modified to retrieve data base on ledger_id  |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     6-Mar-2005  W. Shen       Add two parameters to GetEventClassEventType |
|                               Ledger Currency Project                      |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
|     11-Jul-2005 A.Wan         Changed for MPA.  4262811                    |
+===========================================================================*/

g_application_name        VARCHAR2(240);
g_entity_name             VARCHAR2(80);
g_event_class_name        VARCHAR2(80);
g_event_type_name         VARCHAR2(80);


/*-----------------------------------------------------------------------+
|                                                                        |
|  Public function                                                       |
|                                                                        |
|    GenerateEventClassAndType                                           |
|                                                                        |
|  Generates the EventType_xxx() and EventCass_xxx() functions from the  |
|  Event Type Code and Event Class Code assigned to the AAD.             |
|                                                                        |
+-----------------------------------------------------------------------*/

FUNCTION GenerateEventClassAndType   (
  p_application_id               IN NUMBER
, p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_product_rule_version         IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_product_rule_name            IN VARCHAR2
, p_package_name                 IN VARCHAR2
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
;


------------------------------------------------------------------------
-- 4262811 Making public for xla_cmp_acct_line_type_pkg.GenerateMpaBody
------------------------------------------------------------------------
FUNCTION GenerateHdrDescription  (
   p_hdr_description_index    IN BINARY_INTEGER
 , p_rec_aad_objects          IN xla_cmp_source_pkg.t_rec_aad_objects
 , p_rec_sources              IN xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
;
---------------------------------------------------------------------


/*-----------------------------------------------------------------+
|                                                                  |
|  Public function                                                 |
|                                                                  |
|    BuildMainProc                                                 |
|                                                                  |
|  Generates the main procedure CreateHeadersAndLines() in the AAD |
|  packages                                                        |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION BuildMainProc(
  p_application_id               IN NUMBER
, p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_product_rule_name            IN VARCHAR2
, p_product_rule_version         IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_package_name                 IN VARCHAR2
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
;
--
--
END xla_cmp_event_type_pkg; -- end of package spec
 

/
