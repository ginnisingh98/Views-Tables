--------------------------------------------------------
--  DDL for Package Body OKE_DTS_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DTS_WORKFLOW" AS
/* $Header: OKEDTSWB.pls 120.3 2008/03/25 09:12:27 serukull ship $ */

  Function Get_Location(P_Buy_Or_Sell Varchar2
			, P_Direction Varchar2
			, P_Id Number) Return Varchar2 Is

    Cursor Location_C1(P_Id Number) Is
    Select Name
    From okx_locations_v
    Where Id1 = P_Id;

    Cursor Location_C2(P_Id Number) Is
    Select Name
    From okx_vendor_sites_v
    Where Id1 = P_Id;

    Cursor Location_C3(P_Id Number) Is
    Select Name
    From oke_cust_site_uses_v
    Where Id1 = P_Id;

    L_Location Varchar2(80);

  Begin

    If P_Direction = 'IN' Then
      Open Location_C1(P_Id);
      Fetch Location_C1 Into L_Location;
      Close Location_C1;

    Else
      If P_Buy_Or_Sell = 'B' Then
	Open Location_C2(P_Id);
	Fetch Location_C2 Into L_Location;
        Close Location_C2;

      Else

	Open Location_C3(P_Id);
	Fetch Location_C3 Into L_Location;
	Close Location_C3;
      End If;
    End If;

    Return L_Location;

  End Get_Location;

/* bug 6874204 */
FUNCTION check_operation_allowed (p_line_id Number) RETURN BOOLEAN IS

    l_found boolean := FALSE;
    l_sts_code varchar2(80);
    l_value varchar2(1);

    cursor c(p_id Number) IS
    select sts_code from okc_k_lines_b
    where id = p_id;

    cursor opn_csr(p_sts_code varchar2) is
    select 'x' from okc_assents
    where opn_code = 'INITIATE_DELV'
    and sts_code = p_sts_code
    and scs_code = 'PROJECT'
    and allowed_yn = 'Y';

  BEGIN
    open c(p_line_id);
    fetch c into l_sts_code;
    close c;

     open opn_csr(l_sts_code);
     fetch opn_csr into l_value;
     l_found := opn_csr%found;
     close opn_csr;

      return l_found;

 end check_operation_allowed;

    PROCEDURE LAUNCH_MAIN_PROCESS
   ( P_DELIVERABLE_ID             IN      NUMBER
   , P_DTS_WF_MODE                IN      VARCHAR2
   )
   IS
      P_API_VERSION                 NUMBER;

      CURSOR CSR_ORG(P_ORG_ID Number) IS
         SELECT NAME
         FROM   HR_ALL_ORGANIZATION_UNITS
         WHERE  ORGANIZATION_ID = P_ORG_ID;

      CURSOR CSR_DTS(P_DELIVERABLE_ID IN NUMBER) IS
         SELECT D.K_HEADER_ID
         , D.DELIVERABLE_ID
         , D.DELIVERABLE_NUM
         , DECODE(D.ITEM_ID, NULL, NULL, I.NAME)        ITEM_NUMBER
         , B.CONTRACT_NUMBER
         , S.LINE_NUMBER
         , W.SOURCE_CODE
         , W.USAGE_CODE
         , D.DESCRIPTION
         , H.K_TYPE
         , W.WF_ITEM_TYPE
	 , W.WF_PROCESS
         FROM OKE_K_DELIVERABLES_VL     D
	 , OKE_WORKFLOWS                W
	 , OKC_K_HEADERS_B              B
	 , OKE_K_HEADERS_FULL_V         H
	 , OKC_K_LINES_B                S
	 , OKE_SYSTEM_ITEMS_V           I
         WHERE D.DELIVERABLE_ID         = P_DELIVERABLE_ID
	 AND W.SOURCE_CODE              = 'DTS'
         AND W.USAGE_CODE               =
 DECODE(D.DIRECTION,'IN','INBOUND','OUT','OUTBOUND',NULL)
         AND B.ID                       = D.K_HEADER_ID
         AND H.K_HEADER_ID              = D.K_HEADER_ID
         AND S.ID                       = D.K_LINE_ID
         AND I.ID1                   (+)= D.ITEM_ID
         AND I.ID2                   (+)= D.INVENTORY_ORG_ID
         ;

      PROCEDURE LAUNCH_DTS
      (
       P_API_VERSION                 NUMBER
      ,P_K_HEADER_ID  	             NUMBER
      ,P_DELIVERABLE_ID              NUMBER
      ,P_DELIVERABLE_NUM             VARCHAR2
      ,P_ITEM_NUMBER	             VARCHAR2
      ,P_K_NUMBER 		     VARCHAR2
      ,P_LINE_NUMBER 		     VARCHAR2
      ,P_SOURCE_CODE                 VARCHAR2
      ,P_USAGE_CODE                  VARCHAR2
      ,P_DESCRIPTION                 VARCHAR2
      ,P_DOC_TYPE                    VARCHAR2
      ,P_DTS_WF_MODE                 VARCHAR2
      ,L_WF_ITEM_TYPE                VARCHAR2
      ,L_WF_PROCESS                  VARCHAR2
      )
      IS
         L_WF_Item_Key  VARCHAR2(240);
         L_WF_User_Key  VARCHAR2(240);
         L_org_id       NUMBER;

         CURSOR c_org is
         select authoring_org_id from oke_k_headers_v where
               k_header_id=p_k_header_id;
      BEGIN

         open c_org;
         fetch c_org into l_org_id;
         close c_org;

         L_WF_Item_Key     := P_Deliverable_ID || ':' ||
	                      L_WF_PROCESS     || ':' ||
                          to_char(sysdate , 'DDMONRRHH24MISS');

         L_WF_User_Key     := P_K_Number        || ':' ||
                              P_Line_Number     || ':' ||
                              P_Deliverable_Num || ':' ||
	                      L_WF_PROCESS      || ':' ||
			      P_Deliverable_ID  || ':' ||
                          to_char(sysdate , 'DDMONRRHH24MISS');

         WF_Engine.CreateProcess
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , Process  => L_WF_Process);

         WF_Engine.SetItemOwner
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , Owner    => FND_GLOBAL.User_Name);

         WF_Engine.SetItemUserKey
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , UserKey  => L_WF_User_Key);

          --
          -- Setting various Workflow Item Attributes
          --
         WF_ENGINE.SetItemAttrNumber
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'API_VERSION'
            , AValue      => P_API_VERSION );

         WF_ENGINE.SetItemAttrNumber
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'ORG_ID'
            , AValue      => l_org_id );

         WF_ENGINE.SetItemAttrNumber
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'K_HEADER_ID'
            , AValue      => P_K_HEADER_ID );

         WF_ENGINE.SetItemAttrNumber
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'DELIVERABLE_ID'
            , AValue      => P_DELIVERABLE_ID );

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'DELIVERABLE_NUM'
            , AValue      => P_DELIVERABLE_NUM );

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'ITEM_NUM'
            , AValue      => P_ITEM_NUMBER );

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'K_NUMBER'
            , AValue      => P_K_NUMBER );

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'LINE_NUMBER'
            , AValue      => P_LINE_NUMBER );

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'SOURCE_CODE'
            , AValue      => P_SOURCE_CODE);

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'USAGE_CODE'
            , AValue      => P_USAGE_CODE);

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'DESCRIPTION'
            , AValue      => P_DESCRIPTION);

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'DOC_TYPE'
            , AValue      => P_DOC_TYPE);

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'DTS_WF_MODE'
            , AValue      => P_DTS_WF_MODE );

         WF_ENGINE.SetItemAttrText
            ( ItemType => L_WF_Item_Type
            , ItemKey  => L_WF_Item_Key
            , AName       => 'REQUESTOR'
            , AValue      => FND_GLOBAL.User_Name );

