--------------------------------------------------------
--  DDL for Package Body CSM_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PROFILE_PKG" AS
/* $Header: csmuprfb.pls 120.6.12010000.3 2009/09/03 05:49:16 trajasek ship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
--	Melvin P	04/30/02	Base creation
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

v_DefaultStatusResponsibility number;
v_CurrentUser varchar2(30);

G_RESP_LEVEL_ID    CONSTANT NUMBER := 10003;
G_USER_LEVEL_ID    CONSTANT NUMBER := 10004;

Function value_specific(p_profile_option_name in varchar2,
                        p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return varchar2
is
l_retvalue varchar2(255);
l_user_id fnd_user.user_id%type;
l_responsibility_id fnd_user_resp_groups.responsibility_id%type;
l_application_id fnd_application.application_id%type;

-- will always return 1 row as of now for a publication
cursor l_resp_app_id_csr(c_user_id NUMBER)
is
SELECT responsibility_id,app_id
FROM   asg_user
WHERE  user_id = c_user_id;


begin
 -- initialize the user_id and the application_id
 l_user_id := p_user_id;

    -- R12 get the responsibility_id and application_id for the publication
 open  l_resp_app_id_csr(l_user_id);
 fetch l_resp_app_id_csr into l_responsibility_id,l_application_id;
 close l_resp_app_id_csr;

 if p_application_id is not null THEN
     l_application_id := p_application_id;
 end if;

 if p_responsibility_id is not null then
    l_responsibility_id := p_responsibility_id;
 end if;

 l_retvalue := fnd_profile.value_specific(p_profile_option_name, l_user_id,
                                     l_responsibility_id, l_application_id);

 return l_retvalue;
end value_specific;

function get_master_organization_id (p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return number
IS
begin
--	return fnd_profile.value('ASO_PRODUCT_ORGANIZATION_ID');
  return value_specific('ASO_PRODUCT_ORGANIZATION_ID', p_user_id,
                            p_responsibility_id, p_application_id);
end get_master_organization_id;

function get_service_validation_org(p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return number
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CS_INV_VALIDATION_ORG';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CS_INV_VALIDATION_ORG', p_user_id,
                       p_responsibility_id, p_application_id);
end get_service_validation_org;

function get_organization_id(p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return number
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CS_INV_VALIDATION_ORG';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CS_INV_VALIDATION_ORG', p_user_id,
                       p_responsibility_id, p_application_id);
end get_organization_id;

Function get_category_set_id(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSM_ITEM_CATEGORY_SET_FILTER';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CSM_ITEM_CATEGORY_SET_FILTER', p_user_id,
                       p_responsibility_id, p_application_id);
END get_category_set_id;

Function get_category_id(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSM_ITEM_CATEGORY_FILTER';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CSM_ITEM_CATEGORY_FILTER', p_user_id,
                       p_responsibility_id, p_application_id);
END get_category_id;

Function get_history_count(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return NUMBER
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT NVL(acc.profile_option_value,0)
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSM_HISTORY_COUNT';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN round(l_profile_option_value);
    END IF;
    CLOSE l_profile_opt_value_csr;

	l_profile_option_value := value_specific('CSM_HISTORY_COUNT', p_user_id,
                                    p_responsibility_id, p_application_id);

    RETURN round(NVL(l_profile_option_value,0));
EXCEPTION
  WHEN OTHERS THEN
     RETURN 0;
END get_history_count;

function get_org_id(p_user_id in fnd_user.user_id%type,
                    p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                    p_application_id fnd_application.application_id%type default null)
return number
is
begin
    return value_specific('CS_SR_ORG_ID', p_user_id, p_responsibility_id,
                           p_application_id);
end get_org_id;

function GetProfileAt( x_name in varchar2
                    , x_user_id in number default null
                    , x_resp_id in number default null
                    , x_site_level in BOOLEAN default false )
return number
is
CURSOR c_profile ( p_profile_option_name VARCHAR2,
                   p_resp_level_value    NUMBER,
                   p_user_level_value    NUMBER
                 ) IS
  SELECT val.profile_option_value
    FROM fnd_profile_options       opt,
         fnd_profile_option_values val
    WHERE NVL(opt.start_date_active, SYSDATE) <= SYSDATE
     AND NVL(opt.end_date_active,   SYSDATE) >= SYSDATE
     AND opt.profile_option_name = p_profile_option_name
     AND opt.application_id      = val.application_id
     AND opt.profile_option_id   = val.profile_option_id
     AND ( ( val.level_id    = G_RESP_LEVEL_ID    AND
             val.level_value = p_resp_level_value
           ) OR
           ( val.level_id    = G_USER_LEVEL_ID    AND
             val.level_value = p_user_level_value
           )
         )
         ORDER BY val.level_id DESC;

   l_profile_option_value VARCHAR2(240);
   l_return_val NUMBER;

BEGIN
  OPEN c_profile ( x_name,
                   x_resp_id,
                   x_user_id
                 );
  FETCH c_profile INTO l_profile_option_value;
  CLOSE c_profile;

  l_return_val := TO_NUMBER( l_profile_option_value);
  IF l_return_val IS NULL AND x_site_level = TRUE THEN
     fnd_profile.GET(NAME => x_name, VAL => l_profile_option_value );
     l_return_val := TO_NUMBER(l_profile_option_value);
  END IF;
  RETURN l_return_val;
end GetProfileAt;


function GetDefaultStatusResponsibility(p_user_id fnd_user.user_id%type) return number IS
BEGIN
-- commented for bug 3255962
-- IF v_CurrentUser <> nvl(ASG_BASE.get_user_name, csm_util_pkg.get_user_name(p_user_id)) THEN
--   v_CurrentUser := nvl(ASG_BASE.get_user_name, csm_util_pkg.get_user_name(p_user_id));
   v_DefaultStatusResponsibility := GetProfileAt( x_name =>'CSF_STATUS_RESPONSIBILITY'
                                                , x_user_id => nvl(ASG_BASE.get_user_Id, p_user_id)
                                                , x_site_level => TRUE );
-- END IF;
 return v_DefaultStatusResponsibility;
end GetDefaultStatusResponsibility;

Function get_change_completed_tasks (p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return varchar2 IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSF_M_CHANGE_COMPLETED_TASKS';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CSF_M_CHANGE_COMPLETED_TASKS', p_user_id,
                       p_responsibility_id, p_application_id);
end get_change_completed_tasks;

Function show_new_mail_only(p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return varchar2 IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSF_M_SHOW_NEW_MAIL_ONLY';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CSF_M_SHOW_NEW_MAIL_ONLY', p_user_id,
                        p_responsibility_id, p_application_id);
end show_new_mail_only;


Function get_task_history_days(p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return number IS
l_profile_option_value NUMBER;

BEGIN
--this profile is not downloaded to client so it wont be there in acc..

	l_profile_option_value := value_specific('CSM_PURGE_INTERVAL', p_user_id,
                        p_responsibility_id, p_application_id);

    RETURN ROUND(NVL(l_profile_option_value,0));
EXCEPTION
  WHEN OTHERS THEN
     RETURN 0;
end get_task_history_days;

Function get_max_attachment_size(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return NUMBER
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT acc.profile_option_value
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSM_MAX_ATTACHMENT_SIZE';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	return value_specific('CSM_MAX_ATTACHMENT_SIZE', p_user_id,
                       p_responsibility_id, p_application_id);
END get_max_attachment_size;

FUNCTION get_max_ib_at_location(p_user_id fnd_user.user_id%TYPE,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL,
                        p_application_id fnd_application.application_id%TYPE DEFAULT NULL
                        )
RETURN NUMBER
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT NVL(acc.profile_option_value,0)
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSM_IB_ITEMS_AT_LOCATION';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN ROUND(l_profile_option_value);
    END IF;
    CLOSE l_profile_opt_value_csr;

	l_profile_option_value := value_specific('CSM_IB_ITEMS_AT_LOCATION', p_user_id,
                                              p_responsibility_id, p_application_id);

    RETURN ROUND(NVL(l_profile_option_value,0));
EXCEPTION
  WHEN OTHERS THEN
     RETURN 0;
END get_max_ib_at_location;

FUNCTION get_max_readings_per_counter(p_user_id fnd_user.user_id%TYPE,
                                      p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL,
                                      p_application_id fnd_application.application_id%TYPE DEFAULT NULL
                                      )
RETURN NUMBER
IS
l_profile_option_value NUMBER;

CURSOR l_profile_opt_value_csr(p_userid IN NUMBER) IS
SELECT NVL(acc.profile_option_value,3) -- download just 3 readings if profile is not set
FROM csm_profile_option_values_acc acc,
     fnd_profile_options po
WHERE acc.user_id = p_user_id
AND acc.profile_option_id = po.profile_option_id
AND po.profile_option_name = 'CSM_MAX_READINGS_PER_COUNTER';

BEGIN
    -- get profile option from acc table to improve performance
    OPEN l_profile_opt_value_csr(p_user_id);
    FETCH l_profile_opt_value_csr INTO l_profile_option_value;
    IF l_profile_opt_value_csr%FOUND THEN
        CLOSE l_profile_opt_value_csr;
        RETURN l_profile_option_value;
    END IF;
    CLOSE l_profile_opt_value_csr;

	l_profile_option_value := value_specific('CSM_MAX_READINGS_PER_COUNTER', p_user_id,
                                              p_responsibility_id, p_application_id);

    -- if profile is not set, download only 3 readings for performance
    RETURN ROUND(NVL(l_profile_option_value,3));

EXCEPTION
  WHEN OTHERS THEN
     RETURN 0;
END get_max_readings_per_counter;

FUNCTION Get_Route_Data_To_Owner(p_user_id fnd_user.user_id%TYPE DEFAULT NULL,
                                      p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL,
                                      p_application_id fnd_application.application_id%TYPE DEFAULT NULL
                                      )
RETURN VARCHAR2
IS
l_profile_option_value VARCHAR2(1);

BEGIN
	l_profile_option_value := value_specific('CSM_DATA_ROUTED_TO_GRP_OWNER', p_user_id,
                                              p_responsibility_id, p_application_id);
    -- if profile is not set then return 'N'
    RETURN NVL(l_profile_option_value,'N');

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'N';
END Get_Route_Data_To_Owner;

--This function is used by Mobile Query and should not be used by others.
--The function gets the profile value for csm mobile query schema directly from the base table
--without using FND API

FUNCTION Get_Mobile_Query_Schema( p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL
                                 )
RETURN VARCHAR2
IS
l_profile_option_value VARCHAR2(255) := NULL;
l_profile_option_NAME  VARCHAR2(255) := 'CSM_MOBILE_QUERY_SCHEMA';

CURSOR c_get_resp_value (c_resp_id NUMBER)
IS
SELECT val.PROFILE_OPTION_VALUE
FROM   FND_PROFILE_OPTION_VALUES val,
       FND_PROFILE_OPTIONS prf
WHERE  prf.PROFILE_OPTION_ID   =  val.PROFILE_OPTION_ID
AND    prf.PROFILE_OPTION_NAME = 'CSM_MOBILE_QUERY_SCHEMA'
AND    LEVEL_ID    = 10003
AND    LEVEL_VALUE = c_resp_id;

CURSOR c_get_site_value
IS
SELECT val.PROFILE_OPTION_VALUE
FROM   FND_PROFILE_OPTION_VALUES val,
       FND_PROFILE_OPTIONS prf
WHERE  prf.PROFILE_OPTION_ID   =  val.PROFILE_OPTION_ID
AND    prf.PROFILE_OPTION_NAME = 'CSM_MOBILE_QUERY_SCHEMA'
AND    LEVEL_ID    = 10001
AND    LEVEL_VALUE = 0;

BEGIN

  IF p_responsibility_id IS NOT NULL THEN
      OPEN  c_get_resp_value (p_responsibility_id);
      FETCH c_get_resp_value INTO l_profile_option_value;
      CLOSE c_get_resp_value;
  ELSE
      OPEN  c_get_site_value;
      FETCH c_get_site_value INTO l_profile_option_value;
      CLOSE c_get_site_value;
  END IF;

    -- if profile is not set then return Null
   RETURN l_profile_option_value;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END Get_Mobile_Query_Schema;

END CSM_PROFILE_PKG;

/
