--------------------------------------------------------
--  DDL for Package Body CSTPSCWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSCWF" AS
/* $Header: CSTSCWFB.pls 120.0 2005/05/25 04:48:32 appldev noship $ */

-- FUNCTION
--  START_STD_WF       Calls the appropriate Standard Costing Workflow process
--                     based on the accounting line type.
--
--
-- RETURN VALUES
--  integer             -1      Use default account.
--                      >0      This is the User defined account.
--                       0      This is an error condition.

FUNCTION START_STD_WF(X_TXN_ID IN NUMBER,
                          X_TXN_TYPE_ID IN NUMBER,
                          X_TXN_ACT_ID NUMBER,
                          X_TXN_SRC_TYPE_ID IN NUMBER,
                          X_ORG_ID  IN NUMBER,
                          X_ITEM_ID IN NUMBER,
                          X_CE_ID IN NUMBER,
                          X_ALT IN NUMBER,
                          X_SUBINV IN VARCHAR2,
                          X_CG_ID IN NUMBER,
                          X_RES_ID IN NUMBER,
                          X_ERR_NUM OUT NOCOPY NUMBER,
                          X_ERR_CODE OUT NOCOPY VARCHAR2,
                          X_ERR_MSG OUT NOCOPY VARCHAR2)
RETURN integer IS

  L_ITEMTYPE  VARCHAR2(30) := 'CSTSTDWF';
  L_ITEMKEY	  VARCHAR2(30) := '#SYNCH';
  L_ACCT_NUM NUMBER := -1;
  L_WORKFLOW_FUNC_FLAG NUMBER;

  BEGIN

  /* Initializing the flag to 0. This flag should be set to 1
      for every accounting line type for which a workflow process
      is created. The flag is to ensure that all workflow calls
      are invoked only for the accounting line types that are
      supported for Product Line Accounting. */

    L_WORKFLOW_FUNC_FLAG := 0;

--  SELECT TO_CHAR(FND_FLEX_WORKFLOW_ITEMKEY_S.NEXTVAL) into L_ITEMKEY from dual;

     IF (X_ALT = 1) THEN
-- Inventory valuation

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT1');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 2) THEN
-- Account

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT2');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 3) THEN
-- Overhead absorption

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT3');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 4) THEN
-- Resource absorption

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT4');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 5) THEN
-- Receiving inspection

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT5');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 6) THEN
-- PPV or rate variance

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT6');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 7) THEN
-- WIP valuation

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT7');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 8) THEN
-- WIP variance

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT8');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 9) THEN
-- Inter-org payables

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT9');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 10) THEN
-- Inter-org receivables

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT10');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 11) THEN
-- Inter-org transfer credit

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT11');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 12) THEN
-- Inter-org freight charge

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT12');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 13) THEN
-- Average cost variance

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT13');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 14) THEN
-- Intransit inventory

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT14');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 15) THEN
-- Encumbrance reversal

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT15');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 30) THEN
/* Added for Transfer Pricing Project */
-- Profit in inventory

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT30');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 16) THEN
-- Accrual

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT16');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 31) THEN
-- Clearing Account

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT31');
          L_WORKFLOW_FUNC_FLAG := 1;

     ELSIF (X_ALT = 32) THEN
