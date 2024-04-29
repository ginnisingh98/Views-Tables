--------------------------------------------------------
--  DDL for Package Body CE_P2P_STMT_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_P2P_STMT_NOTIFICATION" as
/* $Header: cep2pwfb.pls 120.1 2002/11/12 21:21:44 bhchung noship $ */
PROCEDURE  SELECT_TRANSMISSION_TYPE(ITEMTYPE          IN  VARCHAR2
                               ,ITEMKEY           IN  VARCHAR2
                               ,ACTID             IN  NUMBER
                               ,FUNCMODE          IN  VARCHAR2
                               ,RESULTOUT         OUT NOCOPY VARCHAR2
                               ) IS
l_role varchar2(60);

BEGIN
   if (funcmode='RUN') then
      resultout:=wf_engine.getitemattrtext(itemtype => itemtype
                                          ,itemkey  => itemkey
                                          ,aname    => 'TRANSMISSION_TYPE'
                                          );
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
END SELECT_TRANSMISSION_TYPE;


END CE_P2P_STMT_NOTIFICATION;

/
