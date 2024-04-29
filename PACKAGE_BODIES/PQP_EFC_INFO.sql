--------------------------------------------------------
--  DDL for Package Body PQP_EFC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EFC_INFO" AS
/* $Header: pqpefinf.pkb 115.3 2004/02/13 10:14:45 tmehra noship $ */
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
l_version      VARCHAR2(30) := 'APR2001';
l_detected     BOOLEAN;
l_table_name   VARCHAR2(30);
l_column_name  VARCHAR2(30);
l_result       VARCHAR2(30);


l_status    varchar2(30);
l_industry  varchar2(30);
l_owner     varchar2(30);

l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('PAY', l_status,
                                                      l_industry, l_owner);


   CURSOR csr_test(l_table_name  IN VARCHAR2,
                   l_column_name IN VARCHAR2,
                   p_owner       IN VARCHAR2) IS
   SELECT 'Y'
   FROM   all_tab_columns
   WHERE  table_name = l_table_name
     AND  column_name  = l_column_name
     AND  owner        = p_owner;

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
   l_table_name  := 'PQP_VEHICLE_DETAILS';
   l_column_name := 'VHD_ATTRIBUTE_CATEGORY';

   OPEN csr_test(l_table_name, l_column_name,l_owner);
   FETCH csr_test INTO l_result;
   IF csr_test%FOUND THEN
      l_detected:=TRUE;
   END IF;
   CLOSE csr_test;
   --
   IF l_detected THEN
      l_version := 'JUL2001';
   END IF;
   --
RETURN(l_version);

--
END get_db_version;

--
END pqp_efc_info;

/
