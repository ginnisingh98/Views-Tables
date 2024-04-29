--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PTL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PTL_PARAM" AS
/*$Header: hriopprm.pkb 120.1 2005/09/27 07:10:54 cbridge noship $ */
  FUNCTION get_params(region_id IN VARCHAR2) RETURN VARCHAR2 IS
     employee_id    NUMBER(10);
     employee_name  VARCHAR2(240);
  BEGIN
     employee_id := hri_bpl_security.get_apps_signin_person_id;
     BEGIN
         SELECT per.full_name INTO employee_name
         FROM   per_all_people_f per
         WHERE  per.person_id = employee_id
         AND    TRUNC(SYSDATE) BETWEEN per.effective_start_date
                               AND     per.effective_end_date;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
              employee_name := NULL;
     END;

     IF    (region_id = 'HRI_P_SALABV_SUP_RCM') THEN
            RETURN '&'||'HRI_P_SUP_LNAME_CN='||employee_name;
     ELSIF (region_id = 'HRI_P_ABV_HIRAC_SUP_X') THEN
            RETURN '&'||'HRI_P_SUP_ID='||employee_name||
                   '&'||'HRI_P_ABV_ID='||'Head Count';
     ELSIF (region_id = 'HRI_P_ABV_CHG_X') THEN
            RETURN '&'||'HRI_P_SUP_ID='||employee_name||
                   '&'||'HRI_P_ABV_ID='||'Head Count';
     ELSIF (region_id = 'HRI_P_ABVTRN_SUPRO_SEPRSN_RPD') THEN
            RETURN '&'||'HRI_P_SUP_ID='||employee_name||
                   '&'||'HRI_P_ABV_ID='||'Head Count'||
                   '&'||'HRI_P_PDRNG_ID='||'Quarter';
     ELSIF (region_id = 'HRI_P_ABVTRN_SUPRO_LOW_RPD') THEN
            RETURN '&'||'HRI_P_SUP_ID='||employee_name||
                   '&'||'HRI_P_ABV_ID='||'Head Count'||
                   '&'||'HRI_P_PDRNG_ID='||'Quarter';
     ELSIF (region_id = 'HRI_P_ABV_SEP_SUP_RPD') THEN
            RETURN '&'||'HRI_P_SUP_ID='||employee_name||
                   '&'||'HRI_P_ABV_ID='||'Head Count'||
                   '&'||'PERIOD='||'Quarter';
     ELSIF (region_id = 'HRI_P_SALABV_NEWHIRE_JB_RPD') THEN
            RETURN '&'||'HRI_P_SUP_ID='||employee_name||
                   '&'||'HRI_P_PDRNG_ID='||'Quarter';
     END IF;
  END get_params;

  FUNCTION get_dbi_params(region_id IN VARCHAR2) RETURN VARCHAR2 IS
     employee_id    NUMBER(10);
     employee_name  VARCHAR2(240);
     currency       FII_CURRENCIES_V.VALUE%TYPE;
  BEGIN
     -- bug 3886182, wrapped in an NVL(, -1)
     employee_id := NVL(hri_bpl_security.get_apps_signin_person_id,-1);
     currency:='FII_GLOBAL1';

     IF    (region_id = 'HRI_PMV_MGR_PARAM_PORTLET') THEN
            RETURN '&'||'AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
                   '&'||'BIS_MANAGER='||employee_id||
                   '&'||'CURRENCY='||currency||
                   '&'||'SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL'||
                   '&'||'TIME+FII_ROLLING_QTR=TIME+FII_ROLLING_QTR' ;
     --
     ELSIF (region_id = 'HRI_PMV_ABS_PARAM_PORTLET') THEN
            RETURN '&'||'AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
                   '&'||'BIS_MANAGER='||employee_id||
                   '&'||'CURRENCY='||currency||
                   '&'||'SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL'||
                   '&'||'TIME+FII_ROLLING_QTR=TIME+FII_ROLLING_QTR' ;
     --
     ELSE
         RETURN NULL;
     END IF;
  END get_dbi_params;

  FUNCTION get_dbi_mgr_id RETURN VARCHAR2 IS
  BEGIN
   -- bug 3886182, wrapped in an NVL(, -1)
   return NVL(hri_bpl_security.get_apps_signin_person_id,-1);
  END get_dbi_mgr_id;


  FUNCTION get_dbi_curr RETURN VARCHAR2 IS
    currency       FII_CURRENCIES_V.VALUE%TYPE;
  BEGIN
      RETURN 'FII_GLOBAL1';
  END get_dbi_curr;

  FUNCTION get_dbi_date RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY');
  END get_dbi_date;

END hri_oltp_ptl_param;

/
