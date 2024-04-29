--------------------------------------------------------
--  DDL for Package FND_ACCESS_CONTROL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ACCESS_CONTROL_UTIL" AUTHID CURRENT_USER AS
/* $Header: AFACUTLS.pls 120.1.12010000.3 2017/03/16 15:06:12 emiranda ship $ */


FUNCTION Get_Org_Name( p_org_id NUMBER )
RETURN VARCHAR2;

FUNCTION Policy_Exists(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Add_Policy(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
, p_function_schema     IN VARCHAR2
, p_policy_function     IN VARCHAR2
, p_statement_types     IN VARCHAR2 := 'SELECT, INSERT, UPDATE, DELETE'
, p_update_check        IN BOOLEAN  := TRUE
, p_enable              IN BOOLEAN  := TRUE
);

PROCEDURE Drop_Policy(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
);

PROCEDURE Add_Policy(
  p_object_schema       IN VARCHAR2
, p_object_name         IN VARCHAR2
, p_policy_name         IN VARCHAR2
, p_function_schema     IN VARCHAR2
, p_policy_function     IN VARCHAR2
, p_statement_types     IN VARCHAR2 := 'SELECT, INSERT, UPDATE, DELETE'
, p_update_check        IN BOOLEAN  := TRUE
, p_enable              IN BOOLEAN  := TRUE
, p_static_policy       IN BOOLEAN
, p_policy_type         IN BINARY_INTEGER DEFAULT NULL
);

END fnd_access_control_util;

/
