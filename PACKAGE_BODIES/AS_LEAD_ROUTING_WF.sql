--------------------------------------------------------
--  DDL for Package Body AS_LEAD_ROUTING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEAD_ROUTING_WF" AS
/* $Header: asxldrtb.pls 115.49 2003/09/11 17:31:08 solin ship $ */

-- Start of Comments
-- Package name     : AS_LEAD_ROUTING_WF
-- Purpose          : Sales Leads Workflow
-- NOTE             :
-- History          :
--      11/07/2000 FFANG  Created.
--      05/23/2001 SOLIN  Change for real time assignment and sales lead
--                        sales team.
--      07/10/2001 SOLIN  Use UPDATE statement directly in UpdateSalesLead
--      07/25/2001 SOLIN  Enhancement bug 1732822.
--                        Set status_code to profile AS_LEAD_ROUTING_STATUS
--                        and accept_flag to 'N' when assign owner.
--      07/31/2001 SOLIN  Add customer user hook and GetOwner function.
--      08/07/2001 SOLIN  Add call to JTF_CALENDAR_PUB.
--      09/06/2001 SOLIN  Enhancement bug 1963262.
--                        Owner can decline sales lead.
--      12/10/2001 SOLIN  Bug 2102901.
--                        Add salesgroup_id for current user.
--      02/04/2002 SOLIN  Enhancement bug 2098158.
--                        Add p_PRIMARY_CNT_PERSON_PARTY_ID,
--                        p_PRIMARY_CONTACT_PHONE_ID when calling sales lead
--                        update row.
--      11/04/2002 SOLIN  Enhancement Bug 2238553
--                        When owner is changed, don't change status.
--      02/14/2003 SOLIN  Bug 2796513
--                        If owner was on the sales team with freeze_flag='Y'
--                        owner will still have freeze_flag='Y'
--      02/20/2003 SOLIN  Bug 2796503
--                        Show message if no more available resource can be
--                        lead owner.
--      03/20/2003 SOLIN  Bug 2831426
--                        Add open_flag in as_accesses_all table.
--      04/28/2003 SOLIN  Bug 2926777
--                        Close_reason should not be changed when
--                        lead is reassigned.
--      05/01/2003 SOLIN  Bug 2928041
--                        Add open_flag, object_creation_date, and
--                        lead_rank_score in as_accesses_all table
--      09/11/2003 SOLIN  Change for Sales_Lead_Update_Row new columns
--
-- END of Comments


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_LEAD_ROUTING_WF';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxldrtb.pls';

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
g_resource_id_tbl       NUMBER_TABLE;
g_group_id_tbl          NUMBER_TABLE;
g_person_id_tbl         NUMBER_TABLE;

-- The follwing is the meaning of g_resource_flag_tbl:
-- 'D': This resource is the default resource from profile
--      AS_DEFAULT_RESOURCE_ID, "OS: Default Resource ID used for Sales
--      Lead Assignment".
-- 'L': This resource is the login user.
-- 'T': This resource is defined in territory.
g_resource_flag_tbl     FLAG_TABLE;

-- This id is current user's group_id.
g_user_group_id         NUMBER;

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE StartProcess(
    p_sales_lead_id        IN     NUMBER,
    p_salesgroup_id        IN     NUMBER,
    p_reject_reason_code   IN     VARCHAR2 := NULL,
    x_return_status        IN OUT NOCOPY VARCHAR2,
    x_item_type            OUT NOCOPY    VARCHAR2,
    x_item_key             OUT NOCOPY    VARCHAR2 )
IS
    Item_Type       VARCHAR2(8) := 'ASXSLASW' ;
    Item_Key        VARCHAR2(30);
    l_status        VARCHAR2(80);
    l_result        VARCHAR2(80);
    l_sequence      VARCHAR2(240);
    l_seqnum        NUMBER(38);
    workflowprocess VARCHAR2(30) := 'SALES_LEAD_ASSIGNMENT';
    l_profile_rs_id NUMBER;
BEGIN
    -- Start Process :
    --  If workflowprocess is passed, it will be run.
    --  If workflowprocess is NOT passed, the selector FUNCTION
    --  defined in the item type will determine which process to run.

    SELECT TO_CHAR(AS_WORKFLOW_KEYS_S.nextval) INTO Item_Key
    FROM dual;

    g_user_group_id := p_salesgroup_id;

    wf_engine.CreateProcess( ItemType => Item_Type,
                             ItemKey  => Item_Key,
                             process  => Workflowprocess);

    -- Initialize workflow item attributes
    --
    wf_engine.SetItemAttrNumber(itemtype => Item_Type,
                                itemkey  => Item_Key,
                                aname    => 'SALES_LEAD_ID',
                                avalue   => p_sales_lead_id);

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          itemkey      => Item_Key,
                          aname        => 'ORIG_RESOURCE_ID',
                          number_value => NULL);

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          itemkey      => Item_Key,
                          aname        => 'RESOURCE_ID',
                          number_value => 0);

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          itemkey      => Item_Key,
                          aname        => 'GROUP_ID',
                          number_value => 0);

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          itemkey      => Item_Key,
                          aname        => 'PERSON_ID',
                          number_value => 0);

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          Itemkey      => Item_Key,
                          aname        => 'BUSINESS_GROUP_ID',
                          number_value => 0);

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          Itemkey      => Item_Key,
                          aname        => 'REJECT_REASON_CODE',
                          text_value   => p_reject_reason_code);

    -- The following call was added, such that default attribute id
    -- is added item list. This will be populated, once  if the resource id
    -- from profile as_default_resource_id is used.
    -- Refer: Bug 1613424

    wf_engine.AddItemAttr(itemtype     => Item_Type,
                          Itemkey      => Item_Key,
                          aname        => 'DEFAULT_RESOURCE_ID',
                          number_value => 0);

    wf_engine.StartProcess(itemtype  => Item_Type,
                           itemkey   => Item_Key );

    wf_engine.ItemStatus(itemtype => Item_Type,
                         itemkey  => Item_Key,
                         status   => l_status,
                         result   => l_result);

    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'After ItemStatus:' || l_result);
    END IF;

    x_item_type := Item_Type;
    x_item_key := Item_Key;
    x_return_status := l_result ;

    -- code change for bug 1613424 start
    -- l_profile_rs_id is used as a temp variable.
    -- if this has some value other than zero, it means that
    -- GetAvailableResource either had used profile or login user's
    -- resource id. In which case, the start process returns
    -- 'W'arning to the calling program.

    l_profile_rs_id :=  wf_engine.GetItemAttrNumber(
                                  itemtype => Item_Type,
                                  itemkey => Item_Key,
                                  aname => 'DEFAULT_RESOURCE_ID' );

    IF (l_profile_rs_id <> 0 ) AND ( l_result = 'S')
    THEN
        x_return_status := 'W';
    END IF;
    -- code change for bug 1613424 end

