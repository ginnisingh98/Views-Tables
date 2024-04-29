--------------------------------------------------------
--  DDL for Package Body OKS_IBINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_IBINT_PUB" As
/* $Header: OKSPIBIB.pls 120.52.12010000.3 2010/03/09 12:35:27 cgopinee ship $ */


  -- Constants used for Message Logging
  G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_CURRENT    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.oks_int_ibint_pub';


 -- created for bom issues
 FUNCTION CHECK_PARENT_CP_K(
  p_order_line_id number,
  p_srvord_line_id number)
  Return BOOLEAN
  IS
  CURSOR  l_parent_cp_csr IS
     Select csi.instance_id
     from csi_item_instances csi , oe_order_lines_all ol
     where ol.line_id  = csi.last_oe_order_line_id
     and   ol.inventory_item_id = csi.inventory_item_id
     and ol.line_id = p_order_line_id ;

  CURSOR l_k_exists (p_item_id NUMBER)IS
        Select 'x'
        From okc_k_rel_objs  rel
             ,okc_k_lines_b line
             ,okc_k_items item
        Where rel.Object1_Id1 = to_char(p_srvord_line_id)
        And    rel.jtot_object1_code = 'OKX_ORDERLINE'
        And  item.cle_id = line.id
        And  item.object1_id1 = to_char(p_item_id)
        And  item.jtot_object1_code = 'OKX_CUSTPROD'
        And   line.id = rel.cle_id
        And   line.lse_id in (9,25)
        And   line.dnz_chr_id = item.dnz_chr_id;


  l_parent_cp_id NUMBER;
  v_flag                        BOOLEAN := TRUE;
  v_temp                        VARCHAR2( 5 );
  Begin

    OPEN  l_parent_cp_csr;
    FETCH l_parent_cp_csr into l_parent_cp_id;
    CLOSE l_parent_cp_csr;

     OPEN l_k_exists (l_parent_cp_id);
     FETCH l_k_exists into v_temp;
     IF ( l_k_exists%FOUND ) THEN
               v_flag := TRUE;
     ELSE
               v_flag := FALSE;
               IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.CHECK_PARENT_AP_K',
                    'Contract not created for parent item yet' );
               END IF;

     END IF;

     CLOSE l_k_exists;
     RETURN (v_flag);
 END;





 Function get_party_id (p_custid Number) Return Number
 Is
    Cursor l_party_csr Is
                       Select Party_Id from OKX_CUSTOMER_ACCOUNTS_V
                       Where  Id1 = p_custid;
    l_party_id         NUMBER;

 Begin

    Open l_party_csr;
    Fetch l_party_csr Into l_party_id;
    If l_party_csr%notfound Then
             Close l_Party_Csr ;
             Return(NULL);
             OKC_API.set_message(G_APP_NAME,'OKS_PARTY_ID_NOT_FOUND','CUSTOMER_ID',P_custid);  --message changed Vigandhi
             Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

    Close l_party_csr;

    Return (l_party_id);


End;
----------------------------------------------------------------------------
-- Update Contract Details
----------------------------------------------------------------------------

Procedure Update_Contract_Details
(    p_hdr_id  Number,
     p_order_line_id number,
     x_return_status Out NOCOPY Varchar2
)
Is

Cursor l_link_csr1 Is
       Select NVL(link_ord_line_id1, order_line_id1)
       From   Oks_k_order_details
       Where  order_line_id1 = to_char(p_ordeR_line_id);

Cursor l_link_csr_a(l_link_ord_id   varchar2) Is
       Select id ,ordeR_line_id1,object_version_number
       From   Oks_k_order_details
       Where  link_ord_line_id1 = l_link_ord_id
       And    Chr_id Is NULL;

Cursor l_link_csr_b(l_link_ord_id   varchar2) Is
       Select id ,ordeR_line_id1,object_version_number
       From   Oks_k_order_details
       Where  order_line_id1 = l_link_ord_id
       And    Chr_id Is NULL;


l_link_rec1            l_link_csr_a%rowtype;
l_link_rec2            l_link_csr_b%rowtype;
l_link_to_order_id     Varchar2(40);
l_return_status        Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count            Number;
l_msg_data             Varchar2(2000);
link_flag              Number := 0;
  l_codv_tbl_in      OKS_COD_PVT.codv_tbl_type;
  l_codv_tbl_out     OKS_COD_PVT.codv_tbl_type;

Begin

    x_return_status := l_return_status;

    Open l_link_csr1;
    Fetch l_link_csr1 Into l_link_to_order_id;

    If l_link_csr1%notfound Then
             Close l_link_csr1 ;
             OKC_API.set_message(G_APP_NAME,'OKS_ORDER_DETAILS','ORDER_DETAILS',p_order_line_id);
             Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

    Close l_link_csr1;

    link_flag := 0;

    Open l_link_csr_a(l_link_to_order_id);
    Loop
           Fetch l_link_csr_a into l_link_rec1;
           Exit WHEN l_link_csr_a%NOTFOUND;

           l_codv_tbl_in(1).id                     := l_link_rec1.id;
           l_codv_tbl_in(1).chr_id                 := p_hdr_id;
           l_codv_tbl_in(1).object_version_number  := l_link_rec1.object_version_number;   ----bugfix 2458974

           OKS_COD_PVT.update_row
           (
               p_api_version     => 1.0 ,
               p_init_msg_list   => 'T',
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               p_codv_tbl        => l_codv_tbl_in,
               x_codv_tbl        => l_codv_tbl_out
           );
          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.UPDATE_CONTRACT_DETAILS',
                 'oks_cod_pvt.update_row(Return status = '|| l_return_status || ')');
          END IF;

           If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                x_return_status := l_return_status;
                Raise G_EXCEPTION_HALT_VALIDATION;
           End if;

                link_flag := 1;

    End Loop;
    Close l_link_csr_a;

    --If link_flag = 0 Then
    Open l_link_csr_b(l_link_to_order_id);
    Loop

         Fetch l_link_csr_b into l_link_rec2;
         Exit WHEN l_link_csr_b%NOTFOUND;

         l_codv_tbl_in(1).id                     := l_link_rec2.id;
         l_codv_tbl_in(1).chr_id                 := p_hdr_id;
         l_codv_tbl_in(1).object_version_number  := l_link_rec2.object_version_number;  --bugfix 2458974

         OKS_COD_PVT.update_row
         (
               p_api_version     => 1.0 ,
               p_init_msg_list   => 'T',
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               p_codv_tbl        => l_codv_tbl_in,
               x_codv_tbl        => l_codv_tbl_out
          );

          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.UPDATE_CONTRACT_DETAILS',
                 'oks_cod_pvt.update_row(Return status = '|| l_return_status || ')');
          END IF;

          If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                 x_return_status := l_return_status;
                 Raise G_EXCEPTION_HALT_VALIDATION;
          End If;

    End Loop;
    Close l_link_csr_b;

---End if;


Exception
     When  G_EXCEPTION_HALT_VALIDATION Then
             x_return_status   :=   l_return_status;

     When  Others Then
             x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
             OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.UPDATE_CONTRACT_DETAILS.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
             END IF;

End;

-------------------------------------------------------------------------------------------------
-- Get Order header Id
-------------------------------------------------------------------------------------------------

Function get_order_header_id  (p_order_line_id Number) Return Number
Is
    Cursor l_header_csr Is
                       Select Header_id from OKX_ORDER_LINES_V
                       Where  Id1 = p_order_line_id;

    l_header_id         NUMBER;

Begin

    Open l_header_csr;
    Fetch l_header_csr Into l_header_id;

    If l_header_csr%notfound Then
             Close l_header_csr;
             Return(NULL);
             OKC_API.set_message(G_APP_NAME,'OKS_ORD_LINE-DTLS_NOT_FOUND','ORDER_LINE',p_order_line_id);  --message changed -Vigandhi
             Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

    Close l_header_csr;

    Return (l_header_id);

End;

-----------------------------------------------------------------------------------------------
--Get Contract Details
-----------------------------------------------------------------------------------------------

Procedure get_contract_details
(
     p_order_line_id IN          Number,
     l_renewal_rec   OUT NOCOPY  renewal_rec_type,
     x_return_status OUT NOCOPY  Varchar2
 )
Is
    Cursor l_chr_csr Is
           Select    Chr_id
                    ,Renewal_type
                    ,po_required_yn
                    ,Renewal_pricing_type
                    ,Markup_percent
                    ,Price_list_id1
                    ,link_chr_id
                    ,contact_id
                    ,email_id
                    ,phone_id
                    ,fax_id
                    ,site_id
                    ,cod_type
                    ,billing_profile_id    --new parameter added -vigandhi (May29-02)
                    ,line_renewal_type
            From    Oks_K_Order_Details_V
            Where   ORDER_LINE_ID1 = to_char(p_order_line_id);

    l_chdr_id         NUMBER;

Begin
    x_return_status           := OKC_API.G_RET_STS_SUCCESS;
    Open l_chr_csr;
    Fetch l_chr_csr Into l_renewal_rec;
    Close l_chr_csr;

Exception
When  Others Then
             x_return_status   :=   OKC_API.G_RET_STS_ERROR;
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.GET_CONTRACT_DETAILS.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
             END IF;
             OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
End;

PROCEDURE IB_New(
                P_instance_rec  Instance_rec_type,
                x_inst_dtls_tbl OUT NOCOPY OKS_IHD_PVT.ihdv_tbl_type,
                x_return_status OUT NoCopy Varchar2,
                x_msg_count OUT NOCOPY Number,
                x_msg_data  OUT NOCOPY VARCHAR2
                )
 Is
 l_return_status    Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
 l_msg_count        NUMBER;
 l_parameters       Varchar2(2000);
  l_Header_rec       OKS_EXTWAR_UTIL_PVT.Header_Rec_Type;
  l_line_rec         OKS_EXTWAR_UTIL_PVT.Line_Rec_Type;
  War_tbl 	     OKS_EXTWAR_UTIL_PVT.War_tbl;

Cursor l_line_Csr(p_inventory_id Number) Is
                  Select  MTL.Name
                         ,MTL.Description
                         ,MTL.Primary_UOM_Code
                         ,MTL.Service_starting_delay
                  From    OKX_SYSTEM_ITEMS_V MTL
                  Where   MTL.id1   = p_Inventory_id
                  And     MTL.Organization_id = okc_context.get_okc_organization_id;

Cursor l_org_csr (p_line_id Number) Is
     select org_id
            ,sold_from_org_id
            ,ship_from_org_id
     from oe_order_lines_all
     where Line_id = p_line_id;

Cursor l_organization_csr(p_org_id Number) Is
       Select master_organization_id
       From oe_system_parameters_all
       where org_id = p_org_id;

Cursor l_refnum_csr(p_cp_id NUMBER) IS
       select instance_number
       from csi_item_instances
       where instance_id = p_cp_id;

Cursor l_subscr_csr(p_instance_id Number) Is
       Select instance_id
       From   Oks_subscr_header_b
       Where  instance_id = p_instance_id
       And    rownum < 2;


l_organization_id   Number;
l_ref_num           Varchar2(30);
l_temp              number;


l_line_dtl_rec     l_line_csr%rowtype;
l_org_rec          l_org_csr%rowtype;



  l_instparent_id  Number;
l_instance_id      Number;

  Cursor Cust_csr(p_id Number) is

       Select csi.last_oe_agreement_id Product_agreement_id
             ,oh.transactional_curr_code Original_order_currency_code
       From   CSI_ITEM_INSTANCES Csi,
              OE_ORDER_HEADERS_ALL OH,
              OE_ORDER_LINES_ALL OL
       Where  csi.instance_id  = p_id
       And    csi.last_oe_order_line_id = ol.line_id
       And    oh.header_id = ol.header_id;

  Cursor l_contact_csr(p_line_id Number) Is
       Select  OC.Object1_id1
              ,OC.cro_code
       From    OKS_K_ORDER_CONTACTS_V OC
              ,OKS_K_ORDER_DETAILS_V OD
       Where  OC.cod_id = OD.id
      -- And    OD.order_line_id1 = p_line_id;
       And    OD.order_line_id1 = to_char(p_line_id); -- Bug Fix #4896051

  Cursor l_Qty_csr(p_id  Number)  Is
       Select fulfilled_quantity
       From   OKX_ORDER_LINES_V
       Where  Id1 = p_id;

  -- warranty consolidation
  -- cursor to get chr_id of existing warranty contract for an order.  vigandhi

  Cursor get_chr_id_csr(p_object_id NUmber) IS
       Select      Chr_id
       From        OKC_K_REL_OBJS RO, OkC_K_HEADERS_V OH
       Where       RO.OBJECT1_ID1 = to_char(P_Object_id)
       And         RO.jtot_object1_code  = 'OKX_ORDERHEAD'
       And         RO.rty_code = 'CONTRACTWARRANTYORDER'
       And         RO.chr_id  = OH.id
       And         OH.sts_code not in ('TERMINATED','CANCELLED');


Cursor l_hdr_scs_csr(p_chr_id  Number) Is
     Select scs_code
         From   OKC_K_HEADERS_V
         Where  id = p_chr_id;

 Cursor l_rel_csr(p_ordlineid Number, p_serv_ordline_id Number,p_item_id Number) Is
        Select rel.cle_id
        From okc_k_rel_objs  rel
             ,okc_k_lines_b line
             ,okc_k_items item
        Where rel.Object1_Id1 in (to_char(p_ordlineid),to_char(p_serv_ordline_id))
        And    rel.jtot_object1_code = 'OKX_ORDERLINE'
        And  item.cle_id = line.id
        And  item.object1_id1 = to_char(p_item_id)
        And  item.jtot_object1_code = 'OKX_CUSTPROD'
        And   line.id = rel.cle_id
        And   line.lse_id in (9, 25)
        And   line.dnz_chr_id = item.dnz_chr_id;



Cursor l_cle_csr(p_ordlineid Number, p_serv_ordline_id Number) Is
        Select rel.cle_id
        From okc_k_rel_objs_v  rel
             ,okc_k_lines_b line
        Where rel.Object1_Id1 in (to_char(p_ordlineid),to_char(p_serv_ordline_id))
        And    rel.jtot_object1_code = 'OKX_ORDERLINE'
        And   line.id = rel.cle_id
        And   line.lse_id in (1,19);

 Cursor l_object_csr(p_cle_id Number, p_cp_id Number) Is
     Select line.id
     From   Okc_k_lines_b line
           ,okc_k_items item
     WHere  item.cle_id = line.id
     ANd    line.cle_id = p_cle_id
     And    line.lse_id in (9, 25)
     And    item.object1_id1 = to_char(p_cp_id)
     ANd    item.jtot_object1_code = 'OKX_CUSTPROD'
     And     item.dnz_chr_id = line.dnz_chr_id;

