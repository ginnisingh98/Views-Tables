--------------------------------------------------------
--  DDL for Package Body JTY_USAGE_SEC_POLICY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_USAGE_SEC_POLICY_PVT" AS
/* $Header: jtfusgpb.pls 120.0 2005/10/21 09:25:32 jradhakr noship $ */

--
-- Name
--     get_usg_security
-- Purpose
--   This function implements the security policy for the territory usages
--   access control mechanism. It is automatically called by the oracle
--   server whenever a secured table or view is referenced by a SQL
--   statement. Products should not call this function directly.
--
--   The security policy function is expected to return a predicate
--   (a WHERE clause) that will control which records can be accessed
--   or modified by the SQL statement. After incorporating the
--   predicate, the server will parse, optimize and execute the
--   modified statement.
--
-- Arguments
--   table_alias     - Alias being used for jtf_sources
--

FUNCTION get_usg_security ( obj_schema VARCHAR2,
                            obj_name   VARCHAR2)
RETURN VARCHAR2 IS
  l_where_clause       VARCHAR2(1000);
  l_status             VARCHAR2(10);
  l_sec_by_usgs_flag   VARCHAR2(2);
BEGIN

    fnd_data_security.get_security_predicate (
                      p_api_version => 1.0,
                      p_object_name => obj_name,
                      x_predicate => l_where_clause,
                      x_return_status => l_status);

  RETURN l_where_clause;
END get_usg_security;

END JTY_USAGE_SEC_POLICY_PVT;

/
