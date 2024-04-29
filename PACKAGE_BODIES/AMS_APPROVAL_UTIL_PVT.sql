--------------------------------------------------------
--  DDL for Package Body AMS_APPROVAL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVAL_UTIL_PVT" as
/* $Header: amsvuapb.pls 120.2.12010000.1 2008/07/24 15:18:56 appldev ship $ */
 PROCEDURE Get_Object_Owner(itemtype          IN       VARCHAR2,
                            itemkey           IN       VARCHAR2,
                            x_approver_id     OUT NOCOPY      NUMBER,
                            x_return_status   OUT NOCOPY      VARCHAR2)

IS
l_activity_type    VARCHAR2(30);
l_activity_id      NUMBER;
l_return_status    VARCHAR2(1);
l_table_name       VARCHAR2(30);
l_pk_name          VARCHAR2(30);
l_stmt             VARCHAR2(200);
l_owner_id         NUMBER;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  -- Determine the Activity Type

  l_activity_type  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE');

  IF l_activity_type NOT IN ('CAMP','CSCH','EVEH', 'EVEO', 'EONE',
                             'DELV','OFFR') THEN -- 4378800 Added OFFR
    Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Determine the Primary Key

  l_activity_id  := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
				 aname    => 'AMS_ACTIVITY_ID');


  -- Get the Table and PK

  Ams_Utility_Pvt.get_qual_table_name_and_pk(p_sys_qual => l_activity_type,
                                             x_return_status => x_return_status,
					     x_table_name => l_table_name,
					     x_pk_name => l_pk_name);


  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
      Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_NOAPPR');
      Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Get the owner_user_id from the table
  l_stmt := 'SELECT owner_user_id FROM '||l_table_name||' where '||l_pk_name||' = :b1';

  -- Change the owner_user_id to owner_id when the activity type is offer : Bug#6337333
  IF l_activity_type IN ('OFFR') THEN
	l_stmt := 'SELECT owner_id FROM '||l_table_name||' where '||l_pk_name||' = :b1';
  END IF;


  EXECUTE IMMEDIATE l_stmt INTO l_owner_id USING l_activity_id;

  x_approver_id := l_owner_id;

END Get_Object_Owner;


PROCEDURE Get_Parent_Object_Owner(itemtype           IN       VARCHAR2,
                                   itemkey           IN       VARCHAR2,
                                   x_approver_id     OUT NOCOPY      NUMBER,
                                   x_return_status   OUT NOCOPY      VARCHAR2)
IS
l_activity_type    VARCHAR2(30);
l_activity_id      NUMBER;
l_owner_id         NUMBER;

TYPE owner_csr_type IS REF CURSOR ;
l_owner_details owner_csr_type;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Determine the Activity Type

  l_activity_type  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE');

  IF l_activity_type NOT IN ('CSCH','EVEO', 'OFFR') THEN
    Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF l_activity_type IN ('CSCH','EVEO') AND
     NVL(Fnd_Profile.Value(name => 'AMS_SOURCE_FROM_PARENT'), 'N') = 'N' THEN
    Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Determine the Primary Key

  l_activity_id  := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
				 aname    => 'AMS_ACTIVITY_ID');

  IF l_activity_type = 'CSCH' THEN
    OPEN l_owner_details  FOR
    SELECT B.owner_user_id
    FROM ams_campaign_schedules_vl A, ams_campaigns_vl B
    WHERE B.campaign_id = A.campaign_id
    AND A.schedule_id = l_activity_id;
  ELSIF l_activity_type = 'EVEO' THEN
    OPEN l_owner_details  FOR
    SELECT B.owner_user_id
    FROM ams_event_offers_vl A, ams_event_headers_vl B
    WHERE B.event_header_id = A.event_header_id
    AND A.event_offer_id = l_activity_id;
  ELSIF l_activity_type = 'OFFR' THEN
    OPEN l_owner_details  FOR
    SELECT B.owner_user_id
    FROM ams_act_offers A, ams_campaigns_vl B
    WHERE B.campaign_id = A.act_offer_used_by_id
    AND A.arc_act_offer_used_by = 'CAMP'
    AND A.qp_list_header_id = l_activity_id;
  END IF;

  FETCH l_owner_details INTO l_owner_id;
    IF l_owner_details%NOTFOUND THEN
      CLOSE l_owner_details;
      Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_NOAPPR');
      Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RETURN;
    END IF;
  CLOSE l_owner_details;

  x_approver_id := l_owner_id;

END Get_Parent_Object_Owner;

PROCEDURE Get_Budget_Owner(itemtype           IN       VARCHAR2,
                            itemkey           IN       VARCHAR2,
                            x_approver_id     OUT NOCOPY      NUMBER,
                            x_return_status   OUT NOCOPY      VARCHAR2)
