--------------------------------------------------------
--  DDL for Package Body PQH_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_EFC_INFO" AS
/* $Header: pqhefinf.pkb 115.3 2004/02/12 11:08:59 scnair noship $ */
--

-- ----------------------------------------------------------------------------
-- |-------------------------< get_db_version >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Determines the latest minipack version to have been applied.
--
-- ----------------------------------------------------------------------------
FUNCTION get_db_version RETURN VARCHAR2 IS
--

-- set EFC baseline version
l_version VARCHAR2(30) := 'APR2001';
l_detected BOOLEAN;
l_db_value varchar2(10);

l_status    varchar2(30);
l_industry  varchar2(30);
l_owner     varchar2(30);

l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_owner);
cursor csr_test (p_owner varchar2) is
select 'Y' from all_tab_columns
where table_name ='PQH_BUDGET_VERSIONS'
and column_name ='BUDGET_UNIT1_VALUE'
and data_precision is null
and owner = p_owner;
--
BEGIN
--

-- test for product minipack code
-- JUL2001 = July 2001

l_detected := FALSE;
--
-- <code for detecting July minipack>
-- if found, set l_detected to TRUE
--
open csr_test(l_owner);
fetch csr_test into l_db_value;
if csr_test%found then
   l_detected := TRUE;
else
   l_detected := FALSE;
end if;
close csr_test;

IF l_detected THEN
  l_version := 'JUL2001';
END IF;


RETURN(l_version);

--
END get_db_version;

--
END pqh_efc_info;

/