-- Added: Vigandhi : 18-nov-2004
-- Cursor added to derive the sold to org id in order to get
-- the GCD rules for sold to customer
Cursor  l_Ord_Hdr_csr(p_line_id NUMBER) Is
                  Select  OH.SOLD_TO_ORG_ID
                    From  OE_Order_Headers_ALL OH,
                          OE_ORDER_LINES_ALL OL
                   Where  OH.Header_id  = OL.Header_id
                     AND  OL.line_id    =  p_line_id;

  l_item_id          Number;
  l_rel_id           Number;
 l_line_id          Number;



  l_contact_rec      l_contact_csr%rowtype;
  l_cust_rec         Cust_csr%rowtype;


  l_msg_data         VARCHAR2(2000);
  l_service_status   Varchar2(20);
  l_ptr              Number;
  l_ctr              Number :=1;
  l_line_dtl_rec     l_line_csr%rowtype;
  l_war_date         DATE;
  l_itm_rec          l_line_csr%ROWTYPE;
  l_date             DATE;
  p_order_header_id  NUMBER;
  p_chdr_id          NUMBER;
  p_party_id         NUMBER;
  l_ptr1             NUMBER;
  l_rnrl_rec_out     oks_renew_util_pvt.rnrl_rec_type;
  l_chr_id           NUMBER := Null;
  l_fulfilled_qty    NUMBER;
  l_hdr_scs_code  Varchar2(30);
  i number;
  l_index number;
  l_order_error     VARCHAR2(2000);
  l_curr_code       VARCHAR2(15);
  l_process         BOOLEAN  := TRUE;
  l_Ord_hdr_rec      l_Ord_Hdr_csr%rowtype ;
  l_extwar_rec       OKS_EXTWARPRGM_PVT .extwar_rec_Type;
  p_contact_tbl      OKS_EXTWARPRGM_PVT .contact_tbl;
    l_SalesCredit_tbl  OKS_EXTWARPRGM_PVT.SalesCredit_tbl;
  l_SalesCredit_tbl_hdr  OKS_EXTWARPRGM_PVT.SalesCredit_tbl; --mmadhavi bug 4174921
  l_pricing_attributes_in     OKS_EXTWARPRGM_PVT.Pricing_attributes_Type;
    l_inst_dtls_tbl   OKS_IHD_PVT.ihdv_tbl_type  ;
  l_insthist_rec  OKS_INS_PVT.insv_rec_type;



