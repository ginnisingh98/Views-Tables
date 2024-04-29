--------------------------------------------------------
--  DDL for Package XLA_RPT_UTIL_QRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_RPT_UTIL_QRY_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarput2.pkh 120.1.12010000.1 2009/11/10 23:46:24 nksurana noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarput2.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_rpt_util_qry_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification. This calls the various Application/Report       |
|     specific hooks to get their Custom Query for SLA wrapper Reports.      |
|                                                                            |
| HISTORY                                                                    |
|     08/13/2009  nksurana        Created                                    |
|                                                                            |
+===========================================================================*/


PROCEDURE get_custom_query(p_application_id      IN  NUMBER,
                           p_custom_query_flag   IN  VARCHAR2,
                           p_custom_header_query OUT NOCOPY VARCHAR2,
                           p_custom_line_query   OUT NOCOPY VARCHAR2);

END xla_rpt_util_qry_pkg;

/
