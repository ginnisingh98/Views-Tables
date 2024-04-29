--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_BEN_PTL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_BEN_PTL_PARAM" AS
/* $Header: hriopprmben.pkb 120.0 2005/09/21 01:27:20 anmajumd noship $ */
--
PROCEDURE PRINT_TABLE_PARAMETERS (
     p_page_parameter_tbl IN              bis_pmv_page_parameter_tbl )
IS
   --
   --
BEGIN
   --
   hr_utility.trace_on(null, 'DBIBEN');
   hr_utility.set_location('--------------------------------------', 9999);
   --
   IF (p_page_parameter_tbl.COUNT > 0)
   THEN
      --
      FOR i IN p_page_parameter_tbl.FIRST .. p_page_parameter_tbl.LAST
      LOOP
         --
         hr_utility.set_location('----', 9999);
         hr_utility.set_location('ACE parameter_name = ' || p_page_parameter_tbl (i).parameter_name, 9999);
         hr_utility.set_location('ACE parameter_value = ' || p_page_parameter_tbl (i).parameter_value, 9999);
         hr_utility.set_location('ACE parameter_id = ' || p_page_parameter_tbl (i).parameter_id, 9999);
         --
      END LOOP;
      --
   END IF;
   --
   hr_utility.trace_off;
   --
END PRINT_TABLE_PARAMETERS;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< GET_PGM_DIMENSION >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function will return PGM_ID for default program. This ID will be used
-- to default the Program Dimension on all of the four standalone reports.
--
FUNCTION GET_PGM_DIMENSION RETURN VARCHAR2
IS
   --
   l_pgm_id             NUMBER;
   l_param              VARCHAR2(2000);
   --
   CURSOR c_pgm
   IS
      SELECT ID
        FROM (SELECT   ID
                  FROM hri_cl_co_pgm_v
                 WHERE SYSDATE BETWEEN start_date AND end_date
              ORDER BY VALUE)
       WHERE ROWNUM < 2;
   --
BEGIN
   --
   open c_pgm;
      --
      fetch c_pgm into l_pgm_id;
      --
      if c_pgm%found
      then
        --
        l_param :=  l_pgm_id;
        --
      else
        --
        l_param := NULL;
        --
      end if;
      --
   close c_pgm;
   --
   RETURN l_param;
   --
END GET_PGM_DIMENSION;
--
-- ----------------------------------------------------------------------------
-- |-------------------< GET_OES_DASHBOARD_PARAMS >---------------------------|
-- ----------------------------------------------------------------------------
--
-- The function will return string containing all default parameters for parameter
-- portlet of Open Enrollment Status dashboard.
--
FUNCTION GET_OES_DASHBOARD_PARAMS
   RETURN VARCHAR2
IS
   --
   l_pgm_id             NUMBER;
   l_param              VARCHAR2(2000);
   --
   CURSOR c_pgm
   IS
      SELECT ID
        FROM (SELECT   ID
                  FROM hri_cl_co_pgm_v
                 WHERE SYSDATE BETWEEN start_date AND end_date
              ORDER BY VALUE)
       WHERE ROWNUM < 2;
   --
BEGIN
   --
   open c_pgm;
      --
      fetch c_pgm into l_pgm_id;
      --
      if c_pgm%found
      then
        --
        l_param := '&HRI_PGM_DIM_CN=' || l_pgm_id;
        --
      else
        --
        l_param := NULL;
        --
      end if;
      --
   close c_pgm;
   --
   RETURN l_param;
   --
END GET_OES_DASHBOARD_PARAMS;
--
END HRI_OLTP_BEN_PTL_PARAM;

/
