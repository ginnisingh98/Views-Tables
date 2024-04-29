--------------------------------------------------------
--  DDL for Package XLA_FSAH_DRILLDOWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_FSAH_DRILLDOWN_PKG" AUTHID CURRENT_USER AS
/* $Header: xlafsahdrl.pkh 120.0.12010000.2 2009/08/05 12:31:52 karamakr noship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_FSAH_DRILLDOWN_PKG                                                      |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|								             |
+===========================================================================*/

--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE GenerateUrl
       (ae_header_id       IN number,
        application_id     IN number,
	p_lang_code	   IN varchar2,
	p_url		   OUT NOCOPY varchar2);


END XLA_FSAH_DRILLDOWN_PKG; -- end of package spec

/
