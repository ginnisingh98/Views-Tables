--------------------------------------------------------
--  DDL for Package Body OKE_WORKFLOW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_WORKFLOW_UTILS" AS
/* $Header: OKEWFUTB.pls 120.1 2005/06/24 10:34:54 ausmani noship $ */
--
--  Name          : OKE workflow utilities
--  Pre-reqs      : None
--  Function      : This procedure performs utility functions regard
--                  OKE workflow.
--
--
--  Parameters    :
--  IN            : None
--  OUT NOCOPY           : None
--
--  Returns       : None
--

   PROCEDURE Update_Chg_Status_Apv(ITEMTYPE          IN  VARCHAR2
                              ,ITEMKEY           IN  VARCHAR2
                              ,ACTID             IN  NUMBER
                              ,FUNCMODE          IN  VARCHAR2
                              ,RESULTOUT         OUT NOCOPY VARCHAR2
                              ) IS

      l_chg_request_id  number;
      l_last_updated_id number;
      l_new_status_code varchar2(30);

   BEGIN
      if (funcmode='RUN') then

         l_chg_request_id:=wf_engine.getitemattrtext(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'CHG_REQUEST_ID'
                                                 );

         l_last_updated_id:=wf_engine.getitemattrtext(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'LAST_UPDATED_BY'
                                                 );

         l_new_status_code:=wf_engine.getitemattrtext(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'NEW_STATUS_CODE'
                                                 );

         update OKE_CHG_REQUESTS
            set CHG_STATUS_CODE ='APPROVED'
               ,LAST_UPDATED_BY =l_last_updated_id
               ,LAST_UPDATE_DATE=sysdate
          where CHG_REQUEST_ID  =l_chg_request_id;

         resultout:='COMPLETE:';
         return;
      end if;
      if (funcmode='CANCEL') then
         resultout:='COMPLETE:';
         return;
      end if;
      if (funcmode='TIMEOUT') then
         resultout:='COMPLETE:';
         return;
      end if;

   END Update_Chg_Status_Apv;

   PROCEDURE Update_Chg_Status_Rej(ITEMTYPE          IN  VARCHAR2
                              ,ITEMKEY           IN  VARCHAR2
                              ,ACTID             IN  NUMBER
                              ,FUNCMODE          IN  VARCHAR2
                              ,RESULTOUT         OUT NOCOPY VARCHAR2
                              ) IS

      l_chg_request_id  number;
      l_last_updated_id number;
      l_new_status_code varchar2(30);

   BEGIN
      if (funcmode='RUN') then

         l_chg_request_id:=wf_engine.getitemattrtext(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'CHG_REQUEST_ID'
                                                 );

         l_last_updated_id:=wf_engine.getitemattrtext(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'LAST_UPDATED_BY'
                                                 );

         l_new_status_code:=wf_engine.getitemattrtext(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'NEW_STATUS_CODE'
                                                 );

         update OKE_CHG_REQUESTS
            set CHG_STATUS_CODE ='REJECTED'
               ,LAST_UPDATED_BY =l_last_updated_id
               ,LAST_UPDATE_DATE=sysdate
          where CHG_REQUEST_ID  =l_chg_request_id;

         resultout:='COMPLETE:';
         return;
      end if;
      if (funcmode='CANCEL') then
         resultout:='COMPLETE:';
         return;
      end if;
      if (funcmode='TIMEOUT') then
         resultout:='COMPLETE:';
         return;
      end if;

   END Update_Chg_Status_Rej;

   PROCEDURE Is_Impact_Funding(
                            ITEMTYPE          IN  VARCHAR2
                           ,ITEMKEY           IN  VARCHAR2
                           ,ACTID             IN  NUMBER
                           ,FUNCMODE          IN  VARCHAR2
                           ,RESULTOUT         OUT NOCOPY VARCHAR2
                           )
   IS
      xc_is_impact_funding  varchar2(1) :=
      wf_engine.GetItemAttrText( itemtype => itemtype,
		                 itemkey  => itemkey,
			         aname    => 'IMPACT_FUNDING_FLAG');

   BEGIN
      if (funcmode = 'RUN') then
         if (upper(xc_is_impact_funding)='Y') then
            resultout := 'COMPLETE:Y';
         else
            resultout := 'COMPLETE:N';
         end if;
         return;
      end if;
      if (funcmode = 'CANCEL') then
         resultout := 'COMPLETE:';
         return;
      end if;
      if (funcmode = 'TIMEOUT') then
         resultout := 'COMPLETE:';
         return;
      end if;
   EXCEPTION
      when others then
         wf_core.context('OKE_WORKFLOW_UTILS', 'IS_IMPACT_FUNDING',itemtype, itemkey, actid,funcmode,resultout);
         raise;
   END Is_Impact_Funding;
PROCEDURE Set_moac_context(Item_Type            IN      VARCHAR2 ,
                           Item_Key             IN      VARCHAR2 ,
                           Actvity_ID           IN      NUMBER ,
                           Command              IN      VARCHAR2 ,
                           ResultOut           OUT     NOCOPY VARCHAR2)
IS
ORG_ID NUMBER;
BEGIN

  ORG_ID := WF_Engine.GetItemAttrNumber(Item_Type , Item_Key , 'ORG_ID');

  IF (command = 'RUN') THEN
          ResultOut := 'COMPLETE:';
  END IF;

  IF (command = 'SET_CTX') THEN
        mo_global.set_policy_context( 'S', Org_Id);
  END IF;

  IF (command = 'TEST_CTX') THEN
       IF (NVL(mo_global.get_access_mode,'NULL') <> 'S') OR
          (NVL(mo_global.get_current_org_id,-99) <> Org_Id)    THEN
          ResultOut := 'FALSE';
  ELSE
          ResultOut := 'TRUE';
       END IF;
  END IF;
END;
END OKE_WORKFLOW_UTILS;

/