Begin

       If p_instance_rec.order_line_id Is NULL Or (p_instance_rec.order_line_id = Okc_api.g_miss_num) Then

          -- Added: Vigandhi : 18-nov-2004
          -- Get the renewal rules defined in GCD
          p_party_id         := Get_Party_id(p_instance_rec.old_CustomeR_acct_id);

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                                    'party id(Legacy) = ' ||p_party_id );
          END IF;

          OKS_RENEW_UTIL_PUB.GET_RENEW_RULES
          (
               p_api_version     => 1.0,
               p_init_msg_list   => 'T',
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               P_Chr_Id          => null,
               P_PARTY_ID        => p_party_id ,
               P_ORG_ID          => p_instance_rec.org_id,
               P_Date            => SYSDATE ,
               P_RNRL_Rec        => null,
               X_RNRL_Rec        => l_rnrl_rec_out
          );

          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                        'oks_renew_util_pub.get_renew_rules(Return status = ' ||l_return_status );
          END IF;

          If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
               x_return_status := l_return_status;
               Raise G_EXCEPTION_HALT_VALIDATION;
          End If;

          -- Setting the org context
          Okc_context.set_okc_org_context (p_instance_rec.org_id, p_instance_rec.organization_id);

      Else

          -- Vigandhi : 08-Dec-2005
          --- Fix for Bug 4295015
          IF nvl(fnd_profile.value('OKS_WARRANTY_CONSOLIDATION'), 'Y') = 'Y'
          THEN
                Update Okc_k_headers_all_b
                Set last_updated_by = last_updated_by
                Where id = -1;

                If SQL%ROWCOUNT < 1 Then

                       l_return_status := OKC_API.G_RET_STS_ERROR;
                      OKC_API.set_message(G_APP_NAME,'OKS_INVD_COV_TMPLT_HDR');
                      Raise G_EXCEPTION_HALT_VALIDATION;

                END IF;
          End If;

          -- Added: Vigandhi : 18-nov-2004
          -- Get the renewal rules defined in GCD

          Open l_Ord_Hdr_csr(p_instance_rec.Order_line_id);
          Fetch l_Ord_Hdr_csr into l_Ord_hdr_rec;
          If  l_Ord_Hdr_csr%notfound then
                Close l_Ord_Hdr_csr;
                l_return_status := OKC_API.G_RET_STS_ERROR;
                IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                        'l_ord_hdr_csr failed. No details found for line id ' ||p_instance_rec.Order_line_id );
                END IF;
                OKC_API.set_message(G_APP_NAME, 'OKS_ORD_HDR_DTLS_NOT_FOUND','ORDER_HEADER_ID',p_instance_rec.Order_line_id);
                Raise G_EXCEPTION_HALT_VALIDATION;
          End if;
          Close l_Ord_Hdr_csr;

          p_party_id         := Get_Party_id(l_Ord_hdr_rec.Sold_to_Org_id);

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                                    'party id(OM Generated) = ' ||p_party_id );
          END IF;

          OKS_RENEW_UTIL_PUB.GET_RENEW_RULES
          (
               p_api_version     => 1.0,
               p_init_msg_list   => 'T',
               x_return_status   => l_return_status,
               x_msg_count       => l_msg_count,
               x_msg_data        => l_msg_data,
               P_Chr_Id          => null,
               P_PARTY_ID        => p_party_id ,
               P_ORG_ID          => p_instance_rec.org_id,
               P_Date            => SYSDATE ,
               P_RNRL_Rec        => null,
               X_RNRL_Rec        => l_rnrl_rec_out
          );

          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                        'oks_renew_util_pub.get_renew_rules(Return status = ' ||l_return_status );
          END IF;

          If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
               x_return_status := l_return_status;
               Raise G_EXCEPTION_HALT_VALIDATION;
          End If;

          -- Setting the org context
          Open l_org_csr( p_instance_rec.order_line_id);
          fetch l_org_csr into l_org_rec ;
          Close l_org_Csr ;

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW.l_org_csr',
                    'Org id ='||l_org_rec.org_id ||
                    ',Sold from org id = '|| l_org_rec.sold_from_org_id ||
                    ',Ship from org id = '||l_org_rec.ship_from_org_id  );
          END IF;
          If Fnd_Profile.Value('OKS_CONTRACTS_VALIDATION_SOURCE') = 'IB' OR Fnd_Profile.Value('OKS_CONTRACTS_VALIDATION_SOURCE') Is NULL Then
                  Okc_context.set_okc_org_context (p_instance_rec.org_id, p_instance_rec.organization_id);

          Elsif Fnd_Profile.Value('OKS_CONTRACTS_VALIDATION_SOURCE') = 'MO' Then
                   Okc_context.set_okc_org_context (l_org_rec.org_id, NULL );

          Elsif Fnd_Profile.Value('OKS_CONTRACTS_VALIDATION_SOURCE') = 'SO' Then

                   l_organization_id := Null;
                   If l_org_rec.sold_from_org_id Is Not Null Then
                       Open l_organization_csr(l_org_rec.sold_from_org_id);
                       Fetch l_organization_csr into l_organization_id;
                       Close l_organization_csr;
                   Else
                       l_organization_id := Null;
                   End If;

                   Okc_context.set_okc_org_context (l_org_rec.org_id, l_organization_id);

          Elsif Fnd_Profile.Value('OKS_CONTRACTS_VALIDATION_SOURCE') = 'SH' Then
                   Okc_context.set_okc_org_context (l_org_rec.org_id, l_org_rec.ship_from_org_id);

          End If;


      End If;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW.after org setup',
                    'Org id = '||okc_context.get_okc_org_id ||
                    ',Organization id = '|| okc_context.get_okc_organization_id );
      END IF;

      OKS_EXTWAR_UTIL_PVT.Get_Warranty_Info
      (
           p_prod_item_id        => p_instance_rec.old_inventory_item_id,
           P_customer_product_id => p_instance_rec.old_Customer_product_id,
           x_return_status       => l_return_status,
           p_Ship_date           => p_instance_rec.shipped_date,
           p_installation_date   => p_instance_rec.installation_date,
           x_warranty_tbl        => war_tbl
       ) ;
       IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                    'oks_extwar_util_pvt.get_warranty_info(Return status = '||l_return_status ||',Count = '|| war_tbl.count ||')' );
       END IF;

       If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
              x_return_status := l_return_status;
              Raise G_EXCEPTION_HALT_VALIDATION;
       End If;



       --If No warranty and if legacy ..Skip immediate And delayed service routine


      If war_tbl.count = 0 And  p_instance_rec.order_line_id = okc_api.g_miss_num Then

                IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                    ' Legacy no order line ' );
                END IF;
                Raise G_EXCEPTION_HALT_VALIDATION;

      ElsIf p_instance_rec.order_line_id <> okc_api.g_miss_num Then
                p_order_header_id  := Get_order_header_id(p_instance_rec.order_line_id);
                IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                    '  Order Line Routine. '|| ';'|| 'Order header id = '||p_order_header_id ||'Before update statement' );
                END IF;

                 /* Fix for Bug 2240584.
                    If the procedure OKS_IBINT_PUB is invoked simultaneously for
                    two order lines of the same Order, two contracts were getting created.
                    To avoid that a update statement is included, so that the second order
                    line waits until the first OL is processed.
                 */

             -- Commented out for the fix of bug# 5088409 (JVARGHES)
             --
             -- Update Oe_Order_Headers_all
             -- Set    last_updated_by = last_updated_by
             -- Where  header_id = p_order_header_id;
             --
             -- Commented out for the fix of bug# 5088409 (JVARGHES)

                IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                    ' After update statement' );
                END IF;

                OKS_INTEGRATION_UTIL_PUB.Create_K_Order_Details
                (
                          p_header_id => p_order_header_id
                        , x_return_status => l_return_status
                        , x_msg_count => l_msg_count
                        , x_msg_data  => l_msg_data
                 );

                 IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                    'oks_integration_util_pub.create_k_order_details(Return status = '||l_return_status ||')' );
                 END IF;

                 If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                        x_return_status := l_return_status;
                        Raise G_EXCEPTION_HALT_VALIDATION;
                 End If;

      End If;

      -- Warranty Check

      If Not war_tbl.Count = 0 Then

             If p_instance_rec.order_line_id = okc_api.g_miss_num Then -- Legacy Warranty Routine
                       IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                          ' Legacy Warranty Routine' );
                       END IF;

                       l_chr_id := null;

                       For l_ptr in 1..war_tbl.count
                       Loop

                               Open  l_line_csr (war_tbl(l_ptr).service_item_id);
                               Fetch l_line_csr Into l_itm_rec;
                               Close l_line_csr;
                               IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW.l_line_csr',
                                    ' Name = '||l_itm_rec.name ||',Description = '||l_itm_rec.description ||
                                    ',Primary UOM code = '||l_itm_rec.Primary_UOM_Code ||',Service starting delay = '||l_itm_rec.Service_starting_delay);
                               END IF;


                               If fnd_profile.value('OKS_ITEM_DISPLAY_PREFERENCE') = 'DISPLAY_NAME' Then
                                   l_extwar_rec.srv_desc                  := l_itm_rec.description;
                                   l_extwar_rec.srv_name                  := l_itm_rec.name;
                               Else
                                   l_extwar_rec.srv_desc                  := l_itm_rec.name;
                                   l_extwar_rec.srv_name                  := l_itm_rec.description;
                               End If;

                               -- warranty consolidation
                               -- If customer product has two or more warraties attached to it in BOM, only one contract will get created
                               -- with as many warranty lines.
                               -- profile option created for warranty consolidation --23-apr-2003

                               IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                    fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                                    ' Warranty consolidation profile option '|| fnd_profile.value('OKS_WARRANTY_CONSOLIDATION'));
                               END IF;

                               If l_chr_id IS NOT NULL AND NVL(fnd_profile.value('OKS_WARRANTY_CONSOLIDATION'),'Y') = 'Y'  Then
                                   l_extwar_rec.Merge_Type                := 'LTC';
                                   l_extwar_rec.merge_Object_Id           :=  l_chr_id;
                               Else
                                   l_extwar_rec.Merge_Type                := 'WARR';
                                   l_extwar_rec.merge_Object_Id           :=  NULL;
                               End if;

                               l_extwar_rec.hdr_scs_code              := 'WARRANTY';
                               l_extwar_rec.Warranty_flag             := 'W';
                               l_extwar_rec.rty_code                  := 'CONTRACTWARRANTYORDER';
                               l_extwar_rec.hdr_sdt                   := war_tbl(1).Warranty_start_date;
                               l_extwar_rec.hdr_edt                   := war_tbl(1).Warranty_end_date;
                               l_extwar_rec.hdr_org_id                := p_instance_rec.org_id;
                               l_extwar_rec.hdr_party_id              := Get_Party_id(p_instance_rec.old_CustomeR_acct_id);
                               --l_extwar_rec.hdr_inv_to_contact_id   := NULL;
                               l_extwar_rec.hdr_bill_2_id             := p_instance_rec.bill_to_site_use_id;
                               l_extwar_rec.hdr_ship_2_id             := p_instance_rec.ship_to_site_use_id;
                               l_extwar_rec.hdr_cust_po_number        := NULL;
                               --l_extwar_rec.hdr_agreement_id        := l_cust_rec.Product_agreement_id;
                               --l_extwar_rec.hdr_currency            := Nvl(l_cust_rec.Original_ordeR_currency_code,'USD');
                               l_extwar_rec.hdr_agreement_id          := NULL;
                               l_extwar_rec.hdr_currency              := OKC_CURRENCY_API.GET_OU_CURRENCY(p_instance_rec.org_id);
                               l_extwar_rec.hdr_acct_rule_id          := NULL;
                               l_extwar_rec.hdr_inv_rule_id           := NULL;
                               l_extwar_rec.hdr_ordeR_hdr_id          := NULL;
                               l_extwar_rec.hdr_third_party_role      := l_rnrl_rec_out.rle_code;
                               --l_extwar_rec.hdr_price_list_id       := l_cust_rec.Price_list_id;
                               l_extwar_rec.hdr_status                := NULL;
                               l_extwar_rec.hdr_payment_term_id       := NULL;
                               l_extwar_rec.hdr_cvn_type              := NULL;
                               l_extwar_rec.hdr_cvn_rate              := NULL;
                               l_extwar_rec.hdr_cvn_date              := NULL;
                               l_extwar_rec.hdr_cvn_euro_rate         := NULL;
                               l_extwar_rec.hdr_chr_group             := l_rnrl_rec_out.cgp_new_id;
                               l_extwar_rec.hdr_pdf_id                := NULL;
                               l_extwar_rec.hdr_tax_exemption_id      := NULL;
                               l_extwar_rec.hdr_tax_status_flag       := NULL;
                               l_extwar_rec.hdr_tax_exemption_id      := NULL;
                               l_extwar_rec.hdr_renewal_type          := 'DNR';
                               l_extwar_rec.hdr_renewal_pricing_type  := NULL;
                               l_extwar_rec.hdr_renewal_price_list_id := NULL;
                               l_extwar_rec.hdr_renewal_markup        := NULL;
                               l_extwar_rec.hdr_renewal_po            := NULL;
                               l_extwar_rec.line_invoicing_rule_id    := NULL;
                               l_extwar_rec.line_accounting_rule_id   := NULL;
                               l_extwar_rec.srv_sdt                   := war_tbl(l_ptr).Warranty_start_date;
                               l_extwar_rec.srv_edt                   := war_tbl(l_ptr).Warranty_end_date;
                               l_extwar_rec.srv_id                    := war_tbl(l_ptr).Service_item_id;
                               l_extwar_rec.srv_cov_template_id       := war_tbl(l_ptr).coverage_schedule_id;
                               --l_extwar_rec.srv_desc                := l_itm_rec.description;
                               --l_extwar_rec.srv_name                := l_itm_rec.name;
                               l_extwar_rec.srv_bill_2_id             := p_instance_rec.bill_to_site_use_id;
                               l_extwar_rec.srv_ship_2_id             := p_instance_rec.ship_to_site_use_id;
                               l_extwar_rec.srv_order_line_id         := NULL;
                               l_extwar_rec.lvl_quantity              := p_instance_rec.old_quantity;
                               l_extwar_rec.Srv_amount                := Null;
                               l_extwar_rec.srv_unit_price            := Null;
                               --l_extwar_rec.srv_currency            := Nvl(l_cust_rec.original_order_currency_code,OKC_CURRENCY_API.GET_OU_CURRENCY(p_instance_rec.org_id));
                               l_extwar_rec.srv_currency              := OKC_CURRENCY_API.GET_OU_CURRENCY(p_instance_rec.org_id);
                               l_extwar_rec.lvl_cp_id                 := p_instance_rec.old_customer_product_id;
                               l_extwar_rec.lvl_inventory_id          := p_instance_rec.old_Inventory_item_id;
                               --l_extwar_rec.lvl_inventory_name      := l_line_dtl_rec.name;
                               l_extwar_rec.lvl_UOM_code              := p_instance_rec.old_Unit_of_measure;
                               l_extwar_rec.Cust_account              := p_instance_rec.old_CustomeR_acct_id;
                               --l_extwar_rec.Merge_Type              := 'WARR';
                               --l_extwar_rec.merge_Object_Id         := NULL;
                               l_extwar_rec.qto_contact_id            := Null;
                               l_extwar_rec.qto_email_id              := Null;
                               l_extwar_rec.qto_phone_id              := Null;
                               l_extwar_rec.qto_fax_id                := Null;
                               l_extwar_rec.qto_site_id               := Null;
                               l_extwar_rec.billing_profile_id        := Null;
                               l_extwar_rec.line_renewal_type         := 'DNR';
                               l_extwar_rec.lvl_line_renewal_type     := 'DNR';
                               l_extwar_rec.tax_amount                := 0;
                               l_extwar_rec.renewal_status            := 'COMPLETE';

                               x_inst_dtls_tbl(l_ptr).TRANSACTION_DATE          :=  p_instance_rec.transaction_date;
                               x_inst_dtls_tbl(l_ptr).TRANSACTION_TYPE          :=  'NEW';
                               x_inst_dtls_tbl(l_ptr).INSTANCE_ID_NEW           :=  p_instance_rec.old_customer_product_id;
                               x_inst_dtls_tbl(l_ptr).INSTANCE_QTY_NEW          :=  p_instance_rec.old_quantity;

                               OKS_EXTWARPRGM_PVT .Create_Contract_IBNEW
                               (
                                 p_extwar_rec         => l_ExtWar_Rec
                               , p_contact_tbl_in     => p_contact_tbl
                               , p_salescredit_tbl_hdr_in     => l_SalesCredit_tbl_hdr  --mmadhavi bug 4174921
                               , p_salescredit_tbl_line_in    => l_salescredit_tbl
                               , p_price_attribs_in   => l_pricing_attributes_in
                               , x_inst_dtls_tbl      => x_inst_dtls_tbl
                               , x_chrid              => l_chr_id
                               , x_return_status      => l_return_status
                               , x_msg_count          => x_msg_count
                               ,x_msg_data            => x_msg_data
                               );
                               IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                                    'oks_extwarprgm_pvt .create_contract_ibnew(Return status = '||l_return_status ||
                                    ',Chr_id = ' || l_chr_Id || ')');
                               END IF;

                               If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                                   x_return_status := l_return_status;
                                   Raise G_EXCEPTION_HALT_VALIDATION;
                               End if;

                       End Loop;


                       Raise G_EXCEPTION_HALT_VALIDATION;

              End If; -- Legacy Warranty Routine End
             IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                'Order based Warranty Routine' );
             END IF;

              --OM Originated Warranty Routine Starts Here

              OKS_EXTWAR_UTIL_PVT.Get_Contract_Header_Info
              (
                     P_Order_line_id  =>  p_instance_rec.Order_line_id,
                     P_CP_Id          =>  p_instance_rec.Old_Customer_product_id,
                     p_caller         =>  'IB',
                     x_order_error    =>  l_order_error,
                     X_Return_Status  =>  l_return_status,
                     X_Header_Rec     =>  l_header_rec
              );

              IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                       'oks_extwar_util_pvt.get_contract_header_info(Return status = '||l_return_status || ')');
              END IF;

              If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                     x_return_status := l_return_status;
                     Raise G_EXCEPTION_HALT_VALIDATION;
              End If;

              For l_ptr in 1..war_tbl.count  --OM Warranty Loop
              Loop

                       OKS_EXTWAR_UTIL_PVT.Get_Contract_Line_Info
                       (
                             P_Order_line_id  => p_instance_rec.Order_line_id,
                             P_CP_Id          => p_instance_rec.old_Customer_product_id,
                             P_Product_Item   => p_instance_rec.old_inventory_item_id,
                             X_Return_Status  => l_return_status,
                             X_Line_Rec       => l_line_rec
                        );

                        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                       'oks_extwar_util_pvt.get_contract_line_info(Return status = '||l_return_status || ')');
                        END IF;

                        -- Exception to be written
                        If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                               x_return_status := l_return_status;
                               Raise G_EXCEPTION_HALT_VALIDATION;
                        End If;


                        OKS_EXTWAR_UTIL_PVT.Check_Service_Duplicate
                        (
                             X_Return_Status       => l_return_status,
                             P_Order_Line_Id       => p_instance_rec.order_line_id,
                             P_Serv_Id             => war_tbl(l_ptr).Service_item_id,
                             P_Customer_Product_id => p_instance_rec.old_customer_product_id,
                             P_Serv_start_date     => war_tbl(l_ptr).Warranty_start_date,
                             P_Serv_end_date       => war_tbl(l_ptr).Warranty_end_date,
                             X_Service_Status      =>l_service_status
                        );
                        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                               'oks_extwar_util_pvt.check_service_duplicate(Return status = '||l_return_status ||
                               'Service status = ' || l_service_status || ')');
                        END IF;

                        -- Exception to be written
                        If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                             x_return_status := l_return_status;
                             Raise G_EXCEPTION_HALT_VALIDATION;
                        End If;

                        -- l_service_status := 'N';
                        If l_service_status = 'N' Then -- Duplicate  Check

                                   -- warranty consolidation  -Vigandhi
                                   -- If existing contract is terminated new warraty contract will be created.
                                   -- If existing contract is expired its sts_code and effectivity will be changed.
                                   -- profile option created for warranty consolidation 23-apr-2003

                                   p_order_header_id  := Get_order_header_id(p_instance_rec.order_line_id);
                                   l_chr_id := Null;

                                   Open get_chr_id_csr(p_order_header_id);
                                   Fetch get_chr_id_csr into l_chr_id;
                                   close get_chr_id_csr;

                                   IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                       fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_NEW',
                                         'Warranty consolidation profile option '|| fnd_profile.value('OKS_WARRANTY_CONSOLIDATION'));
                                   END IF;

                                   If l_chr_id Is not null AND NVL(fnd_profile.value('OKS_WARRANTY_CONSOLIDATION'),'Y') = 'Y'  then
                                             l_extwar_rec.Merge_Type                 := 'LTC';
                                             l_extwar_rec.merge_Object_Id            := l_chr_id;
                                   Else
                                             l_extwar_rec.Merge_Type                 := 'WARR';
                                             l_extwar_rec.merge_Object_Id            := NULL;
                                   end if;


                                   l_extwar_rec.Warranty_flag              := 'W';
                                   l_extwar_rec.hdr_scs_code              := 'WARRANTY';
                                   l_extwar_rec.rty_code                   := 'CONTRACTWARRANTYORDER';
                                   l_extwar_rec.hdr_sdt                    := war_tbl(1).Warranty_start_date;
                                   l_extwar_rec.hdr_edt                    := war_tbl(1).Warranty_end_date;
                                   l_extwar_rec.hdr_org_id                 := l_header_rec.authoring_org_id;
                                   l_extwar_rec.hdr_party_id               := l_header_rec.party_id;
                                   -- l_extwar_rec.hdr_inv_to_contact_id   := l_header_rec.invoice_to_contact_id;
                                   l_extwar_rec.hdr_bill_2_id              := l_header_rec.bill_to_id;
                                   l_extwar_rec.hdr_ship_2_id              := l_header_rec.ship_to_id;
                                   l_extwar_rec.hdr_cust_po_number         := l_header_rec.cust_po_number;
                                   l_extwar_rec.hdr_agreement_id           := l_header_rec.agreement_id;
                                   l_extwar_rec.hdr_currency               := nvl(l_header_rec.currency,OKC_CURRENCY_API.GET_OU_CURRENCY(p_instance_rec.org_id));
                                   l_extwar_rec.hdr_acct_rule_id           := NVL(l_header_rec.accounting_rule_id,1);
                                   l_extwar_rec.hdr_inv_rule_id            := NVL(l_header_rec.invoice_rule_id,-2);
                                   l_extwar_rec.hdr_ordeR_hdr_id           := l_header_rec.order_hdr_id;
                                   l_extwar_rec.hdr_third_party_role       := l_rnrl_rec_out.rle_code;
                                   l_extwar_rec.hdr_price_list_id          := l_header_rec.Price_list_id;
                                   l_extwar_rec.hdr_status                 := NULL;
                                   l_extwar_rec.hdr_payment_term_id        := l_header_rec.hdr_Payment_term_id;
                                   l_extwar_rec.hdr_cvn_type               := l_header_rec.hdr_cvn_type;
                                   l_extwar_rec.hdr_cvn_rate               := l_header_rec.hdr_cvn_rate;
                                   l_extwar_rec.hdr_cvn_date               := l_header_rec.hdr_cvn_date;
                                   l_extwar_rec.hdr_cvn_euro_rate          := NULL;
                                   l_extwar_rec.hdr_chr_group              := l_rnrl_rec_out.cgp_new_id;
                                   l_extwar_rec.hdr_pdf_id                 := NULL;
                                   l_extwar_rec.hdr_tax_exemption_id       := l_header_rec.hdr_tax_exemption_id;
                                   l_extwar_rec.hdr_tax_status_flag        := l_header_rec.hdr_tax_status_flag;
                                   l_extwar_rec.hdr_renewal_type           := 'DNR';
                                   l_extwar_rec.hdr_renewal_pricing_type   := NULL;
                                   l_extwar_rec.hdr_renewal_price_list_id  := NULL;
                                   l_extwar_rec.hdr_renewal_markup         := NULL;
                                   l_extwar_rec.hdr_renewal_po             := NULL;
                                   l_extwar_rec.srv_sdt                    := war_tbl(l_ptr).Warranty_start_date;
                                   l_extwar_rec.srv_edt                    := war_tbl(l_ptr).Warranty_end_date;
                                   l_extwar_rec.srv_id                     := war_tbl(l_ptr).Service_item_id;
                                   l_extwar_rec.srv_cov_template_id        := war_tbl(l_ptr).coverage_schedule_id;
                                   l_extwar_rec.srv_desc                   := l_line_rec.srv_desc;
                                   l_extwar_rec.srv_name                   := l_line_rec.srv_segment1;
                                   l_extwar_rec.srv_bill_2_id              := l_line_rec.bill_to_id;
                                   l_extwar_rec.srv_ship_2_id              := l_line_rec.ship_to_id;
                                   l_extwar_rec.srv_order_line_id          := l_line_rec.order_line_id;
                                   l_extwar_rec.lvl_quantity               := p_instance_rec.old_quantity;
                                   l_extwar_rec.Srv_amount                 := Null;
                                   l_extwar_rec.srv_unit_price             := Null;
                                   --l_extwar_rec.srv_currency             := Null;
                                   l_extwar_rec.srv_currency               := OKC_CURRENCY_API.GET_OU_CURRENCY(p_instance_rec.org_id);
                                   l_extwar_rec.lvl_cp_id                  := p_instance_rec.old_customer_product_id;
                                   l_extwar_rec.lvl_inventory_id           := p_instance_rec.old_Inventory_item_id;
                                   -- l_extwar_rec.lvl_inventory_desc      := l_line_dtl_rec.description;
                                   -- l_extwar_rec.lvl_inventory_name      := l_line_dtl_rec.name;
                                   l_extwar_rec.lvl_UOM_code               := p_instance_rec.old_Unit_of_measure;
                                   l_extwar_rec.Cust_account               :=  l_line_rec.CustomeR_acct_id;
                                   --l_extwar_rec.Cust_account               :=  p_instance_rec.CustomeR_acct_id;
                                   l_extwar_rec.line_Invoicing_rule_id     :=  NVL(l_line_rec.Invoicing_rule_id,-2);
                                   l_extwar_rec.line_Accounting_rule_id    :=  NVL(l_line_rec.Accounting_rule_id,1);
                                   -- l_extwar_rec.Merge_Type                 := 'WARR';
                                   -- l_extwar_rec.merge_Object_Id            := NULL;
                                   l_extwar_rec.qto_contact_id             := Null;
                                   l_extwar_rec.qto_email_id               := Null;
                                   l_extwar_rec.qto_phone_id               := Null;
                                   l_extwar_rec.qto_fax_id                 := Null;
                                   l_extwar_rec.qto_site_id                := Null;
                                   l_extwar_rec.billing_profile_id         := Null;
                                   l_extwar_rec.salesrep_id                := l_header_rec.salesrep_id;
                                   l_extwar_rec.commitment_id              := l_line_rec.commitment_id;
                                   l_extwar_rec.line_renewal_type          := 'DNR';
                                   l_extwar_rec.lvl_line_renewal_type      := 'DNR';
                                   l_extwar_rec.tax_amount                 := 0;
                                   l_extwar_rec.renewal_status             := 'COMPLETE';

                                   p_contact_tbl.delete;

                                   x_inst_dtls_tbl(l_ptr).TRANSACTION_DATE          :=  p_instance_rec.transaction_date;
                                   x_inst_dtls_tbl(l_ptr).TRANSACTION_TYPE          :=  'NEW';
                                   x_inst_dtls_tbl(l_ptr).INSTANCE_ID_NEW           :=  p_instance_rec.old_customer_product_id;
                                   x_inst_dtls_tbl(l_ptr).INSTANCE_QTY_NEW          :=  p_instance_rec.old_quantity;

                                   OKS_EXTWARPRGM_PVT .Create_Contract_IBNEW
                                   (
                                           p_extwar_rec            => l_ExtWar_Rec
                                         , p_contact_tbl_in        => p_contact_tbl
                                         , p_salescredit_tbl_hdr_in     => l_SalesCredit_tbl_hdr  --mmadhavi bug 4174921
                                         , p_salescredit_tbl_line_in    => l_salescredit_tbl
                                         , p_price_attribs_in      => l_pricing_attributes_in
                                         , x_inst_dtls_tbl         => x_inst_dtls_tbl
                                         , x_chrid                 => l_chr_id
                                         , x_return_status         => l_return_status
                                         , x_msg_count             => x_msg_count
                                         , x_msg_data              => x_msg_data
                                   );
                                   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                                        'oks_extwarprgm_pvt .create_contract_ibnew(Return status = '||l_return_status || ')');
                                   END IF;

                                   If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then

                                      FOR i in 1..fnd_msg_pub.count_msg
                                      Loop
                                          fnd_msg_pub.get
                                          (
                                               p_msg_index     => i,
                                               p_encoded       => 'F',
                                               p_data          => l_msg_data,
                                               p_msg_index_out => l_index
                                          );
                                          If(G_FND_LOG_OPTION = 'Y') Then
                                          FND_FILE.PUT_LINE (FND_FILE.LOG, 'OM WARRANTY ERROR : ' || l_msg_data );
                                          End If;
                                      End Loop;

                                      x_return_status := l_return_status;
                                      Raise G_EXCEPTION_HALT_VALIDATION;

                                    End if;

                          End if; -- Duplicate Check Ends

                 End Loop; --OM Warranty Loop

       End If; -- Warranty Check


 Exception
      When G_EXCEPTION_HALT_VALIDATION Then
           x_return_status   :=   l_return_status;

