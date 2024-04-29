--------------------------------------------------------
--  DDL for Package Body CSM_PROFILE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PROFILE_EVENT_PKG" AS
/* $Header: csmeprfb.pls 120.22.12010000.6 2009/09/29 07:10:16 trajasek ship $ */

g_pub_item VARCHAR2(30) := 'CSF_M_PROFILES';

FUNCTION get_all_omfs_resp_palm_users(p_responsibility_id IN NUMBER)
RETURN 	 asg_download.user_list
IS
i NUMBER;
l_all_omfs_palm_users_list asg_download.user_list;

CURSOR l_omfs_resp_palm_users_csr(p_resp_id IN number)
IS
SELECT au.user_id
FROM   asg_user_pub_resps aupr,
       asg_user au
WHERE  aupr.pub_name = 'SERVICEP'
AND    aupr.responsibility_id = p_resp_id
AND    au.user_name = aupr.user_name;

BEGIN
  i := 0;
  FOR r_omfs_resp_palm_users_rec IN l_omfs_resp_palm_users_csr(p_responsibility_id) LOOP
  		i := i + 1;
        l_all_omfs_palm_users_list(i) := r_omfs_resp_palm_users_rec.user_id;
  END LOOP;

  RETURN l_all_omfs_palm_users_list;

END get_all_omfs_resp_palm_users;

PROCEDURE insert_profiles_acc(p_access_id IN number, p_user_id IN number, p_application_id IN number,
                              p_profile_option_id IN number, p_level_id IN number,
                              p_level_value IN number, p_level_value_application_id IN number,
                              p_profile_option_value IN varchar2, p_creation_date IN date)
IS
BEGIN
  INSERT INTO csm_profile_option_values_acc(access_id,
                                            user_id,
                                            application_id,
                                            profile_option_id,
                                            level_id,
                                            level_value,
                                            level_value_application_id,
                                            profile_option_value,
                                            created_by,
                                            creation_date,
                                            last_updated_by,
                                            last_update_date,
                                            last_update_login
                                            )
                                    VALUES (p_access_id,
                                            p_user_id,
                                            p_application_id,
                                            p_profile_option_id,
                                            p_level_id,
                                            p_level_value,
                                            p_level_value_application_id,
                                            p_profile_option_value,
                                            fnd_global.user_id,
                                            p_creation_date,
                                            fnd_global.user_id,
                                            p_creation_date,
                                            fnd_global.login_id
                                            );

EXCEPTION
 WHEN OTHERS THEN
    RAISE;
END insert_profiles_acc;

/**
Refreshes the CSM_PROFILE_VALUES_ACC table, and marks dirty for users accordingly
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag     09/23/02 Added conditions for JTM_CREDIT_CARD_ENABLED in the cursor
                       where clauses
*/
PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_pub_item          varchar2(30) := 'CSF_M_PROFILES';
l_prog_update_date  jtm_con_request_data.last_run_date%TYPE;
l_access_id         jtm_fnd_lookups_acc.access_id%TYPE;
l_user_id           fnd_user.user_id%TYPE;
l_resp_id           fnd_responsibility.responsibility_id%TYPE;
l_app_id            fnd_application.application_id%TYPE;
l_markdirty         boolean;
l_all_omfs_palm_user_list asg_download.user_list;
l_null_user_list          asg_download.user_list;
l_single_access_id_list   asg_download.access_list;
--a null list
l_null_access_list        asg_download.access_list;
l_run_date  date;
l_sqlerrno  varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM   jtm_con_request_data
WHERE  package_name   = 'CSM_PROFILE_EVENT_PKG'
AND    procedure_name = 'REFRESH_ACC';

--Bug 5257429
/*WHENEVER A NEW PROFILE IS ADDED TO INSERT CURSOR, PLEASE DON'T FORGET TO ADD
THAT PROFILE TO C_PURGE CURSOR WHICH WILL OTHERWISE REMOVE IT*/
--Cursor to insert all profiles(without profile value)
CURSOR l_profiles_wovalue_ins_csr
IS
SELECT csm_profiles_acc_s.NEXTVAL as ACCESS_ID, au.user_id ,
       opt.profile_option_id,  opt.application_id
FROM   fnd_profile_options opt,
       ASG_USER au
WHERE (opt.profile_option_name = 'CSF_M_RECIPIENTS_BOUNDARY'
  OR opt.profile_option_name = 'CSF_MOBILE_TASK_TIMES_UPDATABLE'
  OR opt.profile_option_name = 'CSF_DEBRIEF_OVERLAPPING_LABOR'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_SEVERITY'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_URGENCY'
  OR opt.profile_option_name  = 'JTF_TIME_UOM_CLASS'
  OR opt.profile_option_name  = 'ICX_PREFERRED_CURRENCY'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'
  OR opt.profile_option_name  = 'CS_SR_RESTRICT_IB'
  OR opt.profile_option_name  = 'SERVER_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CLIENT_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CSF_BUSINESS_PROCESS'
  OR opt.profile_option_name  = 'CSM_SEARCH_RESULT_SET_SIZE'
  OR opt.profile_option_name  = 'CSM_IB_ITEMS_AT_LOCATION'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_SET_FILTER'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_FILTER'
  OR opt.profile_option_name  = 'CS_INV_VALIDATION_ORG'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_TYPE'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_STATUS'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_SR'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_TASK'
  OR opt.profile_option_name  = 'CSM_ENABLE_UPDATE_ASSIGNMENTS'
  OR opt.profile_option_name  = 'CSM_ENABLE_VIEW_CUST_PRODUCTS'
  OR opt.profile_option_name  = 'CSM_MAX_READINGS_PER_COUNTER'
  OR opt.profile_option_name = 'CSF_RETURN_REASON'
  OR opt.profile_option_name  = 'CSFW_DEFAULT_DISTANCE_UNIT'
  OR opt.profile_option_name  = 'CSF_CAPTURE_TRAVEL'
  OR opt.profile_option_name  = 'CSM_LABOR_LINE_TOTAL_CHECK'   --new CSM profile, obsoleted CSL profile
  OR opt.profile_option_name  = 'ICX_DATE_FORMAT_MASK'
  OR opt.profile_option_name  = 'JTM_TIMEPICKER_FORMAT'
  OR opt.profile_option_name  = 'CSM_TIME_REASONABILITY_CHECK_APPLY' --new CSM profile, obsoleted CSL profile
  OR opt.profile_option_name  = 'ICX_NUMERIC_CHARACTERS'
  OR opt.profile_option_name  = 'CSF_LABOR_DEBRIEF_DEFAULT_UOM'
  OR opt.profile_option_name  = 'CSF_UOM_HOURS'
  OR opt.profile_option_name  = 'CSZ_DEFAULT_CONTACT_BY'
  OR opt.profile_option_name  = 'HZ_REF_TERRITORY'
  OR opt.profile_option_name  = 'HZ_REF_LANG'
  OR opt.profile_option_name  = 'HZ_LANG_FOR_COUNTRY_DISPLAY'
  OR opt.profile_option_name  = 'CSM_MAX_ATTACHMENT_SIZE'  --For PPC
  OR opt.profile_option_name  = 'CSF_UOM_MINUTES'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_STATUS_PERSONAL'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_TYPE_PERSONAL'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF TRANSACTION TYPE'
  OR opt.profile_option_name  = 'INV:EXPENSE_TO_ASSET_TRANSFER'
  OR opt.profile_option_name  = 'JTF_PROFILE_DEFAULT_CURRENCY'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_ASSIGNED_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_PRIORITY'
  OR opt.profile_option_name  = 'CSFW_PLANNED_TASK_WINDOW'
  OR opt.profile_option_name  = 'CS_SR_CONTACT_MANDATORY'
  OR opt.profile_option_name  = 'CSM_RESTRICT_DEBRIEF'
  OR opt.profile_option_name  = 'CSM_RESTRICT_ORDERS'
  OR opt.profile_option_name  = 'CSM_RESTRICT_TRANSFERS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_TYPE'
  OR opt.profile_option_name  = 'CSM_ACCOUNT_MESSAGE_INTERCEPTION'
  OR opt.profile_option_name  = 'CSM_AS_DATA_DOWNLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_AS_DATA_UPLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_ENABLE_AS_STATUS_NFN'
  OR opt.profile_option_name  = 'CSM_NFN_SYNC_ERROR'
  OR opt.profile_option_name  = 'CSM_NOTIFY_DEFERRED'
  OR opt.profile_option_name  = 'CSF_MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_MANDATORY_RESOLUTION_CODE'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_RESTRICT_SERVICE_REQUEST_CREATION_ TO_ SCHEDULED_SITES'
  OR opt.profile_option_name  = 'CSM_WIRELESS_URL'
  OR opt.profile_option_name  = 'CSM_ONLINE_ACCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_DEFAULT_DEBRIEF_SAC_TRAVEL'
  OR opt.profile_option_name  = 'CSM_ALLOW_FREE_FORM_IB'
  OR opt.profile_option_name  = 'CSF: MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_DEBRIEF_LABOR_SAC'
  )
