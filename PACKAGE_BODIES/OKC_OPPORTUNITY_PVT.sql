--------------------------------------------------------
--  DDL for Package Body OKC_OPPORTUNITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OPPORTUNITY_PVT" AS
/* $Header: OKCROPPB.pls 120.0 2005/05/25 19:31:13 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  g_sales_rep Number;
  g_rty_code okc_k_rel_objs.rty_code%TYPE;
  g_opp_h_created Boolean;
  --
  PROCEDURE CREATE_OPPORTUNITY(p_api_version         IN NUMBER,
                               p_context             IN  VARCHAR2,
                               p_contract_id         IN  NUMBER,
                               p_win_probability     IN  NUMBER,
                               p_expected_close_days IN  NUMBER,
                               x_lead_id             OUT NOCOPY NUMBER,
                               p_init_msg_list       IN VARCHAR2,
                               x_msg_data            OUT NOCOPY VARCHAR2,
                               x_msg_count           OUT NOCOPY NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2) IS
    l_return_status Varchar2(1);
    l_lead_id Number;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_Opportunity');
       okc_debug.log('1000: Entering okc_opportunity_pvt.create_opportunity', 2);
    END IF;
    x_return_status := okc_api.g_ret_sts_success;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1010: Before is_opp_creation_allowed');
    END IF;
    Is_Opp_Creation_Allowed(p_context,
                            p_contract_id,
                            l_return_status);
    If l_return_status <> okc_api.g_ret_sts_success Then
      Raise g_exception_halt_validation;
    End If;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1015: Setting Contract Context');
    END IF;
    okc_context.set_okc_org_context(p_chr_id => p_contract_id);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1020: Before create_opp_header');
    END IF;
    Create_Opp_Header(p_api_version,
                      p_context,
                      p_contract_id,
                      p_win_probability,
                      p_expected_close_days,
                      l_lead_id,
                      p_init_msg_list,
                      l_msg_data,
                      l_msg_count,
                      l_return_status);
    If l_return_status <> okc_api.g_ret_sts_success Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1030: Opp Header Creation Return Status - ' || l_return_status);
      END IF;
      Raise g_exception_halt_validation;
    End If;
    IF (l_debug = 'Y') THEN
       okc_debug.log('1040: Opportunity Lead Id - ' || to_char(l_lead_id));
    END IF;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('1050: Before create_opp_lines');
    END IF;
    Create_Opp_Lines(p_api_version,
                     p_context,
                     p_contract_id,
                     l_lead_id,
                     p_init_msg_list,
                     l_msg_data,
                     l_msg_count,
                     l_return_status);
    IF (l_debug = 'Y') THEN
       okc_debug.log('1060: After create_opp_lines');
    END IF;
    If l_return_status <> okc_api.g_ret_sts_success Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('1060: Opp Lines Creation Return Status - ' || l_return_status);
      END IF;
      Raise g_exception_halt_validation;
    End If;
    --

    x_lead_id := l_lead_id;
    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Exiting okc_opportunity_pvt.create_opportunity', 2);
       okc_debug.Reset_Indentation;
    END IF;
  Exception
    When g_exception_halt_validation Then
      x_return_status := l_return_status;
      IF (l_debug = 'Y') THEN
         okc_debug.log('1970: Exiting okc_opportunity_pvt.create_opportunity', 2);
         okc_debug.Reset_Indentation;
      END IF;
    When Others Then
      okc_api.Set_Message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := okc_api.g_ret_sts_unexp_error;
      IF (l_debug = 'Y') THEN
         okc_debug.log('1990: Exiting okc_opportunity_pvt.create_opportunity', 2);
         okc_debug.Reset_Indentation;
      END IF;
  End Create_Opportunity;

  PROCEDURE CREATE_OPP_HEADER(p_api_version         IN NUMBER,
                              p_context             IN  VARCHAR2,
                              p_contract_id         IN  NUMBER,
                              p_win_probability     IN  NUMBER,
                              p_expected_close_days IN  NUMBER,
                              x_lead_id             OUT NOCOPY NUMBER,
                              p_init_msg_list       IN VARCHAR2,
                              x_msg_data            OUT NOCOPY VARCHAR2,
                              x_msg_count           OUT NOCOPY NUMBER,
                              x_return_status       OUT NOCOPY VARCHAR2) IS
    cursor c1 is
    select h.contract_number,
           h.contract_number_modifier,
           h.description,
           h.estimated_amount,
           h.estimated_amount_renewed,
           h.currency_code,
           h.authoring_org_id,
           h.orig_system_source_code,
           h.orig_system_id1,
           rel.object1_id1 lead_id
      from okc_k_headers_v h,
           okc_k_rel_objs rel
     where h.id = p_contract_id
       and rel.chr_id(+) = h.orig_system_id1
       and rel.rty_code(+) = 'OPPEXPSCONTRACT'
       and rel.jtot_object1_code(+) = 'OKX_OPPHEAD';
    --
    cursor c2(p_rle_code okc_k_party_roles_b.rle_code%TYPE) is
    select object1_id1
      from okc_k_party_roles_b
     where dnz_chr_id = p_contract_id
       and cle_id is null
       and rle_code = p_rle_code;
    --
    cursor c3 (p_object_code in okc_contacts.jtot_object1_code%TYPE) is
    select resource_id
      from jtf_rs_salesreps
     where salesrep_id in (select object1_id1
                             from okc_contacts
                            where dnz_chr_id = p_contract_id
                              and jtot_object1_code = p_object_code);
    --
    /* cursor c4 is
    select sales_group_id
      from as_fc_salesforce_v
     where salesforce_id = (select resource_id
                              from jtf_rs_salesreps
                             where salesrep_id = g_sales_rep); */
    --
    cursor c5(p_rule_information_category IN
              okc_rules_b.rule_information_category%TYPE) is
    select rule_information1,
           rule_information2,
           rule_information3,
           rule_information4,
           rule_information5,
           jtot_object1_code,
           object1_id1
      from okc_rules_b
     where dnz_chr_id = p_contract_id
       and rule_information_category = p_rule_information_category;
    --

     cursor c6 (b_id1 NUMBER, p_use_code VARCHAR2) IS
     SELECT party_site_id
     FROM   okx_cust_site_uses_v
     WHERE  id1 = b_id1
     AND    site_use_code = p_use_code   -- ship..to_party_site_id
     AND    status        = 'A'  -- Active Status
     AND    nvl(ORG_ID,-99) = SYS_CONTEXT('OKC_CONTEXT', 'ORG_ID');


     cursor c7 (b_win_probability NUMBER) is
     select sales_stage_id
           ---name, min_win_probability, max_win_probability,
           ---min_win_probability || ' - ' || max_win_probability probability_range,
           ---description
     from  OKX_OPP_SALES_STAGES_V     ---as_sales_stages_all_vl
     where  enabled_flag = 'Y' and
            ( ( (sysdate > start_date_active) and (end_date_active is null) ) or
               (sysdate between start_date_active and end_date_active) )
       and  b_win_probability between min_win_probability and max_win_probability;
           ---order by min_win_probability, max_win_probability;

    c1_rec c1%ROWTYPE;
    c5_rec c5%ROWTYPE;
    c51_rec c5%ROWTYPE;
    c6_rec c6%ROWTYPE;

    c7_rec c7%ROWTYPE;

    l_header_rec as_opportunity_pub.header_rec_type;
    l_in_crjv_tbl okc_k_rel_objs_pub.crjv_tbl_type;
    l_out_crjv_tbl okc_k_rel_objs_pub.crjv_tbl_type;
    l_return_status Varchar2(1);
    l_msg_count Number;
    l_msg_data Varchar2(255);
    l_lead_id Number;
    l_win_probability Number := p_win_probability;
    l_expected_close_days Number := p_expected_close_days;
    l_customer_id Number;
    l_group_id Number;

    l_sales_stage_id NUMBER;
    l_party_site_id  NUMBER;

    l_note_id Number;
    l_cr_note VARCHAR2(30) := 'OKC_OPP_CREATED_FROM_K';
    Note_Message VARCHAR2(2000); -- Bug : 2589898 ENHANCED TO VARCHAR2(2000) FROM VARCHAR2(300)

  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_Opp_Header');
       okc_debug.log('3000: Entering okc_opportunity_pvt.create_opp_header', 2);
    END IF;
    x_return_status := okc_api.g_ret_sts_success;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('3010: Before Get_Opp_Defaults');
    END IF;
    Get_Opp_Defaults(p_context,
                     p_contract_id,
                     l_win_probability,
                     l_expected_close_days,
                     l_return_status);
    If l_return_status <> okc_api.g_ret_sts_success Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('3019: Get_Opp_Defaults Return Status - ' || l_return_status);
      END IF;
      Raise g_exception_halt_validation;
    End If;
    -- Get Contract's details
    Open c1;
    Fetch c1 into c1_rec;
    Close c1;

    -- If contract is renewed and there's EXPIRE opportunity for pre-renewed
    -- contract: we should just link the new contract to the opportunity
  IF p_context = 'RENEW' and c1_rec.lead_id IS NOT NULL and c1_rec.orig_system_source_code='OKC_HDR' THEN
    IF (l_debug = 'Y') THEN
       okc_debug.log('3020: The contract is renewed from contract id #' || c1_rec.orig_system_id1 );
       okc_debug.log('3021: There is opportunity #' || c1_rec.lead_id || ' for pre-renewed contract' );
       okc_debug.log('3022: It will be reused (linked) for the new (renewed) contract' );
    END IF;
    l_lead_id := c1_rec.lead_id ;
    g_opp_h_created := FALSE; -- is used to prevent old header removing
    l_cr_note := 'OKC_OPP_LINKED_TO_K';
   ELSE
    g_opp_h_created := TRUE;

    -- Get Customer ID
    Open c2('CUSTOMER');
    Fetch c2 Into l_customer_id;
    Close c2;
    IF (l_debug = 'Y') THEN
       okc_debug.log('3030: Customer ID - ' || To_Char(l_customer_id));
    END IF;
    -- Get Sales Rep ID, store it in a global so that it can be used
    -- later for opp lines creation
    g_sales_rep := Null;
    Open c3('OKX_SALEPERS');
    Fetch c3 Into g_sales_rep;
    Close c3;
    IF (l_debug = 'Y') THEN
       okc_debug.log('3040: Sales Rep ID - ' || To_Char(g_sales_rep));
    END IF;
    --
    /* Open c4;
    Fetch c4 Into l_group_id;
    Close c4; */
    -- Get the price list ID
    Open c5('PRE');
    Fetch c5 Into c5_rec;
    Close c5;


    --TEMP okc_util.init_trace();
    IF  nvl(fnd_profile.value('AS_OPP_ADDRESS_REQUIRED'), okc_api.g_miss_char) = 'Y' THEN

        Open c5('STO');  --get the site_use_id of the ship_to_party_site_id
        Fetch c5 Into c51_rec;
            IF c5%NOTFOUND OR c51_rec.object1_id1 IS NULL THEN
               okc_api.Set_Message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_OPP_NO_SHIP_ADDRESS'
                                  );
               l_return_status := OKC_API.G_RET_STS_ERROR;
               raise g_exception_halt_validation;
            END IF;
        Open c6(c51_rec.object1_id1,'SHIP_TO'); --get the party_site_id
        Fetch c6 Into c6_rec;
            IF c6%NOTFOUND OR c6_rec.party_site_id IS NULL THEN
               okc_api.Set_Message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKC_OPP_NO_PARTY_SITE_ID',
                                   p_token1        => 'SITE_USE_ID',
                                   p_token1_value  => c51_rec.object1_id1
                                  );
               l_return_status := OKC_API.G_RET_STS_ERROR;
               raise g_exception_halt_validation;
            END IF;
            l_party_site_id := nvl(to_number(c6_rec.party_site_id), okc_api.g_miss_num);
        Close c5;
        Close c6;

    END IF;


    -- Continue preparing the opp header record for the api call

    IF c1_rec.contract_number_modifier IS NULL THEN -- ???
      l_header_rec.description := c1_rec.contract_number;
     ELSE
      l_header_rec.description := c1_rec.contract_number || ' ' ||
                                c1_rec.contract_number_modifier;
    END IF;

    IF p_context = 'RENEW' THEN
       --Bug 2033933 KTST1156: OPPORTUNITIES FROM K RENEWALS DON'T HAVE AN AMOUNT
       l_header_rec.total_amount := c1_rec.estimated_amount_renewed;
    ELSE
       --proceed as usual
       l_header_rec.total_amount := c1_rec.estimated_amount;
    END IF;
    --NOTE! Bug 2050044: We do not now consider the estimated amount as the total_amount because
    --      the total_amount is updated with the sum of the negotiated amounts of the
    --      contract lines later. See history entry for 23-OCT-2001
    --      (see l_header_rec.total_amount := l_updt_hdr_tot_amt; in CREATE_OPP_LINES)



    l_header_rec.currency_code := c1_rec.currency_code;
    l_header_rec.org_id := c1_rec.authoring_org_id;

    IF p_context = 'EXPIRE' THEN
       --Bug 2034318
       --Action assembler defaults the win probability parameter to 50 when calling
       --opportunity. This value may not be valid so we are defaulting it from profile option
       l_header_rec.win_probability := NVL(to_number(Fnd_Profile.Value('AS_OPP_WIN_PROBABILITY')), OKC_API.G_MISS_NUM);
    ELSE
       --proceed as usual
       l_header_rec.win_probability := l_win_probability;
    END IF;


    l_header_rec.decision_date := sysdate + nvl(l_expected_close_days, 0);
    l_header_rec.customer_id := l_customer_id;
    l_header_rec.price_list_id := c5_rec.object1_id1;

    --TEMP okc_util.print_trace(9,'Opportunity name i.e. description: ' || l_header_rec.description);
    IF (l_debug = 'Y') THEN
       okc_debug.log('Opportunity name i.e. description: ' || l_header_rec.description);
    END IF;

    begin   --get sales_stage_id
       OPEN c7(l_win_probability); --get sales_stage_id
       FETCH c7 INTO l_sales_stage_id;
       CLOSE c7;
       l_header_rec.sales_stage_id := NVL(l_sales_stage_id, OKC_API.G_MISS_NUM);
       --TEMP okc_util.print_trace(9,'l_sales_stage_id : ' || l_sales_stage_id);
       IF (l_debug = 'Y') THEN
          okc_debug.log('l_sales_stage_id : ' || TO_CHAR(l_sales_stage_id));
       END IF;
    exception
    when others then
         null;
    end;

    --get value for AMS_P_SOURCE_CODES_V.SOURCE_CODE_ID
    IF nvl(TO_NUMBER(fnd_profile.value('OKC_DEFAULT_OPP_CODE')), okc_api.g_miss_num)  = OKC_API.G_MISS_NUM
                                               AND
       nvl(fnd_profile.value('AS_OPP_SOURCE_CODE_REQUIRED'), okc_api.g_miss_char)  = 'Y'
    THEN
         okc_api.Set_Message(p_app_name      => g_app_name,
                             p_msg_name      => 'OKC_OPP_NO_DEFLT_OPP_CODE'
                            );
         l_return_status := OKC_API.G_RET_STS_ERROR;
         raise g_exception_halt_validation;
    END IF;
    l_header_rec.source_promotion_id := nvl(TO_NUMBER(fnd_profile.value('OKC_DEFAULT_OPP_CODE')), okc_api.g_miss_num);
    --TEMP okc_util.print_trace(9,'l_header_rec.source_promotion_id: ' || l_header_rec.source_promotion_id);
    IF (l_debug = 'Y') THEN
       okc_debug.log('l_header_rec.source_promotion_id: ' || TO_CHAR(l_header_rec.source_promotion_id));
    END IF;

    l_header_rec.address_id := nvl(to_number(l_party_site_id), okc_api.g_miss_num);
    --TEMP okc_util.print_trace(9,'l_header_rec.address_id: ' || l_header_rec.address_id);
    IF (l_debug = 'Y') THEN
       okc_debug.log('l_header_rec.address_id: ' || TO_CHAR(l_header_rec.address_id));
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Before as_opportunity_pub.create_opp_header');
    END IF;
    -- Finally call the opp header api
    AS_OPPORTUNITY_PUB.Create_Opp_Header(
        p_api_version_number     => 2.0, --p_api_version,---2.0,
        p_init_msg_list          => p_init_msg_list, --fnd_api.g_false,
        p_commit                 => fnd_api.g_false,
        p_validation_level       => fnd_api.g_valid_level_full,
        p_header_rec             => l_header_rec,
        p_check_access_flag      => 'Y',
        p_admin_flag             => 'N',
        p_admin_group_id         => Null,
        p_identity_salesforce_id => g_sales_rep,
        -- p_salesgroup_id          => l_group_id,
        p_salesgroup_id          => Null,
        p_partner_cont_party_id  => Null,
        p_profile_tbl            => as_utility_pub.g_miss_profile_tbl,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        x_lead_id                => l_lead_id);
    --
    --Note: final commit is done in OKC_OPPORUNTITY_PUB.create_opportunity!
    IF (l_debug = 'Y') THEN
       okc_debug.log('3510: After as_opportunity_pub.create_opp_header');
    END IF;
    --TEMP okc_util.print_trace(9, 'x_lead_id returned: ' || l_lead_id);
    IF (l_debug = 'Y') THEN
       okc_debug.log('x_lead_id returned: ' || TO_CHAR(l_lead_id));
    END IF;
    If l_return_status <> okc_api.g_ret_sts_success Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('3520: Return Status from Opp header Creation - ' || l_return_status);
      END IF;
      Raise g_exception_halt_validation;
    End If;

  END IF; --    IF p_context = 'RENEW' and c1_rec.lead_id IS NOT NULL and c1_rec.orig_system_source_code='OKC_HDR' THEN

    -- Populate the rel object table to maintain the relationship
    -- between the contract and the opportunity header just created
    l_in_crjv_tbl(1).object_version_number := 1;
    l_in_crjv_tbl(1).chr_id := p_contract_id;
    l_in_crjv_tbl(1).jtot_object1_code := 'OKX_OPPHEAD';
    l_in_crjv_tbl(1).object1_id1 := l_lead_id;
    l_in_crjv_tbl(1).object1_id2 := '#';
    l_in_crjv_tbl(1).rty_code := g_rty_code;
    IF (l_debug = 'Y') THEN
       okc_debug.log('3530: Before creating relation objects');
    END IF;
    -- Call the rel object api
    okc_k_rel_objs_pub.Create_Row(
              p_api_version   => 1.0, --p_api_version,--1.0,
              p_init_msg_list => p_init_msg_list, --okc_api.g_false,
              x_return_status => l_return_status,
              x_msg_count     => l_msg_count,
              x_msg_data      => l_msg_data,
              p_crjv_tbl      => l_in_crjv_tbl,
              x_crjv_tbl      => l_out_crjv_tbl);
    IF (l_debug = 'Y') THEN
       okc_debug.log('3540: After creating relation objects');
    END IF;
    If l_return_status <> okc_api.g_ret_sts_success Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('3550: Return Status from Rel Objects Creation - ' || l_return_status);
      END IF;
      Raise g_exception_halt_validation;
    End If;

    FND_MESSAGE.Set_Name('OKC', l_cr_note);
    FND_MESSAGE.Set_Token('KNUMBER', c1_rec.contract_number , FALSE);
    FND_MESSAGE.Set_Token('KMODIFIER', c1_rec.contract_number_modifier, FALSE);
    FND_MESSAGE.Set_Token('CONTEXT', p_context, FALSE);
    Note_Message := FND_MESSAGE.Get;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3560: note creation:'|| Note_Message);
    END IF;

    JTF_NOTES_PUB.Create_note (
               p_api_version          =>  1.0,
               p_init_msg_list        =>  FND_API.G_FALSE,
               p_commit               =>  FND_API.G_FALSE,
               x_return_status        =>  l_return_status,
               x_msg_count            =>  l_msg_count,
               x_msg_data             =>  l_msg_data,
               p_source_object_id     =>  l_lead_id,
               p_source_object_code   =>  'OPPORTUNITY',
               p_notes                =>  Note_Message,
               p_note_status          =>  'E',
               p_note_type            =>  'AS_SYSTEM',
               p_entered_by           =>  FND_GLOBAL.USER_ID,
               p_entered_date         =>  SYSDATE,
               x_jtf_note_id          =>  l_note_id,
               p_last_update_date     =>  SYSDATE,
               p_last_updated_by      =>  FND_GLOBAL.USER_ID,
               p_creation_date        =>  SYSDATE,
               p_created_by           =>  FND_GLOBAL.USER_ID,
               p_last_update_login    =>  FND_GLOBAL.LOGIN_ID
           );

    IF (l_debug = 'Y') THEN
       okc_debug.log('3570: After creating note');
    END IF;
    If l_return_status <> okc_api.g_ret_sts_success Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('3580: Return Status from Note Creation - ' || l_return_status);
      END IF;
      Raise g_exception_halt_validation;
    End If;

    -- Pass the header opp id back to the caller
    x_lead_id := l_lead_id;

      x_msg_data := l_msg_data;
      x_msg_count := l_msg_count;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Exiting okc_opportunity_pvt.create_opp_header', 2);
       okc_debug.Reset_Indentation;
    END IF;
  Exception
    When g_exception_halt_validation Then
      x_return_status := l_return_status;
      IF (l_debug = 'Y') THEN
         okc_debug.log('3980: Exiting okc_opportunity_pvt.create_opp_header', 2);
         okc_debug.Reset_Indentation;
      END IF;
    When Others Then
      okc_api.Set_Message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := okc_api.g_ret_sts_unexp_error;
      IF (l_debug = 'Y') THEN
         okc_debug.log('3990: Exiting okc_opportunity_pvt.create_opp_header', 2);
         okc_debug.Reset_Indentation;
      END IF;
  End Create_Opp_Header;
  --
  PROCEDURE CREATE_OPP_LINES(p_api_version         IN NUMBER,
                             p_context       IN  VARCHAR2,
                             p_contract_id   IN  NUMBER,
                             p_lead_id       IN  NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2) IS
    -- pl/sql tables for bulk fetch
    Type id_tbl Is Table of okc_k_lines_b.id%Type
                   Index By Binary_Integer;
