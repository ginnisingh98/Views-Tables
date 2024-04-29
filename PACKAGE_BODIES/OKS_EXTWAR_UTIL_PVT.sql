--------------------------------------------------------
--  DDL for Package Body OKS_EXTWAR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_EXTWAR_UTIL_PVT" AS
/* $Header: OKSRUTLB.pls 120.19 2007/12/24 06:35:52 rriyer ship $ */
   TYPE War_item_new_rec_type IS RECORD
   (
   War_item_id   NUMBER,
   EFFECTIVITY_DATE  DATE,
   DISABLE_DATE    DATE
   );

   TYPE War_item_new_tbl_type IS TABLE OF War_item_new_rec_type INDEX BY BINARY_INTEGER;


   TYPE war_item_rec_type IS RECORD (
      war_item_id   NUMBER
   );

   TYPE war_item_id_tbl_type IS TABLE OF war_item_rec_type
      INDEX BY BINARY_INTEGER;

------------------------------------
-- GET SALES REPNAME
------------------------------------
/*
Function get_repname (p_party_id number, p_org_id number) Return Varchar2 Is

  l_terrkren_rec      jtf_territory_pub.jtf_kren_rec_type;
  l_resource_type     varchar2(100)  := to_char(null);
  l_role              varchar2(100)  := to_char(null);
  l_return_status     varchar2(1);
  l_msg_count         number;
  l_msg_data          varchar2(2000);
  l_terrresource_tbl  jtf_territory_pub.winningterrmember_tbl_type;
  l_user_id           fnd_user.user_id%TYPE;
  l_index             Number;
  i                   Number;
  l_org_id            Number;
  cursor l_sname_csr (p_resid number) is select name from jtf_rs_salesreps where resource_id = p_resid;
  l_sname             Varchar2(240);

Begin
  okc_context.set_okc_org_context;
  l_org_id := okc_context.get_okc_org_id;

  MO_GLOBAL.set_org_context(p_org_id,Null);
  FND_PROFILE.PUT ('ORG_ID',p_org_id);

  l_terrkren_rec.PARTY_ID := p_party_id;

  jtf_terr_oks_pub.get_winningterrmembers
  (
               p_api_version_number => 1.0,
               p_terrkren_rec       => l_terrkren_rec,
               p_resource_type      => l_resource_type,
               p_role               => l_role,
               x_return_status      => l_return_status,      -- OUT NOCOPY
               x_msg_count          => l_msg_count,          -- OUT NOCOPY
               x_msg_data           => l_msg_data,           -- OUT NOCOPY
               x_terrresource_tbl   => l_terrresource_tbl
   );

   l_sname := Null;

   If l_terrresource_tbl.count > 0 Then
      open  l_sname_csr (l_terrresource_tbl(l_terrresource_tbl.FIRST).resource_id);
      Fetch l_sname_csr into l_sname;
      close l_sname_csr;

   End If;

   MO_GLOBAL.set_org_context(l_org_id,Null);
   FND_PROFILE.PUT ('ORG_ID',l_org_id);
   Return l_sname;

Exception
When Others Then
      MO_GLOBAL.set_org_context(l_org_id,Null);
      FND_PROFILE.PUT ('ORG_ID',l_org_id);
      Return Null;
End;
*/
----------------------------------------------------------------------
----------------------------------------------------------------------
 ---                    GET ORDER HEADER ID
----------------------------------------------------------------------
----------------------------------------------------------------------
   FUNCTION get_order_header_id (p_order_line_id IN NUMBER)
      RETURN NUMBER
   IS
-- Cursor for getting the Order header id for a order line
      CURSOR l_ord_csr
      IS
         SELECT header_id
           FROM okx_order_lines_v ol
          WHERE ol.id1 = p_order_line_id;

      l_ord_hdr_id   NUMBER;
   BEGIN
      OPEN l_ord_csr;

      FETCH l_ord_csr
       INTO l_ord_hdr_id;

      IF l_ord_csr%NOTFOUND
      THEN
         CLOSE l_ord_csr;

         RETURN (NULL);
      END IF;

      CLOSE l_ord_csr;

      RETURN (l_ord_hdr_id);
   END get_order_header_id;

----------------------------------------------------------------------
----------------------------------------------------------------------
 ------        GET K HEADER ID
----------------------------------------------------------------------
----------------------------------------------------------------------
   FUNCTION get_k_hdr_id (p_order_hdr_id IN NUMBER)
      RETURN NUMBER
   IS
-- Cursor for Gettin g Contract hader id for a particular Order Header
      CURSOR l_kexists_csr
      IS
         SELECT chr_id
           FROM okc_k_rel_objs
          WHERE object1_id1 = TO_CHAR (p_order_hdr_id);

--     And        JTOT_OBJECT1_CODE = (Select Object_id from JTF_OBJECTS_B where object_code =
--                And        OBJECT1_NAME = 'OE_ORDER_HEADERS';
      l_kexists_rec   l_kexists_csr%ROWTYPE;
   BEGIN
      OPEN l_kexists_csr;

      FETCH l_kexists_csr
       INTO l_kexists_rec;

      IF l_kexists_csr%NOTFOUND
      THEN
         CLOSE l_kexists_csr;

         RETURN (NULL);
      END IF;

      CLOSE l_kexists_csr;

      RETURN (l_kexists_rec.chr_id);
   END get_k_hdr_id;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-------            GET_RULES
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

   /*
   FUNCTION GET_RULES
   (
   p_cle_id      NUMBER,
   p_Category    VARCHAR2,
   p_object_Code VARCHAR2
   )
   Return NUMBER
   Is


   --       Cursor Get_Rule_objectid_Csr Is
   --       Select object1_id1
   --       From   okc_rules_v rul
   --             ,okc_rule_groups_v rgp
   --       Where  rul.rgp_id = rgp.id
   --       And    rule_information_category = p_category
   --       And    jtot_object1_Code = p_object_Code
   --       And    cle_id = p_cle_id;

   -- Fixed Bug# 2281008
   Cursor Get_Rule_objectid_Csr Is
          Select object1_id1
          from okc_rules_v
          where rgp_id = (select id from okc_rule_groups_v where cle_id = p_cle_id)
          And  rule_information_category = p_category;



   l_object_id   VARCHAR2(40);

   BEGIN
        Open Get_Rule_objectid_Csr;
        Fetch Get_Rule_objectid_Csr into l_object_id;
        If Get_Rule_objectid_Csr%notfound Then
           Close Get_Rule_objectid_Csr;
           return(null);
        End If;

        Close Get_Rule_objectid_Csr;
        return(l_object_id);

   END GET_RULES;


   FUNCTION GET_HDR_RULES
   (
   p_chr_id      NUMBER,
   p_Category    VARCHAR2,
   p_object_Code VARCHAR2
   )
   Return NUMBER
   Is

   Cursor Get_Rule_objectid_Csr Is
          Select object1_id1
          From   okc_rules_v rul
                ,okc_rule_groups_v rgp
          Where  rul.rgp_id = rgp.id
          And    rule_information_category = p_category
          And    jtot_object1_Code = p_object_Code
          And    rgp.dnz_chr_id = p_chr_id
          And    rgp.cle_id  Is Null;

   l_object_id   VARCHAR2(40);

   BEGIN
        Open Get_Rule_objectid_Csr;
        Fetch Get_Rule_objectid_Csr into l_object_id;
        If Get_Rule_objectid_Csr%notfound Then
           Close Get_Rule_objectid_Csr;
           return(null);
        End If;

        Close Get_Rule_objectid_Csr;
        return(l_object_id);

   END  GET_HDR_RULES;
   */

   ----------------------------------------------------------------------
----------------------------------------------------------------------
   ---                  GET K ITEM ID
----------------------------------------------------------------------
----------------------------------------------------------------------
   FUNCTION get_k_item_line_id (
      p_customer_product_id   NUMBER,
      p_service_line_id       NUMBER
   )
      RETURN NUMBER
   IS
/*
   Cursor which selects id i.e gets all covered levels for a given
   Contract line (Warr or ExtWar)from COntract lines.
*/
      CURSOR l_serv_csr
      IS
         SELECT ID
           FROM okc_k_lines_v
          WHERE cle_id = p_service_line_id;

--ERROR ADD LSL ID TO LIMIT THE QUERY

      --    Cursor for selecting the Customer product id for a Covered level
      CURSOR l_k_items_csr (p_line_id NUMBER)
      IS
         SELECT object1_id1
           FROM okc_k_items_v
          WHERE cle_id = p_line_id AND jtot_object1_code = g_jtf_cusprod;

      l_serv_rec   l_serv_csr%ROWTYPE;
      l_item_rec   l_k_items_csr%ROWTYPE;
   BEGIN
      FOR l_serv_rec IN l_serv_csr
      LOOP
         FOR l_item_rec IN l_k_items_csr (l_serv_rec.ID)
         LOOP
            IF l_item_rec.object1_id1 = p_customer_product_id
            THEN
               RETURN (l_serv_rec.ID);
            END IF;
         END LOOP;
      END LOOP;

      RETURN (NULL);
   END get_k_item_line_id;

/*----------------------------------------------------------------------

PROCEDURE   : GET_K_LINE_ID
DESCRIPTION :
INPUT       : service order line id
              header id
              service start date
              service end date
              customer product id
OUTPUT      : service line id in x_line_id
              return status in x_return_status

----------------------------------------------------------------------*/
   PROCEDURE get_k_line_id (
      p_service_id          IN              NUMBER,
      p_k_hdr_id            IN              NUMBER,
      p_service_startdate   IN              DATE,
      p_service_enddate     IN              DATE,
      x_status              OUT NOCOPY      CHAR,
      x_line_id             OUT NOCOPY      NUMBER,
      p_cust_product_id     IN              NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2
   )
   IS
-- Cursor gets all the contract lines for a given contract header

      --  gets all the contract lines for a given contract header
      CURSOR l_serv_csr (p_object_id NUMBER)
      IS
         SELECT ki.cle_id line_id
           FROM okc_k_items ki
          WHERE ki.dnz_chr_id = p_k_hdr_id
            AND ki.object1_id1 = TO_CHAR (p_object_id)
            AND ki.jtot_object1_code = g_jtf_warr;

              /*Select Kl.id
              From  OKC_K_LINES_B kl
                   ,OKC_K_ITEMS ki
              Where kl.dnz_chr_id = p_K_hdr_Id
              And   kl.lse_id in (14,19)
              And   ki.cle_id = kl.id
              And   ki.object1_id1 = to_char(p_object_id)
              And   ki.jtot_object1_code in (G_JTF_Warr,G_JTF_Extwar)
              And   trunc(p_service_startdate) >= trunc(kl.Start_Date)
              And   trunc(p_service_enddate) <= trunc(kl.end_date)  ;
      */
      CURSOR l_cov_lvl_csr (p_line_id NUMBER, p_object_id NUMBER)
      IS
         SELECT 'x'
           FROM okc_k_lines_b kl, okc_k_items ki
          WHERE ki.cle_id = kl.ID
            AND ki.jtot_object1_code = 'OKX_CUSTPROD'
            AND kl.lse_id IN (25, 18)
            AND kl.cle_id = p_line_id
            AND ki.object1_id1 = TO_CHAR (p_object_id);

      l_serv_rec        l_serv_csr%ROWTYPE;
      l_found           BOOLEAN              := FALSE;
      l_line_id         NUMBER;
      l_return_status   VARCHAR2 (1)         := okc_api.g_ret_sts_success;
      l_object_id       VARCHAR2 (1);
      l_object          VARCHAR2 (1);
   BEGIN
      x_status := 'N';
      l_return_status := okc_api.g_ret_sts_success;

      FOR l_line_rec IN l_serv_csr (p_service_id)
      LOOP
         l_object_id := NULL;

         OPEN l_cov_lvl_csr (l_line_rec.line_id, p_cust_product_id);

         FETCH l_cov_lvl_csr
          INTO l_object_id;

         CLOSE l_cov_lvl_csr;

         IF l_object_id IS NOT NULL
         THEN
            x_status := 'D';
            RAISE g_exception_halt_validation;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END get_k_line_id;

/*----------------------------------------------------------------------

PROCEDURE   : GET_K_ORDER_DETAILS
DESCRIPTION : This procedure is to get details from contract details form
INPUT       : Order line id
OUTPUT      : renewal info in l_renewal_rec

----------------------------------------------------------------------*/
   PROCEDURE get_k_order_details (
      p_order_line_id   IN              NUMBER,
      l_renewal_rec     OUT NOCOPY      renewal_rec_type
   )
   IS
      CURSOR l_chr_csr
      IS
         SELECT chr_id, renewal_type, po_required_yn, renewal_pricing_type,
                markup_percent, price_list_id1, line_renewal_type,
                link_chr_id, contact_id, site_id, email_id, phone_id, fax_id,
                billing_profile_id   --new parameter added -vigandhi (May29-02)
                ,RENEWAL_APPROVAL_FLAG  --Bug# 5173373
           FROM oks_k_order_details_v
          WHERE order_line_id1 = TO_CHAR (p_order_line_id);

     -- Fix for bug# 4690982

     CURSOR c_Chr(c_CHR_ID IN NUMBER) IS
       SELECT Id
         FROM OKC_K_HEADERS_B CHR
             ,OKC_STATUSES_B  CST
        WHERE CHR.STS_CODE = CST.CODE
          AND CHR.DATE_TERMINATED IS NULL
          AND CST.STE_CODE IN ( 'ACTIVE', 'SIGNED')
          AND CHR.ID = c_CHR_ID;

     l_link_chr_id  NUMBER;

     --Fix for bug# 4690982

   BEGIN

     OPEN l_chr_csr;
     FETCH l_chr_csr INTO l_renewal_rec;
     CLOSE l_chr_csr;

     -- Fix for bug# 4690982

     IF l_Renewal_Rec.Link_Chr_Id IS NOT NULL THEN

       OPEN c_Chr(c_CHR_ID  => l_Renewal_Rec.Link_Chr_Id);
       FETCH c_Chr INTO l_link_chr_id;
       CLOSE c_Chr;

       IF l_link_chr_id IS NULL THEN
          FND_FILE.PUT_LINE (FND_FILE.LOG, 'OKS_EXTWAR_UTIL_PVT.get_k_order_details : LINK CHR ID - '
                                           ||TO_CHAR(l_Renewal_Rec.Link_Chr_Id)
                                           ||'is TERMINATED or CANCELLED');
       END IF;

       l_Renewal_Rec.Link_Chr_Id := l_link_chr_id;

     END IF;

     -- Fix for bug# 4690982

   END;

/************************************************************************
    Function to round the amount based on Fnd_currency set up
    Input parameter  --   Amount
    Output Parameter --   Precision Amount -- Hari 03/07/2001
************************************************************************/
   FUNCTION round_currency_amt (p_amount IN NUMBER, p_currency_code IN VARCHAR2)
      RETURN NUMBER
   IS
      CURSOR fnd_cur
      IS
         SELECT minimum_accountable_unit, PRECISION, extended_precision
           FROM fnd_currencies
          WHERE currency_code = p_currency_code;

      l_mau   fnd_currencies.minimum_accountable_unit%TYPE;
      l_sp    fnd_currencies.PRECISION%TYPE;
      l_ep    fnd_currencies.extended_precision%TYPE;
   BEGIN
      OPEN fnd_cur;

      FETCH fnd_cur
       INTO l_mau, l_sp, l_ep;

      CLOSE fnd_cur;

      IF l_mau IS NOT NULL
      THEN
         IF l_mau < 0.00001
         THEN
            RETURN (ROUND (p_amount, 5));
         ELSE
            RETURN (ROUND (p_amount / l_mau) * l_mau);
         END IF;
      ELSIF l_sp IS NOT NULL
      THEN
         IF l_sp > 5
         THEN
            RETURN (ROUND (p_amount, 5));
         ELSE
            RETURN (ROUND (p_amount, l_sp));
         END IF;
      ELSE
         RETURN (ROUND (p_amount, 5));
      END IF;
   END round_currency_amt;

/************************************************************************
    Procedure to strip the credit card of Blank spaces
    Input parameter  --   Credit Card
    Output Parameter --   Stripped Credit card  -- Hari 2/22/2001
************************************************************************/
   PROCEDURE strip_white_spaces (
      p_credit_card_num   IN              VARCHAR2,
      p_stripped_cc_num   OUT NOCOPY      VARCHAR2
   )
   IS
      TYPE character_tab_typ IS TABLE OF CHAR (1)
         INDEX BY BINARY_INTEGER;

      len_credit_card_num   NUMBER            := 0;
      l_cc_num_char         character_tab_typ;
   BEGIN
      SELECT LENGTH (p_credit_card_num)
        INTO len_credit_card_num
        FROM DUAL;

      FOR i IN 1 .. len_credit_card_num
      LOOP
         SELECT SUBSTR (p_credit_card_num, i, 1)
           INTO l_cc_num_char (i)
           FROM DUAL;

         IF ((l_cc_num_char (i) >= '0') AND (l_cc_num_char (i) <= '9'))
         THEN
            -- Numeric digit. Add to stripped_number and table.
            p_stripped_cc_num := p_stripped_cc_num || l_cc_num_char (i);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END strip_white_spaces;

/*----------------------------------------------------------------------

PROCEDURE   : CHECK_SERVICE_DUPLICATE
DESCRIPTION : This procedure is to check the duplicate service ordered.
INPUT       : Order line id
              service order line id
              Service start date
              service end date
OUTPUT      : return status 'S' if success
              duplicate service status
----------------------------------------------------------------------*/
   PROCEDURE check_service_duplicate (
      p_order_line_id         IN              NUMBER,
      p_serv_id               IN              NUMBER,
      p_customer_product_id   IN              NUMBER,
      p_serv_start_date       IN              DATE,
      p_serv_end_date         IN              DATE,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_service_status        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_khdr_csr (p_order_hdr_id NUMBER)
      IS
         SELECT chr_id
           FROM okc_k_rel_objs
          WHERE object1_id1 = TO_CHAR (p_order_hdr_id)
            AND jtot_object1_code = 'OKX_ORDERHEAD';

--Added for bug# 5382119

CURSOR c_Service_Dup(c_order_hdr_id IN VARCHAR2
                    ,c_warr_item_id IN VARCHAR2
                    ,c_instance_id  IN VARCHAR2) IS
       SELECT /*+ leading (kii)  use_nl (kii rel kl kiw)
                index(kiw okc_k_items_n1) */  'D'
       FROM    Okc_k_items kii
              ,Okc_k_rel_objs rel
              ,Okc_k_lines_b kl
              ,Okc_k_items kiw
       WHERE   rel.object1_id1 = c_order_hdr_id
       AND     rel.jtot_object1_code = 'OKX_ORDERHEAD'
       AND     kiw.dnz_chr_id = rel.chr_id
       AND     kiw.object1_id1 = c_warr_item_id
       AND     kiw.jtot_object1_code = G_JTF_WARR
       AND     kl.cle_id = kiw.cle_id
       AND     kl.lse_id IN (18,25)
       AND     kii.cle_id = kl.id
       AND     kii.jtot_object1_code = 'OKX_CUSTPROD'
       AND     kii.object1_id1 = c_instance_id
       AND     kii.dnz_chr_id = rel.chr_id;

--Added for bug# 5382119

      l_return_status     VARCHAR2 (1)  := okc_api.g_ret_sts_success;
      l_order_hdr_id      NUMBER        := NULL;
      l_chr_id            NUMBER;
      l_service_line_id   NUMBER;
      l_cle_status        CHAR;
      l_item_cle_id       NUMBER;
      l_warr_flag         VARCHAR2 (1);
      l_object_name       VARCHAR2 (40);

      l_service_dup     VARCHAR2(30);

   BEGIN

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module_current || '.CHECK_SERVICE_DUPLICATE.begin',
                            'Order Line Id = '
                         || p_order_line_id
                         || ',Service Id = '
                         || p_serv_id
                         || ',Customer Product Id = '
                         || p_customer_product_id
                         || ',Service start date = '
                         || p_serv_start_date
                         || ',Service End date = '
                         || p_serv_end_date
                        );
      END IF;

      x_return_status := l_return_status;
      l_order_hdr_id := get_order_header_id (p_order_line_id);

      IF l_order_hdr_id IS NULL
      THEN
         x_service_status := NULL;
         l_return_status := okc_api.g_ret_sts_error;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                               g_module_current
                            || '.CHECK_SERVICE_DUPLICATE.ERROR',
                            'Order Header Id NULL'
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              'OKS_INVD_ORD_LINE_ID',
                              'LINE_ID',
                              p_order_line_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

-- Modified for bug# 5382119

--    x_service_status := 'N';
--    l_return_status := okc_api.g_ret_sts_success;

     l_service_dup := 'N';

     OPEN c_service_dup(c_order_hdr_id => to_char(l_Order_hdr_id)
                       ,c_warr_item_id => to_char(p_Serv_Id)
                       ,c_instance_id  => to_char(p_customer_product_id));
     FETCH c_service_dup INTO l_service_dup;
     CLOSE c_service_dup;

     x_Service_Status := NVL(l_service_dup,'N');

--    --bug #2317981
--
--      FOR l_hdr_rec IN l_khdr_csr (l_order_hdr_id)
--      LOOP
--         get_k_line_id (p_cust_product_id        => p_customer_product_id,
--                        p_service_id             => p_serv_id,
--                       p_k_hdr_id               => l_hdr_rec.chr_id,
--                        p_service_startdate      => p_serv_start_date,
--                        p_service_enddate        => p_serv_end_date,
--                        x_status                 => l_cle_status,
--                        x_line_id                => l_service_line_id,
--                        x_return_status          => l_return_status
--                       );
--
--         -- to be confirmed
--         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
--         THEN
--            fnd_log.STRING (fnd_log.level_event,
--                               g_module_current
--                            || '.CHECK_SERVICE_DUPLICATE.Internal_Call.after',
--                               'Get_K_Line_Id(Return status = '
--                            || l_return_status
--                            || ', Duplicate Service Line = '
--                            || l_cle_status
--                            || ', Service Line Id = '
--                            || l_service_line_id
--                            || ')'
--                           );
--         END IF;
--
--         x_service_status := l_cle_status;
--
--         IF l_cle_status = 'D'
--         THEN
--            l_return_status := okc_api.g_ret_sts_success;
--            RAISE g_exception_halt_validation;
--         END IF;
--
--         IF NOT l_return_status = okc_api.g_ret_sts_success
--         THEN
--            l_return_status := okc_api.g_ret_sts_unexp_error;
--            okc_api.set_message (g_app_name, 'OKS_PROC_GET_K_LINE_ID');
--            RAISE g_exception_halt_validation;
--         END IF;
--      END LOOP;
--

   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.CHECK_SERVICE_DUPLICATE.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;

         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END check_service_duplicate;

/*----------------------------------------------------------------------

PROCEDURE   : GET_WAR_ITEM_ID
DESCRIPTION : This procedure is to get the warranty item ids.
INPUT       : product item id
              common bill sequence id
OUTPUT      : return status 'S' if successful
              warranty item ids in x_war_item_tbl
----------------------------------------------------------------------*/
   PROCEDURE get_war_item_id (
      p_inventory_item_id    IN              NUMBER,
      p_datec                IN              DATE,
      x_common_bill_seq_id   OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_war_item_tbl         OUT NOCOPY      war_item_id_tbl_type
   )
   IS
      l_comm_bill_seq_id   NUMBER;
      l_ptr2               BINARY_INTEGER;
      l_return_status      VARCHAR2 (1)   := okc_api.g_ret_sts_success;

      CURSOR c_war_items_csr (c_bill_seq_id NUMBER)
      IS
         SELECT   bic.component_item_id war_item_id
             FROM bom_inventory_components bic     --OKX_INV_COMPONENTS_V bic
            WHERE bic.bill_sequence_id = c_bill_seq_id
              AND EXISTS (
                     SELECT 'Component is a Warranty'
                       FROM okx_system_items_v mtl
                      WHERE mtl.id2 = okc_context.get_okc_organization_id
                        AND mtl.id1 = bic.component_item_id
                        AND mtl.vendor_warranty_flag = 'Y')
              AND TRUNC (p_datec) >= TRUNC (bic.effectivity_date)
              AND TRUNC (p_datec) <=
                               NVL (TRUNC (bic.disable_date), TRUNC (p_datec))
         ORDER BY bic.component_item_id;

      CURSOR bill_seq_csr
      IS
         SELECT common_bill_sequence_id
           FROM bom_bill_of_materials                --OKX_BILL_OF_MATERIALS_V
          WHERE organization_id = okc_context.get_okc_organization_id
            AND assembly_item_id = p_inventory_item_id
            AND alternate_bom_designator IS NULL;
   BEGIN
      x_return_status := 'S';

      OPEN bill_seq_csr;

      FETCH bill_seq_csr
       INTO l_comm_bill_seq_id;

      IF bill_seq_csr%NOTFOUND
      THEN
         CLOSE bill_seq_csr;

         RAISE g_exception_halt_validation;
      END IF;

      CLOSE bill_seq_csr;

      x_common_bill_seq_id := l_comm_bill_seq_id;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_WAR_ITEM_ID.after bill_seq_csr',
                         'Common bill Sequence Id =' || x_common_bill_seq_id
                        );
      END IF;

      l_ptr2 := 1;

      FOR c_war_items_rec IN c_war_items_csr (l_comm_bill_seq_id)
      LOOP
         x_war_item_tbl (l_ptr2).war_item_id := c_war_items_rec.war_item_id;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.GET_WAR_ITEM_ID.loop c_war_items_csr',
                               'War Item Id('
                            || l_ptr2
                            || ')'
                            || '='
                            || x_war_item_tbl (l_ptr2).war_item_id
                           );
         END IF;

         l_ptr2 := l_ptr2 + 1;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_module_current || '.GET_WAR_ITEM_ID.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_war_item_id;

