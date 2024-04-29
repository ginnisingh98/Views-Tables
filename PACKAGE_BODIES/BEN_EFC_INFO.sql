--------------------------------------------------------
--  DDL for Package Body BEN_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EFC_INFO" AS
/* $Header: benefinf.pkb 115.5 2004/02/16 02:40:08 vvprabhu noship $ */
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
--
l_table_name VARCHAR2(30);
l_column_name VARCHAR2(30);
l_result VARCHAR2(30);
l_status			varchar2(1);
l_industry			varchar2(1);
l_application_short_name	varchar2(30) := 'BEN';
l_oracle_schema		        varchar2(30);
l_return                        boolean;

--
CURSOR csr_test (
    l_table_name  IN VARCHAR2,
    l_column_name IN VARCHAR2,l_oracle_schema IN VARCHAR2) IS
SELECT 'Y'
  FROM all_tab_columns
  WHERE table_name = l_table_name
    AND column_name = l_column_name
    AND owner = upper(l_oracle_schema);

--
BEGIN
--

-- test for product minipack code
-- JUL2001 = July 2001

l_detected := FALSE;
--
-- Check July minipack
--
l_table_name := 'BEN_PRTT_ENRT_RSLT_F_EFC';
l_column_name := 'PRTT_ENRT_RSLT_ID';
--
-- Bug 3431740 Parameter l_oracle_schema added to cursor csr_test, the value is got by the
-- following call
l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
            		                    status                 => l_status,
                        	            industry               => l_industry,
                              	    oracle_schema          => l_oracle_schema);
--
OPEN csr_test(l_table_name,
              l_column_name,l_oracle_schema);
FETCH csr_test INTO l_result;
IF csr_test%FOUND THEN
  l_detected := TRUE;
END IF;
CLOSE csr_test;
--
IF l_detected THEN
  l_version := 'JUL2001';
END IF;


RETURN(l_version);

--
END get_db_version;

--
END ben_efc_info;

/