IS
l_budget_id        NUMBER;
l_owner_id         NUMBER;
l_activity_type    VARCHAR2(30);
l_activity_id      NUMBER;

CURSOR c_fund_owner IS
SELECT owner
FROM ozf_funds_all_b
WHERE fund_id = l_budget_id;

-- Change for SQL Repository Perf Fix
/*
CURSOR c_budget_source_owner IS
SELECT owner
from ozf_funds_all_b
WHERE fund_id IN (SELECT budget_source_id
                    FROM ozf_act_budgets
		   WHERE activity_budget_id = l_activity_id);
*/
CURSOR c_budget_source_owner IS
SELECT f.owner
FROM ozf_funds_all_b f, ozf_act_budgets a
WHERE f.fund_id = a.budget_source_id
AND a.activity_budget_id = l_activity_id;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  l_activity_type  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE');


  IF l_activity_type NOT IN ('CAMP','CSCH','EVEH', 'EVEO', 'EONE',
                             'DELV', 'FREQ','OFFR') THEN -- 4378800 Added OFFR
    Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

    l_activity_id  := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
				 aname    => 'AMS_ACTIVITY_ID');

  -- Determine the Budget ID
  IF l_activity_type <> 'FREQ' THEN
    l_budget_id  := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_BUDGET_ID',
				 ignore_notfound => true);

   IF l_budget_id IS NOT NULL THEN

    OPEN c_fund_owner;
    FETCH c_fund_owner INTO l_owner_id;
      IF c_fund_owner%NOTFOUND THEN
        CLOSE c_fund_owner;
        -- Set Message here
	Fnd_Message.Set_Name('AMS','AMS_CAMP_BAD_FUND_SOURCE_ID');
	Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        RETURN;
      END IF;
    CLOSE c_fund_owner;

  ELSE

    Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID'); -- Not Budget Line
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
 END IF;

  ELSE -- it is FREQ
     OPEN c_budget_source_owner;
     FETCH c_budget_source_owner INTO l_owner_id;

     IF c_budget_source_owner%NOTFOUND THEN
        CLOSE c_budget_source_owner;
        -- Set Message here
	Fnd_Message.Set_Name('AMS','AMS_CAMP_BAD_FUND_SOURCE_ID');
	Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        RETURN;
    END IF;
    CLOSE c_budget_source_owner;

  END IF;

   x_approver_id := l_owner_id;

END Get_Budget_Owner;

PROCEDURE Get_Parent_Budget_Owner(itemtype    IN       VARCHAR2,
                            itemkey           IN       VARCHAR2,
                            x_approver_id     OUT NOCOPY      NUMBER,
                            x_return_status   OUT NOCOPY      VARCHAR2)
IS
l_activity_type    VARCHAR2(30);
l_activity_id      NUMBER;
l_owner_id         NUMBER;

CURSOR c_parent_fund_owner IS
SELECT B.owner
FROM ozf_funds_all_b A, ozf_funds_all_b B
WHERE A.parent_fund_id = B.fund_id
AND B.fund_id = l_activity_id;

CURSOR c_budget_source_par_owner IS
-- Will return owner if budget is a parent
SELECT B.owner
FROM ozf_funds_all_b A, ozf_funds_all_b B
WHERE A.parent_fund_id = B.fund_id
AND B.fund_id IN (SELECT budget_source_id
                    FROM ozf_act_budgets
		    WHERE activity_budget_id = l_activity_id);


BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  l_activity_type  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE');

  IF l_activity_type NOT IN ('RFRQ', 'FREQ') THEN
    Fnd_Message.Set_Name('AMS','AMS_APPR_FUNC_INVALID');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Determine the Budget ID

  l_activity_id  := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID');

  IF l_activity_type = 'RFRQ' THEN
     OPEN c_parent_fund_owner;
     FETCH c_parent_fund_owner INTO l_owner_id;
     IF c_parent_fund_owner%NOTFOUND THEN
        CLOSE c_parent_fund_owner;
        Fnd_Message.Set_Name('AMS','AMS_CAMP_BAD_FUND_SOURCE_ID');
	Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        RETURN;
     END IF;
     CLOSE c_parent_fund_owner;
  ELSE
     OPEN c_budget_source_par_owner;
     FETCH c_budget_source_par_owner INTO l_owner_id;
     IF c_budget_source_par_owner%NOTFOUND THEN
        CLOSE c_budget_source_par_owner;
        Fnd_Message.Set_Name('AMS','AMS_CAMP_BAD_FUND_SOURCE_ID');
	Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        RETURN;
     END IF;
     CLOSE c_budget_source_par_owner;
  END IF;

     x_approver_id := l_owner_id;

END Get_Parent_Budget_Owner;
END ams_approval_util_pvt;

/
