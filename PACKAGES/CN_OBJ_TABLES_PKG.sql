--------------------------------------------------------
--  DDL for Package CN_OBJ_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_TABLES_PKG" AUTHID CURRENT_USER AS
/* $Header: cnobjtbs.pls 120.1 2005/08/08 04:44:20 rramakri noship $ */

-- Package Name
-- CN_OBJ_TABLES_PKG
-- Purpose
--   Table Handler for cn_obj_tables
--   FORM
--   BLOCK
--
--/*==========================================================================
--
--
--/*==========================================================================
--
--
PROCEDURE  begin_record(
    P_OPERATION                 IN VARCHAR2
  , P_OBJECT_ID                 IN NUMBER
  , P_NAME                      IN VARCHAR2
  , P_DESCRIPTION               IN VARCHAR2
  , P_DEPENDENCY_MAP_COMPLETE   IN VARCHAR2
  , P_STATUS                    IN VARCHAR2
  , P_REPOSITORY_ID             IN NUMBER
  , P_ALIAS                     IN VARCHAR2
  , P_TABLE_LEVEL               IN VARCHAR2
  , P_TABLE_TYPE                IN VARCHAR2
  , P_OBJECT_TYPE               IN VARCHAR2
  , P_SCHEMA                    IN VARCHAR2
  , P_CALC_ELIGIBLE_FLAG        IN VARCHAR2
  , P_USER_NAME                 IN VARCHAR2
  , P_DATA_TYPE                 IN VARCHAR2
  , P_DATA_LENGTH               IN NUMBER
  , P_CALC_FORMULA_FLAG         IN VARCHAR2
  , P_TABLE_ID                  IN NUMBER
  , P_COLUMN_DATATYPE           IN VARCHAR2
  , X_OBJECT_VERSION_NUMBER     IN OUT NOCOPY NUMBER
  , P_ORG_ID                    IN NUMBER
  )  ;
END cn_obj_tables_pkg;
 

/
