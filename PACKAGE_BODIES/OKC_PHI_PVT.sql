--------------------------------------------------------
--  DDL for Package Body OKC_PHI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PHI_PVT" AS
/* $Header: OKCRPHIB.pls 120.0 2005/05/25 19:47:34 appldev noship $  */

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN                 CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN                 CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKC_PHI_PVT';
G_APP_NAME                      CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

TYPE qp_relship_rec_typ IS RECORD
  (
        id                    okc_k_lines_b.id%TYPE,  --Cle id, or line break id
        object_version_number okc_k_lines_b.object_version_number%type,
        line_type             VARCHAR2(30),-- PRICE_HOLD,PH_LINE,PH_LINE_BREAK
        modifier_tbl_index      number
   );



TYPE l_qp_ph_relship_tbl_type IS TABLE OF qp_relship_rec_typ INDEX BY BINARY_INTEGER;

l_qp_ph_relship_tbl      l_qp_ph_relship_tbl_type ; -- table to keep relationship between modifier heaer/line to Contract line

l_clev_tbl               okc_cle_pvt.clev_tbl_type ;
lx_clev_tbl              okc_cle_pvt.clev_tbl_type ;
l_ph_line_breaks_tbl     okc_phl_pvt.okc_ph_line_breaks_v_tbl_type;
lx_ph_line_breaks_tbl    okc_phl_pvt.okc_ph_line_breaks_v_tbl_type;
l_call_qp_api            boolean := false;
l_cust_found             boolean := false;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
/*
-------------------------------------------------------------------------------------------------------------------------
--Procedure : Process_price_hold
--  Input Parameter : p_chr_id Contract Id of contract which has price hold on it.
--                    P_opreation_code   Possible value UPDATE and TERMINATE
--
-- IF this API is called for a contract for the first time with operation UPDATE THEN it creates a Modifier  in QP.
--
-- IF this API is called for a contract for the another time with operation UPDATE THEN it updates a Modifier .
-- in QP and creates new Modifier line IF new liens have been added to contract.
--
-- IF this API is called for a contract with operation TERMINATE THEN it de-activates a Modifier in QP.

-- This API will be called whenever a contract/contract line is activated or Terminated or cancelled.
---------------------------------------------------------------------------------------------------------------------------------
*/

PROCEDURE process_price_hold(p_api_version      IN NUMBER
                             ,p_init_msg_list   IN VARCHAR2
                             ,p_chr_id          IN OKC_K_HEADERS_V.id%TYPE
                             ,p_operation_code  IN VARCHAR2
                             ,p_termination_date  IN DATE
                             ,p_unconditional_call  IN varchar2
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             ) IS

-- Get informationm from Contract Header

 Cursor c_k_header(b_chr_id Number) IS
 SELECT chr.id ID,
        chr.contract_number CONTRACT_NUMBER,
        chr.short_description short_description,
        chr.Currency_code currency_code,
        chr.Contract_number_modifier contract_number_modifier,
        chr.start_date start_date,
        chr.end_date end_date,
        chr.authoring_org_id authoring_org_id,
        chr.inv_organization_id inv_organization_id
 FROM okc_k_headers_V chr
 WHERE chr.id=b_chr_id
 and   chr.application_id in (510,871)
 AND   chr.buy_or_sell='S'
 AND   chr.issue_or_receive='I'
 AND   chr.template_yn='N'
 AND   chr.deleted_yn='N';

-- Get informationm from price hold header( means from Price Hold top line)

 Cursor c_ph_header(b_chr_id Number) IS
 SELECT id ,
        object_version_number,
        ph_min_qty,  -- Minimum Order Quantity
        ph_min_amt,  -- Minimum Order Amount
        ph_qp_reference_id,
        ph_enforce_price_list_yn,
        decode(p_unconditional_call,'Y','N',ph_integrated_with_qp) ph_integrated_with_qp,
        start_date,
        end_date,
        price_list_id,
        date_terminated
FROM okc_k_lines_v cle
WHERE cle.dnz_chr_id=b_chr_id
AND   cle.cle_id is null
AND   cle.lse_id=61  -- Price Hold Line style.
AND   nvl(cle.end_date,sysdate+1) > Sysdate
AND   rownum=1;

-- Get price hold line information

Cursor c_ph_lines(b_cle_id Number) IS
 SELECT cle.id id,
        cle.object_version_number object_version_number,
        cle.line_number line_number,
        cle.lse_id  lse_id,
        ph_pricing_type,
        ph_price_break_basis,
        ph_min_qty,  -- Minimum Line Quantity
        ph_min_amt,  -- Minimum Line Amount
        ph_value,
        ph_qp_reference_id,
        ph_integrated_with_qp,
        start_date,
        end_date,
        jtot_object1_code,
        object1_id1,
        object1_id2,
        uom_code
FROM okc_k_lines_v cle,
     okc_k_items_v cim
WHERE cle.cle_id=b_cle_id
AND   cle.id=cim.cle_id
ORDER BY line_number;

-- Get price hold line break information

Cursor c_ph_line_break(b_ph_line_id Number) IS
 SELECT id ,
        object_version_number,
        pricing_type,
        value_from,
        value_to,
        value,
        qp_reference_id,
        integrated_with_qp
FROM okc_ph_line_breaks_v
WHERE cle_id=b_ph_line_id
AND   nvl(integrated_with_qp,'N')='N'
order by id;

-- Header level qualifier info for a modifier
Cursor c_ph_header_qual(b_list_header_id number) IS
SELECT qualifier_id
FROM qp_qualifiers_v
WHERE list_header_id=b_list_header_id
AND   list_line_id=-1;

-- Get Pricing attribute info of a modifier

CURSOR c_ph_get_pattr_id(b_list_line_id Number,b_list_header_id Number) IS
SELECT pricing_attribute_id
FROM qp_pricing_attributes
WHERE LIST_LINE_ID=b_list_line_id
AND   LIST_HEADER_ID=b_list_header_id;

-- Get Price Hold rule info

CURSOR c_ph_rules(b_chr_id number) IS
SELECT
    rgp.chr_id
   ,rgp.cle_id
   ,rul.object1_id1
   ,rul.object1_id2
   ,rul.jtot_object1_code
   ,rul.object2_id1
   ,rul.object2_id2
   ,rul.jtot_object2_code
   ,rul.object3_id1
   ,rul.object3_id2
   ,rul.jtot_object3_code
   ,rul.rule_information_category
   ,rul.rule_information1
FROM okc_rule_groups_b    rgp
    ,okc_rules_b          rul
WHERE rgp.dnz_chr_id   = b_chr_id
AND rgp.cle_id IS NULL
AND rul.rgp_id         = rgp.id
AND rul.rule_information_category IN ( 'SMD', 'CAN', 'FRT','PTR');


l_k_header                c_k_header%rowtype;
l_ph_header               c_ph_header%rowtype;
l_ph_lines                c_ph_lines%rowtype;
l_ph_line_breaks          c_ph_line_break%rowtype;
l_ph_rules                c_ph_rules%rowtype;
l_ph_header_qual          c_ph_header_qual%rowtype;

l_control_rec             QP_GLOBALS.Control_Rec_Type;
l_return_status           VARCHAR2(1);
l_msg_index               NUMBER;
l_cnt                     NUMBER := 0;
l_hdr_qual_cnt            NUMBER := 0;
l_line_cnt                NUMBER := 0;
l_line_pattr_cnt          NUMBER := 0;
l_line_breaks_cnt         NUMBER := 0;
l_line_breaks_pattr_cnt   NUMBER := 0;
l_qp_rlship_cnt           NUMBER := 0;
cle_cnt                   NUMBER := 0; -- count of lines being updated in okc_k_lines_b with new qp references;
phl_cnt                   NUMBER := 0; -- count of lines being updated in okc_ph_line_breaks with new qp references;
-- Modifier API related variables
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIER_LIST_val_rec       QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_MODIFIERS_val_tbl           QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_QUALIFIERS_val_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_PRICING_ATTR_val_tbl        QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIER_LIST_val_rec     QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_MODIFIERS_val_tbl         QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_QUALIFIERS_val_tbl        QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICING_ATTR_val_tbl      QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;


BEGIN
  Fnd_Msg_Pub.Initialize;
IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'start process_price_hold');
END IF;

l_call_qp_api := false;
l_cust_found  := false;
l_cnt := 0;
l_hdr_qual_cnt := 0;
l_line_cnt := 0;
l_line_breaks_cnt := 0;
l_line_breaks_pattr_cnt := 0;
l_line_pattr_cnt := 0;
l_qp_rlship_cnt := 0;
l_qp_ph_relship_tbl.delete;
l_clev_tbl.delete;
lx_clev_tbl.delete;
l_ph_line_breaks_tbl.delete;
lx_ph_line_breaks_tbl.delete;
cle_cnt := 0;
phl_cnt := 0;

OPEN c_k_header(p_chr_id);
FETCH c_k_header into l_k_header;