/*    Type price_unit_tbl Is Table of okc_k_lines_b.price_unit%Type
                   Index By Binary_Integer;
    Type price_negotiated_tbl Is Table of okc_k_lines_b.price_negotiated%Type
                   Index By Binary_Integer;
    Type currency_code_tbl Is Table of okc_k_lines_b.currency_code%Type
                   Index By Binary_Integer;*/
    Type Lead_Line_Id_tbl Is Table of NUMBER
                   Index By Binary_Integer;
    --
/*    l_id_tbl id_tbl;
    l_cle_id_tbl id_tbl;
    l_price_unit_tbl price_unit_tbl;
    l_price_negotiated_tbl price_negotiated_tbl;
    l_currency_code_tbl currency_code_tbl;*/
    l_object1_id1 okc_k_items.object1_id1%Type;
    l_object1_id2 okc_k_items.object1_id2%Type;
    l_uom_code okc_k_items.uom_code%Type;
    l_number_of_items okc_k_items.number_of_items%Type;
    l_rel_id_tbl id_tbl;
    l_rel_lead_line_id_tbl Lead_Line_Id_tbl;
    --
    l_header_rec as_opportunity_pub.header_rec_type;
    l_line_tbl as_opportunity_pub.line_tbl_type;
    l_line_out_tbl as_opportunity_pub.line_out_tbl_type;
    l_in_crjv_tbl okc_k_rel_objs_pub.crjv_tbl_type;
    l_out_crjv_tbl okc_k_rel_objs_pub.crjv_tbl_type;
    --
    l_org_id Number;
    l_count Number;
    l_row_notfound Boolean;
    l_return_status Varchar2(1);
    l_msg_count Number;
    l_msg_data Varchar2(255);
    l_index Number;
    l_rel_index Number;
    -- next lines added as bug#2205445 fix
    l_interest_type_id Number;
    l_primary_interest_code_id Number;
    l_secondary_interest_code_id Number;
    --


    l_updt_hdr_tot_amt  Number;
    l_lead_id Number;
