--------------------------------------------------------
--  DDL for Package Body HRI_BPL_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_SECURITY" AS
/* $Header: hribpscr.pkb 120.1 2006/11/16 11:35:59 anmajumd noship $ */

/* simply returns the profile option 'HRI_DBI_CHO_NMD_USR' value */
FUNCTION get_named_user_profile_value RETURN NUMBER IS

BEGIN

    RETURN (fnd_profile.value('HRI_DBI_CHO_NMD_USR'));

END get_named_user_profile_value;

/* wrapper function, checks the value for the new CHO
   profile option and returns that if its set
   otherwise returns fnd_global.employee_id          */
FUNCTION get_apps_signin_person_id RETURN NUMBER IS

CURSOR check_cho_resp IS
SELECT 1
FROM fnd_responsibility
WHERE application_id = 453
AND responsibility_key = 'HRI_DBI_CHIEF_HR_OFFICER'
AND fnd_global.resp_id = responsibility_id;

l_cho_resp_ind NUMBER :=0;
l_person_id NUMBER := fnd_global.employee_id;

BEGIN

    OPEN check_cho_resp;
    FETCH check_cho_resp INTO l_cho_resp_ind;
    CLOSE check_cho_resp;

    IF l_cho_resp_ind = 1 THEN
       -- return the CHO named user profile option person_id
       l_person_id := NVL(get_named_user_profile_value,fnd_global.employee_id);
    ELSE
       l_person_id := fnd_global.employee_id;
    END IF;

    RETURN l_person_id;

EXCEPTION WHEN OTHERS THEN
    IF check_cho_resp%ISOPEN THEN
       CLOSE check_cho_resp;
    END IF;
    RETURN l_person_id;

END get_apps_signin_person_id;
--
--
--  Function takes reponsibility id and application id as input and returns
--  the responsibility key
--
FUNCTION get_resp_key(p_resp_id     IN NUMBER,
                      p_resp_appl_id IN NUMBER) RETURN VARCHAR2 IS
--
l_resp_key VARCHAR2(30);
--
CURSOR cur_resp_key
IS
SELECT responsibility_key
FROM FND_RESPONSIBILITY
WHERE responsibility_id = p_resp_id
AND application_id = p_resp_appl_id;
--
BEGIN
  --
  OPEN cur_resp_key;
  FETCH cur_resp_key INTO l_resp_key;
  CLOSE cur_resp_key;
  --
  -- If valid responsibility does not exist for the input parameters then
  -- return NA_EDW
  --
  IF l_resp_key IS NOT NULL THEN
    --
    RETURN(l_resp_key);
    --
  ELSE
    --
    RETURN('NA_EDW');
    --
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF cur_resp_key%ISOPEN THEN
      --
      CLOSE cur_resp_key;
      --
    END IF;
    --
    RETURN('NA_EDW');
    --
END get_resp_key;
--
--
-- Function to get the manager id when a user tries to login to OBIEE. The user
-- gets to see the data as this manager
--
FUNCTION get_mgr_id(p_employee_id IN NUMBER,
                    p_resp_id     IN NUMBER,
                    p_resp_appl_id IN NUMBER) RETURN NUMBER IS