------------------------------------------------------------------------------
         --
         -- Start the Workflow Process
         --
         WF_ENGINE.StartProcess( ItemType => L_WF_Item_Type
                               , ItemKey  => L_WF_Item_Key );

         update oke_k_deliverables_b
	 set    wf_item_key = L_WF_Item_Key
	 where  deliverable_id = P_DELIVERABLE_ID
	 ;

	 commit;
      END LAUNCH_DTS;

   BEGIN
      P_API_VERSION                 := 1;

      FOR REC_DTS IN CSR_DTS(P_DELIVERABLE_ID) LOOP

         IF REC_DTS.WF_ITEM_TYPE IS NULL THEN
            RETURN;
         END IF;

         LAUNCH_DTS
         (
          P_API_VERSION
         ,REC_DTS.K_HEADER_ID
         ,REC_DTS.DELIVERABLE_ID
         ,REC_DTS.DELIVERABLE_NUM
         ,REC_DTS.ITEM_NUMBER
         ,REC_DTS.CONTRACT_NUMBER
         ,REC_DTS.LINE_NUMBER
         ,REC_DTS.SOURCE_CODE
         ,REC_DTS.USAGE_CODE
         ,REC_DTS.DESCRIPTION
         ,REC_DTS.K_TYPE
         ,P_DTS_WF_MODE
         ,REC_DTS.WF_ITEM_TYPE
         ,REC_DTS.WF_PROCESS
         );

      END LOOP;
   END LAUNCH_MAIN_PROCESS;

   PROCEDURE DUE_NTF_TO_SENT
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_K_Header_ID        NUMBER;
      L_Performer          VARCHAR2(80);

      L_Deliverable_ID     NUMBER;
      L_Return_Status      VARCHAR2(1);
      L_Msg_Count          NUMBER;
      L_Msg_Data           VARCHAR2(2000);
      L_Event_ID           NUMBER;
      L_Event_Num          NUMBER;

      L_Due_Ntf_Id         NUMBER;
      L_Source_Code        VARCHAR2(30);
      L_Usage_Code         VARCHAR2(30);
      L_Target_Date        VARCHAR2(30);
      L_Before_After       VARCHAR2(30);
      L_Duration_Days      NUMBER;

      CURSOR CSR_DUE_NTF(P_DUE_NTF_ID    NUMBER
                        ,P_SOURCE_CODE   VARCHAR2
                        ,P_USAGE_CODE    VARCHAR2
			,P_TARGET_DATE   VARCHAR2
			,P_DURATION_DAYS NUMBER) IS
         SELECT ID
	       ,SOURCE_CODE
	       ,USAGE_CODE
               ,TARGET_DATE
	       ,BEFORE_AFTER
	       ,DURATION_DAYS
	       ,RECIPIENT
	       ,ROLE_ID
         FROM   OKE_NOTIFICATIONS
	 WHERE  SOURCE_CODE  = P_SOURCE_CODE
	 AND    USAGE_CODE   = P_USAGE_CODE
	 AND    TARGET_DATE  = P_TARGET_DATE
	 AND    BEFORE_AFTER = 'BEFORE'
	 AND    (P_DUE_NTF_ID IS NULL OR DURATION_DAYS < P_DURATION_DAYS)
	 ORDER  BY DURATION_DAYS DESC
	 ;
      REC_DUE_NTF CSR_DUE_NTF%ROWTYPE;

--      CURSOR CSR_ESC(P_K_HEADER_ID Number,P_ROLE_ID Number) IS
--         SELECT R.NAME
--         FROM   OKE_K_ALL_ACCESS_V  A
--               ,WF_ROLES            R
--         WHERE  A. K_HEADER_ID      = P_K_HEADER_ID
--         AND    A.ROLE_ID           = P_ROLE_ID
--         AND    R.ORIG_SYSTEM       = 'PER'
--         AND    R.ORIG_SYSTEM_ID    = A.PERSON_ID
--	 ORDER BY DECODE(ASSIGNMENT_LEVEL,'OKE_K_HEADERS',1
--					 ,'SITE',2
--					 ,3)
--         ;

   BEGIN

      IF ( FuncMode = 'RUN' ) THEN

         L_K_Header_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_HEADER_ID'
                             );

         L_Deliverable_Id := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

         L_Due_Ntf_Id := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DUE_NTF_ID'
                             );

         L_Source_Code := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'SOURCE_CODE'
                             );

	 L_Usage_Code := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'USAGE_CODE'
                             );

	 L_Target_Date := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'TARGET_DATE'
                             );

	 L_Before_After := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'BEFORE_AFTER'
                             );

         L_Duration_Days := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DURATION_DAYS'
                             );


         OPEN CSR_DUE_NTF(L_Due_Ntf_Id,L_Source_Code,L_Usage_Code,'DELIVERY_DATE',L_Duration_Days);
            FETCH CSR_DUE_NTF INTO REC_DUE_NTF;
         CLOSE CSR_DUE_NTF;

         IF REC_DUE_NTF.ID IS NULL THEN
            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DUE_NTF_ID'
               , AValue      => NULL );

            ResultOut := 'COMPLETE:F';
            RETURN;
         ELSE
            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DUE_NTF_ID'
               , AValue      => REC_DUE_NTF.ID );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'SOURCE_CODE'
               , AValue      => REC_DUE_NTF.SOURCE_CODE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'USAGE_CODE'
               , AValue      => REC_DUE_NTF.USAGE_CODE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'TARGET_DATE'
               , AValue      => REC_DUE_NTF.TARGET_DATE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'BEFORE_AFTER'
               , AValue      => REC_DUE_NTF.BEFORE_AFTER );

            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DURATION_DAYS'
               , AValue      => REC_DUE_NTF.DURATION_DAYS );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'RECIPIENT'
               , AValue      => REC_DUE_NTF.RECIPIENT );

            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'ROLE_ID'
               , AValue      => REC_DUE_NTF.ROLE_ID );

            IF REC_DUE_NTF.RECIPIENT='REQUESTOR' THEN
	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName       => 'PERFORMER'
                  , AValue      => FND_GLOBAL.User_Name);
            ELSIF REC_DUE_NTF.RECIPIENT='CONTRACT_ROLE' THEN