/*----------------------------------------------------------------------

PROCEDURE   : GET_WAR_DUR_PER
DESCRIPTION : This procedure is to get warranty duration, attached
              coverage template id.
INPUT       : product inventory item id,
              warranty inventory item id,
              common bill sequence id,
              transaction date
OUTPUT      : coverage id,
              warranty duration, uom code
              retun status in x_return_status

----------------------------------------------------------------------*/
   PROCEDURE get_war_dur_per (
      p_prod_inv_item_id   IN              NUMBER,
      p_war_inv_item_id    IN              NUMBER,
      p_war_date           IN              DATE,
      p_comm_bill_seq_id   IN              NUMBER,
      x_duration           OUT NOCOPY      NUMBER,
      x_uom_code           OUT NOCOPY      VARCHAR2,
      x_cov_sch_id         OUT NOCOPY      NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2
   )
   IS
      l_war_date          DATE;
      l_com_bill_seq_id   NUMBER;
      l_return_status     VARCHAR2 (1) := okc_api.g_ret_sts_success;

      CURSOR bom_dtls_csr
      IS
         SELECT bic.component_quantity, b.primary_uom_code,
                b.coverage_schedule_id coverage_template_id
           FROM mtl_system_items_b_kfv b,            --okx_system_items_v mtl,
                bom_inventory_components bic        --okx_inv_components_v bic
          WHERE bic.component_item_id = b.inventory_item_id
            AND b.organization_id = okc_context.get_okc_organization_id
            AND bic.bill_sequence_id = p_comm_bill_seq_id
            AND bic.component_item_id = p_war_inv_item_id
            AND TRUNC (l_war_date) >= TRUNC (bic.effectivity_date)
            AND TRUNC (l_war_date) <=
                         NVL (TRUNC (bic.disable_date), TRUNC (l_war_date) + 1)
            -- fix bug 2458473
            AND b.vendor_warranty_flag = 'Y'
            AND ROWNUM < 2;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;
      l_war_date := NVL (p_war_date, SYSDATE);

      OPEN bom_dtls_csr;

      FETCH bom_dtls_csr
       INTO x_duration, x_uom_code, x_cov_sch_id;

      IF bom_dtls_csr%NOTFOUND
      THEN
         CLOSE bom_dtls_csr;

         l_return_status := okc_api.g_ret_sts_unexp_error;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING
                     (fnd_log.level_error,
                      g_module_current || '.GET_WAR_DUR_PER.ERROR',
                      'Bom_dtl_csr not Found: Mising Duration And Coverage  '
                     );
         END IF;

         okc_api.set_message (g_app_name, 'MISSING_DUR_AND_COVERAGE');
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE bom_dtls_csr;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_WAR_DUR_PER.After bom_dtls_csr',
                         'Warranty Duration' || x_duration || ':'
                         || x_uom_code
                        );
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_module_current || '.GET_WAR_DUR_PER.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_war_dur_per;

/*----------------------------------------------------------------------

PROCEDURE   : GET_WARRANTY_INFO
DESCRIPTION : This procedure is to get the information regarding attached
              warranties to an instance defined in BOM
INPUT       : Inventory item id
              Customer product id
              Shipped date
              Installation date
OUTPUT      : Warranty details in x_warranty_tbl
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_warranty_info (
      p_prod_item_id          IN              NUMBER,
      p_customer_product_id   IN              NUMBER,
      x_return_status         OUT NOCOPY      VARCHAR2,
      p_ship_date             IN              DATE,
      p_installation_date     IN              DATE,
      x_warranty_tbl          OUT NOCOPY      war_tbl
   )
   IS
      l_warranty_tbl       war_item_new_tbl_type;
      l_ptr                INTEGER;
      l_comm_bill_seq_id   NUMBER;
      l_return_status      VARCHAR2 (1)          := okc_api.g_ret_sts_success;
      l_ship_date          DATE;
      l_ship_flag          VARCHAR2 (1);
      l_start_delay        NUMBER;
      p_date               DATE;

      CURSOR get_ship_csr
      IS
         SELECT service_starting_delay
           FROM mtl_system_items_b_kfv
          WHERE inventory_item_id = p_prod_item_id
            AND organization_id = okc_context.get_okc_organization_id;

      CURSOR get_ship_flag_csr
      IS
         SELECT DECODE (ol.actual_shipment_date,
                        NULL, 'N',
                        'Y'
                       ) shipped_flag
           FROM csi_item_instances csi, oe_order_lines_all ol
          WHERE csi.instance_id = p_customer_product_id
            AND csi.last_oe_order_line_id = ol.line_id;

  /* fix for bug#6047047 -- fp of bug#5939487 */
     Cursor  C_war_items_csr(C_bill_seq_id NUMBER)  Is
        Select bic.component_item_id war_item_id,bic.effectivity_date,bic.disable_date
        From   BOM_INVENTORY_COMPONENTS bic --OKX_INV_COMPONENTS_V bic
        Where  bic.bill_sequence_id = C_bill_seq_id
        And    exists
                  (
                   Select 'Component is a Warranty'
                   From   OKX_SYSTEM_ITEMS_V mtl
                   Where  mtl.id2 = okc_context.get_okc_organization_id
                   And    mtl.id1 = bic.component_item_id
                   And    mtl.vendor_warranty_flag = 'Y'
                   )
          Order by bic.component_item_id;

     Cursor  Bill_Seq_Csr Is
        Select   common_bill_sequence_id
        From     BOM_BILL_OF_MATERIALS --OKX_BILL_OF_MATERIALS_V
        Where    organization_id = okc_context.get_okc_organization_id
        And      assembly_item_id = P_prod_item_id
        And      alternate_bom_designator is Null;

/* end of fix for bug#6047047-fp of bug#5939487 */

      l_get_date_rec       get_ship_flag_csr%ROWTYPE;
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

/* commented for the bug#6047047-fp of bug#5939487
      IF p_prod_item_id IS NULL
      THEN
         x_return_status := okc_api.g_ret_sts_error;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_WARRANTY_INFO.ERROR',
                            'Product Item Id Required'
                           );
         END IF;

         okc_api.set_message (g_app_name, 'OKS_ORG_ID_INV_ID REQUIRED');
         RAISE g_exception_halt_validation;
      END IF;

      OPEN get_ship_csr;

      FETCH get_ship_csr
       INTO l_start_delay;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_WARRANTY_INFO.after get_chip_csr',
                         'Start Delay = ' || l_start_delay
                        );
      END IF;

     IF get_ship_csr%NOTFOUND
      THEN
         CLOSE get_ship_csr;

         l_return_status := okc_api.g_ret_sts_error;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_WARRANTY_INFO.ERROR',
                            'Get_Ship_Csr not Found'
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              'OKS_SHIPFLG_STDELAY_NOT_SET',
                              'P_PROD_ITEM_ID',
                              p_prod_item_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE get_ship_csr;

      IF p_installation_date IS NULL AND p_ship_date IS NULL
      THEN
         l_return_status := okc_api.g_ret_sts_error;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_WARRANTY_INFO.ERROR',
                            'Installation date and Ship Date not Set'
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              'OKS_SHIPFLG_SHIPDT_NOT_SET',
                              'P_ITEM_ID',
                              p_prod_item_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      -- Installation date will be considered first -- vigandhi 04-jun-2002
      IF p_installation_date IS NOT NULL
      THEN
         l_ship_date := p_installation_date;
         p_date := l_ship_date;
      ELSE
         l_ship_date := p_ship_date;
         p_date := NVL (l_start_delay, 0) + l_ship_date;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.GET_WARRANTY_INFO.ship dates',
                         'Ship Date = ' || l_ship_date || 'p_date = '
                         || p_date
                        );
      END IF;

      get_war_item_id (p_inventory_item_id       => p_prod_item_id,
                       p_datec                   => p_date,
                       x_return_status           => l_return_status,
                       x_war_item_tbl            => l_warranty_tbl,
                       x_common_bill_seq_id      => l_comm_bill_seq_id
                      );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                            g_module_current
                         || '.GET_WARRANTY_INFO.Internal_call.after',
                            ' Get_War_Item_Id(Return status = '
                         || l_return_status
                         || 'Count ='
                         || l_warranty_tbl.COUNT
                         || ')'
                        );
      END IF;

      IF l_warranty_tbl.COUNT = 0
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      IF NOT l_warranty_tbl.COUNT = 0
      THEN
         l_ptr := l_warranty_tbl.FIRST;

         LOOP
            get_war_dur_per
                 (p_prod_inv_item_id      => p_prod_item_id,
                  p_comm_bill_seq_id      => l_comm_bill_seq_id,
                  p_war_inv_item_id       => l_warranty_tbl (l_ptr).war_item_id,
                  x_duration              => x_warranty_tbl (l_ptr).duration_quantity,
                  x_uom_code              => x_warranty_tbl (l_ptr).duration_period,
                  x_cov_sch_id            => x_warranty_tbl (l_ptr).coverage_schedule_id,
                  p_war_date              => p_date,
                  x_return_status         => l_return_status
                 );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_module_current
                               || '.GET_WARRANTY_INFO.Internal_call.after',
                                  ' Get_War_Dur_Per(Return status = '
                               || l_return_status
                               || ')'
                              );
            END IF;

            IF NOT l_return_status = okc_api.g_ret_sts_success
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            x_warranty_tbl (l_ptr).service_item_id :=
                                            l_warranty_tbl (l_ptr).war_item_id;
            x_warranty_tbl (l_ptr).warranty_start_date := TRUNC (p_date);
            x_warranty_tbl (l_ptr).warranty_end_date :=
               TRUNC
                  (okc_time_util_pub.get_enddate
                      (p_start_date      => x_warranty_tbl (l_ptr).warranty_start_date,
                       p_duration        => x_warranty_tbl (l_ptr).duration_quantity,
                       p_timeunit        => x_warranty_tbl (l_ptr).duration_period
                      )
                  );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                                  g_module_current
                               || '.GET_WARRANTY_INFO.Warranty details:',
                                  'start Date = '
                               || x_warranty_tbl (l_ptr).warranty_start_date
                               || ',End date = '
                               || x_warranty_tbl (l_ptr).warranty_end_date
                               || ',Duration = '
                               || x_warranty_tbl (l_ptr).duration_quantity
                               || ',Period = '
                               || x_warranty_tbl (l_ptr).duration_period
                              );
            END IF;

            -- Fixed bug# 2414184 -12Jun2002
            IF x_warranty_tbl (l_ptr).warranty_end_date IS NULL
            THEN
               IF fnd_log.level_error >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_error,
                                     g_module_current
                                  || '.GET_WARRANTY_INFO.ERROR',
                                  'Null Warranty End Date'
                                 );
               END IF;

               okc_api.set_message (g_app_name, 'OKS_END_DT_DUR_REQUIRED');
               l_return_status := okc_api.g_ret_sts_error;
               RAISE g_exception_halt_validation;
            END IF;

            EXIT WHEN (l_ptr = l_warranty_tbl.LAST);
            l_ptr := l_warranty_tbl.NEXT (l_ptr);
         END LOOP;
      END IF;
 */

 /* New code for the bug#6047047 - fp of bug#5939487 */
 -- Added to check the warranty item associated to the item even before checking the start delay in Inventory. --

      If p_prod_item_id is Null then
           x_return_status := OKC_API.G_RET_STS_ERROR;
           IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.ERROR','Product Item Id Required');
           END IF;
           OKC_API.set_message(G_APP_NAME,'OKS_ORG_ID_INV_ID REQUIRED');
           Raise G_EXCEPTION_HALT_VALIDATION;
      End If;

      Open  Bill_Seq_Csr;
      Fetch Bill_Seq_Csr into l_comm_bill_seq_id;
      Close bill_seq_csr;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_WAR_ITEM_ID.after bill_seq_csr','Common bill Sequence Id ='
           || l_Comm_bill_Seq_ID);
      END IF;

     open c_war_items_csr(l_comm_bill_seq_id);
     fetch c_war_items_csr bulk collect into l_warranty_tbl;
     close c_war_items_csr;

 IF l_warranty_tbl.COUNT > 0 Then

      Open Get_Ship_Csr;
      Fetch Get_Ship_Csr into l_start_delay;
      Close Get_ship_Csr;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.after get_chip_csr',
           'Start Delay = '||l_start_delay );
      END IF;

      If p_installation_date Is Null AND p_ship_date Is Null Then
                     l_return_status := OKC_API.G_RET_STS_ERROR;
                     IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                          fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.ERROR','Installation date and Ship Date not Set');
                     END IF;
                     OKC_API.set_message(G_APP_NAME,'OKS_SHIPFLG_SHIPDT_NOT_SET','P_ITEM_ID',p_prod_item_id);
                     Raise G_EXCEPTION_HALT_VALIDATION;
      End If;

      -- Installation date will be considered first -- vigandhi 04-jun-2002

      If p_installation_date Is Not Null Then
           l_ship_date := p_installation_date;
           P_date := l_ship_date;
      Else
           l_ship_date := p_ship_date;
           P_date := Nvl(l_start_delay,0) + l_ship_date;

      End If;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.ship dates',
           'Ship Date = '||l_ship_date || 'p_date = '|| p_date );
      END IF;

      l_ptr := l_warranty_tbl.FIRST;

      Loop

         IF  (trunc(p_date) >= trunc(l_warranty_tbl(l_ptr).EFFECTIVITY_DATE ))
              And (trunc(p_date) <= nvl(trunc(l_warranty_tbl(l_ptr).disable_date),trunc(p_date))) Then

                Get_War_Dur_Per
                (
                  P_prod_inv_item_id   =>  P_prod_item_id,
                  P_comm_bill_seq_id   =>  l_comm_bill_seq_id,
                  P_war_inv_item_id    =>  l_warranty_tbl(l_ptr).war_item_id,
                  X_duration           =>  x_warranty_tbl(l_ptr).duration_Quantity,
                  X_uom_code           =>  x_warranty_tbl(l_ptr).Duration_period,
                  X_cov_sch_id         =>  x_warranty_tbl(l_ptr).Coverage_schedule_id,
                  P_war_date           =>  p_date,
                  X_return_status      =>  l_return_status
                ) ;


              IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.Internal_call.after',
                         ' Get_War_Dur_Per(Return status = '||l_return_status ||')');
              END IF;

              If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
                 Raise G_EXCEPTION_HALT_VALIDATION;
              End If;

              x_warranty_tbl(l_ptr).Service_item_id       :=  l_warranty_tbl(l_ptr).war_item_id;
              x_warranty_tbl(l_ptr).warranty_start_date   :=  trunc(p_date);
              x_warranty_tbl(l_ptr).warranty_end_date     :=  trunc(okc_time_util_pub.get_enddate
                                                               (
                                                                 p_start_date => X_warranty_tbl(l_ptr).warranty_start_date ,
                                                                 p_duration => X_warranty_tbl(l_ptr).Duration_Quantity,
                                                                 p_timeunit => X_warranty_tbl(l_ptr).Duration_period
                                                               ));


              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.Warranty details:',
                     'start Date = '||X_warranty_tbl(l_ptr).warranty_start_date
                  || ',End date = '|| X_warranty_tbl(l_ptr).Warranty_end_date
                  || ',Duration = '|| X_warranty_tbl(l_ptr).Duration_Quantity
                  || ',Period = '|| X_warranty_tbl(l_ptr).Duration_period);
              END IF;

               -- Fixed bug# 2414184 -12Jun2002
               If x_warranty_tbl(l_ptr).warranty_end_date Is Null Then
                        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                          fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.GET_WARRANTY_INFO.ERROR','Null Warranty End Date');
                        END IF;
                        OKC_API.set_message(G_APP_NAME,'OKS_END_DT_DUR_REQUIRED');
                        l_return_status := OKC_API.G_RET_STS_ERROR;
                        RAISE G_EXCEPTION_HALT_VALIDATION;
               End If;

           END IF;

              Exit When (l_ptr = l_warranty_tbl.LAST);

              l_ptr := l_Warranty_tbl.NEXT(l_ptr);

           End Loop;

 END IF;

 -- End of New code --

   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_module_current
                            || '.GET_WARRANTY_INFO.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_warranty_info;