End IB_NEW;



Procedure IB_Interface
(P_Api_Version	NUMBER,
P_init_msg_list	VARCHAR2,
P_single_txn_date_flag	VARCHAR2,
P_Batch_type	VARCHAR2,
P_Batch_ID	NUMBER,
P_OKS_Txn_Inst_tbl	TXN_INSTANCE_tbl,
x_return_status	OUT NOCOPY VARCHAR2,
x_msg_count	OUT NOCOPY NUMBER,
x_msg_data	OUT NOCOPY VARCHAR2)  Is



Cursor get_Instances_for_new_csr Is
Select  old_customer_product_id
       ,old_quantity
       ,Bom_explosion_flag
       ,Old_Unit_of_measure
       ,Old_Inventory_item_id
       ,Old_Customer_acct_id
       ,Organization_id
       ,Bill_to_site_use_id
       ,Ship_to_site_use_id
       ,Org_id
       ,Order_line_id
       ,Shipped_date
       ,Installation_date
       ,transaction_date
From   Oks_instance_temp
Where  New = 'Y';




Cursor get_Contracts_for_transfer_csr Is
 Select                 KI.Dnz_Chr_Id
                   ,KH.authoring_org_id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  ,KH.Contract_number
                  ,KH.scs_code
                  ,OL.Id LineId
                  ,OL.line_NUMBER
                  ,KIS.object1_id1
                  ,KI.CLE_ID
                  ,OL.Start_date Line_start_date
                  ,OL.End_Date line_end_date
                   ,OL.bill_to_site_use_id
                   ,OL.Ship_to_site_use_id
                   ,KL.Price_Negotiated Service_amount
                   ,OKL.tax_amount
                   ,KSL.tax_code
                   ,KL.Price_unit
                   ,OL.Currency_Code Service_Currency
                  ,KI.NUMBER_OF_ITEMS
                   ,OL.cust_acct_id
                   ,KSL.Acct_rule_id line_acct_rule_id
                   ,OL.inv_rule_id line_inv_rule_id
                   ,Kh.price_list_id
                  ,KH.payment_term_id
                  ,KS.acct_rule_id
                  ,KH.Inv_rule_id
                  ,KS.AR_interface_yn
                  ,KS.Summary_trx_yn
                  ,KS.Hold_billing
                  ,KS.Inv_trx_type
                  ,KS.Payment_type
                  ,KH.inv_organization_id
                  ,KH.Conversion_type
                  ,KH.Conversion_rate
                  ,KH.COnversion_rate_date
                  ,KH.Conversion_euro_rate
                  ,KH.Billed_at_source
                  ,Kl.cle_id_renewed
                  ,OL.sts_code line_sts_code
                  ,KL.sts_code
                  ,KL.start_date
                  ,KL.end_date
                  ,KL.date_terminated
                  ,KL.lse_id
                  ,KL.Name
                  ,KL.Item_description
                  ,KL.line_renewal_type_code
                  ,KL.upg_orig_system_ref
                  ,KL.upg_orig_system_ref_id
                  ,KH.cust_po_number
                  ,KH.currency_code
                  ,PARTY.Object1_id1 Party_id
                  ,tmp.old_customer_product_id
                  ,tmp.old_inventory_item_id
                  ,tmp.transfer_date
		  ,tmp.transaction_date
                  ,tmp.old_customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_customer_product_id
                  ,KSL.Coverage_Id
                  ,KSL.standard_cov_yn
                  ,KS.Period_Start
                  ,KS.Period_type
                  ,tmp.old_unit_of_measure
                  ,okl.price_uom sl_price_uom
                  ,ksl.price_uom tl_price_uom
                  ,ks.price_uom  hdr_price_uom
                  ,okl.toplvl_uom_code
		  ,okl.toplvl_price_qty
          From    OKC_K_ITEMS   KI
                  ,OKC_K_HEADERS_ALL_B KH
                  ,OKS_K_HEADERS_B KS
                  ,OKC_K_LINES_V   KL
                  ,OKS_K_LINES_B   OKL
                  ,OKC_STATUSES_B  ST
                  ,OKC_K_PARTY_ROLES_B PARTY
                  , OKC_K_LINES_B OL
                  ,OKS_K_LINES_B KSL
                  ,OKC_K_ITEMS KIS
                  , OKS_INSTANCE_TEMP tmp

           Where   tmp.trf = 'Y'
           And     nvl(tmp.trm,'N') = 'N'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KS.Chr_id(+) = KH.ID
           And     KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )  -- supp
           And     KI.Cle_id = KL.id
	   And     OKL.CLE_ID(+) = KL.ID
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED')
           And     KL.date_terminated Is  Null
           And     KH.template_yn = 'N'
           And     OL.Id = KL.cle_id
           And     KSL.cle_id(+) = OL.Id
           And     KIS.cle_id = OL.Id
           And     KIS.dnz_chr_id = OL.dnz_chr_id
           AND     PARTY.dnz_chr_id = kH.ID
           AND     PARTY.chr_id is not null
           AND     PARTY.cle_id is null
           And     PARTY.rle_code in ('CUSTOMER','SUBSCRIBER')
           And     PARTY.jtot_object1_code = 'OKX_PARTY'
           And   ( (trunc(tmp.transfer_date) <= trunc(KL.end_date)And trunc(tmp.transfer_date) >= trunc(KL.start_date))
                   OR (trunc(tmp.transfer_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(tmp.transfer_date)
		            And kl.lse_id <> 18
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id
                                           )
                      )
                   )
            order by  tmp.old_customer_product_id, kh.creation_date; --KI.Dnz_Chr_Id;

Cursor get_k_for_trm_csr Is
 Select            tmp.old_customer_product_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  ,tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  ,KH.inv_organization_id
                  ,KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  ,tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  ,PARTY.Object1_id1 Party_id
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , Null
                  , Null
                  , Null

           From     OKC_K_ITEMS KI
                  , OKC_K_HEADERS_ALL_B KH
                  , OKC_K_LINES_B   KL
	              , OKC_STATUSES_B ST
                  ,  OKS_INSTANCE_TEMP tmp
                  , OKC_K_LINES_B TL
                  ,OKC_K_ITEMS KIS
                  ,OKC_K_PARTY_ROLES_B PARTY
           Where   tmp.trm = 'Y'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     TL.Id = KL.cle_id
           And     KIS.cle_id = TL.id
           And     KIS.dnz_chr_id = TL.dnz_chr_id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED')
           And     KL.date_terminated Is Null
           And     KH.template_yn = 'N'
           AND     PARTY.dnz_chr_id = kH.ID
           AND     PARTY.chr_id is not null
           AND     PARTY.cle_id is null
           And     PARTY.rle_code in ('CUSTOMER','SUBSCRIBER')
           And     PARTY.jtot_object1_code = 'OKX_PARTY'

           And   ( (trunc(tmp.Termination_date) <= trunc(KL.end_date)
                        And trunc(tmp.Termination_date) >= trunc(KL.start_date))
                   OR (trunc(tmp.Termination_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(tmp.Termination_date)
		            And kl.lse_id <> 18
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id)
                      ))



	Union

 Select            tmp.old_customer_product_id Instance_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  ,tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  ,KH.inv_organization_id
                  ,KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  ,tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  ,PARTY.Object1_id1 Party_id
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , Null
                  , Null
                  , Null


         From    OKC_K_ITEMS   KI
	              ,OKC_K_HEADERS_ALL_B KH
	              ,OKC_K_LINES_B   KL
                      ,OKC_K_LINES_B TL
	              ,OKC_STATUSES_B  ST
		      ,csi_counter_associations CTRASC
                      ,OKS_INSTANCE_TEMP tmp
                      ,OKC_K_ITEMS KIS
                      ,OKC_K_PARTY_ROLES_B PARTY
           Where   tmp.trm = 'Y'
               And     KI.object1_id1 = TO_CHAR (CTRASC.Counter_id)
               And     ctrasc.source_object_id =    tmp.old_customer_product_id
	       And     ctrAsc.source_object_code = 'CP'
	       And     KI.jtot_object1_code = 'OKX_COUNTER'
	       And     KI.dnz_chr_id = KH.ID
	       And     KH.scs_code in ('SERVICE','SUBSCRIPTION')
	       And     KI.Cle_id = KL.id
               And     TL.Id = KL.cle_id
               And     KIS.cle_id = TL.id
               And     KIS.dnz_chr_id = TL.dnz_chr_id
	           And     KL.sts_code = ST.code
	           And     ST.ste_code not in ('TERMINATED','CANCELLED')
	           And     KL.date_terminated Is Null
	           And     KH.template_yn = 'N'
               AND     PARTY.dnz_chr_id = kH.ID
               AND     PARTY.chr_id is not null
               AND     PARTY.cle_id is null
               And     PARTY.rle_code in ('CUSTOMER','SUBSCRIBER')
               And     PARTY.jtot_object1_code = 'OKX_PARTY'

                 And   ( (trunc(tmp.Termination_date) <= trunc(KL.end_date)
                        And trunc(tmp.Termination_date) >= trunc(KL.start_date))
                   OR (trunc(tmp.Termination_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(tmp.Termination_date)
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id)
                      ));

              Cursor get_k_for_ret_csr Is
 Select            tmp.old_customer_product_id Instance_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  ,tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  ,KH.inv_organization_id
                  ,KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  ,tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  ,PARTY.Object1_id1 Party_id
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , Null
                  , Null
                  , Null
           From     OKC_K_ITEMS KI
                  , OKC_K_HEADERS_ALL_B KH
                  , OKC_K_LINES_B   KL
	              , OKC_STATUSES_B ST
                  ,  OKS_INSTANCE_TEMP tmp
                  , OKC_K_LINES_B TL
                  ,OKC_K_ITEMS KIS
                  ,OKC_K_PARTY_ROLES_B PARTY

           Where   tmp.ret = 'Y'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     TL.Id = KL.cle_id
           And     KIS.cle_id = TL.id
           And     KIS.dnz_chr_id = TL.dnz_chr_id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED')
           And     KL.date_terminated Is Null
           AND     PARTY.dnz_chr_id = kH.ID
           AND     PARTY.chr_id is not null
           AND     PARTY.cle_id is null
           And     PARTY.rle_code in ('CUSTOMER','SUBSCRIBER')
           And     PARTY.jtot_object1_code = 'OKX_PARTY'

           And     KH.template_yn = 'N'
                            And   ( (trunc(tmp.Termination_date) <= trunc(KL.end_date)
                        And trunc(tmp.Termination_date) >= trunc(KL.start_date))
                   OR (trunc(tmp.Termination_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(tmp.Termination_date)
		            And kl.lse_id <> 18
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id)
                      ))



	Union

 Select            tmp.old_customer_product_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  ,tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  ,KH.inv_organization_id
                  ,KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  ,tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  , PARTY.Object1_id1 Party_id
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , null
                  , null
                  , null
         From    OKC_K_ITEMS   KI
	            ,OKC_K_HEADERS_ALL_B KH
	                  ,OKC_K_LINES_B   KL
                      ,OKC_K_LINES_B TL
	                  ,OKC_STATUSES_B  ST
			  ,csi_counter_associations CTRASC
                      ,  OKS_INSTANCE_TEMP tmp
                      ,OKC_K_ITEMS KIS
                     ,OKC_K_PARTY_ROLES_B PARTY

           Where   tmp.ret = 'Y'
               And      KI.object1_id1 = to_char(CTRASC.Counter_id)
               And   ctrasc.source_object_id =    tmp.old_customer_product_id
	       And   ctrAsc.source_object_code = 'CP'
	           And     ki.jtot_object1_code = 'OKX_COUNTER'
	           And     KI.dnz_chr_id = KH.ID
	           And     KH.scs_code in ('SERVICE','SUBSCRIPTION')
	           And     KI.Cle_id = KL.id
               And     TL.Id = KL.cle_id
               And     KIS.cle_id = TL.id
               And     KIS.dnz_chr_id = TL.dnz_chr_id
	           And     KL.sts_code = ST.code
	           And     ST.ste_code not in ('TERMINATED','CANCELLED')
	           And     KL.date_terminated Is Null
                          AND     PARTY.dnz_chr_id = kH.ID
           AND     PARTY.chr_id is not null
           AND     PARTY.cle_id is null
           And     PARTY.rle_code in ('CUSTOMER','SUBSCRIBER')
           And     PARTY.jtot_object1_code = 'OKX_PARTY'
	     And     KH.template_yn = 'N'
           And   ( (trunc(tmp.Termination_date) <= trunc(KL.end_date)
                        And trunc(tmp.Termination_date) >= trunc(KL.start_date))
                   OR (trunc(tmp.Termination_date) <= trunc(kl.start_date))
	            OR ( trunc(KL.end_date) < trunc(tmp.Termination_date)
	                    And not exists (Select 'x'
                                           from okc_operation_instances ois,
                                           okc_operation_lines opl,
                                           okc_class_operations cls,
                                           okc_subclasses_b sl
                                           where ois.id=opl.oie_id
                                           And cls.opn_code in ('RENEWAL','REN_CON')
                                           And sl.code= 'SERVICE'
                                           And sl.cls_code = cls.cls_code
                                           and ois.cop_id = cls.id
                                           and object_cle_id=kl.id)
                      ));