IF c_k_header%found then

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'Contract is a Sell contract and is not a template');
END IF;

    OPEN c_ph_header(p_chr_id);


    FETCH c_ph_header into l_ph_header;


    IF c_ph_header%found
       AND l_ph_header.DATE_TERMINATED IS NULL
       AND p_operation_code='UPDATE' then

       -- This is the case of creation and updation of Modfiers .

       fnd_profile.put('QP_SOURCE_SYSTEM_CODE','OKC');
       --Setting the QP system Profile Option to OKC.so that Modifier cannot be updated from QP screens.

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2,'Profile Option QP_SOURCE_SYSTEM_CODE set to OKC');
       END IF;


       IF nvl(l_ph_header.ph_integrated_with_qp,'N')='N' then

                  l_call_qp_api := true;
                  l_MODIFIER_LIST_rec.currency_code := l_k_header.currency_code;
                  l_MODIFIER_LIST_rec.list_type_code := 'DLT';
                  l_MODIFIER_LIST_rec.start_date_active := l_ph_header.start_date;
                  l_MODIFIER_LIST_rec.end_date_active := l_ph_header.end_date;
                  l_MODIFIER_LIST_rec.source_system_code := 'OKC';
                  l_MODIFIER_LIST_rec.active_flag := 'Y';
                  l_MODIFIER_LIST_rec.automatic_flag := 'Y';


                  IF l_ph_header.ph_qp_reference_id IS Null then
                     -- This is case of creation of  Modifiers

                      IF (l_debug = 'Y') THEN
                         okc_util.print_trace(2,'Modifier needs to be created');
                      END IF;
                      l_MODIFIER_LIST_rec.comments := l_k_header.short_description;

                      OKC_API.set_message(p_app_name      => g_app_name, --OKC
                                          p_msg_name      => 'OKC_PH_MODIFIER_NAME',
                                          p_token1        => 'KNUMBER',
		                          p_token1_value  => l_k_header.contract_number,
		                          p_token2        => 'KMODIFIER',
		                          p_token2_value  => nvl(l_k_header.contract_number_modifier,' '));

                     l_MODIFIER_LIST_rec.description := ltrim(rtrim(Fnd_Msg_Pub.Get( p_msg_index => Fnd_Msg_Pub.G_LAST, p_encoded => FND_API.G_FALSE )));  --Modifier Name Transalated
                     l_MODIFIER_LIST_rec.name := l_modifier_list_rec.description;

                      l_MODIFIER_LIST_rec.version_no := '0.1';
                      l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;

                   IF (l_debug = 'Y') THEN

                      okc_util.print_trace(2,'Modifer Name : '|| l_MODIFIER_LIST_rec.name );
                   END IF;


                  /* Updating qp-okc relationship . This table will be used to update okc table with qp_refrence */

                  l_qp_rlship_cnt := l_qp_rlship_cnt +1;
                  l_qp_ph_relship_tbl(l_qp_rlship_cnt).id := l_ph_header.id;
                  l_qp_ph_relship_tbl(l_qp_rlship_cnt).object_version_number := l_ph_header.object_version_number;
                  l_qp_ph_relship_tbl(l_qp_rlship_cnt).line_type := 'PRICE_HOLD';

              ELSE

                 -- This is case of updation of Modifiers

                l_MODIFIER_LIST_rec.list_header_id := l_ph_header.ph_qp_reference_id;
                l_MODIFIER_LIST_rec.operation      := QP_GLOBALS.G_OPR_UPDATE;


               /* Updating qp-okc relationship . This table will be used to update okc table with qp_refrence */

                l_qp_rlship_cnt := l_qp_rlship_cnt +1;
                l_qp_ph_relship_tbl(l_qp_rlship_cnt).id := l_ph_header.id;
                l_qp_ph_relship_tbl(l_qp_rlship_cnt).object_version_number := l_ph_header.object_version_number;
                l_qp_ph_relship_tbl(l_qp_rlship_cnt).line_type := 'PRICE_HOLD';

              END IF; -- IF l_ph_header.ph_qp_reference_id IS Null

              IF l_ph_header.ph_qp_reference_id IS Not Null then

                --  Checking if any qualifer was created when modifier was created for the first time. IF yes THEN deleting those qualifers.

                 OPEN c_ph_header_qual(l_ph_header.ph_qp_reference_id);

                 LOOP

                   FETCH c_ph_header_qual into l_ph_header_qual;
                   exit when c_ph_header_qual%notfound;
                   l_hdr_qual_cnt := l_hdr_qual_cnt +1;
                   l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_id := l_ph_header_qual.qualifier_id;
                   l_QUALIFIERS_tbl(l_hdr_qual_cnt).operation := QP_GLOBALS.G_OPR_DELETE;

                 END LOOP;
                 CLOSE c_ph_header_qual;
             END IF; -- IF l_ph_header.ph_qp_reference_id IS Not Null then


                 -- Creating Header level qualifier for Contract Number
               l_hdr_qual_cnt := l_hdr_qual_cnt +1;
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).excluder_flag := 'N';
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).comparison_operator_code := '=';
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_context := 'CUSTOMER';
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attribute := 'QUALIFIER_ATTRIBUTE31';
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value := p_chr_id;
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_grouping_no := -1;
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).start_date_active := l_ph_header.start_date;
               l_QUALIFIERS_tbl(l_hdr_qual_cnt).operation := QP_GLOBALS.G_OPR_CREATE;
                 -- Creating Header level qualifier for price list

                IF nvl(l_ph_header.ph_enforce_price_list_yn,'N')='Y' then

                    l_hdr_qual_cnt := l_hdr_qual_cnt +1;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).excluder_flag := 'N';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).comparison_operator_code := '=';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_context := 'MODLIST';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attribute := 'QUALIFIER_ATTRIBUTE4';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value := l_ph_header.price_list_id;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_grouping_no := -1;
           --       l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_precedence := 1;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).start_date_active := l_ph_header.start_date;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).operation := QP_GLOBALS.G_OPR_CREATE;
                    IF (l_debug = 'Y') THEN
                       okc_util.print_trace(2,'Qualifier Enforce Price List id '||l_ph_header.price_list_id);
                    END IF;

                END IF; --  IF nvl(l_ph_header.ph_enforce_price_list_yn,'N')='Y' then

               -- Creating Header level qualifier to enforce Minimum Order Amount Condition

                IF l_ph_header.ph_min_amt is Not Null then

                    l_hdr_qual_cnt := l_hdr_qual_cnt +1;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).excluder_flag := 'N';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).comparison_operator_code := 'BETWEEN';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_context := 'VOLUME';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attribute := 'QUALIFIER_ATTRIBUTE10';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value := l_ph_header.ph_min_amt;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value_to :=  999999999999999999999;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_grouping_no := -1;
           --       l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_precedence := 1;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).start_date_active := l_ph_header.start_date;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).operation := QP_GLOBALS.G_OPR_CREATE;
                    IF (l_debug = 'Y') THEN
                       okc_util.print_trace(2,'Qualifier Minimum Purchase Order Amount '||l_ph_header.ph_min_amt);
                    END IF;

                END IF;  -- IF l_ph_header.ph_min_amt is Not Null then



                 -- Creating Header level qualifier to enforce Minimum Order qty Condition

                IF l_ph_header.ph_min_qty is Not Null then

                    l_hdr_qual_cnt := l_hdr_qual_cnt +1;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).excluder_flag := 'N';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).comparison_operator_code := 'BETWEEN';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_context := 'VOLUME';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attribute := 'QUALIFIER_ATTRIBUTE17';
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value := l_ph_header.ph_min_qty;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value_to :=  999999999999999999999;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_grouping_no := -1;
       --           l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_precedence := 1;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).start_date_active := l_ph_header.start_date;
                    l_QUALIFIERS_tbl(l_hdr_qual_cnt).operation := QP_GLOBALS.G_OPR_CREATE;
                    IF (l_debug = 'Y') THEN
                       okc_util.print_trace(2,'Qualifier Minimum Purchase Order Qty '||l_ph_header.ph_min_qty);
                    END IF;

                END IF; -- IF l_ph_header.ph_min_qty is Not Null then

                OPEN c_ph_rules(p_chr_id);

	        LOOP
                    FETCH c_ph_rules into l_ph_rules;
                    exit when c_ph_rules%notfound;

	       	   IF l_ph_rules.rule_information_category='CAN' THEN

		      l_cust_found := true;
                      l_hdr_qual_cnt := l_hdr_qual_cnt +1;
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).excluder_flag := 'N';
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).comparison_operator_code := '=';
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_context := 'CUSTOMER';
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attribute := 'QUALIFIER_ATTRIBUTE2';
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_attr_value := l_ph_rules.object1_id1;
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_grouping_no := -1;
         --           l_QUALIFIERS_tbl(l_hdr_qual_cnt).qualifier_precedence := 1;
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).start_date_active := l_ph_header.start_date;
                      l_QUALIFIERS_tbl(l_hdr_qual_cnt).operation := QP_GLOBALS.G_OPR_CREATE;
                      IF (l_debug = 'Y') THEN
                         okc_util.print_trace(2,'Qualifier Customer Account '||l_ph_rules.object1_id1);
                      END IF;


                  END IF;

              END LOOP;

              CLOSE c_ph_rules;

              IF not l_cust_found THEN

                  OKC_API.set_message(p_app_name   => g_app_name, --OKC
                                      p_msg_name   => 'OKC_NO_PRICE_HOLD_CAN');

                  IF (l_debug = 'Y') THEN
                     okc_util.print_trace(2,'No Customer Account found');
                  END IF;

                  RAISE OKC_API.G_EXCEPTION_ERROR;

              END IF;

      END IF; --  IF nvl(l_ph_header.ph_integrated_with_qp,'N')='N' then

       -- Start Creating Modifier Lines
       OPEN c_ph_lines(l_ph_header.id);

       LOOP
          FETCH c_ph_lines INTO l_ph_lines;
          EXIT WHEN c_ph_lines%NOTFOUND;

          IF nvl(l_ph_lines.ph_integrated_with_qp,'N')='N' THEN

               l_call_qp_api := true;
               l_line_cnt := l_line_cnt + 1;

               IF l_ph_lines.ph_qp_reference_id IS NULL THEN

                     l_MODIFIERS_tbl(l_line_cnt).automatic_flag:= 'Y';
                     l_MODIFIERS_tbl(l_line_cnt).modifier_level_code := 'LINE';
                     l_MODIFIERS_tbl(l_line_cnt).pricing_phase_id := 2;
                     l_MODIFIERS_tbl(l_line_cnt).product_precedence := -9999;
                     l_MODIFIERS_tbl(l_line_cnt).list_line_type_code := 'DIS';
                     l_MODIFIERS_tbl(l_line_cnt).operation := QP_GLOBALS.G_OPR_CREATE;