AND NVL(opt.start_date_active, SYSDATE) <= SYSDATE
AND NVL(opt.end_date_active,   SYSDATE) >= SYSDATE
AND NOT EXISTS
(SELECT 1
 FROM csm_profile_option_values_acc acc
 WHERE acc.profile_option_id  = opt.profile_option_id
 AND acc.application_id       = opt.application_id
 AND acc.user_id              = au.user_id
);
-- get the profiles with values to be inserted
CURSOR l_profiles_ins_csr(p_last_upd_date date,
                          p_csm_appl_id fnd_application.application_id%TYPE,
                          p_csm_resp_id fnd_responsibility.responsibility_id%TYPE)
IS
SELECT val.application_id, val.profile_option_id, val.level_id, val.level_value,
       val.level_value_application_id, val.profile_option_value, opt.profile_option_name
FROM   fnd_profile_options opt,
       fnd_profile_option_values val
WHERE (opt.profile_option_name = 'CSF_M_RECIPIENTS_BOUNDARY'
--  OR opt.profile_option_name = 'CSF_M_AGENDA_ALLOWCHANGESCOMPLETEDTASK'   ---end_dated
  OR opt.profile_option_name = 'CSF_MOBILE_TASK_TIMES_UPDATABLE'
  OR opt.profile_option_name = 'CSF_DEBRIEF_OVERLAPPING_LABOR'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_SEVERITY'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_URGENCY'
  OR opt.profile_option_name  = 'JTF_TIME_UOM_CLASS'
  OR opt.profile_option_name  = 'ICX_PREFERRED_CURRENCY'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'
  OR opt.profile_option_name  = 'CS_SR_RESTRICT_IB'
  OR opt.profile_option_name  = 'SERVER_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CLIENT_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CSF_BUSINESS_PROCESS'
  OR opt.profile_option_name  = 'CSM_SEARCH_RESULT_SET_SIZE'
  OR opt.profile_option_name  = 'CSM_IB_ITEMS_AT_LOCATION'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_SET_FILTER'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_FILTER'
  OR opt.profile_option_name  = 'CS_INV_VALIDATION_ORG'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_TYPE'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_STATUS'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_SR'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_TASK'
  OR opt.profile_option_name  = 'CSM_ENABLE_UPDATE_ASSIGNMENTS'
  OR opt.profile_option_name  = 'CSM_ENABLE_VIEW_CUST_PRODUCTS'
  OR opt.profile_option_name  = 'CSM_MAX_READINGS_PER_COUNTER'
  OR opt.profile_option_name = 'CSF_RETURN_REASON'
  --R 12 updates
  OR opt.profile_option_name  = 'CSFW_DEFAULT_DISTANCE_UNIT'
  OR opt.profile_option_name  = 'CSF_CAPTURE_TRAVEL'
  OR opt.profile_option_name  = 'CSM_LABOR_LINE_TOTAL_CHECK'   --new CSM profile, obsoleted CSL profile
  OR opt.profile_option_name  = 'ICX_DATE_FORMAT_MASK'
  OR opt.profile_option_name  = 'JTM_TIMEPICKER_FORMAT'
  OR opt.profile_option_name  = 'CSM_TIME_REASONABILITY_CHECK_APPLY' --new CSM profile, obsoleted CSL profile
  OR opt.profile_option_name  = 'ICX_NUMERIC_CHARACTERS'
  OR opt.profile_option_name  = 'CSF_LABOR_DEBRIEF_DEFAULT_UOM'
  OR opt.profile_option_name  = 'CSF_UOM_HOURS'
  OR opt.profile_option_name  = 'CSZ_DEFAULT_CONTACT_BY'
  OR opt.profile_option_name  = 'HZ_REF_TERRITORY'
  OR opt.profile_option_name  = 'HZ_REF_LANG'
  OR opt.profile_option_name  = 'HZ_LANG_FOR_COUNTRY_DISPLAY'
  OR opt.profile_option_name  = 'CSM_MAX_ATTACHMENT_SIZE'  --For PPC
  OR opt.profile_option_name  = 'CSF_UOM_MINUTES'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_STATUS_PERSONAL'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_TYPE_PERSONAL'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF TRANSACTION TYPE'
  OR opt.profile_option_name  = 'INV:EXPENSE_TO_ASSET_TRANSFER'
  OR opt.profile_option_name  = 'JTF_PROFILE_DEFAULT_CURRENCY'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_ASSIGNED_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_PRIORITY'
  OR opt.profile_option_name  = 'CSFW_PLANNED_TASK_WINDOW'
  OR opt.profile_option_name  = 'CS_SR_CONTACT_MANDATORY'
  OR opt.profile_option_name  = 'CSM_RESTRICT_DEBRIEF'
  OR opt.profile_option_name  = 'CSM_RESTRICT_ORDERS'
  OR opt.profile_option_name  = 'CSM_RESTRICT_TRANSFERS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_TYPE'
  OR opt.profile_option_name  = 'CSM_ACCOUNT_MESSAGE_INTERCEPTION'
  OR opt.profile_option_name  = 'CSM_AS_DATA_DOWNLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_AS_DATA_UPLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_ENABLE_AS_STATUS_NFN'
  OR opt.profile_option_name  = 'CSM_NFN_SYNC_ERROR'
  OR opt.profile_option_name  = 'CSM_NOTIFY_DEFERRED'
  OR opt.profile_option_name  = 'CSF_MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_MANDATORY_RESOLUTION_CODE'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_RESTRICT_SERVICE_REQUEST_CREATION_ TO_ SCHEDULED_SITES'
  OR opt.profile_option_name  = 'CSM_WIRELESS_URL'
  OR opt.profile_option_name  = 'CSM_ONLINE_ACCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_DEFAULT_DEBRIEF_SAC_TRAVEL'
  OR opt.profile_option_name  = 'CSM_ALLOW_FREE_FORM_IB'
  OR opt.profile_option_name  = 'CSF: MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_DEBRIEF_LABOR_SAC'
  )
AND val.application_id = opt.application_id
AND val.profile_option_id = opt.profile_option_id
AND NVL(opt.start_date_active, SYSDATE) <= SYSDATE
AND NVL(opt.end_date_active,   SYSDATE) >= SYSDATE
AND (  (val.level_id = 10001)
    OR (val.level_id = 10004 AND val.level_value IN (SELECT USER_ID FROM ASG_USER WHERE ENABLED= 'Y'))
    OR (val.level_id = 10002 AND val.level_value = p_csm_appl_id)
    OR (val.level_id = 10003 AND val.level_value = p_csm_resp_id)
    )
AND NOT EXISTS
(SELECT 1
 FROM csm_profile_option_values_acc acc
 WHERE acc.profile_option_id = val.profile_option_id
 AND acc.application_id = val.application_id
 AND acc.level_id = val.level_id
 AND acc.level_value = val.level_value
 AND acc.level_id <> 10003
 UNION
 SELECT 1
 FROM csm_profile_option_values_acc acc,
      fnd_responsibility resp
 WHERE acc.profile_option_id = val.profile_option_id
 AND acc.application_id = val.application_id
 AND acc.level_id = val.level_id
 AND acc.level_value = val.level_value
 AND acc.level_id = 10003
 AND acc.level_value = resp.responsibility_id
 AND acc.level_value_application_id = resp.application_id
 AND SYSDATE BETWEEN nvl(resp.start_date, sysdate) AND nvl(resp.end_date, sysdate)
 )
 ORDER BY val.application_id, val.profile_option_id, val.level_id desc ;