/*----------------------------------------------------------------------

PROCEDURE   : GET_CONTRACT_HEADER_INFO
DESCRIPTION : This procedure is to get the header information details
              for service/item ordered from OM
INPUT       : Order Line id
              Customer product id
              Caller - IB
OUTPUT      : Header details in x_header_rec
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_contract_header_info (
      p_order_line_id   IN              NUMBER,
      p_cp_id           IN              NUMBER,
      p_caller          IN              VARCHAR2,
      x_order_error     OUT NOCOPY      VARCHAR2,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_header_rec      OUT NOCOPY      header_rec_type
   )
   IS
      CURSOR l_ord_hdr_csr (p_hdr_id NUMBER)
      IS
         SELECT oh.order_number,
		oh.org_id,
		oh.ordered_date,
                oh.price_list_id,
		oh.agreement_id,
		oh.cust_po_number,
                oh.invoicing_rule_id,
		oh.accounting_rule_id,
                oh.payment_term_id,
		oh.sold_to_org_id,
		oh.ship_to_org_id,
                oh.invoice_to_org_id,
		oh.invoice_to_contact_id,
                oh.sold_to_contact_id,
		oh.deliver_to_contact_id,
                oh.payment_amount,
		oh.transactional_curr_code,
                oh.tax_exempt_number,
		oh.tax_exempt_flag,
		oh.conversion_rate,
                oh.conversion_type_code,
		oh.conversion_rate_date,
                oh.salesrep_id,
                               -- Modified for 120 CC Extn Projct
                NULL credit_card_expiration_date, -- OH.CREDIT_CARD_EXPIRATION_DATE
                NULL credit_card_number, -- OH.CREDIT_CARD_NUMBER
                                        --
                  --Added in R12 by rsu
                oh.tax_exempt_reason_code,
                oh.tax_point_code
                  --
         FROM   oe_order_headers_all oh
          WHERE oh.header_id = p_hdr_id;

      CURSOR l_party_csr (l_cust_id NUMBER)
      IS
         SELECT party_id
           FROM hz_cust_accounts
          WHERE cust_account_id = l_cust_id;

      CURSOR l_cust_csr (l_inv_org_id NUMBER)
      IS
         SELECT ca.cust_account_id
           FROM hz_cust_acct_sites_all ca, hz_cust_site_uses_all cs
          WHERE ca.cust_acct_site_id = cs.cust_acct_site_id
            AND cs.site_use_id = l_inv_org_id;

--
-- Fix for bug# 4756579 (JVARGHES)
--
--Cursor l_tax_csr(p_no Varchar2,p_cust_id Number) Is
--                  Select TAX_EXEMPTION_ID id1
--                  from   RA_TAX_EXEMPTIONS_ALL
--                 where  CUSTOMER_EXEMPTION_NUMBER = p_no
--                  and    customer_id  = p_cust_id
--                  and    status  in ('MANUAL','PRIMARY','UNAPPROVED');
--
      CURSOR l_tax_csr (p_no VARCHAR2, p_cust_id NUMBER)
      IS
         SELECT tax_exemption_id id1
           FROM zx_exemptions
          WHERE exempt_certificate_number = p_no
            AND cust_account_id = p_cust_id
            AND exemption_status_code IN ('MANUAL', 'PRIMARY', 'UNAPPROVED');

--
--
      CURSOR l_tax_flag_csr (p_id2 VARCHAR2)
      IS
         SELECT lv.lookup_code
           FROM fnd_lookup_values lv
          WHERE lv.LANGUAGE = USERENV ('LANG')
            AND security_group_id =
                   fnd_global.lookup_security_group (lv.lookup_type,
                                                     lv.view_application_id
                                                    )
            AND lv.lookup_type = 'TAX_CONTROL_FLAG'
            AND lv.lookup_code = p_id2;

      CURSOR l_contact_csr (p_hdr_id NUMBER)
      IS
         SELECT ship_to_contact_id
           FROM oe_order_headers_all
          WHERE header_id = p_hdr_id;

      l_ord_hdr_rec         l_ord_hdr_csr%ROWTYPE;
      l_return_status       VARCHAR2 (1)          := okc_api.g_ret_sts_success;
      l_warranty_tbl        war_tbl;
      p_hdr_id              NUMBER;
      l_party_id            NUMBER;
      l_tax_id              NUMBER;
--    l_tax_id2             VARCHAR2 (40);
      l_tax_status          VARCHAR2 (40);
      l_cust_id             NUMBER;
      l_clflag              NUMBER;
      l_contact_id          NUMBER;
      l_upd_rec             oks_rep_pvt.repv_rec_type;
   BEGIN
      x_return_status := l_return_status;
      p_hdr_id := get_order_header_id (p_order_line_id);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_HEADER_INFO.order header',
                         'Order header id = ' || p_hdr_id
                        );
      END IF;

      IF p_hdr_id IS NULL
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                               g_module_current
                            || '.GET_CONTRACT_HEADER_INFO.ERROR: ',
                            'Header Id NULL for line ' || p_order_line_id
                           );
         END IF;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_INVD_ORD_LINE_ID',
                              'LINE_ID',
                              p_order_line_id
                             );

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_INVD_ORD_LINE_ID');
            fnd_message.set_token (token      => 'LINE_ID',
                                   VALUE      => p_order_line_id
                                  );
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         RAISE g_exception_halt_validation;
      END IF;

      OPEN l_ord_hdr_csr (p_hdr_id);

      FETCH l_ord_hdr_csr
       INTO l_ord_hdr_rec;

      IF l_ord_hdr_csr%NOTFOUND
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                               g_module_current
                            || '.GET_CONTRACT_HEADER_INFO.ERROR: ',
                            'Header record not found for header ' || p_hdr_id
                           );
         END IF;

         CLOSE l_ord_hdr_csr;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_ORD_HDR_DTLS_NOT_FOUND',
                              'ORDER_HEADER_ID',
                              p_hdr_id
                             );

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_ORD_HDR_DTLS_NOT_FOUND');
            fnd_message.set_token (token      => 'ORDER_HEADER_ID',
                                   VALUE      => p_hdr_id
                                  );
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE l_ord_hdr_csr;

      -- Added in R12 by rsu
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_HEADER_INFO.order header',
                         'After querying the header'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_HEADER_INFO.order header',
                            'l_Ord_hdr_rec.tax_point_code: '
                         || l_ord_hdr_rec.tax_point_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_HEADER_INFO.order header',
                            'l_Ord_hdr_rec.tax_exempt_reason_code: '
                         || l_ord_hdr_rec.tax_exempt_reason_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_HEADER_INFO.order header',
                            'l_Ord_hdr_rec.tax_exempt_number: '
                         || l_ord_hdr_rec.tax_exempt_number
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_HEADER_INFO.order header',
                            'l_Ord_hdr_rec.tax_exempt_flag: '
                         || l_ord_hdr_rec.tax_exempt_flag
                        );
      END IF;

      --
      l_contact_id := NULL;

      OPEN l_contact_csr (p_hdr_id);

      FETCH l_contact_csr
       INTO l_contact_id;

      CLOSE l_contact_csr;

      OPEN l_party_csr (l_ord_hdr_rec.sold_to_org_id);

      FETCH l_party_csr
       INTO l_party_id;

      IF l_party_csr%NOTFOUND
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                               g_module_current
                            || '.GET_CONTRACT_HEADER_INFO.ERROR: ',
                               'Party Record Not Found For Cust Id '
                            || l_ord_hdr_rec.sold_to_org_id
                           );
         END IF;

         CLOSE l_party_csr;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_PARTY_ID_NOT_FOUND',
                              'CUSTOMER_ID',
                              l_ord_hdr_rec.sold_to_org_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE l_party_csr;

/* -- Commented out for fixing 120 bug# 4899249.

     --  Bug# 1619850 : get tax id using Invoice to org, and then Sold to org and
     --                 and then Ship to org
     --                 Invoice and ship to Org are at the site level must
     --                 access okx_cust_site_uses all
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_CONTRACT_HEADER_INFO.tax calculation',
          'Tax Exemption Number = '||l_ord_hdr_rec.tax_exempt_number ||
          'Tax Exemption Flag = '||l_ord_hdr_rec.tax_exempt_flag ||
          'Invoice To Org Id = ' ||l_ord_hdr_rec.invoice_to_org_id ||
          'Sold To Org Id = '||l_ord_hdr_rec.sold_to_org_id ||
          'Ship To Org Id = '||l_ord_hdr_rec.ship_to_org_id);
     END IF;


      If l_ord_hdr_rec.tax_exempt_number Is Not Null Then
          l_clflag := 1;

          Open l_cust_csr(l_ord_hdr_rec.invoice_to_org_id);
          Fetch l_cust_csr into l_cust_id;

          If l_cust_csr%found then
              Open l_tax_Csr(l_ord_hdr_rec.tax_exempt_number,l_cust_id);
              Fetch l_tax_Csr into l_tax_id;

              If l_tax_Csr%found then
                 l_clflag := 0;
              end if;

              close l_tax_Csr;

          End if;

          Close l_cust_csr;

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_CONTRACT_HEADER_INFO.clflag status',
                'For Invoice Org '|| l_clflag);
          END IF;


          If l_clflag = 1 THEN

              Open l_tax_Csr(l_ord_hdr_rec.tax_exempt_number,l_ord_hdr_rec.Sold_to_Org_id);
              Fetch l_tax_Csr into l_tax_id;

              If l_tax_Csr%found then
                 l_clflag := 0;
              end if;

              close l_tax_csr;

          End if;

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_CONTRACT_HEADER_INFO.clflag status',
                'For Sold Org '|| l_clflag);
          END IF;

          l_cust_id := NULL;

          If l_clflag = 1 THEN
              Open l_cust_csr(l_ord_hdr_rec.ship_to_org_id);
              Fetch l_cust_csr into l_cust_id;

              If l_cust_csr%found then
                  Open l_tax_Csr(l_ord_hdr_rec.tax_exempt_number,l_cust_id);
                  Fetch l_tax_Csr into l_tax_id;

                  If l_tax_Csr%found then
                     l_clflag := 0;
                  end if;

                  close l_tax_Csr;

              End if;

              Close l_cust_csr;

          End if;

          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.GET_CONTRACT_HEADER_INFO.clflag status',
                'For hip Org '|| l_clflag);
          END IF;

        If l_clflag = 1 THEN
                IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                     fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.GET_CONTRACT_HEADER_INFO.ERROR',
                      'Tax Exemption Record Not Found');
                END IF;
                l_return_status := OKC_API.G_RET_STS_ERROR;
                OKC_API.set_message(G_APP_NAME,'OKS_TAX_DTLS_NOT_FOUND');
                Raise G_EXCEPTION_HALT_VALIDATION;
          End if;

      End If;

*/ -- Commented out for fixing 120 bug# 4899249.

      /*  Bug 5008188: Commented by vjramali, as the lookup code validation is not required

      IF l_ord_hdr_rec.tax_exempt_flag IS NOT NULL
      THEN
         OPEN l_tax_flag_csr (l_ord_hdr_rec.tax_exempt_flag);

         FETCH l_tax_flag_csr
          INTO l_tax_id2;

         IF l_tax_flag_csr%NOTFOUND
         THEN
            IF fnd_log.level_error >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_error,
                                  g_module_current
                               || '.GET_CONTRACT_HEADER_INFO.ERROR',
                               ' Tax Exempt Flag Record Not Found '
                              );
            END IF;

            CLOSE l_tax_flag_csr;

            l_return_status := okc_api.g_ret_sts_error;
            --OKC_API.set_message(G_APP_NAME,'OKS_TAX_DTLS_NOT_FOUND');
            RAISE g_exception_halt_validation;
         END IF;

         CLOSE l_tax_flag_csr;
      END IF;
*/
--    IF l_ord_hdr_rec.tax_exempt_number IS NULL AND l_tax_id2 = 'E'

      -- Ensure that a tax_exempt_number is specified if the order is tax exempted (Bug 5008188)
      IF     l_ord_hdr_rec.tax_exempt_number IS NULL
         AND l_ord_hdr_rec.tax_exempt_flag = 'E'
      THEN
         l_tax_status := NULL;
      ELSE
         l_tax_status := l_ord_hdr_rec.tax_exempt_flag;
      END IF;

      x_header_rec.authoring_org_id := l_ord_hdr_rec.org_id;
      x_header_rec.agreement_id := l_ord_hdr_rec.agreement_id;
      x_header_rec.cust_po_number := l_ord_hdr_rec.cust_po_number;
      x_header_rec.invoice_rule_id := l_ord_hdr_rec.invoicing_rule_id;
      x_header_rec.accounting_rule_id := l_ord_hdr_rec.accounting_rule_id;
      x_header_rec.order_hdr_id := p_hdr_id;
      x_header_rec.invoice_to_contact_id := l_ord_hdr_rec.invoice_to_contact_id;
      x_header_rec.currency := l_ord_hdr_rec.transactional_curr_code;
      x_header_rec.party_id := l_party_id;
      x_header_rec.class_code := NULL;
      x_header_rec.bill_to_id := l_ord_hdr_rec.invoice_to_org_id;
      x_header_rec.ship_to_id := l_ord_hdr_rec.ship_to_org_id;
      x_header_rec.price_list_id := l_ord_hdr_rec.price_list_id;
      x_header_rec.hdr_payment_term_id := l_ord_hdr_rec.payment_term_id;
      x_header_rec.hdr_tax_status_flag := l_tax_status;
      x_header_rec.hdr_tax_exemption_id := l_tax_id;
      x_header_rec.hdr_cvn_type := l_ord_hdr_rec.conversion_type_code;
      x_header_rec.hdr_cvn_rate := l_ord_hdr_rec.conversion_rate;
      x_header_rec.hdr_cvn_date := l_ord_hdr_rec.conversion_rate_date;
      x_header_rec.ship_to_contact_id := l_contact_id;
      x_header_rec.salesrep_id := l_ord_hdr_rec.salesrep_id;
      x_header_rec.ccr_number := l_ord_hdr_rec.credit_card_number;
      x_header_rec.ccr_exp_date := l_ord_hdr_rec.credit_card_expiration_date;
      --Added in R12 by rsu
      x_header_rec.tax_classification_code := l_ord_hdr_rec.tax_point_code;
      x_header_rec.exemption_certificate_number := l_ord_hdr_rec.tax_exempt_number;
      x_header_rec.exemption_reason_code := l_ord_hdr_rec.tax_exempt_reason_code;

   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_CONTRACT_HEADER_INFO.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_contract_header_info;

/*----------------------------------------------------------------------

PROCEDURE   : GET_CONTRACT_LINE_INFO
DESCRIPTION : This procedure is to get the details to create a warranty
              line for an item ordered from OM
INPUT       : Order Line id
              Customer product id
              Inventory item id
OUTPUT      : Line details in x_line_rec
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_contract_line_info (
      p_order_line_id   IN              NUMBER,
      p_cp_id           IN              NUMBER,
      p_product_item    IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_line_rec        OUT NOCOPY      line_rec_type
   )
   IS
      CURSOR l_ord_line_csr (l_line_id NUMBER)
      IS
         SELECT ol.org_id,
		ol.line_number,
		ol.sold_to_org_id,
                ol.ship_to_org_id,
		ol.invoice_to_org_id,
		ol.commitment_id,
                -- added in R12 by rsu
                ol.tax_exempt_number,
		ol.tax_exempt_reason_code,
                ol.tax_point_code,
		ol.tax_exempt_flag,
		ol.header_id
                --
         FROM   oe_order_lines_all ol
          WHERE ol.line_id = l_line_id;

      CURSOR l_segment_csr (p_org_id NUMBER)
      IS
         SELECT t.description NAME,
		b.concatenated_segments description
           FROM mtl_system_items_b_kfv b,
		mtl_system_items_tl t
          WHERE
		b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_product_item
            AND b.organization_id = okc_context.get_okc_organization_id;

      l_return_status   VARCHAR2 (1)             := okc_api.g_ret_sts_success;
      l_warranty_tbl    war_tbl;
      l_ptr             BINARY_INTEGER;
      l_ord_line_rec    l_ord_line_csr%ROWTYPE;
      l_segment_rec     l_segment_csr%ROWTYPE;
   BEGIN
      x_return_status := l_return_status;

      OPEN l_ord_line_csr (p_order_line_id);

      FETCH l_ord_line_csr
       INTO l_ord_line_rec;

      IF l_ord_line_csr%NOTFOUND
      THEN
         CLOSE l_ord_line_csr;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current
                            || '.GET_CONTRACT_LINE_INFO.ERROR',
                               'l_ord_line_csr not found for line id = '
                            || p_order_line_id
                           );
         END IF;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_ORD_LINE_DTLS_NOT_FOUND',
                              'ORDER_LINE',
                              p_order_line_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE l_ord_line_csr;

      OPEN l_segment_csr (l_ord_line_rec.org_id);

      FETCH l_segment_csr
       INTO l_segment_rec;

      IF l_segment_csr%NOTFOUND
      THEN
         CLOSE l_segment_csr;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current
                            || '.GET_CONTRACT_LINE_INFO.ERROR',
                               'l_segment_csr not found for org id = '
                            || l_ord_line_rec.org_id
                           );
         END IF;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_ITEM_DTLS_NOT_FOUND',
                              'PRODUCT_ITEM',
                              p_product_item
                             );
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE l_segment_csr;

      x_line_rec.srv_segment1 := l_segment_rec.description;
      x_line_rec.srv_desc := l_segment_rec.NAME;
      -- X_Line_rec.k_line_NUMBER    := FND_PROFILE.VALUE('PREFIX_CONTRACT_NUMBER')||l_ord_Line_rec.line_NUMBER||FND_PROFILE.VALUE('SUFFIX_CONTRACT_NUMBER');
      -- X_Line_rec.srv_segment1     := l_segment_rec.name;
      -- X_Line_rec.srv_id           := l_Warranty_tbl(l_ptr).service_item_id;
      -- X_Line_rec.srv_desc         := l_segment_rec.description;
      x_line_rec.ship_to_id := l_ord_line_rec.ship_to_org_id;
      x_line_rec.bill_to_id := l_ord_line_rec.invoice_to_org_id;
      x_line_rec.order_line_id := p_order_line_id;
      x_line_rec.customer_acct_id := l_ord_line_rec.sold_to_org_id;

      -- X_line_rec.commitment_id    := l_ord_line_rec.commitment_id;

      --Added in R12 by rsu
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_LINE_INFO.order line',
                         'After querying the line'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_LINE_INFO.order line',
                            'l_ord_line_rec.tax_point_code: '
                         || l_ord_line_rec.tax_point_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_LINE_INFO.order line',
                            'l_ord_line_rec.tax_exempt_reason_code: '
                         || l_ord_line_rec.tax_exempt_reason_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_LINE_INFO.order line',
                            'l_ord_line_rec.tax_exempt_number: '
                         || l_ord_line_rec.tax_exempt_number
                        );
         fnd_log.STRING (fnd_log.level_statement,
                            g_module_current
                         || '.GET_CONTRACT_LINE_INFO.order line',
                            'l_ord_line_rec.tax_exempt_flag: '
                         || l_ord_line_rec.tax_exempt_flag
                        );
      END IF;

      x_line_rec.tax_classification_code := l_ord_line_rec.tax_point_code;
      x_line_rec.exemption_certificate_number :=
                                              l_ord_line_rec.tax_exempt_number;
      x_line_rec.exemption_reason_code :=
                                         l_ord_line_rec.tax_exempt_reason_code;
      x_line_rec.tax_status := l_ord_line_rec.tax_exempt_flag;
   --
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_CONTRACT_LINE_INFO.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_contract_line_info;

/*----------------------------------------------------------------------

PROCEDURE   : GET_K_SERVICE_LINE
DESCRIPTION : This procedure is to get the details to create a service
              line for an item ordered from OM
INPUT       : Order Line id
              Customer product id
              Shipped date
              Installation date
              Caller -IB
OUTPUT      : Line details in x_line_rec
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_k_service_line (
      p_order_line_id       IN              NUMBER,
      p_cp_id               IN              NUMBER,
      --new parameter added for extwar enhancment Vigandhi
      p_shipped_date        IN              DATE,
      --new parameter added -Vigandhi 04-jun-2002
      p_installation_date   IN              DATE,
      --new parameter added -Vigandhi 04-jun-2002
      p_caller              IN              VARCHAR2,
      x_order_error         OUT NOCOPY      VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_line_rec            OUT NOCOPY      line_rec_type
   )
   IS
--Bug#1696511
      l_start_date          DATE;
      l_end_date            DATE;

--end bug
      CURSOR l_ord_line_csr
      IS
         SELECT ol.inventory_item_id,
		ol.service_start_date,
                ol.service_end_date,
		ol.service_duration,
		ol.service_period,
                ol.org_id, ol.line_number,
		ol.invoice_to_org_id,
                ol.ship_to_org_id,
		ol.unit_selling_price,
                ol.unit_selling_percent,
		ol.fulfilled_quantity,
                ol.invoice_to_contact_id, --Bug#1696511
                ol.service_reference_type_code,
                ol.service_reference_line_id,
                                          --end bug
               --Ordered_Quantity
                ol.order_quantity_uom,
                --22-NOV-2005 mchoudha added for PPC
                pricing_quantity,
		pricing_quantity_uom, --End PPC
                ol.sold_to_org_id,
                ol.invoicing_rule_id,
		ol.accounting_rule_id,
                ol.commitment_id,
		ol.tax_value,
		ol.price_list_id,
                t.description NAME,
		b.concatenated_segments description,
                b.service_starting_delay,
                b.coverage_schedule_id coverage_template_id,
		ol.header_id,
                ol.tax_exempt_number,               -- Bug#5008188 - vjramali
                ol.tax_exempt_reason_code,
                ol.tax_code, ol.tax_exempt_flag      -- End Bug#5008188
           FROM oe_order_lines_all ol,
                mtl_system_items_b_kfv b,
                mtl_system_items_tl t
          WHERE ol.line_id = p_order_line_id
            AND b.inventory_item_id = ol.inventory_item_id
            AND b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.organization_id = okc_context.get_okc_organization_id;

      CURSOR get_csr_order_line_id (p_service_line_id NUMBER)
      IS
         SELECT actual_shipment_date
           FROM oe_order_lines_all
          WHERE line_id = p_service_line_id;

-- Extwarranty cascading
      CURSOR get_warr_dates_csr
      IS
         SELECT MAX (ol.end_date)
           FROM okc_k_items_v ot, okc_k_lines_v ol
          WHERE ot.object1_id1 = TO_CHAR (p_cp_id)
            AND ol.ID = ot.cle_id
            AND ol.lse_id = 18;

      l_ord_line_rec        l_ord_line_csr%ROWTYPE;
      l_return_status       VARCHAR2 (1)          := okc_api.g_ret_sts_success;
      l_inv_id              NUMBER;
      l_war_edt             DATE;
      l_curr_code           VARCHAR2 (15);
      l_line_tax_status     VARCHAR2 (40);
   BEGIN
      x_return_status := l_return_status;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.GET_K_SERVICE_LINE.Order line',
                         ' *************************************************'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.GET_K_SERVICE_LINE.Order line',
                         'Processing Order line id ' || p_order_line_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.GET_K_SERVICE_LINE.Order line',
                         ' '
                        );
      END IF;

      OPEN l_ord_line_csr;

      FETCH l_ord_line_csr
       INTO l_ord_line_rec;

      IF l_ord_line_csr%NOTFOUND
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_K_SERVICE_LINE.ERROR',
                               'l_Ord_line_csr not found for Order Line = '
                            || p_order_line_id
                           );
         END IF;

         CLOSE l_ord_line_csr;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_ORD_LINE_DTLS_NOT_FOUND',
                              'ORDER_LINE',
                              p_order_line_id
                             );

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_ORD_LINE_DTLS_NOT_FOUND');
            fnd_message.set_token (token      => 'ORDER_LINE',
                                   VALUE      => p_order_line_id
                                  );
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE l_ord_line_csr;

      IF     l_ord_line_rec.service_end_date IS NULL
         AND l_ord_line_rec.service_period IS NULL
         AND l_ord_line_rec.service_duration IS NULL
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_K_SERVICE_LINE.ERROR',
                            'End Date, Duration, Period Required '
                           );
         END IF;

         l_return_status := okc_api.g_ret_sts_error;
         x_return_status := l_return_status;
         okc_api.set_message (g_app_name, 'OKS_END_DT_DUR_REQUIRED');

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_END_DT_DUR_REQUIRED');
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         RAISE g_exception_halt_validation;
      END IF;

      l_inv_id := l_ord_line_rec.inventory_item_id;
      --Bug#1696511
      l_start_date := NULL;
      l_end_date := NULL;

      IF l_ord_line_rec.service_reference_type_code IN
                                                ('ORDER', 'CUSTOMER_PRODUCT')
      THEN
         l_start_date := l_ord_line_rec.service_start_date;
         l_end_date := l_ord_line_rec.service_end_date;

         IF l_end_date IS NULL
         THEN
            l_end_date :=
               okc_time_util_pub.get_enddate (l_start_date,
                                              l_ord_line_rec.service_period,
                                              l_ord_line_rec.service_duration
                                             );
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                               g_module_current
                            || '.GET_K_SERVICE_LINE.Service Dates',
                               'Start date = '
                            || l_start_date
                            || ',End date = '
                            || l_end_date
                           );
         END IF;
      END IF;

      -- Extwarr cascading  -Vigandhi
      -- If service start_date is null Ext warr contract will start from existing warr contract end date, but if no warranty contract
      -- is there ext-warr contract will start from installation date/shipped date of the product.
      IF l_start_date IS NULL
      THEN
         OPEN get_warr_dates_csr;

         FETCH get_warr_dates_csr
          INTO l_war_edt;

         --close get_warr_dates_csr;

         --If get_warr_dates_csr%found then
         IF l_war_edt IS NOT NULL
         THEN
            l_start_date := TRUNC (l_war_edt) + 1;
            l_end_date :=
               okc_time_util_pub.get_enddate (l_start_date,
                                              l_ord_line_rec.service_period,
                                              l_ord_line_rec.service_duration
                                             );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING
                        (fnd_log.level_statement,
                            g_module_current
                         || '.GET_K_SERVICE_LINE.Service Dates after cascading',
                            'Start date = '
                         || l_start_date
                         || ',End date = '
                         || l_end_date
                        );
            END IF;
         ELSE
            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING (fnd_log.level_procedure,
                                  g_module_current
                               || '.GET_K_SERVICE_LINE.Install ship Dates',
                                  'Installation_date= '
                               || p_installation_date
                               || ',Ship date = '
                               || p_shipped_date
                              );
            END IF;

            IF p_installation_date IS NOT NULL
            THEN
               l_start_date := TRUNC (p_installation_date);
            ELSE
               l_start_date :=
                    TRUNC (p_shipped_date)
                  + NVL (l_ord_line_rec.service_starting_delay, 0);
            END IF;

            l_end_date :=
               okc_time_util_pub.get_enddate (l_start_date,
                                              l_ord_line_rec.service_period,
                                              l_ord_line_rec.service_duration
                                             );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.STRING
                  (fnd_log.level_statement,
                      g_module_current
                   || '.GET_K_SERVICE_LINE.Service Dates after cascading- no warranty',
                      'Start date = '
                   || l_start_date
                   || ',End date = '
                   || l_end_date
                  );
            END IF;
         END IF;

         CLOSE get_warr_dates_csr;
      END IF;

      IF l_start_date IS NULL
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_K_SERVICE_LINE.ERROR',
                            ' Null Start Date'
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              'OKS_NULL_SDT',
                              'LINE_ID',
                              p_order_line_id
                             );
         l_return_status := okc_api.g_ret_sts_error;

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_NULL_SDT');
            fnd_message.set_token (token      => 'LINE_ID',
                                   VALUE      => p_order_line_id
                                  );
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         RAISE g_exception_halt_validation;
      END IF;

      IF l_end_date IS NULL
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_K_SERVICE_LINE.ERROR',
                            ' Null End Date'
                           );
         END IF;

         okc_api.set_message (g_app_name, 'OKS_END_DT_DUR_REQUIRED');
         l_return_status := okc_api.g_ret_sts_error;

         --mmadhavi
         IF (p_caller = 'OC')
         THEN
            fnd_message.set_name (g_app_name, 'OKS_END_DT_DUR_REQUIRED');
            x_order_error := '#' || fnd_message.get_encoded || '#';
         END IF;

         --mmadhavi
         RAISE g_exception_halt_validation;
      END IF;

      x_line_rec.srv_segment1 := l_ord_line_rec.description;
      x_line_rec.srv_desc := l_ord_line_rec.NAME;
      x_line_rec.srv_sdt := TRUNC (l_start_date);
      x_line_rec.srv_edt := TRUNC (l_end_date);
      --end bug
      --X_Line_rec.Srv_sdt              :=  l_Ord_Line_rec.Service_Start_Date  + NVL(l_Ord_Line_rec.Service_starting_delay,0);
      --X_Line_rec.Srv_edt              :=  l_Ord_Line_rec.Service_End_Date;
      --X_Line_rec.Srv_segment1         :=  l_Ord_Line_rec.NAME;
      --X_Line_rec.srv_Desc             :=  l_Ord_line_rec.Description;
      x_line_rec.srv_id := l_ord_line_rec.inventory_item_id;
      x_line_rec.org_id := l_ord_line_rec.org_id;
      x_line_rec.order_line_id := p_order_line_id;
      x_line_rec.coverage_schd_id := l_ord_line_rec.coverage_template_id;
      x_line_rec.bill_to_id := l_ord_line_rec.invoice_to_org_id;
      x_line_rec.ship_to_id := l_ord_line_rec.ship_to_org_id;
      --Fix for bug 3452190
      x_line_rec.amount :=
         l_ord_line_rec.unit_selling_price * l_ord_line_rec.fulfilled_quantity;
      x_line_rec.unit_selling_price := l_ord_line_rec.unit_selling_price;
      x_line_rec.unit_selling_percent := l_ord_line_rec.unit_selling_percent;
      x_line_rec.customer_acct_id := l_ord_line_rec.sold_to_org_id;
      x_line_rec.invoice_to_contact_id := l_ord_line_rec.invoice_to_contact_id;
      x_line_rec.qty := l_ord_line_rec.fulfilled_quantity;
      x_line_rec.invoicing_rule_id := l_ord_line_rec.invoicing_rule_id;
      x_line_rec.accounting_rule_id := l_ord_line_rec.accounting_rule_id;
      x_line_rec.commitment_id := l_ord_line_rec.commitment_id;
      x_line_rec.tax_amount := l_ord_line_rec.tax_value;
      x_line_rec.ln_price_list_id := l_ord_line_rec.price_list_id;
      --22-NOV-2005 mchoudha added for PPC
      x_line_rec.pricing_quantity := l_ord_line_rec.pricing_quantity;
      x_line_rec.pricing_quantity_uom := l_ord_line_rec.pricing_quantity_uom;
      x_line_rec.order_quantity_uom := l_ord_line_rec.order_quantity_uom;
      --End PPC

      -- Added as part of Bug fix 5008188 by vjramali
      -- Ensure that a tax_exempt_number is specified if the order line is tax exempted (Bug 5008188)
      IF     l_ord_line_rec.tax_exempt_number IS NULL
         AND l_ord_line_rec.tax_exempt_flag = 'E'
      THEN
         l_line_tax_status := NULL;
      ELSE
         l_line_tax_status := l_ord_line_rec.tax_exempt_flag;
      END IF;

      x_line_rec.tax_classification_code := l_ord_line_rec.tax_code;
      x_line_rec.exemption_certificate_number := l_ord_line_rec.tax_exempt_number;
      x_line_rec.exemption_reason_code := l_ord_line_rec.tax_exempt_reason_code;
      x_line_rec.tax_status := l_line_tax_status;
      --

   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_K_SERVICE_LINE.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_k_service_line;

/*----------------------------------------------------------------------

PROCEDURE   : CHECK_IMMEDIATE_SERVICE
DESCRIPTION : This procedure is to get all the contract line details
              for a services ordered for an instance existing in the
              same order
INPUT       : Instance id ,Order line id
OUTPUT      : service details in x_service_tbl
              delayed service status in X_Delayed_Service_Status
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE check_immediate_service (
      p_order_line_id              IN              NUMBER,
      x_service_tbl                OUT NOCOPY      service_tbl,
      x_immediate_service_status   OUT NOCOPY      VARCHAR2,
      x_return_status              OUT NOCOPY      VARCHAR2
   )
   IS
      l_ord_hdr_id        NUMBER;
      l_ptr               INTEGER;
      l_found             BOOLEAN      := TRUE;
      l_order_header_id   NUMBER;
      l_return_status     VARCHAR2 (1) := okc_api.g_ret_sts_success;

      CURSOR l_line_csr (p_ord_hdr_id NUMBER)
      IS
         SELECT line_id, inventory_item_id, service_start_date,
                service_end_date, service_reference_line_id
           FROM oe_order_lines_all
          WHERE header_id = p_ord_hdr_id
            AND service_reference_line_id = p_order_line_id
            AND service_reference_type_code IS NOT NULL;
   BEGIN
      x_return_status := l_return_status;
      l_ord_hdr_id := get_order_header_id (p_order_line_id);

      IF l_ord_hdr_id IS NULL
      THEN
         x_immediate_service_status := 'N';
         l_return_status := okc_api.g_ret_sts_error;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                               g_module_current
                            || '.CHECK_IMMEDIATE_SERVICE.ERROR',
                               'Order Header Id NULL for Order line Id '
                            || p_order_line_id
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              'OKS_INVD_ORD_LINE_ID',
                              'LINE_ID',
                              p_order_line_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      l_ptr := 1;

      FOR l_line_rec IN l_line_csr (l_ord_hdr_id)
      LOOP
         l_order_header_id :=
                   get_order_header_id (l_line_rec.service_reference_line_id);

         IF l_order_header_id = l_ord_hdr_id
         THEN
            l_found := TRUE;
            x_service_tbl (l_ptr).order_line_id := l_line_rec.line_id;
            x_service_tbl (l_ptr).service_item_id :=
                                                 l_line_rec.inventory_item_id;
            x_service_tbl (l_ptr).order_header_id := l_ord_hdr_id;
            x_service_tbl (l_ptr).start_date := l_line_rec.service_start_date;
            x_service_tbl (l_ptr).end_date := l_line_rec.service_end_date;
         END IF;

         l_ptr := l_ptr + 1;
      END LOOP;

      IF l_found = TRUE
      THEN
         x_immediate_service_status := 'Y';
      ELSE
         x_immediate_service_status := 'N';
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.CHECK_IMMEDIATE_SERVICE.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END check_immediate_service;

/*----------------------------------------------------------------------

PROCEDURE   : CHECK_DELAYED_SERVICE
DESCRIPTION : This procedure is to get all the contract line details
              for services ordered for an instance existing in different
              order
INPUT       : Instance id ,Order line id
OUTPUT      : service details in x_service_tbl
              delayed service status in X_Delayed_Service_Status
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE check_delayed_service (
      p_customer_product_id      IN              NUMBER,
      p_order_line_id            IN              NUMBER,
      x_service_tbl              OUT NOCOPY      service_tbl,
      x_delayed_service_status   OUT NOCOPY      VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2
   )
   IS
      l_ord_hdr_id        NUMBER;
      l_ptr               INTEGER;
      l_found             BOOLEAN      := TRUE;
      l_order_header_id   NUMBER;
      l_return_status     VARCHAR2 (1) := okc_api.g_ret_sts_success;

/* --Commented 17-jul-2003
   --Delayed services with ref type ORDER can be picked up
   --by order capture concurrent prog
Cursor  l_line_Csr(p_ord_hdr_id NUMBER) Is
                   Select  line_id
                          ,Service_Start_Date
                          ,Service_End_Date
                          ,Inventory_Item_Id
                          ,Service_Reference_Line_Id
                   From    OE_ORDER_LINES_ALL
                   Where   not HEADER_ID  = p_ord_hdr_id
                   And     Service_reference_type_code = 'ORDER'
                   And     Service_Reference_line_id = p_order_line_id
                   And     Service_Duration is Not Null;
*/
      CURSOR l_line_serv_csr (p_ord_hdr_id NUMBER)
      IS
         SELECT line_id, service_start_date, service_end_date,
                inventory_item_id, service_reference_line_id
           FROM oe_order_lines_all
          WHERE header_id = p_ord_hdr_id
            AND service_reference_type_code = 'CUSTOMER_PRODUCT'
            AND service_reference_line_id = p_customer_product_id
            AND service_duration IS NOT NULL;
   BEGIN
      x_return_status := l_return_status;
      x_delayed_service_status := 'N';
      l_ord_hdr_id := get_order_header_id (p_order_line_id);

      IF l_ord_hdr_id IS NULL
      THEN
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.CHECK_DELAYED_SERVICE.ERROR',
                            'Invalid Order Line Id ' || p_order_line_id
                           );
         END IF;

         x_delayed_service_status := 'N';
         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_INVD_ORD_LINE_ID',
                              'LINE_ID',
                              p_order_line_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

