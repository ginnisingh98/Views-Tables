--------------------------------------------------------
--  DDL for Package Body IEX_CHECKLIST_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CHECKLIST_UTILITY" AS
/* $Header: iexvchkb.pls 120.11.12010000.5 2010/01/20 16:31:40 ehuh ship $ */

  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'IEX_CHECKLIST_UTILITY';
  G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexvchkb.pls';
  G_APPL_ID              NUMBER;
  G_LOGIN_ID             NUMBER;
  G_PROGRAM_ID           NUMBER;
  G_USER_ID              NUMBER;
  G_REQUEST_ID           NUMBER;

  PG_DEBUG               NUMBER(2);

  --------------------------------------------------------------------
  -- This function returns to image name for the checklist items which are
  --  FUNCTIONAL_AREA
  --------------------------------------------------------------------

FUNCTION GET_GO_TO_TASK_IMAGE_NAME(p_checklist_item_name  IN VARCHAR2,
                                   p_checklist_item_type  IN VARCHAR2,
                                   p_checklist_item_status IN VARCHAR2)
  RETURN VARCHAR2
IS
BEGIN
  IF p_checklist_item_type IN ('FUNCTIONAL_AREA', 'FUNCTIONAL_INIT') THEN
    IF p_checklist_item_status = 'DISABLED' THEN
      RETURN '/OA_MEDIA/takeaction_disabled.gif';
    ELSE
      RETURN '/OA_MEDIA/takeaction_enabled.gif';
    END IF;
  ELSE
    RETURN NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

--------------------------------------------------------------------
-- This function returns to image name of status of the checklist items
-- based upon the status of the tasks of the checklist items.
--
-- If any task is 'In Progress' then the main status will also be
-- In Progress'.
-- If any task is 'Complete' and no task is 'In Progress' then the
-- main status will be 'Complete'.
-- If all tasks are 'Not Applicable' then the main status will also
-- be 'Not Applicable'.
-- If all tasks are 'Not Started' then the main status will also
-- be 'Not Started'
--
--------------------------------------------------------------------
FUNCTION GET_STATUS_IMAGE_NAME(p_checklist_item_name  IN VARCHAR2,
                               p_checklist_item_type  IN VARCHAR2,
                               p_checklist_item_status IN VARCHAR2)
  RETURN VARCHAR2
IS
BEGIN
  IF p_checklist_item_type IN ('FUNCTIONAL_AREA', 'FUNCTIONAL_INIT') THEN
    IF p_checklist_item_status = 'DISABLED' THEN
      RETURN '/OA_MEDIA/notstartedind_status.gif';
    ELSIF p_checklist_item_status = 'NOTSTARTED' THEN
      RETURN '/OA_MEDIA/notstartedind_status.gif';
    ELSIF p_checklist_item_status = 'COMPLETE' THEN
      RETURN '/OA_MEDIA/completeind_status.gif';
    ELSIF p_checklist_item_status = 'INPROGRESS' THEN
      RETURN '/OA_MEDIA/inprogressind_status.gif';
    ELSIF p_checklist_item_status = 'NOTAPPLICABLE' THEN
      RETURN '/OA_MEDIA/notapplicableind_status.gif';
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

FUNCTION GET_RANGE_FROM_VALUE(
  p_score_comp_type_id IN NUMBER,
  p_lookup_code IN VARCHAR2)
  RETURN NUMBER
IS
  CURSOR c_low_from IS
    SELECT low_from
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;

  CURSOR c_medium_from IS
    SELECT medium_from
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;

  CURSOR c_high_from IS
    SELECT high_from
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;

  l_value NUMBER;
BEGIN
  IF p_lookup_code = 'LOW' THEN
    OPEN c_low_from;
    FETCH c_low_from INTO l_value;
    CLOSE c_low_from;
  ELSIF p_lookup_code = 'MEDIUM' THEN
    OPEN c_medium_from;
    FETCH c_medium_from INTO l_value;
    CLOSE c_medium_from;
  ELSIF p_lookup_code = 'HIGH' THEN
    OPEN c_high_from;
    FETCH c_high_from INTO l_value;
    CLOSE c_high_from;
  END IF;

  return l_value;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

FUNCTION GET_RANGE_TO_VALUE(
  p_score_comp_type_id IN NUMBER,
  p_lookup_code IN VARCHAR2) RETURN NUMBER
IS
  CURSOR c_low_to IS
    SELECT low_to
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;

  CURSOR c_medium_to IS
    SELECT medium_to
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;

  CURSOR c_high_to IS
    SELECT high_to
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;

  l_value NUMBER;
BEGIN
  IF p_lookup_code = 'LOW' THEN
    OPEN c_low_to;
    FETCH c_low_to INTO l_value;
    CLOSE c_low_to;
  ELSIF p_lookup_code = 'MEDIUM' THEN
    OPEN c_medium_to;
    FETCH c_medium_to INTO l_value;
    CLOSE c_medium_to;
  ELSIF p_lookup_code = 'HIGH' THEN
    OPEN c_high_to;
    FETCH c_high_to INTO l_value;
    CLOSE c_high_to;
  END IF;

  return l_value;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

PROCEDURE UPDATE_METRIC_RATING(
  p_score_comp_type_id IN NUMBER,
  p_low_from IN NUMBER,
  p_low_to IN NUMBER,
  p_medium_from IN NUMBER,
  p_medium_to IN NUMBER,
  p_high_from IN NUMBER,
  p_high_to IN NUMBER)
IS
  CURSOR c_rating IS
    SELECT '1'
    FROM iex_metric_ratings
    WHERE score_comp_type_id = p_score_comp_type_id;
  l_metric_rating_id NUMBER;
  l_dummy VARCHAR2(1);