/* IF Modifer has already been created before and new line is being added.In that case Modifier line table needs List header id */

                   IF l_ph_header.ph_qp_reference_id IS NOT NULL THEN

                         l_MODIFIERS_tbl(l_line_cnt).list_header_id := l_ph_header.ph_qp_reference_id;

                   END IF;

                  /* Updating qp-okc relationship . This table will be used to update okc table with qp_refrence */

                     l_qp_rlship_cnt := l_qp_rlship_cnt +1;
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).id := l_ph_lines.id;
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).object_version_number := l_ph_lines.object_version_number;
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).line_type := 'PH_LINE';
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).modifier_tbl_index := l_line_cnt;

              ELSE
                     l_MODIFIERS_tbl(l_line_cnt).operation := QP_GLOBALS.G_OPR_UPDATE;
                     l_MODIFIERS_tbl(l_line_cnt).list_line_id :=  l_ph_lines.ph_qp_reference_id;
                     l_MODIFIERS_tbl(l_line_cnt).list_header_id := l_ph_header.ph_qp_reference_id;

                 /* Updating qp-okc relationship . This table will be used to update okc table with qp_refrence */

                     l_qp_rlship_cnt := l_qp_rlship_cnt +1;
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).id := l_ph_lines.id;
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).object_version_number := l_ph_lines.object_version_number;
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).line_type := 'PH_LINE';
                     l_qp_ph_relship_tbl(l_qp_rlship_cnt).modifier_tbl_index := l_line_cnt;

              END IF; --IF l_ph_lines.ph_qp_reference_id IS NULL then

              l_MODIFIERS_tbl(l_line_cnt).start_date_active := l_ph_lines.start_date;
              l_MODIFIERS_tbl(l_line_cnt).end_date_active := l_ph_lines.end_date;
              l_MODIFIERS_tbl(l_line_cnt).incompatibility_grp_code := fnd_profile.value('OKC_PH_LINE_INCOMPATIBILITY_GROUP');

              IF (l_debug = 'Y') THEN
                 okc_util.print_trace(3,'Incompatibility Group : '||l_MODIFIERS_tbl(l_line_cnt).incompatibility_grp_code );
              END IF;

              IF l_ph_lines.ph_qp_reference_id IS NULL then

                    -- Creation of Pricing Attribute

                    IF l_ph_lines.lse_id=62  THEN -- Line style is Item Number

                         l_line_pattr_cnt := l_line_pattr_cnt + 1;

                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attribute:= 'PRICING_ATTRIBUTE1';
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attr_value:= l_ph_lines.object1_id1;  -- Inventory Item  Id

                   ELSIF l_ph_lines.lse_id=63  THEN -- Line style is Item category

                         l_line_pattr_cnt := l_line_pattr_cnt + 1;
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attribute:= 'PRICING_ATTRIBUTE2';
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attr_value:= l_ph_lines.object1_id1;  -- Category  Id

                   ELSIF l_ph_lines.lse_id=64  THEN -- Line style is All Items

                         l_line_pattr_cnt := l_line_pattr_cnt + 1;
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attribute:= 'PRICING_ATTRIBUTE3';
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attr_value:= 'ALL';  -- Inventory Item  Id

                   END IF;  -- IF l_ph_lines.lse_id=62  then

                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_attribute_context:= 'ITEM';
                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_uom_code := l_ph_lines.uom_code;
                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).excluder_flag:= 'N';
                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).MODIFIERS_index:=l_line_cnt;
                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).operation := QP_GLOBALS.G_OPR_CREATE;
              ELSE

                   -- Updation of Pricing Attribute
                   l_line_pattr_cnt := l_line_pattr_cnt + 1;
                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_uom_code := l_ph_lines.uom_code;

                   -- get pricing attribute id to be updated

                   OPEN c_ph_get_pattr_id(l_ph_lines.ph_qp_reference_id,l_ph_header.ph_qp_reference_id);

                   FETCH c_ph_get_pattr_id INTO l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute_id;

                   CLOSE c_ph_get_pattr_id;

                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).operation := QP_GLOBALS.G_OPR_UPDATE;

             END IF; --IF l_ph_lines.ph_qp_reference_id IS NULL then

             IF l_ph_lines.ph_pricing_type='DISCOUNT_PERCENT' then

                  l_MODIFIERS_tbl(l_line_cnt).operand := l_ph_lines.ph_value;
                  l_MODIFIERS_tbl(l_line_cnt).arithmetic_operator := '%';

            ELSIF l_ph_lines.ph_pricing_type='DISCOUNT_AMOUNT' then
                  l_MODIFIERS_tbl(l_line_cnt).operand := l_ph_lines.ph_value;
                  l_MODIFIERS_tbl(l_line_cnt).arithmetic_operator := 'AMT';
            ELSIF l_ph_lines.ph_pricing_type='NEW_PRICE' then
                  l_MODIFIERS_tbl(l_line_cnt).operand := l_ph_lines.ph_value;
                  l_MODIFIERS_tbl(l_line_cnt).arithmetic_operator := 'NEWPRICE';
            ELSIF l_ph_lines.ph_pricing_type='PRICE_BREAK' then

                  IF l_ph_lines.ph_qp_reference_id IS NULL then
                       l_MODIFIERS_tbl(l_line_cnt).list_line_type_code := 'PBH';
                       l_MODIFIERS_tbl(l_line_cnt).price_break_type_code := 'POINT';
                       l_MODIFIERS_tbl(l_line_cnt).modifier_parent_index := l_line_cnt;
                       l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute_context:= 'VOLUME';
                       l_PRICING_ATTR_tbl(l_line_pattr_cnt).comparison_operator_code:= 'BETWEEN';
                  ELSE

                       l_MODIFIERS_tbl(l_line_cnt).modifier_parent_index := l_line_cnt;
                  END IF;  -- IF l_ph_lines.ph_qp_reference_id IS NULL then

                  IF l_ph_lines.ph_price_break_basis='ITEM_QUANTITY' then
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute:= 'PRICING_ATTRIBUTE10';

                  ELSIF l_ph_lines.ph_price_break_basis='ITEM_AMOUNT' then
                         l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute:= 'PRICING_ATTRIBUTE12';

                  END IF; -- IF l_ph_lines.ph_price_break_basis='ITEM_QUANTITY' then


                  l_line_breaks_cnt := l_line_cnt;
                  l_line_breaks_pattr_cnt := l_line_pattr_cnt;

                  OPEN c_ph_line_break(l_ph_lines.id);
                  LOOP
                        FETCH c_ph_line_break INTO l_ph_line_breaks;
                        EXIT WHEN c_ph_line_break%NOTFOUND;

                        l_line_breaks_cnt := l_line_breaks_cnt + 1;

                        IF l_ph_line_breaks.qp_reference_id IS NULL then
                            l_MODIFIERS_tbl(l_line_breaks_cnt).automatic_flag:= 'Y';
                            l_MODIFIERS_tbl(l_line_breaks_cnt).modifier_level_code := 'LINE';
                            l_MODIFIERS_tbl(l_line_breaks_cnt).accrual_flag := 'N';
                            l_MODIFIERS_tbl(l_line_breaks_cnt).pricing_group_sequence := 1;
                            l_MODIFIERS_tbl(l_line_breaks_cnt).pricing_phase_id := 2;
                            l_MODIFIERS_tbl(l_line_breaks_cnt).product_precedence := 1;
                            l_MODIFIERS_tbl(l_line_breaks_cnt).price_break_type_code := 'POINT';
                            l_MODIFIERS_tbl(l_line_breaks_cnt).modifier_parent_index := l_line_cnt;
                            l_MODIFIERS_tbl(l_line_breaks_cnt).rltd_modifier_grp_no := 10;
                            l_MODIFIERS_tbl(l_line_breaks_cnt).rltd_modifier_grp_type := 'PRICE BREAK';
                            l_MODIFIERS_tbl(l_line_breaks_cnt).operation := QP_GLOBALS.G_OPR_CREATE;