/* --commented 17-jul-2003
      For L_line_rec in L_Line_Csr(l_ord_hdr_id)
      Loop
           l_order_header_id := get_order_header_id(l_line_rec.Service_reference_line_id);
           If l_order_header_id = l_ord_hdr_id then
                  X_Delayed_Service_Status  := 'Y';
                  X_Service_Tbl(l_ptr).order_Line_id   := L_line_rec.line_id;
                  X_Service_Tbl(l_ptr).Srv_ref_line_id := l_line_rec.Service_reference_line_id;
                  X_Service_Tbl(l_ptr).Service_item_id := L_line_rec.Inventory_item_id;
                  X_Service_Tbl(l_ptr).order_header_id := l_ord_hdr_id;
                  X_Service_Tbl(l_ptr).start_date      := l_line_rec.Service_start_date;
                  X_Service_Tbl(l_ptr).end_date        := l_line_rec.Service_End_date;
            End If;
            l_ptr := l_ptr + 1;
       End Loop;
       If l_ptr >  1 Then
              l_ptr := l_ptr + 1;
       Else
              l_ptr := 1;
       End If;
*/
      l_ptr := 1;

      FOR l_line_serv_rec IN l_line_serv_csr (l_ord_hdr_id)
      LOOP
         IF l_line_serv_rec.service_reference_line_id = p_customer_product_id
         THEN
            x_delayed_service_status := 'Y';
            x_service_tbl (l_ptr).order_line_id := l_line_serv_rec.line_id;
            x_service_tbl (l_ptr).service_item_id :=
                                            l_line_serv_rec.inventory_item_id;
            x_service_tbl (l_ptr).order_header_id := l_ord_hdr_id;
            x_service_tbl (l_ptr).start_date :=
                                           l_line_serv_rec.service_start_date;
            x_service_tbl (l_ptr).end_date :=
                                             l_line_serv_rec.service_end_date;
         END IF;

         -- to be discussed about the delayed service
         l_ptr := l_ptr + 1;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.CHECK_DELAYED_SERVICE.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END check_delayed_service;

/*----------------------------------------------------------------------

PROCEDURE   : GET_CONTRACT_DETAILS
DESCRIPTION : This procedure is to get all the contract/covered line
              information covering a particular instance
INPUT       : Instance id ,Transaction type ,Transaction date
OUTPUT      : contract details in x_contract_tbl
              sales credit details in x_sales_credit_tbl_hdr
         and x_sales_credit_tbl_line
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_contract_details (
      p_id                      IN              VARCHAR2,
      p_type                    IN              VARCHAR2,
      p_date                    IN              DATE,
      p_trxn_type               IN              VARCHAR2,
      x_available_yn            OUT NOCOPY      VARCHAR2,
      x_contract_tbl            OUT NOCOPY      contract_tbl_type,
      x_sales_credit_tbl_hdr    OUT NOCOPY      oks_extwarprgm_pvt.salescredit_tbl,
      --mmadhavi 4174921
      x_sales_credit_tbl_line   OUT NOCOPY      oks_extwarprgm_pvt.salescredit_tbl,
      x_return_status           OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR get_hdr_csr (p_code VARCHAR2)
      IS
         SELECT ki.ID, ki.number_of_items, ki.dnz_chr_id, ki.cle_id,
                kl.sts_code, kl.start_date, kl.end_date, kl.lse_id,
                kl.date_terminated, kl.upg_orig_system_ref,
                kl.upg_orig_system_ref_id, kl.price_unit,
                kl.price_negotiated, kl.NAME, kl.item_description,
                kl.line_renewal_type_code, kh.start_date hdr_sdt,
                kh.end_date hdr_edt, kh.sts_code hdr_sts, kh.price_list_id,
                kh.payment_term_id, kh.inv_rule_id, ks.acct_rule_id,
                kh.inv_organization_id, ks.payment_type, ks.inv_trx_type,
                ks.ar_interface_yn, ks.hold_billing, ks.summary_trx_yn,
                kh.authoring_org_id, kh.contract_number, kh.cust_po_number,
                kh.currency_code, kh.conversion_type, kh.conversion_rate,
                kh.conversion_rate_date, kh.conversion_euro_rate,
                kh.scs_code, okl.tax_amount                    -- bug 3736860
                                           ,
                party.object1_id1 party_id
           FROM okc_k_items_v ki,
                okc_k_headers_b kh,
                oks_k_headers_b ks,
                okc_k_lines_v kl,
                oks_k_lines_b okl,
                okc_statuses_v st,
                okc_k_party_roles_b party
          WHERE ki.object1_id1 = p_id
            AND ki.jtot_object1_code = p_code
            AND ki.dnz_chr_id = kh.ID
            AND ks.chr_id(+) = kh.ID                   -- Vigandhi 06-jan-2004
            AND kh.scs_code IN ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
            -- support to subscription category contracts
            AND ki.cle_id = kl.ID
            AND okl.cle_id(+) = kl.ID
            AND kl.sts_code = st.code
            AND st.ste_code NOT IN ('TERMINATED', 'CANCELLED')
            AND kl.date_terminated IS NULL
            AND kh.template_yn = 'N'
--           And     PARTY.chr_id = KH.Id
            AND party.dnz_chr_id = kh.ID                 -- vigandhi 16-mar-05
            AND party.chr_id IS NOT NULL
            -- Added for performance issue 4223824
            AND party.cle_id IS NULL
            AND party.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
            AND party.jtot_object1_code = 'OKX_PARTY';

      CURSOR get_serv_id (p_cleid NUMBER)
      IS
         SELECT object1_id1
           FROM okc_k_items_v
          WHERE cle_id = p_cleid
            AND jtot_object1_code IN (g_jtf_warr, g_jtf_extwar, g_jtf_usage);

      --***
      CURSOR get_line_det_csr (p_hdr_id NUMBER, p_line_id NUMBER)
      IS
         SELECT ol.ID, ol.cle_id, ol.start_date, ol.end_date, ol.NAME,
                ol.item_description, ol.price_negotiated, ol.currency_code,
                ol.line_number, ol.lse_id, ol.inv_rule_id,
                ol.bill_to_site_use_id, ol.ship_to_site_use_id,
                ol.cust_acct_id
--                 ,OL.unit_price
                   --,OL.cle_id_renewed
                , ol.sts_code, oh.contract_number_modifier, kl.acct_rule_id,
                kl.tax_code                                      --Bug#4121175
           FROM okc_k_lines_v ol, oks_k_lines_b kl, okc_k_headers_b oh
          WHERE ol.dnz_chr_id = p_hdr_id
            AND oh.ID = ol.dnz_chr_id
            AND kl.cle_id(+) = ol.ID                   -- Vigandhi 06-Jan-2004
            AND oh.scs_code IN ('WARRANTY', 'SERVICE', 'SUBSCRIPTION')
            -- support to subscription category contracts
            AND ol.ID IN (SELECT okl.cle_id
                            FROM okc_k_lines_v okl
                           WHERE okl.ID = p_line_id AND okl.cle_id IS NOT NULL);

/*Cursor l_serv_Csr(p_serv_id NUMBER) is
           Select  COVERAGE_SCHEDULE_ID coverage_template_id
           From    MTL_SYSTEM_ITEMS_B_KFV -- OKX_SYSTEM_ITEMS_V
           WHere   INVENTORY_ITEM_ID = p_serv_id;
*/
      CURSOR l_serv_csr (p_serv_id NUMBER)
      IS
         SELECT t.description NAME, b.concatenated_segments description,
                b.coverage_schedule_id coverage_template_id
           FROM mtl_system_items_b_kfv b, mtl_system_items_tl t
          WHERE b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.inventory_item_id = p_serv_id
            AND ROWNUM < 2;

-- added cursor for sales_credit -govind
      CURSOR l_sales_credit_csr (p_cle_id NUMBER)
      IS
         SELECT ctc_id, sales_credit_type_id1, PERCENT, sales_group_id
           FROM oks_k_sales_credits_v
          WHERE cle_id = p_cle_id;

      CURSOR l_rel_csr (
         p_line_id       NUMBER,
         p_hdr_id        NUMBER,
         p_object_code   VARCHAR2
      )
      IS
         SELECT object1_id1
           FROM okc_k_rel_objs_v
          WHERE cle_id = p_line_id
            AND chr_id = p_hdr_id
            AND jtot_object1_code = p_object_code;

      CURSOR l_access_csr (p_hdr_id NUMBER)
      IS
         SELECT resource_id, GROUP_ID, access_level
           FROM okc_k_accesses_v
          WHERE chr_id = p_hdr_id;

--mmadhavi bug 4174921
      CURSOR l_sales_credit_hdr_csr (p_chr_id NUMBER)
      IS
         SELECT ctc_id, sales_credit_type_id1, PERCENT, sales_group_id
           FROM oks_k_sales_credits_v
          WHERE chr_id = p_chr_id AND cle_id IS NULL;

--mmadhavi bug 4174921
      p_line_id               NUMBER;
      l_ptr                   NUMBER;
      l_found                 VARCHAR2 (5);
      p_code                  VARCHAR2 (40);
      l_cust_account          VARCHAR2 (40);
      l_serv_id               VARCHAR2 (40);
      l_unit_price            NUMBER;
      l_serv_amount           NUMBER;
      l_coverage_tempid       NUMBER;
      l_chrid                 NUMBER;
      l_return_status         VARCHAR2 (1)   := okc_api.g_ret_sts_success;
      warranty_flag           VARCHAR2 (1);
      l_id                    NUMBER;
      l_org_id                NUMBER;
      l_contract_number       VARCHAR2 (120);
      l_sc_ctr                NUMBER;
      l_flag                  VARCHAR2 (10);
      l_start_delay           NUMBER;
      l_rel_id                NUMBER;
      l_cust_ponum            VARCHAR2 (50);                     --07-May-2003
      l_hdr_currency          VARCHAR2 (15);                     --07-May-2003
      l_ordhdr_id             VARCHAR2 (40);                     --07-May-2003
      l_sts_code              VARCHAR2 (30);                     --17-jul-2003
      l_ste_code              VARCHAR2 (30);                     --17-jul-2003
      l_resource_id           NUMBER;
      l_group_id              NUMBER;
      l_access_level          VARCHAR2 (3);
      l_service_name          VARCHAR2 (240);
      l_service_description   VARCHAR2 (240);
      l_sc_hdr_ctr            NUMBER;
   BEGIN
      x_return_status := l_return_status;

      IF UPPER (p_type) = 'P'
      THEN
         p_code := g_jtf_party;
      ELSIF UPPER (p_type) = 'S'
      THEN
         p_code := g_jtf_covlvl;
      ELSIF UPPER (p_type) = 'C'
      THEN
         p_code := g_jtf_custacct;
      ELSIF UPPER (p_type) = 'CP'
      THEN
         p_code := g_jtf_cusprod;
      END IF;

      l_ptr := 1;

      FOR l_chr_rec IN get_hdr_csr (p_code)
      LOOP
         l_flag := 'F';
         oks_extwarprgm_pvt.get_sts_code (NULL,
                                          l_chr_rec.sts_code,
                                          l_ste_code,
                                          l_sts_code
                                         );

         IF p_trxn_type <> 'IDC'
         THEN
            IF l_chr_rec.lse_id IN (9, 18, 25) AND l_ste_code <> 'EXPIRED'
            THEN
               IF    (    TRUNC (p_date) <=
                             TRUNC (NVL (l_chr_rec.date_terminated,
                                         l_chr_rec.end_date
                                        )
                                   )
                      AND TRUNC (p_date) >= TRUNC (l_chr_rec.start_date)
                     )
                  OR (TRUNC (p_date) <= TRUNC (l_chr_rec.start_date))
               THEN
                  l_flag := 'T';
               END IF;
            END IF;
         ELSE
            IF l_chr_rec.lse_id = 18
            THEN
               l_flag := 'T';
            END IF;
         END IF;

         IF l_flag = 'T'
         THEN
            l_found := 'T';
            l_ordhdr_id := NULL;

            OPEN l_rel_csr (NULL, l_chr_rec.dnz_chr_id, 'OKX_ORDERHEAD');

            FETCH l_rel_csr
             INTO l_ordhdr_id;

            CLOSE l_rel_csr;

            l_group_id := NULL;
            l_resource_id := NULL;
            l_access_level := NULL;

            OPEN l_access_csr (l_chr_rec.dnz_chr_id);

            FETCH l_access_csr
             INTO l_resource_id, l_group_id, l_access_level;

            CLOSE l_access_csr;

--mmadhavi  bug 4174921
            l_sc_hdr_ctr := 0;

            FOR l_sales_credit_hdr_rec IN
               l_sales_credit_hdr_csr (l_chr_rec.dnz_chr_id)
            LOOP
               l_sc_hdr_ctr := l_sc_hdr_ctr + 1;
               x_sales_credit_tbl_hdr (l_sc_hdr_ctr).ctc_id :=
                                                l_sales_credit_hdr_rec.ctc_id;
               x_sales_credit_tbl_hdr (l_sc_hdr_ctr).sales_credit_type_id :=
                                 l_sales_credit_hdr_rec.sales_credit_type_id1;
               x_sales_credit_tbl_hdr (l_sc_hdr_ctr).PERCENT :=
                                               l_sales_credit_hdr_rec.PERCENT;
               x_sales_credit_tbl_hdr (l_sc_hdr_ctr).sales_group_id :=
                                        l_sales_credit_hdr_rec.sales_group_id;
            END LOOP;          -- For l_sales_credit_rec IN l_sales_credit_csr

