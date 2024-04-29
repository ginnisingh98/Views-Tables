--------------------------------------------------------
--  DDL for Package Body OKE_COMM_ACT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_COMM_ACT_UTILS" AS
/* $Header: OKEACTUB.pls 120.1.12010000.2 2008/09/29 10:49:08 rriyer ship $ */

--
--  Name          : Update_Text
--  Pre-reqs      : None
--  Function      : This procedure updates communication text
--
PROCEDURE Update_Text(
             X_k_header_id                NUMBER,
             X_communication_num          VARCHAR2,
             X_text                       VARCHAR2
  ) is

begin

  update OKE_K_COMMUNICATIONS
  set text = X_text
  where k_header_id = X_k_header_id
  and communication_num = X_communication_num;

end Update_Text;


--
--  Name          : Action_Workflow
--  Pre-reqs      : None
--  Function      : This procedure launches the workflow when
--                  a communication was created
--                  or the communication action was changed
--
PROCEDURE Action_Workflow
( P_K_Header_ID        IN  NUMBER
, P_K_Line_ID          IN  NUMBER
, P_Deliverable_ID     IN  NUMBER
, P_Communication_Num  IN  VARCHAR2
, P_Type_Name          IN  VARCHAR2
, P_Reason_Name        IN  VARCHAR2
, P_Party_Name         IN  VARCHAR2
, P_Party_Location     IN  VARCHAR2
, P_Party_Role         IN  VARCHAR2
, P_Party_Contact      IN  VARCHAR2
, P_New_Action_Code    IN  VARCHAR2
, P_Owner              IN  NUMBER
, P_Priority_Name      IN  VARCHAR2
, P_Communication_Date IN  DATE
, P_Communication_Text IN  VARCHAR2
, P_Updated_By         IN  NUMBER
, P_Update_Date        IN  DATE
, P_Login_ID           IN  NUMBER
, P_WF_ITEM_KEY        OUT NOCOPY VARCHAR2
) IS

  CURSOR kh IS
    SELECT k_number
          ,k_type
          ,authoring_org_id
    FROM   oke_k_headers_full_v
    WHERE  k_header_id = P_K_Header_ID;

  CURSOR kl IS
    SELECT line_number
    FROM   oke_k_lines_full_v
    WHERE  k_line_id = P_K_Line_ID;

  CURSOR kd IS
    SELECT deliverable_num
    FROM   oke_k_deliverables_vl
    WHERE  Deliverable_id = P_Deliverable_ID;

  CURSOR o IS
    SELECT user_name
    FROM   fnd_user
    WHERE  user_id = P_Updated_By;

  CURSOR   new_action IS
    SELECT wf_item_type
    ,      wf_process
    ,      comm_action_name
    FROM   oke_comm_actions_vl
    WHERE  comm_action_code = P_New_Action_Code;

-- Jun 20, 2002 : bug 2435609. Person_id is not unique.
-- Add effective_start_date and effective_end_date.
-- Only one person can be active at one time.
--
-- Aut 08, 2003 : bug 3051397. Send notification to Action Owner
-- if action owner is a WF_ROLE (must be a FND_USER), otherwise send to
-- Requestor who log the communication.
-- Use wf_roiles instead of per_people_f
  CURSOR p IS
    SELECT name, display_name
    FROM   wf_roles
    WHERE  orig_system = 'PER'
    AND    orig_system_id = P_Owner;

  l_wf_item_type          VARCHAR2(8);
  l_wf_process            VARCHAR2(30);
  l_wf_item_key           VARCHAR2(240);
  l_wf_user_key           VARCHAR2(240);

-- Aug 08, 2003 Bug 3051397. Change variable length from 30 to 100
-- according to the column length of FND_USER
  l_user_name             VARCHAR2(100);
  l_requestor             VARCHAR2(100);

  l_contract_num          VARCHAR2(240);
  l_k_type                VARCHAR2(240);
  l_line_number           VARCHAR2(240);
  l_dts_number            VARCHAR2(240);
  l_new_action            VARCHAR2(240);
  l_action_owner          VARCHAR2(240);
  l_org_id                NUMBER;

BEGIN

  OPEN  new_action;
  FETCH new_action INTO l_wf_item_type , l_wf_process , l_new_action;
  CLOSE new_action;

  IF ( l_wf_item_type IS NOT NULL and l_wf_process IS NOT NULL) THEN

    OPEN  kh;
    FETCH kh INTO l_contract_num,l_k_type,l_org_id;
    CLOSE kh;

    OPEN  kl;
    FETCH kl INTO l_line_number;
    CLOSE kl;

    OPEN  kd;
    FETCH kd INTO l_dts_number;
    CLOSE kd;

    OPEN  o;
    FETCH o INTO l_user_name;
    CLOSE o;

