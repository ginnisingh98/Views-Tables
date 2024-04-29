--------------------------------------------------------
--  DDL for Package XLA_DRILLDOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_DRILLDOWN_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaiqdrl.pkh 120.6 2005/07/22 23:16:08 sasingha noship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_drilldown_pkg                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|        This Package is a PL/SQL wrapper to the GL Team  for Drilldown |
| specific Procedures.                                                  |
| HISTORY                                                               |
|    14-MAR-05  Kprattip          Created                               |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| is_FA_drilldown                                                       |
|                                                                       |
+======================================================================*/

FUNCTION is_FA_drilldown (
   p_je_header_id               NUMBER
  ,p_je_source                  VARCHAR2
  ,p_je_category                VARCHAR2 ) RETURN BOOLEAN;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| check_drilldown                                                       |
|                                                                       |
+======================================================================*/


PROCEDURE check_drilldown
  (p_je_source                VARCHAR2
  ,p_je_category              VARCHAR2
  ,p_je_header_id             NUMBER
  ,p_je_line_num              NUMBER
  ,p_drilldown_flag  OUT NOCOPY  VARCHAR2
  ,p_application_id  OUT NOCOPY  NUMBER );

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| open_drilldown                                                        |
|                                                                       |
+======================================================================*/


PROCEDURE open_drilldown
  (p_je_source                  VARCHAR2
  ,p_je_header_id               NUMBER
  ,p_je_from_sla_flag           VARCHAR2 DEFAULT NULL
  ,p_form_function              IN OUT NOCOPY  VARCHAR2
  ,p_je_line_num                IN OUT NOCOPY  NUMBER );

END xla_drilldown_pkg;
 

/
