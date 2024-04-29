--------------------------------------------------------
--  DDL for Package PA_WEBADI_TRX_XFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WEBADI_TRX_XFACE" AUTHID CURRENT_USER as
/* $Header: PAXWADIS.pls 120.1 2006/05/03 15:25 eyefimov noship $ */

Procedure Trx_Import ( P_Transaction_Source IN VARCHAR2,
                       P_Batch_Name         IN VARCHAR2,
                       P_Org_Id             IN NUMBER,
                       X_Msg               OUT NOCOPY VARCHAR,
                       X_Request_Id        OUT NOCOPY NUMBER );

Function Get_Default_OU_Name Return Varchar2;

Function Get_Default_Ou_Id Return Number;

End PA_WEBADI_TRX_XFACE;
 

/
