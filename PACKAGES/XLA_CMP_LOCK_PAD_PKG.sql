--------------------------------------------------------
--  DDL for Package XLA_CMP_LOCK_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_LOCK_PAD_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacplok.pkh 120.2 2003/07/23 17:44:46 tshakire ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_lock_pad_pkg                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     05/25/2002      K.Boussema    Created                                  |
|     26-MAI-2003     K.Boussema    Added amb_context_code column            |
+===========================================================================*/

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| global variable                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Procedures and Functions                                                 |
--|                                                                          |
--|                                                                          |
--+==========================================================================+


FUNCTION LockPAD (  p_application_id         IN NUMBER
                  , p_product_rule_code      IN VARCHAR2
                  , p_product_rule_type_code IN VARCHAR2
                  , p_product_rule_name      IN VARCHAR2
                  , p_amb_context_code       IN VARCHAR2
                  )
RETURN BOOLEAN
;

END xla_cmp_lock_pad_pkg; -- end of package spec
 

/