EXCEPTION
    when others then
        wf_core.context(Item_type, 'StartProcess', p_sales_lead_id,
                        Workflowprocess);
        x_return_status := 'ERROR';
        raise;
END StartProcess;

/*******************************/
-- Scope: private
-- setResource
-- Note: sets the resource
/*******************************/
PROCEDURE SetResource(
    itemtype         IN VARCHAR2,
    itemkey          IN VARCHAR2,
    resource_id      IN NUMBER,
    group_id         IN NUMBER,
    person_id        IN NUMBER) IS
BEGIN
    wf_engine.SetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'RESOURCE_ID',
        avalue   => resource_id);

    wf_engine.SetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'GROUP_ID',
        avalue   => group_id);

    wf_engine.SetItemAttrNumber (
        itemtype => itemtype,
        itemkey  => itemkey,
        aname    => 'PERSON_ID',
        avalue   => person_id);
END SetResource;

/*****************************************************/
-- Scope: private
-- GetAlternateResource
-- Note: There's no territory matching this sales lead.
--       Get default resource and login user.
/*****************************************************/
PROCEDURE GetAlternateResource IS
    l_rs_id     NUMBER := NULL;

    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category = 'EMPLOYEE'
      AND res.user_id = fnd_global.user_id;

    CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> 'Y'
      AND rrel.delete_flag <> 'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = 'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- in this cursor, instead of in the above cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

BEGIN
    l_rs_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
    IF l_rs_id IS NULL
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'profile not set');
        END IF;
        -- Profile is not set. hence going against the logged in user

        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_rs_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'No resource found for login user!');
            END IF;
            CLOSE C_get_current_resource;
            RETURN;
        END IF;
        CLOSE C_get_current_resource;

        IF l_rs_id IS NOT NULL
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'User''s resource id is:' || l_rs_id);
            END IF;
            IF g_user_group_id = fnd_api.g_miss_num
            THEN
                g_group_id_tbl(1) := NULL;
                OPEN c_get_group_id (l_rs_id);
                FETCH c_get_group_id INTO g_group_id_tbl(1);
                CLOSE c_get_group_id;
            ELSE
                g_group_id_tbl(1) := g_user_group_id;
            END IF;

            OPEN c_get_person_id (l_rs_id);
            FETCH c_get_person_id INTO g_person_id_tbl(1);
            CLOSE c_get_person_id;
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Users group id is:' || g_group_id_tbl(1));
            END IF;
            g_resource_id_tbl(1) := l_rs_id;
            g_resource_flag_tbl(1) := 'L';
        END IF;

    ELSE -- profile resource id is not null
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile resource id :'|| l_rs_id);
        END IF;
        g_group_id_tbl(1) := NULL;
        OPEN c_get_group_id (l_rs_id);
        FETCH c_get_group_id INTO g_group_id_tbl(1);
        CLOSE c_get_group_id;
        OPEN c_get_person_id (l_rs_id);
        FETCH c_get_person_id INTO g_person_id_tbl(1);
        CLOSE c_get_person_id;
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile group id :' || g_group_id_tbl(1));
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile person id :' || g_person_id_tbl(1));
        END IF;
        g_resource_id_tbl(1) := l_rs_id;
        g_resource_flag_tbl(1) := 'D';

        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_rs_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN
            CLOSE C_get_current_resource;
            -- result := 'COMPLETE:ERROR';
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'No resource found!');
            END IF;
            RETURN;
        END IF;
        CLOSE C_get_current_resource;

        IF l_rs_id IS NOT NULL AND
           l_rs_id <> g_resource_id_tbl(1)
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'User''s resource id is:' || l_rs_id);
            END IF;
            IF g_user_group_id = fnd_api.g_miss_num
            THEN
                g_group_id_tbl(2) := NULL;
                OPEN c_get_group_id (l_rs_id);
                FETCH c_get_group_id INTO g_group_id_tbl(2);
                CLOSE c_get_group_id;
            ELSE
                g_group_id_tbl(2) := g_user_group_id;
            END IF;

            OPEN c_get_person_id (l_rs_id);
            FETCH c_get_person_id INTO g_person_id_tbl(2);
            CLOSE c_get_person_id;
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Users group id is:' || g_group_id_tbl(2));
            END IF;
            g_resource_id_tbl(2) := l_rs_id;
            g_resource_flag_tbl(2) := 'L';
        END IF;
    END IF; -- resource id from profile check

END GetAlternateResource;

