--------------------------------------------------------
--  DDL for Package FA_XLA_CMP_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_CMP_CREATE_PKG" AUTHID CURRENT_USER AS
/* $Header: faxlaccs.pls 120.0.12010000.2 2009/07/19 08:40:43 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_create_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for creation packages (spec and body) in the database                  |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY    Created                                        |
+===========================================================================*/


C_SPECIFICATION                  CONSTANT    VARCHAR2(30) := 'PACKAGE';
C_BODY                           CONSTANT    VARCHAR2(30) := 'PACKAGE BODY';



--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC Functions                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

FUNCTION CreateSpecPackage(
                            p_package_name         IN VARCHAR2,
                            p_package_text         IN VARCHAR2
                           )
RETURN BOOLEAN;

FUNCTION CreateBodyPackage(
                            p_package_name         IN VARCHAR2,
                            p_package_text         IN DBMS_SQL.VARCHAR2S
                           )
RETURN BOOLEAN;


FUNCTION push_database_object
                          (
                            p_object_name          IN VARCHAR2,
                            p_object_type          IN VARCHAR2,
                            p_object_owner         IN VARCHAR2,
                            p_apps_account         IN VARCHAR2,
                            p_ddl_text             IN CLOB
                           )
RETURN BOOLEAN;

FUNCTION execute_dml
               (
                p_dml_text         IN CLOB
               )
RETURN BOOLEAN;

END fa_xla_cmp_create_pkg; -- end of package spec

/