--               OPEN CSR_ESC(L_K_Header_ID,REC_DUE_NTF.ROLE_ID);
--                  FETCH CSR_ESC INTO L_Performer;
--               CLOSE CSR_ESC;

               L_Performer := OKE_UTILS.Retrieve_WF_Role_Name(L_K_Header_ID,REC_DUE_NTF.ROLE_ID);

	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'PERFORMER'
                  , AValue   => L_Performer );

	    ELSE
	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName       => 'PERFORMER'
                  , AValue      => FND_GLOBAL.User_Name);
            END IF;

	    ResultOut := 'COMPLETE:T';
            RETURN;
         END IF;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'DUE_NTF_TO_SENT'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END DUE_NTF_TO_SENT;

   PROCEDURE PAST_DUE_NTF_TO_SENT
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_K_Header_ID        NUMBER;
      L_Performer          VARCHAR2(80);

      L_Deliverable_ID     NUMBER;
      L_Return_Status      VARCHAR2(1);
      L_Msg_Count          NUMBER;
      L_Msg_Data           VARCHAR2(2000);
      L_Event_ID           NUMBER;
      L_Event_Num          NUMBER;

      L_Due_Ntf_Id         NUMBER;
      L_Source_Code        VARCHAR2(30);
      L_Usage_Code         VARCHAR2(30);
      L_Target_Date        VARCHAR2(30);
      L_Before_After       VARCHAR2(30);
      L_Duration_Days      NUMBER;

      CURSOR CSR_DUE_NTF(P_DUE_NTF_ID    NUMBER
                        ,P_SOURCE_CODE   VARCHAR2
                        ,P_USAGE_CODE    VARCHAR2
			,P_TARGET_DATE   VARCHAR2
			,P_DURATION_DAYS NUMBER) IS
         SELECT ID
	       ,SOURCE_CODE
	       ,USAGE_CODE
               ,TARGET_DATE
	       ,BEFORE_AFTER
	       ,DURATION_DAYS
	       ,RECIPIENT
	       ,ROLE_ID
         FROM   OKE_NOTIFICATIONS
	 WHERE  SOURCE_CODE  = P_SOURCE_CODE
	 AND    USAGE_CODE   = P_USAGE_CODE
	 AND    TARGET_DATE  = P_TARGET_DATE
	 AND    BEFORE_AFTER = 'AFTER'
	 AND    (P_DUE_NTF_ID IS NULL OR DURATION_DAYS > P_DURATION_DAYS)
	 ORDER  BY DURATION_DAYS ASC
	 ;
      REC_DUE_NTF CSR_DUE_NTF%ROWTYPE;

--      CURSOR CSR_ESC(P_K_HEADER_ID Number,P_ROLE_ID Number) IS
--         SELECT R.NAME
--         FROM   OKE_K_ALL_ACCESS_V  A
--               ,WF_ROLES            R
--         WHERE  A. K_HEADER_ID      = P_K_HEADER_ID
--         AND    A.ROLE_ID           = P_ROLE_ID
--         AND    R.ORIG_SYSTEM       = 'PER'
--         AND    R.ORIG_SYSTEM_ID    = A.PERSON_ID
--	 ORDER BY DECODE(ASSIGNMENT_LEVEL,'OKE_K_HEADERS',1
--					 ,'SITE',2
--					 ,3)
--         ;

   BEGIN

      IF ( FuncMode = 'RUN' ) THEN

         L_K_Header_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_HEADER_ID'
                             );

         L_Deliverable_Id := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

         L_Due_Ntf_Id := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DUE_NTF_ID'
                             );

         L_Source_Code := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'SOURCE_CODE'
                             );

	 L_Usage_Code := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'USAGE_CODE'
                             );

	 L_Target_Date := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'TARGET_DATE'
                             );

	 L_Before_After := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'BEFORE_AFTER'
                             );

         L_Duration_Days := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DURATION_DAYS'
                             );


         OPEN CSR_DUE_NTF(L_Due_Ntf_Id,L_Source_Code,L_Usage_Code,'DELIVERY_DATE',L_Duration_Days);
            FETCH CSR_DUE_NTF INTO REC_DUE_NTF;
         CLOSE CSR_DUE_NTF;

         IF REC_DUE_NTF.ID IS NULL THEN
            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DUE_NTF_ID'
               , AValue      => NULL );

            ResultOut := 'COMPLETE:F';
            RETURN;
         ELSE
            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DUE_NTF_ID'
               , AValue      => REC_DUE_NTF.ID );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'SOURCE_CODE'
               , AValue      => REC_DUE_NTF.SOURCE_CODE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'USAGE_CODE'
               , AValue      => REC_DUE_NTF.USAGE_CODE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'TARGET_DATE'
               , AValue      => REC_DUE_NTF.TARGET_DATE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'BEFORE_AFTER'
               , AValue      => REC_DUE_NTF.BEFORE_AFTER );

            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DURATION_DAYS'
               , AValue      => REC_DUE_NTF.DURATION_DAYS );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'RECIPIENT'
               , AValue      => REC_DUE_NTF.RECIPIENT );

            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'ROLE_ID'
               , AValue      => REC_DUE_NTF.ROLE_ID );

            IF REC_DUE_NTF.RECIPIENT='REQUESTOR' THEN
	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName       => 'PERFORMER'
                  , AValue      => FND_GLOBAL.User_Name);
            ELSIF REC_DUE_NTF.RECIPIENT='CONTRACT_ROLE' THEN
