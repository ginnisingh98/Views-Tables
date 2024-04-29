--------------------------------------------------------
--  DDL for Package XLA_CMP_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_CREATE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpdbo.pkh 120.4 2004/06/18 08:08:38 aquaglia ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_create_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for creation packages (spec and body) in the database                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     22-APR-2003 K.Boussema    Included error messages                      |
|     02-JUN-2004 A.Quaglia     Added push_database_object, execute_dml      |
|     18-JUN-2004 A.Quaglia     push_database_object: changed IN OUT into IN |
+===========================================================================*/
--
--
C_SPECIFICATION                  CONSTANT    VARCHAR2(30) := 'PACKAGE';
C_BODY                           CONSTANT    VARCHAR2(30) := 'PACKAGE BODY';

G_STANDARD_MESSAGE    CONSTANT VARCHAR2(1)
                         := xla_exceptions_pkg.C_STANDARD_MESSAGE;
G_OA_MESSAGE          CONSTANT VARCHAR2(1)
                         := xla_exceptions_pkg.C_OA_MESSAGE;
--
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC Functions                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION CreateSpecPackage(
                             p_product_rule_name    IN VARCHAR2
                           , p_package_name         IN VARCHAR2
                           , p_package_text         IN VARCHAR2
                           )
RETURN BOOLEAN
;
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC Functions                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION CreateBodyPackage(
                             p_product_rule_name    IN VARCHAR2
                           , p_package_name         IN VARCHAR2
                           , p_package_text         IN DBMS_SQL.VARCHAR2S
                           )
RETURN BOOLEAN
;


--Additions for the Transaction Account Builder
FUNCTION push_database_object
                        (
                          p_object_name          IN VARCHAR2
                         ,p_object_type          IN VARCHAR2
                         ,p_object_owner         IN VARCHAR2
                         ,p_apps_account         IN VARCHAR2
                         ,p_msg_mode             IN VARCHAR2
                         ,p_ddl_text             IN CLOB
                        )
RETURN BOOLEAN;

FUNCTION execute_dml
               (
                 p_dml_text         IN CLOB
                ,p_msg_mode         IN VARCHAR2
               )
RETURN BOOLEAN;

--
--
END xla_cmp_create_pkg; -- end of package spec
 

/
