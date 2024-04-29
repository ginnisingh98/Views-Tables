--------------------------------------------------------
--  DDL for Package Body OKS_OMINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_OMINT_PUB" AS
/* $Header: OKSPOMIB.pls 120.25 2007/12/24 10:17:56 rriyer ship $ */



TYPE War_item_rec_type IS RECORD (War_item_id Number);

TYPE War_item_id_tbl_type IS TABLE OF War_item_rec_type INDEX BY BINARY_INTEGER;

l_war_item_Id           NUMBER;



Procedure Get_Duration
(
  P_Api_Version     IN Number,
  P_init_msg_list           IN Varchar2 Default OKC_API.G_FALSE,
  X_msg_Count        OUT NOCOPY  Number,
  X_msg_Data         OUT NOCOPY  Varchar2,
  X_Return_Status          OUT NOCOPY  Varchar2,
  P_customer_id             IN Number,
  P_system_id       IN Number,
  P_Service_Duration  IN Number,
  P_service_period    IN Varchar2,
  P_coterm_checked_yn IN Varchar2 Default OKC_API.G_FALSE,
  P_start_date      IN Date,
  P_end_date          IN Date,
  X_service_duration OUT NOCOPY  Number,
  X_service_period   OUT NOCOPY Varchar2,
  X_new_end_date           OUT NOCOPY  Date
)
Is
l_api_name        CONSTANT VARCHAR2(30) := 'GET_DURATION';
l_api_version     CONSTANT NUMBER           := 11.5;
l_row_count           NUMBER;
l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

Cursor l_Customer_Coterm_Csr is
          Select Coterminate_Day_Month
          From HZ_CUST_ACCOUNTS  --OKX_CUSTOMER_ACCOUNTS_V
          Where CUST_ACCOUNT_ID = p_customer_id;

Cursor l_System_Coterm_Csr is
         Select Coterminate_Day_Month
         From CS_SYSTEMS_ALL_B --OKX_SYSTEMS_V
         Where  SYSTEM_ID = P_system_id;

Cursor l_UOM_Csr Is
         Select UOM_Code, Unit_Of_Measure
         From MTL_UNITS_OF_MEASURE_TL --OKX_UNITS_OF_MEASURE_V
         Where UOM_Code = p_Service_Period;


Cursor l_tce_csr(p_code varchar2, p_qty Number) Is
       Select uom_code
       from   OKC_TIME_CODE_UNITS_V
       Where tce_code = p_code
       And   quantity = p_qty;


l_sys_coterm    Varchar2(6);
l_cus_coterm    Varchar2(6);
l_min_duration  Number;
l_min_period    Varchar2(10);
l_coterm_day    Varchar2(6);

l_time_duration    Number;
l_time_unit            Varchar2(20);
l_uom_rec          l_UOM_Csr%ROWTYPE;
l_unit_of_measure        Varchar2(20);
l_tce_rec               l_tce_csr%rowtype;
BEGIN

     x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- Profile Check
     l_min_duration := fnd_profile.value('OKS_MINIMUM_SVC_DURATION');
     l_min_period   := fnd_profile.value('OKS_MINIMUM_SVC_PERIOD');
     l_min_duration := Round(l_min_duration,0);
     If l_min_duration Is Null Or l_min_period Is Null  Then
  --     l_min_duration := 60;
      --   l_min_period   := 'DAY';

       l_return_status := OKC_API.G_RET_STS_ERROR;
       OKC_API.set_message(G_APP_NAME,'OKS_PROFILE_NOT_SET');
      Raise G_EXCEPTION_HALT_VALIDATION;

     End If;

-- Parameter Check

     If p_start_date Is Null Then
          l_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message(G_APP_NAME,'OKS_START_DATE_REQUIRED');
          Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

     If p_end_date Is Null And (p_service_duration Is Null Or p_service_period Is Null) Then
          l_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message(G_APP_NAME,'OKS_END_DT_DUR_REQUIRED');
          Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

     If p_Service_Duration Is Not Null Then
          Open  l_UOM_Csr;
          Fetch l_UOM_Csr Into l_UOM_Rec;
          If l_UOM_Csr%NotFound Then
               l_return_status := OKC_API.G_RET_STS_ERROR;
               OKC_API.set_message(G_APP_NAME,'OKS_INVD_PERIOD');
               Raise G_EXCEPTION_HALT_VALIDATION;
          End if;
          l_unit_of_measure := l_uom_rec.uom_code;
     End If;

     Open  l_system_coterm_csr;
     Fetch l_system_coterm_csr Into l_sys_coterm;
     Close l_system_coterm_csr;

     Open  l_customer_coterm_csr;
     Fetch l_customer_coterm_csr into l_cus_coterm;
     Close l_customer_coterm_csr;

     If l_sys_coterm Is Not NULL Then
         l_coterm_day := l_sys_coterm;
     Elsif l_cus_coterm Is Not NULL Then
         l_coterm_day := l_cus_coterm;
     End if;

     If l_coterm_day is not null And Upper(p_coterm_checked_yn) = 'Y' Then
         x_new_end_date :=  TO_DATE(l_coterm_day || to_char(p_start_date,'YYYY'),'MM/DD/YYYY HH24:MI:SS');
         If Upper(l_min_period) = 'DAY' Then
         Loop
             If (x_new_end_date - p_start_Date) < l_min_duration  Then
                    x_new_end_date := add_months(x_new_end_date,12);
             Else
                    exit;
             End if;
         End Loop;
         Elsif Upper(l_min_period) = 'MONTHS' then
         Loop
             if months_between(x_new_end_date,p_start_date) < l_min_duration then
                     x_new_end_date := add_months(x_new_end_date,12);
             else
                     exit;
             End if;
         End Loop;
         Elsif Upper(l_min_period) = 'YEAR' then
         Loop
             If months_between(x_new_end_date,p_start_date) < (l_min_duration * 12) then
                   x_new_end_date := add_months(x_new_end_date,12);
             Else
                   exit;
             End if;
         End Loop;
         End if;

         OKC_TIME_UTIL_PUB.get_duration (
                                         p_start_date => p_start_date,
                                         p_end_date   => x_new_end_date,
                                         x_duration   => x_service_duration,
                                         x_timeunit   => x_service_period,
                                         x_return_status => l_return_status
                                        );

         If   not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                 Raise G_EXCEPTION_HALT_VALIDATION;
         End if;
     Else

         If p_end_date is null then
                 x_new_end_date := OKC_TIME_UTIL_PUB.GET_ENDDATE
                                   (
                                    p_start_date => p_start_date,
                                    p_timeunit   => l_unit_of_measure,
                                    p_duration   => p_service_duration
                                   );
         Else
                 x_new_end_date := p_end_date;
         End If;


         If Upper(l_min_period) = 'MONTHS' then
                 if months_between(x_new_end_date,p_start_date) < l_min_duration then
                             Open l_tce_csr('MONTH',1);
                             Fetch l_tce_csr into l_tce_rec;
                             Close l_tce_csr;
                             x_new_end_date := OKC_TIME_UTIL_PUB.get_enddate
                                               (
                                                 p_start_date => p_start_date,
                                                 p_duration => l_min_duration,
                                                 p_timeunit => l_tce_rec.uom_code
                                               );
                 End if;
         Elsif Upper(l_min_period) = 'DAY' then
                 If (x_new_end_date - p_start_Date) < l_min_duration  then
                              Open l_tce_csr('DAY',1);
                             Fetch l_tce_csr into l_tce_rec;
                             Close l_tce_csr;
                             x_new_end_date := OKC_TIME_UTIL_PUB.get_enddate
                                               (
                                                 p_start_date => p_start_date,
                                                 p_duration   => l_min_duration,
                                                 p_timeunit   => l_tce_rec.uom_code
                                               );
                 End if;
         Elsif Upper(l_min_period) = 'YEAR' then
                 If  months_between(x_new_end_date,p_start_date) < (l_min_duration * 12) then
                             Open l_tce_csr('YEAR',1);
                             Fetch l_tce_csr into l_tce_rec;
                             Close l_tce_csr;
                             x_new_end_date := OKC_TIME_UTIL_PUB.get_enddate
                                               (
                                                p_start_date => p_start_date,
                                                p_duration => l_min_duration,
                                                p_timeunit => l_tce_rec.uom_code
                                                );
                 End if;
          End if;

          OKC_TIME_UTIL_PUB.get_duration (
                                          p_start_date    => p_start_date,
                                          p_end_date      => x_new_end_date,
                                          x_duration      => x_service_duration,
                                          x_timeunit      => x_service_period,
                                          x_return_status => l_return_status
                                          );


          If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                  Raise G_EXCEPTION_HALT_VALIDATION;
          End If;

     End if;

Exception

      When  G_EXCEPTION_HALT_VALIDATION Then
            x_return_status := l_return_status;
      When  Others Then
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END;


Procedure Is_service_available
(
 P_Api_Version        IN  Number,
 P_init_msg_list      IN  Varchar2 Default OKC_API.G_FALSE,
 X_msg_Count            OUT  NOCOPY  Number,
 X_msg_Data             OUT  NOCOPY  Varchar2,
 X_Return_Status          OUT  NOCOPY  Varchar2,
 p_check_service_rec  IN  CHECK_SERVICE_REC_TYPE,
 X_Available_YN      OUT  NOCOPY  Varchar2,
 --NPALEPU added on 29-sep-2005 for bug # 4608694
 P_ORG_ID          IN  NUMBER   Default NULL
 --END NPALEPU
 )
 Is
 l_api_name        CONSTANT VARCHAR2(30) := 'GET_DURATION';
 l_api_version     CONSTANT NUMBER       := 11.5;
 l_row_count       NUMBER;
 l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

--Local
 l_first  Boolean := TRUE;
 l_pstat  Boolean;
 l_cstat  Boolean;

 Cursor l_service_csr (Obj_type Varchar2) Is
        Select   Id
                ,General_YN
                ,Except_Object_Type
                ,Start_Date_Active
                ,End_Date_Active
        From     OKS_SERV_AVAILS_V
        Where    object1_id1 = p_check_service_rec.service_item_id
        And      Except_Object_type = Nvl(obj_type,Except_Object_type)
        Order By Except_Object_type;

 Cursor l_party_csr (l_custid Number) Is
        Select Party_Id From OKX_CUSTOMER_ACCOUNTS_V
        Where  Id1 = l_custid;

 Cursor l_cp_status_csr Is
        Select distinct SERVICE_ORDER_ALLOWED_FLAG
        From   CS_CUSTOMER_PRODUCT_STATUSES
        Where  customer_product_status_id In
        (
           select customer_product_status_id From okx_customer_products_v
           where  id1 = p_check_service_rec.customer_product_id
        );