--               OPEN CSR_ESC(L_K_Header_ID,REC_DUE_NTF.ROLE_ID);
--                  FETCH CSR_ESC INTO L_Performer;
--               CLOSE CSR_ESC;

               L_Performer := OKE_UTILS.Retrieve_WF_Role_Name(L_K_Header_ID,REC_DUE_NTF.ROLE_ID);

               WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'PERFORMER'
                  , AValue   => L_Performer );

	    ELSE
	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName       => 'PERFORMER'
                  , AValue      => FND_GLOBAL.User_Name);
            END IF;

            ResultOut := 'COMPLETE:T';
            RETURN;
         END IF;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'DUE_NTF_TO_SENT'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END PAST_DUE_NTF_TO_SENT;

   PROCEDURE SELECT_DATE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_ID     NUMBER;
      L_Return_Status      VARCHAR2(1);
      L_Msg_Count          NUMBER;
      L_Msg_Data           VARCHAR2(2000);
      L_Event_ID           NUMBER;
      L_Event_Num          NUMBER;

      L_Due_Ntf_Id         NUMBER;
      L_Source_Code        VARCHAR2(30);
      L_Usage_Code         VARCHAR2(30);
      L_Target_Date        VARCHAR2(30);
      L_Before_After       VARCHAR2(30);
      L_Duration_Days      NUMBER;

      L_Delivery_Date      DATE;
      L_Deliverable_Num    VARCHAR2(240);
      L_Description        VARCHAR2(2000);

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

         L_Due_Ntf_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DUE_NTF_ID'
                             );

         L_Source_Code := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'SOURCE_CODE'
                             );

         L_Usage_Code := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'USAGE_CODE'
                             );

         L_Target_date := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'TARGET_DATE'
                             );

	 L_Before_After := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'BEFORE_AFTER'
                             );

         L_Duration_Days := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DURATION_DAYS'
                             );


         BEGIN
            SELECT DELIVERY_DATE
                  ,DELIVERABLE_NUM
                  ,DESCRIPTION
            INTO   L_Delivery_Date
	          ,L_Deliverable_Num
		  ,L_Description
            FROM   OKE_K_DELIVERABLES_VL
            WHERE  DELIVERABLE_ID=L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF L_Delivery_Date IS NULL THEN
            ResultOut := 'COMPLETE:F';
         ELSE
            WF_ENGINE.SetItemAttrDate
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName    => 'DELIVERY_DATE'
               , AValue   => L_Delivery_Date );

            WF_ENGINE.SetItemAttrDate
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'TARGET_DATE_VALUE'
               , AValue      => L_Delivery_Date );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DELIVERABLE_NUM'
               , AValue      => L_DELIVERABLE_NUM );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DESCRIPTION'
               , AValue      => L_DESCRIPTION );

            IF L_Before_After = 'BEFORE' THEN
               WF_ENGINE.SetItemAttrDate
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'COMPARE_DATE'
                  , AValue   => sysdate+L_Duration_Days );
	    ELSE
               WF_ENGINE.SetItemAttrDate
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'COMPARE_DATE'
                  , AValue   => sysdate-L_Duration_Days );
	    END IF;

            ResultOut := 'COMPLETE:T';
         END IF;
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'SELECT_DATE'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END SELECT_DATE;

   PROCEDURE READY_TO_SHIP
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_K_HEADER_ID             NUMBER;
      L_K_LINE_ID               NUMBER;
      L_Hold                    BOOLEAN;
      L_return_status           VARCHAR2(1);
      L_msg_count               NUMBER;
      L_msg_data                VARCHAR2(2000);

      L_Deliverable_ID          NUMBER;
      L_Available_For_Ship_Flag VARCHAR2(1);

      l_item_id                 NUMBER;
      l_description             VARCHAR2(2000);
      l_quantity                NUMBER;
      l_uom_code                VARCHAR2(10);
      l_ship_to_location_id     NUMBER;
      l_ship_from_location_id   NUMBER;
      l_expected_date           DATE;

   BEGIN
      L_Hold :=FALSE;

      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

	 BEGIN
            SELECT AVAILABLE_FOR_SHIP_FLAG
	          ,ITEM_ID
		  ,DESCRIPTION
		  ,QUANTITY
		  ,UOM_CODE
		  ,SHIP_TO_LOCATION_ID
		  ,SHIP_FROM_LOCATION_ID
		  ,EXPECTED_SHIPMENT_DATE
            INTO   L_Available_For_Ship_Flag
	          ,l_item_id
		  ,l_description
		  ,l_quantity
		  ,l_uom_code
		  ,l_ship_to_location_id
		  ,l_ship_from_location_id
		  ,l_expected_date
            FROM   OKE_K_DELIVERABLES_VL
            WHERE  DELIVERABLE_ID=L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

-- BUG 3597451
	 IF L_Available_For_Ship_Flag <> 'Y'
	    OR (l_item_id is null and l_description is null)
	    OR l_quantity is null
            OR l_uom_code is null
            OR l_ship_to_location_id is null
            OR l_ship_from_location_id is null
            OR l_expected_date is null THEN

	    ResultOut := 'COMPLETE:F';
	    RETURN;
         ELSE
            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'ACTION'
               , AValue      => 'SHIP' );
            ResultOut := 'COMPLETE:T';
         END IF;


         BEGIN
            SELECT K_HEADER_ID
	          ,K_LINE_ID
	    INTO   L_K_HEADER_ID
	          ,L_K_LINE_ID
	    FROM   OKE_K_DELIVERABLES_VL
	    WHERE  DELIVERABLE_ID  = L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               ResultOut := 'ERROR:';
               WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'ERRORTEXT'
                  , AValue   => sqlerrm );
               WF_Core.Context
                  ( 'OKE_DTS_WORKFLOW'
                  , 'READY_TO_SHIP'
                  , ItemType
                  , ItemKey
                  , to_char(ActID)
                  , FuncMode
                  , ResultOut );
               RAISE;
	 END;

	 -- Check if deliverable on hold
         L_Hold := OKE_CHECK_HOLD_PKG.Is_Hold(1
				, 'T'
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data
				, 'DELIVERABLE'
				, L_K_HEADER_ID
				, L_K_LINE_ID
				, L_Deliverable_ID);
         IF L_Hold THEN
            ResultOut := 'COMPLETE:F';
            RETURN;
         END IF;

        IF NOT check_operation_allowed(L_K_LINE_ID) THEN
             ResultOut := 'COMPLETE:F';
            RETURN;
        END IF;

         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'READY_TO_SHIP'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END READY_TO_SHIP;

   PROCEDURE READY_TO_CREATE_MDS
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_K_HEADER_ID             NUMBER;
      L_K_LINE_ID               NUMBER;
      L_Hold                    BOOLEAN;
      L_return_status           VARCHAR2(1);
      L_msg_count               NUMBER;
      L_msg_data                VARCHAR2(2000);

      L_Deliverable_ID  NUMBER;
      L_Create_Demand VARCHAR2(1);

      l_item_id                 NUMBER;
      l_inventory_org_id        NUMBER;
      l_ndb_schedule_designator VARCHAR2(2000);
      l_quantity                NUMBER;
      l_uom_code                VARCHAR2(10);
      l_expected_date           DATE;



   BEGIN

      L_Hold                    := FALSE;

      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

         BEGIN
            SELECT CREATE_DEMAND
	          ,ITEM_ID
		  ,INVENTORY_ORG_ID
		  ,NDB_SCHEDULE_DESIGNATOR
		  ,QUANTITY
		  ,UOM_CODE
		  ,EXPECTED_SHIPMENT_DATE
            INTO   L_Create_Demand
	          ,l_item_id
		  ,l_inventory_org_id
		  ,l_ndb_schedule_designator
		  ,l_quantity
		  ,l_uom_code
		  ,l_expected_date
            FROM   OKE_K_DELIVERABLES_VL
            WHERE  DELIVERABLE_ID=L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