--    OPEN  p;
--    FETCH p INTO l_action_owner;
--    CLOSE p;
-- Aut 08, 2003 : bug 3051397. Send notification to Action Owner
-- if action owner is a WF_ROLE, otherwise send to
-- Requestor who log the communication.

    IF (P_Owner is null) THEN
      l_requestor := l_user_name;
    ELSE
      OPEN  p;
      FETCH p INTO l_requestor, l_action_owner;

      IF p%notfound THEN
        l_requestor := l_user_name;
        SELECT full_name into l_action_owner
        FROM   per_all_people_f
        WHERE  person_id = P_Owner
        AND    sysdate between effective_start_date and effective_end_date;
      END IF;
      CLOSE p;
    END IF;

    l_wf_item_key := P_k_header_ID || '-' ||
                     P_Communication_Num || '-' ||
                     P_New_Action_Code || '-' ||
                     TO_CHAR(sysdate,'YYYYMMDDHH24MISS');

    l_wf_user_key := l_Contract_Num || '-' ||
                     P_Communication_Num || '-' ||
                     P_New_Action_Code || '-' ||
                     TO_CHAR(sysdate,'YYYYMMDDHH24MISS');

    P_WF_ITEM_KEY:=l_wf_item_key;

    WF_ENGINE.CreateProcess( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , process  => l_wf_process );

    WF_ENGINE.SetItemOwner ( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , owner    => l_user_name );

    WF_ENGINE.SetItemUserKey( itemtype => l_wf_item_type
                            , itemkey  => l_wf_item_key
                            , userkey  => l_wf_user_key );

-------------------------------------------------------------------
    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_TYPE'
                             , avalue   => l_k_type );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_NUMBER'
                             , avalue   => l_Contract_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LINE_NUMBER'
                             , avalue   => l_Line_Number );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DTS_NUMBER'
                             , avalue   => l_DTS_Number );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'REQUESTOR'
                             , avalue   => l_requestor);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ADMINISTRATOR'
                             , avalue   => l_user_name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_NUM'
                             , avalue   => P_Communication_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LOGGED_BY'
                             , avalue   => l_user_name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_TYPE'
                             , avalue   => P_Type_Name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_REASON'
                             , avalue   => P_Reason_Name );

-------------------------------------------------------------------
--Party Name
-------------------------------------------------------------------
    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_NAME'
                             , avalue   => P_Party_Name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_LOCATION'
                             , avalue   => P_PARTY_LOCATION );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_ROLE'
                             , avalue   => P_PARTY_ROLE );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_CONTACT'
                             , avalue   => P_PARTY_CONTACT );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ACTION_NAME'
                             , avalue   => l_new_action );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ACTION_OWNER'
                             , avalue   => l_action_owner);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PRIORITY_NAME'
                             , avalue   => P_Priority_Name);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_DATE'
                             , avalue   => P_COMMUNICATION_DATE );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_TEXT'
                             , avalue   => P_COMMUNICATION_TEXT );

    WF_ENGINE.SetItemAttrNumber( itemtype => l_wf_item_type
                               , itemkey  => l_wf_item_key
                               , aname    => 'ORG_ID'
                               , avalue   => l_org_id );

    WF_ENGINE.StartProcess( itemtype => l_wf_item_type
                          , itemkey  => l_wf_item_key );

  END IF;

END Action_Workflow;