-- get the profiles to be updated
CURSOR l_profiles_upd_csr
IS
SELECT val.application_id,
  val.profile_option_id,
  val.level_id,
  val.level_value,
  val.level_value_application_id,
  val.profile_option_value,
  acc.user_id,
  acc.access_id
FROM fnd_profile_option_values val,
     csm_profile_option_values_acc acc
WHERE val.profile_option_id = acc.profile_option_id
 AND val.application_id     = acc.application_id
 AND acc.level_id           = val.level_id
 AND acc.level_value        = val.level_value
 AND NVL(val.profile_option_value,-1) <> NVL(acc.profile_option_value,-1);

-- get the profiles to be deleted
CURSOR l_profiles_del_csr(p_last_upd_date date)
IS
SELECT acc.access_id, acc.application_id, acc.profile_option_id, acc.level_id, acc.level_value,
       acc.level_value_application_id, acc.profile_option_value, opt.profile_option_name,
       acc.user_id
FROM  csm_profile_option_values_acc acc,
      fnd_profile_options opt
WHERE acc.profile_option_id = opt.profile_option_id
AND   acc.application_id = opt.application_id
AND acc.level_id IS NOT NULL
AND acc.level_value IS NOT NULL
AND (opt.profile_option_name = 'CSF_M_RECIPIENTS_BOUNDARY'
--  OR opt.profile_option_name = 'CSF_M_AGENDA_ALLOWCHANGESCOMPLETEDTASK'
  OR opt.profile_option_name = 'CSF_MOBILE_TASK_TIMES_UPDATABLE'
  OR opt.profile_option_name = 'CSF_DEBRIEF_OVERLAPPING_LABOR'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_SEVERITY'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_URGENCY'
  OR opt.profile_option_name  = 'JTF_TIME_UOM_CLASS'
  OR opt.profile_option_name  = 'ICX_PREFERRED_CURRENCY'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'
  OR opt.profile_option_name  = 'CS_SR_RESTRICT_IB'
  OR opt.profile_option_name  = 'SERVER_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CLIENT_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CSF_BUSINESS_PROCESS'
  OR opt.profile_option_name  = 'CSM_SEARCH_RESULT_SET_SIZE'
  OR opt.profile_option_name  = 'CSM_IB_ITEMS_AT_LOCATION'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_SET_FILTER'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_FILTER'
  OR opt.profile_option_name  = 'CS_INV_VALIDATION_ORG'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_TYPE'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_STATUS'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_SR'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_TASK'
  OR opt.profile_option_name  = 'CSM_ENABLE_UPDATE_ASSIGNMENTS'
  OR opt.profile_option_name  = 'CSM_ENABLE_VIEW_CUST_PRODUCTS'
  OR opt.profile_option_name  = 'CSM_MAX_READINGS_PER_COUNTER'
  OR opt.profile_option_name = 'CSF_RETURN_REASON'
  --R 12 updates
  OR opt.profile_option_name  = 'CSFW_DEFAULT_DISTANCE_UNIT'
  OR opt.profile_option_name  = 'CSF_CAPTURE_TRAVEL'
  OR opt.profile_option_name  = 'CSM_LABOR_LINE_TOTAL_CHECK'
  OR opt.profile_option_name  = 'ICX_DATE_FORMAT_MASK'
  OR opt.profile_option_name  = 'JTM_TIMEPICKER_FORMAT'
  OR opt.profile_option_name  = 'CSM_TIME_REASONABILITY_CHECK_APPLY'
  OR opt.profile_option_name  = 'ICX_NUMERIC_CHARACTERS'
  OR opt.profile_option_name  = 'CSF_LABOR_DEBRIEF_DEFAULT_UOM'
  OR opt.profile_option_name  = 'CSF_UOM_HOURS'
  OR opt.profile_option_name  = 'CSZ_DEFAULT_CONTACT_BY'
  OR opt.profile_option_name  = 'HZ_REF_TERRITORY'
  OR opt.profile_option_name  = 'HZ_REF_LANG'
  OR opt.profile_option_name  = 'HZ_LANG_FOR_COUNTRY_DISPLAY'
  OR opt.profile_option_name  = 'CSM_MAX_ATTACHMENT_SIZE'  --For PPC
  OR opt.profile_option_name  = 'CSF_UOM_MINUTES'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_STATUS_PERSONAL'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_TYPE_PERSONAL'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF TRANSACTION TYPE'
  OR opt.profile_option_name  = 'INV:EXPENSE_TO_ASSET_TRANSFER'
  OR opt.profile_option_name  = 'JTF_PROFILE_DEFAULT_CURRENCY'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_ASSIGNED_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_PRIORITY'
  OR opt.profile_option_name  = 'CSFW_PLANNED_TASK_WINDOW'
  OR opt.profile_option_name  = 'CS_SR_CONTACT_MANDATORY'
  OR opt.profile_option_name  = 'CSM_RESTRICT_DEBRIEF'
  OR opt.profile_option_name  = 'CSM_RESTRICT_ORDERS'
  OR opt.profile_option_name  = 'CSM_RESTRICT_TRANSFERS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_TYPE'
  OR opt.profile_option_name  = 'CSM_ACCOUNT_MESSAGE_INTERCEPTION'
  OR opt.profile_option_name  = 'CSM_AS_DATA_DOWNLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_AS_DATA_UPLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_ENABLE_AS_STATUS_NFN'
  OR opt.profile_option_name  = 'CSM_NFN_SYNC_ERROR'
  OR opt.profile_option_name  = 'CSM_NOTIFY_DEFERRED'
  OR opt.profile_option_name  = 'CSF_MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_MANDATORY_RESOLUTION_CODE'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_RESTRICT_SERVICE_REQUEST_CREATION_ TO_ SCHEDULED_SITES'
  OR opt.profile_option_name  = 'CSM_WIRELESS_URL'
  OR opt.profile_option_name  = 'CSM_ONLINE_ACCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_DEFAULT_DEBRIEF_SAC_TRAVEL'
  OR opt.profile_option_name  = 'CSM_ALLOW_FREE_FORM_IB'
  OR opt.profile_option_name  = 'CSF: MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_DEBRIEF_LABOR_SAC'
  )
AND NOT EXISTS
(SELECT 1
 FROM fnd_profile_option_values val
 WHERE val.application_id = acc.application_id
 AND val.profile_option_id = acc.profile_option_id
 AND val.level_id = acc.level_id
 AND val.level_value = acc.level_value
 AND val.level_id <> 10003
 UNION
 SELECT 1
 FROM fnd_profile_option_values val,
      fnd_responsibility resp
 WHERE val.application_id = acc.application_id
 AND val.profile_option_id = acc.profile_option_id
 AND val.level_id = acc.level_id
 AND val.level_value = acc.level_value
 AND val.level_id = 10003
 AND val.level_value = resp.responsibility_id
 AND val.level_value_application_id = resp.application_id
 AND SYSDATE BETWEEN nvl(resp.start_date, sysdate) AND nvl(resp.end_date, sysdate)
 )
 ORDER BY acc.profile_option_id, acc.level_id desc
 FOR UPDATE OF acc.profile_option_value, acc.level_id, acc.level_value nowait
 ;