/*
    cursor line_csr_sum_amt is
    select SUM(DECODE(p_context, 'RENEW', cle.price_negotiated_renewed, cle.price_negotiated))
      from okc_k_lines_b cle
     where level = 1
     start with cle.id in (select cle2.id
                             from okc_k_lines_b cle2,
                                  okc_k_items itm,
                                  okc_statuses_b sts,
                                                    jtf_object_usages jou
                            where cle2.dnz_chr_id = p_contract_id
                              and cle2.date_renewed is null
                              and cle2.sts_code = sts.code
                              and itm.cle_id = cle.id
                              -- and itm.jtot_object1_code = 'OKX_LICPROD'
                              and itm.jtot_object1_code = jou.object_code
                                                and jou.object_user_code = 'OKX_MTL_SYSTEM_ITEM'
                              and sts.ste_code <> 'TERMINATED'
                              and ((p_context = 'EXPIRE'
                              and   sts.ste_code in ('ACTIVE', 'SIGNED'))
                               or  (p_context in ('AUTHORING', 'RENEW')
                              and   sts.ste_code = 'ENTERED'))
                              and not exists (select 'x'
                                                from okc_k_rel_objs rel
                                               where (rel.cle_id = cle2.id
                                                  or  rel.cle_id = cle2.cle_id)
                                                 and rel.rty_code = g_rty_code))
    connect by prior cle.id = cle.cle_id;
*/
    -- The new cursor to select top lines which should be creates
    cursor line_csr is
    select cle.id,
           cle.cle_id,
           cle.price_unit,
           cle.price_negotiated,
           cle.currency_code,
           cle.orig_system_source_code,
           cle.orig_system_id1,
           itm.object1_id1,
           itm.object1_id2,
           itm.uom_code,
           itm.number_of_items
      from okc_k_lines_b cle,
           okc_k_items itm,
           okc_statuses_b sts,
           jtf_object_usages jou
      where cle.chr_id = p_contract_id
        and cle.date_renewed is null
        and cle.sts_code = sts.code
        and itm.cle_id = cle.id
        -- and itm.jtot_object1_code = 'OKX_LICPROD'
        and itm.jtot_object1_code = jou.object_code
        and jou.object_user_code = 'OKX_MTL_SYSTEM_ITEM'
        and sts.ste_code <> 'TERMINATED'
        and ((p_context = 'EXPIRE' and sts.ste_code in ('ACTIVE', 'SIGNED'))
         or  (p_context in ('AUTHORING', 'RENEW') and sts.ste_code = 'ENTERED'))
        and not exists (select 'x' from okc_k_rel_objs rel
                           where (rel.cle_id = cle.id
                           or  rel.cle_id = cle.cle_id)
                           and rel.rty_code = g_rty_code)
    ;
    -- The old one
