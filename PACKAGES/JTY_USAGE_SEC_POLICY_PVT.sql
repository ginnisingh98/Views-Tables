--------------------------------------------------------
--  DDL for Package JTY_USAGE_SEC_POLICY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_USAGE_SEC_POLICY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfusgps.pls 120.0 2005/10/21 09:25:29 jradhakr noship $ */

--
-- Name
--     get_usg_security
-- Purpose
--   Called by oracle (vpd policy) for securing data by territory usages.
-- Arguments
--   table_alias     - Alias being used for jtf_sources
--

FUNCTION get_usg_security ( obj_schema VARCHAR2,
                      obj_name   VARCHAR2)
RETURN VARCHAR2;

END JTY_USAGE_SEC_POLICY_PVT;

 

/