--mmadhavi bug 4174921
            FOR l_get_line_rec IN get_line_det_csr (l_chr_rec.dnz_chr_id,
                                                    l_chr_rec.cle_id
                                                   )
            LOOP
               l_serv_id := NULL;

               OPEN get_serv_id (l_get_line_rec.ID);

               FETCH get_serv_id
                INTO l_serv_id;

               CLOSE get_serv_id;

               x_contract_tbl (l_ptr).service_inventory_id := l_serv_id;
               -- added sales credit loop -govind
               l_sc_ctr := 0;

               FOR l_sales_credit_rec IN
                  l_sales_credit_csr (l_get_line_rec.ID)
               LOOP
                  l_sc_ctr := l_sc_ctr + 1;
                  x_sales_credit_tbl_line (l_sc_ctr).ctc_id :=
                                                    l_sales_credit_rec.ctc_id;
                  x_sales_credit_tbl_line (l_sc_ctr).sales_credit_type_id :=
                                     l_sales_credit_rec.sales_credit_type_id1;
                  x_sales_credit_tbl_line (l_sc_ctr).PERCENT :=
                                                   l_sales_credit_rec.PERCENT;
                  x_sales_credit_tbl_line (l_sc_ctr).sales_group_id :=
                                            l_sales_credit_rec.sales_group_id;
               END LOOP;       -- For l_sales_credit_rec IN l_sales_credit_csr

               IF l_get_line_rec.lse_id = 19
               THEN
                  x_contract_tbl (l_ptr).warranty_flag := 'E';
               --x_contract_tbl(l_ptr).start_delay   := 0;

               --added Elsif for service  -govind
               ELSIF     l_get_line_rec.lse_id = 1
                     AND l_chr_rec.scs_code = 'SERVICE'
               THEN
                  x_contract_tbl (l_ptr).warranty_flag := 'S';
               --x_contract_tbl(l_ptr).start_delay   := 0;
               ELSIF l_get_line_rec.lse_id = 14
               THEN
                  x_contract_tbl (l_ptr).warranty_flag := 'W';
               --x_contract_tbl(l_ptr).start_delay   := NVL(l_start_delay,0);

               -- support to subscription category contracts
               ELSIF     l_get_line_rec.lse_id = 1
                     AND l_chr_rec.scs_code = 'SUBSCRIPTION'
               THEN
                  x_contract_tbl (l_ptr).warranty_flag := 'SU';
               END IF;

               l_coverage_tempid := NULL;

               OPEN l_serv_csr (x_contract_tbl (l_ptr).service_inventory_id);

               FETCH l_serv_csr
                INTO l_service_name, l_service_description, l_coverage_tempid;

               CLOSE l_serv_csr;

               x_contract_tbl (l_ptr).service_cov_id := l_coverage_tempid;
               x_contract_tbl (l_ptr).service_name := l_service_description;
               x_contract_tbl (l_ptr).service_description := l_service_name;
               l_rel_id := NULL;

               OPEN l_rel_csr (l_chr_rec.cle_id,
                               l_chr_rec.dnz_chr_id,
                               'OKX_ORDERHEAD'
                              );

               FETCH l_rel_csr
                INTO l_rel_id;

               CLOSE l_rel_csr;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.STRING (fnd_log.level_statement,
                                     g_module_current
                                  || '.GET_CONTRACT_DETAILS.After l_rel_csr',
                                  'Service Order line id = ' || l_rel_id
                                 );
               END IF;

               IF l_get_line_rec.contract_number_modifier IS NOT NULL
               THEN
                  x_contract_tbl (l_ptr).cle_id_renewed :=
                                      l_get_line_rec.contract_number_modifier;
               ELSE
                  IF l_rel_id IS NOT NULL
                  THEN
                     x_contract_tbl (l_ptr).cle_id_renewed := NULL;
                  ELSE
                     x_contract_tbl (l_ptr).cle_id_renewed := 'Y';
                  END IF;
               END IF;

               x_contract_tbl (l_ptr).cust_account :=
                                                   l_get_line_rec.cust_acct_id;
               x_contract_tbl (l_ptr).service_unit_price :=
                                                          l_chr_rec.price_unit;
               x_contract_tbl (l_ptr).service_amount :=
                                                    l_chr_rec.price_negotiated;
-- bug 3736860
               x_contract_tbl (l_ptr).service_tax_amount :=
                                                          l_chr_rec.tax_amount;
-- bug 3736860
-- bug 4121175
               x_contract_tbl (l_ptr).tax_code := l_get_line_rec.tax_code;
-- bug 4121175
               x_contract_tbl (l_ptr).service_order_line_id := l_rel_id;
               x_contract_tbl (l_ptr).hdr_id := l_chr_rec.dnz_chr_id;
               x_contract_tbl (l_ptr).hdr_sdt := l_chr_rec.hdr_sdt;
               x_contract_tbl (l_ptr).hdr_edt := l_chr_rec.hdr_edt;
               x_contract_tbl (l_ptr).hdr_sts := l_chr_rec.hdr_sts;
               x_contract_tbl (l_ptr).hdr_org_id := l_chr_rec.authoring_org_id;
               x_contract_tbl (l_ptr).contract_number :=
                                                     l_chr_rec.contract_number;
               x_contract_tbl (l_ptr).cust_po_number :=
                                                      l_chr_rec.cust_po_number;
               x_contract_tbl (l_ptr).header_currency :=
                                                       l_chr_rec.currency_code;
               x_contract_tbl (l_ptr).ord_hdr_id := l_ordhdr_id;
               x_contract_tbl (l_ptr).k_item_id := l_chr_rec.ID;
               x_contract_tbl (l_ptr).service_line_number :=
                                                    l_get_line_rec.line_number;
               x_contract_tbl (l_ptr).cp_qty := l_chr_rec.number_of_items;
               x_contract_tbl (l_ptr).object_line_id := l_chr_rec.cle_id;
               x_contract_tbl (l_ptr).service_line_id := l_get_line_rec.ID;
               x_contract_tbl (l_ptr).service_sdt := l_get_line_rec.start_date;
               x_contract_tbl (l_ptr).service_edt := l_get_line_rec.end_date;
               x_contract_tbl (l_ptr).service_currency :=
                                                  l_get_line_rec.currency_code;
               --X_Contract_tbl(l_ptr).Service_Bill_2_id     := Get_rules(l_get_line_rec.id,'BTO',G_JTF_Billto);
               --X_Contract_tbl(l_ptr).Service_Ship_2_id     := Get_rules(l_get_line_rec.id,'STO',G_JTF_Shipto);
               x_contract_tbl (l_ptr).service_bill_2_id :=
                                            l_get_line_rec.bill_to_site_use_id;
               x_contract_tbl (l_ptr).service_ship_2_id :=
                                            l_get_line_rec.ship_to_site_use_id;
               x_contract_tbl (l_ptr).service_line_number :=
                                                    l_get_line_rec.line_number;
               --X_Contract_tbl(l_ptr).Invoice_rule_id       := l_Get_Line_rec.Object1_id1;
               x_contract_tbl (l_ptr).invoice_rule_id :=
                                                    l_get_line_rec.inv_rule_id;
               x_contract_tbl (l_ptr).accounting_rule_id :=
                                                   l_get_line_rec.acct_rule_id;
               x_contract_tbl (l_ptr).price_list_id := l_chr_rec.price_list_id;
               x_contract_tbl (l_ptr).payment_term_id :=
                                                     l_chr_rec.payment_term_id;
               x_contract_tbl (l_ptr).hdr_acct_rule_id :=
                                                        l_chr_rec.acct_rule_id;
               x_contract_tbl (l_ptr).hdr_inv_rule_id := l_chr_rec.inv_rule_id;
               x_contract_tbl (l_ptr).ar_interface_yn :=
                                                     l_chr_rec.ar_interface_yn;
               x_contract_tbl (l_ptr).hold_billing := l_chr_rec.hold_billing;
               x_contract_tbl (l_ptr).summary_trx_yn :=
                                                      l_chr_rec.summary_trx_yn;
               x_contract_tbl (l_ptr).inv_trx_type := l_chr_rec.inv_trx_type;
               x_contract_tbl (l_ptr).payment_type := l_chr_rec.payment_type;
               x_contract_tbl (l_ptr).organization_id :=
                                                 l_chr_rec.inv_organization_id;
               x_contract_tbl (l_ptr).cvn_type := l_chr_rec.conversion_type;
               x_contract_tbl (l_ptr).cvn_rate := l_chr_rec.conversion_rate;
               x_contract_tbl (l_ptr).cvn_date :=
                                                l_chr_rec.conversion_rate_date;
               x_contract_tbl (l_ptr).cvn_euro_rate :=
                                                l_chr_rec.conversion_euro_rate;
               x_contract_tbl (l_ptr).resource_id := l_resource_id;
               x_contract_tbl (l_ptr).GROUP_ID := l_group_id;
               x_contract_tbl (l_ptr).access_level := l_access_level;
               x_contract_tbl (l_ptr).prod_name := l_chr_rec.NAME;
               x_contract_tbl (l_ptr).prod_description :=
                                                    l_chr_rec.item_description;
               x_contract_tbl (l_ptr).cle_id_renewed :=
                                       l_get_line_rec.contract_number_modifier;
               x_contract_tbl (l_ptr).sts_code := l_get_line_rec.sts_code;
               x_contract_tbl (l_ptr).prod_sts_code := l_chr_rec.sts_code;
               x_contract_tbl (l_ptr).prod_sdt := l_chr_rec.start_date;
               x_contract_tbl (l_ptr).prod_edt := l_chr_rec.end_date;
               x_contract_tbl (l_ptr).prod_term_date :=
                                                     l_chr_rec.date_terminated;
               --X_Contract_tbl(l_ptr).prod_line_renewal_type := Get_rules(l_chr_rec.id,'LRT',G_JTF_Billto);
               x_contract_tbl (l_ptr).prod_line_renewal_type :=
                                              l_chr_rec.line_renewal_type_code;
               x_contract_tbl (l_ptr).upg_orig_system_ref :=
                                                 l_chr_rec.upg_orig_system_ref;
               x_contract_tbl (l_ptr).upg_orig_system_ref_id :=
                                              l_chr_rec.upg_orig_system_ref_id;
               x_contract_tbl (l_ptr).party_id := l_chr_rec.party_id;
            END LOOP;

-- For l_Get_Line_rec in Get_Line_det_csr (l_chr_rec.dnz_chr_id, l_chr_rec.cle_id)
            l_ptr := l_ptr + 1;
         END IF;
      END LOOP;                        -- For l_chr_rec in Get_hdr_csr(p_Code)

      IF l_found = 'T'
      THEN
         x_available_yn := 'Y';
      ELSE
         x_available_yn := 'N';
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_CONTRACT_DETAILS.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_contract_details;

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--         CREATE_BILLING_SCHEDULE
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
   PROCEDURE create_billing_schedule (
      p_bill_start_date        IN              DATE,
      p_bill_end_date          IN              DATE,
      p_billing_frequency      IN              VARCHAR2,
      p_billing_method         IN              VARCHAR2,
      p_regular_offset_days    IN              NUMBER,
      p_first_bill_to_date     IN              DATE,
      p_first_inv_date         IN              DATE,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_billing_schedule_tbl   OUT NOCOPY      billing_schedule_tbl_type,
      p_cle_id                 IN              NUMBER
   )
   IS
      l_ptr                      NUMBER;
      l_return_status            VARCHAR2 (1)    := okc_api.g_ret_sts_success;

      CURSOR l_bill_csr
      IS
         SELECT date_billed_from, date_billed_to, creation_date
           FROM oks_bill_cont_lines_v
          WHERE cle_id = p_cle_id;

      l_bill_rec                 l_bill_csr%ROWTYPE;
      x_bill_from_date           DATE;
      l_fst_or_bill_start_date   DATE;

      CURSOR l_uom_csr (p_code VARCHAR2)
      IS
         SELECT tce_code, quantity
           FROM okc_time_code_units_v
          WHERE uom_code = p_code;

      l_tce_code                 VARCHAR2 (10);
      l_qty                      NUMBER;
   BEGIN
      IF p_bill_start_date IS NULL OR p_bill_end_date IS NULL
      THEN
         l_return_status := okc_api.g_ret_sts_success;
         RAISE g_exception_halt_validation;
      END IF;

      x_return_status := l_return_status;
      l_ptr := 1;
      x_billing_schedule_tbl (l_ptr).bill_from_date := NULL;
      x_billing_schedule_tbl (l_ptr).bill_to_date := NULL;
      x_billing_schedule_tbl (l_ptr).invoice_on_date := NULL;

      IF p_billing_frequency IS NULL
      THEN
         x_billing_schedule_tbl (l_ptr).bill_from_date := p_bill_start_date;
         x_billing_schedule_tbl (l_ptr).bill_to_date := p_bill_end_date;

         IF UPPER (p_billing_method) = 'ADVANCE'
         THEN
            x_billing_schedule_tbl (l_ptr).invoice_on_date :=
                                    NVL (p_first_inv_date, p_bill_start_date);
         ELSIF UPPER (p_billing_method) = 'ARREARS'
         THEN
            x_billing_schedule_tbl (l_ptr).invoice_on_date := NULL;
         END IF;

         l_return_status := okc_api.g_ret_sts_success;
         RAISE g_exception_halt_validation;
      END IF;

      /**
       If l_ptr = 1 and   p_first_bill_to_date Is not Null and p_first_inv_date Is not Null Then
      **/
      IF l_ptr = 1 AND p_first_bill_to_date IS NOT NULL
      THEN
         x_billing_schedule_tbl (l_ptr).bill_from_date :=
            NVL (x_billing_schedule_tbl (l_ptr).bill_from_date,
                 p_bill_start_date
                );
         x_billing_schedule_tbl (l_ptr).bill_to_date :=
            NVL (x_billing_schedule_tbl (l_ptr).bill_to_date,
                 p_first_bill_to_date
                );

         IF UPPER (p_billing_method) = 'ADVANCE'
         THEN
            l_fst_or_bill_start_date :=
                                    NVL (p_first_inv_date, p_bill_start_date);
            x_billing_schedule_tbl (l_ptr).invoice_on_date :=
               NVL (x_billing_schedule_tbl (l_ptr).invoice_on_date,
                    l_fst_or_bill_start_date
                   );
         ELSE
            x_billing_schedule_tbl (l_ptr).invoice_on_date := NULL;
         END IF;

         x_billing_schedule_tbl (l_ptr).billed_flag := 'F';

         IF x_billing_schedule_tbl (l_ptr).bill_to_date = p_bill_end_date
         THEN
            l_return_status := okc_api.g_ret_sts_success;
            RAISE g_exception_halt_validation;
         ELSE
            l_ptr := l_ptr + 1;
         END IF;
      END IF;

      LOOP
         IF l_ptr > 1
         THEN
            x_billing_schedule_tbl (l_ptr).bill_from_date :=
                          x_billing_schedule_tbl (l_ptr - 1).bill_to_date + 1;
         ELSE
            x_billing_schedule_tbl (l_ptr).bill_from_date :=
                                                            p_bill_start_date;
         END IF;

         l_tce_code := NULL;
         l_qty := NULL;

         OPEN l_uom_csr (p_billing_frequency);

         FETCH l_uom_csr
          INTO l_tce_code, l_qty;

         CLOSE l_uom_csr;

         IF UPPER (l_tce_code) = 'DAY' AND l_qty = 1
         THEN
            x_billing_schedule_tbl (l_ptr).bill_to_date :=
               LEAST ((x_billing_schedule_tbl (l_ptr).bill_from_date),
                      p_bill_end_date
                     );
         ELSIF UPPER (l_tce_code) = 'DAY' AND l_qty = 7
         THEN
            x_billing_schedule_tbl (l_ptr).bill_to_date :=
               LEAST ((x_billing_schedule_tbl (l_ptr).bill_from_date + 6),
                      p_bill_end_date
                     );
         ELSIF UPPER (l_tce_code) = 'MONTH' AND l_qty = 1
         THEN
            x_billing_schedule_tbl (l_ptr).bill_to_date :=
               LEAST
                  ((  ADD_MONTHS
                                (x_billing_schedule_tbl (l_ptr).bill_from_date,
                                 1
                                )
                    - 1
                   ),
                   p_bill_end_date
                  );
         ELSIF    (UPPER (l_tce_code) = 'YEAR' AND l_qty = 1)
               OR (UPPER (l_tce_code) = 'MONTH' AND l_qty = 12)
         THEN
            x_billing_schedule_tbl (l_ptr).bill_to_date :=
               LEAST
                  ((  ADD_MONTHS
                                (x_billing_schedule_tbl (l_ptr).bill_from_date,
                                 12
                                )
                    - 1
                   ),
                   p_bill_end_date
                  );
         ELSIF UPPER (l_tce_code) = 'MONTH' AND l_qty = 3
         THEN
            x_billing_schedule_tbl (l_ptr).bill_to_date :=
               LEAST
                  ((  ADD_MONTHS
                                (x_billing_schedule_tbl (l_ptr).bill_from_date,
                                 3
                                )
                    - 1
                   ),
                   p_bill_end_date
                  );
         ELSE
            l_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name, 'OKS_WRONG_BILLING_FREQUENCY');
            RAISE g_exception_halt_validation;
         END IF;

         IF UPPER (p_billing_method) = 'ADVANCE'
         THEN
            x_billing_schedule_tbl (l_ptr).invoice_on_date :=
                 x_billing_schedule_tbl (l_ptr).bill_from_date
               + p_regular_offset_days;
         ELSIF UPPER (p_billing_method) = 'ARREARS'
         THEN
            x_billing_schedule_tbl (l_ptr).invoice_on_date := NULL;
         ELSE
            l_return_status := okc_api.g_ret_sts_unexp_error;
            okc_api.set_message (g_app_name, 'OKS_WRONG_BILLING_METHOD');
         END IF;

         x_billing_schedule_tbl (l_ptr).billed_flag := 'F';
         EXIT WHEN x_billing_schedule_tbl (l_ptr).bill_to_date =
                                                               p_bill_end_date;
         l_ptr := l_ptr + 1;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END create_billing_schedule;

/*----------------------------------------------------------------------

PROCEDURE   : GET_WARRANTY_INFO
DESCRIPTION : This procedure is to get the information regarding attached
              warranties to an instance defined in BOM
INPUT       : Org id
              Inventory item id
              Date
OUTPUT      : Warranty details in x_warranty_tbl
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_warranty_info (
      p_org_id          IN              NUMBER,
      p_prod_item_id    IN              NUMBER,
      p_date            IN              DATE DEFAULT SYSDATE,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_warranty_tbl    OUT NOCOPY      war_tbl
   )
   IS
      l_warranty_tbl       war_item_id_tbl_type;
      l_ptr                INTEGER;
      l_comm_bill_seq_id   NUMBER;
      l_return_status      VARCHAR2 (1)         := okc_api.g_ret_sts_success;
      l_ship_date          DATE;
      l_ship_flag          VARCHAR2 (1);
      l_start_delay        NUMBER;

      CURSOR get_ship_csr
      IS
         SELECT shippable_item_flag, service_starting_delay
           FROM okx_system_items_v
          WHERE id1 = p_prod_item_id
            AND organization_id = okc_context.get_okc_organization_id;
   BEGIN
      okc_context.set_okc_org_context (p_org_id               => p_org_id,
                                       p_organization_id      => NULL
                                      );
      x_return_status := okc_api.g_ret_sts_success;

      IF p_prod_item_id IS NULL
      THEN
         --or p_customer_product_id is NULL
         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_WARRANTY_INFO.ERROR',
                            'Product Item Id Required'
                           );
         END IF;

         x_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name, 'OKS_ORG_ID_INV_ID REQUIRED');
         RAISE g_exception_halt_validation;
      END IF;

      get_war_item_id (p_inventory_item_id       => p_prod_item_id,
                       p_datec                   => p_date,
                       x_return_status           => l_return_status,
                       x_war_item_tbl            => l_warranty_tbl,
                       x_common_bill_seq_id      => l_comm_bill_seq_id
                      );

      IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_event,
                            g_module_current
                         || '.GET_WARRANTY_INFO.Internal_call.after',
                            'Get_war_item_id(Return status = '
                         || l_return_status
                         || 'Count = '
                         || l_warranty_tbl.COUNT
                         || ')'
                        );
      END IF;

      IF l_warranty_tbl.COUNT = 0
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      IF NOT l_warranty_tbl.COUNT = 0
      THEN
         l_ptr := l_warranty_tbl.FIRST;

         LOOP
            get_war_dur_per
                 (p_prod_inv_item_id      => p_prod_item_id,
                  p_comm_bill_seq_id      => l_comm_bill_seq_id,
                  p_war_inv_item_id       => l_warranty_tbl (l_ptr).war_item_id,
                  x_duration              => x_warranty_tbl (l_ptr).duration_quantity,
                  x_uom_code              => x_warranty_tbl (l_ptr).duration_period,
                  x_cov_sch_id            => x_warranty_tbl (l_ptr).coverage_schedule_id,
                  p_war_date              => p_date,
                  x_return_status         => l_return_status
                 );

            IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_event,
                                  g_module_current
                               || '.GET_WARRANTY_INFO.Internal call.after',
                                  'Get_War_Dur_Per(Return status = '
                               || l_return_status
                               || ')'
                              );
            END IF;

            IF NOT l_return_status = okc_api.g_ret_sts_success
            THEN
               RAISE g_exception_halt_validation;
            END IF;

            x_warranty_tbl (l_ptr).service_item_id :=
                                            l_warranty_tbl (l_ptr).war_item_id;
            x_warranty_tbl (l_ptr).warranty_start_date := p_date;
            x_warranty_tbl (l_ptr).warranty_end_date :=
               okc_time_util_pub.get_enddate
                   (p_start_date      => x_warranty_tbl (l_ptr).warranty_start_date,
                    p_duration        => x_warranty_tbl (l_ptr).duration_quantity,
                    p_timeunit        => x_warranty_tbl (l_ptr).duration_period
                   );
            EXIT WHEN (l_ptr = l_warranty_tbl.LAST);
            l_ptr := l_warranty_tbl.NEXT (l_ptr);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
         NULL;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_module_current
                            || '.GET_WARRANTY_INFO.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END get_warranty_info;

/*----------------------------------------------------------------------

PROCEDURE   : GET_TRANSFER_DETAIL
DESCRIPTION : This procedure is to get header, line and sub line details
              of the contracts covering the instance being transfered.
INPUT       : Instance id
OUTPUT      : header details in x_hdr_rec
              Line details in x_line_rec
              Covered lvl details in x_covd_rec
              retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE get_transfer_detail (
      p_cpid            IN              NUMBER,
      x_hdr_rec         OUT NOCOPY      oks_extwarprgm_pvt.k_header_rec_type,
      x_line_rec        OUT NOCOPY      oks_extwarprgm_pvt.k_line_service_rec_type,
      x_covd_rec        OUT NOCOPY      oks_extwarprgm_pvt.k_line_covered_level_rec_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cust_csr
      IS
         SELECT csi.last_oe_order_line_id original_order_line_id,
                csi.inventory_item_id, csi.quantity,
                csi.unit_of_measure uom_code, t.description NAME  -- mtl.name
                                                                ,
                b.concatenated_segments description         --mtl.description
                                                   ,
                b.coverage_schedule_id coverage_template_id
           -- mtl.coverage_template_id
         FROM   csi_item_instances csi,
                mtl_system_items_b_kfv b,
                mtl_system_items_tl t                 --okx_system_items_v mtl
          WHERE csi.instance_id = p_cpid
            AND csi.inventory_item_id = b.inventory_item_id
            AND b.inventory_item_id = t.inventory_item_id
            AND b.organization_id = t.organization_id
            AND t.LANGUAGE = USERENV ('LANG')
            AND b.organization_id = okc_context.get_okc_organization_id;

      CURSOR order_csr (p_line_id NUMBER)
      IS
         SELECT ol.header_id, oh.transactional_curr_code, oh.cust_po_number,
                oh.invoice_to_contact_id, oh.agreement_id,
                oh.invoicing_rule_id, oh.accounting_rule_id
           FROM oe_order_lines_all ol                  -- OKX_ORDER_LINES_V OL
                                     ,
                oe_order_headers_all oh              -- OKX_ORDER_HEADERS_V OH
          WHERE ol.line_id = p_line_id AND ol.header_id = oh.header_id;

      cust_rec          cust_csr%ROWTYPE;
      order_rec         order_csr%ROWTYPE;
      l_return_status   VARCHAR2 (1)        := okc_api.g_ret_sts_success;
   BEGIN
      x_return_status := l_return_status;

      OPEN cust_csr;

      FETCH cust_csr
       INTO cust_rec;

      IF cust_csr%NOTFOUND
      THEN
         CLOSE cust_csr;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            g_module_current || '.GET_TRANSFER_DETAILS.ERROR',
                            ' Cust_csr Not Found '
                           );
         END IF;

         l_return_status := okc_api.g_ret_sts_error;
         okc_api.set_message (g_app_name,
                              'OKS_CUST_PROD_DTLS_NOT_FOUND',
                              'CUSTOMER_PRODUCT',
                              p_cpid
                             );
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE cust_csr;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module_current || '.GET_TRANSFER_DETAILS',
                            ' Original order line Id = '
                         || cust_rec.original_order_line_id
                        );
      END IF;

      IF cust_rec.original_order_line_id IS NOT NULL
      THEN
         OPEN order_csr (cust_rec.original_order_line_id);

         FETCH order_csr
          INTO order_rec;

         CLOSE order_csr;

--          X_hdr_rec.invoice_to_contact_id      := Order_rec.invoice_to_contact_id;
         x_hdr_rec.cust_po_number := order_rec.cust_po_number;
         x_hdr_rec.agreement_id := order_rec.agreement_id;
         --X_hdr_rec.currency                   := Order_rec.Transactional_curr_code;
         x_hdr_rec.accounting_rule_id := order_rec.accounting_rule_id;
         x_hdr_rec.invoice_rule_id := order_rec.invoicing_rule_id;
         x_hdr_rec.order_hdr_id := order_rec.header_id;
      END IF;

      /*If Order_rec.Transactional_curr_code Is Null Then
               X_hdr_rec.currency                   := OKC_CURRENCY_API.GET_OU_CURRENCY(okc_context.get_okc_org_id);

      End If;*/
      x_hdr_rec.contract_number := NULL;
      x_hdr_rec.start_date := NULL;
      x_hdr_rec.end_date := NULL;
      x_hdr_rec.sts_code := NULL;
      x_hdr_rec.class_code := NULL;
        -- X_hdr_rec.authoring_org_id           := Cust_rec.org_id;
      --   X_hdr_rec.party_id                   := Cust_rec.Party_id;
       --  X_hdr_rec.bill_to_id                 := Cust_rec.bill_to_id;
       --  X_hdr_rec.ship_to_id                 := Cust_rec.ship_to_id;
      x_line_rec.k_id := NULL;
      x_line_rec.k_line_number := NULL;
      x_line_rec.object_name := NULL;
      x_line_rec.srv_segment1 := NULL;
      x_line_rec.srv_desc := NULL;
      x_line_rec.srv_sdt := NULL;
      x_line_rec.srv_edt := NULL;
      x_line_rec.coverage_template_id := cust_rec.coverage_template_id;
      -- X_line_rec.org_id                    := Cust_rec.Org_id;
      x_line_rec.srv_id := NULL;
       -- X_line_rec.bill_to_id                := Cust_rec.bill_to_id;
      --  X_line_rec.ship_to_id                := Cust_rec.ship_to_id;
      x_line_rec.order_line_id := cust_rec.original_order_line_id;
      x_line_rec.currency := NULL;

      -- X_line_rec.cust_account              := Cust_rec.customer_id;
      IF fnd_profile.VALUE ('OKS_ITEM_DISPLAY_PREFERENCE') = 'DISPLAY_NAME'
      THEN
         x_covd_rec.product_segment1 := cust_rec.description;
         x_covd_rec.product_desc := cust_rec.NAME;
      ELSE
         x_covd_rec.product_segment1 := cust_rec.NAME;
         x_covd_rec.product_desc := cust_rec.description;
      END IF;

      x_covd_rec.k_id := NULL;
      x_covd_rec.attach_2_line_id := NULL;
      x_covd_rec.line_number := NULL;
      --X_covd_rec.product_segment1           := Cust_rec.Name;
      --X_covd_rec.product_desc               := Cust_rec.description;
      x_covd_rec.product_end_date := NULL;
      x_covd_rec.customer_product_id := p_cpid;
      x_covd_rec.product_item_id := cust_rec.inventory_item_id;
      x_covd_rec.product_start_date := NULL;
      x_covd_rec.quantity := cust_rec.quantity;
      x_covd_rec.uom_code := cust_rec.uom_code;
      x_covd_rec.list_price := NULL;
      x_covd_rec.negotiated_amount := NULL;
      x_covd_rec.warranty_flag := NULL;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_TRANSFER_DETAILS.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END;

   PROCEDURE update_timestamp (
      p_counter_group_id     IN              NUMBER,
      p_service_start_date   IN              DATE,
      p_service_line_id      IN              NUMBER,
      x_status               OUT NOCOPY      VARCHAR2
   )
   IS