-- Retroactive Price Adjustment

          wf_engine.CreateProcess(L_ITEMTYPE, L_ITEMKEY, 'STDALT32');
          L_WORKFLOW_FUNC_FLAG := 1;

     END IF;

  IF ( L_WORKFLOW_FUNC_FLAG = 1 ) THEN

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    => 'TXN_ID',
                               avalue   => X_TXN_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    => 'TXN_TYPE_ID',
                               avalue   => X_TXN_TYPE_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    => 'TXN_ACT_ID',
                               avalue   => X_TXN_ACT_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    => 'SRC_TYPE_ID',
                               avalue   => X_TXN_SRC_TYPE_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    => 'ITEM_ID',
                               avalue   => X_ITEM_ID);

     wf_engine.SetItemAttrText(itemtype => L_ITEMTYPE,

                               itemkey  => L_ITEMKEY,

                               aname    => 'SUBINV',
                               avalue   => X_SUBINV);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,

                               itemkey  => L_ITEMKEY,

                               aname    => 'CG_ID',
                               avalue   => X_CG_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,

                               itemkey  => L_ITEMKEY,

                               aname    => 'ORG_ID',
                               avalue   => X_ORG_ID);

    wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,

                               itemkey  => L_ITEMKEY,

                               aname    => 'CE_ID',
                               avalue   => X_CE_ID);

    wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,

                               itemkey  => L_ITEMKEY,

                               aname    => 'RES_ID',
                               avalue   => X_RES_ID);


    wf_engine.StartProcess(L_ITEMTYPE, L_ITEMKEY);

    L_ACCT_NUM := wf_engine.GetItemAttrNumber(itemtype => L_ITEMTYPE,

                                              itemkey  => L_ITEMKEY,

                                              aname    => 'ACCT');


    X_ERR_NUM := wf_engine.GetItemAttrNumber(itemtype => L_ITEMTYPE,

                                             itemkey  => L_ITEMKEY,

                                             aname    => 'ERR_NUM');


    X_ERR_CODE := wf_engine.GetItemAttrText(itemtype => L_ITEMTYPE,

                                            itemkey  => L_ITEMKEY,

                                            aname    => 'ERR_CODE');

    X_ERR_MSG := wf_engine.GetItemAttrText(itemtype => L_ITEMTYPE,

                                           itemkey  => L_ITEMKEY,

                                           aname    => 'ERR_MSG');

   END IF;

   return L_ACCT_NUM;

   EXCEPTION
     WHEN OTHERS THEN
      X_ERR_NUM := -1;
      X_ERR_CODE := TO_CHAR(SQLCODE);
      X_ERR_MSG := 'Error in CSTPSCWF.START_STD_WF' || substrb(SQLERRM,1,150);
      return 0;
      RAISE;
  END; /*  START_STD_WF */


-- WORKFLOW FUNCTION
--  GET_STD_CE          Returns the cost element ID.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains the cost element ID.


  PROCEDURE GET_STD_CE(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2)
  IS
     L_CE          NUMBER;
  BEGIN
  IF (FUNCMODE = 'RUN') THEN
     L_CE := wf_engine.GetItemAttrNumber(itemtype,itemkey,'CE_ID');

     if (L_CE = 1) then
        result := 'COMPLETE:1';
     elsif (L_CE = 2) then
        result := 'COMPLETE:2';
     elsif (L_CE = 3) then
        result := 'COMPLETE:3';
     elsif (L_CE = 4) then
        result := 'COMPLETE:4';
     else
        result := 'COMPLETE:5';
     end if;

     RETURN;
  END IF;

  IF (funcmode = 'CANCEL') THEN
       result :=  'COMPLETE';
       RETURN;
  ELSE
       result := '';
       RETURN;
  END IF;

    EXCEPTION
       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_STD_CE',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','Error in CSTPSCWF.GET_STD_CE' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;

  END;  /* GET_STD_CE */


-- WORKFLOW FUNCTION
--  GET_DEF_ACC        Returns -1 for using default accounts.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains -1.


PROCEDURE GET_DEF_ACC(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2) IS
  BEGIN
  IF (FUNCMODE = 'RUN') THEN
        result := 'COMPLETE:-1';

    wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',-1);

     RETURN;
  END IF;

  IF (funcmode = 'CANCEL') THEN
       result :=  'COMPLETE';
       RETURN;
  ELSE
       result := '';
       RETURN;
  END IF;
 EXCEPTION
       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_DEF_ACC',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','CSTPSCWF.GET_DEF_ACC' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;

  END;  /* GET_DEF_ACC */


-- WORKFLOW FUNCTION
--  GET_STD_MTL_PLA    Returns the Product line Material Account.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains SUCCESS or FAILURE.


  PROCEDURE GET_STD_MTL_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2)
  IS
     L_ACCOUNT number := -1;
     L_ORG_ID number;
     L_ITEM_ID number;
     L_SUBINV varchar2(20);
  BEGIN
  IF (FUNCMODE = 'RUN') THEN

    L_ORG_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
    L_ITEM_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ITEM_ID');
    L_SUBINV := wf_engine.GetItemAttrText(itemtype,itemkey,'SUBINV');

    SELECT nvl(mca.material_account,-1) into L_ACCOUNT
    FROM MTL_CATEGORY_ACCOUNTS mca,
         MTL_ITEM_CATEGORIES   mic,
         MTL_DEFAULT_CATEGORY_SETS mdcs
    WHERE mdcs.functional_area_id = 8
    AND   mdcs.category_set_id = mic.category_set_id
    AND   mca.category_id = mic.category_id
    AND   mca.category_set_id = mic.category_set_id
    AND   mca.organization_id = mic.organization_id
    AND   mca.subinventory_code = L_SUBINV
    AND   mic.organization_id = L_ORG_ID
    AND   mic.inventory_item_id = L_ITEM_ID;

    wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',L_ACCOUNT);

     result := 'COMPLETE:SUCCESS';
    RETURN;
   END IF;

  IF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;

  ELSE

       result := '';

       RETURN;

  END IF;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
         L_ACCOUNT := -1;
         wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',-1);
         result := 'COMPLETE:SUCCESS';
         RETURN;

       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_STD_MTL_PLA',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
 wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','CSTPSCWF.GET_STD_MTL_PLA' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;
  END;  /* GET_STD_MTL_PLA */


