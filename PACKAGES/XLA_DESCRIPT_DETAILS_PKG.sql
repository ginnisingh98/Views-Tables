--------------------------------------------------------
--  DDL for Package XLA_DESCRIPT_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_DESCRIPT_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdpd.pkh 120.1 2003/03/18 00:37:40 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_descript_details_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Description Priority_details package                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_desc_prio_details                                              |
|                                                                       |
| Deletes all description details for the description priority          |
|                                                                       |
+======================================================================*/

PROCEDURE delete_desc_prio_details
  (p_description_prio_id              IN NUMBER);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| display_desc_prio_details                                             |
|                                                                       |
| Returns the entire description detail for the priority                |
|                                                                       |
+======================================================================*/

FUNCTION display_desc_prio_details
  (p_description_prio_id              IN NUMBER
  ,p_chart_of_accounts_id             IN NUMBER)
RETURN VARCHAR2;

END xla_descript_details_pkg;
 

/