-- BUG 3597451
	 IF L_Create_Demand <> 'Y'
	    OR l_item_id is null
	    OR l_inventory_org_id is null
	    OR l_ndb_schedule_designator is null
	    OR l_quantity is null
            OR l_uom_code is null
            OR l_expected_date is null THEN

	    ResultOut := 'COMPLETE:F';
	    RETURN;
         ELSE
            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'ACTION'
               , AValue      => 'PLAN' );
            ResultOut := 'COMPLETE:T';
         END IF;

         BEGIN
            SELECT K_HEADER_ID
	          ,K_LINE_ID
	    INTO   L_K_HEADER_ID
	          ,L_K_LINE_ID
	    FROM   OKE_K_DELIVERABLES_VL
	    WHERE  DELIVERABLE_ID  = L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               ResultOut := 'ERROR:';
               WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'ERRORTEXT'
                  , AValue   => sqlerrm );
               WF_Core.Context
                  ( 'OKE_DTS_WORKFLOW'
                  , 'READY_TO_CREATE_MDS'
                  , ItemType
                  , ItemKey
                  , to_char(ActID)
                  , FuncMode
                  , ResultOut );
               RAISE;
	 END;

	 -- Check if deliverable on hold
         L_Hold := OKE_CHECK_HOLD_PKG.Is_Hold(1
				, 'T'
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data
				, 'DELIVERABLE'
				, L_K_HEADER_ID
				, L_K_LINE_ID
				, L_Deliverable_ID);
         IF L_Hold THEN
            ResultOut := 'COMPLETE:F';
            RETURN;
         END IF;

        IF NOT check_operation_allowed(L_K_LINE_ID) THEN
             ResultOut := 'COMPLETE:F';
            RETURN;
        END IF;

         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'READY_TO_CREATE_MDS'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END READY_TO_CREATE_MDS;

   PROCEDURE READY_TO_PROCURE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_K_HEADER_ID             NUMBER;
      L_K_LINE_ID               NUMBER;
      L_Hold                    BOOLEAN;
      L_return_status           VARCHAR2(1);
      L_msg_count               NUMBER;
      L_msg_data                VARCHAR2(2000);

      L_Deliverable_ID   NUMBER;
      L_Ready_To_Procure VARCHAR2(1);

   BEGIN

      L_Hold                    := FALSE;

      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

         BEGIN
            SELECT READY_TO_PROCURE
            INTO   L_Ready_To_Procure
            FROM   OKE_K_DELIVERABLES_VL
            WHERE  DELIVERABLE_ID=L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         IF L_Ready_To_Procure <> 'Y' THEN

	    ResultOut := 'COMPLETE:F';
	    RETURN;
         ELSE
            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'ACTION'
               , AValue      => 'REQ' );
            ResultOut := 'COMPLETE:T';
         END IF;

	 BEGIN
            SELECT K_HEADER_ID
	          ,K_LINE_ID
	    INTO   L_K_HEADER_ID
	          ,L_K_LINE_ID
	    FROM   OKE_K_DELIVERABLES_VL
	    WHERE  DELIVERABLE_ID  = L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               ResultOut := 'ERROR:';
               WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName    => 'ERRORTEXT'
                  , AValue   => sqlerrm );
               WF_Core.Context
                  ( 'OKE_DTS_WORKFLOW'
                  , 'READY_TO_PROCURE'
                  , ItemType
                  , ItemKey
                  , to_char(ActID)
                  , FuncMode
                  , ResultOut );
               RAISE;
	 END;

	 -- Check if deliverable on hold
         L_Hold := OKE_CHECK_HOLD_PKG.Is_Hold(1
				, 'T'
				, L_Return_Status
				, L_Msg_Count
				, L_Msg_Data
				, 'DELIVERABLE'
				, L_K_HEADER_ID
				, L_K_LINE_ID
				, L_Deliverable_ID);
         IF L_Hold THEN
            ResultOut := 'COMPLETE:F';
            RETURN;
         END IF;

        IF NOT check_operation_allowed(L_K_LINE_ID) THEN
             ResultOut := 'COMPLETE:F';
            RETURN;
        END IF;

         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'READY_TO_PROCURE'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END READY_TO_PROCURE;

   PROCEDURE LAUNCH_SHIP
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_Id      Number;

      L_Ship_To_Location_Id Number;
      L_Ship_To_Location    Varchar2(80);
      L_Requestor           Varchar2(80);
      L_WorkDate            Date;
      L_Id                  Number;
      L_Po_Id               Number;
      L_Delivery_Id         Number;

      L_Msg_Count           Number;
      L_Msg_Data            Varchar2(2000);
      L_Item                Varchar2(240);
      L_Org                 Varchar2(240);
      L_Contract_Number     Varchar2(450);
      L_Inventory_Org_Id    Number;
      L_Header_Id           Number;
      L_Line_Number         Varchar2(450);
      L_Return_Status       Varchar2(1);
      Debug_Counter         Number ;
      Counter               Number ;

      Cursor Wsh_C3(P_Id Number) Is
      Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
      From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
      Where D.Deliverable_Id = P_Id
      And B.Id = D.K_Header_Id
      And H.K_Header_Id = B.Id
      And D.Project_Id = P.Project_Id(+)
      And D.Task_Id = T.Task_Id(+)
      And D.Item_Id = I.Id1(+)
      And D.Inventory_Org_Id = I.Id2(+)
      And D.K_Line_Id = S.Id
      And D.Available_For_Ship_Flag = 'Y';

      Wsh_Rec Wsh_C3%ROWTYPE;

      Cursor Org_C(P_Id Number) Is
      Select Name
      From hr_all_organization_units
      Where Organization_Id = P_Id;

   BEGIN

      L_Return_Status       := Oke_Api.G_Ret_Sts_Success;
      Debug_Counter         := 0;
      Counter               := 0;

      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

--------------------------------------------------------------
         L_Header_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_HEADER_ID'
                             );

         L_Contract_Number:= WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_NUMBER'
                             );

	 L_Line_Number:= WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'LINE_NUMBER'
                             );
         L_Requestor   := WF_Engine.GetItemAttrText
                                ( ItemType => ItemType
                                , ItemKey  => ItemKey
                                , AName    => 'REQUESTOR'
                                );
--------------------------------------------------------------
	 OPEN Wsh_C3(L_Deliverable_Id);
	    Fetch Wsh_C3 into Wsh_Rec;
	    IF Wsh_C3%FOUND Then
               L_Inventory_Org_Id := OKE_DTS_ACTION_PKG.Get_Org(Wsh_Rec.Direction
				, Wsh_Rec.Ship_From_Org_Id
				, Wsh_Rec.Ship_To_Org_Id);
	       Open Org_C(L_Inventory_Org_Id);
	          Fetch Org_C Into L_Org;
	       Close Org_C;

	       L_Ship_To_Location := Get_Location(Wsh_Rec.Buy_Or_Sell
						, Wsh_Rec.Direction
						, Wsh_Rec.Ship_To_Location_Id);


               OKE_DTS_INTEGRATION_PKG.Launch_Process
                     ( P_ACTION		            => 'SHIP'
                     , P_API_VERSION                => 1
                     , P_COUNTRY_OF_ORIGIN_CODE     => Wsh_Rec.country_of_origin_code
                     , P_CURRENCY_CODE              => Wsh_Rec.CURRENCY_CODE
                     , P_DELIVERABLE_ID             => L_DELIVERABLE_ID
                     , P_DELIVERABLE_NUM            => Wsh_Rec.DELIVERABLE_NUM
                     , P_INIT_MSG_LIST	            => 'T'
                     , P_INSPECTION_REQED	    => Wsh_Rec.inspection_req_flag
                     , P_ITEM_DESCRIPTION           => Wsh_Rec.ITEM_DESCRIPTION
                     , P_ITEM_ID		    => Wsh_Rec.ITEM_ID
                     , P_ITEM_NUM		    => Wsh_Rec.ITEM
                     , P_K_HEADER_ID  	            => L_HEADER_ID
                     , P_K_NUMBER		    => L_Contract_Number
                     , P_LINE_NUMBER		    => L_LINE_NUMBER
                     , P_MPS_TRANSACTION_ID	    => Wsh_Rec.MPS_TRANSACTION_ID
                     , P_ORGANIZATION	            => L_ORG
                     , P_ORGANIZATION_ID	    => l_inventory_org_id
                     , P_PROJECT_ID		    => Wsh_Rec.PROJECT_ID
                     , P_PROJECT_NUM                => Wsh_Rec.PROJECT_NUMBER
                     , P_QUANTITY    	            => Wsh_Rec.QUANTITY
                     , P_SCHEDULE_DATE              => Wsh_Rec.expected_shipment_date
                     , P_SCHEDULE_DESIGNATOR        => Wsh_Rec.ndb_schedule_designator
                     , P_SHIP_TO_LOCATION           => L_SHIP_TO_LOCATION
                     , P_TASK_ID      	            => Wsh_Rec.TASK_ID
                     , P_TASK_NUM                   => Wsh_Rec.TASK_NUMBER
                     , P_UNIT_NUMBER                => Wsh_Rec.UNIT_NUMBER
                     , P_UOM_CODE                   => Wsh_Rec.UOM_CODE
                     , P_WORK_DATE		    => L_WORKDATE
                     , P_REQUESTOR => l_requestor
                     );

            End If;
         CLOSE Wsh_C3;