/*******************************/
-- API: GET RESOUCE
/*******************************/
PROCEDURE GetAvailableResource (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS
  l_sales_lead_id         NUMBER;
  l_resource_id_tbl       NUMBER_TABLE;
  l_group_id_tbl          NUMBER_TABLE;
  l_person_id_tbl         NUMBER_TABLE;
  l_resource_flag_tbl     FLAG_TABLE;
  l_check_calendar        VARCHAR2(1);
  l_index1                NUMBER; -- point to l_resource_id_tbl
  l_index2                NUMBER; -- point to g_resource_id_tbl
  l_last                  NUMBER; -- total number of rec in l_resource_id_tbl
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_planned_start_date    DATE;
  l_planned_end_date      DATE;
  l_shift_construct_id    NUMBER;
  l_availability_type     VARCHAR2(60);

  -- SOLIN, enhancement for 11.5.9, 11/08/2002
  -- Leads re-route must not be routed back to a resource that has previously
  -- owned the lead before.
  CURSOR c_get_lead_resource(c_sales_lead_id NUMBER) IS
    SELECT ACC.SALESFORCE_ID, ACC.SALES_GROUP_ID, ACC.PERSON_ID, 'T'
    FROM AS_ACCESSES_ALL ACC
    WHERE ACC.SALES_LEAD_ID = c_sales_lead_id
    AND ACC.CREATED_BY_TAP_FLAG = 'Y'
    AND NOT EXISTS (
        SELECT 1
        FROM AS_SALES_LEADS_LOG LOG
        WHERE LOG.SALES_LEAD_ID = c_sales_lead_id
        AND   LOG.ASSIGN_TO_SALESFORCE_ID = ACC.SALESFORCE_ID
        AND  (LOG.ASSIGN_SALES_GROUP_ID = ACC.SALES_GROUP_ID
          OR  LOG.ASSIGN_SALES_GROUP_ID IS NULL AND ACC.SALES_GROUP_ID IS NULL))
   ORDER BY ACC.ACCESS_ID;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'GetAvailableResource: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN
        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'SALES_LEAD_ID');

        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'sl_id:' || l_sales_lead_id);
        END IF;

        -- Get sales team for the sales lead
        OPEN c_get_lead_resource(l_sales_lead_id);
        FETCH c_get_lead_resource BULK COLLECT INTO
            l_resource_id_tbl, l_group_id_tbl, l_person_id_tbl,
            l_resource_flag_tbl;
        CLOSE c_get_lead_resource;

        l_check_calendar :=
            NVL(FND_PROFILE.Value('AS_SL_ASSIGN_CALENDAR_REQ'),'N');
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'l_resource_id_tbl.count=' || l_resource_id_tbl.count);
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Check calendar?' || l_check_calendar);
        END IF;

        g_resource_id_tbl.delete;
        l_last := l_resource_id_tbl.last;
        IF l_check_calendar = 'Y' AND l_last > 0
        THEN
            l_index1 := 1;
            l_index2 := 0;
            WHILE l_index1 <= l_last
            LOOP
                IF (AS_DEBUG_LOW_ON) THEN
                    AS_UTILITY_PVT.Debug_Message(
                        FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Check resource ' || l_resource_id_tbl(l_index1));
                END IF;
                -- Check the calendar for resource availability
                -- Call Calendar API
                JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT(
                    P_API_VERSION        => 1.0,
                    P_INIT_MSG_LIST      => FND_API.G_FALSE,
                    P_RESOURCE_ID        => l_resource_id_tbl(l_index1),
                    P_RESOURCE_TYPE      => 'RS_EMPLOYEE',
                    P_START_DATE_TIME    => SYSDATE-1,
                    P_END_DATE_TIME      => SYSDATE+1,
                    P_DURATION           => 8,
                    X_RETURN_STATUS      => l_return_status,
                    X_MSG_COUNT          => l_msg_count,
                    X_MSG_DATA           => l_msg_data,
                    X_SLOT_START_DATE    => l_planned_start_date,
                    X_SLOT_END_DATE      => l_planned_end_date,
                    X_SHIFT_CONSTRUCT_ID => l_shift_construct_id,
                    X_AVAILABILITY_TYPE  => l_availability_type);

                IF l_return_status <> fnd_api.g_ret_sts_success
                THEN
                    -- Unexpected Execution Error from call to Calendar
                    IF (AS_DEBUG_LOW_ON) THEN
                        AS_UTILITY_PVT.Debug_Message(
                            FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'JTF Calendar failed');
                    END IF;
                    -- RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF (AS_DEBUG_LOW_ON) THEN
                    AS_UTILITY_PVT.Debug_Message(
                        FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'l_shift_construct_id=' || l_shift_construct_id);
                END IF;
                IF l_shift_construct_id IS NOT NULL
                THEN
                    l_index2 := l_index2 + 1;
                    g_resource_id_tbl(l_index2) :=
                        l_resource_id_tbl(l_index1);
                    g_group_id_tbl(l_index2) := l_group_id_tbl(l_index1);
                    g_person_id_tbl(l_index2) := l_person_id_tbl(l_index1);
                    g_resource_flag_tbl(l_index2) :=
                        l_resource_flag_tbl(l_index1);
                END IF;
                l_index1 := l_index1 + 1;
            END LOOP; -- l_index1 <= l_last
        ELSE
            g_resource_id_tbl := l_resource_id_tbl;
            g_group_id_tbl := l_group_id_tbl;
            g_person_id_tbl := l_person_id_tbl;
            g_resource_flag_tbl := l_resource_flag_tbl;
        END IF; -- l_check_calendar = 'Y' AND l_last > 0

        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'g_resource_id_tbl.count=' || g_resource_id_tbl.count);
        END IF;
        result := 'COMPLETE:S';
    END IF; -- function mode check
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'GetAvailableResource: End');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
        END IF;
        wf_core.context(
            itemtype,
            'GETAVAILABLERESOURCE',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END GetAvailableResource;
-------------------------------------------------------------


/*******************************/
-- API: GET OWNER
/*******************************/
PROCEDURE GetOwner(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2)
IS
  l_rs_id                 NUMBER := null;

  l_sales_lead_id         NUMBER;
  l_call_user_hook        BOOLEAN;
  l_sales_lead_rec        AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type;
  l_org_owner_id_tbl      NUMBER_TABLE;
  l_i                     NUMBER;
  l_return_status         VARCHAR2(15);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_resource_id           NUMBER;
  l_group_id              NUMBER;
  l_person_id             NUMBER;
  l_resource_avail_flag   VARCHAR2(1);

  CURSOR c_get_sales_lead(c_sales_lead_id NUMBER) IS
    SELECT SALES_LEAD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
           CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
           PROGRAM_ID, PROGRAM_UPDATE_DATE, LEAD_NUMBER, STATUS_CODE,
           CUSTOMER_ID, ADDRESS_ID, SOURCE_PROMOTION_ID, INITIATING_CONTACT_ID,
           ORIG_SYSTEM_REFERENCE, CONTACT_ROLE_CODE, CHANNEL_CODE,
           BUDGET_AMOUNT, CURRENCY_CODE, DECISION_TIMEFRAME_CODE,
           CLOSE_REASON, LEAD_RANK_ID, LEAD_RANK_CODE, PARENT_PROJECT,
           DESCRIPTION, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
           ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
           ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, BUDGET_STATUS_CODE,
           ACCEPT_FLAG, VEHICLE_RESPONSE_CODE, TOTAL_SCORE, SCORECARD_ID,
           KEEP_FLAG, URGENT_FLAG, IMPORT_FLAG, REJECT_REASON_CODE,
           DELETED_FLAG, OFFER_ID, INCUMBENT_PARTNER_PARTY_ID,
           INCUMBENT_PARTNER_RESOURCE_ID, PRM_EXEC_SPONSOR_FLAG,
           PRM_PRJ_LEAD_IN_PLACE_FLAG, PRM_SALES_LEAD_TYPE,
           PRM_IND_CLASSIFICATION_CODE, QUALIFIED_FLAG, ORIG_SYSTEM_CODE,
           PRM_ASSIGNMENT_TYPE, AUTO_ASSIGNMENT_TYPE, PRIMARY_CONTACT_PARTY_ID,
           PRIMARY_CNT_PERSON_PARTY_ID, PRIMARY_CONTACT_PHONE_ID,
           REFERRED_BY, REFERRAL_TYPE, REFERRAL_STATUS, REF_DECLINE_REASON,
           REF_COMM_LTR_STATUS, REF_ORDER_NUMBER, REF_ORDER_AMT,
           REF_COMM_AMT, LEAD_DATE, SOURCE_SYSTEM, COUNTRY,
           TOTAL_AMOUNT, EXPIRATION_DATE, LEAD_ENGINE_RUN_DATE, LEAD_RANK_IND,
           CURRENT_REROUTES
    FROM AS_SALES_LEADS
    WHERE SALES_LEAD_ID = c_sales_lead_id;

  CURSOR c_get_resource_avail(c_sales_lead_id NUMBER) IS
    SELECT 'Y'
    FROM AS_ACCESSES_ALL ACC
    WHERE ACC.SALES_LEAD_ID = c_sales_lead_id
    AND ACC.CREATED_BY_TAP_FLAG = 'Y';
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'GetOwner: Start');
    END IF;

    IF funcmode = 'RUN'
    THEN
        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'SALES_LEAD_ID');

        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'sl_id:' || l_sales_lead_id);
        END IF;

        IF g_resource_id_tbl.count = 0
        THEN
            GetAlternateResource;
        END IF;

        l_call_user_hook := JTF_USR_HKS.Ok_to_execute('AS_LEAD_ROUTING_WF',
                            'GetOwner','B','C');

        -- USER HOOK standard : customer pre-processing section - mandatory
        IF l_call_user_hook
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Call user_hook is true');
            END IF;
            OPEN c_get_sales_lead(l_sales_lead_id);
            FETCH c_get_sales_lead INTO
                l_sales_lead_rec.SALES_LEAD_ID,
                l_sales_lead_rec.LAST_UPDATE_DATE,
                l_sales_lead_rec.LAST_UPDATED_BY,
                l_sales_lead_rec.CREATION_DATE,
                l_sales_lead_rec.CREATED_BY,
                l_sales_lead_rec.LAST_UPDATE_LOGIN,
                l_sales_lead_rec.REQUEST_ID,
                l_sales_lead_rec.PROGRAM_APPLICATION_ID,
                l_sales_lead_rec.PROGRAM_ID,
                l_sales_lead_rec.PROGRAM_UPDATE_DATE,
                l_sales_lead_rec.LEAD_NUMBER, l_sales_lead_rec.STATUS_CODE,
                l_sales_lead_rec.CUSTOMER_ID, l_sales_lead_rec.ADDRESS_ID,
                l_sales_lead_rec.SOURCE_PROMOTION_ID,
                l_sales_lead_rec.INITIATING_CONTACT_ID,
                l_sales_lead_rec.ORIG_SYSTEM_REFERENCE,
                l_sales_lead_rec.CONTACT_ROLE_CODE,
                l_sales_lead_rec.CHANNEL_CODE,
                l_sales_lead_rec.BUDGET_AMOUNT, l_sales_lead_rec.CURRENCY_CODE,
                l_sales_lead_rec.DECISION_TIMEFRAME_CODE,
                l_sales_lead_rec.CLOSE_REASON, l_sales_lead_rec.LEAD_RANK_ID,
                l_sales_lead_rec.LEAD_RANK_CODE,
                l_sales_lead_rec.PARENT_PROJECT,
                l_sales_lead_rec.DESCRIPTION,
                l_sales_lead_rec.ATTRIBUTE_CATEGORY,
                l_sales_lead_rec.ATTRIBUTE1, l_sales_lead_rec.ATTRIBUTE2,
                l_sales_lead_rec.ATTRIBUTE3, l_sales_lead_rec.ATTRIBUTE4,
                l_sales_lead_rec.ATTRIBUTE5, l_sales_lead_rec.ATTRIBUTE6,
                l_sales_lead_rec.ATTRIBUTE7, l_sales_lead_rec.ATTRIBUTE8,
                l_sales_lead_rec.ATTRIBUTE9, l_sales_lead_rec.ATTRIBUTE10,
                l_sales_lead_rec.ATTRIBUTE11, l_sales_lead_rec.ATTRIBUTE12,
                l_sales_lead_rec.ATTRIBUTE13, l_sales_lead_rec.ATTRIBUTE14,
                l_sales_lead_rec.ATTRIBUTE15,
                l_sales_lead_rec.BUDGET_STATUS_CODE,
                l_sales_lead_rec.ACCEPT_FLAG,
                l_sales_lead_rec.VEHICLE_RESPONSE_CODE,
                l_sales_lead_rec.TOTAL_SCORE, l_sales_lead_rec.SCORECARD_ID,
                l_sales_lead_rec.KEEP_FLAG, l_sales_lead_rec.URGENT_FLAG,
                l_sales_lead_rec.IMPORT_FLAG,
                l_sales_lead_rec.REJECT_REASON_CODE,
                l_sales_lead_rec.DELETED_FLAG, l_sales_lead_rec.OFFER_ID,
                l_sales_lead_rec.INCUMBENT_PARTNER_PARTY_ID,
                l_sales_lead_rec.INCUMBENT_PARTNER_RESOURCE_ID,
                l_sales_lead_rec.PRM_EXEC_SPONSOR_FLAG,
                l_sales_lead_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
                l_sales_lead_rec.PRM_SALES_LEAD_TYPE,
                l_sales_lead_rec.PRM_IND_CLASSIFICATION_CODE,
                l_sales_lead_rec.QUALIFIED_FLAG,
                l_sales_lead_rec.ORIG_SYSTEM_CODE,
                l_sales_lead_rec.PRM_ASSIGNMENT_TYPE,
                l_sales_lead_rec.AUTO_ASSIGNMENT_TYPE,
                l_sales_lead_rec.PRIMARY_CONTACT_PARTY_ID,
                l_sales_lead_rec.PRIMARY_CNT_PERSON_PARTY_ID,
                l_sales_lead_rec.PRIMARY_CONTACT_PHONE_ID,
                l_sales_lead_rec.REFERRED_BY,
                l_sales_lead_rec.REFERRAL_TYPE,
                l_sales_lead_rec.REFERRAL_STATUS,
                l_sales_lead_rec.REF_DECLINE_REASON,
                l_sales_lead_rec.REF_COMM_LTR_STATUS,
                l_sales_lead_rec.REF_ORDER_NUMBER,
                l_sales_lead_rec.REF_ORDER_AMT,
                l_sales_lead_rec.REF_COMM_AMT,
                l_sales_lead_rec.LEAD_DATE,
                l_sales_lead_rec.SOURCE_SYSTEM,
                l_sales_lead_rec.COUNTRY,
                l_sales_lead_rec.TOTAL_AMOUNT,
                l_sales_lead_rec.EXPIRATION_DATE,
                l_sales_lead_rec.LEAD_ENGINE_RUN_DATE,
                l_sales_lead_rec.LEAD_RANK_IND,
                l_sales_lead_rec.CURRENT_REROUTES;
            CLOSE c_get_sales_lead;
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'desc:' || l_sales_lead_rec.description);
            END IF;

            AS_LEAD_ROUTING_WF_CUHK.Get_Owner_Pre(
                p_api_version_number    =>  2.0,
                p_init_msg_list         =>  FND_API.G_FALSE,
                p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
                p_commit                =>  FND_API.G_FALSE,
                p_resource_id_tbl       =>  g_resource_id_tbl,
                p_group_id_tbl          =>  g_group_id_tbl,
                p_person_id_tbl         =>  g_person_id_tbl,
                p_resource_flag_tbl     =>  g_resource_flag_tbl,
                p_sales_lead_rec        =>  l_sales_lead_rec,
                x_resource_id           =>  l_resource_id,
                x_group_id              =>  l_group_id,
                x_person_id             =>  l_person_id,
                x_return_status         =>  l_return_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data);

            IF l_return_status = fnd_api.g_ret_sts_success THEN
                result := 'COMPLETE:S';
            ELSE
                result := 'COMPLETE:ERROR';
            END IF;
        END IF;

        IF (l_call_user_hook AND l_resource_id IS NULL) OR
            NOT l_call_user_hook
        THEN
            IF NOT l_call_user_hook
            THEN
                IF (AS_DEBUG_LOW_ON) THEN
                    AS_UTILITY_PVT.Debug_Message(
                        FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'There''s no customer user hook');
                END IF;
            ELSE
                IF (AS_DEBUG_LOW_ON) THEN
                    AS_UTILITY_PVT.Debug_Message(
                        FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'User hook doesn''t return resource');
                END IF;
            END IF;

            -- Set the first resource as owner
            -- If owner decline this sales lead and s/he is the only
            -- salesforce in the sales team, s/he will be stuck in it.
            l_resource_id := g_resource_id_tbl(1);
            l_group_id := g_group_id_tbl(1);
            l_person_id := g_person_id_tbl(1);

            IF g_resource_flag_tbl(1) = 'D'
            THEN
                -- Set default resource will have return status 'W' in
                -- StartProcess
                wf_engine.SetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'DEFAULT_RESOURCE_ID',
                    avalue   => l_resource_id);

                OPEN c_get_resource_avail(l_sales_lead_id);
                FETCH c_get_resource_avail INTO l_resource_avail_flag;
                CLOSE c_get_resource_avail;
                IF (AS_DEBUG_LOW_ON) THEN
                    AS_UTILITY_PVT.Debug_Message(
                        FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'res avail?' || l_resource_avail_flag);
                END IF;

                IF l_resource_avail_flag = 'Y'
                THEN
                    -- There are resources available, but they were previous
                    -- lead owners.
                    AS_UTILITY_PVT.Set_Message(
                        p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name  => 'AS_WARN_DEF_RESOURCE_ID');
                ELSE
                    AS_UTILITY_PVT.Set_Message(
                        p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                        p_msg_name  => 'AS_WARN_USING_DEF_RESOURCE_ID');
                END IF;
            ELSIF g_resource_flag_tbl(1) = 'L'
            THEN
                -- Set default resource will have return status 'W' in
                -- StartProcess
                wf_engine.SetItemAttrNumber (
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'DEFAULT_RESOURCE_ID',
                    avalue   => l_resource_id);

                AS_UTILITY_PVT.Set_Message(
                    p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name  => 'AS_WARN_USING_USER_RESOURCE_ID');
            END IF;
        END IF;
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Set owner rs_id=' || l_resource_id);
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                ' group_id=' || l_group_id);
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                ' person_id=' || l_person_id);
        END IF;
        SetResource( itemtype, itemkey, l_resource_id, l_group_id, l_person_id);
        result := 'COMPLETE:S';
    END IF; -- funcmode = 'RUN'

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'GetOwner: End');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
        END IF;
        wf_core.context(
            itemtype,
            'GETOWNER',
            itemtype,
            itemkey, to_char(actid),funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END GetOwner;


PROCEDURE UpdateSalesLeads (
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    result         OUT NOCOPY VARCHAR2 )
IS
    l_customer_id          NUMBER;
    l_address_id           NUMBER;
    l_sales_lead_id        NUMBER := NULL;
    l_resource_id          NUMBER;
    l_group_id             NUMBER;
    l_person_id            NUMBER;
    l_access_exist_flag    VARCHAR2(1);
    l_status_code          VARCHAR2(30);
    l_sales_lead_log_id    NUMBER;
    l_reject_reason_code   VARCHAR2(30);
    l_lead_rank_id         NUMBER;
    l_qualified_flag       VARCHAR2(1);
    l_freeze_flag          VARCHAR2(1);
    l_open_status_flag     VARCHAR2(1);
    l_lead_rank_score      NUMBER;
    l_creation_date        DATE;

    CURSOR c_access_exist(c_sales_lead_id NUMBER, c_resource_id NUMBER,
                        c_group_id NUMBER) IS
      SELECT freeze_flag
      FROM as_accesses_all
      WHERE sales_lead_id = c_sales_lead_id
      AND   salesforce_id = c_resource_id
      AND ((sales_group_id = c_group_id) OR
           (sales_group_id IS NULL AND c_group_id IS NULL));

    CURSOR c_sales_lead(c_sales_lead_id NUMBER) IS
      SELECT customer_id, address_id, reject_reason_code,
             lead_rank_id, qualified_flag, NVL(accept_flag, 'N'), status_code
      FROM as_sales_leads
      WHERE Sales_lead_id = c_sales_lead_id;

    -- Get whether status is open or not for the lead
    -- Get lead_rank_score and lead creation_date
    CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
      SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
             rk.min_score, sl.creation_date
      FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
      WHERE sl.sales_lead_id = c_sales_lead_id
      AND   sl.status_code = sta.status_code
      AND   sl.lead_rank_id = rk.rank_id(+);
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'UpdateSalesLeads: Start');
    END IF;
    IF funcmode = 'RUN'
    THEN
        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'SALES_LEAD_ID' );

        l_resource_id := wf_engine.GetItemAttrNumber(
                             itemtype => itemtype,
                             itemkey => itemkey,
                             aname => 'RESOURCE_ID' );

        l_group_id := wf_engine.GetItemAttrNumber(
                          itemtype => itemtype,
                          itemkey => itemkey,
                          aname => 'GROUP_ID' );

        l_person_id := wf_engine.GetItemAttrNumber(
                           itemtype => itemtype,
                           itemkey => itemkey,
                           aname => 'PERSON_ID' );

        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'res id in upd=' || l_Resource_Id);
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'group id in upd='||l_group_id);
        END IF;

        OPEN c_sales_lead(l_sales_lead_id);
        FETCH c_sales_lead INTO l_customer_id, l_address_id,
                                l_reject_reason_code, l_lead_rank_id,
                                l_qualified_flag, l_freeze_flag, l_status_code;
        CLOSE c_sales_lead;

        -- Call API to create log entry
        AS_SALES_LEADS_LOG_PKG.Insert_Row(
            px_log_id                 => l_sales_lead_log_id ,
            p_sales_lead_id           => l_sales_lead_id,
            p_created_by              => fnd_global.user_id,
            p_creation_date           => SYSDATE,
            p_last_updated_by         => fnd_global.user_id,
            p_last_update_date        => SYSDATE,
            p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
            p_request_id              => FND_GLOBAL.Conc_Request_Id,
            p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
            p_program_id              => FND_GLOBAL.Conc_Program_Id,
            p_program_update_date     => SYSDATE,
            p_status_code             => l_status_code,
            p_assign_to_person_id     => l_person_id,
            p_assign_to_salesforce_id => l_resource_id,
            p_reject_reason_code      => l_reject_reason_code,
            p_assign_sales_group_id   => l_group_id,
            p_lead_rank_id            => l_lead_rank_id,
            p_qualified_flag          => l_qualified_flag,
            p_category                => NULL);

        -- Call table handler directly, not calling Update_Sales_Lead,
        -- in case current user doesn't have update privilege.
        AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
            p_SALES_LEAD_ID  => l_SALES_LEAD_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_CREATION_DATE  => FND_API.G_MISS_DATE,
            p_CREATED_BY  => FND_API.G_MISS_NUM,
            p_LAST_UPDATE_LOGIN  => FND_API.G_MISS_NUM,
            p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
            p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
            p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
            p_PROGRAM_UPDATE_DATE  => SYSDATE,
            p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
            p_STATUS_CODE => FND_API.G_MISS_CHAR,
            p_CUSTOMER_ID  => l_CUSTOMER_ID,
            p_ADDRESS_ID  => l_ADDRESS_ID,
            p_SOURCE_PROMOTION_ID  => FND_API.G_MISS_NUM,
            p_INITIATING_CONTACT_ID => FND_API.G_MISS_NUM,
            p_ORIG_SYSTEM_REFERENCE => FND_API.G_MISS_CHAR,
            p_CONTACT_ROLE_CODE  => FND_API.G_MISS_CHAR,
            p_CHANNEL_CODE  => FND_API.G_MISS_CHAR,
            p_BUDGET_AMOUNT  => FND_API.G_MISS_NUM,
            p_CURRENCY_CODE  => FND_API.G_MISS_CHAR,
            p_DECISION_TIMEFRAME_CODE => FND_API.G_MISS_CHAR,
            p_CLOSE_REASON  => FND_API.G_MISS_CHAR,
            p_LEAD_RANK_ID  => FND_API.G_MISS_NUM,
            p_LEAD_RANK_CODE  => FND_API.G_MISS_CHAR,
            p_PARENT_PROJECT  => FND_API.G_MISS_CHAR,
            p_DESCRIPTION  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE_CATEGORY  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE1  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE2  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE3  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE4  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE5  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE6  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE7  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE8  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE9  => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE15 => FND_API.G_MISS_CHAR,
            p_ASSIGN_TO_PERSON_ID  => l_person_id,
            p_ASSIGN_TO_SALESFORCE_ID => l_resource_id,
            p_ASSIGN_SALES_GROUP_ID => l_group_id,
            p_ASSIGN_DATE  => SYSDATE,
            p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
            p_ACCEPT_FLAG  => 'N',
            p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
            p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
            p_SCORECARD_ID  => FND_API.G_MISS_NUM,
            p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
            p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
            p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
            p_REJECT_REASON_CODE  => NULL,
            p_DELETED_FLAG => FND_API.G_MISS_CHAR,
            p_OFFER_ID  =>  FND_API.G_MISS_NUM,
            p_QUALIFIED_FLAG => l_qualified_flag,
            p_ORIG_SYSTEM_CODE => FND_API.G_MISS_CHAR,
            p_INC_PARTNER_PARTY_ID => FND_API.G_MISS_NUM,
            p_INC_PARTNER_RESOURCE_ID => FND_API.G_MISS_NUM,
            p_PRM_EXEC_SPONSOR_FLAG   => FND_API.G_MISS_CHAR,
            p_PRM_PRJ_LEAD_IN_PLACE_FLAG => FND_API.G_MISS_CHAR,
            p_PRM_SALES_LEAD_TYPE     => FND_API.G_MISS_CHAR,
            p_PRM_IND_CLASSIFICATION_CODE => FND_API.G_MISS_CHAR,
            p_PRM_ASSIGNMENT_TYPE => FND_API.G_MISS_CHAR,
            p_AUTO_ASSIGNMENT_TYPE => FND_API.G_MISS_CHAR,
            p_PRIMARY_CONTACT_PARTY_ID => FND_API.G_MISS_NUM,
            p_PRIMARY_CNT_PERSON_PARTY_ID => FND_API.G_MISS_NUM,
            p_PRIMARY_CONTACT_PHONE_ID => FND_API.G_MISS_NUM,
            p_REFERRED_BY => FND_API.G_MISS_NUM,
            p_REFERRAL_TYPE => FND_API.G_MISS_CHAR,
            p_REFERRAL_STATUS => FND_API.G_MISS_CHAR,
            p_REF_DECLINE_REASON => FND_API.G_MISS_CHAR,
            p_REF_COMM_LTR_STATUS => FND_API.G_MISS_CHAR,
            p_REF_ORDER_NUMBER => FND_API.G_MISS_NUM,
            p_REF_ORDER_AMT => FND_API.G_MISS_NUM,
            p_REF_COMM_AMT => FND_API.G_MISS_NUM,
            -- bug No.2341515, 2368075
            p_LEAD_DATE =>  FND_API.G_MISS_DATE,
            p_SOURCE_SYSTEM => FND_API.G_MISS_CHAR,
            p_COUNTRY => FND_API.G_MISS_CHAR,
            p_TOTAL_AMOUNT => FND_API.G_MISS_NUM,
            p_EXPIRATION_DATE => FND_API.G_MISS_DATE,
            p_LEAD_RANK_IND => FND_API.G_MISS_CHAR,
            p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE,
            p_CURRENT_REROUTES => FND_API.G_MISS_NUM,
            p_STATUS_OPEN_FLAG => FND_API.G_MISS_CHAR,
            p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM,
            -- 11.5.10 new columns
            p_MARKETING_SCORE => FND_API.G_MISS_NUM,
            p_INTERACTION_SCORE => FND_API.G_MISS_NUM,
            p_SOURCE_PRIMARY_REFERENCE => FND_API.G_MISS_CHAR,
            p_SOURCE_SECONDARY_REFERENCE => FND_API.G_MISS_CHAR,
            p_SALES_METHODOLOGY_ID => FND_API.G_MISS_NUM,
            p_SALES_STAGE_ID => FND_API.G_MISS_NUM);


        OPEN c_access_exist(l_sales_lead_id, l_resource_id, l_group_id);
        FETCH c_access_exist INTO l_access_exist_flag;
        CLOSE c_access_exist;

        -- Clear owner in as_accesses_all.
        -- There may be more than one owner_flag='Y' for the lead in
        -- as_accesses_all:
        -- 1. When owner rejects the lead
        -- 2. When monitoring engine times out
        UPDATE as_accesses_all
        SET owner_flag = 'N'
        WHERE sales_lead_id = l_sales_lead_id;

        IF l_access_exist_flag IS NOT NULL
        THEN
            -- If the owner was frozen in the sales team, he is still frozen in
            -- the sales team. No matter whether he accept the lead or not.
            IF l_access_exist_flag = 'Y'
            THEN
                l_freeze_flag := 'Y';
            END IF;
            UPDATE as_accesses_all
            SET team_leader_flag = 'Y',
                owner_flag = 'Y',
                freeze_flag = l_freeze_flag,
                created_by_tap_flag = 'Y'
            WHERE sales_lead_id = l_sales_lead_id
            AND   salesforce_id = l_resource_id
            AND ((sales_group_id = l_group_id) OR
                 (sales_group_id IS NULL AND l_group_id IS NULL));
        ELSE
            OPEN c_get_open_status_flag(l_sales_lead_id);
            FETCH c_get_open_status_flag INTO l_open_status_flag,
                l_lead_rank_score, l_creation_date;
            CLOSE c_get_open_status_flag;

            INSERT INTO as_accesses_all
                (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY
                ,CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
                ,ACCESS_TYPE, FREEZE_FLAG, REASSIGN_FLAG, TEAM_LEADER_FLAG
                ,OWNER_FLAG, CREATED_BY_TAP_FLAG
                ,CUSTOMER_ID, ADDRESS_ID, SALES_LEAD_ID, SALESFORCE_ID
                ,PERSON_ID, SALES_GROUP_ID, OPEN_FLAG, LEAD_RANK_SCORE
                ,OBJECT_CREATION_DATE)
            SELECT as_accesses_s.nextval, SYSDATE, FND_GLOBAL.USER_ID,
                SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, 'X',
                l_freeze_flag ,'N', 'Y', 'Y', 'Y',
                l_customer_id, l_address_id, l_sales_lead_id,
                l_resource_id, l_person_id, l_group_id, l_open_status_flag,
                l_lead_rank_score, l_creation_date
            FROM SYS.DUAL;
        END IF; -- l_access_exist_flag IS NOT NULL

        result := 'COMPLETE:S';
    END IF; -- funcmode = 'RUN'
    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'UpdateSalesLeads: End');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context(itemtype, 'UpdateSalesLeads', itemtype, itemkey,
                        to_char(actid), funcmode);
        result := 'COMPLETE:ERROR';
        RAISE;