--------------------
      CURSOR c_ctr_timestamp (cp_counter_group_id NUMBER)
      IS
         SELECT counter_value_id, counter_id
           FROM okx_counters_v
          WHERE counter_group_id = cp_counter_group_id AND TYPE = 'TIME';

---------------------
      g_miss_num    CONSTANT NUMBER                               := 9.99e125;
      g_miss_char   CONSTANT VARCHAR2 (1)         := fnd_global.local_chr (0);
      g_miss_date   CONSTANT DATE                       := TO_DATE ('1', 'j');
      g_false       CONSTANT VARCHAR2 (1)                              := 'F';
      x_return_status        VARCHAR2 (1);
      x_msg_count            NUMBER;
      x_msg_data             VARCHAR2 (500);
      l_ctr_rdg_tbl          cs_ctr_capture_reading_pub.ctr_rdg_tbl_type;
      l_ctr_grp_log_rec      cs_ctr_capture_reading_pub.ctr_grp_log_rec_type;
   BEGIN
      -- Initialise table variables
      l_ctr_rdg_tbl (1).counter_value_id := g_miss_num;
      l_ctr_rdg_tbl (1).counter_id := g_miss_num;
      l_ctr_rdg_tbl (1).value_timestamp := g_miss_date;
      l_ctr_rdg_tbl (1).counter_reading := g_miss_num;
      l_ctr_rdg_tbl (1).reset_flag := g_false;
      l_ctr_rdg_tbl (1).reset_reason := g_miss_char;
      l_ctr_rdg_tbl (1).pre_reset_last_rdg := g_miss_num;
      l_ctr_rdg_tbl (1).post_reset_first_rdg := g_miss_num;
      l_ctr_rdg_tbl (1).misc_reading_type := g_miss_char;
      l_ctr_rdg_tbl (1).misc_reading := g_miss_num;
      l_ctr_rdg_tbl (1).object_version_number := g_miss_num;
      l_ctr_rdg_tbl (1).attribute1 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute2 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute3 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute4 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute5 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute6 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute7 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute8 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute9 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute10 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute11 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute12 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute13 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute14 := g_miss_char;
      l_ctr_rdg_tbl (1).attribute15 := g_miss_char;
      l_ctr_rdg_tbl (1).CONTEXT := g_miss_char;
      l_ctr_grp_log_rec.counter_grp_log_id := g_miss_num;
      l_ctr_grp_log_rec.counter_group_id := g_miss_num;
      l_ctr_grp_log_rec.value_timestamp := g_miss_date;
      l_ctr_grp_log_rec.source_transaction_id := g_miss_num;
      l_ctr_grp_log_rec.source_transaction_code := g_miss_char;
      l_ctr_grp_log_rec.attribute1 := g_miss_char;
      l_ctr_grp_log_rec.attribute2 := g_miss_char;
      l_ctr_grp_log_rec.attribute3 := g_miss_char;
      l_ctr_grp_log_rec.attribute4 := g_miss_char;
      l_ctr_grp_log_rec.attribute5 := g_miss_char;
      l_ctr_grp_log_rec.attribute6 := g_miss_char;
      l_ctr_grp_log_rec.attribute7 := g_miss_char;
      l_ctr_grp_log_rec.attribute8 := g_miss_char;
      l_ctr_grp_log_rec.attribute9 := g_miss_char;
      l_ctr_grp_log_rec.attribute10 := g_miss_char;
      l_ctr_grp_log_rec.attribute11 := g_miss_char;
      l_ctr_grp_log_rec.attribute12 := g_miss_char;
      l_ctr_grp_log_rec.attribute13 := g_miss_char;
      l_ctr_grp_log_rec.attribute14 := g_miss_char;
      l_ctr_grp_log_rec.attribute15 := g_miss_char;
      l_ctr_grp_log_rec.CONTEXT := g_miss_char;

      FOR l_ctr_timestamp IN c_ctr_timestamp (p_counter_group_id)
      LOOP
         l_ctr_rdg_tbl (1).counter_id := l_ctr_timestamp.counter_id;
         l_ctr_rdg_tbl (1).counter_reading := 0;
         l_ctr_rdg_tbl (1).value_timestamp := p_service_start_date;
         l_ctr_grp_log_rec.counter_group_id := p_counter_group_id;
         l_ctr_grp_log_rec.value_timestamp := p_service_start_date;
         l_ctr_grp_log_rec.source_transaction_id := p_service_line_id;
         l_ctr_grp_log_rec.source_transaction_code := 'CONTRACT_LINE';
         cs_ctr_capture_reading_pub.capture_counter_reading
                                     (p_api_version_number      => 1.0,
                                      p_init_msg_list           => 'T',
                                      p_commit                  => 'F',
                                      p_validation_level        => 100,
                                      p_ctr_grp_log_rec         => l_ctr_grp_log_rec,
                                      p_ctr_rdg_tbl             => l_ctr_rdg_tbl,
                                      x_return_status           => x_return_status,
                                      x_msg_count               => x_msg_count,
                                      x_msg_data                => x_msg_data
                                     );
         x_status := x_return_status;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END update_timestamp;

