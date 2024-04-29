--------------------------------------------------------
--  DDL for Package XLA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SECURITY_PKG" AUTHID CURRENT_USER AS
-- $Header: xlacmsec.pkh 120.7 2006/08/11 17:53:18 wychan ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlacmsec.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_security_pkg                                                        |
|                                                                            |
| DESCRIPTION                                                                |
|    XLA security package that contains code related to implementation of    |
|    'Transaction Security' on accounting events.                            |
|                                                                            |
| HISTORY                                                                    |
|    08-Feb-01  G. Gu           Created                                      |
|    10-Mar-01  P. Labrevois    Reviewed                                     |
|    15-Nov-02  S. Singhania    Reworked on the package to make it a working |
|                               package.                                     |
|    27-Nov-02  S. Singhania    Added 'install_security' procedure           |
|    11-Feb-03  S. Singhania    Removed 'install_security' and               |
|                                'xla_security_policy' from this package.    |
|                                                                            |
+===========================================================================*/

PROCEDURE set_security_context
       (p_application_id             IN  NUMBER);

PROCEDURE set_security_context
       (p_application_id             IN  NUMBER
       ,p_always_do_mo_init_flag     IN  VARCHAR2);

PROCEDURE set_subledger_security
       (p_application_id             IN NUMBER
       ,p_security_function_name     IN VARCHAR2);

END xla_security_pkg;
 

/