BEGIN
  OPEN c_rating;
  FETCH c_rating INTO l_dummy;
  IF c_rating%FOUND THEN
    UPDATE iex_metric_ratings
    SET low_from = p_low_from, low_to = p_low_to,
        medium_from = p_medium_from, medium_to = p_medium_to,
        high_from = p_high_from, high_to = p_high_to,
        last_update_date = SYSDATE, last_updated_by = fnd_global.user_id, last_update_login = fnd_global.login_id
    WHERE score_comp_type_id = p_score_comp_type_id;
  ELSE
    SELECT iex_metric_ratings_s.nextval
    INTO l_metric_rating_id
    FROM dual;

    INSERT INTO iex_metric_ratings(metric_rating_id, score_comp_type_id, low_from, low_to,
                    medium_from, medium_to, high_from, high_to,
                    creation_date, created_by, last_update_date, last_updated_by, last_update_login)
    VALUES (l_metric_rating_id, p_score_comp_type_id, p_low_from, p_low_to,
                    p_medium_from, p_medium_to, p_high_from, p_high_to,
                    SYSDATE, fnd_global.user_id, SYSDATE, fnd_global.user_id, fnd_global.user_id);
 END IF;
 CLOSE c_rating;
--EXCEPTION
  --WHEN OTHERS THEN
    --fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');
    --fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    --fnd_msg_pub.add;
END;