/* IF Modifer  has already been created before and new line break is being added.In that case Modifier line table needs List header id */

                   IF l_ph_header.ph_qp_reference_id IS NOT NULL THEN

                         l_MODIFIERS_tbl(l_line_breaks_cnt).list_header_id := l_ph_header.ph_qp_reference_id;

                  END IF;

                            /* Updating qp-okc relationship . This table will be used to update okc table with qp_refrence */

                             l_qp_rlship_cnt := l_qp_rlship_cnt +1;
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).id := l_ph_line_breaks.id;
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).object_version_number := l_ph_line_breaks.object_version_number;
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).line_type := 'PH_LINE_BREAK';
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).modifier_tbl_index := l_line_breaks_cnt;

                        ELSE
                             l_MODIFIERS_tbl(l_line_breaks_cnt).operation := QP_GLOBALS.G_OPR_UPDATE;
                             l_MODIFIERS_tbl(l_line_breaks_cnt).list_line_id   :=  l_ph_line_breaks.qp_reference_id;
                             l_MODIFIERS_tbl(l_line_breaks_cnt).list_header_id := l_ph_header.ph_qp_reference_id;
                             /* Updating qp-okc relationship . This table will be used to update okc table with qp_refrence */

                             l_qp_rlship_cnt := l_qp_rlship_cnt +1;
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).id := l_ph_line_breaks.id;
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).object_version_number := l_ph_line_breaks.object_version_number;
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).line_type := 'PH_LINE_BREAK';
                             l_qp_ph_relship_tbl(l_qp_rlship_cnt).modifier_tbl_index := l_line_breaks_cnt;

                        END IF; -- IF l_ph_line_breaks.qp_reference_id IS NULL then
                        l_MODIFIERS_tbl(l_line_breaks_cnt).list_line_type_code := 'DIS';
                        l_MODIFIERS_tbl(l_line_breaks_cnt).operand := l_ph_line_breaks.value;
                        l_MODIFIERS_tbl(l_line_breaks_cnt).start_date_active := l_ph_lines.start_date;
                        l_MODIFIERS_tbl(l_line_breaks_cnt).end_date_active := l_ph_lines.end_date;

                        IF l_ph_line_breaks.pricing_type='DISCOUNT_PERCENT' then
                           l_MODIFIERS_tbl(l_line_breaks_cnt).arithmetic_operator := '%';
                        ELSIF l_ph_line_breaks.pricing_type ='DISCOUNT_AMOUNT' then
                           l_MODIFIERS_tbl(l_line_breaks_cnt).arithmetic_operator := 'AMT';

                        ELSIF l_ph_line_breaks.pricing_type ='NEW_PRICE' then
                           l_MODIFIERS_tbl(l_line_breaks_cnt).arithmetic_operator := 'NEWPRICE';
                        END IF; --IF l_ph_line_breaks.pricing_type='DISCOUNT_PERCENT' then

                        l_line_breaks_pattr_cnt := l_line_breaks_pattr_cnt + 1;
                        IF l_ph_line_breaks.qp_reference_id IS NULL then
                             l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).MODIFIERS_index:= l_line_breaks_cnt;
                             l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).operation := QP_GLOBALS.G_OPR_CREATE;

                             IF l_ph_lines.lse_id=62  THEN -- to be changed with actual lse id of subline Item Number from seed

                                l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attribute:= 'PRICING_ATTRIBUTE1';
                                l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attr_value:= l_ph_lines.object1_id1;  -- Inventory Item  Id
                                l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attribute_context:= 'ITEM';

                            ELSIF l_ph_lines.lse_id=63  THEN -- to be changed with actual lse id of subline Item category

                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attribute:= 'PRICING_ATTRIBUTE2';
                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attr_value:= l_ph_lines.object1_id1;  -- Category  Id
                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attribute_context:= 'ITEM';

                           ELSIF l_ph_lines.lse_id=64  THEN -- to be changed with actual lse id of subline  All Items

                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attribute:= 'PRICING_ATTRIBUTE3';
                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attr_value:= 'ALL';  -- Inventory Item  Id
                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_attribute_context:= 'ITEM';
                               l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).excluder_flag:= 'N';

                          END IF;  -- IF l_ph_lines.lse_id=62  then

                    ELSE
                          -- get pricing attribute id to be updated
                          OPEN c_ph_get_pattr_id(l_ph_line_breaks.qp_reference_id,l_ph_header.ph_qp_reference_id);
                          FETCH c_ph_get_pattr_id INTO l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).pricing_attribute_id;
                          CLOSE c_ph_get_pattr_id;

                          l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).operation := QP_GLOBALS.G_OPR_UPDATE;

                   END IF;  --IF l_ph_line_breaks.qp_reference_id IS NULL then


                  IF l_ph_lines.ph_price_break_basis='ITEM_QUANTITY' then
                          l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).pricing_attribute:= 'PRICING_ATTRIBUTE10';

                  ELSIF l_ph_lines.ph_price_break_basis='ITEM_AMOUNT' then
                         l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).pricing_attribute:= 'PRICING_ATTRIBUTE12';

                  END IF; -- IF l_ph_lines.ph_price_break_basis='ITEM_QUANTITY' then


                        l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).pricing_attribute_context:= 'VOLUME';

                        l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).pricing_attr_value_from:= l_ph_line_breaks.value_from;
                        l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).pricing_attr_value_to:= l_ph_line_breaks.value_to;
                        l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).comparison_operator_code:= 'BETWEEN';
                        l_PRICING_ATTR_tbl(l_line_breaks_pattr_cnt).product_uom_code:= l_ph_lines.uom_code;

                END LOOP;

                CLOSE c_ph_line_break;

                l_line_cnt := l_line_breaks_cnt;
                l_line_pattr_cnt := l_line_breaks_pattr_cnt;
                l_line_breaks_pattr_cnt:=0;
         END IF;  -- IF l_ph_lines.ph_pricing_type='DISCOUNT_PERCENT' then


         /*       Line Purchase Minimum Condition    */

         IF l_ph_lines.ph_pricing_type <> 'PRICE_BREAK' THEN

              IF l_ph_lines.ph_min_qty is NOT NULL THEN

                    l_modifiers_tbl(l_line_cnt).price_break_type_code :='POINT';
                    l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute_context:= 'VOLUME';

                    l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute:= 'PRICING_ATTRIBUTE10';

                    l_PRICING_ATTR_tbl(l_line_pattr_cnt).comparison_operator_code:= 'BETWEEN';

                    l_PRICING_ATTR_tbl(l_line_pattr_cnt).product_uom_code:= l_ph_lines.uom_code;

                    l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attr_value_from:= l_ph_lines.ph_min_qty;

                    l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attr_value_to:= '999999999999999999999';

            ELSIF l_ph_lines.ph_min_amt IS NOT NULL  THEN

                   l_modifiers_tbl(l_line_cnt).price_break_type_code :='POINT';
                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute_context:= 'VOLUME';

                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute:= 'PRICING_ATTRIBUTE12';

                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).comparison_operator_code:= 'BETWEEN';

                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attr_value_from:= l_ph_lines.ph_min_amt;

                   l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attr_value_to:= '999999999999999999999';

           ELSIF l_ph_lines.ph_min_amt IS NULL AND l_ph_lines.ph_min_qty IS NULL THEN

                  l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute_context:= Null;

                  l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attribute:= Null;

                  l_PRICING_ATTR_tbl(l_line_pattr_cnt).comparison_operator_code:= Null;
                  l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attr_value_from:=Null;
                  l_PRICING_ATTR_tbl(l_line_pattr_cnt).pricing_attr_value_to:= Null;

           END IF;  -- IF l_ph_lines.ph_min_qty is NOT NULL then


       END IF;  -- IF l_ph_lines.ph_pricing_type <> 'PRICE_BREAK' then

     /*             End Line Purchase Minimum              */


     END IF; --- IF nvl(l_ph_lines.ph_integrated_with_qp,'N')='N' then
  END LOOP;
  CLOSE c_ph_lines;



  IF l_call_qp_api THEN

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2,'Calling QP_Modifiers_PUB.proces_modifiers');
     END IF;

     QP_Modifiers_PUB.Process_Modifiers(p_api_version_number => 1.0
                                       ,p_init_msg_list => FND_API.G_FALSE
                                       ,p_return_values => FND_API.G_FALSE
                                       ,p_commit => FND_API.G_FALSE
                                       ,x_return_status => l_return_status
                                       ,x_msg_count =>     x_msg_count
                                       ,x_msg_data =>      x_msg_data
                                       ,p_MODIFIER_LIST_rec => l_MODIFIER_LIST_rec
                                       ,p_MODIFIERS_tbl => l_MODIFIERS_tbl
                                       ,p_QUALIFIERS_tbl => l_QUALIFIERS_tbl
                                       ,p_PRICING_ATTR_tbl=> l_PRICING_ATTR_tbl
                                       ,x_MODIFIER_LIST_rec => l_x_MODIFIER_LIST_rec
                                       ,x_MODIFIER_LIST_val_rec => l_x_MODIFIER_LIST_val_rec
                                       ,x_MODIFIERS_tbl => l_x_MODIFIERS_tbl
                                       ,x_MODIFIERS_val_tbl => l_x_MODIFIERS_val_tbl
                                       ,x_QUALIFIERS_tbl => l_x_QUALIFIERS_tbl
                                       ,x_QUALIFIERS_val_tbl => l_x_QUALIFIERS_val_tbl
                                       ,x_PRICING_ATTR_tbl => l_x_PRICING_ATTR_tbl
                                       ,x_PRICING_ATTR_val_tbl => l_x_PRICING_ATTR_val_tbl
                                        );

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2,'Exited QP_Modifiers_proces_modifiers, Status '||l_return_status);
     END IF;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2,'List Header Id '||l_x_MODIFIER_LIST_rec.list_header_id);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;


  END IF; -- IF l_call_qp_api THEN
   /* Build PL/SQL table to update Lines and line breaks with qp_refrence_id */

    IF l_qp_ph_relship_tbl.first IS NOT NULL and l_call_qp_api THEN

        FOR i IN l_qp_ph_relship_tbl.first..l_qp_ph_relship_tbl.last LOOP
             IF l_qp_ph_relship_tbl(i).line_type ='PRICE_HOLD' then

                   cle_cnt := cle_cnt + 1;
                   l_clev_tbl(cle_cnt).id := l_qp_ph_relship_tbl(i).id;
                   l_clev_tbl(cle_cnt).object_version_number := l_qp_ph_relship_tbl(i).object_version_number;
                   l_clev_tbl(cle_cnt).ph_integrated_with_qp := 'Y';
                   l_clev_tbl(cle_cnt).ph_qp_reference_id := l_x_MODIFIER_LIST_rec.list_header_id;
                   IF (l_debug = 'Y') THEN
                      okc_util.print_trace(3,' id '||  l_clev_tbl(cle_cnt).id ||' ph_qp_reference_id '||l_clev_tbl(cle_cnt).ph_qp_reference_id);
                   END IF;

            ELSIF l_qp_ph_relship_tbl(i).line_type ='PH_LINE' then

                   cle_cnt := cle_cnt + 1;
                   l_clev_tbl(cle_cnt).id := l_qp_ph_relship_tbl(i).id;
                   l_clev_tbl(cle_cnt).object_version_number := l_qp_ph_relship_tbl(i).object_version_number;
                   l_clev_tbl(cle_cnt).ph_integrated_with_qp := 'Y';
                   l_clev_tbl(cle_cnt).ph_qp_reference_id := l_x_MODIFIERS_tbl(l_qp_ph_relship_tbl(i).modifier_tbl_index).list_line_id;

                   IF (l_debug = 'Y') THEN
                      okc_util.print_trace(3,' id '||  l_clev_tbl(cle_cnt).id ||' ph_qp_reference_id '||l_clev_tbl(cle_cnt).ph_qp_reference_id);
                   END IF;

           ELSIF l_qp_ph_relship_tbl(i).line_type ='PH_LINE_BREAK' then

                    phl_cnt := phl_cnt + 1;
                    l_ph_line_breaks_tbl(phl_cnt).id := l_qp_ph_relship_tbl(i).id;
                    l_ph_line_breaks_tbl(phl_cnt).object_version_number := l_qp_ph_relship_tbl(i).object_version_number;
                    l_ph_line_breaks_tbl(phl_cnt).integrated_with_qp := 'Y';
                    l_ph_line_breaks_tbl(phl_cnt).qp_reference_id := l_x_MODIFIERS_tbl(l_qp_ph_relship_tbl(i).modifier_tbl_index).list_line_id;
                    IF (l_debug = 'Y') THEN
                       okc_util.print_trace(3,' break id '||  l_ph_line_breaks_tbl(phl_cnt).id ||' ph_qp_reference_id '||l_ph_line_breaks_tbl(phl_cnt).qp_reference_id);
                    END IF;
         END IF;
    END LOOP;

    IF l_clev_tbl.count > 0 then
         IF (l_debug = 'Y') THEN
            okc_util.print_trace(2,'Start  OKC_CONTRACT_PUB.update_contract_line');
         END IF;

         OKC_CONTRACT_PUB.update_contract_line( p_api_version   => 1.0,
                                                p_init_msg_list => FND_API.G_FALSE,
                                                x_return_status => l_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_restricted_update => OKC_API.G_TRUE,
                                                p_clev_tbl      => l_clev_tbl,
                                                x_clev_tbl      => lx_clev_tbl);

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(2,'End  OKC_CONTRACT_PUB.update_contract_line:Status'||l_return_status);
         END IF;


         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

   END IF;

         IF l_ph_line_breaks_tbl.count > 0 then

              IF (l_debug = 'Y') THEN
                 okc_util.print_trace(2,'Start  OKC_PHL_PVT.update_row');
              END IF;
              OKC_PHL_PVT.update_row( p_api_version   => 1.0,
                                      p_init_msg_list => FND_API.G_FALSE,
                                      x_return_status => l_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_okc_ph_line_breaks_v_tbl =>l_ph_line_breaks_tbl,
                                      x_okc_ph_line_breaks_v_tbl =>lx_ph_line_breaks_tbl);
              IF (l_debug = 'Y') THEN
                 okc_util.print_trace(2,'End  OKC_PHL_PVT.update_row:Status'||l_return_status);
              END IF;


             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

       END IF;

  END IF;  --  IF l_qp_ph_relship_tbl.first IS NOT NULL THEN