--
l_return_value  NUMBER(15);
l_mgr_id_all    NUMBER(15);
l_mgr_id_anlyst NUMBER(15);
--
BEGIN
  --
  -- Find the responsibility key when logged in from a new responsibility
  --
  IF (p_resp_id <> g_resp_id) OR g_resp_key IS NULL OR g_resp_key='NA_EDW' THEN
    --
    g_resp_id  := p_resp_id;
    --
    g_resp_key := get_resp_key(p_resp_id, p_resp_appl_id);
    --
  END IF;
  --
  -- If logged in through Line Manager responsibility then return the employee id
  --
  IF g_resp_key = 'HRI_OBI_ALL_MGRH' THEN
    --
    l_mgr_id_all := p_employee_id;
    --
    IF l_mgr_id_all IS NULL THEN
      --
      l_mgr_id_all:= -1;
      --
    END IF;
    --
    l_return_value := l_mgr_id_all;
    --
  --
  -- If logged in through the HR Manager By Analyst responsibility, then
  -- return the value of the profile HRI:HR Analyst(Manager View) Top
  --
  ELSIF g_resp_key = 'HRI_OBIEE_WRKFC_MGRH' THEN
    --
    l_mgr_id_anlyst := fnd_profile.value('HRI_OBIEE_WRKFC_MGRH_TOP');
    --
    IF l_mgr_id_anlyst IS NULL THEN
      --
      l_mgr_id_anlyst := -1;
      --
    END IF;
    --
    l_return_value:= l_mgr_id_anlyst;
    --
  ELSE
    --
    -- Return -1 for all other responsibilities other than Line Manager and
    -- HR Manager By Analyst responsibility
    --
    l_return_value:= -1;
    --
  END IF;
  --
  RETURN(l_return_value);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RETURN(-1);
    --
END get_mgr_id;
--
-- Function to get the organization id when a user tries to login to OBIEE.
-- The user gets to see the data of this organization
--
FUNCTION get_org_id(p_employee_id IN NUMBER,
                    p_resp_id IN NUMBER,
                    p_resp_appl_id IN NUMBER) RETURN NUMBER IS
--
l_return_value  NUMBER(15);
l_org_id_anlyst NUMBER(15);
l_org_id_all    NUMBER(15);
--
BEGIN
  --
  IF (p_resp_id <> g_resp_id) OR g_resp_key IS NULL OR g_resp_key = 'NA_EDW' THEN
    --
    g_resp_id := p_resp_id;
    --
    g_resp_key := get_resp_key(p_resp_id, p_resp_appl_id);
    --
  END IF;
  --
  -- If logged in through HR Analyst by Organization responsibility then
  -- return the value of profile HRI:HR Analyst (Organization View) Top
  -- for the user
  --
  IF g_resp_key = 'HRI_OBIEE_WRKFC_ORGH' THEN
    --
    l_org_id_anlyst := fnd_profile.value('HRI_OBIEE_WRKFC_ORGH_TOP');
    --
    --
    IF l_org_id_anlyst IS NULL THEN
    --
    l_org_id_anlyst := -1;
    --
    END IF;
    --
    l_return_value:= l_org_id_anlyst;
  --
  --
  -- If logged in through the Department manager responsibility then
  -- return the value of profile HRI:Line Manager (Organization View) Top
  -- for the user
  --
  ELSIF g_resp_key = 'HRI_OBI_ALL_ORGH' THEN
    --
    l_org_id_all := fnd_profile.value('HRI_OBI_ALL_ORGH_TOP');
    --
    IF l_org_id_all IS NULL THEN
      --
      l_org_id_all := -1;
      --
    END IF;
    --
    l_return_value:= l_org_id_all;
    --
  ELSE
    --
    -- Return -1 for all other responsibilities other than Department Manager
    -- and HR Analyst By Organization responsibility
    --
    l_return_value:= -1;
    --
  END IF;
  --
  RETURN(l_return_value);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RETURN(-1);
    --
END get_org_id;
--
-- Overloaded version of get_mgr_id. It takes no parameter as input and uses
-- FND packages to set the parameters
--
FUNCTION get_mgr_id RETURN NUMBER IS
--
l_mgr_id NUMBER(15);
--
BEGIN
 --
 l_mgr_id := get_mgr_id(fnd_global.employee_id, fnd_global.resp_id, fnd_global.resp_appl_id);
 --
 RETURN(l_mgr_id);
 --
END get_mgr_id;
--
-- Overloaded version of get_org_id. It takes no parameter as input and uses
-- FND packages to set the parameters
--
FUNCTION get_org_id RETURN NUMBER IS
--
l_org_id NUMBER(15);
--
BEGIN
 --
 l_org_id := get_org_id(fnd_global.employee_id, fnd_global.resp_id, fnd_global.resp_appl_id);
 --
 RETURN(l_org_id);
 --
END get_org_id;
--
END HRI_BPL_SECURITY;

/
