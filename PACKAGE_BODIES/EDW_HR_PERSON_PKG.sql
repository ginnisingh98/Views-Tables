--------------------------------------------------------
--  DDL for Package Body EDW_HR_PERSON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_PERSON_PKG" AS
/*$Header: hriekpsn.pkb 120.1 2005/06/07 05:40:55 anmajumd noship $*/
FUNCTION Regular_Employee_FK (
              p_person_id     in NUMBER,
              p_instance_code in VARCHAR2 :=NULL)
              RETURN VARCHAR2 IS
  --
  l_emp VARCHAR2(240) := 'NA_EDW';
  l_instance     VARCHAR2(30)  := NULL;
  --
 BEGIN
   --
   IF(p_person_id is NULL) THEN
     --
     RETURN 'NA_EDW';
     --
   END IF;
   --
   IF (p_instance_code is NOT NULL) then
     --
     l_instance := p_instance_code;
     --
   ELSE
     --
     select instance_code into l_instance
     from edw_local_instance;
     --
   END IF;
   --
   l_emp :=  p_person_id || '-' || l_instance
                         || '-' || 'EMPLOYEE'
                         || '-' || 'PERS';
   --
   RETURN l_emp;
   --
 EXCEPTION
   --
   WHEN OTHERS THEN
     RETURN 'NA_EDW';
   --
 END Regular_Employee_FK;
---------------------------------------------------
FUNCTION Planner_FK (
	     p_organization_id in NUMBER,
	     p_planner_code    in VARCHAR2,
         p_instance_code   in VARCHAR2 :=NULL)
         RETURN VARCHAR2 IS
  --
  l_emp          VARCHAR2(240) := 'NA_EDW';
  l_instance     VARCHAR2(30)  := NULL;
  --
 BEGIN
   --
   IF(p_planner_code is NULL OR p_organization_id is NULL) THEN
     --
     RETURN 'NA_EDW';
     --
   END IF;
   --
   IF (p_instance_code is NOT NULL) then
     --
     l_instance := p_instance_code;
     --
   ELSE
     --
     select instance_code into l_instance
     from edw_local_instance;
     --
   END IF;
   --
   l_emp := p_planner_code || '-' || p_organization_id
                           || '-' || l_instance
                           || '-' || 'PLANNER'
                           || '-' || 'PERS';
   --
   RETURN l_emp;
   --
 EXCEPTION
 --
 WHEN OTHERS THEN
	RETURN 'NA_EDW';
 --
 END Planner_FK;
---------------------------------------------------
 FUNCTION Sales_Rep_FK (
	     p_salesrep_id     in NUMBER,
  	     p_organization_id in NUMBER,
         p_instance_code   in VARCHAR2 :=NULL)
         RETURN VARCHAR2 IS
  --
  l_emp       VARCHAR2(240) := 'NA_EDW';
  l_instance  VARCHAR2(30)  := NULL;
  --
 BEGIN
   --
   IF(p_salesrep_id is NULL) THEN
     --
     RETURN 'NA_EDW';
     --
   END IF;
   --
   IF (p_instance_code is NOT NULL) THEN
     --
     l_instance := p_instance_code;
     --
   ELSE
     --
     select instance_code into l_instance
     from edw_local_instance;
     --
   END IF;
   --
   l_emp := p_salesrep_id || '-' || p_organization_id
                          || '-' || l_instance
                          || '-' || 'SALESREP'
                          || '-' || 'PERS';
   --
   RETURN l_emp;
   --
 EXCEPTION
 --
 WHEN OTHERS THEN
	RETURN 'NA_EDW';
 --
 END Sales_Rep_FK;
---------------------------------------------------------------
 FUNCTION Buyer_Flag (p_person_id in NUMBER)
          RETURN VARCHAR2 IS
 --
 l_tmp NUMBER := NULL;
 --
 BEGIN
   --
   SELECT agent_id into l_tmp
   FROM po_agents
   WHERE agent_id = p_person_id
   AND rownum < 2;
   --
   IF l_tmp IS NULL THEN
     --
     RETURN 'N';
     --
   ELSE
     --
     RETURN 'Y';
     --
   END IF;
   --
 EXCEPTION
 WHEN OTHERS THEN
   --
   RETURN 'N';
   --
 END Buyer_Flag;
---------------------------------------------------------------
FUNCTION Planner_Flag (p_person_id in NUMBER)
         RETURN VARCHAR2 IS
  --
  l_tmp NUMBER := NULL;
  --
Begin
  --
  SELECT employee_id into l_tmp
  FROM mtl_planners
  WHERE employee_id = p_person_id
  AND rownum < 2;
  --
  IF l_tmp IS NULL THEN
    --
    RETURN 'N';
    --
  ELSE
    --
    RETURN 'Y';
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
  RETURN 'N';
  --
END Planner_Flag;
---------------------------------------------------------------
FUNCTION Sales_Rep_Flag (p_person_id in NUMBER)
         RETURN VARCHAR2 IS
  --
  l_tmp NUMBER := NULL;
  --
BEGIN
  --
  SELECT person_id into l_tmp
  FROM ra_salesreps_all
  WHERE person_id = p_person_id
  AND rownum < 2;
  --
  IF l_tmp IS NULL THEN
    --
    RETURN 'N';
    --
  ELSE
    --
    RETURN 'Y';
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
  RETURN 'N';
  --
END Sales_Rep_Flag;
--
END EDW_HR_PERSON_PKG;

/
