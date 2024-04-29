--------------------------------------------------------
--  DDL for Package Body PA_WEBADI_TRX_XFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WEBADI_TRX_XFACE" as
/* $Header: PAXWADIB.pls 120.2 2006/05/03 15:26 eyefimov noship $ */

Procedure Trx_Import ( P_Transaction_Source IN VARCHAR2,
                       P_Batch_Name         IN VARCHAR2,
                       P_Org_Id             IN NUMBER,
                       X_Msg               OUT NOCOPY VARCHAR,
                       X_Request_Id        OUT NOCOPY NUMBER )
is

begin

     Fnd_Request.Set_Org_Id(P_Org_Id);
     X_Request_Id := Fnd_Request.Submit_Request(
                                           'PA',
                                           'PAXTRTRX',
                                           NULL,
                                           NULL,
                                           FALSE,
                                           P_Transaction_Source ,
                                           P_Batch_Name,
                                           chr(0),NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL) ;

    if ( X_Request_Id = 0 ) then
        FND_MESSAGE.Retrieve(X_Msg);
    else
        x_msg := ' ';
        commit ;
    end if ;

Exception
     When Others Then
          Raise;

End Trx_Import ;

Function Get_Default_OU_Name Return Varchar2 is

      l_Default_Org_Id Number := Null;
      l_Default_Ou_Name Varchar2(240) := Null;
      l_Ou_Count Number := Null;

Begin

      Pa_Moac_Utils.Initialize(P_Product_Code => 'PA');
      Pa_Moac_Utils.Get_Default_OU(P_Product_Code => 'PA',
                                   P_Default_Org_Id => l_Default_Org_Id,
                                   P_Default_Ou_Name => l_Default_Ou_Name,
                                   P_Ou_Count => l_Ou_Count);

      Return (l_Default_Ou_Name);

End Get_Default_OU_Name;

Function Get_Default_Ou_Id Return Number is

      l_Default_Org_Id Number := Null;
      l_Default_Ou_Name Varchar2(240) := Null;
      l_Ou_Count Number := Null;

Begin

      Pa_Moac_Utils.Initialize(P_Product_Code => 'PA');
      Pa_Moac_Utils.Get_Default_OU(P_Product_Code => 'PA',
                                   P_Default_Org_Id => l_Default_Org_Id,
                                   P_Default_Ou_Name => l_Default_Ou_Name,
                                   P_Ou_Count => l_Ou_Count);

      Return (l_Default_Org_Id);

End Get_Default_OU_Id;

End PA_WEBADI_TRX_XFACE;

/