/*    cursor line_csr is
    select cle.id,
           cle.cle_id,
           cle.price_unit,
           cle.price_negotiated,
           cle.currency_code
      from okc_k_lines_b cle
     where level = 1
     start with cle.id in (select cle2.id
                             from okc_k_lines_b cle2,
                                  okc_k_items itm,
                                  okc_statuses_b sts,
						    jtf_object_usages jou
                            where cle2.dnz_chr_id = p_contract_id
                              and cle2.date_renewed is null
                              and cle2.sts_code = sts.code
                              and itm.cle_id = cle.id
                              -- and itm.jtot_object1_code = 'OKX_LICPROD'
                              and itm.jtot_object1_code = jou.object_code
						and jou.object_user_code = 'OKX_MTL_SYSTEM_ITEM'
                              and sts.ste_code <> 'TERMINATED'
                              and ((p_context = 'EXPIRE'
                              and   sts.ste_code in ('ACTIVE', 'SIGNED'))
                               or  (p_context in ('AUTHORING', 'RENEW')
                              and   sts.ste_code = 'ENTERED'))
                              and not exists (select 'x'
                                                from okc_k_rel_objs rel
                                               where (rel.cle_id = cle2.id
                                                  or  rel.cle_id = cle2.cle_id)
                                                 and rel.rty_code = g_rty_code))
    connect by prior cle.id = cle.cle_id;
*/
--
    cursor exp_rel_csr (p_cle_id okc_k_items.cle_id%TYPE)is
        select object1_id1, object1_id2
          from okc_k_rel_objs rel
          where rel.cle_id = p_cle_id
            and rel.rty_code = 'OPPEXPSCONTRACT';