--------------------------------------------------------------

         ResultOut := 'COMPLETE:';
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'LAUNCH_SHIP'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END LAUNCH_SHIP;

   PROCEDURE LAUNCH_PLAN
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_Id      Number;

      L_Ship_To_Location_Id Number;
      L_Ship_To_Location    Varchar2(80);
      L_Requestor           Varchar2(80);
      L_WorkDate            Date;
      L_Id                  Number;
      L_Po_Id               Number;
      L_Delivery_Id         Number;

      L_Msg_Count           Number;
      L_Msg_Data            Varchar2(2000);
      L_Item                Varchar2(240);
      L_Org                 Varchar2(240);
      L_Contract_Number     Varchar2(450);
      L_Inventory_Org_Id    Number;
      L_Header_Id           Number;
      L_Line_Number         Varchar2(450);
      L_Return_Status       Varchar2(1);
      Debug_Counter         Number ;
      Counter               Number ;

      Cursor MDS_C3(P_Id Number) Is
      Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, I.Description Item_Description
	, D.Item_Id
	, I.Name Item
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
      From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
      Where D.Deliverable_Id = P_Id
      And B.Id = D.K_Header_Id
      And H.K_Header_Id = B.Id
      And D.Project_Id = P.Project_Id(+)
      And D.Task_Id = T.Task_Id(+)
      And D.Item_Id = I.Id1
      And D.Inventory_Org_Id = I.Id2
      And D.K_Line_Id = S.Id
      And D.Create_Demand = 'Y';

      Mds_Rec Mds_C3%ROWTYPE;

      Cursor Org_C(P_Id Number) Is
         Select Name
         From hr_all_organization_units
         Where Organization_Id = P_Id;

   BEGIN
      L_Return_Status       := Oke_Api.G_Ret_Sts_Success;
      Debug_Counter         := 0;
      Counter               := 0;


      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );
--------------------------------------------------------------
         L_Header_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_HEADER_ID'
                             );

         L_Contract_Number:= WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_NUMBER'
                             );

	 L_Line_Number:= WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'LINE_NUMBER'
                             );
         L_Requestor   := WF_Engine.GetItemAttrText
                                ( ItemType => ItemType
                                , ItemKey  => ItemKey
                                , AName    => 'REQUESTOR'
                                );
--------------------------------------------------------------
	 OPEN Mds_C3(L_Deliverable_Id);
	    Fetch Mds_C3 into Mds_Rec;
	    IF Mds_C3%FOUND Then
	       L_Inventory_Org_Id := OKE_DTS_ACTION_PKG.Get_Org(Mds_Rec.Direction
					, Mds_Rec.Ship_From_Org_Id
					, Mds_Rec.Ship_To_Org_Id);

	       Open Org_C(L_Inventory_Org_Id);
		  Fetch Org_C Into L_Org;
	       Close Org_C;

	       L_Ship_To_Location := Get_Location(Mds_Rec.Buy_Or_Sell
						, Mds_Rec.Direction
						, Mds_Rec.Ship_To_Location_Id);


               OKE_DTS_INTEGRATION_PKG.Launch_Process
                     ( P_ACTION		            => 'PLAN'
                     , P_API_VERSION                => 1
                     , P_COUNTRY_OF_ORIGIN_CODE     => Mds_Rec.country_of_origin_code
                     , P_CURRENCY_CODE              => Mds_Rec.CURRENCY_CODE
                     , P_DELIVERABLE_ID             => L_DELIVERABLE_ID
                     , P_DELIVERABLE_NUM            => Mds_Rec.DELIVERABLE_NUM
                     , P_INIT_MSG_LIST	            => 'T'
                     , P_INSPECTION_REQED	    => Mds_Rec.inspection_req_flag
                     , P_ITEM_DESCRIPTION           => Mds_Rec.ITEM_DESCRIPTION
                     , P_ITEM_ID		    => Mds_Rec.ITEM_ID
                     , P_ITEM_NUM		    => Mds_Rec.ITEM
                     , P_K_HEADER_ID  	            => L_HEADER_ID
                     , P_K_NUMBER		    => L_Contract_Number
                     , P_LINE_NUMBER		    => L_LINE_NUMBER
                     , P_MPS_TRANSACTION_ID	    => Mds_Rec.MPS_TRANSACTION_ID
                     , P_ORGANIZATION	            => L_ORG
                     , P_ORGANIZATION_ID	    => l_inventory_org_id
                     , P_PROJECT_ID		    => Mds_Rec.PROJECT_ID
                     , P_PROJECT_NUM                => Mds_Rec.PROJECT_NUMBER
                     , P_QUANTITY    	            => Mds_Rec.QUANTITY
                     , P_SCHEDULE_DATE              => Mds_Rec.expected_shipment_date
                     , P_SCHEDULE_DESIGNATOR        => Mds_Rec.ndb_schedule_designator
                     , P_SHIP_TO_LOCATION           => L_SHIP_TO_LOCATION
                     , P_TASK_ID      	            => Mds_Rec.TASK_ID
                     , P_TASK_NUM                   => Mds_Rec.TASK_NUMBER
                     , P_UNIT_NUMBER                => Mds_Rec.UNIT_NUMBER
                     , P_UOM_CODE                   => Mds_Rec.UOM_CODE
                     , P_WORK_DATE		    => L_WORKDATE
                     , P_REQUESTOR => l_requestor
                     );
            End If;
	 CLOSE Mds_C3;

         ResultOut := 'COMPLETE:';
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'LAUNCH_PLAN'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END LAUNCH_PLAN;

   PROCEDURE LAUNCH_REQ
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_Id      Number;

      L_Ship_To_Location_Id Number;
      L_Ship_To_Location    Varchar2(80);
      L_Requestor           Varchar2(80);
      L_WorkDate            Date;
      L_Id                  Number;
      L_Po_Id               Number;
      L_Delivery_Id         Number;

      L_Msg_Count           Number;
      L_Msg_Data            Varchar2(2000);
      L_Item                Varchar2(240);
      L_Org                 Varchar2(240);
      L_Contract_Number     Varchar2(450);
      L_Inventory_Org_Id    Number;
      L_Header_Id           Number;
      L_Line_Number         Varchar2(450);
      L_Return_Status       Varchar2(1);
      Debug_Counter         Number ;
      Counter               Number ;

      Cursor PO_C3(P_Id Number) Is
      Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
      From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
      Where D.Deliverable_Id = P_Id
      And B.Id = D.K_Header_Id
      And H.K_Header_Id = B.Id
      And D.Project_Id = P.Project_Id(+)
      And D.Task_Id = T.Task_Id(+)
      And D.Item_Id = I.Id1(+)
      And D.Inventory_Org_Id = I.Id2(+)
      And D.K_Line_Id = S.Id
      And D.Ready_To_Procure = 'Y';

      Po_Rec Po_C3%ROWTYPE;

      Cursor Org_C(P_Id Number) Is
         Select Name
         From hr_all_organization_units
         Where Organization_Id = P_Id;

   BEGIN
      L_Return_Status       := Oke_Api.G_Ret_Sts_Success;
      Debug_Counter         := 0;
      Counter               := 0;

      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );
