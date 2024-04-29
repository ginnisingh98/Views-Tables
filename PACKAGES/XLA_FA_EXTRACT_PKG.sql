--------------------------------------------------------
--  DDL for Package XLA_FA_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_FA_EXTRACT_PKG" AUTHID CURRENT_USER AS
-- $Header: xlafaext.pkh 120.0 2006/03/14 19:41:11 svjoshi noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_fa_extract_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     Call accounting program integration APIs for Fixed Assests             |
|                                                                            |
| HISTORY                                                                    |
|     03/06/2006    Shishir Joshi   Created                                  |
|                                                                            |
+===========================================================================*/


PROCEDURE COMPILE
   (p_application_id           IN integer
   ,p_amb_context_code         IN VARCHAR2
   ,p_product_rule_type_code   IN VARCHAR2
   ,p_product_rule_code        IN VARCHAR2
   );
END xla_fa_extract_pkg; -- end of package spec.

 

/
