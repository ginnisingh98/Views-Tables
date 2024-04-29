--------------------------------------------------------
--  DDL for Package WSH_TRANSACTIONS_TPW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRANSACTIONS_TPW_UTIL" AUTHID CURRENT_USER AS
/* $Header: WSHTXTPS.pls 120.0.12010000.2 2009/03/23 23:51:21 brana ship $ */

   C_SDEBUG  CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
   C_DEBUG   CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;

   PROCEDURE Check_Cancel_Allowed_WF ( P_item_type  IN    VARCHAR2,
                                       P_item_key   IN    VARCHAR2,
                                       P_actid      IN    NUMBER,
                                       P_funcmode   IN    VARCHAR2,
                                       X_resultout  OUT NOCOPY    VARCHAR2 );

   PROCEDURE Send_Cbod_Success_WF ( P_item_type  IN    VARCHAR2,
                                    P_item_key   IN    VARCHAR2,
                                    P_actid      IN    NUMBER,
                                    P_funcmode   IN    VARCHAR2,
                                    X_resultout  OUT NOCOPY    VARCHAR2 );

   PROCEDURE Send_Cbod_Failure_WF ( P_item_type  IN    VARCHAR2,
                                    P_item_key   IN    VARCHAR2,
                                    P_actid      IN    NUMBER,
                                    P_funcmode   IN    VARCHAR2,
                                    X_resultout  OUT NOCOPY    VARCHAR2 );

   PROCEDURE Raise_Cancel_Event_WF ( P_item_type  IN    VARCHAR2,
                                     P_item_key   IN    VARCHAR2,
                                     P_actid      IN    NUMBER,
                                     P_funcmode   IN    VARCHAR2,
                                     X_resultout  OUT NOCOPY    VARCHAR2 );
    -- ---------------------------------------------------------------------
    -- Procedure:	Raise_Close_Event_WF
    --
    -- Parameters:	Item_Type IN  VARCHAR2
    --                  Item_Key  IN  VARCHAR2
    --		       	Actid     IN  NUMBER
    --                  Funcmode  IN  VARCHAR2
    --                  Resultout OUT VARCHAR2
    --
    -- Description:  This procedure is called from Inbound workflow (WSHSTNDI) to
    --               trigger the API Raise_Close_Event that intern calls the business
    --               event oracle.apps.wsh.standalone.spwf to close all the previous
    --               error out revision of Shipment Request
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------
   PROCEDURE Raise_Close_Event_WF  ( P_item_type  IN          VARCHAR2 ,
                                     P_item_key   IN          VARCHAR2 ,
                                     P_actid      IN          NUMBER   ,
                                     P_funcmode   IN          VARCHAR2 ,
                                     X_resultout  OUT NOCOPY  VARCHAR2 );

   PROCEDURE Send_Cbod_Success ( P_item_type      IN    VARCHAR2,
                                 P_item_key       IN    VARCHAR2,
                                 X_Return_Status  OUT NOCOPY    VARCHAR2 );

   PROCEDURE Send_Cbod_Failure ( P_item_type      IN    VARCHAR2,
                                 P_item_key       IN    VARCHAR2,
                                 X_Return_Status  OUT NOCOPY    VARCHAR2 );

   PROCEDURE Check_Cancel_Allowed ( P_item_type  IN    VARCHAR2,
                                    P_item_key   IN    VARCHAR2,
                                    X_return_Status OUT NOCOPY  VARCHAR2 );

   PROCEDURE Raise_Cancel_Event ( P_item_type  IN    VARCHAR2,
                                  P_item_key   IN    VARCHAR2,
                                  X_return_Status OUT NOCOPY  VARCHAR2 );

    -- ---------------------------------------------------------------------
    -- Procedure:	Raise_Close_Event
    --
    -- Parameters:	P_Item_Type IN  VARCHAR2
    --                  P_Item_Key  IN  VARCHAR2
    --		       	X_return_Status VARCHAR2
    --
    -- Description:  This procedure is called from Raise_Close_Event_WF API to
    --               trigger the business event oracle.apps.wsh.standalone.spwf and
    ---              close all the previous error out revision of Shipment Request
    -- Created:     Standalone WMS Project
    -- -----------------------------------------------------------------------
   PROCEDURE Raise_Close_Event  ( P_item_type     IN          VARCHAR2 ,
                                  P_item_key      IN          VARCHAR2 ,
                                  X_return_Status OUT NOCOPY  VARCHAR2 );

   PROCEDURE Send_Shipment_Advice ( P_Entity_ID        IN  NUMBER,
                                    P_Entity_Type      IN  VARCHAR2,
                                    P_Action_Type      IN  VARCHAR2,
                                    P_Document_Type    IN  VARCHAR2,
                                    P_Org_ID           IN  NUMBER,
                                    X_Return_Status    OUT NOCOPY  VARCHAR2 );
END WSH_TRANSACTIONS_TPW_UTIL;

/
