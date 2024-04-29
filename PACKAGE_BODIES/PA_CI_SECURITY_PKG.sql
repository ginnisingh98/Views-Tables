--------------------------------------------------------
--  DDL for Package Body PA_CI_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_SECURITY_PKG" AS
/* $Header: PACISECB.pls 120.2.12010000.2 2009/07/13 21:20:12 smereddy ship $ */
TYPE t_cache IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
G_proj_auth_tab t_cache;
G_ci_type_tab t_cache;
G_view_proj_i_tab t_cache;
G_view_proj_cr_tab t_cache;
G_view_proj_co_tab t_cache;

G_user_id NUMBER := -999;
G_party_id NUMBER := -999;
G_resp_id NUMBER := -999;
G_project_id NUMBER := -999;

FUNCTION check_view_project(
  p_project_id NUMBER,
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_class_code pa_ci_types_b.ci_type_class_code%TYPE;
BEGIN
  IF G_user_id <> p_user_id THEN
    G_user_id := p_user_id;
    G_resp_id := p_resp_id;
    G_party_id :=  pa_control_items_utils.getPartyId(p_user_id);
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
  ELSIF G_resp_id <> p_resp_id THEN
    G_resp_id := p_resp_id;
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
  END IF;

  SELECT ci_type_class_code
  INTO l_class_code
  FROM pa_ci_types_b cit,
       pa_control_items ci
  WHERE ci.ci_id = p_ci_id
    AND cit.ci_type_id = ci.ci_type_id;

  IF l_class_code = 'ISSUE' THEN
    IF NOT G_view_proj_i_tab.EXISTS(p_project_id) THEN
      G_view_proj_i_tab(p_project_id) := pa_security_pvt.check_user_privilege(
        p_privilege => 'PA_CTRL_ISSUES',
        p_object_name => 'PA_PROJECTS',
        p_object_key => p_project_id);
    END IF;

    RETURN G_view_proj_i_tab(p_project_id);

  ELSIF l_class_code = 'CHANGE_REQUEST' THEN
    IF NOT G_view_proj_cr_tab.EXISTS(p_project_id) THEN
      G_view_proj_cr_tab(p_project_id) := pa_security_pvt.check_user_privilege(
        p_privilege => 'PA_CTRL_CHG_REQS',
        p_object_name => 'PA_PROJECTS',
        p_object_key => p_project_id);
    END IF;

    RETURN G_view_proj_cr_tab(p_project_id);

  ELSIF l_class_code = 'CHANGE_ORDER' THEN
    IF NOT G_view_proj_co_tab.EXISTS(p_project_id) THEN
      G_view_proj_co_tab(p_project_id) := pa_security_pvt.check_user_privilege(
        p_privilege => 'PA_CTRL_CHG_ORDS',
        p_object_name => 'PA_PROJECTS',
        p_object_key => p_project_id);
    END IF;

    RETURN G_view_proj_co_tab(p_project_id);
  END IF;
END check_view_project;

FUNCTION check_view_project (
  p_project_id NUMBER,
  p_ci_id NUMBER,
  p_ci_type_class_code VARCHAR2,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_class_code pa_ci_types_b.ci_type_class_code%TYPE;
BEGIN
  IF G_user_id <> p_user_id THEN
    G_user_id := p_user_id;
    G_resp_id := p_resp_id;
    G_party_id :=  pa_control_items_utils.getPartyId(p_user_id);
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
  ELSIF G_resp_id <> p_resp_id THEN
    G_resp_id := p_resp_id;
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
  END IF;

  l_class_code := p_ci_type_class_code;

  IF l_class_code = 'ISSUE' THEN
    IF NOT G_view_proj_i_tab.EXISTS(p_project_id) THEN
      G_view_proj_i_tab(p_project_id) := pa_security_pvt.check_user_privilege(
        p_privilege => 'PA_CTRL_ISSUES',
        p_object_name => 'PA_PROJECTS',
        p_object_key => p_project_id);
  END IF;

    RETURN G_view_proj_i_tab(p_project_id);

  ELSIF l_class_code = 'CHANGE_REQUEST' THEN
    IF NOT G_view_proj_cr_tab.EXISTS(p_project_id) THEN
      G_view_proj_cr_tab(p_project_id) := pa_security_pvt.check_user_privilege(
        p_privilege => 'PA_CTRL_CHG_REQS',
        p_object_name => 'PA_PROJECTS',
        p_object_key => p_project_id);
    END IF;

    RETURN G_view_proj_cr_tab(p_project_id);

  ELSIF l_class_code = 'CHANGE_ORDER' THEN
    IF NOT G_view_proj_co_tab.EXISTS(p_project_id) THEN
      G_view_proj_co_tab(p_project_id) := pa_security_pvt.check_user_privilege(
        p_privilege => 'PA_CTRL_CHG_ORDS',
        p_object_name => 'PA_PROJECTS',
        p_object_key => p_project_id);
    END IF;

    RETURN G_view_proj_co_tab(p_project_id);
  END IF;
END check_view_project;


FUNCTION check_proj_auth_ci(
  p_project_id NUMBER,
  p_user_id NUMBER,
  p_resp_id NUMBER)
RETURN VARCHAR2
IS
BEGIN
--mthai_debug_msg('a('||p_project_id||', '||p_user_id||', '||p_resp_id||')');
  IF G_user_id <> p_user_id THEN
    G_user_id := p_user_id;
    G_resp_id := p_resp_id;
    G_party_id :=  pa_control_items_utils.getPartyId(p_user_id);
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
--mthai_debug_msg('Reset 1');
  ELSIF G_resp_id <> p_resp_id THEN
    G_resp_id := p_resp_id;
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
--mthai_debug_msg('Reset 2');
  END IF;

  IF NOT G_proj_auth_tab.EXISTS(p_project_id) THEN
    G_proj_auth_tab(p_project_id) := pa_security_pvt.check_user_privilege(
      p_privilege => 'PA_CI_UPDATE',
      p_object_name => 'PA_PROJECTS',
      p_object_key => p_project_id);
--mthai_debug_msg('pa not found, query returns '||G_proj_auth_tab(p_project_id));
  END IF;

  RETURN G_proj_auth_tab(p_project_id);
END check_proj_auth_ci;

FUNCTION is_owner(
  p_ci_id NUMBER,
  p_user_id NUMBER)
RETURN VARCHAR2
IS
  l_status_code VARCHAR2(100);
  l_owner_party_id NUMBER;
  l_creator_user_id NUMBER;
BEGIN
--mthai_debug_msg('o('||p_ci_id||', '||p_user_id||')');
--Clearing cache if user_id is changed
  IF G_user_id <> p_user_id THEN
    G_user_id := p_user_id;
    G_resp_id := -999;
    G_party_id :=  pa_control_items_utils.getPartyId(p_user_id);
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
--mthai_debug_msg('Reset 3');
  END IF;

  SELECT s.project_system_status_code, ci.owner_id, ci.created_by
  INTO l_status_code, l_owner_party_id, l_creator_user_id
  FROM pa_control_items ci,
       pa_project_statuses s
  WHERE ci.ci_id = p_ci_id
    AND s.status_type = 'CONTROL_ITEM'
    AND s.project_status_code = ci.status_code;

  IF (l_status_code='CI_DRAFT' AND l_creator_user_id = G_user_id) OR
     (l_status_code<>'CI_DRAFT' AND l_owner_party_id = G_party_id) THEN
    RETURN 'T';
  END IF;

  RETURN 'F';
END is_owner;

FUNCTION check_view_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_status_code VARCHAR2(100);
  l_project_id NUMBER;
  l_tmp NUMBER;
BEGIN
  SELECT ci.project_id, s.project_system_status_code
  INTO l_project_id, l_status_code
  FROM pa_control_items ci,
       pa_project_statuses s
  WHERE ci.ci_id = p_ci_id
    AND s.status_type = 'CONTROL_ITEM'
    AND s.project_status_code = ci.status_code;

  --Only the creator can see a draft item.
  IF l_status_code = 'CI_DRAFT' AND
     check_proj_auth_ci(l_project_id, p_user_id, p_resp_id) = 'F' AND
     is_owner(p_ci_id, p_user_id) = 'F' THEN
    RETURN 'F';
  END IF;

  --Need to have access to the project to see the control items
  IF check_view_project(l_project_id, p_ci_id, p_user_id, p_resp_id) = 'F' THEN
    --Allowing view access if user ever has an action
    BEGIN
      SELECT 1
      INTO l_tmp
      FROM pa_ci_actions a
      WHERE a.ci_id = p_ci_id
        AND a.assigned_to = G_party_id
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'F';
    END;
  END IF;

  RETURN 'T';
END;

FUNCTION check_view_access(
  p_ci_id NUMBER,
  p_project_id NUMBER,
  p_sys_stat_code VARCHAR2,
  p_ci_type_class_code VARCHAR2,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_status_code VARCHAR2(100);
  l_project_id NUMBER;
  l_tmp NUMBER;
BEGIN
  l_status_code := p_sys_stat_code;
  l_project_id  := p_project_id;

  --Only the creator can see a draft item.
  IF l_status_code = 'CI_DRAFT' AND
     check_proj_auth_ci(l_project_id, p_user_id, p_resp_id) = 'F' AND
     is_owner(p_ci_id, p_user_id) = 'F' THEN
    RETURN 'F';
  END IF;

  --Need to have access to the project to see the control items
  IF check_view_project(l_project_id, p_ci_id, p_ci_type_class_code, p_user_id, p_resp_id) = 'F' THEN
    --Allowing view access if user ever has an action
    BEGIN
      SELECT 1
      INTO l_tmp
      FROM pa_ci_actions a
      WHERE a.ci_id = p_ci_id
        AND a.assigned_to = G_party_id
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'F';
    END;
  END IF;

  RETURN 'T';
END;

FUNCTION check_update_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_tmp NUMBER;
  l_project_id NUMBER;
  l_project_org_id NUMBER;
  l_locked_flag varchar2(1) := 'N';
BEGIN
-- Bug#8668693 the follwoing code is to make sure that the pages get rendered in read only mode when the
-- document gets locked.

select nvl(locked_flag,'N')
INTO l_locked_flag
from pa_control_items
where ci_id = p_ci_id;

if(l_locked_flag = 'Y') then
RETURN 'F';
end if;

  SELECT ci.project_id, ppa.org_id
  INTO l_project_id, l_project_org_id
  FROM pa_control_items ci,
       pa_projects_all ppa
  WHERE ppa.project_id=ci.project_id
    AND ci.ci_id=p_ci_id;

  --Control item cannot be updated across OU
  --Bug#4519391.Modified the if below to use the function pa_moac_utils.check_access.Passing the org_id
  --for the project in concern to this function. The function would return N if the project is not secured.
  IF (pa_moac_utils.check_access(l_project_org_id) = 'N') THEN
    RETURN 'F';
  END IF;

  --Project Authorities and Owner can update the item
  IF check_proj_auth_ci(l_project_id, p_user_id, p_resp_id) = 'T' OR
     is_owner(p_ci_id, p_user_id) = 'T' THEN
    RETURN 'T';
  END IF;

  --People w/ an open Update action can update the item
  BEGIN
    SELECT 1
    INTO l_tmp
    FROM pa_ci_actions a,
         pa_project_statuses s
    WHERE a.ci_id = p_ci_id
      AND s.project_status_code = a.status_code
      AND s.status_type = 'CI_ACTION'
      AND s.project_system_status_code = 'CI_ACTION_OPEN'
      AND a.type_code = 'UPDATE'
--      AND a.assigned_to = pa_control_items_utils.getPartyId(p_user_id)
      AND a.assigned_to = G_party_id
      AND ROWNUM = 1;

    RETURN 'T';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'F';
  END;

  RETURN 'F';
END;

FUNCTION check_update_access1(
  p_ci_id NUMBER,
  p_project_id NUMBER,
  p_proj_org_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_tmp NUMBER;
  l_project_id NUMBER;
  l_project_org_id NUMBER;
BEGIN
/*
  SELECT ci.project_id, ppa.org_id
  INTO l_project_id, l_project_org_id
  FROM pa_control_items ci,
       pa_projects_all ppa
  WHERE ppa.project_id=ci.project_id
    AND ci.ci_id=p_ci_id;
    */

    l_project_id     := p_project_id;
    l_project_org_id := p_proj_org_id;

  --Control item cannot be updated across OU
  --Bug#4519391.Modified the if below to use the function pa_moac_utils.check_access.Passing the org_id
  --for the project in concern to this function. The function would return N if the project is not secured.
  IF (pa_moac_utils.check_access(l_project_org_id) = 'N') THEN
    RETURN 'F';
  END IF;

  --Project Authorities and Owner can update the item
  IF check_proj_auth_ci(l_project_id, p_user_id, p_resp_id) = 'T' OR
     is_owner(p_ci_id, p_user_id) = 'T' THEN
    RETURN 'T';
  END IF;

  --People w/ an open Update action can update the item
  BEGIN
    SELECT 1
    INTO l_tmp
    FROM pa_ci_actions a,
         pa_project_statuses s
    WHERE a.ci_id = p_ci_id
      AND s.project_status_code = a.status_code
      AND s.status_type = 'CI_ACTION'
      AND s.project_system_status_code = 'CI_ACTION_OPEN'
      AND a.type_code = 'UPDATE'
--      AND a.assigned_to = pa_control_items_utils.getPartyId(p_user_id)
      AND a.assigned_to = G_party_id
      AND ROWNUM = 1;

    RETURN 'T';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'F';
  END;

  RETURN 'F';
END;

FUNCTION check_change_owner_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_tmp NUMBER;
  l_project_id NUMBER;
  l_project_org_id NUMBER;
BEGIN
  SELECT ci.project_id, ppa.org_id
  INTO l_project_id, l_project_org_id
  FROM pa_control_items ci, pa_projects_all ppa
  WHERE ci.project_id=ppa.project_id
    AND ci.ci_id = p_ci_id;

  --Control item cannot be updated across OU
  --Bug#4519391.Modified the if below to use the function pa_moac_utils.check_access.Passing the org_id
  --for the project in concern to this function. The function would return N if the project is not secured.
  IF (pa_moac_utils.check_access(l_project_org_id) = 'N') THEN
    RETURN 'F';
  END IF;

  --Project Authorities and Owner can change the owner the item
  IF check_proj_auth_ci(l_project_id, p_user_id, p_resp_id) = 'T' OR
     is_owner(p_ci_id, p_user_id) = 'T' THEN
    RETURN 'T';
  END IF;

  RETURN 'F';
END;

FUNCTION check_change_status_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
BEGIN
  RETURN check_change_owner_access(p_ci_id, p_user_id, p_resp_id);
END;

FUNCTION check_highlight_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id,
  p_project_id NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
  l_tmp NUMBER;
  l_project_id NUMBER := p_project_id;
BEGIN
  IF p_ci_id > 0 THEN
    SELECT project_id
    INTO l_project_id
    FROM pa_control_items
    WHERE ci_id = p_ci_id;
  END IF;

  --Only Project Authorities can highlight the item
  IF check_proj_auth_ci(l_project_id, p_user_id, p_resp_id) = 'T' THEN
    RETURN 'T';
  END IF;

  RETURN 'F';
END;

FUNCTION check_implement_impact_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
BEGIN
  RETURN check_change_owner_access(p_ci_id, p_user_id, p_resp_id);
END;


FUNCTION check_create_action(
            p_ci_id IN NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id,
            p_calling_context IN VARCHAR2 DEFAULT 'UI')-- Bug 5676037. Added the parameter to identify the amg context.
 return VARCHAR2
 IS
    l_result varchar2(1);
    l_party_id number;
    l_ci_action_id number;
    l_status_code varchar2(30);
    l_status_result varchar2(1);
    l_project_id NUMBER;
    l_project_org_id NUMBER;

    Cursor person_with_open_action is
    select a.ci_action_id
    from pa_ci_actions a,
         pa_project_statuses s
    where a.assigned_to = l_party_id
    and a.ci_id = p_ci_id
    and s.project_status_code = a.status_code
    AND s.status_type = 'CI_ACTION'
    and s.project_system_status_code = 'CI_ACTION_OPEN';

  BEGIN

    l_party_id := PA_CONTROL_ITEMS_UTILS.GetPartyId(p_user_id);

    if(l_party_id IS NULL) then
        return 'F';
    end if;

  --Bug 5676037. Added the if condition to identify the AMG context. From AMG context
  -- CheckCIActionAllowed should not be called.
  if(p_calling_context <> 'AMG') then
    l_status_result := PA_CONTROL_ITEMS_UTILS.CheckCIActionAllowed(null,null,'CONTROL_ITEM_ALLOW_ACTION', p_ci_id);
    if (l_status_result = 'N') then
        return 'F';
    end if;
  end if;--    if(p_calling_context <> 'AMG') then

  SELECT ci.project_id, ppa.org_id
  INTO l_project_id, l_project_org_id
  FROM pa_control_items ci, pa_projects_all ppa
  WHERE ci.project_id=ppa.project_id
    AND ci.ci_id = p_ci_id;

  --Control item cannot be updated across OU
  --Bug#4519391.Modified the if below to use the function pa_moac_utils.check_access.Passing the org_id
  --for the project in concern to this function. The function would return N if the project is not secured.
  IF (pa_moac_utils.check_access(l_project_org_id) = 'N') THEN
    RETURN 'F';
  END IF;

  IF check_proj_auth_ci(l_project_id, p_user_id, fnd_global.resp_id) = 'T' OR
     is_owner(p_ci_id, p_user_id) = 'T' THEN
    RETURN 'T';
  END IF;

  Open person_with_open_action;
  fetch person_with_open_action into l_ci_action_id;
  if (person_with_open_action%FOUND) then
    close person_with_open_action;
    return 'T';
  end if;
  close person_with_open_action;

  RETURN 'F';

  END check_create_action;

FUNCTION check_item_owner_project_auth(
            p_ci_id in NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id)
         RETURN VARCHAR2
IS
  l_project_id number;
  l_project_org_id number;

BEGIN
  SELECT ci.project_id, ppa.org_id
  INTO l_project_id, l_project_org_id
  FROM pa_control_items ci, pa_projects_all ppa
  WHERE ci.project_id=ppa.project_id
    AND ci.ci_id = p_ci_id;

  --Control item cannot be updated across OU
  --Bug#4519391.Modified the if below to use the function pa_moac_utils.check_access.Passing the org_id
  --for the project in concern to this function. The function would return N if the project is not secured.
  IF (pa_moac_utils.check_access(l_project_org_id) = 'N') THEN
    RETURN 'F';
  END IF;

  IF check_proj_auth_ci(l_project_id, p_user_id, fnd_global.resp_id) = 'T' OR
     is_owner(p_ci_id, p_user_id) = 'T' THEN
    RETURN 'T';
  END IF;

  RETURN 'F';
END check_item_owner_project_auth;


 FUNCTION check_open_action_assigned_to(
            p_ci_action_id  IN NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id)
 return varchar2
 IS
    l_result varchar2(1);
    l_party_id number;

    Cursor comment_or_close_action is
    select 'T'
    from pa_ci_actions a,
         pa_project_statuses s
    where a.ci_action_id = p_ci_action_id
    and a.assigned_to = l_party_id
    and s.project_status_code = a.status_code
    AND s.status_type = 'CI_ACTION'
    and s.project_system_status_code = 'CI_ACTION_OPEN';

    BEGIN
    l_party_id := PA_CONTROL_ITEMS_UTILS.GetPartyId(p_user_id);

    if(l_party_id IS NULL) then
        return 'F';
    end if;

    Open comment_or_close_action;
    fetch comment_or_close_action into l_result;
    if (comment_or_close_action%NOTFOUND) then
        l_party_id := NULL;
        close comment_or_close_action;
        return 'F';
    end if;
    close comment_or_close_action;

    return l_result;
    EXCEPTION
    	WHEN OTHERS THEN -- catch the exceptins here
        	RAISE;
 END check_open_action_assigned_to;

  FUNCTION check_updatable_comment(
            p_ci_comment_id  IN NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id)
 return varchar2
 IS
    l_ci_id number;
    l_created_by number;

    Cursor comment_owner is
    select ci_id, created_by
    from pa_ci_comments
    where ci_comment_id = p_ci_comment_id;

    BEGIN

    Open comment_owner;
    fetch comment_owner into l_ci_id,l_created_by;
    if (comment_owner%NOTFOUND) then
        close comment_owner;
        return 'F';
    end if;
    close comment_owner;

    if (l_created_by = p_user_id) then
        return 'T';
    end if;

    return check_item_owner_project_auth(l_ci_id, p_user_id);

    EXCEPTION
    	WHEN OTHERS THEN -- catch the exceptins here
        	RAISE;
 END check_updatable_comment;

FUNCTION check_create_CI(
  p_ci_type_id NUMBER,
  p_project_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2
IS
  l_tmp NUMBER;
  l_allow_all_usage_flag VARCHAR2(1);
  l_access_level NUMBER;
  l_return_status VARCHAR2(1) := 'S';
  l_msg_count NUMBER := 0;
  l_msg_data VARCHAR2(4000) := '';
  l_resource_id NUMBER := -999;
BEGIN
  IF G_user_id<>p_user_id OR G_resp_id<>p_resp_id THEN
    G_user_id := p_user_id;
    G_resp_id := p_resp_id;
    G_party_id :=  pa_control_items_utils.getPartyId(p_user_id);
    G_project_id := p_project_id;
    G_proj_auth_tab.DELETE;
    G_view_proj_i_tab.DELETE;
    G_view_proj_cr_tab.DELETE;
    G_view_proj_co_tab.DELETE;
    G_ci_type_tab.DELETE;
  ELSIF G_project_id<>p_project_id THEN
    G_project_id := p_project_id;
    G_ci_type_tab.DELETE;
  END IF;

  IF G_ci_type_tab.EXISTS(p_ci_type_id) THEN
    RETURN G_ci_type_tab(p_ci_type_id);
  END IF;

  SELECT allow_all_usage_flag
  INTO l_allow_all_usage_flag
  FROM pa_ci_types_b
  WHERE ci_type_id = p_ci_type_id;

  IF l_allow_all_usage_flag = 'N' THEN
    BEGIN
      SELECT 1
      INTO l_tmp
      FROM pa_ci_type_usage citu,
           pa_projects_all ppa,
           pa_project_types_all ppt
      WHERE ppa.project_id = p_project_id
        AND ppt.project_type = ppa.project_type
        AND citu.project_type_id = ppt.project_type_id
        AND citu.ci_type_id = p_ci_type_id
        AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        G_ci_type_tab(p_ci_type_id) := 'F';
        RETURN G_ci_type_tab(p_ci_type_id);
    END;
  END IF;

  IF check_proj_auth_ci(p_project_id, p_user_id, p_resp_id) = 'T' THEN
    G_ci_type_tab(p_ci_type_id) := 'T';
    RETURN G_ci_type_tab(p_ci_type_id);
  END IF;

  BEGIN
    l_resource_id := pa_resource_utils.get_resource_id(NULL, p_user_id);

    SELECT 1
    INTO l_tmp
    FROM pa_object_dist_lists l,
         pa_dist_list_items i,
         pa_project_parties p
    WHERE l.object_type = 'PA_CI_TYPES'
      AND l.object_id = p_ci_type_id
      AND i.list_id = l.list_id
      AND p.project_id = p_project_id
      AND p.resource_id = l_resource_id
      AND (   i.recipient_type = 'ALL_PROJECT_PARTIES'
           OR (    i.recipient_type = 'PROJECT_ROLE'
               AND p.project_role_id = i.recipient_id
              )
          )
      AND ROWNUM = 1;

    G_ci_type_tab(p_ci_type_id) := 'T';
    RETURN G_ci_type_tab(p_ci_type_id);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  G_ci_type_tab(p_ci_type_id) := 'F';
  RETURN G_ci_type_tab(p_ci_type_id);
END;


FUNCTION is_to_owner_allowed(
  p_ci_id NUMBER,
  p_owner_id NUMBER)
RETURN VARCHAR2
IS
  l_tmp NUMBER;
  l_project_id NUMBER;
  l_owner_id NUMBER;

  cursor c_owner (p_project_id NUMBER) is
   select distinct resource_party_id
     from PA_PROJECT_PARTIES_V
    where party_type <> 'ORGANIZATION'
      and project_id = p_project_id
      and resource_party_id = p_owner_id;

BEGIN

  SELECT project_id
  INTO l_project_id
  FROM pa_control_items
  WHERE ci_id = p_ci_id;

  open c_owner(l_project_id);
  fetch c_owner into l_owner_id;

  If c_owner%NOTFOUND then
     close c_owner;
     RETURN 'F';
  End if;
  close c_owner;

  RETURN 'T';

EXCEPTION
  WHEN OTHERS THEN
        RAISE;
END;

END pa_ci_security_pkg;

/