/****  Added cursor to check servicable flag for product ***/

--npalepu 29-sep-2005 added for bug # 4608694
/* Cursor l_servicable_prod_csr (p_item_id Number) Is
       Select serviceable_product_flag
       FROM mtl_system_items_b
       WHERE inventory_item_id = p_item_id
       AND rownum < 2;  */

  Cursor l_servicable_prod_csr (p_item_id Number, l_organization_id Number) Is
       Select serviceable_product_flag
       From OKX_SYSTEM_ITEMS_V
       Where id1 = p_item_id
       And   id2 = l_organization_id;
--end npalepu

/* start fixes 4605912
Cursor l_servicable_prod_csr (p_item_id Number, l_organization_id Number) Is
       Select serviceable_product_flag
       From OKX_SYSTEM_ITEMS_V
       Where id1 = p_item_id
       And   id2 = l_organization_id;
end fixes 4605912 */



/**** End of cursor  04/30/2001 ***/

--- Added cursor to get inventory item id when customer product id is passed but
-- inventory item id is not passed by user for Bug # 2252026
Cursor l_product_item_id_csr(cust_prdId NUMBER) IS
    select INVENTORY_ITEM_ID
    from cs_customer_products_all
    where CUSTOMER_PRODUCT_ID = cust_prdId;

/* This cursor added to check whether the item is model */