ELSIF c_ph_header%FOUND
      AND p_operation_code='TERMINATE'
      AND l_ph_header.ph_qp_reference_id IS NOT NULL THEN


      IF p_termination_date IS NULL THEN

             OKC_API.set_message(p_app_name   => g_app_name, --OKC
                                 p_msg_name      => 'OKC_NO_PH_TERMINATE_DATE');

              RAISE OKC_API.G_EXCEPTION_ERROR;

       END IF;

       l_call_qp_api := true ;

       -- case of end date modifier.
       fnd_profile.put('QP_SOURCE_SYSTEM_CODE','OKC');

       --Setting the QP system Profile Option to OKC.so that Modifer cannot be updated from QP screens.

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(2,'Profile Option QP_SOURCE_SYSTEM_CODE set to OKC');
        END IF;

        l_MODIFIER_LIST_rec.end_date_active := p_termination_date;
        l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
        l_MODIFIER_LIST_rec.list_header_id  :=  l_ph_header.ph_qp_reference_id;

        IF l_call_qp_api THEN


          IF (l_debug = 'Y') THEN
             okc_util.print_trace(2,'Calling QP_Modifiers_proces_modifiers');
          END IF;

          QP_Modifiers_PUB.Process_Modifiers (p_api_version_number => 1.0
                                             ,p_init_msg_list => FND_API.G_FALSE
                                             ,p_return_values => FND_API.G_FALSE
                                             ,p_commit => FND_API.G_FALSE
                                             ,x_return_status => l_return_status
                                             ,x_msg_count =>x_msg_count
                                             ,x_msg_data => x_msg_data
                                             ,p_MODIFIER_LIST_rec => l_MODIFIER_LIST_rec
                                             ,p_MODIFIERS_tbl => l_MODIFIERS_tbl
                                             ,p_QUALIFIERS_tbl => l_QUALIFIERS_tbl
                                             ,p_PRICING_ATTR_tbl=> l_PRICING_ATTR_tbl
                                             ,x_MODIFIER_LIST_rec => l_x_MODIFIER_LIST_rec
                                             ,x_MODIFIER_LIST_val_rec => l_x_MODIFIER_LIST_val_rec
                                             ,x_MODIFIERS_tbl => l_x_MODIFIERS_tbl
                                             ,x_MODIFIERS_val_tbl => l_x_MODIFIERS_val_tbl
                                             ,x_QUALIFIERS_tbl => l_x_QUALIFIERS_tbl
                                             ,x_QUALIFIERS_val_tbl => l_x_QUALIFIERS_val_tbl
                                             ,x_PRICING_ATTR_tbl => l_x_PRICING_ATTR_tbl
                                             ,x_PRICING_ATTR_val_tbl => l_x_PRICING_ATTR_val_tbl
                                       );
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(2,'Exited QP_Modifiers_proces_modifiers, Status '||l_return_status);
             okc_util.print_trace(2,'List Header Id '||l_x_MODIFIER_LIST_rec.list_header_id);
          END IF;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

    END IF;


    CLOSE c_ph_header;

END IF;

CLOSE c_k_header;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
-- transferring error messages from QP to FND error stack
 FOR i in 1..x_msg_count LOOP
      x_msg_data := oe_msg_pub.get(p_msg_index => i,
                                   p_encoded => 'F'
                                  );

      FND_MSG_PUB.Add_Exc_Msg (
                               p_pkg_name       =>  'OKC_PHI_PVT',
                               p_procedure_name  =>  'process_price_hold',
                               p_error_text   =>  x_msg_data
                            );
END LOOP;

IF c_k_header%ISOPEN THEN
    CLOSE c_k_header;
END IF;

IF c_ph_header%ISOPEN THEN
    CLOSE c_ph_header;
END IF;

IF c_ph_rules%ISOPEN THEN
    CLOSE c_ph_rules;
END IF;

IF c_ph_lines%ISOPEN THEN
    CLOSE c_ph_lines;
END IF;

IF c_ph_line_break%ISOPEN THEN
    CLOSE c_ph_line_break;
END IF;

IF c_ph_header_qual%ISOPEN THEN
    CLOSE c_ph_header_qual;
END IF;
x_return_status := FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 FOR i in 1..x_msg_count LOOP
      x_msg_data := oe_msg_pub.get(p_msg_index => i,
                                   p_encoded => 'F'
                                  );

      FND_MSG_PUB.Add_Exc_Msg (
                               p_pkg_name       =>  'OKC_PHI_PVT',
                               p_procedure_name  =>  'process_price_hold',
                               p_error_text   =>  x_msg_data
                            );
 END LOOP;

IF c_k_header%ISOPEN THEN
    CLOSE c_k_header;
END IF;

IF c_ph_header%ISOPEN THEN
    CLOSE c_ph_header;
END IF;

IF c_ph_rules%ISOPEN THEN
    CLOSE c_ph_rules;
END IF;