--
/*    cursor item_csr (p_cle_id okc_k_items.cle_id%TYPE)is
    select itm.object1_id1,
           itm.object1_id2,
           itm.uom_code,
           itm.number_of_items
      from okc_k_items itm,
		 jtf_object_usages jou
     where itm.cle_id = p_cle_id
       -- and itm.jtot_object1_code = 'OKX_LICPROD'
       -- and itm.jtot_object1_code = 'OKX_MTL_SYSTEM_ITEMS'
       and itm.jtot_object1_code = jou.object_code
	  and jou.object_user_code = 'OKX_MTL_SYSTEM_ITEM'
       and rownum = 1; */
    --
    -- Cursor selects interest type (Marketing Category) for the inventory item
    --
    cursor item_interest_csr (p_organization_id NUMBER, p_inv_item_id NUMBER)is
    SELECT interest_type_id,
           primary_interest_code_id,
           secondary_interest_code_id
--      FROM AST_INV_ITEM_LOV_V
      FROM (
SELECT
      mic.organization_id,
      mic.inventory_item_id,
      mc.segment1 interest_type_id,
      mc.segment2 primary_interest_code_id,
      mc.segment3 secondary_interest_code_id
FROM  fnd_id_flex_structures fifs,
      mtl_item_categories mic,
      MTL_CATEGORIES_B MC
WHERE fifs.id_flex_code = 'MCAT' AND fifs.application_id = 401
  AND fifs.id_flex_structure_code = 'SALES_CATEGORIES'
  AND mc.structure_id = fifs.id_flex_num
  and mc.SEGMENT1 < 'A' AND mic.category_set_id = 5
  AND mic.category_id = mc.category_id
      )
      WHERE organization_id = p_organization_id
        and inventory_item_id=p_inv_item_id;
/*    --
    Function Parent_Inv_Item_Exists(p_cle_id Number) Return Boolean IS
      l_ret Boolean := False;
    Begin
      For i in l_id_tbl.FIRST..l_id_tbl.LAST
      Loop
        If p_cle_id = l_id_tbl(i) Then
          l_ret := True;
          Exit;
        End If;
      End Loop;
      Return l_ret;
    End Parent_Inv_Item_Exists;
*/    --
   --
   --
  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Create_Opp_Lines');
       okc_debug.log('5000: Entering okc_opportunity_pvt.create_opp_lines', 2);
       okc_debug.log('       with next parameters:', 2);
       okc_debug.log('       p_context      = '||p_context);
       okc_debug.log('       p_contract_id  = '||p_contract_id);
       okc_debug.log('       p_lead_id      = '||p_lead_id);
       okc_debug.log('       g_rty_code     = '||g_rty_code);
    END IF;
    x_return_status := okc_api.g_ret_sts_success;
    -- Set the org_id for the curernt contract
    l_org_id := okc_context.get_okc_org_id;
    -- set the opp header id
    l_header_rec.lead_id := p_lead_id;
/*
    -- added to update header amt
    -- Bug 2050044
     OPEN line_csr_sum_amt;
       FETCH line_csr_sum_amt INTO l_updt_hdr_tot_amt;
     CLOSE line_csr_sum_amt;

    l_header_rec.total_amount := l_updt_hdr_tot_amt;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5005: Updating total header amount to '||l_updt_hdr_tot_amt, 2);
    END IF;
    -- update header now
    AS_OPPORTUNITY_PUB.Update_Opp_Header
    (   p_api_version_number        => 2.0,
        p_init_msg_list             => p_init_msg_list,
        p_commit                    => fnd_api.g_false,
        p_validation_level          => fnd_api.g_valid_level_full,
        p_header_rec                => l_header_rec,
        p_check_access_flag         => 'Y',
        p_admin_flag                => 'N',
        p_admin_group_id            => Null,
        p_identity_salesforce_id    => g_sales_rep,
        p_partner_cont_party_id	    => Null,
        p_profile_tbl	    	    => as_utility_pub.g_miss_profile_tbl,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data,
        x_lead_id                   => l_lead_id );
*/
    -- end added


    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('5010: Before opening cursor line_csr');
    END IF;
/* -- GF
    -- Get all the eligible contract lines for opp lines creation
    Open line_csr;
    Fetch line_csr Bulk Collect
     Into l_id_tbl,
          l_cle_id_tbl,
          l_price_unit_tbl,
          l_price_negotiated_tbl,
          l_currency_code_tbl;
    Close line_csr;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('5020: After Closing cursor line_csr');
    END IF;
    l_count := l_id_tbl.count;
    IF (l_debug = 'Y') THEN
       okc_debug.log('5030: Number of lines for Opp creation - ' || to_char(l_count));
    END IF;
*/
    -- Process further only if there are some eligible lines.
    -- This should not arise since is_opp_creation_allowed will return Error
    -- in this case
    l_updt_hdr_tot_amt := 0; --??
--    If l_count > 0 Then
      l_index := 1;
      l_rel_index := 1;
      FOR line_csr_rec IN line_csr LOOP
        l_object1_id1 := NULL;
        l_object1_id2 := NULL;
        IF p_context='RENEW' and line_csr_rec.orig_system_source_code='OKC_LINE'
           AND line_csr_rec.orig_system_id1 IS NOT NULL
         THEN
          Open exp_rel_csr( line_csr_rec.orig_system_id1 );
          Fetch exp_rel_csr Into l_object1_id1, l_object1_id2;
          Close exp_rel_csr;
        END IF;
          -- Prepare a separate table for lines id for later use
          -- for rel objects creation. We cannot use the same l_id_tbl
          -- here since there might be some mismatch between this table
          -- and the output lines_out_tbl from the api call. This could
          -- happen if opportunity was created as for expired contract
          -- for original line_csr(before it was renewed). In this case
          -- we should create link to the opportunity for the new (renewed) line.
        l_rel_id_tbl(l_rel_index) := line_csr_rec.id;
        -- IF l_object1_id1 is NULL it'll be populated after opportunity line is created
        l_rel_lead_line_id_tbl(l_rel_index) := l_object1_id1;
        l_rel_index := l_rel_index + 1;
        IF l_object1_id1 IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
             okc_debug.log('5031.1: Opportunity line #'||l_object1_id1||' has already been created as expired for renewed line ');
          END IF;
         else
        -- Make sure the parent is not already processed
--        If Not Parent_Inv_Item_Exists(l_cle_id_tbl(i)) Then
          IF (l_debug = 'Y') THEN
             okc_debug.log('5031.2: Contract line '||line_csr_rec.id||' is going to be included into opportunity');
          END IF;
