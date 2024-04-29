--------------------------------------------------------
--  DDL for Package CE_P2P_STMT_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_P2P_STMT_NOTIFICATION" AUTHID CURRENT_USER as
/* $Header: cep2pwfs.pls 120.1 2002/11/12 21:22:08 bhchung noship $ */
PROCEDURE  SELECT_TRANSMISSION_TYPE(ITEMTYPE          IN  VARCHAR2
                               ,ITEMKEY           IN  VARCHAR2
                               ,ACTID             IN  NUMBER
                               ,FUNCMODE          IN  VARCHAR2
                               ,RESULTOUT         OUT NOCOPY VARCHAR2
                               );

END CE_P2P_STMT_NOTIFICATION;

 

/