/*Cursor l_model_item_csr (p_inv_item_id NUMBER) IS
    select 'Y'
    from mtl_system_items
    where inventory_item_id = p_inv_item_id
    and ((bom_item_type = 1) OR
    (bom_item_type = 4 AND
    (pick_components_flag = 'Y' OR replenish_to_order_flag = 'Y')));
*/

 l_party_id    Number;
 l_service_rec l_service_csr%ROWTYPE;
 End_Exc       Exception;
 l_servicable_flag_yn      Varchar2(1);
 l_cp_status   Varchar2(3);
 l_organization_id Number;
 l_product_item_id NUMBER := p_check_service_rec.product_item_id;
 l_model_flag  Varchar2(1) := 'N';

 --NPALEPU 29-sep-2005 for bug # 4608694
 l_original_org_id       NUMBER;
 l_original_access_mode  Varchar2(1);
 --npalepu added on 23-dec-2005 for bug # 4897884
 l_org_id               NUMBER;
 l_default_org_id        hr_operating_units.organization_id%TYPE;
 l_default_ou_name       hr_operating_units.name%TYPE;
 l_ou_count              NUMBER;
 --end 4897884
 --END NPALEPU

 Procedure Product (Pid IN Number, Stat OUT NOCOPY  Boolean)
 Is
 Cursor l_product_csr (p_mast_id Number, p_prod_id Number) Is
        Select  Object1_Id1,
                Start_Date_Active,
                End_Date_Active
        From    OKS_SERV_AVAIL_EXCEPTS_V
        Where   SAV_Id = p_mast_id And
                Object1_Id1 = p_prod_id;


 l_product_rec  l_product_csr%ROWTYPE;


 BEGIN

      Open  l_service_csr ('P');
      Fetch l_service_csr Into l_service_rec;
      If l_service_csr%NOTFOUND Then
           -- Close l_service_csr;
            Stat := TRUE;
            Raise End_Exc;
      Else
            If l_service_rec.general_yn = 'Y' Then
                    If TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
                                 Between TRUNC(NVL(l_service_rec.Start_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                   And TRUNC(NVL(l_service_rec.End_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                     Then
                           For l_product_rec In l_product_csr(l_service_rec.Id, Pid)
                           Loop
                              If  TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
                                  Between TRUNC(NVL(l_product_rec.Start_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                    And TRUNC(NVL(l_product_rec.End_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                              Then

                                         Stat := FALSE;
                                         Raise End_Exc;
                               End If;
                           End Loop;
                           Stat := TRUE;
                           Raise End_Exc;
                    Else
                           Stat := FALSE;
                           Raise End_Exc;
                    End If;  -- If TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
            Else      -- If l_service_rec.general_yn = 'Y' Then
                    If  TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
                                Between TRUNC(NVL(l_service_rec.Start_Date_Active,  NVL(p_check_service_rec.request_date ,sysdate)))
                                    And TRUNC(NVL(l_service_rec.End_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                    Then
                           For l_product_rec In l_product_csr(l_service_rec.Id, Pid)
                           Loop
                               If TRUNC(NVL(p_check_service_rec.request_date,sysdate))
                                  Between TRUNC(NVL(l_product_rec.Start_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                      And TRUNC(NVL(l_product_rec.End_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                Then
                                         Stat := TRUE;
                                         Raise End_Exc;
                               End If;
                           End Loop;
                           Stat := FALSE;
                           Raise End_Exc;
                    Else
                           Stat := TRUE;
                           Raise End_Exc;
                    End If;

            End If; -- If l_service_rec.general_yn = 'Y' Then

      End If; -- If l_service_csr%NOTFOUND Then
      Close l_service_csr;

Exception

        When End_Exc Then
              Close l_service_csr;
              Null;
        When Others Then
              Stat := False;

END;


Procedure Customer (p_Cid Number, Stat OUT NOCOPY  Boolean)
Is
Cursor l_customer_csr (p_mast_id Number, p_cust_id Number) Is
          Select Object1_Id1,
                 Start_Date_Active,
                 End_Date_Active
          From   OKS_SERV_AVAIL_EXCEPTS_V
          Where  SAV_Id = p_mast_id
          And    Object1_Id1 = p_cust_id;

BEGIN
      Open  l_service_csr ('C');
      Fetch l_service_csr Into l_service_rec;
      If l_service_csr%NOTFOUND Then
     --       Close l_service_csr;
            Stat := TRUE;
            Raise End_Exc;
      Else
            If l_service_rec.general_yn = 'Y' Then
               If  TRUNC(NVL(p_check_service_rec.request_date ,sysdate) )
                                 Between TRUNC(NVL(l_service_rec.Start_Date_Active,  NVL(p_check_service_rec.request_date ,sysdate)))
                                 And     TRUNC(NVL(l_service_rec.End_Date_Active,  NVL(p_check_service_rec.request_date ,sysdate)))
                Then
                        For l_customer_rec In l_customer_csr(l_service_rec.Id, p_Cid)
                        Loop
                            If  TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
                                 Between TRUNC(NVL(l_customer_rec.Start_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                 And TRUNC(NVL(l_customer_rec.End_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                             Then
                                       Stat := FALSE;
                                       Raise End_Exc;
                            End If;
                        End Loop;
                        Stat := TRUE;
                        Raise End_Exc;
                Else
                        Stat := FALSE;
                        Raise End_Exc;
                End If;
            Else
                     If  TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
                                 Between TRUNC(NVL(l_service_rec.Start_Date_Active,  NVL(p_check_service_rec.request_date ,sysdate)))
                                     And TRUNC(NVL(l_service_rec.End_Date_Active,  NVL(p_check_service_rec.request_date ,sysdate)))
                     Then
                          For l_customer_rec In l_customer_csr(l_service_rec.Id, p_cid)
                          Loop
                            If  TRUNC(NVL(p_check_service_rec.request_date ,sysdate))
                                Between TRUNC(NVL(l_customer_rec.Start_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                    And TRUNC(NVL(l_customer_rec.End_Date_Active, NVL(p_check_service_rec.request_date ,sysdate)))
                                   Then
                                           Stat := TRUE;
                                           Raise End_Exc;
                             End If;
                           End Loop;
                              Stat := FALSE;
                              Raise End_Exc;
                     Else
                              Stat := TRUE;
                              Raise End_Exc;
                     End If;

            End If;
      End If;
      Close l_service_csr;


Exception

         When End_Exc Then
              Close l_service_csr;
              Null;
         When Others Then
              Stat := False;

END;


BEGIN
    If (l_product_item_id is null
                    AND p_check_service_rec.customer_product_id is not null) Then
                Open l_product_item_id_csr(p_check_service_rec.customer_product_id);
                Fetch l_product_item_id_csr into l_product_item_id;
                Close l_product_item_id_csr;
     End If;
/* start fixes 4605912
  --set org_id if it is null
   if okc_context.get_okc_org_id IS NULL
   then
     okc_context.set_okc_org_context;
   end if;

     l_organization_id := okc_context.get_okc_organization_id;
end fixes 4605912*/

--NPALEPU 21-sep-2005 for bug # 4608694

   --capturing the original context
    l_original_org_id       := mo_global.get_current_org_id;
    l_original_access_mode  := mo_global.get_access_mode();

    IF p_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>P_ORG_ID);    */
        l_org_id := p_org_id;
        --end 4897884
    ELSIF l_original_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>l_original_org_id);    */
        l_org_id := l_original_org_id;
        --end 4897884
    ELSE
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context; */
        mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
        l_org_id := l_default_org_id;
        --end 4897884
    END IF;
  --END NPALEPU

    --npalepu added on 23-dec-2005 for bug # 4897884
    IF l_org_id IS NOT NULL AND l_org_id <> -99 THEN
        l_organization_id := OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_org_id);
    END IF;
    --end 4897884

     If p_check_service_rec.Service_Item_id Is Null
     Or (p_check_service_rec.Customer_id Is Null and l_product_item_id Is Null) Then
            l_return_status := OKC_API.G_RET_STS_ERROR;
            x_available_yn := 'N';
            OKC_API.set_message(G_APP_NAME, 'OKS_MISSING_REQUIRED_PARAMETERS');
            Raise  G_EXCEPTION_HALT_VALIDATION;
     End If;
/****** Added to check whether Item is servicable or not ****/

If l_product_item_id Is Not Null Then

   /* Open  l_model_item_csr (l_product_item_id);
    Fetch l_model_item_csr Into l_model_flag;
    Close l_model_item_csr;

    If l_model_flag = 'Y' then
       l_return_status  := OKC_API.G_RET_STS_SUCCESS;
       x_available_yn := 'Y';
       Raise G_EXCEPTION_HALT_VALIDATION;
    End If;
  */
/* start fixes 4605912
    Open l_servicable_prod_csr(l_product_item_id,l_organization_id);
end fixes 4605912*/
--NPALEPU 29-sep-2005 for bug # 4608694
 /*   Open l_servicable_prod_csr(l_product_item_id); */
    Open l_servicable_prod_csr(l_product_item_id,l_organization_id);
--end npalepu
    Fetch l_servicable_prod_csr Into l_servicable_flag_yn;
    Close l_servicable_prod_csr;

    IF NVL(l_servicable_flag_yn,'N') = 'N' THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            x_available_yn := 'N';
            OKC_API.set_message(G_APP_NAME, 'OKS_PRODUCT_NOT_SERVICABLE');
            Raise  G_EXCEPTION_HALT_VALIDATION;
     END IF;
End If;

/*** End of check ***/

     Open  l_service_csr (Null);
     Fetch l_service_csr Into l_service_rec;

     If l_service_csr%NOTFOUND Then

            If p_check_service_rec.customer_product_id Is Not Null Then
                l_cp_status := Null;

                Open l_cp_status_csr;
                Fetch l_cp_status_csr Into l_cp_status;
                Close l_cp_status_csr;

                If Nvl(l_cp_status,'Y') = 'N' Then
                    x_available_yn := 'N';
                End If;
            End If;

            x_available_yn := 'Y';
            Close l_service_csr;
            Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

     Close l_service_csr;

     l_cstat := TRUE;
     l_pstat := TRUE;

     If p_check_service_rec.customer_id Is Not Null Then

        l_party_id := Null;
        Open l_party_csr (p_check_service_rec.customer_id);
        Fetch l_party_csr Into l_party_id;
        Close l_party_csr;

        If l_party_id IS Null Then
           l_return_status := 'E';
           x_available_yn := 'N';
           OKC_API.set_message(G_APP_NAME,'OKS_PARTY_ID_NOT_FOUND','CUSTOMER_ID',to_char(p_check_service_rec.customer_id));
           Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

        Customer(l_party_id, l_cstat);

     End If;

     If l_cstat Then
            If l_product_item_id Is Not Null Then
                        Product (l_product_item_id, l_pstat);
            End If;
     End If;

     If l_cstat And l_pstat Then
            x_available_yn := 'Y';
     Else
            x_available_yn := 'N';
     End If;

     If p_check_service_rec.customer_product_id Is Not Null Then

        l_cp_status := Null;

        Open l_cp_status_csr;
        Fetch l_cp_status_csr Into l_cp_status;
        Close l_cp_status_csr;

        If Nvl(l_cp_status,'Y') = 'N' Then
           x_available_yn := 'N';
        End If;

     End If;

     x_return_status := l_return_status;

    --npalepu 23-dec-2005 removed the code for bug # 4897884
  /*   --NPALEPU 29-sep-2005 for bug # 4608694
     --Resetting to original context
      mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
    --END NPALEPU */
    --end 4897884

Exception

       When  G_EXCEPTION_HALT_VALIDATION Then

               x_return_status := l_return_status;
               Null;
               --npalepu 23-dec-2005 removed the code for bug # 4897884
               /* --NPALEPU 29-sep-2005 for bug # 4608694
               --Resetting to original context
               mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
               --END NPALEPU */
               --end 4897884
       When  Others Then
               x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
               OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
               --npalepu 23-dec-2005 removed the code for bug # 4897884
               /* --NPALEPU 29-sep-2005 for bug # 4608694
               --Resetting th eoriginal context
               mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
               --END NPALEPU */
               --end 4897884

END;


Procedure Available_Services
(
P_Api_Version    IN  Number,
P_init_msg_list  IN  Varchar2 Default OKC_API.G_FALSE,
X_msg_Count     OUT  NOCOPY  Number,
X_msg_Data      OUT NOCOPY   Varchar2,
X_Return_Status OUT  NOCOPY  Varchar2,
p_avail_service_rec IN AVAIL_SERVICE_REC_TYPE,
X_Orderable_Service_tbl OUT  NOCOPY  order_service_tbl_type,
--NPALEPU added on 21-sep-2005 for bug # 4608694
P_ORG_ID         IN  NUMBER   Default NULL
--END NPALEPU
)
Is

-- Added two more condition for bug # 2721044
--- Could not replace the view because we need the TL table for order by
--npalepu modified on 23-dec-2005 for bug # 4897884
/* Cursor l_srv_csr Is     */
Cursor l_srv_csr(v_organization_id IN NUMBER) Is
--end 4897884
     Select INVENTORY_ITEM_ID id1
      From MTL_SYSTEM_ITEMS_B_KFV
      Where VENDOR_WARRANTY_FLAG = 'N'
      And   SERVICE_ITEM_FLAG    = 'Y'
      AND   CUSTOMER_ORDER_ENABLED_FLAG = 'Y'
      AND   DECODE(ENABLED_FLAG,'Y','A','I')  = 'A'
      --npalepu modified on 23-dec-2005 for bug # 4897884
      /* And   ORGANIZATION_ID = okc_context.get_okc_organization_id */
      And   ORGANIZATION_ID = v_organization_id
      --end 4897884
     order by CONCATENATED_SEGMENTS;



Cursor l_party_csr (l_custid Number) Is
        Select Party_Id From OKX_CUSTOMER_ACCOUNTS_V
        Where  Id1 = l_custid;


l_party_id    Number;


l_api_name      CONSTANT VARCHAR2(30) := 'GET_DURATION';
l_api_version   CONSTANT NUMBER     := 11.5;
l_row_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_ptr           Binary_Integer := 0 ;
l_avail         Varchar2(1);
l_isrec         Check_service_rec_type;
l_Srv_tbl       order_service_tbl_type;
l_found         BOOLEAN;

--NPALEPU 21-sep-2005 for bug # 4608694
l_original_org_id       NUMBER;
l_original_access_mode  Varchar2(1);
--npalepu added on 23-dec-2005 for bug # 4897884
l_org_id                NUMBER;
l_default_org_id        hr_operating_units.organization_id%TYPE;
l_default_ou_name       hr_operating_units.name%TYPE;
l_ou_count              NUMBER;
l_organization_id       NUMBER;
--end 4897884
--END NPALEPU

BEGIN

 --NPALEPU 21-sep-2005 for bug # 4608694

  /* --set org_id if it is null
    if okc_context.get_okc_org_id IS NULL then
        okc_context.set_okc_org_context;
    end if; */

   --capturing the original context
    l_original_org_id       := mo_global.get_current_org_id;
    l_original_access_mode  := mo_global.get_access_mode();

    IF p_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>P_ORG_ID);    */
        l_org_id := p_org_id;
        --end 4897884
    ELSIF l_original_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>l_original_org_id);    */
        l_org_id := l_original_org_id;
        --end 4897884
    ELSE
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context; */
        mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
        l_org_id := l_default_org_id;
        --end 4897884
    END IF;
  --END NPALEPU

    --npalepu added on 23-dec-2005 for bug # 4897884
    IF l_org_id IS NOT NULL AND l_org_id <> -99 THEN
        l_organization_id := OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_org_id);
    END IF;
    --end 4897884

      l_party_id := Null;

        If p_avail_service_rec.customer_id Is Not Null Then

     Open l_party_csr (p_avail_service_rec.customer_id);
     Fetch l_party_csr Into l_party_id;
     Close l_party_csr;

     If l_party_id IS Null Then
           l_return_status := 'E';
           OKC_API.set_message(G_APP_NAME,'OKS_PARTY_ID_NOT_FOUND','CUSTOMER_ID',to_char(p_avail_service_rec.customer_id));
           Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

        End If;

      --npalepu modified on 23-dec-2005 for bug # 4897884
      /* For l_srv_rec In l_srv_csr */
      For l_srv_rec In l_srv_csr(l_organization_id)
      --end 4897884
      Loop

          l_avail := 'N';

          l_isrec.service_item_id := l_srv_rec.id1;
          l_isrec.product_item_id := p_avail_service_rec.product_item_id;
          l_isrec.customer_id     := p_avail_service_rec.customer_id;
          l_isrec.request_date    := p_avail_service_rec.request_date;


          --npalepu modified on 20-nov-2005
          /* Is_Service_Available
           (
            1.0,
            OKC_API.G_FALSE,
            l_row_count,
            l_msg_Data,
            l_Return_Status,
            l_isrec,
            l_Avail
           );  */
          Is_Service_Available
           (
            P_Api_Version       => 1.0,
            P_init_msg_list     => OKC_API.G_FALSE,
            X_msg_Count         => l_row_count,
            X_msg_Data          => l_msg_Data,
            X_Return_Status     => l_Return_Status,
            p_check_service_rec => l_isrec,
            X_Available_YN      => l_Avail
           );
          --end npalepu

          If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              Raise G_EXCEPTION_HALT_VALIDATION;
          End If;


          If l_Avail = 'Y' Then
              l_ptr := l_ptr + 1;
              X_Orderable_Service_tbl(l_ptr).Service_Item_id := l_srv_rec.id1;
          End If;

      End Loop;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      --npalepu removed the following code for bug # 4897884
      /* --NPALEPU 21-sep-2005 for bug # 4608694
      --Resetting to original context
      mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
      --END NPALEPU */
      --end 4897884


Exception
       When  G_EXCEPTION_HALT_VALIDATION Then
             x_return_status := l_return_status;
             Null;
             --npalepu removed the following code for bug # 4897884
             /* --NPALEPU 21-sep-2005 for bug # 4608694
             --Resetting to original context
             mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
             --END NPALEPU */
             --end 4897884
       When  Others Then
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
             --npalepu removed the following code for bug # 4897884
             /* --NPALEPU 21-sep-2005 for bug # 4608694
             --Resetting to original context
             mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
             --END NPALEPU */
             --end 4897884

END;

Procedure OKS_Available_Services
(
P_Api_Version    IN  Number,
P_init_msg_list  IN  Varchar2 Default OKC_API.G_FALSE,
X_msg_Count     OUT  NOCOPY  Number,
X_msg_Data      OUT  NOCOPY  Varchar2,
X_Return_Status OUT  NOCOPY  Varchar2,
p_avail_service_rec IN AVAIL_SERVICE_REC_TYPE,
--ADDED FOR OKS REQ
X_Orderable_Service_tbl OUT  NOCOPY  OKS_order_service_tbl_type,
--NPALEPU added on 21-sep-2005 for bug # 4608694
P_ORG_ID         IN  NUMBER   Default NULL
--END NPALEPU
)
Is


--npalepu modified on 23-dec-2005 for bug # 4897884
/* Cursor l_srv_csr Is */
Cursor l_srv_csr(v_organization_id IN NUMBER) Is
--end 4897884
   --ADDED FOR OKS REQ
       Select    B.INVENTORY_ITEM_ID Id1,
                 T.DESCRIPTION Name,
                 B.CONCATENATED_SEGMENTS Description,
                 B.COVERAGE_SCHEDULE_ID COVERAGE_TEMPLATE_ID
       From      MTL_SYSTEM_ITEMS_B_KFV B,MTL_SYSTEM_ITEMS_TL T  --OKX_SYSTEM_ITEMS_V
       Where     B.SERVICE_ITEM_FLAG='Y'
       And       B.VENDOR_WARRANTY_FLAG = 'N'
       And B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID
       AND B.ORGANIZATION_ID = T.ORGANIZATION_ID
       AND T.LANGUAGE = userenv('LANG')
       --npalepu modified on 23-dec-2005 for bug # 4897884
       /*          And    B.ORGANIZATION_ID = okc_context.get_okc_organization_id; */
       AND B.ORGANIZATION_ID = v_organization_id;
       --end 4897884

Cursor l_party_csr (l_custid Number) Is
        Select Party_Id From HZ_CUST_ACCOUNTS -- OKX_CUSTOMER_ACCOUNTS_V
        Where  CUST_ACCOUNT_ID = l_custid;


l_party_id    Number;


l_api_name      CONSTANT VARCHAR2(30) := 'GET_DURATION';
l_api_version   CONSTANT NUMBER     := 11.5;
l_row_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_ptr           Binary_Integer := 0 ;
l_avail         Varchar2(1);
l_isrec         Check_service_rec_type;
l_Srv_tbl       order_service_tbl_type;
l_found         BOOLEAN;

--NPALEPU 21-sep-2005 for bug # 4608694
l_original_org_id       NUMBER;
l_original_access_mode  Varchar2(1);
--npalepu added on 23-dec-2005 for bug # 4897884
l_org_id                NUMBER;
l_default_org_id        hr_operating_units.organization_id%TYPE;
l_default_ou_name       hr_operating_units.name%TYPE;
l_ou_count              NUMBER;
l_organization_id       NUMBER;
--end 4897884
--END NPALEPU

BEGIN

    /* l_party_id := Null;

        If p_avail_service_rec.customer_id Is Not Null Then

     Open l_party_csr (p_avail_service_rec.customer_id);
     Fetch l_party_csr Into l_party_id;
     Close l_party_csr;

     If l_party_id IS Null Then
           l_return_status := 'E';
           OKC_API.set_message(G_APP_NAME,'OKS_PARTY_ID_NOT_FOUND','CUSTOMER_ID',to_char(p_check_service_rec.customer_id));
           Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

        End If;
   */

 --NPALEPU 21-sep-2005 for bug # 4608694

  /* --set org_id if it is null
    if okc_context.get_okc_org_id IS NULL then
        okc_context.set_okc_org_context;
    end if; */

   --capturing the original context
    l_original_org_id       := mo_global.get_current_org_id;
    l_original_access_mode  := mo_global.get_access_mode();

    IF p_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>P_ORG_ID);    */
        l_org_id := p_org_id;
        --end 4897884
    ELSIF l_original_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>l_original_org_id);    */
        l_org_id := l_original_org_id;
        --end 4897884
    ELSE
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context; */
        mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
        l_org_id := l_default_org_id;
        --end 4897884
    END IF;
  --END NPALEPU

    --npalepu added on 23-dec-2005 for bug # 4897884
    IF l_org_id IS NOT NULL AND l_org_id <> -99 THEN
        l_organization_id := OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_org_id);
    END IF;
    --end 4897884

      --npalepu modified on 23-dec-2005 for bug # 4897884
      /* For l_srv_rec In l_srv_csr */
      For l_srv_rec In l_srv_csr(l_organization_id)
      --end 4897884
      Loop

          l_avail := 'N';

          l_isrec.service_item_id := l_srv_rec.id1;
          l_isrec.product_item_id := p_avail_service_rec.product_item_id;
          l_isrec.customer_id     := p_avail_service_rec.customer_id;
          l_isrec.request_date    := p_avail_service_rec.request_date;


          --npalepu modified on 20-nov-2005
          /* Is_Service_Available
           (
            1.0,
            OKC_API.G_FALSE,
            l_row_count,
            l_msg_Data,
            l_Return_Status,
            l_isrec,
            l_Avail
           );  */
          Is_Service_Available
           (
            P_Api_Version       => 1.0,
            P_init_msg_list     => OKC_API.G_FALSE,
            X_msg_Count         => l_row_count,
            X_msg_Data          => l_msg_Data,
            X_Return_Status     => l_Return_Status,
            p_check_service_rec => l_isrec,
            X_Available_YN      => l_Avail
           );
          --end npalepu

          If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              Raise G_EXCEPTION_HALT_VALIDATION;
          End If;


          If l_Avail = 'Y' Then
              l_ptr := l_ptr + 1;
              X_Orderable_Service_tbl(l_ptr).Service_Item_id := l_srv_rec.id1;
--ADDED FOR OKS REQ
              X_Orderable_Service_tbl(l_ptr).Name            := l_srv_rec.Name;
              X_Orderable_Service_tbl(l_ptr).Description     := l_srv_rec.Description;
              X_Orderable_Service_tbl(l_ptr).Coverage_template_id := l_srv_rec.Coverage_template_id;
          End If;

      End Loop;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      --npalepu removed the following code for bug # 4897884
     /* --NPALEPU 21-sep-2005 for bug # 4608694
      --Resetting to original context
      mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
      --END NPALEPU */
      --end 4897884

Exception
       When  G_EXCEPTION_HALT_VALIDATION Then
             x_return_status := l_return_status;
             Null;
             --npalepu removed the following code for bug # 4897884
             /* --NPALEPU 21-sep-2005 for bug # 4608694
             --Resetting to original context
             mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
             --END NPALEPU */
             --end 4897884

       When  Others Then
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
           --npalepu removed the following code for bug # 4897884
           /* --NPALEPU 21-sep-2005 for bug # 4608694
           --Resetting to original context
           mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
           --END NPALEPU */
           --end 4897884
END;


Procedure Is_service_available
                    (p_api_version      IN Number
                    ,p_party_id         IN Number
                    ,p_service_id       IN Number
                    ,p_request_date     IN Date Default sysdate
                    ,p_init_msg_list    IN Varchar2 Default OKC_API.G_FALSE
                    ,x_available_yn     OUT  NOCOPY Varchar2
                    ,x_msg_Count        OUT  NOCOPY Number
                    ,x_msg_Data         OUT  NOCOPY Varchar2
                    ,x_return_status    OUT NOCOPY  Varchar2)
Is

 End_Exc       Exception;
 l_api_name        CONSTANT VARCHAR2(30) := 'GET_DURATION';
 l_api_version     CONSTANT NUMBER       := 11.5;

 Cursor l_service_csr (Obj_type Varchar2) Is
        Select   Id
                ,General_YN
                ,Except_Object_Type
                ,Start_Date_Active
                ,End_Date_Active
        From     OKS_SERV_AVAILS_V
        Where    object1_id1 = p_service_id
        And      Except_Object_type = Nvl(obj_type,Except_Object_type)
        Order By Except_Object_type;

l_service_rec         l_service_csr%ROWTYPE;

Cursor l_customer_csr (p_mast_id Number, p_party_id Number) Is
          Select Object1_Id1,
                 Start_Date_Active,
                 End_Date_Active
          From   OKS_SERV_AVAIL_EXCEPTS_V
          Where  SAV_Id = p_mast_id
          And    Object1_Id1 = p_party_id;


BEGIN
       -- initialize return status
   x_return_status := OKC_API.G_RET_STS_SUCCESS;
     If p_Service_id Is Null Or p_party_id Is Null  Then
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message(G_APP_NAME, 'OKS_MISSING_REQUIRED_PARAMETERS');
            Raise  G_EXCEPTION_HALT_VALIDATION;
     End If;

      Open  l_service_csr ('C');
      Fetch l_service_csr Into l_service_rec;
      If l_service_csr%NOTFOUND Then
          --  Close l_service_csr;
            x_available_yn := 'Y';
            --Stat := TRUE;
            Raise End_Exc;
      Else
            If l_service_rec.general_yn = 'Y' Then
               If  TRUNC(NVL(p_request_date ,sysdate))
                       Between TRUNC(NVL(l_service_rec.Start_Date_Active,  NVL(p_request_date ,sysdate)))
                        And     TRUNC(NVL(l_service_rec.End_Date_Active,  NVL(p_request_date ,sysdate)))
                Then
                        For l_customer_rec In l_customer_csr(l_service_rec.Id, p_party_id)
                        Loop
                        If  TRUNC(NVL(p_request_date ,sysdate))
                         Between TRUNC(NVL(l_customer_rec.Start_Date_Active, NVL(p_request_date ,sysdate)))
                            And TRUNC(NVL(l_customer_rec.End_Date_Active, NVL(p_request_date ,sysdate)))
                             Then
                                      -- Stat := FALSE;
                                       x_available_yn := 'N';
                                       Raise End_Exc;
                            End If;
                        End Loop; -- For l_customer_rec In l_customer_csr(l_service_rec.Id, p_party_id)

                        --Stat := TRUE;
                        x_available_yn := 'Y';
                        Raise End_Exc;
                Else
                       -- Stat := FALSE;
                          x_available_yn := 'N';
                        Raise End_Exc;
                End If;
            Else
                     If  TRUNC(NVL(p_request_date ,sysdate))
                         Between TRUNC(NVL(l_service_rec.Start_Date_Active,  NVL(p_request_date ,sysdate)))
                            And TRUNC(NVL(l_service_rec.End_Date_Active,  NVL(p_request_date ,sysdate)))
                     Then
                          For l_customer_rec In l_customer_csr(l_service_rec.Id, p_party_id)
                          Loop
                          If  TRUNC(NVL(p_request_date ,sysdate))
                          Between TRUNC(NVL(l_customer_rec.Start_Date_Active, NVL(p_request_date ,sysdate)))
                             And TRUNC(NVL(l_customer_rec.End_Date_Active, NVL(p_request_date ,sysdate)))
                                   Then
                                          -- Stat := TRUE;
                                           x_available_yn := 'Y';
                                           Raise End_Exc;
                             End If;
                           End Loop;
                              --Stat := FALSE;
                              x_available_yn := 'N';
                              Raise End_Exc;
                     Else
                              --Stat := TRUE;
                              x_available_yn := 'Y';
                              Raise End_Exc;
                     End If;

            End If;
      End If;
      Close l_service_csr;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;


Exception

         When End_Exc Then
              Close l_service_csr;
              Null;
         When  Others Then
           x_available_yn := 'N';
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Is_service_available;


Procedure  Delete_Contract_details
                  ( p_api_version       IN Number
                   ,p_init_msg_list     IN Varchar2 Default OKC_API.G_FALSE
                   ,p_order_line_id     IN Number
                   ,x_msg_Count        OUT NOCOPY  Number
                   ,x_msg_Data         OUT  NOCOPY Varchar2
                   ,x_return_status    OUT  NOCOPY Varchar2)
Is

l_api_name        CONSTANT VARCHAR2(30) := 'GET_DURATION';
l_api_version     CONSTANT NUMBER           := 11.5;
l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count       Number;
l_msg_data        Varchar(2000);
l_line_id         Number := Null;
l_coc_tbl_in      Oks_coc_pvt.cocv_tbl_type;
l_coc_tbl_out     Oks_coc_pvt.cocv_tbl_type;
l_cod_tbl_in      Oks_cod_pvt.codv_tbl_type;
l_cod_tbl_out     Oks_cod_pvt.codv_tbl_type;

Cursor l_k_csr(l_order_line_id Number) Is
       Select Id
       From   Oks_k_order_details
       Where  Order_line_id1 = to_char(l_order_line_id);


Cursor l_kdetails_csr(l_line_id Number) Is
        Select Id
        From   Oks_k_order_details
        Where  Link_ord_line_id1 = to_char(l_line_id);


Cursor l_contact_csr(l_id Number) Is
       Select Id
       From   Oks_k_order_contacts
       Where  Cod_id = l_id;



BEGIN


       x_return_status := l_return_status;

       Open l_k_csr(p_order_line_id);
       Fetch l_k_csr into l_line_id;
       Close l_k_csr;

       If l_line_id is Not Null Then
            For l_rec in l_kdetails_csr(p_Order_line_id)
            Loop

                   For l_contact_rec in l_contact_csr(l_rec.id)
                   Loop


                         l_coc_tbl_in(1).id := l_contact_rec.id;

                         Oks_Order_Contacts_Pub.Delete_Order_Contact
                         (
                                P_api_version   => 1.0
                               ,P_init_msg_list => 'T'
                               ,X_return_status => l_return_status
                               ,X_msg_count     => l_msg_count
                               ,X_msg_data      => l_msg_data
                               ,P_cocv_tbl      => l_coc_tbl_in

                         );

                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                                 Raise G_EXCEPTION_HALT_VALIDATION;
                         End If;
                   End Loop;

                   l_cod_tbl_in(1).Id  :=  l_rec.id;
                   Oks_Order_details_pub.Delete_order_detail
                   (
                       P_api_version   => 1.0
                      ,P_init_msg_list => 'T'
                      ,X_return_status => l_return_status
                      ,X_msg_count     => l_msg_count
                      ,X_msg_data      => l_msg_data
                      ,P_codv_tbl      => l_cod_tbl_in
                   );

                   If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                       Raise G_EXCEPTION_HALT_VALIDATION;
                   End If;
            End Loop;

            For l_contact_rec in l_contact_csr(l_line_id)
            Loop
                 l_coc_tbl_in(1).id := l_contact_rec.id;

                 Oks_Order_Contacts_Pub.Delete_Order_Contact
                (
                 P_api_version   => 1.0
                ,P_init_msg_list => 'T'
                ,X_return_status => l_return_status
                ,X_msg_count     => l_msg_count
                ,X_msg_data      => l_msg_data
                ,P_cocv_tbl      => l_coc_tbl_in

               );

               If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                     Raise G_EXCEPTION_HALT_VALIDATION;
               End If;
            End Loop;

            l_cod_tbl_in(1).Id  :=  l_line_id;
            Oks_Order_details_pub.Delete_order_detail
            (
                       P_api_version   => 1.0
                      ,P_init_msg_list => 'T'
                      ,X_return_status => l_return_status
                      ,X_msg_count     => l_msg_count
                      ,X_msg_data      => l_msg_data
                      ,P_codv_tbl      => l_cod_tbl_in
            );

            If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              Raise G_EXCEPTION_HALT_VALIDATION;
            End If;



       End If;






Exception
    When  G_EXCEPTION_HALT_VALIDATION Then
            x_return_status := l_return_status;
      When  Others Then
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Delete_Contract_details;



 Procedure  GET_SVC_SDATE
(
 P_api_version       IN  Number,
 P_init_msg_list     IN  Varchar2,
 P_order_line_id     IN  Number,   -- (Service Order line Id)
 X_msg_count         OUT  NOCOPY Number,
 X_msg_data          OUT  NOCOPY Varchar2,
 X_return_status     OUT  NOCOPY Varchar2,
 X_start_date        OUT  NOCOPY Date,
  X_end_date         OUT  NOCOPY Date
 )
 Is

 Cursor l_Oline_csr Is
       Select service_reference_type_code
              ,service_reference_line_id
              ,service_duration
              ,service_period
              ,fulfillment_date
       From   oe_order_lines_all
       Where  line_id = p_order_line_id;

 Cursor l_get_warr_dates_csr(p_cp_id Number) IS
       Select max(ol.end_date)
       From okc_k_items ot, okc_k_lines_b ol
       Where ot.object1_id1 = to_char(p_cp_id) -- Bug Fix #5011519
       And   ol.id     = ot.cle_id
       And   ol.lse_id = 18   ;

Cursor l_cp_csr(p_line_id Number) Is
       Select  csi.instance_id
              ,csi.install_date
              ,ol.Actual_shipment_date
              ,ol.schedule_ship_date
       From    csi_item_instances csi
              ,oe_order_lines_all ol
       Where   ol.line_id = csi.last_oe_order_line_id
       And     ol.inventory_item_id = csi.inventory_item_id
       And     ol.line_id = p_line_id;

Cursor l_product_csr(p_cp_id Number) Is
       Select csi.install_date
       From   csi_item_instances csi
       Where  csi.instance_id = p_cp_id;


 l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_cp_rec            l_cp_csr%rowtype;
 l_line_rec          l_oline_csr%rowtype;
 l_install_date      Date;
 l_ship_date         Date;
 l_warend_date       Date;



 Begin

         l_line_rec := Null;
         l_cp_rec   := Null;

         l_return_status   := OKC_API.G_RET_STS_SUCCESS;
         x_return_status := l_return_status;
         Open l_oline_csr;
         Fetch l_oline_csr into l_line_rec;
         Close l_oline_csr;

         If l_line_rec.Service_reference_type_code = 'ORDER' Then
                 Open l_cp_csr(l_line_rec.service_reference_line_id);
                 Fetch l_cp_csr into l_cp_rec;
                 Close l_cp_csr;

                 If l_cp_rec.instance_id Is Null Then
                     l_return_status := 'E';
                     OKC_API.set_message(G_APP_NAME,'OKS_NULL_SDT','LINE_ID',p_order_line_id);
                     Raise G_EXCEPTION_HALT_VALIDATION;
                 End If;
                 l_warend_date := Null;
                 Open l_get_warr_dates_csr(l_cp_rec.instance_id);
                 fetch l_get_warr_dates_csr into l_warend_date;
                 Close l_get_warr_dates_csr;

                 If l_warend_date is Not null Then
                       X_start_date := trunc(l_warend_date) + 1;

                 Else
                        l_ship_date := nvl(l_cp_rec.actual_shipment_date,l_cp_rec.schedule_ship_date);
                        X_start_date := Trunc(Nvl(l_cp_rec.install_date, l_ship_date));
                 End If;


           ElsIf l_line_rec.Service_reference_type_code = 'CUSTOMER_PRODUCT' Then
                 l_warend_date := Null;
                 Open l_get_warr_dates_csr(l_line_rec.service_reference_line_id);
                 Fetch l_get_warr_dates_csr into l_warend_date;
                 Close l_get_warr_dates_csr;

                 If l_warend_date is Not null Then
                      X_start_date := trunc(l_warend_date) + 1;

                 Else
                        Open l_product_csr(l_line_rec.service_reference_line_id);
                        Fetch l_product_csr into l_install_date;
                        Close l_product_csr;


                        X_start_date := Trunc(NVL(l_install_date,l_line_rec.fulfillment_date));
                 End If;

            End If;
            If X_start_date Is Null Then
                     l_return_status := 'E';
                     OKC_API.set_message(G_APP_NAME,'OKS_NULL_SDT','LINE_ID',p_order_line_id);
                     Raise G_EXCEPTION_HALT_VALIDATION;
            End If;
            X_end_date   :=  okc_time_util_pub.get_enddate
                                                   ( X_Start_Date
                                                    ,l_line_rec.service_period
                                                    ,l_line_rec.service_duration
                                                    );

           x_return_status := l_return_status;

 Exception
    When  G_EXCEPTION_HALT_VALIDATION Then
            x_return_status := l_return_status;
      When  Others Then
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);



 End;

  -- Added for ASO Queue Replacement

 PROCEDURE Interface_Service_Order_Lines
   (p_Service_Order_Lines   IN   Service_Order_Lines_TblType
   ,x_Return_Status         OUT  NOCOPY  VARCHAR2
   ,x_Error_Message         OUT  NOCOPY  VARCHAR2)
 IS

   TYPE Num_TblType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   l_Order_Header_ID_Tbl     Num_TblType;
   l_Order_Line_ID_Tbl       Num_TblType;
   l_Order_Number_Tbl        Num_TblType;

   l_Tbl_Idx                 NUMBER;
   l_SrvOrdLine_Idx          NUMBER;
   l_SrvOrdLine_Idx_FIRST    NUMBER;
   l_SrvOrdLine_Idx_LAST     NUMBER;

 BEGIN

   l_Tbl_Idx               := 0;
   l_SrvOrdLine_Idx        := p_Service_Order_Lines.FIRST;

   WHILE l_SrvOrdLine_Idx IS NOT NULL LOOP

     l_Tbl_Idx                        := l_Tbl_Idx + 1;

     l_Order_Header_ID_Tbl(l_Tbl_Idx) := p_Service_Order_Lines(l_SrvOrdLine_Idx).Order_Header_ID;
     l_Order_Line_ID_Tbl(l_Tbl_Idx)   := p_Service_Order_Lines(l_SrvOrdLine_Idx).Order_Line_ID;
     l_Order_Number_Tbl(l_Tbl_Idx)    := p_Service_Order_Lines(l_SrvOrdLine_Idx).Order_Number;

     l_SrvOrdLine_Idx                 := p_Service_Order_Lines.NEXT(l_SrvOrdLine_Idx);

   END LOOP;

   --

   l_SrvOrdLine_Idx_FIRST  := l_Order_Line_ID_Tbl.FIRST;
   l_SrvOrdLine_Idx_LAST   := l_Order_Line_ID_Tbl.LAST;

   --

   FORALL f_SrvOrdLine_Idx IN l_SrvOrdLine_Idx_FIRST .. l_SrvOrdLine_Idx_LAST
     INSERT INTO OKS_REPROCESSING
       (ID
       ,ORDER_ID
       ,ORDER_LINE_ID
       ,CONTRACT_ID
       ,CONTRACT_LINE_ID
       ,SUBLINE_ID
       ,ERROR_TEXT
       ,SUCCESS_FLAG
       ,SOURCE_FLAG
       ,CONC_REQUEST_ID
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
       ,OBJECT_VERSION_NUMBER
       ,SECURITY_GROUP_ID
       ,REPROCESS_YN
       ,ORDER_NUMBER )
     VALUES
       (TO_NUMBER(RAWTOHEX(SYS_GUID()),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
       ,l_Order_Header_ID_Tbl(f_SrvOrdLine_Idx)
       ,l_Order_Line_ID_Tbl(f_SrvOrdLine_Idx)
       ,NULL
       ,NULL
       ,NULL
       ,NULL
       ,'N'
       ,'ASO'
       ,NULL
       ,FND_GLOBAL.USER_ID
       ,SYSDATE
       ,FND_GLOBAL.USER_ID
       ,SYSDATE
       ,FND_GLOBAL.LOGIN_ID
       ,1
       ,NULL
       ,'Y'
       ,l_Order_Number_Tbl(f_SrvOrdLine_idx));

     x_Return_Status := 'S';

   EXCEPTION

     WHEN OTHERS THEN
       x_Return_Status := 'U';
       x_Error_Message := 'Unexpected Error :'||' ('||SQLCODE||') '||SUBSTR(SQLERRM,1,170);

 END Interface_Service_Order_Lines;

 /*
  Important Note regarding bug#5330614  , Dated 14-JUN-2006
  This function OKS_OMINT_PUB.Get_quantity is called by Pricing engine to prorate the price breaks if
  the prorate option is set to 'ALL' for the usage. This function should not be changed and should remain
  as is as it is needed for proration of price breaks.
  OKS_OMINT_PUB.Get_target_duration function is called by pricing engine to determine the
  duration between pair of passed service dates and in case of usage, this function will return NULL.
 */

FUNCTION  get_quantity(p_start_date   IN DATE,
                       p_end_date      IN DATE,
                       p_source_uom    IN VARCHAR2 DEFAULT NULL,
                       p_org_id        IN VARCHAR2 DEFAULT NULL)
return number
as

CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 AND LANGUAGE = USERENV('LANG');
 cr_validate_uom  cs_validate_uom%ROWTYPE;


--Added for bug# 5623790 by sjanakir
CURSOR l_lse_id_csr(p_id IN NUMBER) IS
  SELECT lse_id
  FROM   OKC_K_LINES_B
 WHERE  id = p_id;
--Addition Ends
 l_target_qty   NUMBER;
 l_source_uom   varchar2(30);
 l_price_uom    varchar2(30);
 l_period_type  varchar2(30);
 l_period_start varchar2(30);
 l_chr_id       NUMBER;
 l_status       varchar2(80);
 --Added for bug# 5623790 by sjanakir
 l_cle_id       NUMBER;
 l_lse_id	NUMBER;
 --Addition Ends

 invalid_date_exception         EXCEPTION;
 invalid_uom_exception          EXCEPTION;

BEGIN
IF p_source_uom Is Null Then
    l_source_uom := OKS_TIME_MEASURES_PUB.get_uom_code('MONTH',1);
Else
    open cs_validate_uom(p_source_uom);
    fetch cs_validate_uom into cr_validate_uom;

    IF cs_validate_uom%NOTFOUND
    THEN
       RAISE INVALID_UOM_EXCEPTION;
    END IF;

    l_source_uom := p_source_uom;
    close cs_validate_uom;
END IF;

IF (p_start_date IS NULL)OR(p_end_date IS NULL)OR(p_start_date > p_end_date)
THEN
    RAISE INVALID_DATE_EXCEPTION;
END IF;

--OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.CHR_ID is set by QP_PKG before calling pricing engine

l_chr_id := OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.CHR_ID;

OKS_RENEW_UTIL_PUB.get_period_defaults(p_hdr_id        => l_chr_id,
                                       p_org_id        => p_org_id,
                                       x_period_type   => l_period_type,
                                       x_period_start  => l_period_start,
                                       x_price_uom     => l_price_uom,
                                       x_return_status => l_status);
 --Added for bug# 5623790 by sjanakir
 l_cle_id := OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.TOP_LINE_ID;

 Open l_lse_id_csr(l_cle_id);
 Fetch l_lse_id_csr into l_lse_id;
 Close l_lse_id_csr;

 IF l_lse_id = 12 THEN
    l_period_start := 'SERVICE';
 END IF;
--Addition Ends


IF l_status = OKC_API.G_RET_STS_ERROR
THEN
    return 0;
END IF;

IF l_chr_id IS NULL
THEN
    l_period_start := 'SERVICE'; --one time billing for OM/ASO case
END IF;

l_target_qty := OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => p_start_date,
                                                   p_end_date     => p_end_date,
                                                   p_source_uom   => p_source_uom,
                                                   p_period_type  => l_period_type,
                                                   p_period_start => l_period_start);

return(l_target_qty);

EXCEPTION
WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.set_message('OKS','OKS_INVD_UOM_CODE');
      close cs_validate_uom;
      return 0;
WHEN
    INVALID_DATE_EXCEPTION
    THEN
      OKC_API.set_message('OKC','OKC_REP_INV_EFF_DATE_SD');
      return 0;
WHEN OTHERS THEN
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        return 0;

END get_quantity;

--21-DEC-2005 mchoudha
 /* NEW Function added for R12 enhancement partialperiods. This function will replace
 the use of OKS_TIME_MEASURES_PUB.get_quantity by Pricing, and will also replace the use
 of inventory uom conversion API by Order Management and  Quoting/Sales Online.
 */

 /*
  Important Note regarding bug#5330614 dated 14-JUN-2006 :
  OKS_OMINT_PUB.Get_target_duration function is called by pricing engine to determine the
  duration between pair of passed service dates and in case of usage this function will return NULL.
  The function OKS_OMINT_PUB.Get_quantity is called by Pricing engine to prorate the price breaks if
  the prorate option is set to 'ALL' for the usage.
 */
FUNCTION  get_target_duration (  p_start_date      IN DATE DEFAULT NULL,
                                 p_end_date        IN DATE DEFAULT NULL,
                                 p_source_uom      IN VARCHAR2 DEFAULT NULL,
                                 p_source_duration IN NUMBER DEFAULT NULL,
                                 p_target_uom      IN VARCHAR2 DEFAULT NULL,/*Default Month*/
                                 p_org_id          IN NUMBER DEFAULT NULL)
return number
AS

CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 AND LANGUAGE = USERENV('LANG');
 cr_validate_uom  cs_validate_uom%ROWTYPE;

--Added for bug#5330614
 Cursor l_lse_id_csr(p_id IN NUMBER) IS
 SELECT lse_id
 FROM   OKC_K_LINES_B
 WHERE  id = p_id;

 l_target_qty   NUMBER;
 l_target_uom   varchar2(30);
 l_price_uom    varchar2(30);
 l_period_type  varchar2(30);
 l_period_start varchar2(30);
 l_chr_id       NUMBER;
 l_cle_id       NUMBER;
 l_top_line_id  NUMBER;
 l_source_uom_quantity      NUMBER;
 l_source_tce_code          VARCHAR2(30);
 l_target_uom_quantity      NUMBER;
 l_target_tce_code          VARCHAR2(30);
 l_return_status     VARCHAR2(1);
 l_lse_id            NUMBER;
 invalid_date_exception         EXCEPTION;
 invalid_uom_exception          EXCEPTION;
 G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

/* CURSOR om_period_csr(p_id IN NUMBER) IS
select service_period,service_duration
from  okc_k_lines_b subline,
      okc_k_rel_objs rel,
      oe_order_lines_all oel
where subline.cle_id = p_id
and   rel.cle_id = subline.id
and   oel.line_id  = rel.object1_id1;*/

BEGIN

--check for target uom passed if null then default to month
IF p_target_uom Is Null Then
    l_target_uom := OKS_TIME_MEASURES_PUB.get_uom_code('MONTH',1);
Else
    --validate the target uom passed
    open cs_validate_uom(p_target_uom);
    fetch cs_validate_uom into cr_validate_uom;

    IF cs_validate_uom%NOTFOUND
    THEN
       RAISE INVALID_UOM_EXCEPTION;
    END IF;

    l_target_uom := p_target_uom;
    close cs_validate_uom;
END IF;

--fetching the contract id
l_chr_id := OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.CHR_ID;

--Added for bug#5330614
l_cle_id := OKS_QPATTRIB_PVT.G_CONTRACT_LINREC.TOP_LINE_ID;

Open l_lse_id_csr(l_cle_id);
Fetch l_lse_id_csr into l_lse_id;
Close l_lse_id_csr;

IF l_lse_id = 12 THEN
   return NULL;
END IF;
--bug#5330614

--l_top_line_id := OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.TOP_LINE_ID;
--l_service_period := NULL;
--Call from OKS to Price Engine
/*IF l_top_line_id IS NOT NULL THEN
  Open om_period_csr(l_top_line_id);
  Fetch om_period_csr into l_service_period,l_service_duration;
  Close om_period_csr;
END IF; */

--22-MAR-2006 mchoudha Changes for Partial periods CR3
IF l_chr_id IS  NOT NULL OR --price engine call from OKS
   (l_chr_id IS NULL AND (p_start_date IS NOT NULL) AND (p_end_date IS NOT NULL))  --OM call with start date present
THEN

  IF (p_start_date IS NOT NULL) AND (p_end_date IS NOT NULL)
  THEN

    IF (p_start_date > p_end_date) THEN
      RAISE INVALID_DATE_EXCEPTION;
    END IF;


  --OKS_QPATTRIB_PVT.G_CONTRACT_HDRREC.CHR_ID is set by QP_PKG before calling pricing engine

    --get the partial period attributes stamped on the contract
    OKS_RENEW_UTIL_PUB.get_period_defaults(p_hdr_id      => l_chr_id,
                                         p_org_id        => p_org_id,
                                         x_period_type   => l_period_type,
                                         x_period_start  => l_period_start,
                                         x_price_uom     => l_price_uom,
                                         x_return_status => l_return_status);
    IF l_return_status = OKC_API.G_RET_STS_ERROR
    THEN
      return 0;
    END IF;

    --mchoudha added l_chr_id is NULL condition for bug#5182587
    --so that the assignment within IF condition gets executed  only for OM contracts
    IF l_period_start IS NOT NULL AND l_chr_id IS NULL THEN
      l_period_start := 'SERVICE';
    END IF;

    l_target_qty := OKS_TIME_MEASURES_PUB.get_quantity(p_start_date   => p_start_date,
                                                     p_end_date     => p_end_date,
                                                     p_source_uom   => l_target_uom,
                                                     p_period_type  => l_period_type,
                                                     p_period_start => l_period_start);
  ELSE
    return 0;
  END IF;
/*ELSIF  l_chr_id IS  NOT NULL  AND l_service_period IS NOT NULL --OKS price engine call for OM/ASO/Istore case
     NULL;*/

ELSE --OM/ASO/Istore case

  l_period_start := 'SERVICE';
  l_period_type := 'FIXED';

  IF (p_source_uom is NOT NULL) AND (p_source_duration is NOT NULL) THEN

    --Get the seeded timeunit for the source uom
    OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_source_uom,
                     x_return_status => l_return_status,
                     x_quantity      => l_source_uom_quantity ,
                     x_timeunit      => l_source_tce_code);
    IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    --Get the seeded timeunit for the target uom
    OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => l_target_uom,
                     x_return_status => l_return_status,
                     x_quantity      => l_target_uom_quantity ,
                     x_timeunit      => l_target_tce_code);
    IF l_return_status <> 'S' THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    /*Conversion logic using fixed 30 days in a month*/

    --When source uom is seeded in terms of DAY
    IF l_source_tce_code ='DAY' THEN
      IF l_target_tce_code ='YEAR' THEN
        l_target_qty:= p_source_duration*(l_source_uom_quantity/(360*l_target_uom_quantity));
      ELSIF l_target_tce_code ='MONTH' THEN
        l_target_qty:= p_source_duration*(l_source_uom_quantity/(30*l_target_uom_quantity));
      ELSIF l_target_tce_code ='DAY' THEN
        l_target_qty:= p_source_duration*(l_source_uom_quantity/l_target_uom_quantity);
      END IF;
    --When source uom is seeded in terms of MONTH
    ELSIF l_source_tce_code ='MONTH' THEN
      IF l_target_tce_code ='YEAR' THEN
        l_target_qty:= p_source_duration*(l_source_uom_quantity/(12*l_target_uom_quantity));
      ELSIF l_target_tce_code ='MONTH' THEN
        l_target_qty:= p_source_duration*(l_source_uom_quantity/l_target_uom_quantity);
      ELSIF l_target_tce_code ='DAY' THEN
        l_target_qty:= p_source_duration*((l_source_uom_quantity*30)/l_target_uom_quantity);
      END IF;
    --When source uom is seeded in terms of YEAR
    ELSIF l_source_tce_code ='YEAR' THEN
      IF l_target_tce_code ='YEAR' THEN
        l_target_qty:= p_source_duration*(l_source_uom_quantity/l_target_uom_quantity);
      ELSIF l_target_tce_code ='MONTH' THEN
        l_target_qty:= p_source_duration*((l_source_uom_quantity*12)/l_target_uom_quantity);
      ELSIF l_target_tce_code ='DAY' THEN
        l_target_qty:= p_source_duration*((l_source_uom_quantity*360)/l_target_uom_quantity);
      END IF;

    END IF;
  ELSE  --none of two sets of parameters are passed so set the error message and return 0
    OKC_API.set_message('OKS','OKS_INVD_DURATION');
    return 0;
  END IF;
END IF;
return(l_target_qty);

EXCEPTION
WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.set_message('OKS','OKS_INVD_UOM_CODE');
      close cs_validate_uom;
      return 0;
WHEN
    G_EXCEPTION_HALT_VALIDATION
    THEN
      return 0;
WHEN
    INVALID_DATE_EXCEPTION
    THEN
      OKC_API.set_message('OKC','OKC_REP_INV_EFF_DATE_SD');
      return 0;
WHEN OTHERS THEN
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        return 0;

END get_target_duration;

--NPALEPU
--23-JUN-2005
--SERVICE AVAILABILITY API ENHANCEMENT(ER 3680488)
--ADDED NEW OVERLOADED API "Available_Services"

PROCEDURE Available_Services
(
      P_Api_Version           IN  NUMBER,
      P_init_msg_list         IN  VARCHAR2 Default OKC_API.G_FALSE,
      P_search_input          IN  VARCHAR2 Default OKC_API.G_MISS_CHAR,
      P_MAX_ROWS_RETURNED     IN  NUMBER   Default 200,
      X_msg_Count             OUT NOCOPY NUMBER,
      X_msg_Data              OUT NOCOPY VARCHAR2,
      X_Return_Status         OUT NOCOPY VARCHAR2,
      p_avail_service_rec     IN  AVAIL_SERVICE_REC_TYPE,
      X_Orderable_Service_tbl OUT NOCOPY NEW_ORDER_SERVICE_TBL_TYPE,
      --NPALEPU added on 21-sep-2005 for bug # 4608694
      P_ORG_ID                IN  NUMBER   Default NULL
      --END NPALEPU
)
IS

--cursor to fetch the services when P_search_input value is not null
--npalepu 23-dec-2005 for bug # 4897884 removed MTL_UNITS_OF_MEASURE_VL uom,
-- MTL_UNITS_OF_MEASURE_VL srvuom,FND_LOOKUP_VALUES fnd,FND_LOOKUP_VALUES fnd1 tables
Cursor l_service_csr(v_organization_id IN NUMBER) Is
    SELECT
        kfv.organization_id            Organization_id,
        kfv.inventory_item_id          id1,
        kfv.concatenated_segments      Concatenated_segments,
        kfv.description                Description,
        kfv.primary_uom_code           Primary_uom_code,
        uom.description                Primary_uom_description,
        kfv.Serviceable_product_flag   Serviceable_product_flag,
        kfv.service_item_flag          Service_item_flag,
        kfv.bom_item_type              Bom_item_type,
        fnd.meaning                    Bom_item_type_meaning,
        kfv.item_type                  Item_type,
        fnd1.meaning                   Item_type_meaning,
        kfv.service_duration           Service_duration,
        kfv.service_duration_period_code Service_duration_period_code,
        srvuom.description             Service_duration_period_mean,
        kfv.shippable_item_flag        shippable_item_flag,
        kfv.returnable_flag            Returnable_flag
    FROM    MTL_SYSTEM_ITEMS_B_KFV kfv,
            MTL_UNITS_OF_MEASURE_VL uom,
            MTL_UNITS_OF_MEASURE_VL srvuom,
            FND_LOOKUP_VALUES fnd,
            FND_LOOKUP_VALUES fnd1
    WHERE   kfv.vendor_warranty_flag = 'N'
    AND     kfv.service_item_flag    = 'Y'
    AND     kfv.customer_order_enabled_flag = 'Y'
    AND     kfv.enabled_flag  = 'Y'
    --npalepu modified on 23-dec-2005 for bug # 4897884
    /* AND     kfv.organization_id = okc_context.get_okc_organization_id */
    AND     kfv.organization_id = v_organization_id
    --end npalepu
    --NPALEPU,11-AUG-2005
    --Used UPPER Function as Requested by Quoting Team.
    --AND     (kfv.concatenated_segments LIKE P_search_input OR kfv.description LIKE P_search_input )
    AND     (UPPER(kfv.concatenated_segments) LIKE UPPER(P_search_input) OR UPPER(kfv.description) LIKE UPPER(P_search_input) )
    --END NPALEPU
    AND     uom.uom_code     = primary_uom_code
    AND     srvuom.uom_code  = service_duration_period_code
    AND     fnd.lookup_type  = 'BOM_ITEM_TYPE'
    AND     fnd.lookup_code  = bom_item_type
    AND     fnd.language     = USERENV('LANG')
    AND     fnd1.lookup_type = 'ITEM_TYPE'
    AND     fnd1.lookup_code = item_type
    AND     fnd1.language    = USERENV('LANG')
    ORDER BY CONCATENATED_SEGMENTS;

--cursor to fetch the services when P_search_input value is null
--npalepu 23-dec-2005 for bug # 4897884 removed MTL_UNITS_OF_MEASURE_VL uom,
-- MTL_UNITS_OF_MEASURE_VL srvuom,FND_LOOKUP_VALUES fnd,FND_LOOKUP_VALUES fnd1 tables
Cursor l_service_csr1(v_organization_id IN NUMBER) Is
    SELECT
        kfv.organization_id            Organization_id,
        kfv.inventory_item_id          id1,
        kfv.concatenated_segments      Concatenated_segments,
        kfv.description                Description,
        kfv.primary_uom_code           Primary_uom_code,
        uom.description                Primary_uom_description,
        kfv.Serviceable_product_flag   Serviceable_product_flag,
        kfv.service_item_flag          Service_item_flag,
        kfv.bom_item_type              Bom_item_type,
        fnd.meaning                    Bom_item_type_meaning,
        kfv.item_type                  Item_type,
        fnd1.meaning                   Item_type_meaning,
        kfv.service_duration           Service_duration,
        kfv.service_duration_period_code Service_duration_period_code,
        srvuom.description             Service_duration_period_mean,
        kfv.shippable_item_flag        shippable_item_flag,
        kfv.returnable_flag            Returnable_flag
    FROM    MTL_SYSTEM_ITEMS_B_KFV kfv,
            MTL_UNITS_OF_MEASURE_VL uom,
            MTL_UNITS_OF_MEASURE_VL srvuom,
            FND_LOOKUP_VALUES fnd,
            FND_LOOKUP_VALUES fnd1
    WHERE   kfv.vendor_warranty_flag = 'N'
    AND     kfv.service_item_flag    = 'Y'
    AND     kfv.customer_order_enabled_flag = 'Y'
    AND     kfv.enabled_flag  = 'Y'
    --npalepu modified on 23-dec-2005 for bug # 4897884
    /* AND     kfv.organization_id = okc_context.get_okc_organization_id */
    AND     kfv.organization_id = v_organization_id
    --end npalepu
    AND     uom.uom_code     = primary_uom_code
    AND     srvuom.uom_code  = service_duration_period_code
    AND     fnd.lookup_type  = 'BOM_ITEM_TYPE'
    AND     fnd.lookup_code  = bom_item_type
    AND     fnd.language     = USERENV('LANG')
    AND     fnd1.lookup_type = 'ITEM_TYPE'
    AND     fnd1.lookup_code = item_type
    AND     fnd1.language    = USERENV('LANG')
    ORDER BY CONCATENATED_SEGMENTS;

Cursor l_party_csr (l_custid Number) Is
        Select Party_Id From OKX_CUSTOMER_ACCOUNTS_V
        Where  Id1 = l_custid;

l_party_id    Number;

TYPE Srv_tbl_type IS TABLE OF l_service_csr%ROWTYPE INDEX BY BINARY_INTEGER;
l_Srv_tbl       Srv_tbl_type;

l_api_name        CONSTANT VARCHAR2(30) := 'GET_DURATION';
l_api_version     CONSTANT NUMBER     := 11.5;
l_row_count       NUMBER;
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_ptr             Binary_Integer := 0 ;
l_avail           Varchar2(1);
l_isrec           Check_service_rec_type;
l_found           BOOLEAN;
l_index           Binary_Integer := 0 ;
l_outer_loop_exit Varchar2(1) := 'N';

 --NPALEPU 21-sep-2005 for bug # 4608694
l_original_org_id       NUMBER;
l_original_access_mode  Varchar2(1);
--npalepu added on 23-dec-2005 for bug # 4897884
l_org_id                NUMBER;
l_default_org_id        hr_operating_units.organization_id%TYPE;
l_default_ou_name       hr_operating_units.name%TYPE;
l_ou_count              NUMBER;
l_organization_id       NUMBER;
--end 4897884
--END NPALEPU


BEGIN

  --NPALEPU 21-sep-2005 for bug # 4608694

  /* --set org_id if it is null
    if okc_context.get_okc_org_id IS NULL then
        okc_context.set_okc_org_context;
    end if; */

   --capturing the original context
    l_original_org_id       := mo_global.get_current_org_id;
    l_original_access_mode  := mo_global.get_access_mode();

    IF p_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>P_ORG_ID);    */
        l_org_id := p_org_id;
        --end 4897884
    ELSIF l_original_org_id IS NOT NULL THEN
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context(p_org_id =>l_original_org_id);    */
        l_org_id := l_original_org_id;
        --end 4897884
    ELSE
        --npalepu added on 23-dec-2005 for bug # 4897884
        /* okc_context.set_okc_org_context; */
        mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
        l_org_id := l_default_org_id;
        --end 4897884
    END IF;
  --END NPALEPU

    --npalepu added on 23-dec-2005 for bug # 4897884
    IF l_org_id IS NOT NULL AND l_org_id <> -99 THEN
        l_organization_id := OE_PROFILE.VALUE('OE_ORGANIZATION_ID',l_org_id);
    END IF;
    --end 4897884

    l_party_id := Null;

    If p_avail_service_rec.customer_id Is Not Null Then

        Open l_party_csr (p_avail_service_rec.customer_id);
        Fetch l_party_csr Into l_party_id;
        Close l_party_csr;

        If l_party_id IS Null Then
            l_return_status := 'E';
            OKC_API.set_message(G_APP_NAME,'OKS_PARTY_ID_NOT_FOUND','CUSTOMER_ID',to_char(p_avail_service_rec.customer_id));
            Raise G_EXCEPTION_HALT_VALIDATION;
        End If; /*IF <l_party_id IS Null> */

    End If; /*IF <p_avail_service_rec.customer_id Is Not Null> */

    IF ((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL)) THEN
        --npalepu modified on 23-dec-2005 for bug # 4897884
        /* OPEN l_service_csr1; */
        OPEN l_service_csr1(l_organization_id);
        --end 4897884
    ELSE
        --npalepu modified on 23-dec-2005 for bug # 4897884
        /* OPEN l_service_csr; */
        OPEN l_service_csr(l_organization_id);
        --end 4897884
    End IF;/*IF <((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL))>    */

    LOOP
        IF ((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL)) THEN
            FETCH l_service_csr1 BULK COLLECT INTO l_Srv_tbl LIMIT 1000;
        ELSE
            FETCH l_service_csr     BULK COLLECT INTO l_Srv_tbl LIMIT 1000;
        END IF; /*IF <((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL))> */

        IF l_Srv_tbl.count > 0 THEN
            l_index := l_Srv_tbl.FIRST;

            while l_index is not null
            Loop

                l_avail := 'N';
                l_isrec.service_item_id := l_Srv_tbl(l_index).id1;
                l_isrec.product_item_id := p_avail_service_rec.product_item_id;
                l_isrec.customer_id        := p_avail_service_rec.customer_id;
                l_isrec.request_date       := p_avail_service_rec.request_date;

                --npalepu modified on 20-nov-2005
                /* Is_Service_Available
                (
                1.0,
                OKC_API.G_FALSE,
                l_row_count,
                l_msg_Data,
                l_Return_Status,
                l_isrec,
                l_Avail
                );  */
                Is_Service_Available
                (
                P_Api_Version       => 1.0,
                P_init_msg_list     => OKC_API.G_FALSE,
                X_msg_Count         => l_row_count,
                X_msg_Data          => l_msg_Data,
                X_Return_Status     => l_Return_Status,
                p_check_service_rec => l_isrec,
                X_Available_YN      => l_Avail
                );
                --end npalepu

                If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                    Raise G_EXCEPTION_HALT_VALIDATION;
                End If;

                IF (l_ptr >= P_MAX_ROWS_RETURNED) THEN
                    l_outer_loop_exit := 'Y';
                    Exit;
                END IF; /* IF <(l_ptr = P_MAX_ROWS_RETURNED)> */

                If l_Avail = 'Y' Then
                    l_ptr := l_ptr + 1;
                    X_Orderable_Service_tbl(l_ptr).Inventory_organization_id    := l_Srv_tbl(l_index).Organization_id;
                    X_Orderable_Service_tbl(l_ptr).Service_Item_id              := l_Srv_tbl(l_index).id1;
                    X_Orderable_Service_tbl(l_ptr).Concatenated_segments        := l_Srv_tbl(l_index).concatenated_segments;
                    X_Orderable_Service_tbl(l_ptr).Description                  := l_Srv_tbl(l_index).Description;
                    X_Orderable_Service_tbl(l_ptr).Primary_uom_code             := l_Srv_tbl(l_index).Primary_uom_code;
                    X_Orderable_Service_tbl(l_ptr).Serviceable_product_flag     := l_Srv_tbl(l_index).Serviceable_product_flag;
                    X_Orderable_Service_tbl(l_ptr).Service_item_flag            := l_Srv_tbl(l_index).Service_item_flag;
                    X_Orderable_Service_tbl(l_ptr).Bom_item_type                := l_Srv_tbl(l_index).Bom_item_type;
                    X_Orderable_Service_tbl(l_ptr).Item_type                    := l_Srv_tbl(l_index).Item_type;
                    X_Orderable_Service_tbl(l_ptr).Service_duration             := l_Srv_tbl(l_index).Service_duration;
                    X_Orderable_Service_tbl(l_ptr).Service_duration_period_code := l_Srv_tbl(l_index).Service_duration_period_code;
                    X_Orderable_Service_tbl(l_ptr).Shippable_item_flag          := l_Srv_tbl(l_index).Shippable_item_flag;
                    X_Orderable_Service_tbl(l_ptr).Returnable_flag              := l_Srv_tbl(l_index).Returnable_flag;
                End If;/*IF <l_Avail    = 'Y'> */

                l_index := l_Srv_tbl.next(l_index);

            End Loop;/* End of While Loop */

        END IF; /*IF <l_Srv_tbl.count > 0> */

        IF (l_outer_loop_exit = 'Y') THEN
            l_outer_loop_exit := 'N';
            Exit;
        END IF; /*IF <(l_outer_loop_exit = 'Y')> */

        If ((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL)) then
            Exit When l_service_csr1%NOTFound;
        ELSE
            Exit When l_service_csr%NOTFound;
        End If; /*IF <((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL))> */

    END LOOP;/*End of Outer Loop */

    If ((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL)) then
        CLOSE l_service_csr1;
    ELSE
        CLOSE l_service_csr;
    End If; /*IF <((P_search_input = OKC_API.G_MISS_CHAR) OR (P_search_input IS NULL))> */

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    --npalepu removed the code for bug # 4897884
    /* --NPALEPU 21-sep-2005 for bug # 4608694
    --Resetting to original context
    mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
    --END NPALEPU */
    --end 4897884

Exception
    When  G_EXCEPTION_HALT_VALIDATION Then
        x_return_status := l_return_status;
        IF (l_service_csr1%ISOPEN) THEN
            CLOSE l_service_csr1;
        ELSIF (l_service_csr%ISOPEN) THEN
            CLOSE l_service_csr;
        END IF;
        --npalepu removed the code for bug # 4897884
        /*--NPALEPU 21-sep-2005 for bug # 4608694
        --Resetting to original context
        mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
        --END NPALEPU */
        --end 4897884
    When  Others Then
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        IF (l_service_csr1%ISOPEN) THEN
            CLOSE l_service_csr1;
        ELSIF (l_service_csr%ISOPEN) THEN
            CLOSE l_service_csr;
        END IF;
        --npalepu removed the code for bug # 4897884
        /* --NPALEPU 21-sep-2005 for bug # 4608694
        --Resetting to original context
        mo_global.set_policy_context(l_original_access_mode,l_original_org_id);
        --END NPALEPU */
        --end 4897884
END  Available_Services;
--END NPALEPU

END OKS_OMINT_PUB;

/
