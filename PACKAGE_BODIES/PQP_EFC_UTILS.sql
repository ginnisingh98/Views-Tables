--------------------------------------------------------
--  DDL for Package Body PQP_EFC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EFC_UTILS" AS
/* $Header: pqpefutl.pkb 120.1 2005/05/30 00:12:41 rvishwan noship $ */
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
END pqp_efc_utils;

/