Cursor get_k_for_idc_csr Is

 Select            tmp.old_customer_product_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  ,tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  ,KH.inv_organization_id
                  ,KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  ,tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  , null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , null
                  , Null
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , null
                  , null
                  , null
           From     OKC_K_ITEMS KI
                  , OKC_K_HEADERS_ALL_B KH
                  , OKC_K_LINES_B   KL
	              , OKC_STATUSES_B ST
                  ,  OKS_INSTANCE_TEMP tmp
                  , OKC_K_LINES_B TL
                  ,OKC_K_ITEMS KIS
           Where   tmp.idc = 'Y'
           And     nvl(tmp.trm,'N') = 'N'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY')
           And     KI.Cle_id = KL.id
           And     TL.Id = KL.cle_id
           And     KIS.cle_id = TL.id
           And     KIS.dnz_chr_id = TL.dnz_chr_id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED')
           And     KL.date_terminated Is Null
           And     KH.template_yn = 'N'
           And     KL.lse_id = 18;


           Cursor get_k_for_Spl_csr Is
 Select            tmp.old_customer_product_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  ,tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  ,KH.inv_organization_id
                  ,KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  ,tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  , null
                  , OKL.tax_amount
                  , KL.Price_unit
                  , KL.Name
                  , KL.Item_description
                  , KL.upg_orig_system_ref
                  , KL.upg_orig_system_ref_id
                  , tmp.new_inventory_item_id
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , okl.price_uom
                  , okl.toplvl_uom_code
                  , okl.toplvl_price_qty
           From     OKC_K_ITEMS KI
                  , OKC_K_HEADERS_ALL_B KH
                  , OKC_K_LINES_v   KL
	              , OKC_STATUSES_B ST
                  ,  OKS_INSTANCE_TEMP tmp
                  , OKC_K_LINES_B TL
                  ,OKC_K_ITEMS KIS
                  , OKS_K_LINES_B OKL
           Where   tmp.spl = 'Y'
           And     nvl(tmp.trm,'N') = 'N'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     TL.Id = KL.cle_id
           And     KIS.cle_id = TL.id
           And     KIS.dnz_chr_id = TL.dnz_chr_id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED','HOLD')
           And     KL.date_terminated Is Null
           And     KH.template_yn = 'N'
           And     OKL.cle_id = kl.id
           And    ((trunc(tmp.transaction_date) <= trunc(KL.end_date)And trunc(tmp.transaction_date) >= trunc(KL.start_date))
                    OR (trunc(tmp.transaction_date) <= trunc(kl.start_date)) )
           order by  tmp.old_customer_product_id, kh.creation_date; --KI.Dnz_Chr_Id;


Cursor get_k_for_rpl_csr Is
 Select            tmp.old_customer_product_id Instance_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,tmp.old_quantity
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  , tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  , KH.inv_organization_id
                  , KL.lse_id
                  , KH.scs_code
                  , tmp.new_customer_product_id
                  , KIS.Object1_id1
                  , TL.Currency_code
                  , tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  , null
                  , OKL.tax_amount
                  , KL.Price_unit
                  , KL.Name
                  , KL.Item_description
                  , KL.upg_orig_system_ref
                  , KL.upg_orig_system_ref_id
                  , tmp.new_inventory_item_id
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , okl.price_uom
                  , okl.toplvl_uom_code
                  , okl.toplvl_price_qty
           From     OKC_K_ITEMS KI
                  , OKC_K_HEADERS_ALL_B KH
                  , OKC_K_LINES_v   KL
	              , OKC_STATUSES_B ST
                  ,  OKS_INSTANCE_TEMP tmp
                  , OKC_K_LINES_B TL
                  ,OKC_K_ITEMS KIS
                  , OKS_K_LINES_B OKL

           Where   tmp.rpl = 'Y'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     TL.Id = KL.cle_id
           And     KIS.cle_id = TL.id
           And     KIS.dnz_chr_id = TL.dnz_chr_id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED','HOLD')
           And     KL.date_terminated Is Null
           And     OKL.cle_id = kl.id
           And     KH.template_yn = 'N'
           And    ((trunc(tmp.transaction_date) <= trunc(KL.end_date)And trunc(tmp.transaction_date) >= trunc(KL.start_date))
                    OR (trunc(tmp.transaction_date) <= trunc(kl.start_date)) )
           order by  tmp.old_customer_product_id, kh.creation_date; -- KI.Dnz_Chr_Id;


 Cursor get_k_for_upd_csr Is
 Select            tmp.old_customer_product_id Instance_id
                  ,tmp.termination_date
                  ,tmp.installation_date
                  ,tmp.transaction_date
                  ,tmp.old_Customer_acct_id
                  ,tmp.new_customer_acct_id
                  ,tmp.System_id
                  ,KI.number_of_items
                  ,tmp.new_quantity
                  ,tmp.new_customer_product_id
                  ,KI.CLE_ID SubLine_id
                  , KI.Dnz_Chr_Id
                  ,KH.start_date  hdr_sdt
                  ,KH.end_date    hdr_edt
                  ,KH.sts_code    hdr_sts
                  , KL.Cle_Id
                  ,KL.Price_negotiated
                  , KL.Start_date
                  , KL.end_date
                  , KL.sts_code prod_sts
                  , KL.Cust_acct_id
                  , TL.start_date Srv_sdt
                  , TL.end_date Srv_edt
                  , KH.sts_code
                  , KH.Contract_number
                  , KI.number_of_items
                  , TL.price_negotiated
                  , KL.date_terminated
                  , tmp.old_inventory_item_id
                  , KH.authoring_org_id
                  , KH.inv_organization_id
                  , KL.lse_id
                  , KH.scs_code
                  , tmp.old_customer_product_id
                  , KIS.object1_id1
                  , TL.Currency_code
                  , tmp.old_unit_of_measure
                  , KL.line_renewal_type_code
                  , tmp.raise_credit
                  , null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , Null
                  , tmp.return_reason_code
                  , tmp.order_line_id
                  , okl.price_uom
                  , okl.toplvl_uom_code
                  , okl.toplvl_price_qty
           From     OKC_K_ITEMS KI
                  , OKC_K_HEADERS_ALL_B KH
                  , OKC_K_LINES_B   KL
	              , OKC_STATUSES_B ST
                  ,  OKS_INSTANCE_TEMP tmp
                  , OKC_K_LINES_B TL
                  , OKC_K_ITEMS KIS
                  , OKS_K_LINES_B OKL
           Where   tmp.upd = 'Y'
           And     Nvl(tmp.trm,'N') = 'N'
           And     KI.Object1_id1 = to_char(tmp.old_customer_product_id)
           And     KI.Jtot_Object1_code = 'OKX_CUSTPROD'
           And     KI.dnz_chr_id = KH.ID
           And     KH.scs_code in ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
           And     KI.Cle_id = KL.id
           And     TL.Id = KL.cle_id
           And     KIS.cle_id = TL.id
           And     KIS.dnz_chr_id = TL.dnz_chr_id
           And     KL.sts_code = ST.code
           And     ST.ste_code not in ('TERMINATED','CANCELLED')
           And     KL.date_terminated Is Null
           And     KH.template_yn = 'N'
           AND     OKL.cle_id = KI.cle_id
           And    ((trunc(tmp.transaction_date) <= trunc(KL.end_date)And trunc(tmp.transaction_date) >= trunc(KL.start_date))
                    OR (trunc(tmp.transaction_date) <= trunc(kl.start_date)) );

Cursor check_subscription_instance Is
       Select 'Y'
       From   Oks_subscr_header_b oks, Oks_instance_temp tmp
       Where  oks.instance_id = tmp.old_customer_product_id;

Cursor l_refnum_csr(p_cp_id NUMBER) IS
       select instance_number
       from csi_item_instances
       where instance_id = p_cp_id;

k_trf_tbl OKS_EXTWARPRGM_PVT.Contract_trf_tbl;
k_trm_tbl OKS_EXTWARPRGM_PVT.Contract_tbl;
k_ret_tbl OKS_EXTWARPRGM_PVT.Contract_tbl;
k_idc_tbl OKS_EXTWARPRGM_PVT.Contract_tbl;
k_spl_tbl OKS_EXTWARPRGM_PVT.Contract_tbl;
k_rpl_tbl OKS_EXTWARPRGM_PVT.Contract_tbl;
k_upd_tbl OKS_EXTWARPRGM_PVT.Contract_tbl;


l_return_status Varchar2(1):= OKC_API.G_RET_STS_SUCCESS;
l_inst_dtls_tbl   OKS_IHD_PVT.ihdv_tbl_type  ;
l_subscr_instance  Varchar2(1);
l_ref_num   Varchar2(30);
l_temp Number;
l_parameters Varchar2(2000);
  l_insthist_rec  OKS_INS_PVT.insv_rec_type;
  x_insthist_rec  OKS_INS_PVT.insv_rec_type;
  l_instparent_id Number;
x_inst_dtls_tbl   OKS_IHD_PVT.ihdv_tbl_type  ;