--------------------------------------------------------------
         L_Header_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_HEADER_ID'
                             );

         L_Contract_Number:= WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_NUMBER'
                             );

	 L_Line_Number:= WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'LINE_NUMBER'
                             );
        L_Requestor   := WF_Engine.GetItemAttrText
                                ( ItemType => ItemType
                                , ItemKey  => ItemKey
                                , AName    => 'REQUESTOR'
                                );
--------------------------------------------------------------
	 OPEN Po_C3(L_Deliverable_Id);
	    Fetch Po_C3 into Po_Rec;
	    IF Po_C3%FOUND Then
	       L_Inventory_Org_Id := OKE_DTS_ACTION_PKG.Get_Org(Po_Rec.Direction
					, Po_Rec.Ship_From_Org_Id
					, Po_Rec.Ship_To_Org_Id);

	       Open Org_C(L_Inventory_Org_Id);
	          Fetch Org_C Into L_Org;
	       Close Org_C;

	       L_Ship_To_Location := Get_Location(Po_Rec.Buy_Or_Sell
						, Po_Rec.Direction
						, Po_Rec.Ship_To_Location_Id);


               OKE_DTS_INTEGRATION_PKG.Launch_Process
                     ( P_ACTION		            => 'REQ'
                     , P_API_VERSION                => 1
                     , P_COUNTRY_OF_ORIGIN_CODE     => Po_Rec.country_of_origin_code
                     , P_CURRENCY_CODE              => Po_Rec.CURRENCY_CODE
                     , P_DELIVERABLE_ID             => L_DELIVERABLE_ID
                     , P_DELIVERABLE_NUM            => Po_Rec.DELIVERABLE_NUM
                     , P_INIT_MSG_LIST	            => 'T'
                     , P_INSPECTION_REQED	    => Po_Rec.inspection_req_flag
                     , P_ITEM_DESCRIPTION           => Po_Rec.ITEM_DESCRIPTION
                     , P_ITEM_ID		    => Po_Rec.ITEM_ID
                     , P_ITEM_NUM		    => Po_Rec.ITEM
                     , P_K_HEADER_ID  	            => L_HEADER_ID
                     , P_K_NUMBER		    => L_Contract_Number
                     , P_LINE_NUMBER		    => L_LINE_NUMBER
                     , P_MPS_TRANSACTION_ID	    => Po_Rec.MPS_TRANSACTION_ID
                     , P_ORGANIZATION	            => L_ORG
                     , P_ORGANIZATION_ID	    => l_inventory_org_id
                     , P_PROJECT_ID		    => Po_Rec.PROJECT_ID
                     , P_PROJECT_NUM                => Po_Rec.PROJECT_NUMBER
                     , P_QUANTITY    	            => Po_Rec.QUANTITY
                     , P_SCHEDULE_DATE              => Po_Rec.expected_shipment_date
                     , P_SCHEDULE_DESIGNATOR        => Po_Rec.ndb_schedule_designator
                     , P_SHIP_TO_LOCATION           => L_SHIP_TO_LOCATION
                     , P_TASK_ID      	            => Po_Rec.TASK_ID
                     , P_TASK_NUM                   => Po_Rec.TASK_NUMBER
                     , P_UNIT_NUMBER                => Po_Rec.UNIT_NUMBER
                     , P_UOM_CODE                   => Po_Rec.UOM_CODE
                     , P_WORK_DATE		    => L_WORKDATE
                     , P_REQUESTOR => l_requestor
                     );

            End If; 	-- Operation Check
   	 Close Po_C3;



         ResultOut := 'COMPLETE:';
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'LAUNCH_REQ'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END LAUNCH_REQ;


   PROCEDURE READY_TO_COMPLETE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_ID  NUMBER;
      L_Completed_Flag VARCHAR2(1);
   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

         BEGIN
            SELECT COMPLETED_FLAG
            INTO   L_Completed_Flag
            FROM   OKE_K_DELIVERABLES_VL
            WHERE  DELIVERABLE_ID=L_Deliverable_ID;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;


         IF L_Completed_Flag = 'Y' THEN
            ResultOut := 'COMPLETE:T';
         ELSE
            ResultOut := 'COMPLETE:F';
         END IF;
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'READY_TO_COMPLETE'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END READY_TO_COMPLETE;


   PROCEDURE REQ_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_ID  NUMBER;
      L_Value NUMBER;
      L_Action VARCHAR2(25);

-- bug 3795796 Add deliver_to_location_id condition to have index key
      l_ship_to_location_id     NUMBER;

      CURSOR L IS
      SELECT SHIP_TO_LOCATION_ID
      FROM OKE_K_DELIVERABLES_B
      WHERE Deliverable_ID = L_Deliverable_ID;

      CURSOR C IS
      SELECT PO_Ref_1
      FROM OKE_K_DELIVERABLES_B
      WHERE Deliverable_ID = L_Deliverable_ID
      AND NOT EXISTS ( SELECT 1
                         FROM po_requisitions_interface_all
                        WHERE deliver_to_location_id      = l_ship_to_location_id
		          AND oke_contract_deliverable_id = l_deliverable_id
		          AND process_flag = 'ERROR' );

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );

	 OPEN L;
   	 FETCH L INTO L_Ship_To_Location_ID;
 	 CLOSE L;

	 OPEN C;
   	 FETCH C INTO L_Value;
 	 CLOSE C;

         IF L_Value > 0 THEN

            ResultOut := 'COMPLETE:T';
         ELSE
            ResultOut := 'COMPLETE:F';
         END IF;
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'REQ_EXISTED'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END REQ_EXISTED;

   PROCEDURE SHIP_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_ID  NUMBER;
      L_Value NUMBER;
      L_Action VARCHAR2(25);

      CURSOR C IS
      SELECT Shipping_Request_ID
      FROM OKE_K_DELIVERABLES_B
      WHERE Deliverable_ID = L_Deliverable_ID;

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );
	 OPEN C;
   	 FETCH C INTO L_Value;
 	 CLOSE C;

         IF L_Value > 0 THEN

            ResultOut := 'COMPLETE:T';
         ELSE
            ResultOut := 'COMPLETE:F';
         END IF;
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'SHIP_EXISTED'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END SHIP_EXISTED;

   PROCEDURE PLAN_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Deliverable_ID  NUMBER;
      L_Value NUMBER;
      L_Action VARCHAR2(25);

      CURSOR C IS
      SELECT Mps_Transaction_ID
      FROM OKE_K_DELIVERABLES_B
      WHERE Deliverable_ID = L_Deliverable_ID;

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Deliverable_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DELIVERABLE_ID'
                             );
	 OPEN C;
   	 FETCH C INTO L_Value;
 	 CLOSE C;

         IF L_Value > 0 THEN

            ResultOut := 'COMPLETE:T';
         ELSE
            ResultOut := 'COMPLETE:F';
         END IF;
         RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'PLAN_EXISTED'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END PLAN_EXISTED;


   PROCEDURE ABORT_PROCESS
   ( P_DELIVERABLE_ID    IN         NUMBER
   )
   IS
      L_WF_Item_Key  VARCHAR2(240);

      CURSOR C IS
      SELECT WF_ITEM_KEY
      FROM OKE_K_DELIVERABLES_B
      WHERE Deliverable_ID = P_Deliverable_ID;

   BEGIN
      OPEN C;
         FETCH C INTO L_WF_Item_Key;
      CLOSE C;

      IF L_WF_Item_Key IS NOT NULL THEN
         WF_ENGINE.AbortProcess('OKEDTS',L_WF_Item_Key);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END ABORT_PROCESS;

   PROCEDURE PERFORMER_EXISTED
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Performer VARCHAR2(80);

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Performer := WF_Engine.GetItemAttrText
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'PERFORMER'
                             );

	 IF L_Performer is null THEN
            ResultOut := 'COMPLETE:F';
         ELSE
            ResultOut := 'COMPLETE:T';
         END IF;

	 RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'PERFORMER_EXISTED'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END PERFORMER_EXISTED;

   PROCEDURE ELIGIBLE_TO_SEND
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_K_Header_ID        NUMBER;
      L_Due_Ntf_Id         NUMBER;
      L_Performer          VARCHAR2(80);

      CURSOR CSR_DUE_NTF(P_DUE_NTF_ID    NUMBER) IS
         SELECT ID
	       ,SOURCE_CODE
	       ,USAGE_CODE
               ,TARGET_DATE
	       ,BEFORE_AFTER
	       ,DURATION_DAYS
	       ,RECIPIENT
	       ,ROLE_ID
         FROM   OKE_NOTIFICATIONS
	 WHERE  ID=P_DUE_NTF_ID
	 ;
      REC_DUE_NTF CSR_DUE_NTF%ROWTYPE;