--Bug 5257429
CURSOR c_purge IS
 SELECT /*+ index(ACC CSM_PROFILE_VALUES_ACC_N1) */
        ACC.APPLICATION_ID,
        ACC.PROFILE_OPTION_ID
 FROM csm_profile_option_values_acc ACC
 WHERE NOT EXISTS( SELECT 1
                   FROM  FND_PROFILE_OPTIONS OPT
                   WHERE OPT.PROFILE_OPTION_ID = ACC.PROFILE_OPTION_ID
                   AND   OPT.APPLICATION_ID = ACC.APPLICATION_ID
		   AND   OPT.PROFILE_OPTION_NAME IN
                   ( 'CSF_M_RECIPIENTS_BOUNDARY'
                   , 'CSF_MOBILE_TASK_TIMES_UPDATABLE'
                   , 'CSF_DEBRIEF_OVERLAPPING_LABOR'
                   , 'INC_DEFAULT_INCIDENT_SEVERITY'
                   , 'INC_DEFAULT_INCIDENT_URGENCY'
                   , 'JTF_TIME_UOM_CLASS'
                   , 'ICX_PREFERRED_CURRENCY'
                   , 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'
                   , 'CS_SR_RESTRICT_IB'
                   , 'SERVER_TIMEZONE_ID'
                   , 'CLIENT_TIMEZONE_ID'
                   , 'CSF_BUSINESS_PROCESS'
                   , 'CSM_SEARCH_RESULT_SET_SIZE'
                   , 'CSM_IB_ITEMS_AT_LOCATION'
                   , 'CSM_ITEM_CATEGORY_SET_FILTER'
                   , 'CSM_ITEM_CATEGORY_FILTER'
                   , 'CS_INV_VALIDATION_ORG'
                   , 'INC_DEFAULT_INCIDENT_TYPE'
                   , 'INC_DEFAULT_INCIDENT_STATUS'
                   , 'CSM_ENABLE_CREATE_SR'
                   , 'CSM_ENABLE_CREATE_TASK'
                   , 'CSM_ENABLE_UPDATE_ASSIGNMENTS'
                   , 'CSM_ENABLE_VIEW_CUST_PRODUCTS'
                   , 'CSM_MAX_READINGS_PER_COUNTER'
                   , 'CSF_RETURN_REASON'
                   , 'CSFW_DEFAULT_DISTANCE_UNIT'
                   , 'CSF_CAPTURE_TRAVEL'
                   , 'CSM_LABOR_LINE_TOTAL_CHECK'
                   , 'ICX_DATE_FORMAT_MASK'
                   , 'JTM_TIMEPICKER_FORMAT'
                   , 'CSM_TIME_REASONABILITY_CHECK_APPLY'
                   , 'ICX_NUMERIC_CHARACTERS'
                   , 'CSF_LABOR_DEBRIEF_DEFAULT_UOM'
                   , 'CSF_UOM_HOURS'
                   , 'CSZ_DEFAULT_CONTACT_BY'
                   , 'HZ_REF_TERRITORY'
                   , 'HZ_REF_LANG'
                   , 'HZ_LANG_FOR_COUNTRY_DISPLAY'
                   , 'CSM_MAX_ATTACHMENT_SIZE'  --For PPC
                   , 'CSF_UOM_MINUTES'
                   , 'CSF_DEFAULT_TASK_STATUS_PERSONAL'
                   , 'CSF_DEFAULT_TASK_TYPE_PERSONAL'
                   , 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
                   , 'CSF:DEFAULT DEBRIEF TRANSACTION TYPE'
                   , 'INV:EXPENSE_TO_ASSET_TRANSFER'
                   , 'JTF_PROFILE_DEFAULT_CURRENCY'
                   , 'CSF_DEFAULT_TASK_ASSIGNED_STATUS'
                   , 'JTF_TASK_DEFAULT_TASK_STATUS'
                   , 'JTF_TASK_DEFAULT_TASK_PRIORITY'
                   , 'CSFW_PLANNED_TASK_WINDOW'
                   , 'CS_SR_CONTACT_MANDATORY'
                   , 'CSM_RESTRICT_DEBRIEF'
                   , 'CSM_RESTRICT_ORDERS'
                   , 'CSM_RESTRICT_TRANSFERS'
                   , 'JTF_TASK_DEFAULT_TASK_TYPE'
                   , 'CSM_ACCOUNT_MESSAGE_INTERCEPTION'
                   , 'CSM_AS_DATA_DOWNLOAD_INTERVAL'
                   , 'CSM_AS_DATA_UPLOAD_INTERVAL'
                   , 'CSM_ENABLE_AS_STATUS_NFN'
                   , 'CSM_NFN_SYNC_ERROR'
                   , 'CSM_NOTIFY_DEFERRED'
                   , 'CSF_MANDATORY_LABOR_DEBRIEF'
                   , 'CSF_MANDATORY_RESOLUTION_CODE'
                   , 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
                   , 'CSF_RESTRICT_SERVICE_REQUEST_CREATION_ TO_ SCHEDULED_SITES'
                   , 'CSM_WIRELESS_URL'
                   , 'CSM_ONLINE_ACCESS'
                   , 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
                   , 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
                   , 'CSF_DEFAULT_DEBRIEF_SAC_TRAVEL'
                   , 'CSM_ALLOW_FREE_FORM_IB'
                   , 'CSF: MANDATORY_LABOR_DEBRIEF'
                   , 'CSF_DEBRIEF_LABOR_SAC'
                   )
                 AND NVL(OPT.start_date_active, SYSDATE) <= SYSDATE
                 AND NVL(OPT.end_date_active,   SYSDATE) >= SYSDATE
                 );

TYPE PURGE_TAB IS TABLE OF c_purge%ROWTYPE;
l_tab PURGE_TAB;

--Bug 5257429
CURSOR c_get_accessID(b_app_id NUMBER, b_prfopt_id NUMBER)
IS
 SELECT ACC.ACCESS_ID,ACC.USER_ID
 FROM   csm_profile_option_values_acc ACC
 WHERE ACC.APPLICATION_ID= b_app_id
 AND   ACC.PROFILE_OPTION_ID= b_prfopt_id;


CURSOR l_get_old_profile_csr (p_profile_option_id IN number, p_user_id IN number)
IS
SELECT access_id, profile_option_value, level_id
FROM csm_profile_option_values_acc
WHERE profile_option_id = p_profile_option_id
AND user_id = p_user_id
ORDER BY level_id desc
FOR UPDATE OF profile_option_value, level_id, level_value, last_update_date nowait;

-- get the value at the next profile level
CURSOR c_profiles_csr ( p_profile_option_name VARCHAR2,
                       p_user_id IN NUMBER DEFAULT NULL,
                       p_csm_resp_id IN NUMBER DEFAULT NULL,
                       p_csm_app_id IN NUMBER DEFAULT NULL
                      )
IS
SELECT val.profile_option_value,
       val.level_id,
       val.level_value,
       val.level_value_application_id,
       val.profile_option_id
FROM fnd_profile_options       opt,
     fnd_profile_option_values val
WHERE opt.profile_option_name = p_profile_option_name
AND NVL(opt.start_date_active, SYSDATE) <= SYSDATE
AND NVL(opt.end_date_active,   SYSDATE) >= SYSDATE
AND opt.application_id      = val.application_id
AND opt.profile_option_id   = val.profile_option_id
AND ( ( val.level_id      = 10001
      )
        OR
      ( val.level_id    = 10002    AND
        val.level_value = p_csm_app_id
      ) OR
      ( val.level_id    = 10003    AND
        val.level_value = p_csm_resp_id
      ) OR
      ( val.level_id    = 10004    AND
        val.level_value = p_user_id
       )
    )
ORDER BY val.level_id DESC;

r_profiles_rec c_profiles_csr%ROWTYPE;

CURSOR c_profile ( p_profile_option_name IN VARCHAR2,
                   p_user_level_value  IN  NUMBER DEFAULT NULL,
                   p_csm_resp_id IN NUMBER default NULL,
                   p_csm_app_id IN NUMBER DEFAULT NULL
                 ) IS
SELECT val.profile_option_value,
       val.level_id,
       val.level_value,
       val.level_value_application_id
FROM fnd_profile_options       opt,
     fnd_profile_option_values val