-- WORKFLOW FUNCTION
--  GET_STD_MO_PLA     Returns the Product line Material Overhead Account.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains SUCCESS or FAILURE.


  PROCEDURE GET_STD_MO_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2)
  IS
     L_ACCOUNT number := -1;
     L_ORG_ID number;
     L_ITEM_ID number;
     L_SUBINV varchar2(20);
  BEGIN
  IF (FUNCMODE = 'RUN') THEN

    L_ORG_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
    L_ITEM_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ITEM_ID');
    L_SUBINV := wf_engine.GetItemAttrText(itemtype,itemkey,'SUBINV');

    SELECT nvl(mca.material_overhead_account,-1) into L_ACCOUNT
    FROM MTL_CATEGORY_ACCOUNTS mca,
         MTL_ITEM_CATEGORIES   mic,
         MTL_DEFAULT_CATEGORY_SETS mdcs
    WHERE mdcs.functional_area_id = 8
    AND   mdcs.category_set_id = mic.category_set_id
    AND   mca.category_id = mic.category_id
    AND   mca.category_set_id = mic.category_set_id
    AND   mca.organization_id = mic.organization_id
    AND   mca.subinventory_code = L_SUBINV
    AND   mic.organization_id = L_ORG_ID
    AND   mic.inventory_item_id = L_ITEM_ID;

    wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',L_ACCOUNT);

     result := 'COMPLETE:SUCCESS';
    RETURN;
   END IF;

  IF (funcmode = 'CANCEL') THEN
    result :=  wf_engine.eng_completed;
       RETURN;

  ELSE

       result := '';

       RETURN;

  END IF;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
         L_ACCOUNT := -1;
         wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',-1);
         result := 'COMPLETE:SUCCESS';
         RETURN;


       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_STD_MO_PLA',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','Error in CSTPSCWF.GET_STD_MO_PLA' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;

  END;  /* GET_STD_MO_PLA */


-- WORKFLOW FUNCTION
--  GET_STD_RES_PLA     Returns the Product line Resource Account.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains SUCCESS or FAILURE.


  PROCEDURE GET_STD_RES_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2)
  IS
     L_ACCOUNT number := -1;
     L_ORG_ID number;
     L_ITEM_ID number;
     L_SUBINV varchar2(20);
  BEGIN
  IF (FUNCMODE = 'RUN') THEN

    L_ORG_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
    L_ITEM_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ITEM_ID');
    L_SUBINV := wf_engine.GetItemAttrText(itemtype,itemkey,'SUBINV');

    SELECT nvl(mca.resource_account,-1) into L_ACCOUNT
    FROM MTL_CATEGORY_ACCOUNTS mca,
         MTL_ITEM_CATEGORIES   mic,
         MTL_DEFAULT_CATEGORY_SETS mdcs
    WHERE mdcs.functional_area_id = 8
    AND   mdcs.category_set_id = mic.category_set_id
    AND   mca.category_id = mic.category_id
    AND   mca.category_set_id = mic.category_set_id
    AND   mca.organization_id = mic.organization_id
    AND   mca.subinventory_code = L_SUBINV
    AND   mic.organization_id = L_ORG_ID
    AND   mic.inventory_item_id = L_ITEM_ID;

    wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',L_ACCOUNT);

     result := 'COMPLETE:SUCCESS';
    RETURN;
   END IF;

  IF (funcmode = 'CANCEL') THEN
    result :=  wf_engine.eng_completed;
       RETURN;

  ELSE

       result := '';

       RETURN;

  END IF;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
         L_ACCOUNT := -1;
         wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',-1);
         result := 'COMPLETE:SUCCESS';
         RETURN;


       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_STD_RES_PLA',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','Error in CSTPSCWF.GET_STD_RES_PLA' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;
  END;  /* GET_STD_RES_PLA */