--      CURSOR CSR_ESC(P_K_HEADER_ID Number,P_ROLE_ID Number) IS
--         SELECT R.NAME
--         FROM   OKE_K_ALL_ACCESS_V  A
--               ,WF_ROLES            R
--         WHERE  A. K_HEADER_ID      = P_K_HEADER_ID
--         AND    A.ROLE_ID           = P_ROLE_ID
--         AND    R.ORIG_SYSTEM       = 'PER'
--         AND    R.ORIG_SYSTEM_ID    = A.PERSON_ID
--	 ORDER BY DECODE(ASSIGNMENT_LEVEL,'OKE_K_HEADERS',1
--					 ,'SITE',2
--					 ,3)
--         ;

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_K_Header_ID := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'K_HEADER_ID'
                             );

         L_Due_Ntf_Id := WF_Engine.GetItemAttrNumber
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'DUE_NTF_ID'
                             );

         OPEN CSR_DUE_NTF(L_Due_Ntf_Id);
            FETCH CSR_DUE_NTF INTO REC_DUE_NTF;
         CLOSE CSR_DUE_NTF;

         IF REC_DUE_NTF.ID IS NULL THEN
            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DUE_NTF_ID'
               , AValue      => NULL );

            ResultOut := 'COMPLETE:F';
            RETURN;
         ELSE
            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DUE_NTF_ID'
               , AValue      => REC_DUE_NTF.ID );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'SOURCE_CODE'
               , AValue      => REC_DUE_NTF.SOURCE_CODE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'USAGE_CODE'
               , AValue      => REC_DUE_NTF.USAGE_CODE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'TARGET_DATE'
               , AValue      => REC_DUE_NTF.TARGET_DATE );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'BEFORE_AFTER'
               , AValue      => REC_DUE_NTF.BEFORE_AFTER );

            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'DURATION_DAYS'
               , AValue      => REC_DUE_NTF.DURATION_DAYS );

            WF_ENGINE.SetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'RECIPIENT'
               , AValue      => REC_DUE_NTF.RECIPIENT );

            WF_ENGINE.SetItemAttrNumber
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName       => 'ROLE_ID'
               , AValue      => REC_DUE_NTF.ROLE_ID );

            IF REC_DUE_NTF.RECIPIENT='REQUESTOR' THEN
	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName       => 'PERFORMER'
                  , AValue      => FND_GLOBAL.User_Name);
            ELSIF REC_DUE_NTF.RECIPIENT='CONTRACT_ROLE' THEN
--               OPEN CSR_ESC(L_K_Header_ID,REC_DUE_NTF.ROLE_ID);
--                  FETCH CSR_ESC INTO L_Performer;
--               CLOSE CSR_ESC;

               L_Performer := OKE_UTILS.Retrieve_WF_Role_Name(L_K_Header_ID,REC_DUE_NTF.ROLE_ID);

               IF L_Performer IS NULL THEN
                  ResultOut := 'COMPLETE:F';
		  RETURN;
               ELSE
                  WF_ENGINE.SetItemAttrText
                     ( ItemType => ItemType
                     , ItemKey  => ItemKey
                     , AName    => 'PERFORMER'
                     , AValue   => L_Performer );
               END IF;

	    ELSE
	       WF_ENGINE.SetItemAttrText
                  ( ItemType => ItemType
                  , ItemKey  => ItemKey
                  , AName       => 'PERFORMER'
                  , AValue      => FND_GLOBAL.User_Name);
            END IF;

	    ResultOut := 'COMPLETE:T';
            RETURN;
         END IF;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'ELIGIBLE_TO_SEND'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END ELIGIBLE_TO_SEND;

   PROCEDURE LESS_THAN_TARGET_DATE
   ( ItemType            IN         VARCHAR2
   , ItemKey             IN         VARCHAR2
   , ActID               IN         NUMBER
   , FuncMode            IN         VARCHAR2
   , ResultOut           OUT NOCOPY VARCHAR2
   )
   IS
      L_Target_Date_Value DATE;

   BEGIN
      IF ( FuncMode = 'RUN' ) THEN

         L_Target_Date_Value := WF_Engine.GetItemAttrDate
                             ( ItemType => ItemType
                             , ItemKey  => ItemKey
                             , AName    => 'TARGET_DATE_VALUE'
                             );

	 IF Sysdate < L_Target_Date_Value THEN
            ResultOut := 'COMPLETE:T';
         ELSE
            ResultOut := 'COMPLETE:F';
         END IF;

	 RETURN;
      END IF;

      IF ( FuncMode = 'CANCEL' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

      IF ( FuncMode = 'TIMEOUT' ) THEN
         ResultOut := '';
         RETURN;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         ResultOut := 'ERROR:';
         WF_ENGINE.SetItemAttrText
            ( ItemType => ItemType
            , ItemKey  => ItemKey
            , AName    => 'ERRORTEXT'
            , AValue   => sqlerrm );
      WF_Core.Context
            ( 'OKE_DTS_WORKFLOW'
            , 'LESS_THAN_TARGET_DATE'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
      RAISE;

   END LESS_THAN_TARGET_DATE;

END OKE_DTS_WORKFLOW;

/