-- Begin kasreeni 12-16-2005 4887338
PROCEDURE checkUpgradeStrategies( x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_CheckStrategyGroups IS
    SELECT COUNT(1) FROM IEX_STRATEGY_TEMPLATES_B istl
      -- WHERE istl.strategy_temp_id >  10000 and NOT EXISTS (SELECT 1 FROM IEX_STRATEGY_TEMPLATE_GROUPS istg  -- bug 6067428
      WHERE istl.strategy_temp_id >=  10000 and NOT EXISTS (SELECT 1 FROM IEX_STRATEGY_TEMPLATE_GROUPS istg
          WHERE istg.STRATEGY_TEMP_ID = ISTL.STRATEGY_TEMP_ID);

   l_Upgrades NUMBER := 0;
BEGIN
   IEX_DEBUG_PUB.logmessage('IN checkUpgradeStrategie ');
   Open c_CheckStrategyGroups;
   FETCH C_CheckStrategyGroups INTO l_Upgrades;
   close c_CheckStrategyGroups;
   if l_Upgrades > 0 then
      IEX_DEBUG_PUB.logmessage('Inserting into StrategyGroups');
      INSERT INTO IEX_STRATEGY_TEMPLATE_GROUPS (
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        GROUP_ID,
        GROUP_NAME,
        STRATEGY_RANK,
        ENABLED_FLAG,
        CATEGORY_TYPE,
        CHANGE_STRATEGY_YN,
        CHECK_LIST_YN,
        CHECK_LIST_TEMP_ID,
        VALID_FROM_DT,
        VALID_TO_DT,
        OBJECT_FILTER_ID,
        STRATEGY_LEVEL,
        SCORE_TOLERANCE,
        STRATEGY_TEMP_ID
      )
      SELECT
        1,
        ISTL.CREATED_BY,
        ISTL.CREATION_DATE,
        ISTL.LAST_UPDATE_DATE,
        ISTL.LAST_UPDATED_BY,
        ISTL.LAST_UPDATE_LOGIN,
        ISTL.REQUEST_ID,
        ISTL.STRATEGY_TEMP_ID, -- IEX_STRATEGY_TEMPLATE_GROUPS_S.NEXTVAL, bug 9256394
        ISTL.STRATEGY_NAME,
        ISTL.STRATEGY_RANK,
        ISTL.ENABLED_FLAG,
        ISTL.CATEGORY_TYPE,
        ISTL.CHANGE_STRATEGY_YN,
        ISTL.CHECK_LIST_YN,
        ISTL.CHECK_LIST_TEMP_ID ,
        ISTL.VALID_FROM_DT,
        ISTL.VALID_TO_DT,
        ISTL.OBJECT_FILTER_ID,
        ISTL.STRATEGY_LEVEL,
        ISTL.SCORE_TOLERANCE,
        ISTL.STRATEGY_TEMP_ID
     FROM  IEX_STRATEGY_TEMPLATES_VL ISTL
     WHERE istl.strategy_temp_id >= 10000
        AND (istl.strategy_temp_group_id is NULL or istl.strategy_temp_group_id = 0)
        AND NOT EXISTS (SELECT 1 FROM IEX_STRATEGY_TEMPLATE_GROUPS istg
        WHERE istg.STRATEGY_TEMP_ID = ISTL.STRATEGY_TEMP_ID);

     UPDATE IEX_STRATEGY_TEMPLATES_b istl
        SET istl.STRATEGY_TEMP_GROUP_ID =
            (SELECT istg.GROUP_ID FROM IEX_STRATEGY_TEMPLATE_GROUPS istg
                WHERE istg.strategy_temp_id = istl.strategy_temp_id)
        WHERE istl.strategy_temp_id >= 10000
       AND (istl.strategy_temp_group_id is NULL  or istl.strategy_temp_group_id = 0);

     commit;

  end if;
  IEX_DEBUG_PUB.logmessage('End checkUpgradeStrategie ');
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
    fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;

END checkUpgradeStrategies;

-- End kasreeni 12-16-2005 4887338

PROCEDURE UPDATE_CHECKLIST_ITEM(
    p_checklist_item_id IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2) IS
  CURSOR c_general_info IS
    SELECT fnd_profile.value_specific('IEX_COLLECTIONS_BUCKET_NAME', -1, -1, -1, -1, -1) COLLECTIONS_BUCKET,
           fnd_profile.value_specific('IEX_ENABLE_CUST_STATUS_EVENT', -1, -1, -1, -1, -1) CUST_STATUS_EVENT,
           fnd_profile.value_specific('IEX_CUST_ACCESS', -1, -1, -1, -1, -1) WORK_QUEUE_ACCESS,
           fnd_profile.value_specific('IEX_ACCESS_LEVEL', -1, -1, -1, -1, -1) ACCESS_LEVEL,
           fnd_profile.value_specific('IEX_COLLECTIONS_RATE_TYPE', -1, -1, -1, -1, -1) RATE_TYPE
--           fnd_profile.value_specific('ACCOUNT_INTERACTION_ACTIVITY', -1, -1, -1, -1, -1) ACCOUNT_ACTIVITY,
--           fnd_profile.value_specific('IEX_DELINQUENCY_ACTIVITY', -1, -1, -1, -1, -1) DELINQUENCY_ACTIVITY,
--           fnd_profile.value_specific('DISPUTE_INTERACTION_ACTIVITY', -1, -1, -1, -1, -1) DISPUTE_ACTIVITY,
--           fnd_profile.value_specific('IEX_ADJUSTMENT_ACTIVITY', -1, -1, -1, -1, -1) ADJUSTMENT_ACTIVITY,
--           fnd_profile.value_specific('PAYMENT_INTERACTION_ACTIVITY', -1, -1, -1, -1, -1) PAYMENT_ACTIVITY,
--           fnd_profile.value_specific('PROMISE_INTERACTION_ACTIVITY', -1, -1, -1, -1, -1) PROMISE_ACTIVITY,
--           fnd_profile.value_specific('IEX_STRATEGY_ACTIVITY', -1, -1, -1, -1, -1) STRATEGY_ACTIVITY,
--           fnd_profile.value_specific('IEX_CREDIT_HOLD', -1, -1, -1, -1, -1) credit_hold,
--           fnd_profile.value_specific('IEX_SERVICE_HOLD', -1, -1, -1, -1, -1) service_hold_delin
    FROM dual;

  l_general_info_row c_general_info%ROWTYPE;
  l_status VARCHAR2(30);

  -- Bug 8479638 by ehuh 5/6/2009
  Cursor c_object_filter Is
    select obj.object_id,obj.object_filter_id,obj.last_updated_by,obj.last_update_login
      from iex_object_filters obj, iex_strategy_template_groups stg
      where stg.group_id = obj.object_id
        and obj.object_filter_type = 'IEXSTRAT'
        and obj.object_id > 10000
        and (stg.object_filter_id is null or stg.object_filter_id = 0);

BEGIN
  x_return_status := 'S';
  l_status := 'COMPLETE';

  IEX_DEBUG_PUB.logmessage('Update CheckList ' || p_checklist_item_id);

  -- Bug 8479638 by ehuh 5/6/2009
  For rec_object_filter IN c_object_filter LOOP
       update iex_strategy_template_groups
          set object_filter_id=rec_object_filter.object_filter_id,last_update_date=sysdate,last_updated_by=rec_object_filter.last_updated_by,last_update_login=rec_object_filter.last_update_login
          where group_id = rec_object_filter.object_id;
  End LOOP;

-- Begin kasreeni 12-16-2005 4887338
  if (p_checklist_item_id = 100 ) then
    IEX_DEBUG_PUB.logmessage('Calling checkUpgradeStrategie ');
     checkUpgradeStrategies(x_return_status);
     return ;
  end if;
-- End kasreeni 12-16-2005 4887338

  IF p_checklist_item_id = 3 THEN
    OPEN c_general_info;
    FETCH c_general_info INTO l_general_info_row;
    CLOSE c_general_info;

    IF l_general_info_row.collections_bucket IS NOT NULL AND
--       l_general_info_row.cust_status_event IS NOT NULL AND
       l_general_info_row.work_queue_access IS NOT NULL AND
       l_general_info_row.access_level IS NOT NULL AND
       l_general_info_row.rate_type IS NOT NULL
--       l_general_info_row.account_activity IS NOT NULL AND
--       l_general_info_row.delinquency_activity IS NOT NULL AND
--       l_general_info_row.dispute_activity IS NOT NULL AND
--       l_general_info_row.adjustment_activity IS NOT NULL AND
--       l_general_info_row.payment_activity IS NOT NULL AND
--       l_general_info_row.promise_activity IS NOT NULL AND
--       l_general_info_row.strategy_activity IS NOT NULL AND
--       l_general_info_row.credit_hold IS NOT NULL AND
--       l_general_info_row.service_hold_delin IS NOT NULL THEN
    THEN
      l_status := 'COMPLETE';
    ELSE
      l_status := 'INPROGRESS';
    END IF;

    iex_debug_pub.logmessage('l_status=' || l_status);

    UPDATE iex_checklist_items_b
    SET status = l_status, task_last_modified_date = SYSDATE, last_update_date = SYSDATE,
        last_updated_by = G_USER_ID, last_update_login = G_LOGIN_ID
    WHERE checklist_item_id = p_checklist_item_id;
  ELSE
    UPDATE iex_checklist_items_b
    SET status = l_status, task_last_modified_date = SYSDATE, last_update_date = SYSDATE,
        last_updated_by = G_USER_ID, last_update_login = G_LOGIN_ID
    WHERE checklist_item_id = p_checklist_item_id;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
END UPDATE_CHECKLIST_ITEM;

PROCEDURE CHANGE_LEASING_SETUP(
    p_leasing_enabled IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2) IS
  CURSOR c_resp IS
    SELECT  resp.application_id, resp.responsibility_id, resp.menu_id
    FROM fnd_responsibility resp, fnd_menus menu
    WHERE resp.menu_id = menu.menu_id
    AND menu.menu_name = 'IEX_COLLECTIONS_AGENT'
    -- Begin fix bug #4930424-remove TABLE ACCESS FULL
    AND resp.application_id = 695;
    -- End fix bug #4930424-remove TABLE ACCESS FULL

  CURSOR c_funct(p_responsibility_id NUMBER, p_function_name VARCHAR2) IS
    SELECT rf.action_id, ff.function_id
    FROM fnd_resp_functions rf, fnd_form_functions ff
    WHERE rf.responsibility_id(+) = p_responsibility_id
    AND ff.function_name = p_function_name
    AND rf.action_id(+) = ff.function_id
    AND rf.rule_type(+) = 'F';

  r_funct c_funct%ROWTYPE;
  l_function_name VARCHAR2(30);
  l_rowid VARCHAR(1000);

  CURSOR c_lookup IS
    SELECT lookup_type, lookup_code, meaning,
           description, enabled_flag, start_date_active, end_date_active,
           territory_code, attribute_category, attribute1, attribute2,
           attribute3, attribute4, attribute5, attribute6,
           attribute7, attribute8, attribute9, attribute10,
           attribute11, attribute12, attribute13, attribute14, attribute15,
           tag, security_group_id, view_application_id
    FROM fnd_lookup_values_vl
    WHERE (lookup_type = 'IEX_HISTORY_TYPE'
           AND lookup_code IN ('PAYMENT_CNSLD', 'PAYMENT_CONTRACT', 'PROMISE_CNSLD', 'PROMISE_CONTRACT'))
    OR (lookup_type = 'IEX_CNSLD');
  l_enabled_flag VARCHAR2(1);
BEGIN
  x_return_status := 'S';

  l_enabled_flag := NVL(p_leasing_enabled, 'N');

  IF l_enabled_flag = 'N' THEN
    FOR r_resp IN c_resp LOOP
      l_function_name := 'IEX_COLL_CNTR';
      iex_debug_pub.logmessage('r.resp.responsibility_id=' || r_resp.responsibility_id || ':l_function_name=' || l_function_name);
      OPEN c_funct(r_resp.responsibility_id, l_function_name);
      FETCH c_funct INTO r_funct;
      iex_debug_pub.logmessage('r_funct.action_id=' || r_funct.action_id || ':r_funct.function_id=' || r_funct.function_id);
      IF r_funct.action_id IS NULL THEN
        fnd_resp_functions_pkg.insert_row(x_rowid => l_rowid,
         x_application_id => r_resp.application_id,
         x_responsibility_id => r_resp.responsibility_id,
         x_action_id => r_funct.function_id,
         x_rule_type => 'F',
         x_creation_date => SYSDATE,
         x_created_by => 1,
         x_last_updated_by => 1,
         x_last_update_date => SYSDATE,
         x_last_update_login => 1);

         iex_debug_pub.logmessage('x_rowid=' || l_rowid);

      END IF;

      CLOSE c_funct;

      l_function_name := 'IEX_COLL_CASE';
      r_funct.action_id := NULL;
      r_funct.function_id := NULL;
      iex_debug_pub.logmessage('r.resp.responsibility_id=' || r_resp.responsibility_id || ':l_function_name=' || l_function_name);
      OPEN c_funct(r_resp.responsibility_id, l_function_name);
      FETCH c_funct INTO r_funct;
      iex_debug_pub.logmessage('r_funct.action_id=' || r_funct.action_id || ':r_funct.function_id=' || r_funct.function_id);
      IF r_funct.action_id IS NULL THEN
        fnd_resp_functions_pkg.insert_row(x_rowid => l_rowid,
         x_application_id => r_resp.application_id,
         x_responsibility_id => r_resp.responsibility_id,
         x_action_id => r_funct.function_id,
         x_rule_type => 'F',
         x_creation_date => SYSDATE,
         x_created_by => 1,
         x_last_updated_by => 1,
         x_last_update_date => SYSDATE,
         x_last_update_login => 1);

         iex_debug_pub.logmessage('x_rowid=' || l_rowid);
      END IF;

      CLOSE c_funct;
    END LOOP;
  ELSE
    FOR r_resp IN c_resp LOOP
      l_function_name := 'IEX_COLL_CNTR';
      iex_debug_pub.logmessage('r.resp.responsibility_id=' || r_resp.responsibility_id || ':l_function_name=' || l_function_name);
      OPEN c_funct(r_resp.responsibility_id, l_function_name);
      FETCH c_funct INTO r_funct;
      iex_debug_pub.logmessage('r_funct.action_id=' || r_funct.action_id || ':r_funct.function_id=' || r_funct.function_id);
      IF r_funct.action_id IS NOT NULL THEN
        fnd_resp_functions_pkg.delete_row(x_application_id => r_resp.application_id,
         x_responsibility_id => r_resp.responsibility_id,
         x_action_id => r_funct.action_id,
         x_rule_type => 'F');
      END IF;

      CLOSE c_funct;

      l_function_name := 'IEX_COLL_CASE';
      r_funct.action_id := NULL;
      r_funct.function_id := NULL;
      iex_debug_pub.logmessage('r.resp.responsibility_id=' || r_resp.responsibility_id || ':l_function_name=' || l_function_name);
      OPEN c_funct(r_resp.responsibility_id, l_function_name);
      FETCH c_funct INTO r_funct;
      iex_debug_pub.logmessage('r_funct.action_id=' || r_funct.action_id || ':r_funct.function_id=' || r_funct.function_id);
      IF r_funct.action_id IS NOT NULL THEN
        fnd_resp_functions_pkg.delete_row(x_application_id => r_resp.application_id,
         x_responsibility_id => r_resp.responsibility_id,
         x_action_id => r_funct.action_id,
         x_rule_type => 'F');

         iex_debug_pub.logmessage('x_rowid=' || l_rowid);
      END IF;

      CLOSE c_funct;
    END LOOP;
  END IF;

  FOR r_lookup IN c_lookup LOOP
    fnd_lookup_values_pkg.update_row(
      x_lookup_type => r_lookup.lookup_type,
      x_security_group_id => r_lookup.security_group_id,
      x_view_application_id => r_lookup.view_application_id,
      x_lookup_code => r_lookup.lookup_code,
      x_tag => r_lookup.tag,
      x_enabled_flag => l_enabled_flag,
      x_start_date_active => r_lookup.start_date_active,
      x_end_date_active => r_lookup.end_date_active,
      x_territory_code => r_lookup.territory_code,
      x_meaning => r_lookup.meaning,
      x_description => r_lookup.description,
      x_last_update_date => sysdate,
      x_last_updated_by => 1,
      x_last_update_login => 1,
      x_attribute_category=>r_lookup.attribute_category,
      x_attribute1=>r_lookup.attribute1,
      x_attribute2=>r_lookup.attribute2,
      x_attribute3=>r_lookup.attribute3,
      x_attribute4=>r_lookup.attribute4,
      x_attribute5=>r_lookup.attribute5,
      x_attribute6=>r_lookup.attribute6,
      x_attribute7=>r_lookup.attribute7,
      x_attribute8=>r_lookup.attribute8,
      x_attribute9=>r_lookup.attribute9,
      x_attribute10=>r_lookup.attribute10,
      x_attribute11=>r_lookup.attribute11,
      x_attribute12=>r_lookup.attribute12,
      x_attribute13=>r_lookup.attribute13,
      x_attribute14=>r_lookup.attribute14,
      x_attribute15=>r_lookup.attribute15
    );
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
    fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;
END CHANGE_LEASING_SETUP;

PROCEDURE CHANGE_LOAN_SETUP(
    p_loan_enabled IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2) IS
  CURSOR c_resp IS
    SELECT  resp.application_id, resp.responsibility_id, resp.menu_id
    FROM fnd_responsibility resp, fnd_menus menu
    WHERE resp.menu_id = menu.menu_id
    AND menu.menu_name = 'IEX_COLLECTIONS_AGENT'
    -- Begin fix bug #4930424-remove TABLE ACCESS FULL
    AND resp.application_id = 695;
    -- End fix bug #4930424-remove TABLE ACCESS FULL

  CURSOR c_funct(p_responsibility_id NUMBER, p_function_name VARCHAR2) IS
    SELECT rf.action_id, ff.function_id
    FROM fnd_resp_functions rf, fnd_form_functions ff
    WHERE rf.responsibility_id(+) = p_responsibility_id
    AND ff.function_name = p_function_name
    AND rf.action_id(+) = ff.function_id
    AND rf.rule_type(+) = 'F';

-- Begin by Ehuh to fix a bug 4639561
  CURSOR get_function_id IS
    Select function_id from fnd_form_functions
      where function_name = 'IEX_COLL_LOAN';

  CURSOR get_menu_id IS
    Select menu_id from fnd_menus
      where menu_name = 'IEX_COLL';

  CURSOR get_entry_sequence(p_menu_id NUMBER, p_function_id NUMBER) IS
    Select entry_sequence from fnd_menu_entries
      where menu_id = p_menu_id
        and function_id = p_function_id;

  l_entry_sequence number := 0;
  l_menu_id        number := 0;
  l_func_id        number := 0;
-- End to fix bug 4639561

  r_funct c_funct%ROWTYPE;
  l_function_name VARCHAR2(30);
  l_rowid VARCHAR(1000);

  l_enabled_flag VARCHAR2(1);
BEGIN
  x_return_status := 'S';

  l_enabled_flag := NVL(p_loan_enabled, 'N');

  IF l_enabled_flag = 'N' THEN
    FOR r_resp IN c_resp LOOP
      l_function_name := 'IEX_COLL_LOAN';
      iex_debug_pub.logmessage('r.resp.responsibility_id=' || r_resp.responsibility_id || ':l_function_name=' || l_function_name);
      OPEN c_funct(r_resp.responsibility_id, l_function_name);
      FETCH c_funct INTO r_funct;
      iex_debug_pub.logmessage('r_funct.action_id=' || r_funct.action_id || ':r_funct.function_id=' || r_funct.function_id);
      IF r_funct.action_id IS NULL THEN
        fnd_resp_functions_pkg.insert_row(x_rowid => l_rowid,
         x_application_id => r_resp.application_id,
         x_responsibility_id => r_resp.responsibility_id,
         x_action_id => r_funct.function_id,
         x_rule_type => 'F',
         x_creation_date => SYSDATE,
         x_created_by => 1,
         x_last_updated_by => 1,
         x_last_update_date => SYSDATE,
         x_last_update_login => 1);

         iex_debug_pub.logmessage('x_rowid=' || l_rowid);

      END IF;

      CLOSE c_funct;
    END LOOP;
  ELSE
    FOR r_resp IN c_resp LOOP
      l_function_name := 'IEX_COLL_LOAN';
      iex_debug_pub.logmessage('r.resp.responsibility_id=' || r_resp.responsibility_id || ':l_function_name=' || l_function_name);
      OPEN c_funct(r_resp.responsibility_id, l_function_name);
      FETCH c_funct INTO r_funct;
      iex_debug_pub.logmessage('r_funct.action_id=' || r_funct.action_id || ':r_funct.function_id=' || r_funct.function_id);
      IF r_funct.action_id IS NOT NULL THEN
        fnd_resp_functions_pkg.delete_row(x_application_id => r_resp.application_id,
         x_responsibility_id => r_resp.responsibility_id,
         x_action_id => r_funct.action_id,
         x_rule_type => 'F');
      END IF;

      CLOSE c_funct;
    END LOOP;
  END IF;

-- Begin by Ehuh to fix a bug 4639561
   Begin
     OPEN  get_function_id;
     FETCH get_function_id into l_func_id;
     iex_debug_pub.logmessage('Function ID = '||l_func_id);

     if get_function_id%NOTFOUND then
        iex_debug_pub.logmessage('NOt found FUNCTION  ID  ');
        null;
     end if;

     close get_function_id;

     OPEN  get_menu_id;
     FETCH get_menu_id into l_menu_id;

     if get_menu_id%NOTFOUND then
        iex_debug_pub.logmessage('NOt found MENU  ID  ');
        null;
     end if;

     close get_menu_id;

     if (l_menu_id <> 0) and (l_func_id <> 0) then
        OPEN get_entry_sequence(l_menu_id , l_func_id );
        FETCH get_entry_sequence into l_entry_sequence;

        if get_entry_sequence%NOTFOUND then
           iex_debug_pub.logmessage('NOt found ENTRY SEQ    ');
           null;
        end if;

        close get_entry_sequence;

        FND_MENU_ENTRIES_PKG.update_row(
                          x_menu_id => l_menu_id,
                          x_entry_sequence => l_entry_sequence,
                          x_sub_menu_id => null,
                          x_function_id => l_func_id,
                          x_grant_flag => l_enabled_flag,
                          x_prompt => null,
                          x_description => null,
                          x_last_update_date => SYSDATE,
                          x_last_updated_by  => 1,
                          x_last_update_login => 1 );
     end if;

 Exception
  When others then
     iex_debug_pub.logmessage('Exceptopn  ');
     null;
 End;
-- End to fix bug 4639561

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
    fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;
END CHANGE_LOAN_SETUP;

PROCEDURE CHANGE_BUSINESS_LEVEL(p_business_level IN VARCHAR2,
                                p_promise_enabled IN VARCHAR2,
                                p_collections_methods IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2) IS
  CURSOR c_resp IS
    SELECT  resp.application_id, resp.responsibility_id, resp.menu_id, resp.responsibility_key
    FROM fnd_responsibility resp
    WHERE resp.application_id = 695;
  l_return BOOLEAN;
  l_promise_enabled VARCHAR2(1);
  l_strategy_enabled VARCHAR2(1);
  l_business_level VARCHAR2(30);
  l_str_levels number; -- Changed for bug 8708271 pnaveenk multi level strategy
BEGIN
  x_return_status := 'S';
  l_business_level := p_business_level;
  l_promise_enabled := NVL(p_promise_enabled, 'Y');
  IF NVL(p_collections_methods, 'DUNNING') = 'DUNNING' THEN
    l_strategy_enabled := 'N';
  ELSE
    l_strategy_enabled := 'Y';
  END IF;

  iex_debug_pub.logmessage('Starting ....');

  iex_debug_pub.logmessage('l_promise_enabled=' || l_promise_enabled || ': l_strategy_enabled=' || l_strategy_enabled);

  -- Start bug 7454867
  begin
    iex_debug_pub.logmessage('Starting Update menu for Stategy Tab based on Questionnaire ....');
    iex_debug_pub.logmessage('p_collections_methods...... '||p_collections_methods);

    if  p_collections_methods = 'STRATEGIES' then
       update fnd_menu_entries set grant_flag = 'Y' where menu_id = 1006151 and function_id = 1011354;
    else
       update fnd_menu_entries set grant_flag = 'N' where menu_id = 1006151 and function_id = 1011354;
    end if;
    exception
       when others then
          null;
          iex_debug_pub.logmessage('Exception ....Starting Update menu for Stategy Tab based on Questionnaire');
  end;
  -- End bug 7454867

  -- Start for bug 8708271 pnaveenk multi level strategy
  Begin

  SELECT count(*)
  INTO l_str_levels
  FROM IEX_LOOKUPS_V
  WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
  AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';
  Exception
    when others then
      iex_debug_pub.logmessage( 'Exception in finding number of strategy levels being used');
  End;

  IF l_str_levels > 1 then
     iex_debug_pub.logmessage(' Multi level strategy is being used. No need to setup profiles here.');
     return;
  End if;

  -- End for bug 8708271 pnaveenk
  -- Begin fix bug #5142565-JYPARK-Change site level profile too
  IF l_business_level = 'CUSTOMER' THEN
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
                      x_value => l_strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
  ELSIF l_business_level = 'ACCOUNT' THEN
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
                      x_value => l_Strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
  ELSIF l_business_level = 'BILL_TO' THEN
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
                      x_value => l_Strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
  ELSIF l_business_level = 'DELINQUENCY' THEN
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
    l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
                      x_value => l_Strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
  END IF;
  -- End fix bug #5142565-JYPARK-Change site level profile too

  -- Begin fix bug #5142565-JYPARK-remove change profile at resp level
--  FOR r_resp IN c_resp LOOP
--    iex_debug_pub.logmessage('responsibility_key=' || r_resp.responsibility_key);
--    IF l_business_level = 'CUSTOMER' THEN
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
--                        x_value => 'Y',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
--                        x_value => l_promise_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
--                        x_value => l_strategy_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--    ELSIF l_business_level = 'ACCOUNT' THEN
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
--                        x_value => 'Y',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
--                        x_value => l_promise_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
--                        x_value => l_Strategy_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--    ELSIF l_business_level = 'BILL_TO' THEN
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
--                        x_value => 'Y',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
--                        x_value => l_promise_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
--                        x_value => l_Strategy_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--    ELSIF l_business_level = 'DELINQUENCY' THEN
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
--                        x_value => 'Y',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
--                        x_value => l_promise_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
--                        x_value => 'N',
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--      l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
--                        x_value => l_Strategy_enabled,
--                        x_level_name => 'RESP',
--                        x_level_value => r_resp.responsibility_id,
--                        x_level_value_app_id => '695',
--                        x_level_value2 => null);
--    END IF;
--  END LOOP;
  -- End fix bug #5142565-JYPARK-remove change profile at resp level
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
    fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;
END CHANGE_BUSINESS_LEVEL;


PROCEDURE UPDATE_CHECKLIST_ITEM_BY_NAME(
    p_checklist_item_name IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2) IS
  CURSOR c_checklist IS
    SELECT checklist_item_id
    FROM iex_checklist_items_b
    WHERE checklist_item_name = p_checklist_item_name;

  l_checklist_item_id NUMBER;
BEGIN
  OPEN c_checklist;
  FETCH c_checklist INTO l_checklist_item_id;
  CLOSE c_checklist;


  update_checklist_item(l_checklist_item_id, x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
    fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');

    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);

    fnd_msg_pub.add;
END UPDATE_CHECKLIST_ITEM_BY_NAME;

-- Start for bug 8708271 pnaveenk multi level strategy
PROCEDURE CHANGE_MULTIPLE_LEVEL(
    p_account_level IN VARCHAR2,
    p_billto_level IN VARCHAR2,
    p_customer_level IN VARCHAR2,
    p_delinquency_level IN VARCHAR2,
    p_override_party_level IN VARCHAR2,
    p_ou_running_level IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2) IS

    l_return BOOLEAN;
    l_promise_enabled varchar2(1);
    l_strategy_enabled varchar2(1);
    p_promise_enabled varchar2(1);
    p_collections_methods varchar2(20);

    cursor c_promise_str is
    select promise_enabled, collections_methods
    from iex_questionnaire_items;

BEGIN

    open c_promise_str;
    fetch c_promise_str into p_promise_enabled,p_collections_methods;
    close c_promise_str;

    l_promise_enabled := NVL(p_promise_enabled, 'Y');
    IF NVL(p_collections_methods, 'DUNNING') = 'DUNNING' THEN
    l_strategy_enabled := 'N';
    ELSE
    l_strategy_enabled := 'Y';
    END IF;

    iex_debug_pub.logmessage(' Start IEX_CHECKLIST_UTILITY.CHANGE_MULTIPLE_LEVEL procedure. Setting profiles');
    iex_debug_pub.logmessage (' Values of levels set -- Customer Level' || p_customer_level || 'Account Level' || p_account_level || 'BillTo Level' || p_billto_level);
    iex_debug_pub.logmessage ( ' Delinquency Level ' || p_delinquency_level || 'Party Override' || p_override_party_level || 'Operating Unit Override' || p_ou_running_level);
    iex_debug_pub.logmessage ( ' Promise enabled ' || l_promise_enabled || 'Strategy enabled ' || l_strategy_enabled);

    IF p_customer_level = 'Y' then
       l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
                                    x_value => 'Y',
                                    x_level_name => 'SITE',
                                    x_level_value => null,
                                    x_level_value_app_id => '',
                                    x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Customer View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Customer View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
                      x_value => l_strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Customer View Strategies.');
       END IF;
    ELSE
       l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_DELINQUENCIES',
                                    x_value => 'N',
                                    x_level_name => 'SITE',
                                    x_level_value => null,
                                    x_level_value_app_id => '',
                                    x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Customer View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Customer View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_CUST_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Customer View Strategies.');
       END IF;

    END IF;

    IF p_account_level = 'Y' then
       l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Account View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Account View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
                      x_value => l_Strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Account View Strategies.');
       END IF;

    ELSE
       l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Account View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Account View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_ACC_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Account View Strategies.');
       END IF;
    END IF;

     IF p_billto_level = 'Y' then
       l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Bill-to View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Bill-to View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
                      x_value => l_Strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Bill-to View Strategies.');
       END IF;

      ELSE

       l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Bill-to View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Bill-to View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_BILLTO_STRATEGIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Bill-to View Strategies.');
       END IF;

    END IF;

    IF p_delinquency_level = 'Y' then
       l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Delinquency View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
                      x_value => l_promise_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Delinquency View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
                      x_value => l_Strategy_enabled,
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Delinquency View Strategies.');
       END IF;

     ELSE

       l_return := fnd_profile.save(x_name => 'IEX_QEN_DELINQUENCIES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Delinquency View Delinquencies.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_PROMISES',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Delinquency View Promises.');
       END IF;
       l_return := fnd_profile.save(x_name => 'IEX_QEN_STRATEGY',
                      x_value => 'N',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEU: Queue: Delinquency View Strategies.');
       END IF;

    END IF;

    IF p_ou_running_level = 'Y' then
    l_return := fnd_profile.save(x_name => 'IEX_PROC_STR_ORG',
                      x_value => 'Y',
                      x_level_name => 'SITE',
                      x_level_value => null,
                      x_level_value_app_id => '',
                      x_level_value2 => null);
       IF l_return = FALSE then
           iex_debug_pub.logmessage('Failed to set the profile IEX: Process Strategies by Operating Unit.');
       END IF;
    END IF;
    x_return_status := 'S';
    iex_debug_pub.logmessage(' End procedure IEX_CHECKLIST_UTILITY.CHANGE_MULTIPLE_LEVEL . Successfully set the profile values');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'F';
    fnd_message.set_name ('IEX', 'IEX_ADMIN_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
    fnd_msg_pub.add;


END CHANGE_MULTIPLE_LEVEL;

PROCEDURE UPDATE_MLSETUP IS

cursor c_questionnaire_details is
select business_level, using_customer_level, using_account_level, using_billto_level,
using_delinquency_level, define_ou_running_level , define_party_running_level
from iex_questionnaire_items;

l_business_level varchar2(20);
l_using_customer_level  varchar2(1);
l_using_account_level varchar2(1);
l_using_billto_level varchar2(1);
l_using_delinquency_level varchar2(1);
l_define_ou_running_level varchar2(1);
l_define_party_running_level varchar2(1);
c_str_upd varchar2(2000);
l_count number;

 l_last_updated_by       number  := FND_GLOBAL.USER_ID;
 l_last_update_login     number := nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),0);


Begin

    open c_questionnaire_details;
    fetch c_questionnaire_details into l_business_level,l_using_customer_level,l_using_account_level,l_using_billto_level,
    l_using_delinquency_level,l_define_ou_running_level,l_define_party_running_level;
    close c_questionnaire_details;
    iex_debug_pub.logmessage(' In procedure IEX_CHECKLIST_UTILITY.UPDATE_MLSETUP  Begin updating multi level strategy set up in questionnaire table');

    c_str_upd := 'update iex_questionnaire_items set ';
    l_count := 0;

    IF l_using_customer_level is null then

       if l_business_level = 'CUSTOMER' then
       c_str_upd := c_str_upd || ' using_customer_level = ''Y'' ';
       else
       c_str_upd := c_str_upd || ' using_customer_level = ''N'' ';
       end if;
       l_count := l_count + 1;

    END IF;

    IF l_using_account_level is null then
       if l_count > 0 then
       c_str_upd := c_str_upd || ' , ';
       end if;
       if l_business_level = 'ACCOUNT' then
       c_str_upd := c_str_upd || ' using_account_level = ''Y'' ';
       else
       c_str_upd := c_str_upd || ' using_account_level = ''N'' ';
       end if;
       l_count := l_count + 1;

    END IF;

    IF l_using_billto_level is null then
       if l_count > 0 then
       c_str_upd := c_str_upd || ' , ';
       end if;
       if l_business_level = 'BILL_TO' then
       c_str_upd := c_str_upd || ' using_billto_level = ''Y'' ';
       else
       c_str_upd := c_str_upd || ' using_billto_level = ''N'' ';
       end if;
       l_count := l_count + 1;

    END IF;

    IF l_using_delinquency_level is null then
       if l_count > 0 then
       c_str_upd := c_str_upd || ' , ';
       end if;
       if l_business_level = 'DELINQUENCY' then
       c_str_upd := c_str_upd || ' using_delinquency_level = ''Y'' ';
       else
       c_str_upd := c_str_upd || ' using_delinquency_level = ''N'' ';
       end if;
       l_count := l_count + 1;

    END IF;

    IF l_define_ou_running_level is null then
       if l_count > 0 then
       c_str_upd := c_str_upd || ' , ';
       end if;
       if l_business_level = 'DELINQUENCY' then
       c_str_upd := c_str_upd || ' define_ou_running_level = ''Y'' ';
       else
       c_str_upd := c_str_upd || ' define_ou_running_level = ''N'' ';
       end if;
       l_count := l_count + 1;

    END IF;

    IF l_define_party_running_level is null then
       if l_count > 0 then
       c_str_upd := c_str_upd || ' , ';
       end if;
       if l_business_level = 'DELINQUENCY' then
       c_str_upd := c_str_upd || ' define_party_running_level = ''Y'' ';
       else
       c_str_upd := c_str_upd || ' define_party_running_level = ''N'' ';
       end if;
       l_count := l_count + 1;

    END IF;
     Begin
     IF l_count > 0 then

      c_str_upd := c_str_upd || ' , last_update_date = sysdate  , last_updated_by = ' || l_last_updated_by || ' , last_update_login = ' || l_last_update_login;
      iex_debug_pub.logmessage( ' Update Statement constructed before execution ' || c_str_upd);
      execute immediate c_str_upd;
      commit;
     END IF;

     Exception
      when others then
       iex_debug_pub.logmessage( ' Exception in executing SQL statement ' );
     End;
    iex_debug_pub.logmessage('End Procedure IEX_CHECKLIST_UTILITY.UPDATE_MLSETUP updating multi level set up in questionnaire table');

    Exception
    When Others then
     iex_debug_pub.logmessage( ' Exception in updating ml set up' ||  ' sqlcode = ' || sqlcode || ' sqlerrm = ' || sqlerrm);

End  UPDATE_MLSETUP;


-- End for bug 8708271 multi level strategy

BEGIN
  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
  G_APPL_ID               := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID              := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID            := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID               := FND_GLOBAL.User_Id;
  G_REQUEST_ID            := FND_GLOBAL.Conc_Request_Id;
END IEX_CHECKLIST_UTILITY;

/