l_access_mode     Varchar2(10);
l_org_id          Number;
l_process_status  Varchar2(1);
Begin
/*
FND_GLOBAL.APPS_INITIALIZE(1005214, 21708, 515);
fnd_profile.put('AFLOG_ENABLED', 'Y');
fnd_profile.put('AFLOG_MODULE', '%');
fnd_profile.put('AFLOG_LEVEL', '1');
fnd_profile.put('AFLOG_FILENAME', '');
fnd_log_repository.init;

*/
    x_return_status := l_return_status;

    l_access_mode := MO_GLOBAL.Get_access_mode;
    l_org_id      := MO_GLOBAL.Get_current_org_id;

    MO_Global.set_policy_context('A', null);

    Delete from Oks_Instance_temp;

    FORALL i in P_oks_txn_inst_tbl.FIRST..P_oks_txn_inst_tbl.LAST
    INSERT INTO oks_instance_temp
    Values P_oks_txn_inst_tbl(i);

    --If instance is a subscription instance throw an error
    Open check_subscription_instance;
    Fetch check_subscription_instance into l_subscr_instance;
    Close check_subscription_instance;

    If l_subscr_instance = 'Y' Then
            l_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message(G_APP_NAME,'OKS_SUBSCRIPTION_INST_ERR');
            Raise G_EXCEPTION_HALT_VALIDATION;

    End If;
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Batch Id'||p_batch_id ||')'  );
    End If;
    If p_batch_id Is not Null Then

            OKS_MASS_UPDATE_PVT.update_contracts (
              p_api_version            => 1.0,
              p_init_msg_list          => 'T',
              p_batch_type             => P_batch_type,
              p_batch_id               => P_batch_id,
              p_new_acct_id            => P_oks_txn_inst_tbl(1).New_Customer_acct_id,
              p_old_acct_id           => P_oks_txn_inst_tbl(1).Old_Customer_acct_id,
              x_return_status          => l_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data
            );

            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                        'OKS_MASS_UPDATE.update_contracts(Return status = ' ||l_return_status );
            END IF;

            If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
               x_return_status := l_return_status;
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;
     Else



            --New Transaction
            -- Get all the instances for new transaction
            Open get_instances_for_new_csr;
            Fetch get_instances_for_new_csr Bulk Collect into instance_tbl;
            Close get_instances_for_new_csr;
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction New =' ||instance_tbl.count);
            End If;
            If instance_tbl.count > 0 Then
                  For i in 1..instance_tbl.count
                  Loop

                        IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

                                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.IB_INTERFACE.Begin.parameters',
                                 'Transaction Type = '|| 'NEW'|| 'Transaction date = '|| instance_tbl(i).transaction_date
                                 ||'Bom explosion flag = '|| instance_tbl(i).bom_explosion_flag );
                                fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.IB_INTERFACE.Begin.parameter',
                                 'Old Org = '||instance_tbl(i).org_id||',Old Customer Product Id = '||instance_tbl(i).old_customer_product_id
                                 ||',Old Order Line Id = '||instance_tbl(i).order_line_id ||',Old Shipped Date = '|| instance_tbl(i).shipped_date
                                 ||',Old Bill To = '|| instance_tbl(i).bill_to_site_use_id ||',Old Ship To = '||instance_tbl(i).ship_to_site_use_id
                                 ||',Old Quantity = '|| instance_tbl(i).old_quantity || ',Old Unit Of Measurement = '|| instance_tbl(i).old_unit_of_measure
                                 ||',Old Inventory Item Id = '||instance_tbl(i).old_inventory_item_id || ',Old Customer acount Id = '||instance_tbl(i).old_customer_acct_id
                                 ||',Old Organization Id = ' ||instance_tbl(i).organization_id );

                        END IF;

                         Ib_new(
                                 P_instance_rec => instance_tbl(i),
                                 x_inst_dtls_tbl  => l_inst_dtls_tbl,
                                 x_return_status  => l_return_status,
                                 x_msg_count => x_msg_count,
                                 x_msg_data  => x_msg_data
                               );




                         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Ib_new(Return status = '||l_return_status ||')'  );
                         End If;
                         x_return_status := l_return_status;
                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;

                         ------------------------------------------------------
                        -- Inserting instance details into history and
                        -- history details table
                        ------------------------------------------------------

                        If  l_inst_dtls_tbl.count = 0 OR l_return_status <> 'S' Then

                             IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                                  'No records for history details or status invalid ' );
                             End If;
                             Null;
                        Else
                             OPEN l_refnum_csr (instance_tbl(i).old_customer_product_id);
                             FETCH l_refnum_csr into l_ref_num;
                             Close l_refnum_csr;

                             If instance_tbl(i).order_line_id = okc_api.g_miss_num Then
                                  l_temp := null;
                             Else
                                  l_temp := instance_tbl(i).order_line_id ;
                             End If;

                             l_parameters :=
                               ' Org Id:'       ||  instance_tbl(i).org_id              ||',Old CP:'             || instance_tbl(i).old_customer_product_id    ||',Order line id:'      || l_temp
                             ||',Ship Date:'    ||  instance_tbl(i).shipped_date        ||',Bill to:'            || instance_tbl(i).bill_to_site_use_id    ||',Ship to:'            || instance_tbl(i).ship_to_site_use_id
                             ||',Old Qty:'      ||  instance_tbl(i).old_quantity            ||',UOM:'                || instance_tbl(i).old_unit_of_measure        ||',Old Inv id:'         || instance_tbl(i).old_inventory_item_id
                             ||',Old cust acct:'||  instance_tbl(i).old_customer_acct_id    ||',Old Organization id:'|| instance_tbl(i).organization_id        ||',Installation date:'  || instance_tbl(i).installation_date
                             || ',Trxn type:'          || 'NEW'
                             ||',Trxn date:'    ||  instance_tbl(i).transaction_date
                             ||',Bom Expl flag:'|| instance_tbl(i).bom_explosion_flag ;

                             --oks_instance_history
                             l_insthist_rec.INSTANCE_ID           :=  instance_tbl(i).old_customer_product_id;
                             l_insthist_rec.TRANSACTION_TYPE      :=   'NEW';
                             l_insthist_rec.TRANSACTION_DATE      :=   instance_tbl(i).transaction_date ;
                             l_insthist_rec.REFERENCE_NUMBER      :=   l_ref_num;
                             l_insthist_rec.parameters            :=   l_parameters;


                             OKS_INS_PVT.insert_row(
                                  p_api_version            =>      1.0,
                                  p_init_msg_list          =>      'T',
                                  x_return_status          =>      l_return_status,
                                  x_msg_count              =>      x_msg_count,
                                  x_msg_data               =>      x_msg_data,
                                  p_insv_rec                =>      l_insthist_rec,
                                  x_insv_rec                =>      x_insthist_rec
                                  );
                             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE.instance history',
                                   'oks_ins_pvt.insert_row(Return status = '||l_return_status ||')'  );
                             End If;
                             x_return_status := l_return_status;
                             If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                                 x_return_status := l_return_status;
                                 Raise G_EXCEPTION_HALT_VALIDATION;
                             End if;
                             l_instparent_id := x_insthist_rec.id;

                             For l_ctr in 1..l_inst_dtls_tbl.count
                             Loop
                                   l_inst_dtls_tbl(l_ctr).ins_id := l_instparent_id;
                             End loop;

                             --oks_inst_history_details
                             OKS_IHD_PVT.insert_row(
                                     p_api_version            => 1.0 ,
                                     p_init_msg_list          => 'T',
                                     x_return_status          => l_return_status,
                                     x_msg_count              => x_msg_count,
                                     x_msg_data               => x_msg_data,
                                     p_ihdv_tbl               => l_inst_dtls_tbl,
                                     x_ihdv_tbl               => x_inst_dtls_tbl
                                      );
                            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE.instance history details',
                                   'oks_ihd_pvt.insert_row(Return status = '||l_return_status ||')'  );
                             End If;
                             x_return_status := l_return_status;
                             If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                                       x_return_status := l_return_status;
                                       Raise G_EXCEPTION_HALT_VALIDATION;
                             End if;

                        End If;



                  End Loop;
            End If;

            -- Transfer transaction
            Open get_Contracts_for_transfer_csr;
            Fetch get_Contracts_for_transfer_csr Bulk Collect into k_trf_tbl;
            Close get_Contracts_for_transfer_csr;
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction Transfer=' ||k_trf_tbl.count);
            End If;



            If K_trf_tbl.count > 0 Then


                   OKS_EXTWARPRGM_PVT .Create_k_System_TRANSFER
                    (
                     p_kdtl_tbl       => k_trf_tbl,
                     x_return_status  => l_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data
                    );
                  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                         'oks_extwarprgm_pvt .create_k_system_transfer(Return status = '||l_return_status ||')'  );
                   End If;

                         x_return_status := l_return_status;
                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;

             End If;

            -- Terminate transaction
            Open get_k_for_trm_csr;
            Fetch get_k_for_trm_csr Bulk Collect into k_trm_tbl;
            Close get_k_for_trm_csr;
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction Terminate=' ||k_trm_tbl.count);
            End If;


            If K_trm_tbl.count > 0 Then

                   OKS_EXTWARPRGM_PVT.Create_COntract_Terminate
                  (
                     p_kdtl_tbl       => k_trm_tbl,
                     x_return_status  => l_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data
                  );
                         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Create_contract_terminate(Return status = '||l_return_status ||')'  );
                         End If;
                         x_return_status := l_return_status;
                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;
             End If;
            -- Return transaction

            Open get_k_for_ret_csr;
            Fetch get_k_for_ret_csr Bulk Collect into k_ret_tbl;
            Close get_k_for_ret_csr;

            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction Return=' ||k_ret_tbl.count);
            End If;

            --errorout_n('in return count'||K_ret_tbl.count);

            If K_ret_tbl.count > 0 Then

                   OKS_EXTWARPRGM_PVT.Create_Contract_IBReturn
                  (
                     p_kdtl_tbl       => k_ret_tbl,
                     x_return_status  => l_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data
                  );

                         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Create_Contract_IBreturn(Return status = '||l_return_status ||')'  );
                         End If;
                         x_return_status := l_return_status;
                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;
             End If;
            -- Update transaction
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                               'Instance quantity Update Profile=' ||fnd_profile.value('OKS_INSTANCE_QUANTITY_UPDATE'));
            End If;

            If NVL(fnd_profile.value('OKS_INSTANCE_QUANTITY_UPDATE'),'N') = 'Y' Then
                 Open get_k_for_upd_csr;
                 Fetch get_k_for_upd_csr Bulk Collect into k_upd_tbl;
                 Close get_k_for_upd_csr;

                 IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                      'Number of instances with transaction Update=' ||k_upd_tbl.count);
                 End If;


                 If K_upd_tbl.count > 0 Then

                        OKS_EXTWARPRGM_PVT.Create_Contract_IBupdate
                       (
                          p_kdtl_tbl       => k_upd_tbl,
                          x_return_status  => l_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data
                       );
                         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Create_contract_IBupdate(Return status = '||l_return_status ||')'  );
                         End If;
                         x_return_status := l_return_status;
                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;
                  End If;

            End If;

            -- IDC transaction

            Open get_k_for_idc_csr;
            Fetch get_k_for_idc_csr Bulk Collect into k_idc_tbl;
            Close get_k_for_idc_csr;
             --errorout_n('idc'||k_idc_tbl.count );

            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction Idc=' ||k_idc_tbl.count);
            End If;


            If K_idc_tbl.count > 0 Then
                OKS_EXTWARPRGM_PVT.Update_Contract_IDC
                  (
                     p_kdtl_tbl       => k_idc_tbl,
                     x_return_status  => l_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data
                  );
                         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Update_contract_idc(Return status = '||l_return_status ||')'  );
                         End If;
                  x_return_status := l_return_status;

                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;

             End If;


            -- Split transaction

            Open get_k_for_spl_csr;
            Fetch get_k_for_spl_csr Bulk Collect into k_spl_tbl;
            Close get_k_for_spl_csr;
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction Split=' ||k_spl_tbl.count);
            End If;


            If K_spl_tbl.count > 0 Then

                   OKS_EXTWARPRGM_PVT.Create_Contract_IBSPLIT
                  (
                     p_kdtl_tbl       => k_spl_tbl,
                     x_return_status  => l_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data
                  );
                         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                              'Create_contract_ibsplit(Return status = '||l_return_status ||')'  );
                         End If;
                         x_return_status := l_return_status;
                         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                            x_return_status := l_return_status;
                            Raise G_EXCEPTION_HALT_VALIDATION;
                         End if;
             End If;

            -- Replace transaction

            Open get_k_for_rpl_csr;
            Fetch get_k_for_rpl_csr Bulk Collect into k_rpl_tbl;
            Close get_k_for_rpl_csr;

            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                 'Number of instances with transaction Replace=' ||k_rpl_tbl.count);
            End If;



            If K_rpl_tbl.count > 0 Then
                  --Call out to Pre-Integration
                  --This is done as part of License Migration
                  --Call out starts here
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                  THEN
                    fnd_log.string(FND_LOG.LEVEL_STATEMENT
                       ,G_MODULE_CURRENT||'.IB_INTERFACE'
				   ,'Before OKS_OMIB_EXTNS_PUB.pre_integration call: ' ||
                     ' ,p_api_version = '|| p_api_version ||
                     ' ,p_init_msg_list = ' || p_init_msg_list ||
                     ' ,p_from_integration = IBINT' ||
                     ' ,p_transaction_type = ' || 'RPL' ||
                     ' ,p_transaction_date = ' || K_rpl_tbl(1).transaction_date||
                     ' ,p_order_line_id = ' || K_rpl_tbl(1).order_line_id ||
                     ' ,p_old_instance_id = ' || K_rpl_tbl(1).old_cp_id ||
                     ' ,p_new_instance_id = ' || K_rpl_tbl(1).new_cp_id);
                  END IF;


                  OKS_OMIB_INT_EXTNS_PUB.pre_integration
	                (p_api_version      => 1.0
                     ,p_init_msg_list    => 'T'
                     ,p_from_integration => 'IBINT'
                     ,p_transaction_type => 'RPL'
                     ,p_transaction_date => K_rpl_tbl(1).transaction_date
                     ,p_order_line_id    => K_rpl_tbl(1).order_line_id
                     ,p_old_instance_id  => K_rpl_tbl(1).old_cp_id
                     ,p_new_instance_id  => K_rpl_tbl(1).new_cp_id
		         ,x_process_status   => l_process_status
                     ,x_return_status    => x_return_status
                     ,x_msg_count        => x_msg_count
                     ,x_msg_data         => x_msg_data);

                  IF fnd_log.level_event >= fnd_log.g_current_runtime_level
                  THEN
                    fnd_log.string(FND_LOG.LEVEL_EVENT
                                  ,G_MODULE_CURRENT||'.IB_INTERFACE'
                                  ,'After OKS_OMIB_INT_EXTNS_PUB.pre_integration Call: ' ||
                                ' ,x_process_status = ' || l_process_status ||
                                ' ,x_return_status = ' || x_return_status);
                  END IF;
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                  THEN
                    RAISE G_EXCEPTION_HALT_VALIDATION;
	             END IF;
                  --Call out ends here
                 IF l_process_status = 'C'  THEN

                              OKS_EXTWARPRGM_PVT.Update_Contract_IBReplace
                             (
                                p_kdtl_tbl       => k_rpl_tbl,
                                x_return_status  => l_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data
                             );
                              IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_INTERFACE',
                                         'Update_Contract_IBReplace(Return status = '||l_return_status ||')'  );
                              End If;
                              x_return_status := l_return_status;
                              If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                                       x_return_status := l_return_status;
                                       Raise G_EXCEPTION_HALT_VALIDATION;
                              End if;
                    End If;
                    --Call out to post integration starts here
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                    THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT
                        ,G_MODULE_CURRENT||'.IB_INTERFACE'
                        ,'Before OKS_OMIB_EXTNS_PUB.post_integration call: ' ||
                      ' ,p_transaction_type = ' || 'RPL'||
                      ' ,p_transaction_date = ' || K_rpl_tbl(1).transaction_date||
                      ' ,p_order_line_id = ' || K_rpl_tbl(1).order_line_id ||
                      ' ,p_old_instance_id = ' || K_rpl_tbl(1).old_cp_id ||
                      ' ,p_new_instance_id = ' || K_rpl_tbl(1).new_cp_id ||
	                 ' ,p_chr_id = ' || NULL ||
	    	    	       ' ,p_topline_id = ' || NULL ||
			       ' ,p_subline_id = ' || NULL);
                    END IF;
                    OKS_OMIB_INT_EXTNS_PUB.post_integration
                        (p_api_version      => 1.0
                        ,p_init_msg_list    => 'T'
                        ,p_from_integration => 'IBINT'
                        ,p_transaction_type => 'RPL'
                        ,p_transaction_date => K_rpl_tbl(1).transaction_date
                        ,p_order_line_id    => K_rpl_tbl(1).order_line_id
                        ,p_old_instance_id  => K_rpl_tbl(1).old_cp_id
                        ,p_new_instance_id  => K_rpl_tbl(1).new_cp_id
                        ,p_chr_id           => NULL
                        ,p_topline_id       => NULL
                        ,p_subline_id       => NULL
                        ,x_return_status    => x_return_status
                        ,x_msg_count        => x_msg_count
                        ,x_msg_data         => x_msg_data);
                    IF fnd_log.level_event >= fnd_log.g_current_runtime_level
                    THEN
                      fnd_log.string(FND_LOG.LEVEL_EVENT
                        ,G_MODULE_CURRENT||'.IB_INTERFACE'
                        ,'After OKS_OMIB_INT_EXTNS_PUB.post_integration Call: ' ||
                      ' ,x_return_status = ' || x_return_status);
                    END IF;
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                      RAISE G_EXCEPTION_HALT_VALIDATION;
	               END IF;




           End If;
     End If;
             --Reset the policy context
             MO_GLOBAL.set_policy_context(l_access_mode,l_org_id);
x_return_status := l_return_status;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
             x_return_status   :=   l_return_status;
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.IB_INTERFACE.UNEXPECTED',
                   'Return status = '||x_return_status );
             END IF;
             --Fix for bug 4947476
             FND_MSG_PUB.Count_And_Get
		(
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);

When  Others Then
             x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.IB_INTERFACE.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
             END IF;
             OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
             --Fix for bug 4947476
             FND_MSG_PUB.Count_And_Get
		(
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);

End;

-- Procedure to delete a batch.
procedure delete_batch
(
 P_Api_Version           IN             NUMBER,
 P_init_msg_list         IN             VARCHAR2,
 P_Batch_ID              IN             NUMBER,
 x_return_status         OUT NOCOPY     VARCHAR2,
 x_msg_count             OUT NOCOPY     NUMBER,
 x_msg_data	         OUT NOCOPY     VARCHAR2)
Is

Begin

     x_return_status := 'S';
     DELETE FROM OKS_BATCH_RULES
     WHERE batch_ID = P_Batch_ID;
Exception
When  Others Then
             x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.IB_INTERFACE.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
             END IF;
             OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);

End;

-- Procedure to validate batch rules before submitting
-- the batch for processing.

procedure Validate_new_owner
(
 P_Api_Version           IN             NUMBER,
 P_init_msg_list         IN             VARCHAR2,
 P_Batch_ID              IN             NUMBER,
 P_new_owner_id          IN             NUMBER,
 x_return_status         OUT NOCOPY     VARCHAR2,
 x_msg_count             OUT NOCOPY     NUMBER,
 x_msg_data	         OUT NOCOPY     VARCHAR2)
IS

   Cursor l_check_csr IS
    SELECT 'x'
      FROM oks_batch_rules
     WHERE batch_id = p_batch_id
       AND NVL(new_account_id, p_new_owner_id) = p_new_owner_id;

   l_dummy_var VARCHAR2(1) := '?';

BEGIN
  x_return_status := 'S';
  IF p_new_owner_id IS NOT NULL THEN
     OPEN l_check_csr;
     FETCH l_check_csr INTO l_dummy_var;
     CLOSE l_check_csr;

     IF l_dummy_var = '?'
     THEN
        x_return_status  := OKC_API.G_RET_STS_ERROR;
        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                  'Accounts mismatch ' ||p_batch_id ||'Account id'|| p_new_owner_id );
        END IF;
        OKC_API.set_message(G_APP_NAME, 'OKS_BATCH_RULES_MISMATCH');
     END IF;
  ELSE
        IF p_batch_id IS NOT NULL
        THEN
            delete_batch(
                P_Api_Version           => p_api_version,
                P_init_msg_list         => p_init_msg_list,
                P_Batch_ID              => p_batch_id,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

                If x_return_status <> OKC_API.G_RET_STS_SUCCESS
                THEN
                     x_return_status  := OKC_API.G_RET_STS_ERROR;
                     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.IB_NEW',
                             'Error while deleting the batch ' ||p_batch_id);
                     END IF;
                END IF;
        END IF;
  END IF;
END;