-- WORKFLOW FUNCTION
--  GET_STD_OSP_PLA     Returns the Product line Outside Processing Account.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains SUCCESS or FAILURE.


  PROCEDURE GET_STD_OSP_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2)
  IS
     L_ACCOUNT number := -1;
     L_ORG_ID number;
     L_ITEM_ID number;
     L_SUBINV varchar2(20);
  BEGIN
  IF (FUNCMODE = 'RUN') THEN

    L_ORG_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
    L_ITEM_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ITEM_ID');
    L_SUBINV := wf_engine.GetItemAttrText(itemtype,itemkey,'SUBINV');


    SELECT nvl(mca.outside_processing_account,-1) into L_ACCOUNT
    FROM MTL_CATEGORY_ACCOUNTS mca,
         MTL_ITEM_CATEGORIES   mic,
         MTL_DEFAULT_CATEGORY_SETS mdcs
    WHERE mdcs.functional_area_id = 8
    AND   mdcs.category_set_id = mic.category_set_id
    AND   mca.category_id = mic.category_id
    AND   mca.category_set_id = mic.category_set_id
    AND   mca.organization_id = mic.organization_id
    AND   mca.subinventory_code = L_SUBINV
    AND   mic.organization_id = L_ORG_ID
    AND   mic.inventory_item_id = L_ITEM_ID;

    wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',L_ACCOUNT);

     result := 'COMPLETE:SUCCESS';
    RETURN;
   END IF;

   IF (funcmode = 'CANCEL') THEN
    result :=  wf_engine.eng_completed;
       RETURN;

   ELSE

       result := '';

       RETURN;

  END IF;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
         L_ACCOUNT := -1;
         wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',-1);
         result := 'COMPLETE:SUCCESS';
         RETURN;


       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_STD_OSP_PLA',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','Error in CSTPSCWF.GET_STD_OSP_PLA' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;
  END;  /* GET_STD_OSP_PLA */


-- WORKFLOW FUNCTION
--  GET_STD_OVH_PLA     Returns the Product line Overhead Account.
--
--
-- RETURN VALUES
--  integer            RESULT OUT variable contains SUCCESS or FAILURE.


  PROCEDURE GET_STD_OVH_PLA(ITEMTYPE  IN VARCHAR2,
                   ITEMKEY     IN VARCHAR2,
                   ACTID       IN NUMBER,
                   FUNCMODE    IN VARCHAR2,
                   RESULT      OUT NOCOPY VARCHAR2)
  IS
     L_ACCOUNT number := -1;
     L_ORG_ID number;
     L_ITEM_ID number;
     L_SUBINV varchar(20);
  BEGIN
  IF (FUNCMODE = 'RUN') THEN

    L_ORG_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
    L_ITEM_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ITEM_ID');
    L_SUBINV := wf_engine.GetItemAttrText(itemtype,itemkey,'SUBINV');


    SELECT nvl(mca.overhead_account,-1) into L_ACCOUNT
    FROM MTL_CATEGORY_ACCOUNTS mca,
         MTL_ITEM_CATEGORIES   mic,
         MTL_DEFAULT_CATEGORY_SETS mdcs
    WHERE mdcs.functional_area_id = 8
    AND   mdcs.category_set_id = mic.category_set_id
    AND   mca.category_id = mic.category_id
    AND   mca.category_set_id = mic.category_set_id
    AND   mca.organization_id = mic.organization_id
    AND   mca.subinventory_code = L_SUBINV
    AND   mic.organization_id = L_ORG_ID
    AND   mic.inventory_item_id = L_ITEM_ID;

    wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',L_ACCOUNT);

     result := 'COMPLETE:SUCCESS';
    RETURN;
   END IF;

   IF (funcmode = 'CANCEL') THEN
    result :=  wf_engine.eng_completed;
       RETURN;

   ELSE

       result := '';

       RETURN;

  END IF;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
         L_ACCOUNT := -1;
         wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',-1);
         result := 'COMPLETE:SUCCESS';
         RETURN;


       WHEN OTHERS THEN
wf_core.context('CSTPSCWF','GET_STD_OVH_PLA',itemtype,itemkey,TO_CHAR(actid),funcmode);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ACCT',0);
     wf_engine.SetItemAttrNumber(itemtype,itemkey,'ERR_NUM',-1);
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_CODE',TO_CHAR(SQLCODE));
     wf_engine.SetItemAttrText(itemtype,itemkey,'ERR_MSG','Error in CSTPSCWF.GET_STD_OVH_PLA' || substrb(SQLERRM,1,150));
      result :=  'COMPLETE:FAILURE';
      RAISE;
  END;  /* GET_STD_OVH_PLA */

END CSTPSCWF;

/
