--------------------------------------------------------
--  DDL for Package XLA_CMP_CONDITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_CONDITION_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpcod.pkh 120.8.12000000.1 2007/01/16 21:06:40 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_condition_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate condition expressions from AMB specifcations               |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     15-JUN-2002 K.Boussema  Created                                        |
|     18-FEB-2003 K.Boussema  Added 'dbdrv' command                          |
|     21-FEB-2003 K.Boussela  Changed GetCondition function                  |
|     19-MAR-2003 K.Boussema  Added amb_context_code column                  |
|     22-APR-2003 K.Boussema    Included Error messages                      |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     07-Mar-2005 K.Boussema    Changed for ADR-enhancements.                |
+===========================================================================*/
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC  function                                                         |
--|                                                                          |
--+==========================================================================+
--
--
--
FUNCTION GetCondition   (
   p_application_id               IN NUMBER
 , p_component_type               IN VARCHAR2
 , p_component_code               IN VARCHAR2
 , p_component_type_code          IN VARCHAR2
 , p_component_name               IN VARCHAR2
 , p_entity_code                  IN VARCHAR2 DEFAULT NULL
 , p_event_class_code             IN VARCHAR2 DEFAULT NULL
 , p_amb_context_code             IN VARCHAR2
 --
 , p_description_prio_id          IN NUMBER   DEFAULT NULL
 , p_acctg_line_code              IN VARCHAR2 DEFAULT NULL
 , p_acctg_line_type_code         IN VARCHAR2 DEFAULT NULL
 , p_segment_rule_detail_id       IN NUMBER   DEFAULT NULL
 --
 , p_array_cond_source_index      IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
 --
 , p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN VARCHAR2
;
--
END xla_cmp_condition_pkg; -- end of package spec
 

/
