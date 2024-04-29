--------------------------------------------------------
--  DDL for Package Body AR_FLEXBUILDER_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_FLEXBUILDER_UPGRADE" AS
/* $Header: ARFLBUPB.pls 120.3 2006/09/09 05:53:57 rkader ship $ */


PROCEDURE CALL_UPGRADED_FLEX ( ITEMTYPE 	IN VARCHAR2
                            , ITEMKEY 		IN VARCHAR2
                            , ACTID             IN NUMBER
                            , FUNCMODE          IN VARCHAR2
                            , RESULT OUT NOCOPY VARCHAR2 ) IS

L_AR_FLEX_NUM NUMBER;
L_AR_ORIGINAL_CCID NUMBER;
L_AR_SUBSTI_CCID NUMBER;

FB_FLEX_SEG VARCHAR2(2000);
FB_ERROR_MSG VARCHAR2(2000);

BEGIN

 IF (funcmode = 'RUN') THEN

  L_AR_FLEX_NUM := WF_ENGINE.GetItemAttrNumber(ITEMTYPE,ITEMKEY,'CHART_OF_ACCOUNTS_ID');
  L_AR_ORIGINAL_CCID := WF_ENGINE.GetItemAttrNumber(ITEMTYPE,ITEMKEY,'ARORIGCCID');
  L_AR_SUBSTI_CCID := WF_ENGINE.GetItemAttrNumber(ITEMTYPE,ITEMKEY,'ARSUBSTICCID');

  IF NOT AR_SUBSTI_BALANCING_SEG.BUILD(
                             FB_FLEX_NUM => L_AR_FLEX_NUM
                            ,AR_FLEX_NUM => L_AR_FLEX_NUM
                            ,AR_ORIGINAL_CCID => L_AR_ORIGINAL_CCID
                            ,AR_SUBSTI_CCID => L_AR_SUBSTI_CCID
                            ,FB_FLEX_SEG => FB_FLEX_SEG
                            ,FB_ERROR_MSG => FB_ERROR_MSG ) THEN


    -- False returned by build function
    -- We need to set the error message and return false.

    WF_ENGINE.SetItemAttrText(ITEMTYPE,ITEMKEY,'ERROR_MESSAGE',FB_ERROR_MSG);

    FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS ( ITEMTYPE , ITEMKEY , FB_FLEX_SEG );

    RESULT := 'FAILURE';

  ELSE

    FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS ( ITEMTYPE , ITEMKEY , FB_FLEX_SEG );

    RESULT := 'SUCCESS';
  END IF;

 ELSIF (funcmode = 'CANCEL') THEN
   result := 'COMPLETE:';
   RETURN;
 ELSE
   result := '';
   RETURN;
 END IF;
END;

END;


/