-- Procedure to create batch rules
procedure create_batch_rules
(
 P_Api_Version           IN              NUMBER,
 P_init_msg_list         IN             VARCHAR2,
 P_Batch_ID              IN             NUMBER,
 p_batch_type            IN             VARCHAR2,
 x_return_status         OUT NOCOPY     VARCHAR2,
 x_msg_count             OUT NOCOPY     NUMBER,
 x_msg_data	         OUT NOCOPY     VARCHAR2)
Is
l_batch_rule  oks_brl_pvt.oks_batch_rules_v_rec_type;
x_batch_rule  oks_brl_pvt.oks_batch_rules_v_rec_type;
l_reason_type   VARCHAR2(3);
l_return_status VARCHAR2(1) := 'S';
begin

IF p_batch_type = 'XFER'
THEN
l_reason_type := 'TRF';
ELSE
l_reason_type := 'EXP';
END IF;

l_batch_rule.batch_id                    := P_Batch_ID;
l_batch_rule.batch_type                  := p_batch_type;
l_batch_rule.batch_source                := 'IB';
l_batch_rule.transaction_date            := SYSDATE;
l_batch_rule.credit_option               := NULL ;
l_batch_rule.termination_reason_code     := l_reason_type ;
l_batch_rule.billing_profile_id          := NULL ;
l_batch_rule.retain_contract_number_flag := 'N' ;
l_batch_rule.contract_modifier           := NULL ;
l_batch_rule.contract_status             := NVL(fnd_profile.value('OKS_TRANSFER_STATUS'),'ENTERED') ;
l_batch_rule.transfer_notes_flag         := 'N';
l_batch_rule.transfer_attachments_flag   := 'N';
l_batch_rule.bill_lines_flag             := 'Y' ;
l_batch_rule.transfer_option_code        := 'COVERAGE' ;
l_batch_rule.bill_account_id             := NULL ;
l_batch_rule.ship_account_id             := NULL ;
l_batch_rule.bill_address_id             := NULL ;
l_batch_rule.ship_address_id             := NULL ;
l_batch_rule.bill_contact_id             := NULL ;
l_batch_rule.new_account_id              := NULL ;
l_batch_rule.object_version_number       := 1 ;

oks_brl_pvt.insert_row(
    p_api_version               => p_api_version,
    p_init_msg_list             => p_init_msg_list,
    x_return_status             => l_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data,
    p_oks_batch_rules_v_rec     => l_batch_rule,
    x_oks_batch_rules_v_rec     => x_batch_rule);

         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.CREATE_BATCH',
                 'oks_brl_pvt.insert_row(Return status = '|| l_return_status || ')');
         END IF;

         If not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                x_return_status := l_return_status;
                Raise G_EXCEPTION_HALT_VALIDATION;
         End if;
x_return_status := l_return_status;
Exception
     When  G_EXCEPTION_HALT_VALIDATION Then
             x_return_status   :=   l_return_status;
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.CARETE_BATCH_RULES.UNEXPECTED',
                                'No Batch rules created');
             END IF;

     When  Others Then
             x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
             OKC_API.set_message(G_APP_NAME,G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE,G_SQLERRM_TOKEN, SQLERRM);
             IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.CARETE_BATCH_RULES.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
             END IF;
End;

FUNCTION CHECK_SUBSCR_INSTANCE( p_instance_id NUMBER)
  RETURN VARCHAR2 IS

Cursor l_subscr_csr Is
       Select 'Y' subscr_instance
       From   Oks_subscr_header_b
       Where  instance_id = p_instance_id
       And    rownum < 2;

l_subscr_instance  VARCHAR2(1):= 'N';
BEGIN
    FOR  subcr_rec in l_subscr_csr LOOP
      l_subscr_instance := subcr_rec.subscr_instance;
    END LOOP;
    RETURN l_subscr_instance;
END CHECK_SUBSCR_INSTANCE;

PROCEDURE POPULATE_CHILD_INSTANCES (p_api_version         IN          Number,
                                    p_init_msg_list       IN          Varchar2 Default OKC_API.G_FALSE,
                                    p_instance_id         IN          NUMBER,
                                    p_transaction_type    IN          VARCHAR2,
                                    x_msg_Count           OUT NOCOPY  Number,
                                    x_msg_Data            OUT NOCOPY  Varchar2,
                                    x_return_status       OUT NOCOPY  Varchar2)
IS

 l_txn_rec        CSI_UTILITY_GRP.txn_oks_rec;
 l_txn_inst_tbl   CSI_UTILITY_GRP.txn_inst_tbl;
 i number := 1;

BEGIN
--Call IB API to get child instances
    l_txn_rec.transaction_type(1) := p_transaction_type;
    l_txn_rec.instance_id :=   p_instance_id;

    CSI_UTILITY_GRP.Get_impacted_item_instances
           (
             p_api_version           => p_api_version
            ,p_commit                => okc_api.g_false
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => fnd_api.g_valid_level_full
            ,x_txn_inst_tbl          => l_txn_inst_tbl
            ,p_txn_oks_rec           => l_txn_rec
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_Count
            ,x_msg_data              => x_msg_Data
           );


-- Delete all the rows in temp table

  delete from oks_instance_k_dtls_temp;


--insert all the instances returned returned by IB API

 INSERT INTO oks_instance_k_dtls_temp (parent_id,instance_id)
  values(p_instance_id,p_instance_id);

/* FORALL i in 1..l_txn_inst_tbl(1).instance_tbl.count */
/* cgopinee bugfix for bug 9289886*/
 FORALL i IN indices OF l_txn_inst_tbl(1).instance_tbl
  INSERT INTO oks_instance_k_dtls_temp (parent_id,instance_id)
  values(p_instance_id,l_txn_inst_tbl(1).instance_tbl(i));

END POPULATE_CHILD_INSTANCES;


PROCEDURE GET_CONTRACTS(p_api_version         IN  Number,
                        p_init_msg_list       IN  Varchar2 Default OKC_API.G_FALSE,
                        p_instance_id         IN  NUMBER,
                        p_validate_yn         IN  VARCHAR2 ,
                        x_msg_Count           OUT NOCOPY  Number,
                        x_msg_Data            OUT NOCOPY  Varchar2,
                        x_return_status       OUT NOCOPY  Varchar2)
IS

  l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Coverage_For_Prod_Sch';
  l_count              NUMBER := 0;
  l_flag               VARCHAR2(2);
  l_rec_count                 NUMBER := 1;
  l_return_status     VARCHAR2(1);
  l_ent_contracts      OKS_ENTITLEMENTS_PUB.output_tbl_ib;
  l_inp_rec            OKS_ENTITLEMENTS_PUB.input_rec_ib;
  i NUMBER := 1;
  j NUMBER := 1;
  x NUMBER  := 1;

    k_number_tbl   VAR120_TBL_TYPE ;
    k_modifier_tbl    VAR120_TBL_TYPE ;
    k_id_tbl       num_TBL_TYPe;
    k_line_num_tbl    VAR150_TBL_TYPE ;
    k_line_id_tbl       num_TBL_TYPe;
    k_cov_level_type_tbl VAR300_TBL_TYPE;
    k_cov_level_name_tbl VAR300_TBL_TYPE;
    k_serv_type_tbl      VAR300_TBL_TYPE;
    k_serv_name_tbl     VAR300_TBL_TYPE;
    k_serv_line_id       num_TBL_TYPe;
    k_line_status       VAR90_TBL_TYPE;
    k_line_start_date   DATE_TBL_TYPE;
    k_line_end_date     DATE_TBL_TYPE;
    k_line_amount    num_TBL_TYPe;
    k_line_curr     VAR150_TBL_TYPE ;
    k_line_trm_date DATE_TBL_TYPE;


    Cursor line_details(p_covered_line_id VARCHAR2, p_service_line_id VARCHAR2) IS
      Select tl.line_number|| '. '||sl.line_number line_number,
       lst.name cov_level_type,
       oks_ib_util_pvt.get_covlvl_name(sli.jtot_object1_code,
                                       sli.object1_id1,
                                       sli.object1_id2
                                       ) cov_level_name,
       tlst.name service_type,
       sts.meaning status,
       sl.start_date,
       sl.end_date,
       (NVL(sl.price_negotiated,0)+NVL(ksl.tax_amount,0)) price_negotiated,
       sl.currency_code ,
       sl.date_terminated
     from okc_k_lines_b sl,
      okc_k_lines_b tl,
      okc_statuses_v sts,
      okc_k_items sli,
      okc_line_styles_v lst,
      okc_line_styles_v tlst,
      oks_k_lines_b  ksl
    where sl.id = p_covered_line_id
    and sl.sts_code=sts.code
    and sl.lse_id = lst.id
    and tl.lse_id  = tlst.id
    and sl.id = sli.cle_id
    and ksl.cle_id = sl.id
    and tl.id = p_service_line_id;


BEGIN

--call entitlements api to get the contracts
    l_inp_rec.product_id      := p_instance_id;
    l_inp_rec.validate_flag   := nvl(p_validate_yn,'N');

    OKS_ENTITLEMENTS_PUB.GET_CONTRACTS( p_api_version => 1.0,
                                       p_init_msg_list => 'T',
                                       p_inp_rec => l_inp_rec,
                                       x_return_status => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       x_ent_contracts => l_ent_contracts);
   i:= l_ent_contracts.FIRST;

   WHILE  i is not null LOOP
       OPEN line_details(l_ent_contracts(i).CovLvl_Line_Id,l_ent_contracts(i).service_line_id);
       FETCH line_details  into
               k_line_num_tbl(j),k_cov_level_type_tbl(j),k_cov_level_name_tbl(j),k_serv_type_tbl(j),
               k_line_status(j),k_line_start_date(j),k_line_end_date(j),k_line_amount(j),k_line_curr(j),
               k_line_trm_date(j);

       CLOSE line_details;

       k_number_tbl(j)         := l_ent_contracts(i).contract_number;
       k_modifier_tbl(j)       := l_ent_contracts(i).contract_number_modifier;
       k_id_tbl(j)             := l_ent_contracts(i).contract_id;
       k_line_id_tbl(j)        := l_ent_contracts(i).CovLvl_Line_Id;
	  --304974183043424478303663115769271900942;
       k_serv_name_tbl(j)      := l_ent_contracts(i).service_name;
       k_serv_line_id(j)       := l_ent_contracts(i).service_line_id;

       i :=l_ent_contracts.next(i);
       j:=j+1;
   END LOOP;
--delete records in the table
delete  OKS_INSTANCE_CONTRACTS_TEMP;
--insert into table
 FORALL j in 1..l_ent_contracts.count
   INSERT INTO OKS_INSTANCE_CONTRACTS_TEMP
            (CONTRACT_NUMBER          ,
             CONTRACT_NUMBER_MODIFIER ,
             CHR_ID                   ,
             LINE_NUMBER              ,
             COVERED_LINE_ID          ,
             COVERED_LEVEL_TYPE       ,
             COVERED_LEVEL_NAME       ,
             SERVICE_TYPE             ,
             SERVICE_NAME             ,
             SERVICE_LINE_ID          ,
             STATUS_MEANING           ,
             START_DATE              ,
             END_DATE                ,
             AMOUNT                  ,
             CURRENCY_CODE       ,
             DATE_TERMINATED)
   VALUES
         ( k_number_tbl(j)       ,
           k_modifier_tbl(j)       ,
           k_id_tbl(j)             ,
           k_line_num_tbl(j)       ,
           k_line_id_tbl(j)        ,
           k_cov_level_type_tbl(j) ,
           k_cov_level_name_tbl(j) ,
           k_serv_type_tbl (j)        ,
           k_serv_name_tbl(j)      ,
           k_serv_line_id(j)       ,
           k_line_status(j)        ,
           k_line_start_date(j)    ,
           k_line_end_date(j)      ,
           k_line_amount(j)    ,
           k_line_curr(j)      ,
           k_line_trm_date(j)   );

commit;

END GET_CONTRACTS ;

PROCEDURE create_item_instance
 (
    p_api_version           IN     NUMBER,
    p_commit                IN     VARCHAR2,
    p_init_msg_list         IN     VARCHAR2,
    p_validation_level      IN     NUMBER,
    p_instance_rec          IN OUT NOCOPY   instance_rec,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
 ) IS

    lp_instance_rec  csi_datastructures_pub.instance_rec;
    lp_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    lp_party_tbl             csi_datastructures_pub.party_tbl;
    lp_account_tbl           csi_datastructures_pub.party_account_tbl;
    lp_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    lp_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
    lp_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
    lp_txn_rec              csi_datastructures_pub.transaction_rec;

BEGIN

--Assign instance information
    lp_instance_rec.EXTERNAL_REFERENCE          := p_instance_rec.EXTERNAL_REFERENCE;
    lp_instance_rec.INVENTORY_ITEM_ID           := p_instance_rec.INVENTORY_ITEM_ID;
    lp_instance_rec.VLD_ORGANIZATION_ID         := p_instance_rec.VLD_ORGANIZATION_ID;
    lp_instance_rec.INVENTORY_REVISION          := p_instance_rec.INVENTORY_REVISION;
    lp_instance_rec.SERIAL_NUMBER               := p_instance_rec.SERIAL_NUMBER;
    lp_instance_rec.LOT_NUMBER                  := p_instance_rec.LOT_NUMBER;
    lp_instance_rec.QUANTITY                    := p_instance_rec.QUANTITY;
    lp_instance_rec.UNIT_OF_MEASURE             := p_instance_rec.UNIT_OF_MEASURE;
    lp_instance_rec.ACTIVE_START_DATE           := p_instance_rec.ACTIVE_START_DATE;
    lp_instance_rec.LOCATION_TYPE_CODE          := p_instance_rec.LOCATION_TYPE_CODE;
    lp_instance_rec.LOCATION_ID                 := p_instance_rec.LOCATION_ID;
    lp_instance_rec.INSTALL_DATE                := p_instance_rec.INSTALL_DATE;
    lp_instance_rec.CONTEXT                     := p_instance_rec.CONTEXT;
    lp_instance_rec.ATTRIBUTE1                  := p_instance_rec.ATTRIBUTE1;
    lp_instance_rec. ATTRIBUTE2                 := p_instance_rec.ATTRIBUTE2;
    lp_instance_rec.ATTRIBUTE3                  := p_instance_rec.ATTRIBUTE3;
    lp_instance_rec.ATTRIBUTE4                  := p_instance_rec.ATTRIBUTE4;
    lp_instance_rec.ATTRIBUTE5                  := p_instance_rec.ATTRIBUTE5;
    lp_instance_rec.ATTRIBUTE6                  := p_instance_rec.ATTRIBUTE6;
    lp_instance_rec.ATTRIBUTE7                  := p_instance_rec.ATTRIBUTE7;
    lp_instance_rec.ATTRIBUTE8                  := p_instance_rec.ATTRIBUTE8;
    lp_instance_rec.ATTRIBUTE9                  := p_instance_rec.ATTRIBUTE9;
    lp_instance_rec.ATTRIBUTE10                 := p_instance_rec.ATTRIBUTE10;
    lp_instance_rec.ATTRIBUTE11                 := p_instance_rec.ATTRIBUTE11;
    lp_instance_rec.ATTRIBUTE12                 := p_instance_rec.ATTRIBUTE12;
    lp_instance_rec.ATTRIBUTE13                 := p_instance_rec.ATTRIBUTE13;
    lp_instance_rec.ATTRIBUTE14                 := p_instance_rec.ATTRIBUTE14;
    lp_instance_rec.ATTRIBUTE15                 := p_instance_rec.ATTRIBUTE15;
    lp_instance_rec.INSTALL_LOCATION_TYPE_CODE  := p_instance_rec.INSTALL_LOCATION_TYPE_CODE;
    lp_instance_rec.INSTALL_LOCATION_ID         := p_instance_rec.INSTALL_LOCATION_ID;
    IF p_instance_rec.CALL_CONTRACTS = 'N' THEN
       lp_instance_rec.CALL_CONTRACTS           := 'F';
    ELSE
       lp_instance_rec.CALL_CONTRACTS           := 'T';
    END IF;
