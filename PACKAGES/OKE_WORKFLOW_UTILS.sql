--------------------------------------------------------
--  DDL for Package OKE_WORKFLOW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_WORKFLOW_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEWFUTS.pls 120.1 2005/06/24 10:35:15 ausmani noship $ */
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
                           );

PROCEDURE Update_Chg_Status_Rej(ITEMTYPE          IN  VARCHAR2
                           ,ITEMKEY           IN  VARCHAR2
                           ,ACTID             IN  NUMBER
                           ,FUNCMODE          IN  VARCHAR2
                           ,RESULTOUT         OUT NOCOPY VARCHAR2
                           );

PROCEDURE Is_Impact_Funding(
                            ITEMTYPE          IN  VARCHAR2
                           ,ITEMKEY           IN  VARCHAR2
                           ,ACTID             IN  NUMBER
                           ,FUNCMODE          IN  VARCHAR2
                           ,RESULTOUT         OUT NOCOPY VARCHAR2
                           );
-- Function set_moac_context
-- This API will be called from Workflow as a callback method to support MOAC
PROCEDURE Set_moac_context(Item_Type            IN      VARCHAR2 ,
                           Item_Key             IN      VARCHAR2 ,
                           Actvity_ID           IN      NUMBER ,
                           Command              IN      VARCHAR2 ,
                           ResultOut           OUT     NOCOPY VARCHAR2);

END OKE_WORKFLOW_UTILS;

 

/