WHERE opt.profile_option_name = p_profile_option_name
AND NVL(opt.start_date_active, SYSDATE) <= SYSDATE
AND NVL(opt.end_date_active,   SYSDATE) >= SYSDATE
AND opt.application_id      = val.application_id
AND opt.profile_option_id   = val.profile_option_id
AND ( ( val.level_id      = 10001
      )
      OR
     ( val.level_id    = 10002    AND
       val.level_value = p_csm_app_id
     ) OR
     ( val.level_id    = 10003    AND
      val.level_value = p_csm_resp_id
     ) OR
     ( val.level_id    = 10004    AND
       val.level_value = p_user_level_value
     )
   )
ORDER BY val.level_id DESC;

cursor c_csm_appl is
SELECT APPLICATION_ID
FROM fnd_application
where application_short_name = 'CSM';

cursor c_csm_resp(c_user_id NUMBER) is
select RESPONSIBILITY_ID
from   ASG_USER
where  USER_ID = c_user_id;

CURSOR c_profile_seq IS
SELECT csm_profiles_acc_s.NEXTVAL
FROM dual;

l_csm_appl_id                 fnd_application.application_id%TYPE;
l_csm_resp_id                 fnd_responsibility.responsibility_id%TYPE;
l_old_profile_option_value    fnd_profile_option_values.profile_option_value%TYPE;
l_old_level_id                fnd_profile_option_values.level_id%TYPE;
l_profile_option_value        fnd_profile_option_values.profile_option_value%TYPE;
l_level_id                    fnd_profile_option_values.level_id%TYPE;
l_level_value                 fnd_profile_option_values.level_value%TYPE;
l_level_value_application_id  fnd_profile_option_values.level_value_application_id%TYPE;

TYPE num_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_acc_tab   num_tab_type;
l_user_tab  num_tab_type;

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr(g_pub_item);
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- get csm application id
 OPEN c_csm_appl;
 FETCH c_csm_appl INTO l_csm_appl_id;
 CLOSE c_csm_appl;


--Bug 5257429
OPEN c_purge;
FETCH c_purge BULK COLLECT INTO l_tab;
CLOSE c_purge;


  CSM_UTIL_PKG.LOG('Entering DELETE to remove ' || l_tab.count||' records',
                             'CSM_PROFILE_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

  FOR I IN 1..l_tab.COUNT
  LOOP
    OPEN c_get_accessID(l_tab(I).APPLICATION_ID,l_tab(I).PROFILE_OPTION_ID);
    FETCH c_get_accessID BULK COLLECT INTO l_acc_tab,l_user_tab;
    CLOSE c_get_accessID;

    FOR J IN 1..l_user_tab.COUNT
    LOOP
    l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,l_acc_tab(J) ,l_user_tab(J), 'D', sysdate );
    END LOOP;

    FORALL J IN 1..l_acc_tab.COUNT
    DELETE FROM csm_profile_option_values_acc WHERE ACCESS_ID=l_acc_tab(J);

  END LOOP;

COMMIT;