--  lp_instance_rec.CALL_CONTRACTS              := p_instance_rec.CALL_CONTRACTS;

--Populate owner party info
    lp_party_tbl(1).party_source_table      :=  'HZ_PARTIES';
    lp_party_tbl(1).party_id                :=  p_instance_rec.PARTY_ID;
    lp_party_tbl(1).relationship_type_code  :=  'OWNER';
    lp_party_tbl(1).contact_flag            :=  'N';
--Populate owner party account info
    lp_account_tbl(1).parent_tbl_index        := 1;
    lp_account_tbl(1).party_account_id        :=  p_instance_rec.ACCOUNT_ID;
    lp_account_tbl(1).relationship_type_code  :=  'OWNER';
--Populate transaction table
    lp_txn_rec.transaction_date := sysdate;
    lp_txn_rec.source_transaction_date := sysdate;
    lp_txn_rec.transaction_type_id:=1;

-- Call IB to create item instance

   CSI_ITEM_INSTANCE_PUB.CREATE_ITEM_INSTANCE(
                p_api_version            =>p_api_version,
                p_commit                 => p_commit,
                p_init_msg_list          =>p_init_msg_list,
                p_instance_rec           => lp_instance_rec,
                p_ext_attrib_values_tbl => lp_ext_attrib_values_tbl,
                p_party_tbl             => lp_party_tbl,
                p_account_tbl           => lp_account_tbl,
                p_pricing_attrib_tbl    => lp_pricing_attrib_tbl,
                p_org_assignments_tbl    => lp_org_assignments_tbl,
                p_asset_assignment_tbl   => lp_asset_assignment_tbl,
                p_txn_rec               => lp_txn_rec,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

               IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                  fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.Create_item_instance',
                    'Csi PAI status = ('||  x_return_status || ')');
               END IF;

  p_instance_rec.instance_id :=lp_instance_rec.instance_id;
  p_instance_rec.instance_number :=lp_instance_rec.instance_number;


 EXCEPTION
 WHEN OTHERS Then
    NULL;

END CREATE_ITEM_INSTANCE;




PROCEDURE CHECK_CONTRACTS_IMPACTED(
    P_Api_Version        IN              NUMBER,
    P_init_msg_list      IN              VARCHAR2 Default OKC_API.G_FALSE,
    P_instance_id        IN              NUMBER,
    p_parent_instance_yn IN              VARCHAR2,
    p_transaction_date   IN              DATE,
    p_new_install_date   IN              DATE,
    P_txn_tbl            IN              txn_tbl_type,
    x_contract_exists_yn OUT NOCOPY      VARCHAR2,
    X_msg_Count          OUT NOCOPY      Number,
    X_msg_Data           OUT NOCOPY      Varchar2,
    x_return_status      OUT NOCOPY      Varchar2) IS

l_contracts_exists VARCHAR2(1) := 'N';

    Cursor idc_contracts IS

    Select  CL.id

   From    OKC_K_ITEMS  KI
          ,OKC_K_HEADERS_ALL_B KH
          ,OKC_K_LINES_B   KL
          ,OKC_K_LINES_B   CL
          ,OKC_STATUSES_b  ST

   Where
        KI.Jtot_Object1_code = 'OKX_CUSTPROD'
   AND   KI.object1_id1 = to_char(p_instance_id)
   And     KI.dnz_chr_id = KH.ID
   And     KH.scs_code in ('WARRANTY')
   And     KI.Cle_id = CL.id
   And     CL.CLE_ID = KL.ID
   And     CL.sts_code = ST.code
   And     ST.ste_code not in ('TERMINATED','CANCELLED')
   And     CL.date_terminated Is Null
   AND     KL.date_terminated is null
--   AND     sysdate between cl.start_date and cl.end_date
   And     KH.template_yn = 'N';

   idc_contracts_REC idc_contracts%rowtype;

    cursor trm_trf_contracts IS
    Select   CL.id
 From    OKC_K_ITEMS   KI
        ,OKC_K_HEADERS_ALL_B KH
        ,OKC_K_LINES_B   CL
         ,OKC_STATUSES_b  ST
Where  KI.Jtot_Object1_code = 'OKX_CUSTPROD'
AND    KI.object1_id1 = to_char(p_instance_id  )
And    KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )
And    KI.Cle_id = CL.id
and   cl.dnz_chr_id = kh.id
And   CL.sts_code = ST.code
And   ST.ste_code not in ('TERMINATED','CANCELLED')
And   CL.date_terminated Is Null
And   KH.template_yn = 'N'
AND     (( cl.end_date >= p_transaction_date)  OR
        (cl.end_date < p_transaction_date
        and not exists (Select 'x'
                        from okc_operation_instances ois,
                        okc_operation_lines opl,
                        okc_class_operations cls,
                        okc_subclasses_b sl
                        where ois.id=opl.oie_id
                        And cls.opn_code in ('RENEWAL','REN_CON')
                        And sl.code= 'SERVICE'
                        And sl.cls_code = cls.cls_code
                        and ois.cop_id = cls.id
                        and object_cle_id=cl.id)));

    cursor trm_trf_contracts1 IS
    Select   CL.id
 From    OKC_K_ITEMS   KI
        ,OKC_K_HEADERS_ALL_B KH
        ,OKC_K_LINES_B   CL
         ,OKC_STATUSES_b  ST
         ,oks_instance_k_dtls_temp temp
Where  KI.Jtot_Object1_code = 'OKX_CUSTPROD'
AND  KI.object1_id1 = to_char(temp.instance_id)
And   KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )
And   KI.Cle_id = CL.id
and cl.dnz_chr_id = kh.id
And   CL.sts_code = ST.code
And   ST.ste_code not in ('TERMINATED','CANCELLED')
And   CL.date_terminated Is Null
And   KH.template_yn = 'N'
AND     (( cl.end_date >= p_transaction_date)  OR
        (cl.end_date < p_transaction_date
        and not exists (Select 'x'
                        from okc_operation_instances ois,
                        okc_operation_lines opl,
                        okc_class_operations cls,
                        okc_subclasses_b sl
                        where ois.id=opl.oie_id
                        And cls.opn_code in ('RENEWAL','REN_CON')
                        And sl.code= 'SERVICE'
                        And sl.cls_code = cls.cls_code
                        and ois.cop_id = cls.id
                        and object_cle_id=cl.id)));

    trm_trf_contracts_rec trm_trf_contracts%rowtype;


    cursor trm_usages_contracts IS
    Select  CL.id
From    OKC_K_ITEMS   KI
       ,OKC_K_HEADERS_ALL_B KH
      ,OKC_K_LINES_B   CL
      ,OKC_STATUSES_B ST
      ,csi_counter_associations CTRASC

where   KI.object1_id1 = to_char(CTRASC.COunter_id)
And     KI.jtot_object1_code = 'OKX_COUNTER'
And     ctrasc.source_object_id = p_instance_id
And     ctrasc.source_object_code = 'CP'
and     kh.id=ki.dnz_chr_id
And     KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )
And     KH.template_yn = 'N'
And     KI.Cle_id = CL.id
And     CL.sts_code = ST.code
And     ST.ste_code not in ('TERMINATED','CANCELLED','ENTERED')
And     CL.date_terminated Is Null
AND     (( cl.end_date >= p_transaction_date)  OR
        (cl.end_date < p_transaction_date
        and not exists (select 'x'
                        from okc_operation_instances ois,
                        okc_operation_lines opl,
                        okc_class_operations cls,
                        okc_subclasses_b sl
                        where ois.id=opl.oie_id
                        And cls.opn_code in ('RENEWAL','REN_CON')
                        And sl.code= 'SERVICE'
                        And sl.cls_code = cls.cls_code
                        and ois.cop_id = cls.id
                        and object_cle_id=cl.id)));

cursor trm_usages_contracts1 IS
    Select  CL.id
From    OKC_K_ITEMS   KI
       ,OKC_K_HEADERS_ALL_B KH
      ,OKC_K_LINES_B   CL
      ,OKC_STATUSES_B ST
      ,csi_counter_associations CTRASC
      ,oks_instance_k_dtls_temp temp
where   KI.object1_id1 = to_char(CTRASC.COunter_id)
And     KI.jtot_object1_code = 'OKX_COUNTER'
And     ctrasc.source_object_id = temp.instance_id
And     ctrasc.source_object_code = 'CP'
and     kh.id=ki.dnz_chr_id
And     KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )
And     KH.template_yn = 'N'
And     KI.Cle_id = CL.id
And     CL.sts_code = ST.code
And     ST.ste_code not in ('TERMINATED','CANCELLED','ENTERED')
And     CL.date_terminated Is Null
AND     (( cl.end_date >= p_transaction_date)  OR
        (cl.end_date < p_transaction_date
        and not exists (select 'x'
                        from okc_operation_instances ois,
                        okc_operation_lines opl,
                        okc_class_operations cls,
                        okc_subclasses_b sl
                        where ois.id=opl.oie_id
                        And cls.opn_code in ('RENEWAL','REN_CON')
                        And sl.code= 'SERVICE'
                        And sl.cls_code = cls.cls_code
                        and ois.cop_id = cls.id
                        and object_cle_id=cl.id)));


     trm_usages_contracts_rec trm_usages_contracts%rowtype;

    cursor spl_upd_contracts IS
    Select    CL.id
   From    OKC_K_ITEMS   KI
          ,OKC_K_HEADERS_ALL_B KH
          ,OKC_K_LINES_B   KL
          ,OKC_K_LINES_B   CL
          ,OKC_STATUSES_b  ST
   Where
         KI.Jtot_Object1_code = 'OKX_CUSTPROD'
   AND   KI.object1_id1 = to_char(p_instance_id)
   And   KI.dnz_chr_id = KH.ID
   And   KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )
   And   KI.Cle_id = CL.id
   And   CL.CLE_ID = KL.ID
   And   CL.sts_code = ST.code
   And   ST.ste_code not in ('TERMINATED','CANCELLED')
   And   CL.date_terminated Is Null
   AND   KL.date_terminated is null
   AND   ((p_transaction_date between cl.start_date and cl.end_date)
   OR    (p_transaction_date <= cl.start_date))
   And   KH.template_yn = 'N';

      spl_upd_contracts_rec spl_upd_contracts%rowtype;
    cursor rin_contracts IS
    Select   cl.id
     From    OKC_K_ITEMS  KI
            ,OKC_K_HEADERS_ALL_B KH
            ,OKC_K_LINES_B   CL
    Where
        KI.Jtot_Object1_code = 'OKX_CUSTPROD'
    AND  KI.object1_id1 = to_char(p_instance_id)
    And   KI.dnz_chr_id = KH.ID
    And   KH.scs_code in ('WARRANTY','SERVICE','SUBSCRIPTION' )
    And   KI.Cle_id = CL.id
    And   CL.date_terminated Is not  Null
    And   KH.template_yn = 'N';

    rin_contracts_rec rin_contracts%rowtype;


  i NUMBER :=1;





 BEGIN

 -- Loop through and figure the operations

  i:= P_txn_tbl.first;

 WHILE i is not null loop

  IF  (P_txn_tbl(i)= 'RIN') THEN
    OPEN rin_contracts;
    FETCH rin_contracts into rin_contracts_rec;
    If rin_contracts%found THEN
      l_contracts_exists := 'Y';
    END IF;
    CLOSE rin_contracts;


  ELSIF  (P_txn_tbl(i) in ('SPL','UPD')) THEN
    OPEN spl_upd_contracts;
    FETCH spl_upd_contracts into spl_upd_contracts_rec;
    If spl_upd_contracts%found THEN
      l_contracts_exists := 'Y';
    END IF;
    CLOSE spl_upd_contracts;

  ELSIF (P_txn_tbl(i) in ('TRF','TRM')) THEN

    if p_parent_instance_yn ='Y' Then
    --populate item instance table
      POPULATE_CHILD_INSTANCES (p_api_version   =>p_api_version,
                                p_init_msg_list=> p_init_msg_list,
                                p_instance_id =>p_instance_id,
                                p_transaction_type => P_txn_tbl(i),
                                x_msg_Count  => X_msg_Count,
                                x_msg_Data  => X_msg_data,
                                x_return_status  =>   x_return_status);
   end if;


    If  p_parent_instance_yn = 'N'
    Then

    OPEN trm_trf_contracts;
    FETCH trm_trf_contracts into trm_trf_contracts_rec;
    If trm_trf_contracts%found THEN
      l_contracts_exists := 'Y';
    END IF;
    CLOSE trm_trf_contracts;

    Else

    OPEN trm_trf_contracts1;
    FETCH trm_trf_contracts1 into trm_trf_contracts_rec;
    If trm_trf_contracts1%found THEN
      l_contracts_exists := 'Y';
    END IF;
    CLOSE trm_trf_contracts1;

    End If;

    IF l_contracts_exists = 'N' AND  P_txn_tbl(i) ='TRM' THEN
    --Also check usages
    If  p_parent_instance_yn = 'N'
    Then
        OPEN trm_usages_contracts;
        FETCH trm_usages_contracts into trm_usages_contracts_rec;
        If trm_usages_contracts%found THEN
          l_contracts_exists := 'Y';
        END IF;
        CLOSE trM_usages_contracts;
    Else
        OPEN trm_usages_contracts1;
        FETCH trm_usages_contracts1 into trm_usages_contracts_rec;
        If trm_usages_contracts1%found THEN
          l_contracts_exists := 'Y';
        END IF;
        CLOSE trM_usages_contracts1;
    END IF;
    End If;

  ELSIF (P_txn_tbl(i) = 'IDC') THEN
    OPEN idc_contracts;
    FETCH idc_contracts into idc_contracts_rec;
    If idc_contracts%found THEN
      l_contracts_exists := 'Y';
    END IF;
    CLOSE idc_contracts;
  END IF;

  IF ((l_contracts_exists = 'Y') OR (P_txn_tbl(i) not in ('UPD','IDC'))) THEN
    EXIT;
  END IF;

  i := P_txn_tbl.next(i);


 END LOOP;

      x_contract_exists_yn:= l_contracts_exists;
      x_return_status := 'S';
 END CHECK_CONTRACTS_IMPACTED;


END OKS_IBINT_PUB;

/