/*
          -- Get the item details
          l_object1_id1 := NULL;
          l_object1_id2 := NULL;
          l_uom_code := NULL;
          l_number_of_items := NULL;
          Open item_csr(l_id_tbl(i));
          Fetch item_csr
           Into l_object1_id1,
                l_object1_id2,
                l_uom_code,
                l_number_of_items;
          Close item_csr;
*/
          -- Get Interest codes for opportunity lines
          l_interest_type_id := NULL;
          l_primary_interest_code_id := NULL;
          l_secondary_interest_code_id := NULL;
          Open item_interest_csr( line_csr_rec.object1_id2, line_csr_rec.object1_id1 );
          Fetch item_interest_csr
           Into l_interest_type_id,
                l_primary_interest_code_id,
                l_secondary_interest_code_id;
          Close item_interest_csr;
          -- Prepare the opp lines table for api call
          l_line_tbl(l_index).lead_id := p_lead_id;
          IF (l_debug = 'Y') THEN
             okc_debug.log('5032:   inventory_item_id='||line_csr_rec.object1_id1);
          END IF;
          l_line_tbl(l_index).inventory_item_id := line_csr_rec.object1_id1;
          l_line_tbl(l_index).organization_id := line_csr_rec.object1_id2;
          IF (l_debug = 'Y') THEN
             okc_debug.log('5033:   uom_code='||line_csr_rec.uom_code);
          END IF;
          l_line_tbl(l_index).uom_code := line_csr_rec.uom_code;
          IF (l_debug = 'Y') THEN
             okc_debug.log('5034:   quantity='||line_csr_rec.number_of_items);
          END IF;
          l_line_tbl(l_index).quantity := line_csr_rec.number_of_items;
          IF (l_debug = 'Y') THEN
             okc_debug.log('5035:   total_amount='||line_csr_rec.price_negotiated);
          END IF;
          l_line_tbl(l_index).total_amount := line_csr_rec.price_negotiated;
          l_line_tbl(l_index).unit_price := line_csr_rec.price_unit;
          l_line_tbl(l_index).price := line_csr_rec.price_negotiated;
          l_line_tbl(l_index).currency_code := line_csr_rec.currency_code;
          l_line_tbl(l_index).org_id := l_org_id;
          IF (l_debug = 'Y') THEN
             okc_debug.log('5035:   interest_type_id='||l_interest_type_id);
          END IF;
          l_line_tbl(l_index).interest_type_id := l_interest_type_id;
          l_line_tbl(l_index).primary_interest_code_id := l_primary_interest_code_id;
          l_line_tbl(l_index).secondary_interest_code_id := l_secondary_interest_code_id;
          l_updt_hdr_tot_amt := l_updt_hdr_tot_amt + l_line_tbl(l_index).total_amount;
          l_index := l_index + 1;
        End If;
      End Loop;
      --
      l_header_rec.total_amount := l_updt_hdr_tot_amt; --??
      IF (l_debug = 'Y') THEN
         okc_debug.log('5040:     '||l_line_tbl.count ||' lines are requested to be created on total amount:'||l_updt_hdr_tot_amt);
      END IF;
      -- Call the opp lines api
      IF l_line_tbl.count>0 THEN
        IF (l_debug = 'Y') THEN
           okc_debug.log('5043: Before calling as_opportunity_pub.create_opp_lines');
        END IF;
        AS_OPPORTUNITY_PUB.Create_Opp_Lines(
          p_api_version_number     => 2.0, --p_api_version,--2.0,
          p_init_msg_list          => p_init_msg_list, --fnd_api.g_false,
          p_commit                 => fnd_api.g_false,
          p_validation_level       => fnd_api.g_valid_level_full,
          p_line_tbl               => l_line_tbl,
          p_header_rec             => l_header_rec,
          p_check_access_flag      => 'Y',
          p_admin_flag             => 'N',
          p_admin_group_id         => Null,
          p_identity_salesforce_id => g_sales_rep,
          -- p_salesgroup_id          => l_group_id,
          p_salesgroup_id          => Null,
          p_partner_cont_party_id  => Null,
          p_profile_tbl            => as_utility_pub.g_miss_profile_tbl,
          x_line_out_tbl           => l_line_out_tbl,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);
        --
        IF (l_debug = 'Y') THEN
           okc_debug.log('5048: After calling as_opportunity_pub.create_opp_lines');
        END IF;
        If l_return_status <> okc_api.g_ret_sts_success Then
          IF (l_debug = 'Y') THEN
             okc_debug.log('5049: Opp Lines Return Status - ' || l_return_status);
          END IF;
          Raise g_exception_halt_validation;
        End If;
        --
        l_count := l_line_out_tbl.count;
       ELSE
        IF (l_debug = 'Y') THEN
           okc_debug.log('5060: There are not lines to be inserted into Oppurtunity');
        END IF;
        IF g_opp_h_created THEN
         IF (l_debug = 'Y') THEN
            okc_debug.log('5061: We should remove Opportunity Header because we''ve created it by mistake');
            okc_debug.log('5063: Before calling as_opportunity_pub.Delete_Opp_Header');
         END IF;
         AS_OPPORTUNITY_PUB.Delete_Opp_Header(
          p_api_version_number     => 2.0, --p_api_version,--2.0,
          p_init_msg_list          => p_init_msg_list, --fnd_api.g_false,
          p_commit                 => fnd_api.g_false,
          p_validation_level       => fnd_api.g_valid_level_full,
          p_header_rec             => l_header_rec,
          p_check_access_flag      => 'Y',
          p_admin_flag             => 'N',
          p_admin_group_id         => Null,
          p_identity_salesforce_id => g_sales_rep,
          p_partner_cont_party_id  => Null,
          p_profile_tbl            => as_utility_pub.g_miss_profile_tbl,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          x_lead_id                => l_lead_id
          );
         --
         IF (l_debug = 'Y') THEN
            okc_debug.log('5068: After calling as_opportunity_pub.Delete_Opp_Header');
         END IF;
         If l_return_status <> okc_api.g_ret_sts_success Then
          IF (l_debug = 'Y') THEN
             okc_debug.log('5069: Opp Lines Return Status - ' || l_return_status);
          END IF;
          Raise g_exception_halt_validation;
         End If;
        End If; -- IF g_opp_h_created THEN
        --
        l_count := 0;
      END IF;
      IF (l_debug = 'Y') THEN
         okc_debug.log('5070: Number of lines processed - ' || To_Char(l_count));
      END IF;

      -- Now we need to populate the rel objects table
      If l_rel_id_tbl.count > 0 Then
        l_index := 1; -- point onto rec in l_line_out_tbl
        l_rel_index := 1; -- point onto rec in l_in_crjv_tbl
        For i in l_rel_id_tbl.FIRST..l_rel_id_tbl.LAST -- point onto rec in l_rel_id_tbl
         Loop
          IF (l_debug = 'Y') THEN
             okc_debug.log('5075: Contract Line ID - ' ||l_rel_id_tbl(i));
          END IF;
          If l_rel_lead_line_id_tbl(i) IS NULL Then
            IF (l_debug = 'Y') THEN
               okc_debug.log('5080: Processed Line Status - ' || l_line_out_tbl(l_index).return_status);
            END IF;
            If l_line_out_tbl(l_index).return_status = okc_api.g_ret_sts_success Then
              l_rel_lead_line_id_tbl(i) := l_line_out_tbl(l_index).lead_line_id;
              IF (l_debug = 'Y') THEN
                 okc_debug.log('5081: Opportunity for the line was created successfully');
              END IF;
             else
              IF (l_debug = 'Y') THEN
                 okc_debug.log('5082: Opportunity for the line was not created');
              END IF;
            END IF;
            l_index := l_index + 1;
           ELSE
            IF (l_debug = 'Y') THEN
               okc_debug.log('5085: Opportunity for the line exists');
            END IF;
          END IF;
          If l_rel_lead_line_id_tbl(i) IS NOT NULL Then
            IF (l_debug = 'Y') THEN
               okc_debug.log('5090: Opportunity Line ID - ' ||l_rel_lead_line_id_tbl(i));
            END IF;
            -- prepare the rel obj table for api call
            l_in_crjv_tbl(l_rel_index).object_version_number := 1;
            l_in_crjv_tbl(l_rel_index).cle_id := l_rel_id_tbl(i);
            l_in_crjv_tbl(l_rel_index).chr_id := p_contract_id; -- ??? new
            l_in_crjv_tbl(l_rel_index).jtot_object1_code := 'OKX_OPPLINES';
            l_in_crjv_tbl(l_rel_index).object1_id1 := l_rel_lead_line_id_tbl(i);
            l_in_crjv_tbl(l_rel_index).object1_id2 := '#';
            l_in_crjv_tbl(l_rel_index).rty_code := g_rty_code;
            l_rel_index := l_rel_index + 1;
          End If;
          IF (l_debug = 'Y') THEN
             okc_debug.log(' ------------ ' );
          END IF;
        End Loop;
        If l_in_crjv_tbl.count > 0 Then
          IF (l_debug = 'Y') THEN
             okc_debug.log('5091: Before creating relation objects');
             okc_debug.log('5092: '||l_in_crjv_tbl.count||' relation lines to be created ');
          END IF;
          -- Call the api here
          okc_k_rel_objs_pub.Create_Row(
                    p_api_version   => 1.0, --p_api_version
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_crjv_tbl      => l_in_crjv_tbl,
                    x_crjv_tbl      => l_out_crjv_tbl);
          IF (l_debug = 'Y') THEN
             okc_debug.log('5095: After creating relation objects');
             okc_debug.log('5096: '||l_out_crjv_tbl.count||' relation lines were created ');
          END IF;
          If l_return_status <> okc_api.g_ret_sts_success Then
            IF (l_debug = 'Y') THEN
               okc_debug.log('5099: Return Status from Rel Objects Creation - ' || l_return_status);
            END IF;
            Raise g_exception_halt_validation;
          End If;
        End If;
      End If;  --      If l_rel_id_tbl.count > 0 Then