IF c_ph_lines%ISOPEN THEN
    CLOSE c_ph_lines;
END IF;

IF c_ph_line_break%ISOPEN THEN
    CLOSE c_ph_line_break;
END IF;

IF c_ph_header_qual%ISOPEN THEN
    CLOSE c_ph_header_qual;
END IF;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


WHEN OTHERS THEN

  FOR i in 1..x_msg_count LOOP
      x_msg_data := oe_msg_pub.get(p_msg_index => i,
                                   p_encoded => 'F'
                                  );

      FND_MSG_PUB.Add_Exc_Msg (
                               p_pkg_name       =>  'OKC_PHI_PVT',
                               p_procedure_name  =>  'process_price_hold',
                               p_error_text   =>  x_msg_data
                            );
  END LOOP;

if c_k_header%ISOPEN then
    CLOSE c_k_header;
end if;

if c_ph_header%ISOPEN then
    CLOSE c_ph_header;
end if;

if c_ph_rules%ISOPEN then
    CLOSE c_ph_rules;
end if;
if c_ph_lines%ISOPEN then
    CLOSE c_ph_lines;
end if;

if c_ph_line_break%ISOPEN then
    CLOSE c_ph_line_break;
end if;

if c_ph_header_qual%ISOPEN then
    CLOSE c_ph_header_qual;
end if;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END;



/*
-------------------------------------------------------------------------------------------------------------------------
--Procedure : extend_price_hold
--  Input Parameter : p_cle_id Contract Line Id of price hold topline.
--
-- This API is called whenever a price hold line is extended.What it does is that it extends
-- modifier and modifier line in QP
--
---------------------------------------------------------------------------------------------------------------------------------
*/

PROCEDURE extend_price_hold(p_api_version     IN NUMBER
                           ,p_init_msg_list   IN VARCHAR2
                           ,p_cle_id          IN OKC_K_LINES_V.id%TYPE   -- Price Hold Topline Id
                           ,x_return_status   OUT NOCOPY VARCHAR2
                           ,x_msg_count       OUT NOCOPY NUMBER
                           ,x_msg_data        OUT NOCOPY VARCHAR2
                            ) IS

 Cursor c_k_header(b_cle_id Number) IS
 SELECT chr.id ID
 FROM okc_k_headers_V chr,
      okc_k_lines_V   cle
 WHERE cle.id=b_cle_id
 AND   chr.id=cle.dnz_chr_id
 AND   chr.application_id in (510,871)
 AND   chr.buy_or_sell='S'
 AND   chr.issue_or_receive='I'
 AND   chr.template_yn='N'
 AND   chr.deleted_yn='N'
 AND   chr.date_terminated IS NULL
 AND   chr.datetime_cancelled IS NULL;

 Cursor c_ph_header(b_cle_id Number) IS
 SELECT id ,
        dnz_chr_id,
        ph_qp_reference_id,
        ph_integrated_with_qp,
        start_date,
        end_date
FROM okc_k_lines_v cle
WHERE cle.id=b_cle_id
AND   cle.cle_id is null
AND   cle.lse_id=61  -- Price Hold Line style.
AND   cle.date_terminated IS NULL
AND   cle.ph_qp_reference_id is not null
AND   rownum=1;


Cursor c_ph_lines(b_cle_id Number) IS
 SELECT cle.id id,
        cle.line_number line_number,
        cle.lse_id  lse_id,
        ph_qp_reference_id,
        ph_integrated_with_qp,
        start_date,
        end_date
FROM okc_k_lines_v cle
WHERE cle.cle_id=b_cle_id
AND   cle.ph_qp_reference_id is not null
ORDER BY line_number;

Cursor c_ph_line_break(b_ph_line_id Number) IS
 SELECT id ,
        qp_reference_id,
        integrated_with_qp
FROM okc_ph_line_breaks_v
WHERE cle_id=b_ph_line_id
AND   qp_reference_id is not null
order by id;


l_k_header         c_k_header%rowtype;
l_ph_header        c_ph_header%rowtype;
l_ph_lines         c_ph_lines%rowtype;
l_ph_line_breaks   c_ph_line_break%rowtype;
l_line_cnt                NUMBER := 0;

l_control_rec      QP_GLOBALS.Control_Rec_Type;
l_return_status    VARCHAR2(1);
l_msg_index        NUMBER;

l_MODIFIER_LIST_rec QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIER_LIST_val_rec QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
l_MODIFIERS_tbl QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_MODIFIERS_val_tbl QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
l_QUALIFIERS_tbl QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_QUALIFIERS_val_tbl QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_PRICING_ATTR_tbl QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_PRICING_ATTR_val_tbl QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;
l_x_MODIFIER_LIST_rec QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIER_LIST_val_rec QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
l_x_MODIFIERS_tbl QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_MODIFIERS_val_tbl QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
l_x_QUALIFIERS_tbl QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_QUALIFIERS_val_tbl QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_x_PRICING_ATTR_tbl QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICING_ATTR_val_tbl QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;

BEGIN
  Fnd_Msg_Pub.Initialize;
l_call_qp_api := false;
OPEN c_k_header(p_cle_id);
fetch c_k_header into l_k_header;
IF c_k_header%FOUND then
  OPEN c_ph_header(p_cle_id);
  FETCH c_ph_header into l_ph_header;
  IF c_ph_header%FOUND THEN
       l_call_qp_api := true;
       l_MODIFIER_LIST_rec.start_date_active := l_ph_header.start_date;
       l_MODIFIER_LIST_rec.end_date_active := l_ph_header.end_date;
       l_MODIFIER_LIST_rec.active_flag := 'N';
       l_MODIFIER_LIST_rec.automatic_flag := 'N';
       l_MODIFIER_LIST_rec.list_header_id := l_ph_header.ph_qp_reference_id;
       l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(1,'List Header Id'||l_ph_header.ph_qp_reference_id||' Start Date '||l_ph_header.start_date||' End Date '||l_ph_header.end_date);
       END IF;

       OPEN c_ph_lines(p_cle_id);
       LOOP
          FETCH c_ph_lines into l_ph_lines;
          EXIT WHEN c_ph_lines%NOTFOUND ;
                       l_call_qp_api := true;
                       l_line_cnt := l_modifiers_tbl.count + 1;
                       l_MODIFIERS_tbl(l_line_cnt).automatic_flag:= 'N';
                       l_MODIFIERS_tbl(l_line_cnt).operation := QP_GLOBALS.G_OPR_UPDATE;
                       l_MODIFIERS_tbl(l_line_cnt).list_line_id :=  l_ph_lines.ph_qp_reference_id;
                       l_MODIFIERS_tbl(l_line_cnt).list_header_id := l_ph_header.ph_qp_reference_id;
                       l_MODIFIERS_tbl(l_line_cnt).start_date_active := l_ph_lines.start_date;
                       l_MODIFIERS_tbl(l_line_cnt).end_date_active := l_ph_lines.end_date;
                       IF (l_debug = 'Y') THEN
                          okc_util.print_trace(2,'List Line Id'||l_ph_lines.ph_qp_reference_id||' Start Date '||l_ph_lines.start_date||' End Date '||l_ph_lines.end_date);
                       END IF;
                       OPEN c_ph_line_break(p_cle_id);
                       LOOP
                          FETCH c_ph_line_break into l_ph_line_breaks;
                          EXIT WHEN c_ph_line_break%NOTFOUND ;
                                       l_line_cnt := l_modifiers_tbl.count + 1;
                                       l_MODIFIERS_tbl(l_line_cnt).automatic_flag:= 'N';
                                       l_MODIFIERS_tbl(l_line_cnt).operation := QP_GLOBALS.G_OPR_UPDATE;
                                       l_MODIFIERS_tbl(l_line_cnt).list_line_id :=  l_ph_line_breaks.qp_reference_id;
                                       l_MODIFIERS_tbl(l_line_cnt).list_header_id := l_ph_header.ph_qp_reference_id;
                                       l_MODIFIERS_tbl(l_line_cnt).start_date_active := l_ph_lines.start_date;
                                       l_MODIFIERS_tbl(l_line_cnt).end_date_active := l_ph_lines.end_date;
                                       IF (l_debug = 'Y') THEN
                                          okc_util.print_trace(3,'List Line Id'||l_ph_line_breaks.qp_reference_id||' Start Date '||l_ph_lines.start_date||' End Date '||l_ph_lines.end_date);
                                       END IF;
                        END LOOP;
                        CLOSE c_ph_line_break;
       END LOOP;
       CLOSE c_ph_lines;


    IF l_call_qp_api THEN

        fnd_profile.put('QP_SOURCE_SYSTEM_CODE','OKC');
              --Setting the QP system Profile Option to OKC.so that Modifer cannot be updated from QP screens.

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(2,'Calling QP_Modifiers_proces_modifiers');
         END IF;


       QP_Modifiers_PUB.Process_Modifiers (p_api_version_number => 1.0
                                          ,p_init_msg_list => FND_API.G_FALSE
                                          ,p_return_values => FND_API.G_FALSE
                                          ,p_commit => FND_API.G_FALSE
                                          ,x_return_status => l_return_status
                                          ,x_msg_count =>x_msg_count
                                          ,x_msg_data => x_msg_data
                                          ,p_MODIFIER_LIST_rec => l_MODIFIER_LIST_rec
                                          ,p_MODIFIERS_tbl => l_MODIFIERS_tbl
                                          ,p_QUALIFIERS_tbl => l_QUALIFIERS_tbl
                                          ,p_PRICING_ATTR_tbl=> l_PRICING_ATTR_tbl
                                          ,x_MODIFIER_LIST_rec => l_x_MODIFIER_LIST_rec
                                          ,x_MODIFIER_LIST_val_rec => l_x_MODIFIER_LIST_val_rec
                                          ,x_MODIFIERS_tbl => l_x_MODIFIERS_tbl
                                          ,x_MODIFIERS_val_tbl => l_x_MODIFIERS_val_tbl
                                          ,x_QUALIFIERS_tbl => l_x_QUALIFIERS_tbl
                                          ,x_QUALIFIERS_val_tbl => l_x_QUALIFIERS_val_tbl
                                          ,x_PRICING_ATTR_tbl => l_x_PRICING_ATTR_tbl
                                          ,x_PRICING_ATTR_val_tbl => l_x_PRICING_ATTR_val_tbl
                                          );

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2,'Exited QP_Modifiers_proces_modifiers, Status '||l_return_status);
          okc_util.print_trace(2,'List Header Id '||l_x_MODIFIER_LIST_rec.list_header_id);
       END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF; -- IF c_ph_header%FOUND Then
  CLOSE c_ph_header;