--- process profile wovalue inserts
 FOR r_profiles_ins_rec IN l_profiles_wovalue_ins_csr LOOP

           -- insert into csm_profile_option_values_acc
           insert_profiles_acc(r_profiles_ins_rec.access_id,r_profiles_ins_rec.user_id,r_profiles_ins_rec.application_id,
                             r_profiles_ins_rec.profile_option_id, 10001,
                             0, NULL,
                             NULL,l_run_date);

           --mark dirty the SDQ for the user
              l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                       r_profiles_ins_rec.access_id, r_profiles_ins_rec.user_id, ASG_DOWNLOAD.INS, SYSDATE);

 END LOOP; -- process profile wovalue inserts

  COMMIT;

 --process deletes
 FOR r_profiles_del_rec IN l_profiles_del_csr(l_prog_update_date) LOOP

  -- initialize the user list
  l_all_omfs_palm_user_list := l_null_user_list;
  l_resp_id := -99;
  l_app_id := -99;
  -- set the old profile option value
  l_old_profile_option_value := r_profiles_del_rec.profile_option_value;

  IF r_profiles_del_rec.level_id = 10004 THEN
    l_all_omfs_palm_user_list(1) := r_profiles_del_rec.level_value;
  ELSIF r_profiles_del_rec.level_id = 10003 THEN
    l_resp_id := r_profiles_del_rec.level_value;
    l_all_omfs_palm_user_list(1) := r_profiles_del_rec.user_id;
  ELSIF r_profiles_del_rec.level_id = 10002 THEN
    l_app_id := r_profiles_del_rec.level_value;
    l_all_omfs_palm_user_list(1) := r_profiles_del_rec.user_id;
  ELSE
    -- get the specific user deleted
    l_all_omfs_palm_user_list(1) := r_profiles_del_rec.user_id;
  END IF;

  -- loop for all the valid omfs palm users based on profile level_id
  FOR i IN 1..l_all_omfs_palm_user_list.count LOOP
    l_user_id := l_all_omfs_palm_user_list(i);

	 -- get csm responsibility id
 	OPEN c_csm_resp(l_user_id);
	FETCH c_csm_resp INTO l_csm_resp_id;
 	CLOSE c_csm_resp;

    IF csm_util_pkg.is_palm_user(l_user_id) THEN
      OPEN c_profiles_csr(r_profiles_del_rec.profile_option_name, l_user_id, l_csm_resp_id, l_csm_appl_id);
      FETCH c_profiles_csr INTO r_profiles_rec;
      IF c_profiles_csr%FOUND THEN
         IF r_profiles_rec.profile_option_value IS NULL THEN
            -- get profile at site level
            fnd_profile.GET(NAME => r_profiles_del_rec.profile_option_name, VAL => r_profiles_rec.profile_option_value );
            r_profiles_rec.level_id := 10001;
            r_profiles_rec.level_value := 0;
         END IF;

         UPDATE csm_profile_option_values_acc
         SET profile_option_value = r_profiles_rec.profile_option_value,
             level_id =  r_profiles_rec.level_id,
             level_value = r_profiles_rec.level_value,
             level_value_application_id = r_profiles_rec.level_value_application_id,
             last_update_date = l_run_date
         WHERE CURRENT OF l_profiles_del_csr;

         --mark dirty the SDQ for the user
         l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                            r_profiles_del_rec.access_id, l_user_id, ASG_DOWNLOAD.UPD, SYSDATE);
      ELSE
          --No value set for this profile at any level and hence set back to site level with value null
         UPDATE csm_profile_option_values_acc
         SET profile_option_value = NULL,
             level_id =  10001,
             level_value = 0,
             level_value_application_id = NULL,
             last_update_date = l_run_date
         WHERE CURRENT OF l_profiles_del_csr;
            --mark dirty the SDQ for the user
         l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                            r_profiles_del_rec.access_id, l_user_id, ASG_DOWNLOAD.UPD, SYSDATE);

      END IF;
      CLOSE c_profiles_csr;
    ELSE
         DELETE FROM csm_profile_option_values_acc WHERE profile_option_id = r_profiles_del_rec.profile_option_id
         AND user_id = l_user_id;
    END IF; -- if valid omfs user

  END LOOP; --palm omfs user loop

 END LOOP; -- process deletes
  COMMIT;

  --process updates STARTS
 FOR r_profiles_upd_rec IN l_profiles_upd_csr LOOP

            UPDATE csm_profile_option_values_acc
            SET   profile_option_value = r_profiles_upd_rec.profile_option_value,
                  last_update_date     = l_run_date
            WHERE USER_ID             = r_profiles_upd_rec.user_id
            AND   profile_option_id   = r_profiles_upd_rec.profile_option_id
            AND   level_id            = r_profiles_upd_rec.level_id
            AND   level_value         = r_profiles_upd_rec.level_value;

                --mark dirty the SDQ for the user
                l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                               r_profiles_upd_rec.access_id, r_profiles_upd_rec.user_id, ASG_DOWNLOAD.UPD, SYSDATE);
 END LOOP;
  COMMIT;
 --process updates ENDS

 --process inserts STARTS
 FOR r_profiles_ins_rec IN l_profiles_ins_csr(l_prog_update_date,
     l_csm_appl_id, l_csm_resp_id) LOOP

  -- initialize the user list
  l_all_omfs_palm_user_list := l_null_user_list;

  IF r_profiles_ins_rec.level_id = 10004 THEN
    l_all_omfs_palm_user_list(1) := r_profiles_ins_rec.level_value;
  ELSIF r_profiles_ins_rec.level_id = 10003 THEN
    -- get all the omfs palm users for the responsibility id

    l_all_omfs_palm_user_list := get_all_omfs_resp_palm_users(r_profiles_ins_rec.level_value);
  ELSE
    -- get all the omfs palm users
    l_all_omfs_palm_user_list := csm_util_pkg.get_all_omfs_palm_user_list;

  END IF;

  -- loop for all the valid omfs palm users based on profile level_id
  FOR i IN 1..l_all_omfs_palm_user_list.COUNT LOOP
    l_user_id := l_all_omfs_palm_user_list(i);

    IF (r_profiles_ins_rec.level_id <> 10004 OR (r_profiles_ins_rec.level_id = 10004
                                           AND csm_util_pkg.is_palm_user(l_user_id))) THEN

      -- delete any lower levels that exist for this profile for the user
      OPEN l_get_old_profile_csr(r_profiles_ins_rec.profile_option_id, l_user_id);
      FETCH l_get_old_profile_csr INTO l_access_id, l_old_profile_option_value, l_old_level_id;
      IF l_get_old_profile_csr%FOUND THEN
        -- only call the WF if a profile at a higher level is added; update the acc table with the new value
        IF r_profiles_ins_rec.level_id > NVL(l_old_level_id,0) THEN

           UPDATE csm_profile_option_values_acc
           SET profile_option_value = r_profiles_ins_rec.profile_option_value,
               level_id = r_profiles_ins_rec.level_id,
               level_value = r_profiles_ins_rec.level_value,
               level_value_application_id = r_profiles_ins_rec.level_value_application_id,
               last_update_date = l_run_date
           WHERE CURRENT OF l_get_old_profile_csr;

           IF is_mfs_profile(p_profile_option_name=>r_profiles_ins_rec.profile_option_name) THEN
                --mark dirty the SDQ for the user
                l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                               l_access_id, l_user_id, ASG_DOWNLOAD.UPD, SYSDATE);
           END IF;
        END IF;

      ELSE -- not found so insert the record(mostly this case is not used as the record is already available)

        IF (r_profiles_ins_rec.level_id = 10004 AND r_profiles_ins_rec.level_value = l_user_id) OR
                   (r_profiles_ins_rec.level_id <> 10004) THEN

           -- get the access_id
           OPEN c_profile_seq;
           FETCH c_profile_seq INTO l_access_id;
           CLOSE c_profile_seq;

           -- insert into csm_profile_option_values_acc
           insert_profiles_acc(l_access_id,l_user_id,r_profiles_ins_rec.application_id,
                             r_profiles_ins_rec.profile_option_id, r_profiles_ins_rec.level_id,
                             r_profiles_ins_rec.level_value, r_profiles_ins_rec.level_value_application_id,
                             r_profiles_ins_rec.profile_option_value,l_run_date);

           --mark dirty the SDQ for the user
              l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                       l_access_id, l_user_id, ASG_DOWNLOAD.INS, SYSDATE);

         END IF;
       END IF;
       CLOSE l_get_old_profile_csr;
   END IF; --- check of is_palm_user for level 10004
  END LOOP; --palm omfs user loop

 END LOOP; -- process inserts

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_run_date,
      last_update_date = SYSDATE
  WHERE package_name = 'CSM_PROFILE_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

 p_status := 'FINE';
 p_message :=  'CSM_PROFILE_EVENT_PKG.Refresh_Acc Executed successfully';

  COMMIT;

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,200);
     ROLLBACK;
     p_status := 'ERROR';
     p_message := 'Error in CSM_PROFILE_EVENT_PKG.Refresh_Acc: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     csm_util_pkg.log('CSM_PROFILE_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg, 'CSM_PROFILE_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_EXCEPTION);
     fnd_file.put_line(fnd_file.log, 'CSM_PROFILE_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END Refresh_Acc;

/***
** Populates the user's acc table with the profiles upon user creation
***/

PROCEDURE refresh_user_acc(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_run_date DATE;
l_access_id jtm_fnd_lookups_acc.access_id%TYPE;
l_markdirty BOOLEAN;

-- get the profiles to be inserted for the new user
CURSOR l_profiles_ins_csr(p_user_id IN number,
                          p_csm_appl_id fnd_application.application_id%TYPE,
                          p_csm_resp_id fnd_responsibility.responsibility_id%TYPE
                         )
IS
SELECT val.application_id, val.profile_option_id, val.level_id, val.level_value,
       val.level_value_application_id, val.profile_option_value, opt.profile_option_name
FROM  fnd_profile_options opt,
      fnd_profile_option_values val
WHERE (opt.profile_option_name = 'CSF_M_RECIPIENTS_BOUNDARY'
--  OR opt.profile_option_name = 'CSF_M_AGENDA_ALLOWCHANGESCOMPLETEDTASK'
  OR opt.profile_option_name = 'CSF_DEBRIEF_OVERLAPPING_LABOR'
  OR opt.profile_option_name = 'CSF_MOBILE_TASK_TIMES_UPDATABLE'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_SEVERITY'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_URGENCY'
  OR opt.profile_option_name  = 'JTF_TIME_UOM_CLASS'
  OR opt.profile_option_name  = 'ICX_PREFERRED_CURRENCY'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'
  OR opt.profile_option_name  = 'CS_SR_RESTRICT_IB'
  OR opt.profile_option_name  = 'SERVER_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CLIENT_TIMEZONE_ID'
  OR opt.profile_option_name  = 'CSF_BUSINESS_PROCESS'
  OR opt.profile_option_name  = 'CSM_SEARCH_RESULT_SET_SIZE'
  OR opt.profile_option_name  = 'CSM_IB_ITEMS_AT_LOCATION'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_SET_FILTER'
  OR opt.profile_option_name  = 'CSM_ITEM_CATEGORY_FILTER'
  OR opt.profile_option_name  = 'CS_INV_VALIDATION_ORG'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_TYPE'
  OR opt.profile_option_name  = 'INC_DEFAULT_INCIDENT_STATUS'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_SR'
  OR opt.profile_option_name  = 'CSM_ENABLE_CREATE_TASK'
  OR opt.profile_option_name  = 'CSM_ENABLE_UPDATE_ASSIGNMENTS'
  OR opt.profile_option_name  = 'CSM_ENABLE_VIEW_CUST_PRODUCTS'
  OR opt.profile_option_name  = 'CSM_MAX_READINGS_PER_COUNTER'
  --bug4172005
  OR opt.profile_option_name = 'CSF_RETURN_REASON'
  --R 12 updates
  OR opt.profile_option_name  = 'CSFW_DEFAULT_DISTANCE_UNIT'
  OR opt.profile_option_name  = 'CSF_CAPTURE_TRAVEL'
  OR opt.profile_option_name  = 'CSM_LABOR_LINE_TOTAL_CHECK'
  OR opt.profile_option_name  = 'ICX_DATE_FORMAT_MASK'
  OR opt.profile_option_name  = 'JTM_TIMEPICKER_FORMAT'
  OR opt.profile_option_name  = 'CSM_TIME_REASONABILITY_CHECK_APPLY'
  OR opt.profile_option_name  = 'ICX_NUMERIC_CHARACTERS'
  OR opt.profile_option_name  = 'CSF_LABOR_DEBRIEF_DEFAULT_UOM'
  OR opt.profile_option_name  = 'CSF_UOM_HOURS'
  OR opt.profile_option_name  = 'CSZ_DEFAULT_CONTACT_BY'
  OR opt.profile_option_name  = 'HZ_REF_TERRITORY'
  OR opt.profile_option_name  = 'HZ_REF_LANG'
  OR opt.profile_option_name  = 'HZ_LANG_FOR_COUNTRY_DISPLAY'
  OR opt.profile_option_name  = 'CSM_MAX_ATTACHMENT_SIZE'  --For PPC
  OR opt.profile_option_name  = 'CSF_UOM_MINUTES'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_STATUS_PERSONAL'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_TYPE_PERSONAL'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF TRANSACTION TYPE'
  OR opt.profile_option_name  = 'INV:EXPENSE_TO_ASSET_TRANSFER'
  OR opt.profile_option_name  = 'JTF_PROFILE_DEFAULT_CURRENCY'
  OR opt.profile_option_name  = 'CSF_DEFAULT_TASK_ASSIGNED_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_STATUS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_PRIORITY'
  OR opt.profile_option_name  = 'CSFW_PLANNED_TASK_WINDOW'
  OR opt.profile_option_name  = 'CS_SR_CONTACT_MANDATORY'
  OR opt.profile_option_name  = 'CSM_RESTRICT_DEBRIEF'
  OR opt.profile_option_name  = 'CSM_RESTRICT_ORDERS'
  OR opt.profile_option_name  = 'CSM_RESTRICT_TRANSFERS'
  OR opt.profile_option_name  = 'JTF_TASK_DEFAULT_TASK_TYPE'
  OR opt.profile_option_name  = 'CSM_ACCOUNT_MESSAGE_INTERCEPTION'
  OR opt.profile_option_name  = 'CSM_AS_DATA_DOWNLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_AS_DATA_UPLOAD_INTERVAL'
  OR opt.profile_option_name  = 'CSM_ENABLE_AS_STATUS_NFN'
  OR opt.profile_option_name  = 'CSM_NFN_SYNC_ERROR'
  OR opt.profile_option_name  = 'CSM_NOTIFY_DEFERRED'
  OR opt.profile_option_name  = 'CSF_MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_MANDATORY_RESOLUTION_CODE'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_RESTRICT_SERVICE_REQUEST_CREATION_ TO_ SCHEDULED_SITES'
  OR opt.profile_option_name  = 'CSM_WIRELESS_URL'
  OR opt.profile_option_name  = 'CSM_ONLINE_ACCESS'
  OR opt.profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
  OR opt.profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
  OR opt.profile_option_name  = 'CSF_DEFAULT_DEBRIEF_SAC_TRAVEL'
  OR opt.profile_option_name  = 'CSM_ALLOW_FREE_FORM_IB'
  OR opt.profile_option_name  = 'CSF: MANDATORY_LABOR_DEBRIEF'
  OR opt.profile_option_name  = 'CSF_DEBRIEF_LABOR_SAC'
  )
AND val.application_id IS NOT NULL
AND val.application_id = opt.application_id
AND val.profile_option_id = opt.profile_option_id
AND (  (val.level_id = 10001)
    OR (val.level_id = 10004 AND val.level_value = p_user_id)
    OR (val.level_id = 10002 AND val.level_value = p_csm_appl_id)
    OR (val.level_id = 10003 AND val.level_value = p_csm_resp_id)
    )
AND NOT EXISTS
(SELECT 1
 FROM csm_profile_option_values_acc acc
 WHERE acc.profile_option_id = val.profile_option_id
 AND acc.application_id = val.application_id
 AND acc.level_id = val.level_id
 AND acc.level_value = val.level_value
 AND val.level_id <> 10003
-- AND NVl(acc.level_value_application_id, -1) = NVL(val.level_value_application_id, -1)
 AND acc.user_id = p_user_id
 UNION
 SELECT 1
 FROM csm_profile_option_values_acc acc,
      fnd_responsibility resp
 WHERE acc.profile_option_id = val.profile_option_id
 AND acc.application_id = val.application_id
 AND acc.level_id = val.level_id
 AND acc.level_value = val.level_value
 AND acc.level_id = 10003
 AND acc.level_value = resp.responsibility_id
 AND acc.level_value_application_id = resp.application_id
 AND acc.user_id = p_user_id
 AND SYSDATE BETWEEN nvl(resp.start_date, sysdate) AND nvl(resp.end_date, sysdate)
 )
 ORDER BY val.application_id, val.profile_option_id, val.level_id desc
 ;

CURSOR l_get_old_profile_csr (p_profile_option_id IN number, p_user_id IN number)
IS
SELECT access_id, profile_option_value, level_id
FROM csm_profile_option_values_acc
WHERE profile_option_id = p_profile_option_id
AND user_id = p_user_id
ORDER BY level_id desc
FOR UPDATE OF profile_option_value, level_id, level_value, last_update_date NOWAIT;

l_old_profile_option_value fnd_profile_option_values.profile_option_value%TYPE;
l_old_level_id fnd_profile_option_values.level_id%TYPE;

CURSOR c_csm_appl IS
SELECT APPLICATION_ID
FROM fnd_application
WHERE application_short_name = 'CSM';

CURSOR  c_csm_resp (c_user_id NUMBER) IS
SELECT  RESPONSIBILITY_ID
FROM 	asg_user
WHERE   user_id = c_user_id;

CURSOR c_profile_seq IS
SELECT csm_profiles_acc_s.NEXTVAL
FROM dual;

l_csm_appl_id fnd_application.application_id%TYPE;
l_csm_resp_id fnd_responsibility.responsibility_id%TYPE;

BEGIN
   l_run_date := SYSDATE;

   -- get csm application id
   OPEN c_csm_appl;
   FETCH c_csm_appl INTO l_csm_appl_id;
   CLOSE c_csm_appl;

   -- get csm responsibility id
   OPEN c_csm_resp(p_user_id);
   FETCH c_csm_resp INTO l_csm_resp_id;
   CLOSE c_csm_resp;

  -- process inserts
   FOR r_profiles_ins_rec IN l_profiles_ins_csr(p_user_id, l_csm_appl_id, l_csm_resp_id) LOOP
      -- delete any lower levels that exist for this profile for the user
      OPEN l_get_old_profile_csr(r_profiles_ins_rec.profile_option_id, p_user_id);
      FETCH l_get_old_profile_csr INTO l_access_id, l_old_profile_option_value, l_old_level_id;
      IF l_get_old_profile_csr%FOUND THEN
        -- only call the WF if a profile at a higher level is added; update the acc table with the new value
        IF r_profiles_ins_rec.level_id > NVL(l_old_level_id,0) THEN
           UPDATE csm_profile_option_values_acc
           SET profile_option_value = r_profiles_ins_rec.profile_option_value,
               level_id = r_profiles_ins_rec.level_id,
               level_value = r_profiles_ins_rec.level_value,
               level_value_application_id = r_profiles_ins_rec.level_value_application_id,
               last_update_date = l_run_date
           WHERE CURRENT OF l_get_old_profile_csr;

        IF is_mfs_profile(p_profile_option_name=>r_profiles_ins_rec.profile_option_name) THEN
            --mark dirty the SDQ for the user
            l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                            l_access_id, p_user_id, ASG_DOWNLOAD.UPD, SYSDATE);
        END IF;

           -- start the profile_option_value_upd WF
--           start_profile_upd_wf(l_access_id, r_profiles_ins_rec.profile_option_name,r_profiles_ins_rec.profile_option_value,
--                                l_old_profile_option_value, p_user_id);
        END IF;
      ELSE
        IF (r_profiles_ins_rec.level_id = 10004 AND r_profiles_ins_rec.level_value = p_user_id) OR
                   (r_profiles_ins_rec.level_id <> 10004) THEN

           -- get the access_id
           OPEN c_profile_seq;
           FETCH c_profile_seq INTO l_access_id;
           CLOSE c_profile_seq;

           -- insert into csm_profile_option_values_acc
           insert_profiles_acc(l_access_id,p_user_id,r_profiles_ins_rec.application_id,
                             r_profiles_ins_rec.profile_option_id, r_profiles_ins_rec.level_id,
                             r_profiles_ins_rec.level_value, r_profiles_ins_rec.level_value_application_id,
                             r_profiles_ins_rec.profile_option_value,l_run_date);

           IF is_mfs_profile(p_profile_option_name=>r_profiles_ins_rec.profile_option_name) THEN
              --mark dirty the SDQ for the user
              l_markdirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                             l_access_id, p_user_id, ASG_DOWNLOAD.INS, SYSDATE);
           END IF;

           -- start the profile_option_value_upd WF using null for the old profle option value
