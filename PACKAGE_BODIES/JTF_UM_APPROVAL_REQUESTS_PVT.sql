--------------------------------------------------------
--  DDL for Package Body JTF_UM_APPROVAL_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_APPROVAL_REQUESTS_PVT" as
/* $Header: JTFVAPRB.pls 120.2.12010000.8 2013/03/27 07:54:45 anurtrip ship $ */
TYPE APPR_REQ_CUR is REF CURSOR;
/**
  * Procedure   :  PENDING_APPROVAL_SYSADMIN
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the pending requests foy sysadmin
  * Parameters  :
  * input parameters
  * @param     p_sort_order
  *     description:  The sort order
  *     required   :  Y
  *     validation :  Must be a valid sort order
  *   p_number_of_records:
  *     description:  The number of records to retrieve from a database
  *     required   :  Y
  *     validation :  Must be a valid number
  * output parameters
  *   x_result: APPROVAL_REQUEST_TABLE_TYPE
 */
procedure PENDING_APPROVAL_SYSADMIN(
    p_sort_order        in varchar2,
    p_number_of_records in number,
    x_result            out NOCOPY APPROVAL_REQUEST_TABLE_TYPE,
    p_sort_option in varchar2) IS
  l_rownum number := 10;  -- Default value
  APPR_REQ APPR_REQ_CUR;
  qry varchar2(4000) :=
    'SELECT REG_ID, REG_LAST_UPDATE_DATE, USER_NAME, PARTY_TYPE, PARTY_ID,
           ENTITY_SOURCE, ENTITY_NAME, WF_ITEM_TYPE, APPROVER, ERROR_ACTIVITY
     FROM (
      SELECT sys_requests.REG_ID, sys_requests.REG_LAST_UPDATE_DATE, sys_requests.USER_NAME,
             sys_requests.PARTY_TYPE, sys_requests.PARTY_ID, sys_requests.ENTITY_SOURCE,
             sys_requests.ENTITY_NAME, sys_requests.WF_ITEM_TYPE, sys_requests.APPROVER,
             JTF_UM_APPROVAL_REQUESTS_PVT.getWorkflowActivityStatus(WF_ITEM_TYPE,REG_ID) ERROR_ACTIVITY
      FROM (
        SELECT UTREG.USERTYPE_REG_ID REG_ID, UTREG.LAST_UPDATE_DATE REG_LAST_UPDATE_DATE,
               FU.USER_NAME USER_NAME, PARTY.PARTY_TYPE PARTY_TYPE, PARTY.PARTY_ID PARTY_ID,
               ''USERTYPE'' ENTITY_SOURCE, UT.USERTYPE_SHORTNAME ENTITY_NAME,
               UTREG.WF_ITEM_TYPE WF_ITEM_TYPE, FU2.USER_NAME APPROVER
        FROM JTF_UM_USERTYPES_VL UT, JTF_UM_APPROVALS_B APPR, HZ_PARTIES PARTY,
             JTF_UM_USERTYPE_REG UTREG, FND_USER FU, FND_USER FU2
        WHERE UTREG.STATUS_CODE in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
        AND   UTREG.USERTYPE_ID = UT.USERTYPE_ID
        AND   UT.APPROVAL_ID = APPR.APPROVAL_ID
        AND   APPR.USE_PENDING_REQ_FLAG = ''Y''
        AND   UTREG.USER_ID = FU.USER_ID
        AND   FU.CUSTOMER_ID = PARTY.PARTY_ID
        AND   nvl (UTREG.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        AND   FU2.USER_ID (+) = UTREG.APPROVER_USER_ID
        UNION ALL
        SELECT SUBREG.SUBSCRIPTION_REG_ID REG_ID, SUBREG.LAST_UPDATE_DATE REG_LAST_UPDATE_DATE,
               FU.USER_NAME USER_NAME, PARTY.PARTY_TYPE PARTY_TYPE, PARTY.PARTY_ID PARTY_ID,
               ''ENROLLMENT'' ENTITY_SOURCE, SUB.SUBSCRIPTION_NAME ENTITY_NAME,
               SUBREG.WF_ITEM_TYPE WF_ITEM_TYPE, FU2.USER_NAME APPROVER
        FROM JTF_UM_SUBSCRIPTIONS_VL SUB,
             JTF_UM_APPROVALS_B APPR,
             HZ_PARTIES PARTY,
             JTF_UM_SUBSCRIPTION_REG SUBREG,
             FND_USER FU,
             JTF_UM_USERTYPE_REG UTREG,
             FND_USER FU2
        WHERE SUBREG.STATUS_CODE in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
        AND   SUBREG.SUBSCRIPTION_ID = SUB.SUBSCRIPTION_ID
        AND   SUB.APPROVAL_ID = APPR.APPROVAL_ID
        AND   APPR.USE_PENDING_REQ_FLAG = ''Y''
        AND   SUBREG.USER_ID = FU.USER_ID
        AND   FU.CUSTOMER_ID = PARTY.PARTY_ID
        AND   (SUBREG.EFFECTIVE_END_DATE IS null OR SUBREG.EFFECTIVE_END_DATE > sysdate)
        AND   SUBREG.USER_ID = UTREG.USER_ID
        AND   UTREG.STATUS_CODE not in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
        AND   nvl (UTREG.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
        AND   FU2.USER_ID (+) = SUBREG.APPROVER_USER_ID
      ) sys_requests ';
  l_party_id HZ_PARTIES.PARTY_ID%TYPE;
  CURSOR GET_COMPANY_NAME IS
    SELECT PARTY.PARTY_NAME FROM HZ_PARTIES PARTY, HZ_RELATIONSHIPS PREL
    WHERE  PARTY.PARTY_ID = PREL.OBJECT_ID
    AND    PREL.PARTY_ID = l_party_id
    AND    PREL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.START_DATE < SYSDATE
    AND    NVL(PREL.END_DATE, SYSDATE+1) > SYSDATE
    AND    PREL.RELATIONSHIP_CODE in ('EMPLOYEE_OF', 'CONTACT_OF')
    ORDER BY PREL.START_DATE;
  l_party_type HZ_PARTIES.PARTY_TYPE%TYPE;
  i NUMBER := 1;
BEGIN
  IF p_number_of_records IS NOT NULL AND p_number_of_records <> 0 THEN
    l_rownum := p_number_of_records;
  END IF;
  IF UPPER(p_sort_order) = 'USER_NAME' THEN
    qry := qry||' order by sys_requests.USER_NAME ' || p_sort_option || ') all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'ENTITY_SOURCE' THEN
    qry := qry||' order by sys_requests.ENTITY_SOURCE '|| p_sort_option ||' ) all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'ENTITY_NAME' THEN
    qry := qry||' order by sys_requests.ENTITY_NAME '|| p_sort_option || ' ) all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'ENTITY_NUMBER' THEN
    qry := qry||' order by ERROR_ACTIVITY , sys_requests.REG_ID ' || p_sort_option || ') all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'APPROVER' THEN
    qry := qry||' order by sys_requests.APPROVER '|| p_sort_option || ' ) all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSE
    qry := qry||' order by REG_LAST_UPDATE_DATE '|| p_sort_option ||' ) all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  END IF;
 open APPR_REQ for qry using l_rownum;
    loop
        fetch APPR_REQ into x_result(i).REG_ID,
                            x_result(i).REG_LAST_UPDATE_DATE,
                            x_result(i).USER_NAME,
                            l_party_type,
                            l_party_id,
                            x_result(i).ENTITY_SOURCE,
                            x_result(i).ENTITY_NAME,
                            x_result(i).WF_ITEM_TYPE,
                            x_result(i).APPROVER,
                            x_result(i).ERROR_ACTIVITY;
        FOR r in GET_COMPANY_NAME LOOP
            x_result(i).COMPANY_NAME := r.party_name;
        END LOOP;
        exit when APPR_REQ%NOTFOUND;
        i := i + 1;
    end loop;
END PENDING_APPROVAL_SYSADMIN;
/**
  * Procedure   :  PENDING_APPROVAL_PRIMARY
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the pending requests foy Primary User
  * Parameters  :
  * input parameters
  * @param     p_sort_order
  *     description:  The sort order
  *     required   :  Y
  *     validation :  Must be a valid sort order
  *   p_number_of_records:
  *     description:  The number of records to retrieve from a database
  *     required   :  Y
  *     validation :  Must be a valid number
  *   p_approver_user_id
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  *   x_result:  APPROVAL_REQUEST_TABLE_TYPE
 */
procedure PENDING_APPROVAL_PRIMARY(
    p_sort_order        in varchar2,
    p_number_of_records in number,
    p_approver_user_id  in number,
    x_result            out NOCOPY APPROVAL_REQUEST_TABLE_TYPE,
    p_sort_option in varchar2) IS
  l_rownum number := 10;  -- Default value
  l_dummy_user_id FND_USER.USER_ID%TYPE;
  l_company_id HZ_PARTIES.PARTY_ID%TYPE;
  l_party_name HZ_PARTIES.PARTY_NAME%TYPE;
  APPR_REQ APPR_REQ_CUR;
  qry varchar2(4000) :=  'SELECT * FROM
    (SELECT REG_ID, REG_LAST_UPDATE_DATE, USER_NAME, ENTITY_SOURCE,
           ENTITY_NAME, WF_ITEM_TYPE,
           JTF_UM_APPROVAL_REQUESTS_PVT.getWorkflowActivityStatus(WF_ITEM_TYPE,REG_ID) ERROR_ACTIVITY
    FROM (
      SELECT UTREG.USERTYPE_REG_ID REG_ID, UTREG.LAST_UPDATE_DATE REG_LAST_UPDATE_DATE,
             FU.USER_NAME USER_NAME, ''USERTYPE'' ENTITY_SOURCE,
             UT.USERTYPE_SHORTNAME ENTITY_NAME, UTREG.WF_ITEM_TYPE WF_ITEM_TYPE
      FROM JTF_UM_USERTYPES_VL UT, JTF_UM_APPROVALS_B APPR,
           HZ_RELATIONSHIPS PREL, JTF_UM_USERTYPE_REG UTREG, FND_USER FU
      WHERE UTREG.STATUS_CODE in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
      AND   UTREG.USERTYPE_ID = UT.USERTYPE_ID
      AND   UT.APPROVAL_ID = APPR.APPROVAL_ID
      AND   APPR.USE_PENDING_REQ_FLAG = ''Y''
      AND   UTREG.USER_ID = FU.USER_ID
      AND   FU.CUSTOMER_ID = PREL.PARTY_ID
      AND   PREL.OBJECT_ID = :l_company_id
      AND    PREL.SUBJECT_TABLE_NAME = ''HZ_PARTIES''
      AND    PREL.OBJECT_TABLE_NAME = ''HZ_PARTIES''
      AND    PREL.START_DATE < SYSDATE
      AND    NVL(PREL.END_DATE, SYSDATE+1) > SYSDATE
      AND    PREL.RELATIONSHIP_CODE in (''EMPLOYEE_OF'', ''CONTACT_OF'')
      AND   nvl (UTREG.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
      AND   UTREG.APPROVER_USER_ID = :l_dummy_user_id
      UNION ALL
      SELECT SUBREG.SUBSCRIPTION_REG_ID REG_ID, SUBREG.LAST_UPDATE_DATE REG_LAST_UPDATE_DATE,
             FU.USER_NAME USER_NAME, ''ENROLLMENT'' ENTITY_SOURCE,
             SUB.SUBSCRIPTION_NAME ENTITY_NAME, SUBREG.WF_ITEM_TYPE WF_ITEM_TYPE
      FROM JTF_UM_SUBSCRIPTIONS_VL SUB, JTF_UM_APPROVALS_B APPR,
           HZ_RELATIONSHIPS PREL, JTF_UM_SUBSCRIPTION_REG SUBREG,
           FND_USER FU, JTF_UM_USERTYPE_REG UTREG
      WHERE SUBREG.STATUS_CODE in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
      AND   SUBREG.SUBSCRIPTION_ID = SUB.SUBSCRIPTION_ID
      AND   SUB.APPROVAL_ID = APPR.APPROVAL_ID
      AND   APPR.USE_PENDING_REQ_FLAG = ''Y''
      AND   SUBREG.USER_ID = FU.USER_ID
      AND   FU.CUSTOMER_ID = PREL.PARTY_ID
      AND   PREL.OBJECT_ID = :l_company_id
      AND    PREL.SUBJECT_TABLE_NAME = ''HZ_PARTIES''
      AND    PREL.OBJECT_TABLE_NAME = ''HZ_PARTIES''
      AND    PREL.RELATIONSHIP_CODE in (''EMPLOYEE_OF'', ''CONTACT_OF'')
      AND    PREL.START_DATE < SYSDATE
      AND    NVL(PREL.END_DATE, SYSDATE+1) > SYSDATE
      AND   (SUBREG.EFFECTIVE_END_DATE IS null OR SUBREG.EFFECTIVE_END_DATE > sysdate)
      AND   SUBREG.USER_ID = UTREG.USER_ID
      AND   UTREG.STATUS_CODE not in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
      AND   nvl (UTREG.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
      AND   SUBREG.APPROVER_USER_ID = :l_dummy_user_id
    ) pri_requests ';
  CURSOR GET_COMPANY_NAME IS
    SELECT PARTY.PARTY_NAME, PARTY.PARTY_ID
    FROM HZ_PARTIES PARTY, HZ_RELATIONSHIPS PREL, FND_USER FU
    WHERE PARTY.PARTY_ID = PREL.OBJECT_ID
    AND   PREL.PARTY_ID = FU.CUSTOMER_ID
    AND   FU.USER_ID = p_approver_user_id
    AND    PREL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.START_DATE < SYSDATE
    AND    NVL(PREL.END_DATE, SYSDATE+1) > SYSDATE
    AND    PREL.RELATIONSHIP_CODE = 'EMPLOYEE_OF'
    ORDER BY PREL.START_DATE DESC;
  i NUMBER := 1;
  CURSOR FIND_DUMMY_USER IS
    SELECT USER_ID
    FROM FND_USER
    WHERE USER_NAME = FND_PROFILE.VALUE('JTF_PRIMARY_USER');
BEGIN
  IF p_number_of_records IS NOT NULL AND p_number_of_records <> 0 THEN
    l_rownum := p_number_of_records;
  END IF;
  PENDING_APPROVAL_OWNER(
      p_sort_order        => p_sort_order,
      p_number_of_records => p_number_of_records,
      p_approver_user_id  => p_approver_user_id,
      x_result            => x_result,
      p_sort_option       => p_sort_option);
  OPEN FIND_DUMMY_USER;
  FETCH FIND_DUMMY_USER INTO l_dummy_user_id;
  CLOSE FIND_DUMMY_USER;
  IF l_dummy_user_id IS NOT NULL THEN
    OPEN GET_COMPANY_NAME;
    FETCH GET_COMPANY_NAME INTO l_party_name, l_company_id;
    CLOSE GET_COMPANY_NAME;
    i := nvl(x_result.LAST, 0) + 1;
    IF UPPER(p_sort_order) = 'USER_NAME' THEN
        qry := qry||' order by pri_requests.USER_NAME ' || p_sort_option || ' )all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
    ELSIF UPPER(p_sort_order) = 'ENTITY_SOURCE' THEN
        qry := qry||' order by pri_requests.ENTITY_SOURCE ' || p_sort_option || ' )all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
    ELSIF UPPER(p_sort_order) = 'ENTITY_NAME' THEN
        qry := qry||' order by pri_requests.ENTITY_NAME ' || p_sort_option || '  )all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
    ELSIF UPPER(p_sort_order) = 'ENTITY_NUMBER' THEN
        qry := qry||' order by ERROR_ACTIVITY , pri_requests.REG_ID ' || p_sort_option || ' )all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
    ELSE
        qry := qry||' order by REG_LAST_UPDATE_DATE ' || p_sort_option || ')all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
    END IF;
    open APPR_REQ for qry using l_company_id, l_dummy_user_id, l_company_id, l_dummy_user_id, l_rownum;
    loop
        fetch APPR_REQ into x_result(i).REG_ID,
                            x_result(i).REG_LAST_UPDATE_DATE,
                            x_result(i).USER_NAME,
                            x_result(i).ENTITY_SOURCE,
                            x_result(i).ENTITY_NAME,
                            x_result(i).WF_ITEM_TYPE,
                            x_result(i).ERROR_ACTIVITY;
        x_result(i).COMPANY_NAME := l_party_name;
        exit when APPR_REQ%NOTFOUND;
        i := i + 1;
    end loop;
  END IF;
END PENDING_APPROVAL_PRIMARY;
/**
  * Procedure   :  PENDING_APPROVAL_OWNER
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the pending requests for the request owner
  * Parameters  :
  * input parameters
  * @param     p_sort_order
  *     description:  The sort order
  *     required   :  Y
  *     validation :  Must be a valid sort order
  *   p_number_of_records:
  *     description:  The number of records to retrieve from a database
  *     required   :  Y
  *     validation :  Must be a valid number
  *   p_approver_user_id
  *     description:  The user_id of a logged in user
  *     required   :  Y
  *     validation :  Must be a valid user_id
  * output parameters
  *   x_result:  APPROVAL_REQUEST_TABLE_TYPE
 */
procedure PENDING_APPROVAL_OWNER(
    p_sort_order        in varchar2,
    p_number_of_records in number,
    p_approver_user_id  in number,
    x_result            out NOCOPY APPROVAL_REQUEST_TABLE_TYPE,
    p_sort_option in varchar2) IS
  l_rownum number := 10;  -- Default value
  APPR_REQ APPR_REQ_CUR;
  qry varchar2(4000) := 'SELECT * FROM
    (SELECT REG_ID, REG_LAST_UPDATE_DATE, USER_NAME, PARTY_TYPE, PARTY_ID,
           ENTITY_SOURCE, ENTITY_NAME, WF_ITEM_TYPE,
           JTF_UM_APPROVAL_REQUESTS_PVT.getWorkflowActivityStatus(WF_ITEM_TYPE, REG_ID) ERROR_ACTIVITY
     FROM (
      SELECT UTREG.USERTYPE_REG_ID REG_ID, UTREG.LAST_UPDATE_DATE
             REG_LAST_UPDATE_DATE, FU.USER_NAME USER_NAME,
             PARTY.PARTY_TYPE PARTY_TYPE, PARTY.PARTY_ID PARTY_ID,
             ''USERTYPE'' ENTITY_SOURCE, UT.USERTYPE_SHORTNAME ENTITY_NAME,
             UTREG.WF_ITEM_TYPE WF_ITEM_TYPE
      FROM JTF_UM_USERTYPES_VL UT, JTF_UM_APPROVALS_B APPR, HZ_PARTIES PARTY,
           JTF_UM_USERTYPE_REG UTREG, FND_USER FU
      WHERE UTREG.STATUS_CODE in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
      AND   UTREG.USERTYPE_ID = UT.USERTYPE_ID
      AND   UT.APPROVAL_ID = APPR.APPROVAL_ID
      AND   APPR.USE_PENDING_REQ_FLAG = ''Y''
      AND   UTREG.USER_ID = FU.USER_ID
      AND   FU.CUSTOMER_ID = PARTY.PARTY_ID
      AND   nvl (UTREG.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
      AND   UTREG.APPROVER_USER_ID = :p_approver_user_id
     UNION ALL
     SELECT SUBREG.SUBSCRIPTION_REG_ID REG_ID, SUBREG.LAST_UPDATE_DATE REG_LAST_UPDATE_DATE,
            FU.USER_NAME USER_NAME, PARTY.PARTY_TYPE PARTY_TYPE,
            PARTY.PARTY_ID PARTY_ID, ''ENROLLMENT'' ENTITY_SOURCE,
            SUB.SUBSCRIPTION_NAME ENTITY_NAME, SUBREG.WF_ITEM_TYPE WF_ITEM_TYPE
      FROM JTF_UM_SUBSCRIPTIONS_VL SUB, JTF_UM_APPROVALS_B APPR, HZ_PARTIES PARTY,
           JTF_UM_SUBSCRIPTION_REG SUBREG, FND_USER FU, JTF_UM_USERTYPE_REG UTREG
      WHERE SUBREG.STATUS_CODE in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
      AND   SUBREG.SUBSCRIPTION_ID = SUB.SUBSCRIPTION_ID
      AND   SUB.APPROVAL_ID = APPR.APPROVAL_ID
      AND   APPR.USE_PENDING_REQ_FLAG = ''Y''
      AND   SUBREG.USER_ID = FU.USER_ID
      AND   FU.CUSTOMER_ID = PARTY.PARTY_ID
      AND   (SUBREG.EFFECTIVE_END_DATE IS null OR SUBREG.EFFECTIVE_END_DATE > sysdate)
      AND   SUBREG.USER_ID = UTREG.USER_ID
      AND   UTREG.STATUS_CODE not in (''PENDING'', ''UPGRADE_APPROVAL_PENDING'')
      AND   nvl (UTREG.EFFECTIVE_END_DATE, sysdate + 1) > sysdate
      AND   SUBREG.APPROVER_USER_ID = :p_approver_user_id
    ) owner_requests ';
  l_party_id    HZ_PARTIES.PARTY_ID%TYPE;
  CURSOR GET_COMPANY_NAME IS
    SELECT PARTY.PARTY_NAME
    FROM HZ_PARTIES PARTY, HZ_RELATIONSHIPS PREL
    WHERE PARTY.PARTY_ID = PREL.OBJECT_ID
    AND   PREL.PARTY_ID = l_party_id
    AND    PREL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND    PREL.START_DATE < SYSDATE
    AND    NVL(PREL.END_DATE, SYSDATE+1) > SYSDATE
    AND    PREL.RELATIONSHIP_CODE in ('EMPLOYEE_OF', 'CONTACT_OF')
    ORDER BY PREL.START_DATE;
  l_party_type HZ_PARTIES.PARTY_TYPE%TYPE;
  i NUMBER := 1;
BEGIN
  IF p_number_of_records IS NOT NULL AND p_number_of_records <> 0 THEN
    l_rownum := p_number_of_records;
  END IF;
  IF UPPER(p_sort_order) = 'USER_NAME' THEN
    qry := qry||' order by owner_requests.USER_NAME ' || p_sort_option || '  )all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'ENTITY_SOURCE' THEN
    qry := qry||' order by owner_requests.ENTITY_SOURCE ' || p_sort_option || ')all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'ENTITY_NAME' THEN
    qry := qry||' order by owner_requests.ENTITY_NAME ' || p_sort_option || ')all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSIF UPPER(p_sort_order) = 'ENTITY_NUMBER' THEN
    qry := qry||' order by ERROR_ACTIVITY , owner_requests.REG_ID ' || p_sort_option || ')all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  ELSE
    qry := qry||' order by REG_LAST_UPDATE_DATE ' || p_sort_option || ')all_requests where ERROR_ACTIVITY in (0,-1,-2) and rownum < :1';
  END IF;
  open APPR_REQ for qry using p_approver_user_id, p_approver_user_id, l_rownum;
    loop
        fetch APPR_REQ into x_result(i).REG_ID,
                            x_result(i).REG_LAST_UPDATE_DATE,
                            x_result(i).USER_NAME,
                            l_party_type,
                            l_party_id,
                            x_result(i).ENTITY_SOURCE,
                            x_result(i).ENTITY_NAME,
                            x_result(i).WF_ITEM_TYPE,
                            x_result(i).ERROR_ACTIVITY;
      exit when APPR_REQ%NOTFOUND;
      FOR r in GET_COMPANY_NAME LOOP
        x_result(i).COMPANY_NAME := r.party_name;
      END LOOP;
      i := i + 1;
    END LOOP;
END PENDING_APPROVAL_OWNER;


/**
  * Function   :  getWFActivityStatus
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Return the status of the given WF item
  * Parameters  :
  * input parameters
  * @param     itemType
  *     description:  The WF item type
  *     required   :  Y
  *     validation :  Must be a valid WF item type
  *   itemKey:
  *     description:  The WF item key
  *     required   :  Y
  *     validation :  Must be a valid WF item key
  *
  * Return Value
  *   x_result:  -1 => Errored WF
  *              -2 => Cancelled WF
  *               0 => Active WF
 */
function getWorkflowActivityStatus(itemType varchar2, itemKey varchar2) return number is
    ret_val number(1) := 0;
    status_code varchar2(100);
begin
    begin
        select x.STATUS_CODE into status_code
        from (SELECT wf_fwkmon.getitemstatus(WorkflowItemEO.ITEM_TYPE, WorkflowItemEO.ITEM_KEY, WorkflowItemEO.END_DATE, WorkflowItemEO.ROOT_ACTIVITY, WorkflowItemEO.ROOT_ACTIVITY_VERSION) STATUS_CODE
                       FROM WF_ITEMS WorkflowItemEO,
            WF_ITEM_TYPES_VL WorkflowItemTypeEO,
            WF_ACTIVITIES_VL ActivityEO
        WHERE WorkflowItemEO.ITEM_TYPE = WorkflowItemTypeEO.NAME AND
                ActivityEO.ITEM_TYPE = WorkflowItemEO.ITEM_TYPE AND
                ActivityEO.NAME = WorkflowItemEO.ROOT_ACTIVITY AND
                ActivityEO.VERSION = WorkflowItemEO.ROOT_ACTIVITY_VERSION AND
                WorkflowItemEO.ITEM_TYPE=itemtype AND
                WorkflowItemEO.ITEM_KEY = itemkey) x
        WHERE STATUS_CODE IN ('ACTIVE','FORCE','ERROR','COMPLETE_WITH_ERRORS');

        if (status_code='ACTIVE') then
            ret_val := 0;
        elsif(status_code='ERROR' or status_code='COMPLETE_WITH_ERRORS') then
            ret_val := -1;
        elsif(status_code='FORCE') then
            ret_val := -2;
        end if;
    exception
        when no_data_found then
            ret_val := -3;
        when others then
            ret_val := -3;
    end;
    return ret_val;
end;
end JTF_UM_APPROVAL_REQUESTS_PVT;

/