/*    Else --      If l_count > 0 Then -- 1
      -- this should never happen since this will be trapped by the itm_csr,
      -- line_csr and rel_csr cursor in is_opp_creation_allowed itself.
      IF (l_debug = 'Y') THEN
         okc_debug.log('5100: No lines selected for opp creation');
      END IF;
      l_return_status := okc_api.g_ret_sts_error;
      Raise g_exception_halt_validation;
    End If;*/
    --

    x_msg_data := l_msg_data;
    x_msg_count := l_msg_count;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting okc_opportunity_pvt.create_opp_lines', 2);
       okc_debug.Reset_Indentation;
    END IF;
  Exception
    When g_exception_halt_validation Then
      x_return_status := l_return_status;
      IF (l_debug = 'Y') THEN
         okc_debug.log('5980: Exiting okc_opportunity_pvt.create_opp_lines', 2);
         okc_debug.Reset_Indentation;
      END IF;
    When Others Then
      okc_api.Set_Message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := okc_api.g_ret_sts_unexp_error;
      IF (l_debug = 'Y') THEN
         okc_debug.log('5990: Exiting okc_opportunity_pvt.create_opp_lines', 2);
         okc_debug.Reset_Indentation;
      END IF;
  End Create_Opp_Lines;

  PROCEDURE IS_OPP_CREATION_ALLOWED(p_context       IN  VARCHAR2,
                                    p_contract_id   IN  NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2) IS
    --
    cursor k_csr is
    select chrb.buy_or_sell,
           chrb.template_yn,
           scs.create_opp_yn,
           sts.ste_code
      from okc_k_headers_b chrb,
           okc_subclasses_b scs,
           okc_statuses_b sts
     where chrb.id = p_contract_id
       and scs.code = chrb.scs_code
       and sts.code = chrb.sts_code;
     k_rec k_csr%ROWTYPE;
    --
    cursor cpl_csr (p_rle_code in okc_k_party_roles_b.rle_code%TYPE) is
    select 'x'
      from okc_k_party_roles_b
     where dnz_chr_id = p_contract_id
       and cle_id is null
       and rle_code = p_rle_code;
    --
    cursor ctc_csr (p_object_code in okc_contacts.jtot_object1_code%TYPE) is
    select 'x'
      from okc_contacts
     where dnz_chr_id = p_contract_id
       and jtot_object1_code = p_object_code

       and object1_id1 is not null; --bug 2071104
    --
	-- item should be of usage OKX_MTL_SYSTEM_ITEM
	cursor itm_csr is
	select 'x'
	from okc_k_items itm, jtf_object_usages jou
	where itm.dnz_chr_id = p_contract_id
	and itm.jtot_object1_code = jou.object_code
	and jou.object_user_code = 'OKX_MTL_SYSTEM_ITEM';
/*
    cursor itm_csr is
    select 'x'
      from okc_k_items
     where dnz_chr_id = p_contract_id
       -- and jtot_object1_code = 'OKX_LICPROD';
       and jtot_object1_code = 'OKX_MTL_SYSTEM_ITEMS';
    */
    --
    cursor line_csr is
    select 'x'
      from okc_k_lines_b cle,
           okc_statuses_b sts
--     where cle.dnz_chr_id = p_contract_id
     where cle.chr_id = p_contract_id
       and cle.sts_code = sts.code
       and sts.ste_code in ('ACTIVE', 'SIGNED');
    --
    cursor rel_csr is
    select 'x'
      from okc_k_lines_b cle
--     where cle.dnz_chr_id = p_contract_id
     where cle.chr_id = p_contract_id
       and cle.date_renewed is null
       and not exists (select 'x'
                         from okc_k_rel_objs rel
                        where (rel.cle_id = cle.id
                           or  rel.cle_id = cle.cle_id)
                          and rel.rty_code = g_rty_code);
    --
    cursor rul_csr(p_rule okc_rules_b.rule_information_category%TYPE,
              p_renewal_type okc_rules_b.rule_information1%TYPE) is
    select 'x'
      from okc_rules_b
     where dnz_chr_id = p_contract_id
       and rule_information_category = p_rule
       and rule_information1 = p_renewal_type;
    --
    l_dummy Varchar2(1);
    l_row_found Boolean;
    l_row_notfound Boolean;
    --
  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Is_Opp_Creation_Allowed');
       okc_debug.log('7000: Entering okc_opportunity_pvt.is_opp_creation_allowed', 2);
    END IF;
    x_return_status := okc_api.g_ret_sts_success;
    -- Get contract's details
    Open k_csr;
    Fetch k_csr Into k_rec;
    l_row_notfound := k_csr%NOTFOUND;
    Close k_csr;
    -- In all the checks below, the mesasegs are to be shown only if
    -- this api has been called from Authoring form.
    -- Error out if it is not a valid contract.
    -- ****NOTE**** we are now showing the error messages i.e. putting
    --              them on the stack, regardless of the context.
    --              Please refer to Bug 2074526
    -- ************
    If l_row_notfound Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_INVALID_CHR');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- Contract's category must allow the opp creation
    If Nvl(k_rec.create_opp_yn, '*') <> 'Y' Then
      If p_context = 'AUTHORING' Then   --we need to check context here because we don't want this
                                        --check for RENEW and EXPIRE processes where we may not want to
                                        --create opportunities
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_INVALID_CATEGORY');
      End If;
      Raise g_exception_halt_validation;
    End If;
    -- Templates cannot be created into opportunities
    If k_rec.template_yn = 'Y' Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_TEMPLATE_CHR');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- Opportunites can be created only for Sell contracts
    If Nvl(k_rec.buy_or_sell, '*') <> 'S' Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_NO_SELL_CHR');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- Not allowed if it is already terminated
    If k_rec.ste_code In ('TERMINATED') Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_CHR_TERMINATED');
      ----End If;
      Raise g_exception_halt_validation;
    End If;

    -- In case this api called from expiry of lines, the contract must
    -- be active. For other cases, it should be in entered status.