--
--  Name          : Comm_Action
--  Pre-reqs      : None
--  Function      : This procedure performs utility functions during
--                  a change request status change.
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Comm_Action
( P_K_Header_ID        IN  NUMBER
, P_K_Line_ID          IN  NUMBER
, P_Deliverable_ID     IN  NUMBER
, P_Communication_Num  IN  VARCHAR2
, P_Type               IN  VARCHAR2
, P_Reason_Code        IN  VARCHAR2
, P_K_Party_ID         IN  NUMBER
, P_Party_Location     IN  VARCHAR2
, P_Party_Role         IN  VARCHAR2
, P_Party_Contact      IN  VARCHAR2
, P_New_Action_Code    IN  VARCHAR2
, P_Owner              IN  NUMBER
, P_Priority_Code      IN  VARCHAR2
, P_Communication_Date IN  DATE
, P_Communication_Text IN  VARCHAR2
, P_Updated_By         IN  NUMBER
, P_Update_Date        IN  DATE
, P_Login_ID           IN  NUMBER
, P_WF_ITEM_KEY        OUT NOCOPY VARCHAR2
) IS

  CURSOR kh IS
    SELECT k_number
          ,k_type
    FROM   oke_k_headers_full_v
    WHERE  k_header_id = P_K_Header_ID;

  CURSOR kl IS
    SELECT line_number
    FROM   oke_k_lines_full_v
    WHERE  k_line_id = P_K_Line_ID;

  CURSOR kd IS
    SELECT deliverable_num
    FROM   oke_k_deliverables_vl
    WHERE  Deliverable_id = P_Deliverable_ID;

  CURSOR o IS
    SELECT user_name
    FROM   fnd_user
    WHERE  user_id = P_Updated_By;

  CURSOR comm_type IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type='COMMUNICATION_TYPE'
    AND    lookup_code=P_TYPE
    AND    view_application_id=777;

  CURSOR comm_reason IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type='COMMUNICATION_REASON_CODE'
    AND    lookup_code=P_REASON_CODE
    AND    view_application_id=777;

  CURSOR   new_action IS
    SELECT wf_item_type
    ,      wf_process
    ,      comm_action_name
    FROM   oke_comm_actions_vl
    WHERE  comm_action_code = P_New_Action_Code;

-- Jun 20, 2002 : bug 2435609. Person_id is not unique.
-- Add effective_start_date and effective_end_date.
-- Only one person can be active at one time.
--
-- Aut 08, 2003 : bug 3051397. Send notification to Action Owner
-- if action owner is a WF_ROLE (must be a FND_USER), otherwise send to
-- Requestor who log the communication.
-- Use wf_roiles instead of per_people_f
  CURSOR p IS
    SELECT name, display_name
    FROM   wf_roles
    WHERE  orig_system = 'PER'
    AND    orig_system_id = P_Owner;

  CURSOR comm_priority IS
    SELECT meaning
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type='COMMUNICATION_PRIORITY'
    AND    lookup_code=P_PRIORITY_CODE
    AND    view_application_id=777;

  l_wf_item_type          VARCHAR2(8);
  l_wf_process            VARCHAR2(30);
  l_wf_item_key           VARCHAR2(240);
  l_wf_user_key           VARCHAR2(240);
  l_wf_threshold          NUMBER;

-- Aug 08, 2003 Bug 3051397. Change variable length from 30 to 100
-- according to the column length of FND_USER
  l_user_name             VARCHAR2(100);
  l_requestor             VARCHAR2(100);

  l_contract_num          VARCHAR2(240);
  l_k_type                VARCHAR2(240);
  l_line_number           VARCHAR2(240);
  l_dts_number            VARCHAR2(240);
  l_communication_type    VARCHAR2(240);
  l_communication_reason  VARCHAR2(240);

--  Nov 3, 2002 : Bug 2637717 - UTF8 HR Column Expansion
--  l_party_name is not used anywhere in this package.
--  Change the varialbe length in case used in the future.
--  l_party_name            VARCHAR2(240);
  l_party_name            VARCHAR2(360);

  l_new_action            VARCHAR2(240);
  l_action_owner          VARCHAR2(240);
  l_priority_name         VARCHAR2(240);

  CURSOR cur_party
  IS
  SELECT JTOT_Object1_Code
        ,      Object1_ID1
        ,      Object1_ID2
        ,      Role
  FROM   okc_k_party_roles_v
  WHERE  ID = P_K_Party_ID;

  l_Party_Object_Code    VARCHAR2(30);
  l_Party_Object_ID1     VARCHAR2(40);
  l_Party_Object_ID2     VARCHAR2(200);
  l_Party_Role_Name      VARCHAR2(80);
  L_Dummy_String         VARCHAR2(2000);

BEGIN

  OPEN  new_action;
  FETCH new_action INTO l_wf_item_type , l_wf_process , l_new_action;
  CLOSE new_action;

  IF ( l_wf_item_type IS NOT NULL and l_wf_process IS NOT NULL) THEN

    OPEN  kh;
    FETCH kh INTO l_contract_num,l_k_type;
    CLOSE kh;

    OPEN  kl;
    FETCH kl INTO l_line_number;
    CLOSE kl;

    OPEN  kd;
    FETCH kd INTO l_dts_number;
    CLOSE kd;

    OPEN  o;
    FETCH o INTO l_user_name;
    CLOSE o;

    OPEN  comm_type;
    FETCH comm_type INTO l_communication_type;
    CLOSE comm_type;

    OPEN  comm_reason;
    FETCH comm_reason INTO l_communication_reason;
    CLOSE comm_reason;