END UpdateSalesLeads;

-----------------------------------
-- rest of the code in this file from here on till the end - is not used
-- do not spend any time on it.
-----------------------------------

-------------------------------------------------------------


PROCEDURE GetAvailableResources (
    itemtype         in VARCHAR2,
    itemkey          in VARCHAR2,
    actid            in NUMBER,
    funcmode         in VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )
IS

    l_available_resources   available_resource_table;

    l_sales_lead_id     NUMBER;
    l_return_status     VARCHAR2(15);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_Assign_Id_tbl     AS_SALES_LEADS_PUB.Assign_Id_Tbl_Type;

BEGIN

    IF funcmode = 'RUN' THEN

        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname => 'SALES_LEAD_ID' );

--	   AS_SALES_LEADS_PVT.Assign_Sales_Lead (
	   AS_SALES_LEAD_ASSIGN_PVT.Assign_Sales_Lead (
            P_Api_Version_Number       =>  2.0,
            P_Init_Msg_List            =>  FND_API.G_FALSE,
            p_commit                   =>  FND_API.G_FALSE,
            p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
            P_Check_Access_Flag        =>  FND_API.G_MISS_CHAR,
            P_Admin_Flag               =>  FND_API.G_MISS_CHAR,
            P_Admin_Group_Id           =>  FND_API.G_MISS_NUM,
            P_identity_salesforce_id   =>  FND_API.G_MISS_NUM,
            P_Sales_Lead_Profile_Tbl   =>  AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
            P_resource_type            =>  NULL,
            P_role                     =>  NULL,
            P_no_of_resources          =>  999,
            P_auto_select_flag         =>  NULL,
            P_effort_duration          =>  8,
            P_effort_uom               =>  'HR',
            P_start_date               =>  sysdate-1,
            P_end_date                 =>  sysdate+1,
            P_territory_flag           =>  'Y',
            P_calendar_flag            =>  'Y',
            P_Sales_Lead_Id            =>  l_sales_lead_id,
            X_Return_Status            =>  l_return_status,
            X_Msg_Count                =>  l_msg_count,
            X_Msg_Data                 =>  l_msg_data,
            X_Assign_Id_Tbl            =>  l_Assign_Id_tbl
            );

        IF l_Assign_Id_tbl.count = 0 THEN
		  result := 'COMPLETE:NORES';
            IF (AS_DEBUG_ERROR_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                         'JTF AM - No resource found!');
            END IF;
            return;
        ELSE
            IF l_Assign_Id_tbl.COUNT > 0 THEN
               FOR i in l_Assign_Id_tbl.first..l_Assign_Id_tbl.last LOOP
                  l_available_resources(i).Resource_Id
						:=l_Assign_Id_tbl(i).Resource_Id;
                  l_available_resources(i).Group_id
						:=l_Assign_Id_tbl(i).Sales_Group_Id;
               END LOOP;
            END IF;

            g_available_resource_table := l_available_resources;
            result := 'COMPLETE:S';
        END IF;
    END IF;

    EXCEPTION
	   when others then
		  wf_core.context(itemtype, 'GetAvailableResources', itemtype,
                            itemkey, to_char(actid),funcmode);
		  result := 'COMPLETE:ERROR';
		  raise;
END GetAvailableResources;


PROCEDURE GetResourceWorkload (
    itemtype       in VARCHAR2,
    itemkey        in VARCHAR2,
    actid          in NUMBER,
    funcmode       in VARCHAR2,
    result         OUT NOCOPY VARCHAR2 )
IS
    CURSOR c_workload (resource_id_in number) IS
        SELECT count(sales_lead_id)
        FROM as_sales_leads
        WHERE assign_to_salesforce_id = resource_id_in;

    l_resource_cnt  NUMBER := 0;
    l_avail_resources      available_resource_table;
    l_resource_rownum NUMBER;

BEGIN

    IF funcmode = 'RUN' THEN
        l_avail_resources := g_available_resource_table;

        -- solin
        -- change to use while loop because l_avail_resources.first may be
        -- 0 or 1
        l_resource_rownum := l_avail_resources.first;
        WHILE l_resource_rownum <= l_avail_resources.last
        LOOP
            OPEN c_workload(l_avail_resources(l_resource_rownum).resource_id);
            FETCH c_workload INTO l_avail_resources(l_resource_rownum).workload;
            CLOSE c_workload;
            l_resource_rownum := l_resource_rownum + 1;
        END LOOP;

        g_available_resource_table := l_avail_resources;

        result := 'COMPLETE:S';
    END IF;

    EXCEPTION
	   when others then
		--
		  wf_core.context(itemtype, 'GetResourceWorkload', itemtype, itemkey,
                            to_char(actid),funcmode);
		  result := 'COMPLETE:ERROR';
		  raise;
END GetResourceWorkload;


PROCEDURE BalanceWorkload (
    itemtype       in VARCHAR2,
    itemkey        in VARCHAR2,
    actid          in NUMBER,
    funcmode       in VARCHAR2,
    result         OUT NOCOPY VARCHAR2 )
IS
    l_rowcnt INTEGER;
    l_available_resources available_resource_table;
    l_leastwork_resource resource_record_type;
    l_selected_id NUMBER;
    l_selected_group_id NUMBER;
    l_logcount NUMBER;
    l_never_assigned NUMBER := 0;
    l_sales_lead_id NUMBER;

    CURSOR c_checklog (resource_id_in number, sl_id_in number) IS
        SELECT count(log_id)
        FROM as_sales_leads_log
        WHERE assign_to_salesforce_id = resource_id_in
		    and sales_lead_id = sl_id_in;

BEGIN
    l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname  	=> 'SALES_LEAD_ID' );

    IF funcmode = 'RUN' THEN
        l_available_resources := g_available_resource_table;

        IF l_available_resources.count > 0
        THEN
            -- solin
            -- change to use while loop because l_available_resources.first may
            -- be 0 or 1
            l_rowcnt := l_available_resources.first;
            l_leastwork_resource := l_available_resources(l_rowcnt);
            WHILE l_rowcnt <= l_available_resources.last
            LOOP
                IF l_available_resources(l_rowcnt).workload <=
                           l_leastwork_resource.workload
                THEN
                    -- Has it been worked on by that resource before ?

                    -- 012201 FFANG, sales leads can be assigned back to the
                    -- sales reps who have worked on it.
                    /* ***
                    OPEN c_checklog(l_available_resources(l_rowcnt).resource_id,
    	    					  l_sales_lead_id);
                    FETCH c_checklog INTO l_logcount;
                    CLOSE c_checklog;
                    IF l_logcount = 0 THEN
				*** */
                        l_leastwork_resource := l_available_resources(l_rowcnt);
                        l_never_assigned := l_never_assigned + 1 ;
                    /* ***
                    END IF;
                    *** */
                END IF;
                l_rowcnt := l_rowcnt + 1;
            END LOOP;
        END IF;

        IF l_never_assigned > 0 THEN
            l_selected_id := l_leastwork_resource.resource_id;
            l_selected_group_id := l_leastwork_resource.group_id;

            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname  => 'RESOURCE_ID',
                                    avalue => l_selected_id);

            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname  => 'BUSINESS_GROUP_ID',
                                    avalue => l_selected_group_id);
            result := 'COMPLETE:S';
        ELSE
            -- Escalate it to the manager of the person with least workload
            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname  => 'BUSINESS_GROUP_ID',
                                  avalue => l_leastwork_resource.group_id);
            result := 'COMPLETE:ESCALATE';
        END IF;
    END IF;

    EXCEPTION
   	when others then
         wf_core.context(Itemtype, 'BalanceWorkload', itemtype, itemkey,
                         to_char(actid),funcmode);
         result := 'COMPLETE:ERROR';
         raise;
