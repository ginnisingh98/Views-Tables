--------------------------------------------------------
--  DDL for Package Body PQH_EFC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_EFC_UTILS" AS
/* $Header: pqhefutl.pkb 120.0 2005/05/29 02:04:09 appldev noship $ */
--

-- ----------------------------------------------------------------------------
-- |---------------------------< get_efc_version >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines the latest EFC / minipack version to have been applied.
--
-- ----------------------------------------------------------------------------
FUNCTION get_efc_version RETURN VARCHAR2 IS
--

--
BEGIN
--

-- show the product minipack code
-- APR2001 = Apr  2001
-- JUL2001 = July 2001
-- OCT2001 = Oct  2001
-- JAN2002 = Jan  2002

RETURN('JUL2001');

--
END get_efc_version;


--
END pqh_efc_utils;

/