--    OPEN  p;
--    FETCH p INTO l_action_owner;
--    CLOSE p;
-- Aut 08, 2003 : bug 3051397. Send notification to Action Owner
-- if action owner is a WF_ROLE, otherwise send to
-- Requestor who log the communication.

    IF (P_Owner is null) THEN
      l_requestor := l_user_name;
    ELSE
      OPEN  p;
      FETCH p INTO l_requestor, l_action_owner;

      IF p%notfound THEN
        l_requestor := l_user_name;
        SELECT full_name into l_action_owner
        FROM   per_all_people_f
        WHERE  person_id = P_Owner
        AND    sysdate between effective_start_date and effective_end_date;
      END IF;
      CLOSE p;
    END IF;

    OPEN  comm_priority;
    FETCH comm_priority INTO l_priority_name;
    CLOSE comm_priority;

    -- bug 6491257 fix
    OPEN  cur_party ;
    FETCH cur_party
    INTO  l_Party_Object_Code , l_Party_Object_ID1, l_Party_Object_ID2, l_Party_Role_Name;
    CLOSE cur_party ;

    OKC_UTIL.Get_Name_Desc_From_JTFV
        ( P_Object_Code => l_Party_Object_Code
        , P_ID1         => l_Party_Object_ID1
        , P_ID2         => l_Party_Object_ID2
        , X_Name        => l_party_name
        , X_Description => L_Dummy_String);


    l_wf_item_key := P_k_header_ID || '-' ||
                     P_Communication_Num || '-' ||
                     P_New_Action_Code || '-' ||
                     TO_CHAR(sysdate,'YYYYMMDDHH24MISS');

    l_wf_user_key := l_Contract_Num || '-' ||
                     P_Communication_Num || '-' ||
                     P_New_Action_Code || '-' ||
                     TO_CHAR(sysdate,'YYYYMMDDHH24MISS');

    P_WF_ITEM_KEY:=l_wf_item_key;

    WF_ENGINE.CreateProcess( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , process  => l_wf_process );

    WF_ENGINE.SetItemOwner ( itemtype => l_wf_item_type
                           , itemkey  => l_wf_item_key
                           , owner    => l_user_name );

    WF_ENGINE.SetItemUserKey( itemtype => l_wf_item_type
                            , itemkey  => l_wf_item_key
                            , userkey  => l_wf_user_key );

-------------------------------------------------------------------
    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_TYPE'
                             , avalue   => l_k_type );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DOC_NUMBER'
                             , avalue   => l_Contract_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LINE_NUMBER'
                             , avalue   => l_Line_Number );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'DTS_NUMBER'
                             , avalue   => l_DTS_Number );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'REQUESTOR'
                             , avalue   => l_requestor);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ADMINISTRATOR'
                             , avalue   => l_user_name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_NUM'
                             , avalue   => P_Communication_Num );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'LOGGED_BY'
                             , avalue   => l_user_name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_TYPE'
                             , avalue   => l_communication_type );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_REASON'
                             , avalue   => l_communication_reason );

-------------------------------------------------------------------
--Party Name
-------------------------------------------------------------------
   WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_NAME'
                             , avalue   => l_party_name);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_LOCATION'
                             , avalue   => P_PARTY_LOCATION );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_ROLE_NAME'
                             , avalue   => l_Party_Role_Name );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PARTY_CONTACT'
                             , avalue   => P_PARTY_CONTACT );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ACTION_NAME'
                             , avalue   => l_new_action );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'ACTION_OWNER'
                             , avalue   => l_action_owner);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'PRIORITY_NAME'
                             , avalue   => l_priority_name);

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_DATE'
                             , avalue   => P_COMMUNICATION_DATE );

    WF_ENGINE.SetItemAttrText( itemtype => l_wf_item_type
                             , itemkey  => l_wf_item_key
                             , aname    => 'COMMUNICATION_TEXT'
                             , avalue   => P_COMMUNICATION_TEXT );

    WF_ENGINE.StartProcess( itemtype => l_wf_item_type
                          , itemkey  => l_wf_item_key );

  END IF;

END Comm_Action;


END OKE_COMM_ACT_UTILS;

/