/* next condition changed 'cause it's not correct. It allows any
    If (p_context in ('AUTHORING', 'RENEW') And
        k_rec.ste_code <> 'ENTERED') Or
       (p_context = 'EXPIRE' And
        k_rec.ste_code Not In ('SIGNED', 'ACTIVE')) Then
*/
    If NOT(( p_context in ('AUTHORING', 'RENEW') And k_rec.ste_code = 'ENTERED')
         OR (p_context = 'EXPIRE' And k_rec.ste_code In ('SIGNED', 'ACTIVE') ))
      Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('7300: Invalid contract status for the context' );
         okc_debug.log('7310: p_context='||p_context||', ste_code='||k_rec.ste_code );
      END IF;
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_INVALID_STATUS');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- Contract must have a Customer assigned to it
    Open cpl_csr('CUSTOMER');
    Fetch cpl_csr into l_dummy;
    l_row_notfound := cpl_csr%NOTFOUND;
    Close cpl_csr;
    If l_row_notfound Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_NO_CUSTOMER');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- Also make sure there is a Salesrep
    Open ctc_csr('OKX_SALEPERS');
    Fetch ctc_csr Into l_dummy;
    l_row_notfound := ctc_csr%NOTFOUND;
    Close ctc_csr;
    If l_row_notfound Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_NO_SALESREP');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- There must be at least one inventory line item
    Open itm_csr;
    Fetch itm_csr Into l_dummy;
    l_row_notfound := itm_csr%NOTFOUND;
    Close itm_csr;
    If l_row_notfound Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_NO_INV_ITEM');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- If opp creation is done from auth or renewal, it should pick
    -- up only those lines that have not already been renewed. In
    -- case of expiry, if the lines are not already renewed, they
    -- are a candidate for opp creation even though an opp was
    -- created for them in the contract's entered status. However
    -- the lines that were created into an opp by an earlier expiry
    -- process should not be picked up again by the next expiry process.
    If p_context in ('AUTHORING', 'RENEW') Then
      g_rty_code := 'OPPREPSCONTRACT';
    Else
      g_rty_code := 'OPPEXPSCONTRACT';
      -- For expiry process, make sure there is one Active/Signed line
      Open line_csr;
      Fetch line_csr Into l_dummy;
      l_row_notfound := line_csr%NOTFOUND;
      Close line_csr;
      If l_row_notfound Then
        ----If p_context = 'AUTHORING' Then
          okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_NO_ACTIVE_LINES');
        ----End If;
        Raise g_exception_halt_validation;
      End If;
    End If;
    --
    Open rel_csr;
    Fetch rel_csr Into l_dummy;
    l_row_notfound := rel_csr%NOTFOUND;
    Close rel_csr;
    If l_row_notfound Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_NO_LINES');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    -- If the contract is evergreen, no opp can be created
    Open rul_csr('REN', 'EVN');
    Fetch rul_csr Into l_dummy;
    l_row_found := rul_csr%FOUND;
    Close rul_csr;
    If l_row_found Then
      ----If p_context = 'AUTHORING' Then
        okc_api.Set_Message(G_APP_NAME, 'OKC_OPP_EVERGREEN_CONTRACT');
      ----End If;
      Raise g_exception_halt_validation;
    End If;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('7500: Opportunity Creation is allowed');
       okc_debug.log('8000: Exiting okc_opportunity_pvt.is_opp_creation_allowed', 2);
       okc_debug.Reset_Indentation;
    END IF;
  Exception
    When g_exception_halt_validation Then
      x_return_status := okc_api.g_ret_sts_error;
      IF (l_debug = 'Y') THEN
         okc_debug.log('7600: Opportunity Creation is not allowed');
         okc_debug.log('7980: Exiting okc_opportunity_pvt.is_opp_creation_allowed', 2);
         okc_debug.Reset_Indentation;
      END IF;
    When Others Then
      okc_api.Set_Message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := okc_api.g_ret_sts_unexp_error;
      IF (l_debug = 'Y') THEN
         okc_debug.log('7990: Exiting okc_opportunity_pvt.is_opp_creation_allowed', 2);
         okc_debug.Reset_Indentation;
      END IF;
  End Is_Opp_Creation_Allowed;

  PROCEDURE GET_OPP_DEFAULTS(p_context           IN  VARCHAR2,
                             p_contract_id       IN  NUMBER,
                             x_win_probability   IN  OUT NOCOPY NUMBER,
                             x_closing_date_days IN  OUT NOCOPY NUMBER,
                             x_return_status     OUT NOCOPY VARCHAR2) IS
    cursor c1(p_rule_information_category IN
              okc_rules_b.rule_information_category%TYPE) is
    select rule_information1,
           rule_information2,
           rule_information3,
           rule_information4,
           rule_information5
      from okc_rules_b
     where dnz_chr_id = p_contract_id
       and rule_information_category = p_rule_information_category;
    c1_rec c1%ROWTYPE;
    l_row_found Boolean;
    --
  Begin
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('Get_Opp_Defaults');
       okc_debug.log('9000: Entering okc_opportunity_pvt.get_opp_defaults', 2);
       okc_debug.log('9010: Calling Mode - ' || p_context);
    END IF;
    x_return_status := okc_api.g_ret_sts_success;
    --
    If p_context = 'RENEW' Then
      Open c1('REN');
      Fetch c1 Into c1_rec;
      l_row_found := c1%FOUND;
      Close c1;
      If l_row_found Then
        x_win_probability := c1_rec.rule_information4;
        x_closing_date_days := c1_rec.rule_information5;
      End If;
    Elsif p_context In ('AUTHORING', 'EXPIRE') Then
      Open c1('RVE');
      Fetch c1 Into c1_rec;
      l_row_found := c1%FOUND;
      Close c1;
      If l_row_found Then
        x_win_probability := c1_rec.rule_information1;
        x_closing_date_days := c1_rec.rule_information2;
      End If;
    End If;
    --
    If x_win_probability Is Null Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('9050: Fetching win_probability from profile');
      END IF;
      x_win_probability := Fnd_Profile.Value('AS_OPP_WIN_PROBABILITY');
    End If;
    If x_closing_date_days Is Null Then
      IF (l_debug = 'Y') THEN
         okc_debug.log('9060: Fetching closing_date_days from profile');
      END IF;
      x_closing_date_days := Fnd_Profile.Value('AS_OPP_CLOSING_DATE_DAYS');
    End If;
    --
    IF (l_debug = 'Y') THEN
       okc_debug.log('9070: x_win_probability - ' || x_win_probability);
       okc_debug.log('9080: x_closing_date_days - ' || x_closing_date_days);
       okc_debug.log('10000: Exiting okc_opportunity_pvt.get_opp_defaults', 2);
       okc_debug.Reset_Indentation;
    END IF;
  Exception
    When Others Then
      okc_api.Set_Message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := okc_api.g_ret_sts_unexp_error;
      IF (l_debug = 'Y') THEN
         okc_debug.log('9990: Exiting okc_opportunity_pvt.get_opp_defaults', 2);
         okc_debug.Reset_Indentation;
      END IF;
  End Get_Opp_Defaults;
END OKC_OPPORTUNITY_PVT;

/