--==========================================================================================================================
   PROCEDURE salescredit (
      p_order_line_id     IN              NUMBER,
      x_salescredit_tbl   OUT NOCOPY      salescredit_tbl,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_scredit_csr
      IS
         SELECT salesrep_id, sales_credit_type_id, PERCENT, sales_group_id
           FROM oe_sales_credits
          WHERE line_id = p_order_line_id;

          /*   Cursor l_salesgroup_csr(p_salesrep_id Number) Is
                          SELECT DISTINCT grp.group_name, grp.group_id
                          FROM   jtf_rs_group_members mem
                                       ,jtf_rs_groups_vl grp
                                       ,jtf_rs_salesreps srp
                                       ,jtf_rs_group_usages usg
                                       ,jtf_rs_role_relations rrl
                          WHERE  srp.resource_id             = mem.resource_id
                          AND    mem.group_id               = grp.group_id
                          AND    mem.group_id               = usg.group_id
                          AND    usg.usage                     = 'SALES'
                          AND    mem.delete_flag            = 'N'
                          AND    mem.group_member_id  = rrl.role_resource_id
                          AND    rrl.role_resource_type     = 'RS_GROUP_MEMBER'
                          AND    rrl.delete_flag                 = 'N'
                          --AND    nvl(rrl.end_date_active,TO_DATE('01/01/4713','MM/DD/RRRR')) >=
                                                                                --:NAME_IN('OKS_HEADER_CONTACTS.START_DATE')
                         -- AND    rrl.start_date_active       <=  :NAME_IN('OKS_HEADER_CONTACTS END_DATE ')
                          AND    srp.salesrep_id               = p_salesrep_id
                          AND    srp.org_id                      = okc_context.get_okc_
                        --  AND    :END_DATE  BETWEEN grp.start_date_active AND
                          --              NVL(grp.end_date_active,TO_DATE('01/01/4713','MM/DD/RRRR'))
                          UNION ALL
                          SELECT group_name, group_id
                          FROM    jtf_rs_groups_tl
                          WHERE group_id = -1
                          AND      LANGUAGE = USERENV('LANG');

      */
      i                 INTEGER      := 0;
      l_return_status   VARCHAR2 (1) := okc_api.g_ret_sts_success;
   BEGIN
      x_return_status := l_return_status;
      i := 1;

      FOR l_scredit_rec IN l_scredit_csr
      LOOP
         x_salescredit_tbl (i).ctc_id := l_scredit_rec.salesrep_id;
         x_salescredit_tbl (i).sales_credit_type_id :=
                                           l_scredit_rec.sales_credit_type_id;
         x_salescredit_tbl (i).PERCENT := l_scredit_rec.PERCENT;
         x_salescredit_tbl (i).sales_group_id := l_scredit_rec.sales_group_id;
         i := i + 1;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_module_current || '.SALESCREDIT.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

--mmadhavi bug 4174921
   PROCEDURE salescredit_header (
      p_order_hdr_id      IN              NUMBER,
      x_salescredit_tbl   OUT NOCOPY      salescredit_tbl,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_scredit_csr
      IS
         SELECT salesrep_id, sales_credit_type_id, PERCENT, sales_group_id
           FROM oe_sales_credits
          WHERE header_id = p_order_hdr_id AND line_id IS NULL;

      i                 INTEGER      := 0;
      l_return_status   VARCHAR2 (1) := okc_api.g_ret_sts_success;
   BEGIN
      x_return_status := l_return_status;
      i := 1;

      FOR l_scredit_rec IN l_scredit_csr
      LOOP
         x_salescredit_tbl (i).ctc_id := l_scredit_rec.salesrep_id;
         x_salescredit_tbl (i).sales_credit_type_id :=
                                           l_scredit_rec.sales_credit_type_id;
         x_salescredit_tbl (i).PERCENT := l_scredit_rec.PERCENT;
         x_salescredit_tbl (i).sales_group_id := l_scredit_rec.sales_group_id;
         i := i + 1;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            g_module_current || '.SALESCREDIT_HDR.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

--mmadhavi bug 4174921
--======================================================================================

   ---UPDATE CONTRACT DETAILS
   PROCEDURE update_contract_details (
      p_hdr_id                       NUMBER,
      p_order_line_id                NUMBER,
      x_return_status   OUT NOCOPY   VARCHAR2
   )
   IS
      CURSOR l_link_csr1
      IS
         SELECT NVL (link_ord_line_id1, order_line_id1)
           FROM oks_k_order_details
          WHERE order_line_id1 = TO_CHAR (p_order_line_id);

      CURSOR l_link_csr_a (l_link_ord_id VARCHAR2)
      IS
         SELECT ID, order_line_id1, object_version_number
           FROM oks_k_order_details
          WHERE link_ord_line_id1 = l_link_ord_id AND chr_id IS NULL;

      CURSOR l_link_csr_b (l_link_ord_id VARCHAR2)
      IS
         SELECT ID, order_line_id1, object_version_number
           FROM oks_k_order_details
          WHERE order_line_id1 = l_link_ord_id AND chr_id IS NULL;

      l_link_rec1          l_link_csr_a%ROWTYPE;
      l_link_rec2          l_link_csr_b%ROWTYPE;
      l_codv_tbl_in        oks_cod_pvt.codv_tbl_type;
      l_codv_tbl_out       oks_cod_pvt.codv_tbl_type;
      l_link_to_order_id   VARCHAR2 (40);
      l_return_status      VARCHAR2 (1)          := okc_api.g_ret_sts_success;
      l_msg_count          NUMBER;
      l_msg_data           VARCHAR2 (2000);
      link_flag            NUMBER                    := 0;
   BEGIN
      x_return_status := l_return_status;

      OPEN l_link_csr1;

      FETCH l_link_csr1
       INTO l_link_to_order_id;

      IF l_link_csr1%NOTFOUND
      THEN
         CLOSE l_link_csr1;

         IF fnd_log.level_error >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_error,
                               g_module_current
                            || '.UPDATE_CONTRACT_DETAILS.ERROR',
                               'l_line_csr1 Not Found for Line Id = '
                            || p_order_line_id
                           );
         END IF;

         okc_api.set_message (g_app_name,
                              'OKS_ORDER_DETAILS',
                              'ORDER_DETAILS',
                              p_order_line_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      CLOSE l_link_csr1;

      link_flag := 0;

      OPEN l_link_csr_a (l_link_to_order_id);

      LOOP
         FETCH l_link_csr_a
          INTO l_link_rec1;

         EXIT WHEN l_link_csr_a%NOTFOUND;
         l_codv_tbl_in (1).ID := l_link_rec1.ID;
         l_codv_tbl_in (1).chr_id := p_hdr_id;
         l_codv_tbl_in (1).object_version_number :=
                                            l_link_rec1.object_version_number;
         --BugFix 2458874
         oks_cod_pvt.update_row (p_api_version        => 1.0,
                                 p_init_msg_list      => 'T',
                                 x_return_status      => l_return_status,
                                 x_msg_count          => l_msg_count,
                                 x_msg_data           => l_msg_data,
                                 p_codv_tbl           => l_codv_tbl_in,
                                 x_codv_tbl           => l_codv_tbl_out
                                );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.UPDATE_CONTRACT_DETAILS.External_call.after',
                               'OKS_COD_PVT.update_row(Return Status = '
                            || l_return_status
                            || ')'
                           );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;

         link_flag := 1;
      END LOOP;

      CLOSE l_link_csr_a;

      --If link_flag = 0 Then
      OPEN l_link_csr_b (l_link_to_order_id);

      LOOP
         FETCH l_link_csr_b
          INTO l_link_rec2;

         EXIT WHEN l_link_csr_b%NOTFOUND;
         l_codv_tbl_in (1).ID := l_link_rec2.ID;
         l_codv_tbl_in (1).chr_id := p_hdr_id;
         l_codv_tbl_in (1).object_version_number :=
                                            l_link_rec2.object_version_number;
         --BugFix 2458874
         oks_cod_pvt.update_row (p_api_version        => 1.0,
                                 p_init_msg_list      => 'T',
                                 x_return_status      => l_return_status,
                                 x_msg_count          => l_msg_count,
                                 x_msg_data           => l_msg_data,
                                 p_codv_tbl           => l_codv_tbl_in,
                                 x_codv_tbl           => l_codv_tbl_out
                                );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_event,
                               g_module_current
                            || '.UPDATE_CONTRACT_DETAILS.External_call.after',
                               'OKS_COD_PVT.update_row(Return Status = '
                            || l_return_status
                            || ')'
                           );
         END IF;

         IF NOT l_return_status = okc_api.g_ret_sts_success
         THEN
            x_return_status := l_return_status;
            RAISE g_exception_halt_validation;
         END IF;
      END LOOP;

      CLOSE l_link_csr_b;
   ---End if;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.UPDATE_CONTRACT_DETAILS.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END;

   PROCEDURE get_pricing_attributes (
      p_order_line_id   IN              NUMBER,
      x_pricing_att     OUT NOCOPY      oks_extwarprgm_pvt.pricing_attributes_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_pricing_att_csr
      IS
         SELECT pricing_context, pricing_attribute1, pricing_attribute2,
                pricing_attribute3, pricing_attribute4, pricing_attribute5,
                pricing_attribute6, pricing_attribute7, pricing_attribute8,
                pricing_attribute9, pricing_attribute10, pricing_attribute11,
                pricing_attribute12, pricing_attribute13,
                pricing_attribute14, pricing_attribute15,
                pricing_attribute16, pricing_attribute17,
                pricing_attribute18, pricing_attribute19,
                pricing_attribute20, pricing_attribute21,
                pricing_attribute22, pricing_attribute23,
                pricing_attribute24, pricing_attribute25,
                pricing_attribute26, pricing_attribute27,
                pricing_attribute28, pricing_attribute29,
                pricing_attribute30, pricing_attribute31,
                pricing_attribute32, pricing_attribute33,
                pricing_attribute34, pricing_attribute35,
                pricing_attribute36, pricing_attribute37,
                pricing_attribute38, pricing_attribute39,
                pricing_attribute40, pricing_attribute41,
                pricing_attribute42, pricing_attribute43,
                pricing_attribute44, pricing_attribute45,
                pricing_attribute46, pricing_attribute47,
                pricing_attribute48, pricing_attribute49,
                pricing_attribute50, pricing_attribute51,
                pricing_attribute52, pricing_attribute53,
                pricing_attribute54, pricing_attribute55,
                pricing_attribute56, pricing_attribute57,
                pricing_attribute58, pricing_attribute59,
                pricing_attribute60, pricing_attribute61,
                pricing_attribute62, pricing_attribute63,
                pricing_attribute64, pricing_attribute65,
                pricing_attribute66, pricing_attribute67,
                pricing_attribute68, pricing_attribute69,
                pricing_attribute70, pricing_attribute71,
                pricing_attribute72, pricing_attribute73,
                pricing_attribute74, pricing_attribute75,
                pricing_attribute76, pricing_attribute77,
                pricing_attribute78, pricing_attribute79,
                pricing_attribute80, pricing_attribute81,
                pricing_attribute82, pricing_attribute83,
                pricing_attribute84, pricing_attribute85,
                pricing_attribute86, pricing_attribute87,
                pricing_attribute88, pricing_attribute89,
                pricing_attribute90, pricing_attribute91,
                pricing_attribute92, pricing_attribute93,
                pricing_attribute94, pricing_attribute95,
                pricing_attribute96, pricing_attribute97,
                pricing_attribute98, pricing_attribute99,
                pricing_attribute100
           FROM oe_order_price_attribs_v okx
          WHERE okx.line_id = p_order_line_id;
   BEGIN
      x_return_status := 'S';

      OPEN l_pricing_att_csr;

      FETCH l_pricing_att_csr
       INTO x_pricing_att;

      CLOSE l_pricing_att_csr;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_PRICING_ATTRIBUTES.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END;

   PROCEDURE get_k_pricing_attributes (
      p_k_line_id       IN              NUMBER,
      x_pricing_att     OUT NOCOPY      oks_extwarprgm_pvt.pricing_attributes_type,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_pricing_att_csr
      IS
         SELECT pricing_context, pricing_attribute1, pricing_attribute2,
                pricing_attribute3, pricing_attribute4, pricing_attribute5,
                pricing_attribute6, pricing_attribute7, pricing_attribute8,
                pricing_attribute9, pricing_attribute10, pricing_attribute11,
                pricing_attribute12, pricing_attribute13,
                pricing_attribute14, pricing_attribute15,
                pricing_attribute16, pricing_attribute17,
                pricing_attribute18, pricing_attribute19,
                pricing_attribute20, pricing_attribute21,
                pricing_attribute22, pricing_attribute23,
                pricing_attribute24, pricing_attribute25,
                pricing_attribute26, pricing_attribute27,
                pricing_attribute28, pricing_attribute29,
                pricing_attribute30, pricing_attribute31,
                pricing_attribute32, pricing_attribute33,
                pricing_attribute34, pricing_attribute35,
                pricing_attribute36, pricing_attribute37,
                pricing_attribute38, pricing_attribute39,
                pricing_attribute40, pricing_attribute41,
                pricing_attribute42, pricing_attribute43,
                pricing_attribute44, pricing_attribute45,
                pricing_attribute46, pricing_attribute47,
                pricing_attribute48, pricing_attribute49,
                pricing_attribute50, pricing_attribute51,
                pricing_attribute52, pricing_attribute53,
                pricing_attribute54, pricing_attribute55,
                pricing_attribute56, pricing_attribute57,
                pricing_attribute58, pricing_attribute59,
                pricing_attribute60, pricing_attribute61,
                pricing_attribute62, pricing_attribute63,
                pricing_attribute64, pricing_attribute65,
                pricing_attribute66, pricing_attribute67,
                pricing_attribute68, pricing_attribute69,
                pricing_attribute70, pricing_attribute71,
                pricing_attribute72, pricing_attribute73,
                pricing_attribute74, pricing_attribute75,
                pricing_attribute76, pricing_attribute77,
                pricing_attribute78, pricing_attribute79,
                pricing_attribute80, pricing_attribute81,
                pricing_attribute82, pricing_attribute83,
                pricing_attribute84, pricing_attribute85,
                pricing_attribute86, pricing_attribute87,
                pricing_attribute88, pricing_attribute89,
                pricing_attribute90, pricing_attribute91,
                pricing_attribute92, pricing_attribute93,
                pricing_attribute94, pricing_attribute95,
                pricing_attribute96, pricing_attribute97,
                pricing_attribute98, pricing_attribute99,
                pricing_attribute100
           FROM okc_price_att_values_v okx
          WHERE okx.cle_id = p_k_line_id;
   BEGIN
      x_return_status := 'S';

      OPEN l_pricing_att_csr;

      FETCH l_pricing_att_csr
       INTO x_pricing_att;

      CLOSE l_pricing_att_csr;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.GET_K_PRICING_ATTRIBUTES.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END;

   FUNCTION oks_get_party (p_chr_id NUMBER, p_rle_code VARCHAR2)
      RETURN NUMBER
   IS
      CURSOR l_party_csr
      IS
         SELECT object1_id1
           FROM okc_k_party_roles_v
          WHERE chr_id = p_chr_id AND rle_code = p_rle_code;

      l_party_id   NUMBER := NULL;
   BEGIN
      OPEN l_party_csr;

      FETCH l_party_csr
       INTO l_party_id;

      CLOSE l_party_csr;

      RETURN l_party_id;
   END;

/*
FUNCTION OKS_GET_HDR_RULES
(
p_chr_id      NUMBER,
p_Category    VARCHAR2,
p_object_Code VARCHAR2
)
Return NUMBER
Is

Cursor Get_Rule_objectid_Csr Is
       Select object1_id1
       From   okc_rules_v rul
             ,okc_rule_groups_v rgp
       Where  rul.rgp_id = rgp.id
       And    rule_information_category = p_category
       And    jtot_object1_Code = p_object_Code
       And    rgp.dnz_chr_id = p_chr_id
       And   cle_id Is Null;
l_object_id   VARCHAR2(40);

BEGIN
     Open Get_Rule_objectid_Csr;
     Fetch Get_Rule_objectid_Csr into l_object_id;
     If Get_Rule_objectid_Csr%notfound Then
        Close Get_Rule_objectid_Csr;
        return(null);
     End If;

     Close Get_Rule_objectid_Csr;
     return(l_object_id);

END OKS_GET_HDR_RULES;
*/
   FUNCTION oks_get_rules (
      p_cle_id        NUMBER,
      p_category      VARCHAR2,
      p_object_code   VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR get_rule_objectid_csr
      IS
         SELECT object1_id1
           FROM okc_rules_v rul, okc_rule_groups_v rgp
          WHERE rul.rgp_id = rgp.ID
            AND rule_information_category = p_category
            AND jtot_object1_code = p_object_code
            AND cle_id = p_cle_id;

      l_object_id   VARCHAR2 (40);
   BEGIN
      OPEN get_rule_objectid_csr;

      FETCH get_rule_objectid_csr
       INTO l_object_id;

      IF get_rule_objectid_csr%NOTFOUND
      THEN
         CLOSE get_rule_objectid_csr;

         RETURN (NULL);
      END IF;

      CLOSE get_rule_objectid_csr;

      RETURN (l_object_id);
   END oks_get_rules;

   FUNCTION oks_get_svc (p_cle_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR get_rule_objectid_csr
      IS
         SELECT object1_id1
           FROM okc_k_items kit
          WHERE cle_id = p_cle_id;

      l_object_id   NUMBER;
   BEGIN
      OPEN get_rule_objectid_csr;

      FETCH get_rule_objectid_csr
       INTO l_object_id;

      IF get_rule_objectid_csr%NOTFOUND
      THEN
         CLOSE get_rule_objectid_csr;

         RETURN (NULL);
      END IF;

      CLOSE get_rule_objectid_csr;

      RETURN (l_object_id);
   END oks_get_svc;

/*----------------------------------------------------------------------

PROCEDURE   : CREATE_SALES_CREDITS
DESCRIPTION : This procedure is to create the sales credits
INPUT       : header id
              line id
OUTPUT      : retun status 'S' if successful

----------------------------------------------------------------------*/
   PROCEDURE create_sales_credits (
      p_header_id                    NUMBER,
      p_line_id                      NUMBER,
      x_return_status   OUT NOCOPY   VARCHAR2
   )
   IS
      l_return_status   VARCHAR2 (3)             := okc_api.g_ret_sts_success;

      CURSOR scredit_csr
      IS
         SELECT PERCENT, ctc_id, sales_credit_type_id1,
                sales_credit_type_id2, sales_group_id
           FROM oks_k_sales_credits_v
          WHERE chr_id = p_header_id AND cle_id IS NULL;

      l_scr_rec         scredit_csr%ROWTYPE;
      l_scrv_tbl_in     oks_sales_credit_pub.scrv_tbl_type;
      l_scrv_tbl_out    oks_sales_credit_pub.scrv_tbl_type;
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2 (2000);
   BEGIN
      x_return_status := l_return_status;

      FOR l_scr_rec IN scredit_csr
      LOOP
         l_scrv_tbl_in (1).PERCENT := l_scr_rec.PERCENT;
         l_scrv_tbl_in (1).ctc_id := l_scr_rec.ctc_id;
         l_scrv_tbl_in (1).sales_credit_type_id1 :=
                                              l_scr_rec.sales_credit_type_id1;
         l_scrv_tbl_in (1).sales_credit_type_id2 :=
                                              l_scr_rec.sales_credit_type_id2;
         l_scrv_tbl_in (1).sales_group_id := l_scr_rec.sales_group_id;
         l_scrv_tbl_in (1).cle_id := p_line_id;
         l_scrv_tbl_in (1).chr_id := p_header_id;
         oks_sales_credit_pub.insert_sales_credit
                                         (p_api_version        => 1.0,
                                          p_init_msg_list      => 'T',
                                          x_return_status      => l_return_status,
                                          x_msg_count          => l_msg_count,
                                          x_msg_data           => l_msg_data,
                                          p_scrv_tbl           => l_scrv_tbl_in,
                                          x_scrv_tbl           => l_scrv_tbl_out
                                         );

         IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
               (fnd_log.level_event,
                g_module_current
                || '.CREATE_SALES_CREDITS.External_call.after',
                   'OKS_SALES_CREDIT_PUB.Insert_Sales_credit(x_return_status = '
                || x_return_status
                || ')'
               );
         END IF;

         IF l_return_status <> 'S'
         THEN
            l_return_status := 'U';
            RAISE g_exception_halt_validation;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );

         IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                               g_module_current
                            || '.CREATE_SALES_CREDITS.UNEXPECTED',
                            'sqlcode = ' || SQLCODE || ', sqlerrm = '
                            || SQLERRM
                           );
         END IF;
   END create_sales_credits;

   FUNCTION get_line_name_if_null (
      p_inventory_item_id   IN              NUMBER,
      p_organization_id     IN              NUMBER,
      p_code                IN              VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      CURSOR l_csr
      IS
         SELECT   application_column_name
             FROM fnd_id_flex_segments_vl
            WHERE application_id = 401 AND id_flex_code = p_code
         ORDER BY segment_num;

      CURSOR l_delr_csr (l_structure_code VARCHAR2)
      IS
         SELECT concatenated_segment_delimiter
           FROM fnd_id_flex_structures_vl
          WHERE application_id = 401
            AND id_flex_code = p_code
            AND id_flex_structure_code = l_structure_code;

      l_structure_code   VARCHAR2 (30);
      l_sel_column       VARCHAR2 (1000);
      l_count            NUMBER          := 1;
      l_select_stmt      VARCHAR2 (4000);
      l_column           VARCHAR2 (600);
      l_exe_count        INTEGER;
      l_cursor_id        INTEGER;
      l_name             VARCHAR2 (800)  := NULL;
      l_delimiter        VARCHAR2 (5);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF p_code = 'SERV'
      THEN
         l_structure_code := 'ORACLE_SERVICE_ITEM_FLEXFIELD';
      ELSIF p_code = 'MSTK'
      THEN
         l_structure_code := 'SYSTEM_ITEMS';
      END IF;

      OPEN l_delr_csr (l_structure_code);

      FETCH l_delr_csr
       INTO l_delimiter;

      CLOSE l_delr_csr;

      OPEN l_csr;

      FETCH l_csr
       INTO l_column;

      LOOP
         EXIT WHEN l_csr%NOTFOUND;

         IF l_count = 1
         THEN
            l_sel_column := l_column;
         ELSE
            l_sel_column :=
                  l_sel_column
               || '||'
               || ''''
               || l_delimiter
               || ''''
               || '||'
               || l_column;
         END IF;

         FETCH l_csr
          INTO l_column;

         l_count := 2;
      END LOOP;

      CLOSE l_csr;

      l_select_stmt :=
            'Select '
         || l_sel_column
         || ' From Mtl_system_items_b
                    Where Inventory_item_id = :d1 And Organization_id = :d2 ';
      l_cursor_id := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (l_cursor_id, l_select_stmt, DBMS_SQL.native);
      DBMS_SQL.bind_variable (l_cursor_id, ':d1', p_inventory_item_id);
      DBMS_SQL.bind_variable (l_cursor_id, ':d2', p_organization_id);
      l_exe_count := DBMS_SQL.EXECUTE (l_cursor_id);
      DBMS_SQL.define_column (l_cursor_id, 1, l_name, 200);

      LOOP
         IF DBMS_SQL.fetch_rows (l_cursor_id) = 0
         THEN
            EXIT;
         END IF;

         DBMS_SQL.column_value (l_cursor_id, 1, l_name);
      END LOOP;

      DBMS_SQL.close_cursor (l_cursor_id);
      --Dbms_Output.Put_Line('Name: ' || l_name);
      RETURN (l_name);
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
         RETURN (l_name);
   END get_line_name_if_null;

   PROCEDURE get_line_name_if_null (
      p_inventory_item_id   IN              NUMBER,
      p_organization_id     IN              NUMBER,
      p_code                IN              VARCHAR2,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_name                OUT NOCOPY      VARCHAR2,
      x_description         OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_csr
      IS
         SELECT   application_column_name
             FROM fnd_id_flex_segments_vl
            WHERE application_id = 401 AND id_flex_code = p_code
         ORDER BY segment_num;

      CURSOR l_delr_csr (l_structure_code VARCHAR2)
      IS
         SELECT concatenated_segment_delimiter
           FROM fnd_id_flex_structures_vl
          WHERE application_id = 401
            AND id_flex_code = p_code
            AND id_flex_structure_code = l_structure_code;

      l_structure_code   VARCHAR2 (30);
      l_sel_column       VARCHAR2 (1000);
      l_count            NUMBER          := 1;
      l_select_stmt      VARCHAR2 (4000);
      l_column           VARCHAR2 (600);
      l_exe_count        INTEGER;
      l_cursor_id        INTEGER;
      l_name             VARCHAR2 (800)  := NULL;
      l_desc             VARCHAR2 (800)  := NULL;
      l_delimiter        VARCHAR2 (5);
   BEGIN
      x_return_status := okc_api.g_ret_sts_success;

      IF p_code = 'SERV'
      THEN
         l_structure_code := 'ORACLE_SERVICE_ITEM_FLEXFIELD';
      ELSIF p_code = 'MSTK'
      THEN
         l_structure_code := 'SYSTEM_ITEMS';
      END IF;

      OPEN l_delr_csr (l_structure_code);

      FETCH l_delr_csr
       INTO l_delimiter;

      CLOSE l_delr_csr;

      OPEN l_csr;

      FETCH l_csr
       INTO l_column;

      LOOP
         EXIT WHEN l_csr%NOTFOUND;

         IF l_count = 1
         THEN
            l_sel_column := l_column;
         ELSE
            l_sel_column :=
                  l_sel_column
               || '||'
               || ''''
               || l_delimiter
               || ''''
               || '||'
               || l_column;
         END IF;

         FETCH l_csr
          INTO l_column;

         l_count := 2;
      END LOOP;

      CLOSE l_csr;

      l_select_stmt :=
            'Select '
         || l_sel_column
         || ' ,Description '
         || ' From Mtl_system_items_b
                    Where Inventory_item_id = :d1 And Organization_id = :d2 ';
      l_cursor_id := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (l_cursor_id, l_select_stmt, DBMS_SQL.native);
      DBMS_SQL.bind_variable (l_cursor_id, ':d1', p_inventory_item_id);
      DBMS_SQL.bind_variable (l_cursor_id, ':d2', p_organization_id);
      l_exe_count := DBMS_SQL.EXECUTE (l_cursor_id);
      DBMS_SQL.define_column (l_cursor_id, 1, l_name, 200);
      DBMS_SQL.define_column (l_cursor_id, 2, l_desc, 500);

      LOOP
         IF DBMS_SQL.fetch_rows (l_cursor_id) = 0
         THEN
            EXIT;
         END IF;

         DBMS_SQL.column_value (l_cursor_id, 1, l_name);
         DBMS_SQL.column_value (l_cursor_id, 2, l_desc);
      END LOOP;

      DBMS_SQL.close_cursor (l_cursor_id);
      --Dbms_Output.Put_Line('Name: ' || l_name);
      --Dbms_Output.Put_Line('Description: ' || l_desc);
      --RETURN(l_name);
      x_name := l_name;
      x_description := l_desc;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := okc_api.g_ret_sts_unexp_error;
         x_name := NULL;
         x_description := NULL;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   --return(l_name);
   END get_line_name_if_null;

   PROCEDURE oks_get_salesrep (
      p_contact_id      IN              NUMBER DEFAULT NULL,
      p_contract_id                     NUMBER,
      x_salesdetails    OUT NOCOPY      salesrec_type,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_get_source_csr (p_salesrep_id NUMBER, p_authorg_id NUMBER)
      IS
         SELECT source_id
           FROM jtf_rs_resource_extns re, jtf_rs_salesreps sr
          WHERE sr.resource_id = re.resource_id
            AND sr.salesrep_id = p_salesrep_id
            AND (sr.org_id = p_authorg_id OR p_authorg_id IS NULL);

      l_source_id     NUMBER;

      CURSOR l_salesrep_curs (p_source_id NUMBER)
      IS
         SELECT ppl.employee_number employee_number, ppl.full_name full_name,
                ppl.work_telephone phone, NULL fax,
                LOWER (ppl.email_address) email, job.NAME job_title,
                loc.address_line_1 address1, loc.address_line_2 address2,
                loc.address_line_3 address3, NULL concatenated_address,
                loc.town_or_city city, loc.postal_code postal_code,
                loc.region_2 state, NULL province, NULL county,
                loc.country country, asg.supervisor_id mgr_id,
                emp.full_name mgr_name, ppl.business_group_id org_id,
                org.NAME org_name, ppl.first_name first_name,
                ppl.last_name last_name, ppl.middle_names middle_name,
                LOWER (ppl.attribute26) new_email
           FROM per_all_people_f ppl,
                hr_all_organization_units org,
                per_all_assignments_f asg,
                per_jobs job,
                hr_locations loc,
                per_all_people_f emp
          WHERE ppl.person_id = p_source_id
            AND TRUNC (SYSDATE) BETWEEN ppl.effective_start_date
                                    AND ppl.effective_end_date
            AND ppl.employee_number IS NOT NULL
            AND ppl.business_group_id = org.organization_id
            AND ppl.person_id = asg.person_id
            AND asg.primary_flag = 'Y'
            AND asg.assignment_type = 'E'
            AND TRUNC (SYSDATE) BETWEEN asg.effective_start_date
                                    AND asg.effective_end_date
            AND asg.job_id = job.job_id(+)
            AND asg.location_id = loc.location_id(+)
            AND asg.supervisor_id = emp.person_id(+)
            AND TRUNC (SYSDATE) BETWEEN emp.effective_start_date(+) AND emp.effective_end_date(+)
            AND NOT EXISTS (
                   SELECT   pep.person_id
                       FROM per_all_people_f pep, per_all_assignments_f asg1
                      WHERE pep.person_id = ppl.person_id
                        AND TRUNC (SYSDATE) BETWEEN pep.effective_start_date
                                                AND pep.effective_end_date
                        AND pep.employee_number IS NOT NULL
                        AND pep.person_id = asg1.person_id
                        AND asg1.primary_flag = 'Y'
                        AND asg1.assignment_type = 'E'
                        AND TRUNC (SYSDATE) BETWEEN asg1.effective_start_date
                                                AND asg1.effective_end_date
                   GROUP BY pep.person_id
                     HAVING COUNT (pep.person_id) > 1);

      l_sales_rec     salesrec_type;

      CURSOR l_phone_csr (p_source_id NUMBER, p_phone_type VARCHAR2)
      IS
         SELECT phone_number
           FROM per_phones
          WHERE parent_id = p_source_id
            AND phone_type = p_phone_type
            AND parent_table = 'PER_ALL_PEOPLE_F'
            AND TRUNC (SYSDATE) BETWEEN date_from AND NVL (date_to, SYSDATE);

      -- Following cursor definition was modified to add check for JTOT_OBJECT1_CODE
      -- and a check for sales person effectivity dates. If there are multiple active
      -- salesrep for a single contract, cursor will return the salesrep who has a
      -- start date closest to the current date (sysdate). This requirement was a part
      -- of territory stamping project.

      --  Cursor l_chr_csr Is
      -- select vc.object1_id1
      --       ,kh.authoring_org_id
      --  From   okc_k_headers_b   kh
      --       ,okc_k_party_roles_B pr
      --       ,okc_contacts      vc
      --  Where  kh.id          = p_contract_id
      -- And    pr.chr_id      = p_contract_id
      -- And    vc.dnz_chr_id  = p_contract_id
      -- And    vc.cpl_id      = pr.id
      -- And    pr.rle_code          = 'VENDOR'
      -- And    vc.JTOT_OBJECT1_CODE = 'OKX_SALEPERS'
      -- And    trunc(sysdate) between nvl(vc.start_date,sysdate-1)
      -- and nvl(vc.end_date,sysdate) ;
      CURSOR l_chr_csr
      IS
         SELECT vc.object1_id1, kh.authoring_org_id
           FROM okc_k_headers_b kh, okc_k_party_roles_b pr, okc_contacts vc
          WHERE kh.ID = p_contract_id
            AND pr.chr_id = p_contract_id
            AND vc.dnz_chr_id = p_contract_id
            AND vc.cpl_id = pr.ID
            AND pr.rle_code = 'VENDOR'
            AND vc.jtot_object1_code = 'OKX_SALEPERS'
            AND vc.ID =
                   oks_extwar_util_pvt.active_salesrep (kh.ID,
                                                        pr.ID,
                                                        kh.authoring_org_id
                                                       );

      l_salesrep_id   NUMBER;
      l_authorg_id    NUMBER;
   BEGIN
/** Code modified to add parameter p_contact_id, to handle situation if a
    contract does not exist -- 08/03/2001  - aiyengar **/
      IF p_contact_id IS NOT NULL
      THEN
         l_salesrep_id := p_contact_id;
      ELSE
         OPEN l_chr_csr;

         FETCH l_chr_csr
          INTO l_salesrep_id, l_authorg_id;

         CLOSE l_chr_csr;
      END IF;

      IF l_salesrep_id IS NULL
      THEN
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                                 'NO CONTACT FOUND FOR CONTRACT ID '
                              || p_contract_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      OPEN l_get_source_csr (l_salesrep_id, l_authorg_id);

      FETCH l_get_source_csr
       INTO l_source_id;

      CLOSE l_get_source_csr;

      IF l_source_id IS NULL
      THEN
         okc_api.set_message (g_app_name,
                              g_required_value,
                              g_col_name_token,
                              'NO SOURCE FOUND FOR SALESREP ' || l_salesrep_id
                             );
         RAISE g_exception_halt_validation;
      END IF;

      OPEN l_salesrep_curs (l_source_id);

      FETCH l_salesrep_curs
       INTO x_salesdetails;

      CLOSE l_salesrep_curs;

      IF x_salesdetails.phone IS NULL
      THEN
         OPEN l_phone_csr (l_source_id, 'W1');

         FETCH l_phone_csr
          INTO x_salesdetails.phone;

         CLOSE l_phone_csr;
      END IF;

      IF x_salesdetails.fax IS NULL
      THEN
         OPEN l_phone_csr (l_source_id, 'WF');

         FETCH l_phone_csr
          INTO x_salesdetails.fax;

         CLOSE l_phone_csr;
      END IF;

      x_salesdetails.concatenated_address :=
            x_salesdetails.address1
         || ', '
         || x_salesdetails.address2
         || x_salesdetails.address3
         || ', '
         || x_salesdetails.city
         || ', '
         || x_salesdetails.state
         || '-'
         || x_salesdetails.postal_code;
      x_return_status := 'S';
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status := 'E';
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

-------------------------------------------------------------------------------------
   PROCEDURE calculate_rev_rec (
      p_conc_request_id   IN   NUMBER,
      p_contract_group    IN   NUMBER,
      p_orgid             IN   NUMBER,
      p_forfdate          IN   DATE,
      p_fortdate          IN   DATE,
      p_min               IN   NUMBER,
      p_max               IN   NUMBER,
      p_regz_date         IN   DATE,
      p_curr              IN   VARCHAR2
   )
   IS
-- /*
--  CURSOR l_kh_csr IS
--  SELECT kh.currency_code,
--         kh.sts_code,
--         kh.id contract_id,
--         Nvl(rul.rule_information1,0) percent,
--         st.ste_code
--    FROM okc_k_headers_b kh,
--         okc_statuses_b  st,
--         okc_rules_b    rul
--   WHERE kh.authoring_org_id = NVL(p_orgid,kh.authoring_org_id)
--     AND kh.sts_code = st.code
--     AND st.ste_code = 'ENTERED'
--     AND rul.dnz_chr_id (+) = kh.id
--     AND rul.rule_information_category (+) = 'RVE'
--     AND ((nvl(to_date(rul.rule_information2,'YYYY/MM/DD HH24:MI:SS'),p_ForFDate) >= p_ForFDate)
--          OR
--          (p_ForFDate IS NULL))
--     AND ((nvl(to_date(rul.rule_information2,'YYYY/MM/DD HH24:MI:SS'),p_ForTDate) <= p_ForTDate)
--          OR
--          (p_ForTDate IS NULL))
  -- AND nvl(to_date(rul.rule_information2,'YYYY/MM/DD HH24:MI:SS'),p_ForFDate)
  --     BETWEEN p_ForFDate And p_ForTDate
--     AND kh.currency_code = NVL(p_curr,kh.currency_code)
--   ORDER BY kh.currency_code,kh.sts_code;
-- */

      --CURSOR l_kh_csr IS
--  SELECT kh.currency_code,
--         kh.sts_code,
--         kh.id contract_id,
--         Nvl(rul.est_rev_percent,0) percent,
--         st.ste_code
--    FROM okc_k_headers_b kh,
--         okc_statuses_b  st,
--         oks_k_headers_b rul
--   WHERE kh.authoring_org_id = NVL(p_orgid,kh.authoring_org_id)
--     AND kh.scs_code in ('SERVICE','WARRANTY')
--     AND kh.sts_code = st.code
--     AND st.ste_code = 'ENTERED'
--     AND rul.chr_id (+) = kh.id
--     AND ((nvl(EST_REV_DATE,p_ForFDate) >= p_ForFDate)
--          OR
--          (p_ForFDate IS NULL))
--     AND ((nvl(EST_REV_DATE,p_ForTDate) <= p_ForTDate)
--          OR
--          (p_ForTDate IS NULL))
--     AND kh.currency_code = NVL(p_curr,kh.currency_code)
--     AND ((p_Contract_Group IS NULL)
--                OR
--                ( kh.id in ( select INCLUDED_CHR_ID from okc_k_grpings
--                start with CGP_PARENT_ID = p_contract_group
--                connect by CGP_PARENT_ID = PRIOR INCLUDED_CGP_ID )))
--   ORDER BY kh.currency_code,kh.sts_code;

      -- To resolve bug#3874970, SQL commented above has been split into 4 SQL's
-- 1. All parameters supplied by the user
      CURSOR l_kh_csr1
      IS
         SELECT   kh.currency_code, kh.sts_code, kh.ID contract_id,
                  NVL (rul.est_rev_percent, 0) PERCENT, st.ste_code
             FROM okc_k_headers_b kh,
                  okc_statuses_b st,
                  oks_k_headers_b rul,
                  (SELECT     included_chr_id
                         FROM okc_k_grpings
                   START WITH cgp_parent_id = p_contract_group
                   CONNECT BY cgp_parent_id = PRIOR included_cgp_id) grp
            WHERE kh.authoring_org_id = p_orgid
              AND kh.scs_code IN ('SERVICE', 'WARRANTY')
              AND kh.sts_code = st.code
              AND st.ste_code = 'ENTERED'
              AND rul.chr_id(+) = kh.ID
              AND kh.ID = grp.included_chr_id
              AND rul.est_rev_date >= p_forfdate
              AND rul.est_rev_date <= p_fortdate
              AND kh.currency_code = p_curr
         ORDER BY kh.currency_code, kh.sts_code;

-- 2. Parameter Org ID not supplied
      CURSOR l_kh_csr2
      IS
         SELECT   kh.currency_code, kh.sts_code, kh.ID contract_id,
                  NVL (rul.est_rev_percent, 0) PERCENT, st.ste_code
             FROM okc_k_headers_b kh,
                  okc_statuses_b st,
                  oks_k_headers_b rul,
                  (SELECT     included_chr_id
                         FROM okc_k_grpings
                   START WITH cgp_parent_id = p_contract_group
                   CONNECT BY cgp_parent_id = PRIOR included_cgp_id) grp
            WHERE kh.scs_code IN ('SERVICE', 'WARRANTY')
              AND kh.sts_code = st.code
              AND st.ste_code = 'ENTERED'
              AND rul.chr_id(+) = kh.ID
              AND kh.ID = grp.included_chr_id
              AND rul.est_rev_date >= p_forfdate
              AND rul.est_rev_date <= p_fortdate
              AND kh.currency_code = p_curr
         ORDER BY kh.currency_code, kh.sts_code;

-- 3. Parameter Currency code not supplied
      CURSOR l_kh_csr3
      IS
         SELECT   kh.currency_code, kh.sts_code, kh.ID contract_id,
                  NVL (rul.est_rev_percent, 0) PERCENT, st.ste_code
             FROM okc_k_headers_b kh,
                  okc_statuses_b st,
                  oks_k_headers_b rul,
                  (SELECT     included_chr_id
                         FROM okc_k_grpings
                   START WITH cgp_parent_id = p_contract_group
                   CONNECT BY cgp_parent_id = PRIOR included_cgp_id) grp
            WHERE kh.authoring_org_id = p_orgid
              AND kh.scs_code IN ('SERVICE', 'WARRANTY')
              AND kh.sts_code = st.code
              AND st.ste_code = 'ENTERED'
              AND rul.chr_id(+) = kh.ID
              AND kh.ID = grp.included_chr_id
              AND rul.est_rev_date >= p_forfdate
              AND rul.est_rev_date <= p_fortdate
         ORDER BY kh.currency_code, kh.sts_code;

-- 4. Both, currency code and Org ID are not supplied
      CURSOR l_kh_csr4
      IS
         SELECT   kh.currency_code, kh.sts_code, kh.ID contract_id,
                  NVL (rul.est_rev_percent, 0) PERCENT, st.ste_code
             FROM okc_k_headers_b kh,
                  okc_statuses_b st,
                  oks_k_headers_b rul,
                  (SELECT     included_chr_id
                         FROM okc_k_grpings
                   START WITH cgp_parent_id = p_contract_group
                   CONNECT BY cgp_parent_id = PRIOR included_cgp_id) grp
            WHERE kh.scs_code IN ('SERVICE', 'WARRANTY')
              AND kh.sts_code = st.code
              AND st.ste_code = 'ENTERED'
              AND rul.chr_id(+) = kh.ID
              AND kh.ID = grp.included_chr_id
              AND rul.est_rev_date >= p_forfdate
              AND rul.est_rev_date <= p_fortdate
         ORDER BY kh.currency_code, kh.sts_code;

-----
      CURSOR l_kl_csr (p_kid NUMBER)
      IS
         SELECT SUM (price_negotiated)
           FROM okc_k_lines_b kl
          WHERE kl.dnz_chr_id = p_kid
            AND kl.lse_id IN (25, 7, 9, 10, 8, 35, 11)
            AND kl.price_negotiated BETWEEN 0 AND 90999999
         HAVING SUM (price_negotiated) BETWEEN NVL (p_min, 0)
                                           AND NVL (p_max, 99999999999999999);

      CURSOR l_klf_csr (p_kid NUMBER)
      IS
--   /*
--          Select
--          Sum ((price_negotiated)/(kl.end_date - kl.start_date+1) *
--                  (decode(sign(p_regz_date-kl.end_date),1,kl.end_date,p_regz_date) -
--                   decode(sign(p_regz_date+1-kl.start_date),1,kl.start_date,p_regz_date+1)
--                   + 1)
--                 )
--          From okc_k_lines_b kl
--          Where  kl.dnz_chr_id = p_kid And
--                 kl.lse_id in (25,7,9,10,8,35,11) And
--                 kl.price_negotiated between 0 and 90999999
--          Having Sum(price_negotiated) between p_min and p_max;
--   */
         SELECT NVL (SUM (  (  kl.price_negotiated
                             / CEIL (DECODE (SIGN (end_date - start_date),
                                             0, 1,
                                             (MONTHS_BETWEEN (kl.end_date,
                                                              kl.start_date
                                                             )
                                             )
                                            )
                                    )
                            )
                          * CEIL (DECODE (SIGN (p_regz_date - kl.start_date),
                                          0, 1,
                                          MONTHS_BETWEEN (p_regz_date,
                                                          kl.start_date
                                                         )
                                         )
                                 )
                         ),
                     0
                    )
           FROM okc_k_lines_b kl
          WHERE kl.dnz_chr_id = p_kid
            AND kl.lse_id IN (25, 7, 9, 10, 8, 35, 11)
            AND kl.price_negotiated BETWEEN 0 AND 90999999
            AND kl.start_date <= p_regz_date;

      CURSOR l_party_csr (l_chr_id NUMBER)
      IS
         SELECT ven.object1_id1, ven.ID, cust.object1_id1
           FROM okc_k_party_roles_b ven, okc_k_party_roles_b cust
          WHERE ven.dnz_chr_id = cust.dnz_chr_id
            AND ven.dnz_chr_id = l_chr_id
            AND ven.cle_id IS NULL
            AND ven.rle_code = 'VENDOR'
            AND cust.dnz_chr_id = l_chr_id
            AND cust.cle_id IS NULL
            AND cust.rle_code = 'CUSTOMER';

      CURSOR l_salesrep_csr (l_cpl_id NUMBER)
      IS
         SELECT 'Y'
           FROM okc_contacts con
          WHERE con.cpl_id = l_cpl_id
            AND con.jtot_object1_code = 'OKX_SALEPERS'
            AND con.cro_code IN ('SUP_SALES', 'SALESPERSON')
            AND TRUNC (SYSDATE) BETWEEN NVL (con.start_date, SYSDATE - 1)
                                    AND NVL (con.end_date, SYSDATE);

      TYPE kh_rectype IS RECORD (
         currency_code   okc_k_headers_b.currency_code%TYPE,
         sts_code        okc_k_headers_b.sts_code%TYPE,
         contract_id     okc_k_headers_b.ID%TYPE,
         PERCENT         VARCHAR2 (50),
         ste_code        okc_statuses_b.ste_code%TYPE
      );

      l_kh_rec               kh_rectype;
      l_curncy_status_prev   VARCHAR2 (200) := '~#~';
      l_curncy_status_curr   VARCHAR2 (200) := '~#~';
      l_curncy_prev          VARCHAR2 (200);
      l_curncy_curr          VARCHAR2 (200);
      l_status_curr          VARCHAR2 (200);
      l_status_prev          VARCHAR2 (200);
      l_ste_curr             VARCHAR2 (200);
      l_ste_prev             VARCHAR2 (200);
      l_ven_party            NUMBER;
      l_cpl_id               NUMBER;
      l_cust_party           NUMBER;
      l_salesrep_exists      VARCHAR2 (1);
      l_revrec_amount        NUMBER;
      l_kh_amount            NUMBER;
      l_forecast_amount      NUMBER;
      l_booking_forecast     NUMBER;
      l_k_amount             NUMBER;
      l_klf_amount           NUMBER;
      l_number_k             NUMBER;
      l_row_count            NUMBER;
-- p_sts_code            Varchar2(50);
-- p_currency            Varchar2(50);
-- l_firsttime           Boolean := TRUE;
-- l_fdate Date;
   BEGIN
-- Initialize variables
      l_revrec_amount := 0;
      l_kh_amount := 0;
      l_forecast_amount := 0;
      l_booking_forecast := 0;
      l_k_amount := 0;
      l_klf_amount := 0;
      l_number_k := 0;
      l_row_count := 0;

      DELETE FROM oks_status_forecast
            WHERE conc_request_id = p_conc_request_id;

      COMMIT;

--      fnd_file.put_line(FND_FILE.LOG, 'P_Orgid:  '||P_Orgid) ;
--      fnd_file.put_line(FND_FILE.LOG, 'P_Curr:  '||P_Curr) ;
      IF p_orgid IS NULL AND p_curr IS NULL
      THEN
         OPEN l_kh_csr4;
--      fnd_file.put_line(FND_FILE.LOG, 'l_kh_csr4') ;
      ELSIF p_orgid IS NULL AND p_curr IS NOT NULL
      THEN
         OPEN l_kh_csr2;
--      fnd_file.put_line(FND_FILE.LOG, 'l_kh_csr2') ;
      ELSIF p_orgid IS NOT NULL AND p_curr IS NULL
      THEN
         OPEN l_kh_csr3;
--      fnd_file.put_line(FND_FILE.LOG, 'l_kh_csr3') ;
      ELSIF p_orgid IS NOT NULL AND p_curr IS NOT NULL
      THEN
         OPEN l_kh_csr1;
--      fnd_file.put_line(FND_FILE.LOG, 'l_kh_csr1') ;
      END IF;

      -- For l_kh_rec in l_kh_csr
      LOOP
         IF l_kh_csr1%ISOPEN
         THEN
            FETCH l_kh_csr1
             INTO l_kh_rec.currency_code, l_kh_rec.sts_code,
                  l_kh_rec.contract_id, l_kh_rec.PERCENT, l_kh_rec.ste_code;

            EXIT WHEN l_kh_csr1%NOTFOUND;
            l_row_count := l_kh_csr1%ROWCOUNT;
         ELSIF l_kh_csr2%ISOPEN
         THEN
            FETCH l_kh_csr2
             INTO l_kh_rec.currency_code, l_kh_rec.sts_code,
                  l_kh_rec.contract_id, l_kh_rec.PERCENT, l_kh_rec.ste_code;

            EXIT WHEN l_kh_csr2%NOTFOUND;
            l_row_count := l_kh_csr2%ROWCOUNT;
         ELSIF l_kh_csr3%ISOPEN
         THEN
            FETCH l_kh_csr3
             INTO l_kh_rec.currency_code, l_kh_rec.sts_code,
                  l_kh_rec.contract_id, l_kh_rec.PERCENT, l_kh_rec.ste_code;

            EXIT WHEN l_kh_csr3%NOTFOUND;
            l_row_count := l_kh_csr3%ROWCOUNT;
         ELSIF l_kh_csr4%ISOPEN
         THEN
            FETCH l_kh_csr4
             INTO l_kh_rec.currency_code, l_kh_rec.sts_code,
                  l_kh_rec.contract_id, l_kh_rec.PERCENT, l_kh_rec.ste_code;

            EXIT WHEN l_kh_csr4%NOTFOUND;
            l_row_count := l_kh_csr4%ROWCOUNT;
         END IF;

         l_curncy_status_prev := l_curncy_status_curr;
         l_curncy_prev := l_curncy_curr;
         l_status_prev := l_status_curr;
         l_ste_prev := l_ste_curr;
         l_curncy_status_curr :=
               LTRIM (RTRIM (l_kh_rec.currency_code))
            || LTRIM (RTRIM (l_kh_rec.sts_code));
         l_curncy_curr := l_kh_rec.currency_code;
         l_status_curr := l_kh_rec.sts_code;
         l_ste_curr := l_kh_rec.ste_code;

         IF     (l_curncy_status_prev <> l_curncy_status_curr)
            AND (l_row_count <> 1)
         THEN
            --Insert into Forecast Summary Table...
            INSERT INTO oks_status_forecast
                        (conc_request_id, run_flag, run_time, status_type,
                         status_code, number_of_contracts, contract_value,
                         rev_rec_value, forecast_value,
                         booking_forecast, currency
                        )
                 VALUES (p_conc_request_id, 1, SYSDATE, l_ste_prev,
                         --'ENTERED',
                         l_status_prev, l_number_k, l_kh_amount,
                         l_revrec_amount, l_forecast_amount,
                         l_booking_forecast, l_curncy_prev
                        );

--           /*
--            l_Curncy_Status_Prev := l_Curncy_Status_Curr;
--            l_Curncy_Prev        := l_Curncy_Curr;
--            l_Status_Prev        := l_Status_Curr;
--            l_Ste_Prev           := l_Ste_Curr;
--           */
            --Initialize Forecast Summary Varibales...
            l_revrec_amount := 0;
            l_kh_amount := 0;
            l_forecast_amount := 0;
            l_booking_forecast := 0;
            l_number_k := 0;
         END IF;

         --Initialize Party and Sales rep cursor attributes
         l_ven_party := NULL;
         l_cust_party := NULL;
         l_cpl_id := NULL;
         l_salesrep_exists := NULL;

         OPEN l_party_csr (l_kh_rec.contract_id);

         FETCH l_party_csr
          INTO l_ven_party, l_cpl_id, l_cust_party;

         CLOSE l_party_csr;

         IF l_ven_party IS NOT NULL AND l_cust_party IS NOT NULL
         THEN
            OPEN l_salesrep_csr (l_cpl_id);

            FETCH l_salesrep_csr
             INTO l_salesrep_exists;

            CLOSE l_salesrep_csr;

            IF l_salesrep_exists IS NOT NULL
            THEN
               l_k_amount := 0;
               l_klf_amount := 0;

               OPEN l_kl_csr (l_kh_rec.contract_id);

               FETCH l_kl_csr
                INTO l_k_amount;

               CLOSE l_kl_csr;

               OPEN l_klf_csr (l_kh_rec.contract_id);

               FETCH l_klf_csr
                INTO l_klf_amount;

               CLOSE l_klf_csr;

               l_kh_amount := l_kh_amount + NVL (l_k_amount, 0);
               l_booking_forecast :=
                    l_booking_forecast
                  + (NVL (l_k_amount, 0) * l_kh_rec.PERCENT / 100);
               l_revrec_amount := l_revrec_amount + NVL (l_klf_amount, 0);
               l_forecast_amount :=
                    l_forecast_amount
                  + (NVL (l_klf_amount, 0) * l_kh_rec.PERCENT / 100);
               l_number_k := l_number_k + 1;
            END IF;
         END IF;
      END LOOP;

      IF l_kh_csr1%ISOPEN
      THEN
         CLOSE l_kh_csr1;
      ELSIF l_kh_csr2%ISOPEN
      THEN
         CLOSE l_kh_csr2;
      ELSIF l_kh_csr3%ISOPEN
      THEN
         CLOSE l_kh_csr3;
      ELSIF l_kh_csr4%ISOPEN
      THEN
         CLOSE l_kh_csr4;
      END IF;

      INSERT INTO oks_status_forecast
                  (conc_request_id, run_flag, run_time, status_type,
                   status_code, number_of_contracts, contract_value,
                   rev_rec_value, forecast_value, booking_forecast,
                   currency
                  )
           VALUES (p_conc_request_id, 1, SYSDATE, l_ste_curr,     --'ENTERED',
                   l_status_curr, l_number_k, l_kh_amount,
                   l_revrec_amount, l_forecast_amount, l_booking_forecast,
                   l_curncy_curr
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

------------------------------------------------------------------------------------
-- Function returns one active sales rep for a contract and
-- a contract party, VENDOR. If there are multiple active  sales reps,
-- function filter records first by start date, then by creation date
-- and then by their names.
   FUNCTION active_salesrep (
      p_contract_id   IN   NUMBER,
      p_party_id      IN   NUMBER,
      p_org_id        IN   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR c_sales_rep (
         p_contract_id   IN   NUMBER,
         p_party_id      IN   NUMBER,
         p_org_id        IN   NUMBER
      )
      IS
         SELECT   con1.ID
             FROM okc_contacts con1, jtf_rs_salesreps salesrep
            WHERE con1.dnz_chr_id = p_contract_id
              AND jtot_object1_code = 'OKX_SALEPERS'
              AND con1.cpl_id = p_party_id
              AND TRUNC (SYSDATE) BETWEEN NVL (con1.start_date, SYSDATE - 1)
                                      AND NVL (con1.end_date, SYSDATE)
              AND NVL (con1.start_date, TO_DATE (1, 'J')) IN (
                     SELECT MAX (NVL (con2.start_date, TO_DATE (1, 'J')))
                       FROM okc_contacts con2
                      WHERE con2.dnz_chr_id = p_contract_id
                        AND jtot_object1_code = 'OKX_SALEPERS'
                        AND con2.cpl_id = p_party_id
                        AND TRUNC (SYSDATE) BETWEEN NVL (con2.start_date,
                                                         SYSDATE - 1
                                                        )
                                                AND NVL (con2.end_date,
                                                         SYSDATE
                                                        ))
              AND salesrep.salesrep_id = TO_NUMBER (con1.object1_id1)
              AND salesrep.org_id = p_org_id
         ORDER BY con1.creation_date DESC, salesrep.NAME ASC;

      l_salesrep_id   NUMBER;
   BEGIN
      OPEN c_sales_rep (p_contract_id, p_party_id, p_org_id);

      FETCH c_sales_rep
       INTO l_salesrep_id;

      CLOSE c_sales_rep;

      RETURN (l_salesrep_id);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (NULL);
   END active_salesrep;

-------------------------------------------------------------------------------------
   FUNCTION check_already_billed (
      p_chr_id     IN   NUMBER,
      p_cle_id     IN   NUMBER,
      p_lse_id     IN   NUMBER,
      p_end_date   IN   DATE
   )
      RETURN BOOLEAN
   IS
      CURSOR l_hdr_bill_cont_lines_csr
      IS
         SELECT TRUNC (MAX (date_billed_to))
           FROM oks_bill_cont_lines
          WHERE cle_id IN (
                    SELECT ID
                      FROM okc_k_lines_b
                     WHERE dnz_chr_id = p_chr_id
                           AND lse_id IN (1, 12, 14, 19));

      CURSOR l_bill_cont_line_csr
      IS
         SELECT TRUNC (MAX (date_billed_to))
           FROM oks_bill_cont_lines
          WHERE cle_id = p_cle_id;

      CURSOR l_bill_sub_line_csr
      IS
         SELECT TRUNC (MAX (date_billed_to))
           FROM oks_bill_sub_lines
          WHERE cle_id = p_cle_id;

      l_max_dt_billed_to   DATE;
   BEGIN
      fnd_msg_pub.initialize;

---IF RETURNS FALSE That means it is not billed
---IF RETURNS true That means it is billed and dates can not be changed.

      ------ERROROUT NOCOPY _AD('Check_Billed p_chr_id = ' || p_chr_id);
------ERROROUT NOCOPY _AD('Check_Billed p_cle_id = ' || p_cle_id);
      IF p_chr_id IS NULL AND p_cle_id IS NULL
      THEN
         RETURN NULL;
      ELSIF p_cle_id IS NOT NULL AND p_lse_id IS NULL
      THEN
         RETURN NULL;
      END IF;

      IF (    p_cle_id IS NOT NULL
          AND (p_lse_id = 1 OR p_lse_id = 12 OR p_lse_id = 14 OR p_lse_id = 19
              )
         )
      THEN                                                          --TOP LINE
         OPEN l_bill_cont_line_csr;

         FETCH l_bill_cont_line_csr
          INTO l_max_dt_billed_to;

         IF l_bill_cont_line_csr%NOTFOUND
         THEN
            CLOSE l_bill_cont_line_csr;

            RETURN FALSE;
         END IF;

         CLOSE l_bill_cont_line_csr;
      ELSIF p_chr_id IS NOT NULL
      THEN                                                           ---HEADER
         OPEN l_hdr_bill_cont_lines_csr;

         FETCH l_hdr_bill_cont_lines_csr
          INTO l_max_dt_billed_to;

         IF l_hdr_bill_cont_lines_csr%NOTFOUND
         THEN
            CLOSE l_hdr_bill_cont_lines_csr;

            RETURN FALSE;
         END IF;

         CLOSE l_hdr_bill_cont_lines_csr;
      ELSE                                                   -----PRODUCT LINE
         OPEN l_bill_sub_line_csr;

         FETCH l_bill_sub_line_csr
          INTO l_max_dt_billed_to;

         IF l_bill_sub_line_csr%NOTFOUND
         THEN
            CLOSE l_bill_sub_line_csr;

            RETURN FALSE;
         END IF;

         CLOSE l_bill_sub_line_csr;
      END IF;

---ERROROUT NOCOPY _AD('l_max_dt_billed_to = ' || l_max_dt_billed_to);
      IF p_end_date IS NOT NULL
      THEN
         IF l_max_dt_billed_to IS NULL
         THEN
            RETURN FALSE;
         ELSIF TRUNC (p_end_date) >= l_max_dt_billed_to
         THEN
            RETURN FALSE;
         ELSE                ----TRUNC(p_end_date) < TRUNC(l_max_dt_billed_to)
            okc_api.set_message (g_app_name,
                                 'OKS_BILLED_CHECK',
                                 'MAX_BILLED_DATE',
                                 l_max_dt_billed_to
                                );
            RETURN TRUE;
         END IF;
      ELSE                                           -----  p_end_date IS NULL
         IF l_max_dt_billed_to IS NULL
         THEN
            RETURN FALSE;
         ELSE
            --OKC_API.set_message(G_APP_NAME,'OKS_BILLED_CHECK','MAX_BILLED_DATE',TO_CHAR(l_max_dt_billed_to,'DD-MON-YYYY HH24:MI:SS'));
            okc_api.set_message (g_app_name, 'OKS_BA_UPDATE_NOT_ALLOWED');
            RETURN TRUE;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (NULL);
   END check_already_billed;
END oks_extwar_util_pvt;

/
