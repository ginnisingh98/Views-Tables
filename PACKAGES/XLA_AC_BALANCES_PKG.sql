--------------------------------------------------------
--  DDL for Package XLA_AC_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AC_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaacbal.pkh 120.0 2008/01/31 08:46:40 veramach noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_ac_balances_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Balance Calculation Package                                    |
|                                                                       |
| HISTORY                                                               |
|                                                                       |
+======================================================================*/

p_batch_code VARCHAR2(100);
p_purge_mode VARCHAR2(1);

FUNCTION call_update_balances RETURN BOOLEAN;
FUNCTION call_purge_interface_recs RETURN BOOLEAN;

PROCEDURE update_balances
                        ( p_errbuf     OUT NOCOPY VARCHAR2
                         ,p_retcode    OUT NOCOPY NUMBER
                         ,p_batch_code IN         VARCHAR2
                         ,p_purge_mode IN         VARCHAR2
                        );

PROCEDURE update_balances
                        ( p_batch_code IN         VARCHAR2
                         ,p_purge_mode IN         VARCHAR2
                        );

PROCEDURE purge_interface_recs(
                               p_batch_code VARCHAR2,
                               p_purge_mode VARCHAR2
                              );
END xla_ac_balances_pkg;

/