END IF; -- IF c_k_header%FOUND then

close c_k_header;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 FOR i in 1..x_msg_count LOOP
      x_msg_data := oe_msg_pub.get(p_msg_index => i,
                                   p_encoded => 'F'
                                  );

      FND_MSG_PUB.Add_Exc_Msg (
                               p_pkg_name       =>  'OKC_PHI_PVT',
                               p_procedure_name  =>  'extend_price_hold',
                               p_error_text   =>  x_msg_data
                            );
 END LOOP;

if c_k_header%ISOPEN then
    CLOSE c_k_header;
end if;

if c_ph_header%ISOPEN then
    CLOSE c_ph_header;
end if;

if c_ph_lines%ISOPEN then
    CLOSE c_ph_lines;
end if;

if c_ph_line_break%ISOPEN then
    CLOSE c_ph_line_break;
end if;

x_return_status := FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 FOR i in 1..x_msg_count LOOP
      x_msg_data := oe_msg_pub.get(p_msg_index => i,
                                   p_encoded => 'F'
                                  );

      FND_MSG_PUB.Add_Exc_Msg (
                               p_pkg_name       =>  'OKC_PHI_PVT',
                               p_procedure_name  =>  'extend_price_hold',
                               p_error_text   =>  x_msg_data
                            );
 END LOOP;

if c_k_header%ISOPEN then
    CLOSE c_k_header;
end if;

if c_ph_header%ISOPEN then
    CLOSE c_ph_header;
end if;

if c_ph_lines%ISOPEN then
    CLOSE c_ph_lines;
end if;

if c_ph_line_break%ISOPEN then
    CLOSE c_ph_line_break;
end if;

x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


WHEN OTHERS THEN

 FOR i in 1..x_msg_count LOOP
      x_msg_data := oe_msg_pub.get(p_msg_index => i,
                                   p_encoded => 'F'
                                  );

      FND_MSG_PUB.Add_Exc_Msg (
                               p_pkg_name       =>  'OKC_PHI_PVT',
                               p_procedure_name  =>  'extend_price_hold',
                               p_error_text   =>  x_msg_data
                            );
 END LOOP;

if c_k_header%ISOPEN then
    CLOSE c_k_header;
end if;

if c_ph_header%ISOPEN then
    CLOSE c_ph_header;
end if;

if c_ph_lines%ISOPEN then
    CLOSE c_ph_lines;
end if;

if c_ph_line_break%ISOPEN then
    CLOSE c_ph_line_break;
end if;

x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END;