--           start_profile_upd_wf(l_access_id, r_profiles_ins_rec.profile_option_name,r_profiles_ins_rec.profile_option_value,
--                             NULL, p_user_id);

        END IF;
      END IF;
      CLOSE l_get_old_profile_csr;

   END LOOP; -- process inserts

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  refresh_user_acc for user_id:'
                       || to_char(p_user_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'csm_profile_event_pkg.refresh_user_acc',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END refresh_user_acc;

FUNCTION IS_MFS_PROFILE(p_profile_option_name IN VARCHAR2) RETURN BOOLEAN
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_profile_option_name fnd_profile_options.profile_option_name%TYPE;

BEGIN
   l_profile_option_name := p_profile_option_name;

   IF (l_profile_option_name = 'CSF_M_RECIPIENTS_BOUNDARY'
--        OR l_profile_option_name = 'CSF_M_AGENDA_ALLOWCHANGESCOMPLETEDTASK'
        OR l_profile_option_name = 'CSF_DEBRIEF_OVERLAPPING_LABOR'
        OR l_profile_option_name = 'CSF_MOBILE_TASK_TIMES_UPDATABLE'
        OR l_profile_option_name  = 'INC_DEFAULT_INCIDENT_SEVERITY'
        OR l_profile_option_name  = 'INC_DEFAULT_INCIDENT_URGENCY'
        OR l_profile_option_name  = 'JTF_TIME_UOM_CLASS'
        OR l_profile_option_name  = 'ICX_PREFERRED_CURRENCY'
        OR l_profile_option_name  = 'JTF_TASK_DEFAULT_ASSIGNEE_STATUS'
        OR l_profile_option_name  = 'CS_SR_RESTRICT_IB'
        OR l_profile_option_name  = 'SERVER_TIMEZONE_ID'
        OR l_profile_option_name  = 'CLIENT_TIMEZONE_ID'
     	OR l_profile_option_name  = 'CSF_BUSINESS_PROCESS'
     	OR l_profile_option_name  = 'CSM_SEARCH_RESULT_SET_SIZE'
        OR l_profile_option_name  = 'CSM_IB_ITEMS_AT_LOCATION'
        OR l_profile_option_name  = 'CSM_ITEM_CATEGORY_SET_FILTER'
        OR l_profile_option_name  = 'CSM_ITEM_CATEGORY_FILTER'
        OR l_profile_option_name  = 'CS_INV_VALIDATION_ORG'
        OR l_profile_option_name  = 'INC_DEFAULT_INCIDENT_TYPE'
        OR l_profile_option_name  = 'CSM_ENABLE_CREATE_SR'
        OR l_profile_option_name  = 'CSM_ENABLE_CREATE_TASK'
        OR l_profile_option_name  = 'CSM_ENABLE_UPDATE_ASSIGNMENTS'
        OR l_profile_option_name  = 'CSM_ENABLE_VIEW_CUST_PRODUCTS'
    	--bug4172005
	    OR l_profile_option_name = 'CSF_RETURN_REASON'
        OR l_profile_option_name  = 'INC_DEFAULT_INCIDENT_STATUS'
		  --R 12 updates
		OR l_profile_option_name  = 'CSFW_DEFAULT_DISTANCE_UNIT'
  		OR l_profile_option_name  = 'CSF_CAPTURE_TRAVEL'
  		OR l_profile_option_name  = 'CSM_LABOR_LINE_TOTAL_CHECK'
  		OR l_profile_option_name  = 'ICX_DATE_FORMAT_MASK'
  		OR l_profile_option_name  = 'JTM_TIMEPICKER_FORMAT'
  		OR l_profile_option_name  = 'CSM_TIME_REASONABILITY_CHECK_APPLY'
  		OR l_profile_option_name  = 'ICX_NUMERIC_CHARACTERS'
  		OR l_profile_option_name  = 'CSF_LABOR_DEBRIEF_DEFAULT_UOM'
  		OR l_profile_option_name  = 'CSF_UOM_HOURS'
  		OR l_profile_option_name  = 'CSZ_DEFAULT_CONTACT_BY'
		OR l_profile_option_name  = 'HZ_REF_TERRITORY'
  		OR l_profile_option_name  = 'HZ_REF_LANG'
  		OR l_profile_option_name  = 'HZ_LANG_FOR_COUNTRY_DISPLAY'
        OR l_profile_option_name  = 'CSM_MAX_ATTACHMENT_SIZE'  --For PPC
  		OR l_profile_option_name  = 'CSF_UOM_MINUTES'
  		OR l_profile_option_name  = 'CSF_DEFAULT_TASK_STATUS_PERSONAL'
  		OR l_profile_option_name  = 'CSF_DEFAULT_TASK_TYPE_PERSONAL'
        OR l_profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
        OR l_profile_option_name  = 'CSF:DEFAULT DEBRIEF TRANSACTION TYPE'
        OR l_profile_option_name  = 'INV:EXPENSE_TO_ASSET_TRANSFER'
        OR l_profile_option_name  = 'JTF_PROFILE_DEFAULT_CURRENCY'
        OR l_profile_option_name  = 'CSF_DEFAULT_TASK_ASSIGNED_STATUS'
        OR l_profile_option_name  = 'JTF_TASK_DEFAULT_TASK_STATUS'
        OR l_profile_option_name  = 'JTF_TASK_DEFAULT_TASK_PRIORITY'
        OR l_profile_option_name  = 'CSFW_PLANNED_TASK_WINDOW'
        OR l_profile_option_name  = 'CS_SR_CONTACT_MANDATORY'
        OR l_profile_option_name  = 'CSM_RESTRICT_DEBRIEF'
        OR l_profile_option_name  = 'CSM_RESTRICT_ORDERS'
        OR l_profile_option_name  = 'CSM_RESTRICT_TRANSFERS'
        OR l_profile_option_name  = 'JTF_TASK_DEFAULT_TASK_TYPE'
        OR l_profile_option_name  = 'CSM_ACCOUNT_MESSAGE_INTERCEPTION'
        OR l_profile_option_name  = 'CSM_AS_DATA_DOWNLOAD_INTERVAL'
        OR l_profile_option_name  = 'CSM_AS_DATA_UPLOAD_INTERVAL'
        OR l_profile_option_name  = 'CSM_ENABLE_AS_STATUS_NFN'
        OR l_profile_option_name  = 'CSM_NFN_SYNC_ERROR'
        OR l_profile_option_name  = 'CSM_NOTIFY_DEFERRED'
        OR l_profile_option_name  = 'CSF_MANDATORY_LABOR_DEBRIEF'
        OR l_profile_option_name  = 'CSF_MANDATORY_RESOLUTION_CODE'
        OR l_profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
        OR l_profile_option_name  = 'CSF_RESTRICT_SERVICE_REQUEST_CREATION_ TO_ SCHEDULED_SITES'
        OR l_profile_option_name  = 'CSM_WIRELESS_URL'
        OR l_profile_option_name  = 'CSM_ONLINE_ACCESS'
        OR l_profile_option_name  = 'CSF:DEFAULT DEBRIEF BUSINESS PROCESS'
        OR l_profile_option_name  = 'CSF_DEFAULT_LABOR_DEBRIEF_DATETIME'
        OR l_profile_option_name  = 'CSF_DEFAULT_DEBRIEF_SAC_TRAVEL'
        OR l_profile_option_name  = 'CSM_ALLOW_FREE_FORM_IB'
        OR l_profile_option_name  = 'CSF: MANDATORY_LABOR_DEBRIEF'
        OR l_profile_option_name  = 'CSF_DEBRIEF_LABOR_SAC'
        ) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in IS_MFS_PROFILE for profile_option_name:' || l_profile_option_name
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_PROFILE_EVENT_PKG.IS_MFS_PROFILE',FND_LOG.LEVEL_EXCEPTION);
        RETURN FALSE;
END IS_MFS_PROFILE;

END CSM_PROFILE_EVENT_PKG;

/