END BalanceWorkload      ;


PROCEDURE EscalatetoManager (
    itemtype       in VARCHAR2,
    itemkey        in VARCHAR2,
    actid          in NUMBER,
    funcmode       in VARCHAR2,
    result         OUT NOCOPY VARCHAR2 )
IS
    CURSOR c_manager ( group_id_in number) IS
        SELECT manager_id
        FROM  jtf_rs_group_dtls_vl
        WHERE group_id = group_id_in;

    l_sales_lead_rec       AS_SALES_LEADS_PUB.sales_lead_rec_type;
    l_sales_lead_profile_tbl   AS_UTILITY_PUB.Profile_Tbl_Type
                               := AS_UTILITY_PUB.G_MISS_PROFILE_TBL;

    l_api_version_number   NUMBER := 2.0;
    l_cnt                  NUMBER := 0;
    l_sales_lead_id        NUMBER;
    l_resource_id          NUMBER;
    l_status_code          VARCHAR2(30);
    l_last_update_date     DATE  := SYSDATE;
    l_return_status        VARCHAR2(15);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_msg_index_out        NUMBER;
    l_group_id             NUMBER;
    l_manager_id	       NUMBER;
    l_origowner_id         NUMBER;

    CURSOR c_sales_lead(x_sales_lead_id NUMBER) IS
    SELECT last_update_date,
           customer_id,
           address_id,
           assign_sales_group_id,
           sales_lead_id
    FROM as_sales_leads
    WHERE sales_lead_id = x_sales_lead_id;

