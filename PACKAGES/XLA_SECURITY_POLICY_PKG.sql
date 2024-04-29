--------------------------------------------------------
--  DDL for Package XLA_SECURITY_POLICY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SECURITY_POLICY_PKG" AUTHID DEFINER AS
-- $Header: xlacmpol.pkh 120.3 2005/08/13 00:57:00 svjoshi ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlacmpol.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_security_policy_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|    Security policy package that contains standard XLA security policy.     |
|                                                                            |
| HISTORY                                                                    |
|    11-Feb-02  S. Singhania    Created from the package XLA_SECURITY_PKG    |
|                                                                            |
+===========================================================================*/

FUNCTION xla_standard_policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION MO_policy
       (p_obj_schema                 IN VARCHAR2
       ,p_obj_name                   IN VARCHAR2)
RETURN VARCHAR2;

END xla_security_policy_pkg;
 

/
