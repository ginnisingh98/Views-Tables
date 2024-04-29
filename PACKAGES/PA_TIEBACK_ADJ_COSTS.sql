--------------------------------------------------------
--  DDL for Package PA_TIEBACK_ADJ_COSTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TIEBACK_ADJ_COSTS" AUTHID CURRENT_USER As
/* $Header: PAXAPJTS.pls 115.1 2002/08/22 19:14:44 eyefimov noship $ */

  TYPE PoDistTab IS TABLE OF VARCHAR2(1)
        INDEX BY BINARY_INTEGER;

  TYPE ParentTxnTab IS TABLE OF VARCHAR2(1)
        INDEX BY BINARY_INTEGER;

Function Is_Adjusted(P_Po_Dist IN Number,
                     P_Txn_Id  IN Number,
                     P_Parent_Txn_Id IN Number,
                     P_Trx_Type IN Varchar2) Return Varchar2;

Procedure TiebackAdjCosts(X_Return_Status      OUT Varchar2,
                          X_Error_Message_Code OUT Varchar2);

   G_REQUEST_ID             Number;
   G_PROGRAM_APPLICATION_ID Number;
   G_PROGRAM_ID             Number;
   G_DEBUG_MODE             Varchar2(1);

Procedure Init ;

Procedure Log_Message(P_Message IN Varchar2);

Procedure Write_Output (X_Return_Status      OUT Varchar2,
                        X_Error_Message_Code OUT Varchar2);

End Pa_Tieback_Adj_Costs;

 

/