BEGIN

    IF funcmode = 'RUN' THEN
        l_group_id :=  wf_engine.GetItemAttrNumber(
                            itemtype => itemtype,
                            itemkey => itemkey,
                            aname => 'BUSINESS_GROUP_ID' );


        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'SALES_LEAD_ID' );

        -- get the group manager resource id
        OPEN c_manager(l_group_id);
        FETCH c_manager INTO l_manager_id;
        IF c_manager%notfound THEN
            -- ffang 110200, forgot to close cursor?
            CLOSE c_manager;
            -- end ffang 110200

            -- assign it to the original owner

            l_origowner_id := wf_engine.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'ORIG_RESOURCE_ID' );

            wf_engine.SetItemAttrNumber ( itemtype => itemtype,
                                          itemkey => itemkey,
                                          aname => 'RESOURCE_ID',
                                          avalue => l_origowner_id);
            IF l_origowner_id is NULL THEN
                l_group_id := NULL;
                wf_engine.SetItemAttrNumber ( itemtype => itemtype,
                                          itemkey => itemkey,
                                          aname => 'BUSINESS_GROUP_ID',
                                          avalue => l_group_id);
            END IF;

            result := 'COMPLETE:NOMGR';
        ELSE
            -- escalate to the group manager
            OPEN c_sales_lead(l_sales_lead_id);
            FETCH c_sales_lead INTO l_sales_lead_rec.last_update_date,
                           l_sales_lead_rec.customer_id,
                           l_sales_lead_rec.address_id,
                           l_sales_lead_rec.assign_sales_group_id,
                           l_sales_lead_rec.sales_lead_id;
            CLOSE c_sales_lead;

            -- Now reassign escalated lead to the manager
            l_sales_lead_rec.assign_to_salesforce_id := l_manager_id;

            AS_SALES_LEADS_PUB.update_sales_lead(
                   p_api_version_number     => l_api_version_number
                  ,p_init_msg_list          => fnd_api.g_FALSE
                  ,p_commit                 => fnd_api.g_false
                  ,p_validation_level       => 0 -- fnd_api.g_valid_level_full
                  ,p_check_access_flag      => 'N' -- fnd_api.g_miss_char
                  ,p_admin_flag             => fnd_api.g_miss_char
                  ,p_admin_group_id         => fnd_api.g_miss_num
                  ,p_identity_salesforce_id => fnd_api.g_miss_num
                  ,p_sales_lead_profile_tbl => l_sales_lead_profile_tbl
                  ,p_sales_lead_rec         => l_sales_lead_rec
                  ,x_return_status          => l_return_status
                  ,x_msg_count              => l_msg_count
                  ,x_msg_data               => l_msg_data
                  );

            CLOSE c_manager;

            IF l_return_status = fnd_api.g_ret_sts_success THEN
                result := 'COMPLETE:S';
            ELSE
     	      result := 'COMPLETE:ERROR';
            END IF;
        END IF;
    END IF;

    EXCEPTION
   	   when others then
		  wf_core.context(Itemtype, 'EscalatetoManager', itemtype, itemkey,
                            to_char(actid), funcmode);
		  result := 'COMPLETE:ERROR';
		  raise;

END EscalatetoManager;


END AS_LEAD_ROUTING_WF;


/