-- This procedure copies Not Price Hold contract lines as sublines for Price Hold TopLine
PROCEDURE COPY_LINES(
             p_api_version	IN	NUMBER,
             p_init_msg_list	IN	VARCHAR2,
             x_return_status	OUT NOCOPY	VARCHAR2,
             x_msg_count	OUT NOCOPY	NUMBER,
             x_msg_data	OUT NOCOPY	VARCHAR2,
             p_chr_id IN NUMBER,  -- Contract Header ID
             p_cle_id in number,  -- Price Hold TopLine ID
             p_restricted_update in VARCHAR2,
             p_delete_before_yn in VARCHAR2 , -- delete current lines before copying
             p_commit_changes_yn in VARCHAR2 , -- commit changes after copying
             x_recs_copied OUT NOCOPY NUMBER) IS
  l_cnt NUMBER := 1;
  m_cnt NUMBER := 0;
  top_line_id NUMBER := p_cle_id;
  top_PRICE_LIST_ID NUMBER;
  top_PH_PRICING_TYPE VARCHAR2(50);
  top_PH_ADJUSTMENT NUMBER;
  l_unit_price NUMBER;
  l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  CURSOR c_cur_ph_lines(p_par_id NUMBER) IS
   select id
    from okc_k_lines_v
    where cle_id = p_par_id;

  CURSOR c_top_lines(p_chr_id NUMBER) IS
   select id
    from okc_k_lines_v
    where chr_id=p_chr_id and item_to_price_yn='Y'
    order by DISPLAY_SEQUENCE;

  CURSOR c_top_ph_line(p_cle_id NUMBER) IS
   select
        PRICE_LIST_ID,
        PH_PRICING_TYPE,
        PH_ADJUSTMENT
    from okc_k_lines_v
    where id=p_cle_id;

  x_clev_rec OKC_CONTRACT_PUB.clev_rec_type;
  n_clev_rec OKC_CONTRACT_PUB.clev_rec_type;
  xn_clev_rec OKC_CONTRACT_PUB.clev_rec_type;

  x_cimv_rec OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
  n_cimv_rec OKC_CONTRACT_ITEM_PUB.cimv_rec_type;
  xn_cimv_rec OKC_CONTRACT_ITEM_PUB.cimv_rec_type;

  l_data_found BOOLEAN := TRUE;

      CURSOR c_clev_rec (p_cle_id number) IS
      SELECT 	'' ID,
		SFWT_FLAG,
		'' CHR_ID,
		DNZ_CHR_ID,
		CLE_ID,
                '' LINE_NUMBER,
                62 LSE_ID,
		STS_CODE,
		'' DISPLAY_SEQUENCE,
		TRN_CODE,
		COMMENTS,
		ITEM_DESCRIPTION,
		OKE_BOE_DESCRIPTION,
		COGNOMEN,
		HIDDEN_IND,
                PRICE_UNIT,
                PRICE_UNIT_PERCENT,
		'' PRICE_NEGOTIATED,
		PRICE_LEVEL_IND,
		INVOICE_LINE_LEVEL_IND,
		DPAS_RATING,
		BLOCK23TEXT,
		EXCEPTION_YN,
		TEMPLATE_USED,
		DATE_TERMINATED,
		NAME,
		START_DATE,
		END_DATE,
		DATE_RENEWED,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                PRICE_LIST_ID,
                PRICING_DATE,
                PRICE_LIST_LINE_ID,
                LINE_LIST_PRICE,
                ITEM_TO_PRICE_YN,
                PRICE_BASIS_YN,
                CONFIG_HEADER_ID,
                CONFIG_REVISION_NUMBER,
                CONFIG_COMPLETE_YN,
                CONFIG_VALID_YN,
                CONFIG_TOP_MODEL_LINE_ID,
                CONFIG_ITEM_TYPE,
                CONFIG_ITEM_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		PRICE_TYPE,
		CURRENCY_CODE,
                SERVICE_ITEM_YN,
                -- new columns for price hold
                PH_PRICING_TYPE,
                PH_ADJUSTMENT,
                PH_PRICE_BREAK_BASIS,
                PH_MIN_QTY,
                PH_MIN_AMT,
                PH_QP_REFERENCE_ID,
                PH_VALUE,
                PH_ENFORCE_PRICE_LIST_YN,
                PH_INTEGRATED_WITH_QP
      FROM	OKC_K_LINES_V
      WHERE	id = p_cle_id;

      CURSOR c_cimv_rec(p_cle_id NUMBER) IS
      SELECT	ID,
		CLE_ID,
		CHR_ID,
		CLE_ID_FOR,
		DNZ_CHR_ID,
		OBJECT1_ID1,
		OBJECT1_ID2,
		'OKX_SYSITEM' JTOT_OBJECT1_CODE,
		UOM_CODE,
		EXCEPTION_YN,
		1 NUMBER_OF_ITEMS,
                'N' PRICED_ITEM_YN
	FROM    OKC_K_ITEMS_V
	WHERE 	CLE_ID = p_cle_id;

 BEGIN
  Fnd_Msg_Pub.Initialize;

  IF Nvl(p_delete_before_yn,'N') = 'Y' THEN
    FOR crec IN c_cur_ph_lines( top_line_id ) LOOP
      okc_contract_pub.delete_contract_line (
               p_api_version		=> p_api_version,
               p_init_msg_list		=> p_init_msg_list,
               x_return_status		=> l_return_status,
               x_msg_count		=> x_msg_count,
               x_msg_data		=> x_msg_data,
               p_line_id		=> crec.id
      );
    END LOOP;
  END IF;

  OPEN c_top_ph_line( top_line_id ) ;
  FETCH c_top_ph_line
     INTO top_PRICE_LIST_ID, top_PH_PRICING_TYPE, top_PH_ADJUSTMENT;
  l_data_found := c_top_ph_line%FOUND;
  CLOSE c_top_ph_line;

  select Greatest(Nvl(Max(DISPLAY_SEQUENCE),0),Nvl(Max(LINE_NUMBER),0))
    INTO m_cnt
    from okc_k_lines_v
    where cle_id = top_line_id;

  FOR crec IN c_top_lines( p_chr_id ) LOOP
      x_clev_rec := n_clev_rec;
      OPEN c_clev_rec ( crec.id );
      FETCH c_clev_rec
      INTO	x_clev_rec.ID,
		x_clev_rec.SFWT_FLAG,
		x_clev_rec.CHR_ID,
		x_clev_rec.DNZ_CHR_ID,
		x_clev_rec.CLE_ID,
                x_clev_rec.LINE_NUMBER,
		x_clev_rec.LSE_ID,
		x_clev_rec.STS_CODE,
		x_clev_rec.DISPLAY_SEQUENCE,
		x_clev_rec.TRN_CODE,
		x_clev_rec.COMMENTS,
		x_clev_rec.ITEM_DESCRIPTION,
		x_clev_rec.OKE_BOE_DESCRIPTION,
		x_clev_rec.COGNOMEN,
		x_clev_rec.HIDDEN_IND,
                x_clev_rec.PRICE_UNIT,
                x_clev_rec.PRICE_UNIT_PERCENT,
		x_clev_rec.PRICE_NEGOTIATED,
		x_clev_rec.PRICE_LEVEL_IND,
		x_clev_rec.INVOICE_LINE_LEVEL_IND,
		x_clev_rec.DPAS_RATING,
		x_clev_rec.BLOCK23TEXT,
		x_clev_rec.EXCEPTION_YN,
		x_clev_rec.TEMPLATE_USED,
		x_clev_rec.DATE_TERMINATED,
		x_clev_rec.NAME,
		x_clev_rec.START_DATE,
		x_clev_rec.END_DATE,
		x_clev_rec.DATE_RENEWED,
                x_clev_rec.REQUEST_ID,
                x_clev_rec.PROGRAM_APPLICATION_ID,
                x_clev_rec.PROGRAM_ID,
                x_clev_rec.PROGRAM_UPDATE_DATE,
                x_clev_rec.PRICE_LIST_ID,
                x_clev_rec.PRICING_DATE,
                x_clev_rec.PRICE_LIST_LINE_ID,
                x_clev_rec.LINE_LIST_PRICE,
                x_clev_rec.ITEM_TO_PRICE_YN,
                x_clev_rec.PRICE_BASIS_YN,
                x_clev_rec.CONFIG_HEADER_ID,
                x_clev_rec.CONFIG_REVISION_NUMBER,
                x_clev_rec.CONFIG_COMPLETE_YN,
                x_clev_rec.CONFIG_VALID_YN,
                x_clev_rec.CONFIG_TOP_MODEL_LINE_ID,
                x_clev_rec.CONFIG_ITEM_TYPE,
                x_clev_rec.CONFIG_ITEM_ID,
		x_clev_rec.ATTRIBUTE_CATEGORY,
		x_clev_rec.ATTRIBUTE1,
		x_clev_rec.ATTRIBUTE2,
		x_clev_rec.ATTRIBUTE3,
		x_clev_rec.ATTRIBUTE4,
		x_clev_rec.ATTRIBUTE5,
		x_clev_rec.ATTRIBUTE6,
		x_clev_rec.ATTRIBUTE7,
		x_clev_rec.ATTRIBUTE8,
		x_clev_rec.ATTRIBUTE9,
		x_clev_rec.ATTRIBUTE10,
		x_clev_rec.ATTRIBUTE11,
		x_clev_rec.ATTRIBUTE12,
		x_clev_rec.ATTRIBUTE13,
		x_clev_rec.ATTRIBUTE14,
		x_clev_rec.ATTRIBUTE15,
		x_clev_rec.PRICE_TYPE,
		x_clev_rec.CURRENCY_CODE,
		x_clev_rec.SERVICE_ITEM_YN,
                x_clev_rec.PH_PRICING_TYPE,
                x_clev_rec.PH_ADJUSTMENT,
                x_clev_rec.PH_PRICE_BREAK_BASIS,
                x_clev_rec.PH_MIN_QTY,
                x_clev_rec.PH_MIN_AMT,
                x_clev_rec.PH_QP_REFERENCE_ID,
                x_clev_rec.PH_VALUE,
                x_clev_rec.PH_ENFORCE_PRICE_LIST_YN,
                x_clev_rec.PH_INTEGRATED_WITH_QP;
      CLOSE c_clev_rec;
      -- retrieving line item
      x_cimv_rec := n_cimv_rec;
      OPEN c_cimv_rec( crec.ID );
      FETCH c_cimv_rec
      INTO	x_cimv_rec.ID,
            x_cimv_rec.CLE_ID,
            x_cimv_rec.CHR_ID,
            x_cimv_rec.CLE_ID_FOR,
            x_cimv_rec.DNZ_CHR_ID,
            x_cimv_rec.OBJECT1_ID1,
            x_cimv_rec.OBJECT1_ID2,
            x_cimv_rec.JTOT_OBJECT1_CODE,
            x_cimv_rec.UOM_CODE,
            x_cimv_rec.EXCEPTION_YN,
            x_cimv_rec.NUMBER_OF_ITEMS,
            x_cimv_rec.PRICED_ITEM_YN;
      l_data_found := c_cimv_rec%FOUND;
      CLOSE c_cimv_rec;

      IF l_data_found THEN
        x_clev_rec.PRICE_LIST_ID := top_PRICE_LIST_ID;
        x_clev_rec.PH_PRICING_TYPE := top_PH_PRICING_TYPE;
        x_clev_rec.PH_ADJUSTMENT := top_PH_ADJUSTMENT;

        l_unit_price := OKC_PRICE_PUB.GET_UNIT_PRICE(
                 p_price_list_id     => top_PRICE_LIST_ID,
                 p_inventory_item_id => x_cimv_rec.OBJECT1_ID1,
                 p_uom_code          => x_cimv_rec.UOM_CODE,
                 p_cur_code          => x_clev_rec.CURRENCY_CODE,
                 p_qty               => 1
              );
        IF l_unit_price IS NOT NULL THEN
          x_clev_rec.PRICE_UNIT := l_unit_price ;
        END IF;

        If x_clev_rec.PH_PRICING_TYPE = 'DISCOUNT_PERCENT' THEN
          x_clev_rec.PH_VALUE := x_clev_rec.PH_ADJUSTMENT ;
         ELSIf x_clev_rec.PH_PRICING_TYPE = 'NEW_PRICE' THEN
          x_clev_rec.PH_VALUE := OKC_PRICE_PUB.ROUND_PRICE(
                           x_clev_rec.PRICE_UNIT*(1-x_clev_rec.PH_ADJUSTMENT/100),
                           x_clev_rec.CURRENCY_CODE
                       ) ;
         ELSIf x_clev_rec.PH_PRICING_TYPE = 'DISCOUNT_AMOUNT' THEN
          x_clev_rec.PH_VALUE := OKC_PRICE_PUB.ROUND_PRICE(
                           x_clev_rec.PRICE_UNIT*x_clev_rec.PH_ADJUSTMENT/100,
                           x_clev_rec.CURRENCY_CODE
                       ) ;
        END IF;
        x_clev_rec.cle_id := top_line_id ;
        x_clev_rec.line_number := m_cnt + l_cnt ;
        x_clev_rec.display_sequence := m_cnt + l_cnt ;

        okc_contract_pub.create_contract_line (
           p_api_version		=> p_api_version,
           p_init_msg_list		=> p_init_msg_list,
           x_return_status		=> l_return_status,
           x_msg_count		=> x_msg_count,
           x_msg_data		=> x_msg_data,
           p_restricted_update     =>  p_restricted_update,
           p_clev_rec		=> x_clev_rec,
           x_clev_rec		=> xn_clev_rec
        );
        IF( l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          x_cimv_rec.cle_id := xn_clev_rec.id;
          okc_contract_item_pub.create_contract_item (
               p_api_version		=> p_api_version,
               p_init_msg_list		=> p_init_msg_list,
               x_return_status		=> l_return_status,
               x_msg_count		=> x_msg_count,
               x_msg_data		=> x_msg_data,
               p_cimv_rec		=> x_cimv_rec,
               x_cimv_rec		=> xn_cimv_rec
          );
        END IF;
        l_cnt := l_cnt + 1 ;
      END IF;

      IF( Nvl(p_commit_changes_yn, 'N') = 'Y' ) THEN
        IF( l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          commit;
         ELSE
          rollback;
        END IF;
      END IF;

  END LOOP;
  x_recs_copied := l_cnt-1;
  x_msg_count := Fnd_Msg_Pub.Count_Msg;
  x_msg_data := Fnd_Msg_Pub.Get( p_msg_index => Fnd_Msg_Pub.G_FIRST, p_encoded => FND_API.G_FALSE );
  IF x_msg_count>0 THEN x_return_status := OKC_API.G_RET_STS_ERROR; END IF;
 EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_msg_count := Fnd_Msg_Pub.Count_Msg;
      x_msg_data := Fnd_Msg_Pub.Get( p_msg_index => Fnd_Msg_Pub.G_FIRST, p_encoded => FND_API.G_FALSE );
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END COPY_LINES;

END OKC_PHI_PVT;

/
