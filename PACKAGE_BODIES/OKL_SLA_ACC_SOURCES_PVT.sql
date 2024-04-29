--------------------------------------------------------
--  DDL for Package Body OKL_SLA_ACC_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SLA_ACC_SOURCES_PVT" AS
/*$Header: OKLRSLAB.pls 120.37.12010000.5 2008/09/02 06:04:34 racheruv ship $*/

  -- Package level variables
  G_MODULE                  CONSTANT  VARCHAR2(255):= 'LEASE.ACCOUNTING.SOURCES.OKL_SLA_ACC_SOURCES_PVT';
  G_DEBUG_ENABLED           CONSTANT  VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON             BOOLEAN;
  G_REPRESENTATION_TYPE               VARCHAR2(20);
  --------------------------------------------------------------------------------
  -- Common Cursor definitions.
  --------------------------------------------------------------------------------
  -- Cursor to fetch the Ledger Language
  CURSOR c_ledger_lang_csr(p_ledger_id   NUMBER)
  IS
    SELECT  DISTINCT NVL(led.sla_description_language, USERENV('LANG')) language_code
      FROM  gl_ledgers              led
           ,xla_ledger_options      lopt
           ,gl_ledger_relationships led_rel
    WHERE  led.ledger_category_code in ('PRIMARY', 'SECONDARY')
      AND  led_rel.target_ledger_category_code in ('PRIMARY', 'SECONDARY')
      AND  led.ledger_id = lopt.ledger_id
      AND  lopt.enabled_flag = 'Y'
      AND  lopt.application_id = 540
      AND  led.ledger_id = led_rel.target_ledger_id
      AND  led_rel.primary_ledger_id = p_ledger_id;

  CURSOR c_org_name_csr( p_org_id NUMBER, p_ledger_lang VARCHAR2 )
  IS
    SELECT  htl.NAME org_name
      FROM  HR_ALL_ORGANIZATION_UNITS_TL htl
     WHERE htl.organization_id = p_org_id
       AND htl.LANGUAGE = p_ledger_lang;
  CURSOR c_org_name_code_csr( p_org_id NUMBER )
  IS
    SELECT  ht.NAME org_name
      FROM  hr_all_organization_units ht
     WHERE ht.organization_id = p_org_id;

  -- Cursor to fetch basic Contract Attributes
  CURSOR  c_khr_attributes_csr  (l_khr_id NUMBER)
  IS
    SELECT   khr.khr_id                              khr_khr_id
            ,chr.cust_acct_id                        cust_acct_id
            ,chr.contract_number                     contract_number
            ,chr.currency_code                       currency_code
            ,chr.START_DATE                          start_date
            ,chr.bill_to_site_use_id                 bill_to_site_use_id
            ,chr.orig_system_reference1              orig_system_reference1
            ,khr.assignable_yn                       assignable_yn
            ,chr.authoring_org_id                    authoring_org_id
            ,khr.converted_account_yn                converted_account_yn
            ,khr.generate_accrual_override_yn        generate_accrual_override_yn
            ,chr.cust_po_number                      cust_po_number
            ,chr.sts_code                            sts_code
            ,hr_org.NAME                             hr_org_name
            ,khr.pdt_id                              pdt_id
            ,chr.scs_code                            scs_code
      FROM   okc_k_headers_all_b         chr
            ,okl_k_headers               khr
            ,hr_all_organization_units   hr_org
     WHERE  khr.id =  l_khr_id
       AND  chr.id = khr.id
       AND  hr_org.organization_id = chr.authoring_org_id;

  -- Use this cursor to fetch the Lesses DFF Information.
  CURSOR c_kpl_attributes_csr (l_khr_id NUMBER)
  IS
    SELECT   kpl.attribute_category
            ,kpl.attribute1
            ,kpl.attribute2
            ,kpl.attribute3
            ,kpl.attribute4
            ,kpl.attribute5
            ,kpl.attribute6
            ,kpl.attribute7
            ,kpl.attribute8
            ,kpl.attribute9
            ,kpl.attribute10
            ,kpl.attribute11
            ,kpl.attribute12
            ,kpl.attribute13
            ,kpl.attribute14
            ,kpl.attribute15
      FROM   okl_k_party_roles    kpl
            ,okc_k_party_roles_b  cplb
     WHERE  cplb.chr_id =  l_khr_id
       AND  cplb.dnz_chr_id = cplb.chr_id
       AND  kpl.id = cplb.id
       AND  cplb.rle_code = 'LESSEE';

  -- Use this cursor to fetch the RRB and ICM values of a particular product
  CURSOR c_rev_rec_int_calc_methods_csr (l_pdt_id NUMBER)
  IS
    SELECT  rrb_qve.value  rev_rec_method_code
           ,icm_qve.value int_calc_method_code
      FROM  okl_pdt_qualitys  icm_pqy
           ,okl_pdt_pqy_vals  icm_pqv
           ,okl_pqy_values    icm_qve
           ,okl_pdt_qualitys  rrb_pqy
           ,okl_pdt_pqy_vals  rrb_pqv
           ,okl_pqy_values    rrb_qve
     WHERE  icm_pqv.pdt_id = l_pdt_id
       AND  icm_pqv.qve_id = icm_qve.id
       AND  icm_qve.pqy_id = icm_pqy.id
       AND  icm_pqy.name   = 'INTEREST_CALCULATION_BASIS'
       AND  rrb_pqv.pdt_id = l_pdt_id
       AND  rrb_pqv.qve_id = rrb_qve.id
       AND  rrb_qve.pqy_id = rrb_pqy.id
       AND  rrb_pqy.name   = 'REVENUE_RECOGNITION_METHOD';

  -- Cursor to fetch the Investor Agreement Details provided the
  --  Contract ID and RENT/RESIDUAL stream type
  CURSOR c_investor_agreement_main_csr(p_khr_id NUMBER, p_sty_type VARCHAR2)
  IS
    SELECT
       ia_chr.id               ia_chr_id
      ,ia_chr.contract_number  ia_contract_number
      ,ia_chr.START_DATE       ia_start_date
      ,ia_pdt.NAME             ia_product_name
      FROM  okl_pool_contents   ia_pool_c
           ,okc_k_headers_all_b ia_chr
           ,okl_k_headers       ia_khr
           ,okl_products        ia_pdt
           ,okl_pools_all       ia_pool
     WHERE  ia_pool_c.sty_code  =  p_sty_type
       AND  ia_pool_c.pol_id = ia_pool.id
       AND  ia_pool.khr_id = ia_chr.id
       AND  ia_chr.scs_code  = G_INVESTOR
       AND  ia_chr.id = ia_khr.id
       AND  ia_pdt.id = ia_khr.pdt_id
       AND  ia_chr.id = ia_khr.id
       AND  ia_pool_c.khr_id = p_khr_id
       AND  ia_pool_c.status_code <> Okl_Pool_Pvt.G_POC_STS_PENDING ; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)
  -- Cursor to fetch IA Accounting Code setup in Terms and Conditions..
  CURSOR c_investor_agree_acc_code_csr (l_rent_ia_chr_id NUMBER, l_res_ia_chr_id NUMBER)
  IS
    SELECT
        DECODE(ia_rule.dnz_chr_id,l_rent_ia_chr_id, ia_rule.rule_information1,NULL) rent_ia_accounting_code
       ,DECODE(ia_rule.dnz_chr_id,l_res_ia_chr_id,ia_rule.rule_information1,NULL)   res_ia_accounting_code
      FROM  okc_rules_b        ia_rule
           ,okc_rule_groups_b  ia_rule_groups
     WHERE  ia_rule.rgp_id                    = ia_rule_groups.id
       AND ia_rule.dnz_chr_id  IN (l_rent_ia_chr_id, l_res_ia_chr_id)
       AND ia_rule_groups.rgd_code           = 'LASEAC'
       AND ia_rule.rule_information_category = 'LASEAC';

  -- Cursor to fetch the Customer Name and Account Number details
  -- Modifed by zrehman Bug#6707320 for Party Merge impact on transaction sources tables
  CURSOR c_cust_name_account_csr (l_khr_id NUMBER,l_cust_acct_id NUMBER )
  IS
    SELECT   cust_party.party_name
            ,cust_party.party_id
            ,cust_accounts.account_number
    FROM   okc_k_party_roles_b  cust_party_roles
            ,hz_parties           cust_party
            ,hz_cust_accounts     cust_accounts
     WHERE  cust_party.party_type in ( 'PERSON','ORGANIZATION')
       AND  cust_party.party_id = cust_party_roles.object1_id1
       AND  '#' = cust_party_roles.object1_id2
       AND  cust_party_roles.jtot_object1_code = 'OKX_PARTY'
       AND  cust_party_roles.rle_code = 'LESSEE'
       AND  cust_party_roles.chr_id = l_khr_id
       AND  cust_party_roles.dnz_chr_id = l_khr_id
       AND  cust_accounts.cust_account_id = l_cust_acct_id;

  -- Cursor to fetch the Active Insurance policy details
  CURSOR c_insurance_csr (l_khr_id NUMBER)
  IS
    SELECT   ins.policy_number
            ,ins.ipe_code
      FROM   okl_ins_policies_all_b ins
     WHERE  ins.khr_id   = l_khr_id
       AND  ins.ipy_type = 'LEASE_POLICY'
       AND  ins.quote_yn = 'N'
       AND  ins.iss_code = 'ACTIVE';

  -- Cursor to fetch the Sales Representative Name using the AGS PK ...
  CURSOR c_sales_rep_acc_sources_csr (p_jtf_sales_rep_pk NUMBER)
  IS
    SELECT  rep.name
      FROM  jtf_rs_salesreps_mo_v rep
     WHERE  salesrep_id = p_jtf_sales_rep_pk;

  -- Cursor to fetch the Sales Representative Details
  CURSOR c_sales_rep_csr (l_khr_id NUMBER)
  IS
    SELECT   rep.name
      FROM   okc_contacts    contact
            ,okx_salesreps_v rep
     WHERE  contact.DNZ_CHR_ID = l_khr_id
       AND  rep.id1 = contact.object1_id1
       AND  rep.id2 = contact.object1_id2;

  -- Cursor to fetch the Credit Line and Master Lease Details
  CURSOR c_creditline_master_lease_csr (l_khr_id NUMBER)
  IS
    SELECT    chr_cr_master.scs_code     CHR_TYPE
             ,decode(chr_cr_master.scs_code,'CREDITLINE_CONTRACT'
                   ,chr_cr_master.contract_number, NULL)  credit_line_number
            ,decode(chr_cr_master.scs_code,'MASTER_LEASE'
                   ,chr_cr_master.contract_number, NULL)  master_lease_number
            ,decode(chr_cr_master.scs_code,'MASTER_LEASE'
                   ,chr_cr_master.id, TO_NUMBER(NULL))    master_lease_id
      FROM   okc_k_headers_all_b chr_cr_master
            ,okc_governances     governances
     WHERE  governances.dnz_chr_id = l_khr_id
       AND  governances.chr_id_referred = chr_cr_master.ID
       AND  chr_cr_master.scs_code in  ('CREDITLINE_CONTRACT', 'MASTER_LEASE');

  -- Sometimes credit line may be associated with Master Lease instead with a contract
  CURSOR c_creditline_sub_csr (l_mla_chr_id NUMBER)
  IS
    SELECT   crline_sub_chr.contract_number
      FROM  okc_k_headers_all_b   crline_sub_chr
           ,okc_governances       crline_gov
     WHERE  crline_gov.dnz_chr_id = l_mla_chr_id
       AND  crline_gov.chr_id_referred = crline_sub_chr.id
       AND  crline_sub_chr.scs_code = 'CREDITLINE_CONTRACT';

  -- Cursor to fetch the Vendor Program Agreement Number
  CURSOR c_vendor_program_number_csr (p_khr_id NUMBER)
  IS
    SELECT   vp_chr.contract_number
      FROM   okc_k_headers_all_b   vp_chr
            ,okl_k_headers         khr
     WHERE  vp_chr.id = khr.khr_id
       AND  vp_chr.scs_code = 'PROGRAM'
       AND  khr.id = p_khr_id;

  -- Use this cursor to fetch the meaning of the of the Contract Status
  CURSOR c_get_status_meaning_csr( p_sts_code VARCHAR2, p_led_lang  VARCHAR2)
  IS
    SELECT   status.meaning       status_meaning
      FROM   okc_statuses_tl      status
     WHERE  status.code     = p_sts_code
       AND  status.language = p_led_lang;

  -- Cursor to fetch the Transaction type in the ledger language.
  CURSOR  c_trx_type_name_csr( p_try_id NUMBER, p_led_lang VARCHAR2 )
  IS
    SELECT  try_tl.NAME          transaction_type_name
           ,try_b.trx_type_class trx_type_class_code
      FROM  okl_trx_types_tl try_tl
           ,okl_trx_types_b  try_b
     WHERE  try_tl.id       = p_try_id
       AND  TRY_B.ID = try_tl.id
       AND  try_tl.language = p_led_lang;

  -- Cursor to fetch the Contract Id from the OKL_TXL_ASSETS table.
  CURSOR c_tas_khr_id_csr( p_source_id  okl_trx_assets.id%TYPE )
  IS
    SELECT DISTINCT tal.dnz_khr_id  khr_id
             ,kle_id                kle_id
      FROM   okl_trx_assets    tas
            ,okl_txl_assets_b  tal
     WHERE  tal.tas_id = tas.id
       AND  tas.id = p_source_id;

  -- Cursor to fetch the Contract Id from the OKL_TXL_ASSETS table.
  CURSOR c_tal_khr_id_csr( p_source_id  okl_txl_assets_b.id%TYPE )
  IS
    SELECT    tal.dnz_khr_id  khr_id
             ,tal.kle_id      kle_id
      FROM   okl_txl_assets_b  tal
     WHERE  tal.id = p_source_id;

  -- Cursor to fetch the Contract Line Information
  CURSOR c_k_lines_csr (p_kle_id NUMBER)
  IS
    SELECT   cleb.line_number
            ,kle.fee_type
            ,DECODE(cleb.lse_id,
              33,    clet.name,  -- For FREE_FORM1 Asset
              NULL)  asset_number
            ,kle.date_delivery_expected
            ,decode(cleb.lse_id,
              33, 'FREE_FORM1',  -- Asset
              1,  'SERVICE',     -- Service
              48, 'SERVICE',
              52, 'FEE',         -- Fee
              NULL)  contract_line_type
      FROM   okc_k_lines_b  cleb
            ,okl_k_lines  kle
            ,okc_k_lines_tl clet
     WHERE  cleb.id = p_kle_id
       AND  kle.id  = cleb.id
       AND  cleb.id = clet.id
       AND  clet.language = USERENV('LANG');


  -- Cursor to fetch the vendor details along with the Line Number
  CURSOR c_vendor_name_csr (p_kle_id NUMBER, p_khr_id NUMBER)
  IS
    SELECT   pov.vendor_id
            ,pov.vendor_name
      FROM   okc_k_lines_b       cleb_vendor
            ,po_vendors          pov
            ,okc_k_party_roles_b pty
     WHERE  cleb_vendor.cle_id     = p_kle_id
       AND  cleb_vendor.dnz_chr_id = p_khr_id
       AND  cleb_vendor.lse_id     = 34
       AND  pty.cle_id             = cleb_vendor.id
       AND  pty.rle_code           = 'OKL_VENDOR'
       AND  pty.dnz_chr_id         = p_khr_id
       AND  pov.vendor_id          = pty.object1_id1;

  -- Cursor to fetch the Asset Installed Site
  CURSOR  c_installed_site_csr (p_kle_id NUMBER, p_khr_id NUMBER)
  IS
    SELECT hl.location_id installed_site_id
      FROM hz_locations hl,
          hz_party_sites hps,
          csi_item_instances csi,
          okc_k_items cim_ib,
          okc_k_lines_b cle_ib,
          okc_k_lines_b cle_inst,
          okc_k_lines_b cle_fin
    WHERE cle_fin.cle_id is null
      AND cle_fin.chr_id = cle_fin.dnz_chr_id
      AND cle_fin.lse_id = 33
      AND cle_inst.cle_id = cle_fin.id
      AND cle_inst.dnz_chr_id = cle_fin.dnz_chr_id
      AND cle_inst.lse_id = 43
      AND cle_ib.cle_id = cle_inst.id
      AND cle_ib.dnz_chr_id = cle_inst.dnz_chr_id
      AND cle_ib.lse_id = 45
      AND cim_ib.cle_id = cle_ib.id
      AND cim_ib.dnz_chr_id = cle_ib.dnz_chr_id
      AND cim_ib.object1_id1 = csi.instance_id
      AND cim_ib.object1_id2 = '#'
      AND cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
      AND csi.install_location_id = hps.party_site_id
      AND csi.install_location_type_code = 'HZ_PARTY_SITES'
      AND hps.location_id = hl.location_id
      AND cle_fin.dnz_chr_id = p_khr_id
      AND cle_fin.id = p_kle_id;

  -- Cursor to fetch the Inventory Item Name
  CURSOR c_inventory_item_name_csr (p_inventory_item_id_pk1 VARCHAR2
                                   ,p_inventory_org_id_pk2  VARCHAR2
                                   ,p_ledger_language       VARCHAR2)
  IS
    SELECT   msitl.description      description
            ,msitb.description      b_description
      FROM   mtl_system_items_tl msitl
            ,mtl_system_items_b  msitb
     WHERE   msitl.inventory_item_id = p_inventory_item_id_pk1
       AND   msitl.organization_id   = p_inventory_org_id_pk2
       AND   msitl.inventory_item_id = msitb.inventory_item_id
       AND   msitl.organization_id = msitb.organization_id
       AND   msitl.LANGUAGE          = p_ledger_language;

  CURSOR c_inventory_org_id_csr( p_khr_id NUMBER )
  IS
    SELECT  khr.inv_organization_id    inv_organization_id
           ,hrb.NAME                   hrb_name
      FROM  okc_k_headers_all_b        khr
           ,hr_all_organization_units  hrb
     WHERE  khr.id = p_khr_id
       AND  hrb.organization_id = khr.inv_organization_id;

  CURSOR c_khr_to_ledger_id_csr( p_khr_id NUMBER )
  IS
    SELECT  set_of_books_id       ledger_id
      FROM  okl_sys_acct_opts_all sysop
           ,okc_k_headers_all_b   cntrct
     WHERE  cntrct.id = p_khr_id
       AND  cntrct.authoring_org_id = sysop.org_id;

  -- for khr category and attributes
  CURSOR c_khr_category_attributes_csr (l_khr_id NUMBER)
  IS
    SELECT   khr.attribute_category
            ,khr.attribute1
            ,khr.attribute2
            ,khr.attribute3
            ,khr.attribute4
            ,khr.attribute5
            ,khr.attribute6
            ,khr.attribute7
            ,khr.attribute8
            ,khr.attribute9
            ,khr.attribute10
            ,khr.attribute11
            ,khr.attribute12
            ,khr.attribute13
            ,khr.attribute14
            ,khr.attribute15
      FROM   okl_k_headers khr
     WHERE   khr.id =  l_khr_id;

  -- for book classification code and tax owner code
  CURSOR c_pdt_bc_to_icm_rrb_csr(p_pdt_id NUMBER)
  IS
    SELECT  pdt.name                     pdt_name
           ,aes.name                     aes_name
           ,gts.name                     sgt_name
           ,gts.deal_type                deal_type
           ,gts.tax_owner                tax_owner
           ,gts.interest_calc_meth_code  interest_calc_meth_code
           ,gts.revenue_recog_meth_code  revenue_recog_meth_code
      FROM  okl_products                 pdt
           ,okl_ae_tmpt_sets_all         aes
           ,okl_st_gen_tmpt_sets_all     gts
     WHERE  pdt.aes_id = aes.id
       AND  aes.gts_id = gts.id
       AND  pdt.id = p_pdt_id;

  --for line attribute category and line attributes
  CURSOR c_line_attributes_csr (l_kle_id NUMBER)
  IS
    SELECT   kle.attribute_category
            ,kle.attribute1
            ,kle.attribute2
            ,kle.attribute3
            ,kle.attribute4
            ,kle.attribute5
            ,kle.attribute6
            ,kle.attribute7
            ,kle.attribute8
            ,kle.attribute9
            ,kle.attribute10
            ,kle.attribute11
            ,kle.attribute12
            ,kle.attribute13
            ,kle.attribute14
            ,kle.attribute15
      FROM   okl_k_lines kle
     WHERE  kle.id =  l_kle_id;

  -- Cursor to fetch the Asset Manufacturer Name, Model Number and Category Name
  CURSOR c_manufacture_model_csr (p_kle_id NUMBER, p_khr_id NUMBER)
  IS
    SELECT   fac.category_id             category_id
              ,fab.manufacturer_name     manufacturer_name
              ,fab.model_number          model_number
              ,fac.SEGMENT1 || '-' || fac.SEGMENT2 asset_category_name
        FROM   okc_k_lines_b        cleb_fa
              ,fa_additions_b       fab
              ,okc_k_items          cim
              ,fa_categories    fac
       WHERE  cleb_fa.cle_id = p_kle_id
         AND  cleb_fa.dnz_chr_id = p_khr_id
         AND  cleb_fa.lse_id = 42
         AND  cim.cle_id    = cleb_fa.id
         AND  cim.dnz_chr_id = p_khr_id
         AND  cim.jtot_object1_code = 'OKX_ASSET'
         AND  fab.asset_id =  cim.object1_id1
         AND  fac.category_id = fab.asset_category_id;

  -- Cursor to fetch the Asset Location Id
  CURSOR c_location_id_csr (p_kle_id NUMBER, p_khr_id NUMBER )
  IS
    SELECT   fdh.location_id
      FROM   okc_k_lines_b           cleb_loc
            ,fa_distribution_history fdh
            ,okc_k_items             cim
     WHERE  cleb_loc.cle_id = p_kle_id
       AND  cleb_loc.dnz_chr_id = p_khr_id
       AND  cleb_loc.lse_id = 42
       AND  cim.cle_id    = cleb_loc.id
       AND  cim.dnz_chr_id = p_khr_id
       AND  fdh.asset_id =  cim.object1_id1
       AND  cim.jtot_object1_code = 'OKX_ASSET'
       AND  fdh.transaction_header_id_out IS NULL;

  -- Cursor to fetch the Asset Location Name
  CURSOR c_asset_location_name_csr (p_fdh_location_id NUMBER)
  IS
    SELECT  location_id                location_id
           ,loc.concatenated_segments  asset_location_name
      FROM   fa_locations_kfv         loc
     WHERE  loc.location_id  = p_fdh_location_id;

  -- Cursor to fetch the transaction number
  -- source table : okl_txl_assets_b
  CURSOR c_txl_trans_number_csr (p_source_id NUMBER)
  IS
    SELECT   tas.trans_number trans_number
            ,txl.id           txl_id
            ,tas.id           tas_id
      FROM   okl_trx_assets   tas
            ,okl_txl_assets_b txl
     WHERE   tas.id = txl.tas_id and
             txl.id = p_source_id;

  -- Cursor to fetch the transaction number
  -- source table : okl_txd_assets_b
  CURSOR c_txd_trans_number_csr (p_source_id NUMBER)
  IS
    SELECT   tas.trans_number trans_number
            ,txl.id           txl_id
            ,tas.id           tas_id
      FROM   okl_trx_assets   tas
            ,okl_txl_assets_b txl
            ,okl_txd_assets_b txd
     WHERE   tas.id = txl.tas_id and
             txl.id = txd.tal_id and
             txd.id = p_source_id;

  -- Cursor to fetch the Transaction Line Description
  CURSOR get_txl_line_desc_csr( p_txl_id NUMBER, p_ledger_lang VARCHAR2 )
  IS
    SELECT   txl_tl.description   trans_line_description
      FROM   okl_txl_assets_tl    txl_tl
     WHERE   txl_tl.id       = p_txl_id
       AND   txl_tl.language = p_ledger_lang;

  -- Cursor to fetch the Asset Year Manufactured
  CURSOR c_asset_year_manufactured_csr (p_kle_id NUMBER, p_khr_id NUMBER)
  IS
    SELECT kle.Year_built year_of_manufacture
      FROM okl_k_lines kle,
           okc_k_lines_b cleb_year
     WHERE kle.id = cleb_year.id
       AND cleb_year.cle_id = p_kle_id
       AND cleb_year.dnz_chr_id = p_khr_id
       AND cleb_year.lse_id = 42;

  -- Cursor to fetch the Aging Bucket Name
  CURSOR c_aging_bucket_name_csr (p_bkt_id NUMBER)
  IS
    SELECT ARB.BUCKET_NAME BUCKET_NAME
      FROM  OKL_BUCKETS OBKT
           ,AR_AGING_BUCKET_LINES_B ARBL
           ,AR_AGING_BUCKETS ARB
     WHERE OBKT.IBC_ID          = ARBL.AGING_BUCKET_LINE_ID
       AND ARBL.AGING_BUCKET_ID = ARB.AGING_BUCKET_ID
       AND OBKT.ID = p_bkt_id;

  -- Cursor to fetch the Receivables Transaction Type using AGS ID
  CURSOR  c_cust_trx_type_csr( p_trx_id NUMBER)
  IS
    SELECT   ctt.name            trx_name
      FROM   ra_cust_trx_types   ctt
     WHERE  ctt.cust_trx_type_id = p_trx_id;

  -- Cursor to fetch termination quote attr
  CURSOR c_termination_qte_csr (l_qte_id NUMBER)
  IS
    SELECT   date_effective_from
            ,quote_number
            ,qtp_code
      FROM  okl_trx_quotes_all_b
     WHERE  id = l_qte_id;

  -- Cursor to fetch contingency code and stream type name
  --  applicable only for AR.
  CURSOR c_contingency_strm_b_csr (p_sty_id NUMBER )
  IS
    SELECT    styb.code                 stream_type_code
             ,styb.stream_type_purpose  stream_type_purpose
			 -- changed to contingency_name from styb.contingency
			 -- for bug fix 6744584. racheruv
             ,adr.contingency_name      contingency_code
      FROM    okl_strm_type_b  styb, ar_deferral_reasons adr
     WHERE    styb.id = p_sty_id
	   AND    styb.contingency_id = adr.contingency_id(+);

  CURSOR c_strm_name_tl_csr (p_sty_id NUMBER, p_lang VARCHAR2)
  IS
    SELECT    stytl.NAME             stream_type_name
      FROM    okl_strm_type_tl stytl
     WHERE    stytl.id = p_sty_id
       AND    stytl.language = p_lang;

  -- Cursor to fetch Investor Related Information
  CURSOR   c_inv_agrmnt_details_csr( p_inv_agrmnt_id   NUMBER)
  IS
    SELECT   invc.contract_number                inv_agrmnt_number
            ,DECODE(invk.securitization_type,
              'SALE',          'SECURITIZATION',
              'LOAN',          'SYNDICATION',
              'SECURITIZATION','SECURITIZATION',
              'SYNDICATION',   'SYNDICATION')    inv_agrmnt_synd_code
            ,pol.pool_number                     inv_agrmnt_pool_number
            ,invc.currency_code                  inv_agrmnt_currency_code
            ,invc.START_DATE                     inv_agrmnt_effective_from
            ,invc.sts_code                       inv_agrmnt_status_code
      FROM   okc_k_headers_all_b  invc
            ,okl_k_headers        invk
            ,okl_pools_all        pol
     WHERE  invc.id = invk.id
       AND  invc.scs_code = G_INVESTOR
       AND  pol.khr_id = invk.id
       AND  invc.id = p_inv_agrmnt_id;

  -- Cursor to fetch the Accounting Distributions
  --  Note: This cursor is used in AR and AP Populate Sources alone
  CURSOR c_account_dist_csr (
           p_source_id     NUMBER
          ,p_source_table  VARCHAR2)
  IS
    SELECT   DISTINCT template_id
      FROM   okl_trns_acc_dstrs_all dist
     WHERE  source_table = p_source_table
       AND  source_id = p_source_id;

  -- Cursor to fetch the template information
  --  Note: This cursor is used in AR and AP Populate Sources alone
  CURSOR c_ae_templates_csr (p_template_id NUMBER)
  IS
    SELECT   name
            ,memo_yn
      FROM   okl_ae_templates_all
     WHERE id = p_template_id;

  -- This cursor is used to fetch the Subsidy Details like
  --  Subsidy Name and Subsidy Party Name. Used only by AR Populate Sources
  -- Modified by zrehman Bug#6707320 for Party Merge Impact on Transaction Sources tables
  CURSOR get_subsidy_details_csr( p_kle_id NUMBER)
  IS
    SELECT  sub.NAME                subsidy_name
           ,party.vendor_name       subsidy_party_name
	   ,party.vendor_id         subsidy_vendor_id
      FROM  okl_subsidies_b sub
           ,okl_k_lines subsidy_line
           ,okc_k_party_roles_b role
           ,po_vendors party
     WHERE  sub.id = subsidy_line.subsidy_id
       AND  role.cle_id = subsidy_line.id
       AND  role.object1_id1 = party.vendor_id
       AND  subsidy_line.id = p_kle_id;

  -- Cursor to fetch the product name
  CURSOR c_get_pdt_name_csr( p_pdt_id NUMBER)
  IS
    SELECT   pdt.name  pdt_name
      FROM   okl_products pdt
     WHERE   pdt.id = p_pdt_id;

  -- Cursor to fetch the Line Style of the given Line ID
  -- Used by FA Populate sources for validation Purposes
  -- Used by AR Populate sources for getting parent_line_id
  CURSOR get_line_style_csr(p_kle_id IN NUMBER)
  IS
    SELECT  lse.lty_code       line_style
           ,cle.cle_id         parent_line_id
      FROM  okc_k_lines_b      cle
           ,okc_line_styles_b  lse
     WHERE  cle.lse_id = lse.id
      AND   cle.id = p_kle_id;

  -- Cursor to fetch the Transaction Line Description for AR TXD
  CURSOR c_tld_line_description (p_tld_tl_id NUMBER, p_lang VARCHAR2)
  IS
    SELECT    tldl.id                tldl_id
             ,tldl.description       trans_line_description
     FROM     okl_txd_ar_ln_dtls_tl  tldl
    WHERE     tldl.id = p_tld_tl_id
      AND     tldl.language = p_lang;

  -- Cursor to fetch the AP Invoice Invoice Transaction Line Description
  CURSOR c_txl_ap_inv_desc_csr (p_tpld_id NUMBER, p_lang  VARCHAR2)
    IS
      SELECT    tpld.id                   tpld_id
               ,tpld.description          trans_line_description
       FROM     okl_txl_ap_inv_lns_tl     tpld
      WHERE     tpld.id = p_tpld_id
        AND     tpld.LANGUAGE = p_lang;

  -- Cursors to fetch the Termination Quote Related Sources for FA Transactions
  -- For Offlease Amortization Transaction
  CURSOR c_tq_dtls_offlease( p_kle_id NUMBER)
  IS
    SELECT   qte.quote_number       quote_number
            ,qte.date_accepted      quote_accepted_date
            ,qte.qtp_code           quote_type
      FROM  okl_trx_quotes_all_b  qte
           ,okl_txl_quote_lines_b tql
     WHERE  qte.id = tql.qte_id
       AND  qte.qst_code in ('ACCEPTED', 'COMPLETE')
       AND  qte.accepted_yn = 'Y'
       AND  tql.qlt_code = 'AMCFIA'
       AND  tql.kle_id = p_kle_id;

  -- For Split Asset Transaction
  CURSOR c_tq_dtls_split_ast( p_kle_id              NUMBER
                             ,p_split_asset_trx_id  NUMBER )
  IS
    SELECT   qte.quote_number       quote_number
            ,qte.date_accepted      quote_accepted_date
            ,qte.qtp_code           quote_type
      FROM   okl_trx_quotes_all_b   qte
            ,okl_txl_quote_lines_b  tql
     WHERE   qte.id = tql.qte_id
       AND   qte.qst_code in ('ACCEPTED', 'COMPLETE')
       AND   qte.accepted_yn = 'Y'
       AND   tql.qlt_code = 'AMCFIA'
       AND   tql.kle_id = p_kle_id
       AND   EXISTS
            (
              SELECT  1
                FROM  okl_trx_assets    tas
                     ,okl_txl_assets_b  tal
                     ,okc_k_lines_b     cleb
               WHERE  cleb.id     = tql.kle_id
                 AND  cleb.cle_id = tal.kle_id
                 AND  tal.tas_id  = tas.id
                 AND  tas.id      = p_split_asset_trx_id
             );

  -- For Release Transaction
  CURSOR c_tq_dtls_release( p_khr_id          NUMBER )
  IS
    SELECT   qte.quote_number       quote_number
            ,qte.date_accepted      quote_accepted_date
            ,qte.qtp_code           quote_type
      FROM   okl_trx_types_b        trx_b
            ,okl_trx_contracts_all  rel_trx
            ,okl_trx_quotes_all_b   qte
     WHERE   trx_b.trx_type_class = 'RE_LEASE'
       AND   trx_b.id = rel_trx.try_id
       AND   rel_trx.khr_id_new = p_khr_id
       AND   rel_trx.tsu_code <> 'PROCESSED'
       AND   qte.id = rel_trx.qte_id;

  -- get the representations. MG uptake
  CURSOR get_rep_type_csr(p_book_type_name varchar2) IS
  SELECT o.ledger_id,
         o.representation_code,
         o.representation_name,
		 o.representation_type
    FROM okl_representations_v o,
	     fa_book_controls f
   WHERE o.ledger_id = f.set_of_books_id
     AND f.book_type_name = p_book_type_name;

  -- get the representations based on book_type_code .. MG uptake
  CURSOR get_reps_csr(p_book_type_code varchar2) IS
  SELECT o.ledger_id,
         o.representation_code,
         o.representation_name,
		 o.representation_type
    FROM okl_representations_v o,
	     fa_book_controls f
   WHERE o.ledger_id = f.set_of_books_id
     AND f.book_type_code = p_book_type_code;

  -- get the reporting product based on the contract product .. MG uptake
  CURSOR c_rep_pdt_csr(p_pdt_id number) IS
  SELECT reporting_pdt_id
    FROM okl_products p
   WHERE p.id = p_pdt_id;

  -- get the book_type_name for asset book type code .. MG uptake
	CURSOR get_book_type_name(p_book_type_code varchar2) IS
	SELECT book_type_name
	  FROM fa_book_controls
     WHERE book_type_code = p_book_type_code;

  PROCEDURE write_to_log(
              p_level                 IN VARCHAR2,
              p_module                IN fnd_log_messages.module%TYPE,
              msg                     IN VARCHAR2 )
  AS
    -- l_level: S - Statement, P- Procedure, B - Both
  BEGIN
    okl_debug_pub.log_debug(
      p_level,
      p_module,
      msg);
  END;

  PROCEDURE put_in_log(
              p_debug_enabled         IN VARCHAR2,
              is_debug_procedure_on   IN BOOLEAN,
              is_debug_statement_on   IN BOOLEAN,
              p_module                IN fnd_log_messages.module%TYPE,
              p_level                 IN VARCHAR2,
              msg                     IN VARCHAR2 )
  AS
    -- l_level: S - Statement, P- Procedure, B - Both
  BEGIN
    IF(p_debug_enabled='Y' AND is_debug_procedure_on AND p_level = 'P')
    THEN
        write_to_log(
          p_level   => FND_LOG.LEVEL_PROCEDURE,
          p_module  => p_module,
          msg       => msg);
    ELSIF (p_debug_enabled='Y' AND is_debug_statement_on AND
          (p_level = 'S' OR p_level = 'B' ))
    THEN
        write_to_log(
          p_level   => FND_LOG.LEVEL_STATEMENT,
          p_module  => p_module,
          msg       => msg);
    END IF;
  END put_in_log;

  PROCEDURE write_ext_hdr_to_log(
               p_teh_rec              IN      okl_teh_pvt.teh_rec_type
              ,p_tehl_tbl             IN      okl_teh_pvt.tehl_tbl_type
              ,p_module               IN      fnd_log_messages.module%TYPE)
  AS
    tl_index   NUMBER;
  BEGIN
    -- Print the Sources captured at extension Header Level
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'HEADER_EXTENSION_ID       =' || p_teh_rec.HEADER_EXTENSION_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SOURCE_ID                 =' || p_teh_rec.SOURCE_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SOURCE_TABLE              =' || p_teh_rec.SOURCE_TABLE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'OBJECT_VERSION_NUMBER     =' || p_teh_rec.OBJECT_VERSION_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_NUMBER           =' || p_teh_rec.CONTRACT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_NUMBER         =' || p_teh_rec.INV_AGRMNT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_CURRENCY_CODE    =' || p_teh_rec.CONTRACT_CURRENCY_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_CURRENCY_CODE  =' || p_teh_rec.INV_AGRMNT_CURRENCY_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_EFFECTIVE_FROM   =' || p_teh_rec.CONTRACT_EFFECTIVE_FROM );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_EFFECTIVE_FROM =' || p_teh_rec.INV_AGRMNT_EFFECTIVE_FROM );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUSTOMER_NAME             =' || p_teh_rec.CUSTOMER_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SALES_REP_NAME            =' || p_teh_rec.SALES_REP_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUSTOMER_ACCOUNT_NUMBER   =' || p_teh_rec.CUSTOMER_ACCOUNT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'BILL_TO_ADDRESS_NUM       =' || p_teh_rec.BILL_TO_ADDRESS_NUM );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INT_CALC_METHOD_CODE      =' || p_teh_rec.INT_CALC_METHOD_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'REV_REC_METHOD_CODE       =' || p_teh_rec.REV_REC_METHOD_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONVERTED_NUMBER          =' || p_teh_rec.CONVERTED_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSIGNABLE_FLAG           =' || p_teh_rec.ASSIGNABLE_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CREDIT_LINE_NUMBER        =' || p_teh_rec.CREDIT_LINE_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'MASTER_LEASE_NUMBER       =' || p_teh_rec.MASTER_LEASE_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'PO_ORDER_NUMBER           =' || p_teh_rec.PO_ORDER_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'VENDOR_PROGRAM_NUMBER     =' || p_teh_rec.VENDOR_PROGRAM_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INS_POLICY_TYPE_CODE      =' || p_teh_rec.INS_POLICY_TYPE_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INS_POLICY_NUMBER         =' || p_teh_rec.INS_POLICY_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TERM_QUOTE_ACCEPT_DATE    =' || p_teh_rec.TERM_QUOTE_ACCEPT_DATE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TERM_QUOTE_NUM            =' || p_teh_rec.TERM_QUOTE_NUM );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TERM_QUOTE_TYPE_CODE      =' || p_teh_rec.TERM_QUOTE_TYPE_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONVERTED_ACCOUNT_FLAG    =' || p_teh_rec.CONVERTED_ACCOUNT_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ACCRUAL_OVERRIDE_FLAG     =' || p_teh_rec.ACCRUAL_OVERRIDE_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE_CATEGORY   =' || p_teh_rec.CUST_ATTRIBUTE_CATEGORY );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE1           =' || p_teh_rec.CUST_ATTRIBUTE1 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE2           =' || p_teh_rec.CUST_ATTRIBUTE2 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE3           =' || p_teh_rec.CUST_ATTRIBUTE3 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE4           =' || p_teh_rec.CUST_ATTRIBUTE4 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE5           =' || p_teh_rec.CUST_ATTRIBUTE5 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE6           =' || p_teh_rec.CUST_ATTRIBUTE6 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE7           =' || p_teh_rec.CUST_ATTRIBUTE7 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE8           =' || p_teh_rec.CUST_ATTRIBUTE8 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE9           =' || p_teh_rec.CUST_ATTRIBUTE9 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE10          =' || p_teh_rec.CUST_ATTRIBUTE10 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE11          =' || p_teh_rec.CUST_ATTRIBUTE11 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE12          =' || p_teh_rec.CUST_ATTRIBUTE12 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE13          =' || p_teh_rec.CUST_ATTRIBUTE13 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE14          =' || p_teh_rec.CUST_ATTRIBUTE14 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE15          =' || p_teh_rec.CUST_ATTRIBUTE15 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RENT_IA_CONTRACT_NUMBER   =' || p_teh_rec.RENT_IA_CONTRACT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RES_IA_CONTRACT_NUMBER    =' || p_teh_rec.RES_IA_CONTRACT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_POOL_NUMBER    =' || p_teh_rec.INV_AGRMNT_POOL_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RENT_IA_PRODUCT_NAME      =' || p_teh_rec.RENT_IA_PRODUCT_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RES_IA_PRODUCT_NAME       =' || p_teh_rec.RES_IA_PRODUCT_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RENT_IA_ACCOUNTING_CODE   =' || p_teh_rec.RENT_IA_ACCOUNTING_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RES_IA_ACCOUNTING_CODE    =' || p_teh_rec.RES_IA_ACCOUNTING_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_SYND_CODE      =' || p_teh_rec.INV_AGRMNT_SYND_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_STATUS_CODE      =' || p_teh_rec.CONTRACT_STATUS_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_STATUS_CODE    =' || p_teh_rec.INV_AGRMNT_STATUS_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TRX_TYPE_CLASS_CODE       =' || p_teh_rec.TRX_TYPE_CLASS_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CHR_OPERATING_UNIT_CODE   =' || p_teh_rec.CHR_OPERATING_UNIT_CODE );
    -- Print translatable sources
    FOR tl_index IN p_tehl_tbl.FIRST .. p_tehl_tbl.LAST
    LOOP
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LANGUAGE                =' || p_tehl_tbl(tl_index).LANGUAGE );
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_STATUS         =' || p_tehl_tbl(tl_index).CONTRACT_STATUS );
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INV_AGRMNT_STATUS       =' || p_tehl_tbl(tl_index).INV_AGRMNT_STATUS );
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CHR_OPERATING_UNIT_NAME =' || p_tehl_tbl(tl_index).CHR_OPERATING_UNIT_NAME );
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TRANSACTION_TYPE_NAME   =' || p_tehl_tbl(tl_index).TRANSACTION_TYPE_NAME );
    END LOOP;
  END;

  PROCEDURE write_ext_line_to_log(
               p_tel_rec              IN      tel_rec_type
              ,p_tell_tbl             IN      tell_tbl_type
              ,p_module               IN      fnd_log_messages.module%TYPE)
  AS
    tl_index   NUMBER;
  BEGIN
    -- Print the Sources captured at Extension Line Level
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_EXTENSION_ID           =' || p_tel_rec.LINE_EXTENSION_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SOURCE_ID                   =' || p_tel_rec.SOURCE_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SOURCE_TABLE                =' || p_tel_rec.SOURCE_TABLE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TEH_ID                      =' || p_tel_rec.TEH_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_LINE_NUMBER        =' || p_tel_rec.CONTRACT_LINE_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'FEE_TYPE_CODE               =' || p_tel_rec.FEE_TYPE_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_NUMBER                =' || p_tel_rec.ASSET_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_CATEGORY_NAME         =' || p_tel_rec.ASSET_CATEGORY_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_VENDOR_NAME           =' || p_tel_rec.ASSET_VENDOR_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_MANUFACTURER_NAME     =' || p_tel_rec.ASSET_MANUFACTURER_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_YEAR_MANUFACTURED     =' || p_tel_rec.ASSET_YEAR_MANUFACTURED );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_MODEL_NUMBER          =' || p_tel_rec.ASSET_MODEL_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_DELIVERED_DATE        =' || p_tel_rec.ASSET_DELIVERED_DATE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INSTALLED_SITE_ID           =' || p_tel_rec.INSTALLED_SITE_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'FIXED_ASSET_LOCATION_NAME   =' || p_tel_rec.FIXED_ASSET_LOCATION_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTINGENCY_CODE            =' || p_tel_rec.CONTINGENCY_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SUBSIDY_NAME                =' || p_tel_rec.SUBSIDY_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'SUBSIDY_PARTY_NAME          =' || p_tel_rec.SUBSIDY_PARTY_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'MEMO_FLAG                   =' || p_tel_rec.MEMO_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RECIEVABLES_TRX_TYPE_NAME   =' || p_tel_rec.RECIEVABLES_TRX_TYPE_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'AGING_BUCKET_NAME           =' || p_tel_rec.AGING_BUCKET_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_LINE_TYPE          =' || p_tel_rec.CONTRACT_LINE_TYPE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'PAY_SUPPLIER_SITE_NAME      =' || p_tel_rec.PAY_SUPPLIER_SITE_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INVENTORY_ITEM_NAME_CODE    =' || p_tel_rec.INVENTORY_ITEM_NAME_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INVENTORY_ORG_CODE          =' || p_tel_rec.INVENTORY_ORG_CODE );
    -- Print translatable sources
    FOR tl_index IN p_tell_tbl.FIRST .. p_tell_tbl.LAST
    LOOP
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LANGUAGE                  =' || p_tell_tbl(tl_index).LANGUAGE );
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INVENTORY_ITEM_NAME       =' || p_tell_tbl(tl_index).INVENTORY_ITEM_NAME );
      write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INVENTORY_ORG_NAMES       =' || p_tell_tbl(tl_index).INVENTORY_ORG_NAME );
    END LOOP;
  END;

  ---------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_tcn_sources
  --      Pre-reqs        : None
  --      Function        : Creates records for OKL_TRX_EXTENSION_V
  --      Parameters      :
  --      IN              : p_source_id IN NUMBER            Required
  --                        Corresponds to the column ID
  --                           in the table OKL_TRX_CONTRACTS.
  --                        p_source_table IN VARCHAR2     Required
  --                        Value  G_TRX_CONTRACTS
  --      Version         : 1.0
  --      History         : Ravi Gooty created
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE populate_tcn_sources(
    p_api_version                IN             NUMBER
   ,p_init_msg_list              IN             VARCHAR2
   ,px_trans_hdr_rec             IN OUT NOCOPY  tehv_rec_type
   ,p_acc_sources_rec            IN             asev_rec_type
   ,x_return_status              OUT    NOCOPY  VARCHAR2
   ,x_msg_count                  OUT    NOCOPY  NUMBER
   ,x_msg_data                   OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'POPULATE_TCN_SOURCES';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -----------------------------------------------------------------
    -- Declare records: Extension Headers
    -----------------------------------------------------------------
    l_teh_rec_in       okl_teh_pvt.teh_rec_type;
    l_teh_rec_out      okl_teh_pvt.teh_rec_type;
    l_tehl_tbl_in      okl_teh_pvt.tehl_tbl_type;
    l_tehl_tbl_out     okl_teh_pvt.tehl_tbl_type;

    -- To fetch  khr_id, Termination Quote_id, Event Class
    CURSOR c_tcn_basic_csr (p_source_id   NUMBER)
    IS
      SELECT   tcn.khr_id                      khr_id
              ,tcn.qte_id                      qte_id
              ,tcn.pdt_id                      pdt_id
              ,tcn.set_of_books_id             ledger_id
              ,try.accounting_event_class_code accounting_event_class_code
              ,try.id                          try_id
              ,tcn_type                        tcn_type
        FROM   okl_trx_contracts_all tcn
              ,okl_trx_types_b       try
       WHERE  tcn.id = p_source_id
         AND  tcn.try_id = try.id
         AND  try.accounting_event_class_code IS NOT NULL;
    l_tcn_basic_csr_rec  c_tcn_basic_csr%ROWTYPE;

    -- Record structures based on the cursor variables.
    l_ledger_lang_rec               c_ledger_lang_csr%ROWTYPE;
    l_get_status_meaning_rec        c_get_status_meaning_csr%ROWTYPE;
    l_khr_attributes_csr_rec        c_khr_attributes_csr%ROWTYPE;
    l_kpl_attributes_csr_rec        c_kpl_attributes_csr%ROWTYPE;
    l_rev_rec_int_calc_mtd_csr_rec  c_rev_rec_int_calc_methods_csr%ROWTYPE;
    l_investor_agree_main_csr_rec   c_investor_agreement_main_csr%ROWTYPE;
    l_inv_agree_acc_code_csr_rec    c_investor_agree_acc_code_csr%ROWTYPE;
    l_cust_name_account_csr_rec     c_cust_name_account_csr%ROWTYPE;
    l_insurance_csr_rec             c_insurance_csr%ROWTYPE;
    l_sales_rep_acc_sources_csr     c_sales_rep_acc_sources_csr%ROWTYPE;
    l_crline_master_lease_csr_rec   c_creditline_master_lease_csr%ROWTYPE;
    l_creditline_sub_csr_rec        c_creditline_sub_csr%ROWTYPE;
    l_vendor_program_number_csr     c_vendor_program_number_csr%ROWTYPE;
    l_trx_type_name_rec             c_trx_type_name_csr%ROWTYPE;
    l_termination_qte_csr_rec       c_termination_qte_csr%ROWTYPE;
    l_inv_agrmnt_details_rec        c_inv_agrmnt_details_csr%ROWTYPE;
    -- Local Variables
    l_khr_id                        okl_trx_contracts_all.khr_id%TYPE;
    l_qte_id                        okl_trx_contracts_all.qte_id%TYPE;
    l_pdt_id                        okl_trx_contracts_all.pdt_id%TYPE;
    l_ledger_id                     okl_trx_contracts_all.set_of_books_id%TYPE;
    l_accounting_event_class_code   okl_trx_types_b.accounting_event_class_code%TYPE;
    l_cust_acct_id                  okc_k_headers_all_b.cust_acct_id%TYPE;
    l_rent_ia_chr_id                okc_k_headers_all_b.id%TYPE;
    l_res_ia_chr_id                 okc_k_headers_all_b.id%TYPE;
    l_master_lease_id               okc_k_headers_all_b.id%TYPE;
    l_acc_sources_rec               asev_rec_type;
    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
    tl_sources_in                      NUMBER := 1;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_TCN_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Return status from OKL_API.START_ACTIVITY :'||l_return_status);
    -- Store the source id and source table in the rec to be passed to the Insert API
    l_teh_rec_in.source_id     := px_trans_hdr_rec.source_id;
    l_teh_rec_in.source_table  := px_trans_hdr_rec.source_table;
    -- Validations ..
    IF px_trans_hdr_rec.source_table NOT LIKE G_TRX_CONTRACTS
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Assign the AGS Record to the Local Record Structure
    l_acc_sources_rec := p_acc_sources_rec;
    -- Validation on the AGS Record
    IF l_acc_sources_rec.source_id IS NULL
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'ACCT_SOURCES.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing Cursor c_tcn_basic_csr: Source ID: ' || px_trans_hdr_rec.source_id);
    FOR  t_rec IN  c_tcn_basic_csr (p_source_id => px_trans_hdr_rec.source_id)
    LOOP
      l_tcn_basic_csr_rec := t_rec;
      IF l_tcn_basic_csr_rec.accounting_event_class_code IS NULL
      THEN
        -- accounting_event_class_code is missing
        OKL_API.set_message(
           p_app_name      => G_APP_NAME
          ,p_msg_name      => G_INVALID_VALUE
          ,p_token1        => G_COL_NAME_TOKEN
          ,p_token1_value  => 'ACCOUNTING_EVENT_CLASS_CODE');
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      l_khr_id    := l_tcn_basic_csr_rec.khr_id;
      l_qte_id    := l_tcn_basic_csr_rec.qte_id;
      l_pdt_id    := l_tcn_basic_csr_rec.pdt_id;
      l_ledger_id := l_tcn_basic_csr_rec.ledger_id;
      l_accounting_event_class_code    := l_tcn_basic_csr_rec.accounting_event_class_code;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' l_khr_id : ' || l_khr_id ||
        ' l_qte_id : ' || l_qte_id ||
        ' l_pdt_id : ' || l_pdt_id ||
        ' l_accounting_event_class_code : ' || l_accounting_event_class_code ||
        ' ledger_id ' ||  TO_CHAR( l_tcn_basic_csr_rec.ledger_id));
    END LOOP; --  c_tcn_basic_csr;

    -- Fetch the Ledger language in order to populate the MLS Sources at header level.
    -- Store the Ledger Language so that its passed to the TAPI
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Picked Language | Ledger Language | USERENV Language p_ledger_id=' || TO_CHAR(l_ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_ledger_id )
    LOOP
      l_tehl_tbl_in(tl_sources_in).language := t_rec.language_code;
      tl_sources_in := tl_sources_in + 1;
    END LOOP;

    FOR tl_sources_in in l_tehl_tbl_in.FIRST .. l_tehl_tbl_in.LAST
    LOOP
      -- Fetch the Transaction Type in Ledger language
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_trx_type_name_csr. p_try_id=' || TO_CHAR(l_tcn_basic_csr_rec.try_id)
        || 'p_led_lang= ' || l_tehl_tbl_in(tl_sources_in).language );
      FOR t_rec IN c_trx_type_name_csr(
                                    p_try_id   => l_tcn_basic_csr_rec.try_id
                                   ,p_led_lang => l_tehl_tbl_in(tl_sources_in).language )
      LOOP
        l_trx_type_name_rec := t_rec;
        l_tehl_tbl_in(tl_sources_in).transaction_type_name  := l_trx_type_name_rec.transaction_type_name;
        l_teh_rec_in.trx_type_class_code    := l_trx_type_name_rec.trx_type_class_code;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Fetched Transaction Type ' || l_tehl_tbl_in(tl_sources_in).transaction_type_name );
      END LOOP;
    END LOOP;

    IF l_accounting_event_class_code NOT IN ( G_INVESTOR )
    THEN
      --------------------------------------------------------------------------------
      -- Populating Common Header Sources
      --------------------------------------------------------------------------------
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing Cursor c_khr_attributes_csr : l_khr_id = ' ||to_char(l_khr_id));
      FOR t_rec IN c_khr_attributes_csr (l_khr_id)
      LOOP
        l_khr_attributes_csr_rec             := t_rec;
        l_teh_rec_in.source_id               := px_trans_hdr_rec.source_id;
        l_teh_rec_in.source_table            := px_trans_hdr_rec.source_table;
        l_cust_acct_id                       := l_khr_attributes_csr_rec.cust_acct_id;
        l_teh_rec_in.contract_number         := l_khr_attributes_csr_rec.contract_number;
        l_teh_rec_in.contract_currency_code  := l_khr_attributes_csr_rec.currency_code;
        l_teh_rec_in.contract_effective_from := l_khr_attributes_csr_rec.start_date;
        l_teh_rec_in.bill_to_address_num     := l_khr_attributes_csr_rec.bill_to_site_use_id;
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
	l_teh_rec_in.cust_site_use_id        := l_khr_attributes_csr_rec.bill_to_site_use_id;
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
        l_teh_rec_in.converted_number        := l_khr_attributes_csr_rec.orig_system_reference1;
        l_teh_rec_in.assignable_flag         := l_khr_attributes_csr_rec.assignable_yn;
        l_teh_rec_in.converted_account_flag  := l_khr_attributes_csr_rec.converted_account_yn;
        l_teh_rec_in.po_order_number         := l_khr_attributes_csr_rec.cust_po_number;
        l_teh_rec_in.accrual_override_flag   := l_khr_attributes_csr_rec.generate_accrual_override_yn;
        l_teh_rec_in.chr_operating_unit_code := l_khr_attributes_csr_rec.hr_org_name;
        l_teh_rec_in.contract_status_code    := l_khr_attributes_csr_rec.sts_code;
        IF l_accounting_event_class_code IN ( G_BOOKING, G_REBOOK, G_RE_LEASE )
        THEN
          l_teh_rec_in.contract_status_code := 'BOOKED';
        ELSIF l_accounting_event_class_code = G_TERMINATION AND
              l_tcn_basic_csr_rec.tcn_type = 'TMT'
        THEN
          -- Full Termination Transaction
          l_teh_rec_in.contract_status_code := 'TERMINATED';
        ELSIF l_accounting_event_class_code = G_EVERGREEN
        THEN
          l_teh_rec_in.contract_status_code := 'EVERGREEN';
        END IF;
      END LOOP; -- c_khr_attributes_csr

      FOR tl_sources_in in l_tehl_tbl_in.FIRST .. l_tehl_tbl_in.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_get_status_meaning_csr. p_sts_code=' ||
          l_khr_attributes_csr_rec.sts_code || 'p_led_lang= ' || l_tehl_tbl_in(tl_sources_in).language );
        FOR t_rec IN c_get_status_meaning_csr(
                                        p_sts_code  => l_teh_rec_in.contract_status_code
                                       ,p_led_lang  => l_tehl_tbl_in(tl_sources_in).language )
        LOOP
          l_get_status_meaning_rec      := t_rec;
          l_tehl_tbl_in(tl_sources_in).contract_status := l_get_status_meaning_rec.status_meaning;
        END LOOP; -- End for c_get_status_meaning_csr

        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_org_name_csr. p_org_id= ' || to_char(l_khr_attributes_csr_rec.authoring_org_id) ||
          ' ledger_language=' || l_tehl_tbl_in(tl_sources_in).language );
        FOR t_rec IN c_org_name_csr(
                      p_org_id      => l_khr_attributes_csr_rec.authoring_org_id
                     ,p_ledger_lang => l_tehl_tbl_in(tl_sources_in).language )
        LOOP
          l_tehl_tbl_in(tl_sources_in).chr_operating_unit_name := t_rec.org_name;
        END LOOP;
      END LOOP;

      IF l_accounting_event_class_code NOT IN ( G_BOOKING )
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'RENT: Executing the Cursor c_investor_agreement_main_csr l_khr_id = : ' || TO_CHAR(l_khr_id));
        FOR t_rec IN c_investor_agreement_main_csr(
                        p_khr_id   => l_khr_id
                       ,p_sty_type => 'RENT')
        LOOP
          l_rent_ia_chr_id                      := t_rec.ia_chr_id;
          l_teh_rec_in.rent_ia_contract_number := t_rec.ia_contract_number;
          l_teh_rec_in.rent_ia_product_name    := t_rec.ia_product_name;
        END LOOP;  -- c_investor_agreement_main_csr

        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'RESIDUAL VALUE: Executing the Cursor c_investor_agreement_main_csr l_khr_id = : ' || TO_CHAR(l_khr_id));
        FOR t_rec IN c_investor_agreement_main_csr(
                        p_khr_id   => l_khr_id
                       ,p_sty_type => 'RESIDUAL VALUE')
        LOOP
          l_res_ia_chr_id                       := t_rec.ia_chr_id;
          l_teh_rec_in.res_ia_contract_number  := t_rec.ia_contract_number;
          l_teh_rec_in.res_ia_product_name     := t_rec.ia_product_name;
        END LOOP;  -- c_investor_agreement_main_csr
      END IF; -- IF l_accounting_event_class_code NOT IN ( G_BOOKING )

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_kpl_attributes_csr l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_kpl_attributes_csr (l_khr_id)
      LOOP
        l_kpl_attributes_csr_rec  := t_rec;
        l_teh_rec_in.cust_attribute_category := l_kpl_attributes_csr_rec.attribute_category;
        l_teh_rec_in.cust_attribute1  := l_kpl_attributes_csr_rec.attribute1;
        l_teh_rec_in.cust_attribute2  := l_kpl_attributes_csr_rec.attribute2;
        l_teh_rec_in.cust_attribute3  := l_kpl_attributes_csr_rec.attribute3;
        l_teh_rec_in.cust_attribute4  := l_kpl_attributes_csr_rec.attribute4;
        l_teh_rec_in.cust_attribute5  := l_kpl_attributes_csr_rec.attribute5;
        l_teh_rec_in.cust_attribute6  := l_kpl_attributes_csr_rec.attribute6;
        l_teh_rec_in.cust_attribute7  := l_kpl_attributes_csr_rec.attribute7;
        l_teh_rec_in.cust_attribute8  := l_kpl_attributes_csr_rec.attribute8;
        l_teh_rec_in.cust_attribute9  := l_kpl_attributes_csr_rec.attribute9;
        l_teh_rec_in.cust_attribute10 := l_kpl_attributes_csr_rec.attribute10;
        l_teh_rec_in.cust_attribute11 := l_kpl_attributes_csr_rec.attribute11;
        l_teh_rec_in.cust_attribute12 := l_kpl_attributes_csr_rec.attribute12;
        l_teh_rec_in.cust_attribute13 := l_kpl_attributes_csr_rec.attribute13;
        l_teh_rec_in.cust_attribute14 := l_kpl_attributes_csr_rec.attribute14;
        l_teh_rec_in.cust_attribute15 := l_kpl_attributes_csr_rec.attribute15;
      END LOOP;   -- c_kpl_attributes_csr_attributes_csr_attributes_csr

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor  c_vendor_program_number_csr p_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_vendor_program_number_csr (p_khr_id => l_khr_id)
      LOOP
        l_teh_rec_in.vendor_program_number  := t_rec.contract_number;
      END LOOP;  -- c_vendor_program_number_csr

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor l_cust_name_account_csr. l_khr_id = ' || TO_CHAR(l_khr_id)
        || ' l_cust_acct_id = ' || TO_CHAR(l_cust_acct_id ) );
      FOR t_rec IN  c_cust_name_account_csr (l_khr_id,l_cust_acct_id)
      LOOP
        l_cust_name_account_csr_rec := t_rec;
        l_teh_rec_in.customer_name        := l_cust_name_account_csr_rec.party_name;
        l_teh_rec_in.customer_account_number  := l_cust_name_account_csr_rec.account_number;
-- added by zrehman Bug#6707320 for Party Merge Impact on Transaction Sources tables start
        l_teh_rec_in.cust_account_id  := l_cust_acct_id;
	l_teh_rec_in.party_id := l_cust_name_account_csr_rec.party_id;
-- added by zrehman Bug#6707320 for Party Merge Impact on Transaction Sources tables end
      END LOOP;  -- c_cust_name_account_csr

      IF l_accounting_event_class_code NOT IN ( G_BOOKING )
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_investor_agree_acc_code_csr. l_rent_ia_chr_id = '
          || TO_CHAR(l_rent_ia_chr_id) || ' l_res_ia_chr_id = ' || l_res_ia_chr_id);
        FOR t_rec in c_investor_agree_acc_code_csr (l_rent_ia_chr_id, l_res_ia_chr_id)
        LOOP
          l_inv_agree_acc_code_csr_rec := t_rec;
          l_teh_rec_in.rent_ia_accounting_code    := l_inv_agree_acc_code_csr_rec.rent_ia_accounting_code;
          l_teh_rec_in.res_ia_accounting_code     := l_inv_agree_acc_code_csr_rec.res_ia_accounting_code;
        END LOOP;  -- c_investor_agree_acc_code_csr
      END IF; -- IF l_accounting_event_class_code NOT IN ( G_BOOKING )

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_rev_rec_int_calc_methods_csr. l_pdt_id = ' || TO_CHAR(l_pdt_id) );
      FOR t_rec  IN c_rev_rec_int_calc_methods_csr(l_pdt_id)
      LOOP
        l_rev_rec_int_calc_mtd_csr_rec := t_rec;
        l_teh_rec_in.rev_rec_method_code  := l_rev_rec_int_calc_mtd_csr_rec.rev_rec_method_code;
        l_teh_rec_in.int_calc_method_code := l_rev_rec_int_calc_mtd_csr_rec.int_calc_method_code;
      END LOOP;

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_creditline_master_lease_csr. l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_creditline_master_lease_csr (l_khr_id)
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ' Line Type ' || t_rec.chr_type );
        IF t_rec.chr_type = 'CREDITLINE_CONTRACT'
        THEN
          l_teh_rec_in.credit_line_number   := t_rec.credit_line_number;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Credit Line Number ' || l_teh_rec_in.credit_line_number );
        END IF;
        IF t_rec.chr_type = 'MASTER_LEASE'
        THEN
          l_master_lease_id                  := t_rec.master_lease_id;
          l_teh_rec_in.master_lease_number  := t_rec.master_lease_number;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Master Lease Number ' ||  l_teh_rec_in.master_lease_number );
        END IF;
      END LOOP;
      IF (l_teh_rec_in.credit_line_number IS NULL AND
          l_master_lease_id IS NOT NULL)
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_creditline_sub_csr. l_master_lease_id = ' || TO_CHAR(l_master_lease_id) );
        FOR t_rec IN c_creditline_sub_csr (l_master_lease_id)
        LOOP
          l_creditline_sub_csr_rec := t_rec;
          l_teh_rec_in.credit_line_number := l_creditline_sub_csr_rec.contract_number;
        END LOOP;
      END IF;
    END IF;  -- NOT LIKE G_INVESTOR
    --------------------------------------------------------------------------------
    -- Populating Sources specific to Event Classe(s)
    --------------------------------------------------------------------------------
    IF (l_accounting_event_class_code IN (G_TERMINATION, G_ASSET_DISPOSITION, G_SPLIT_ASSET))
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_termination_qte_csr. l_qte_id = ' || TO_CHAR(l_qte_id) );
      FOR t_rec IN  c_termination_qte_csr (l_qte_id)
      LOOP
        l_termination_qte_csr_rec := t_rec;
        l_teh_rec_in.term_quote_accept_date := l_termination_qte_csr_rec.date_effective_from;
        l_teh_rec_in.term_quote_num         := l_termination_qte_csr_rec.quote_number;
        l_teh_rec_in.term_quote_type_code   :=  l_termination_qte_csr_rec.qtp_code;
      END LOOP;  -- c_termination_qte_csr
    END IF; -- TERMINATION/ ASSET_DISPOSITION Specific.

    IF  l_accounting_event_class_code IN (G_ACCRUAL)
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_insurance_csr. l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_insurance_csr  (l_khr_id)
      LOOP
        l_insurance_csr_rec := t_rec;
        l_teh_rec_in.ins_policy_type_code  := l_insurance_csr_rec.ipe_code;
        l_teh_rec_in.ins_policy_number  := l_insurance_csr_rec.policy_number;
      END LOOP; -- c_insurance_csr
    END IF; -- ACCRUAL SPECIFIC

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '** Sales Representative ID passed = ' || TO_CHAR(l_acc_sources_rec.jtf_sales_reps_pk) );
    IF ( l_accounting_event_class_code NOT IN
         (G_RECEIPT_APPLICATION, G_INVESTOR) ) AND
        l_acc_sources_rec.jtf_sales_reps_pk IS NOT NULL -- Account Generator Source should not be NULL
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor  c_sales_rep_acc_sources_csr. l_sales_rep_id = ' || TO_CHAR(l_acc_sources_rec.jtf_sales_reps_pk) );
      FOR t_rec IN  c_sales_rep_acc_sources_csr (p_jtf_sales_rep_pk => l_acc_sources_rec.jtf_sales_reps_pk)
      LOOP
        l_sales_rep_acc_sources_csr  := t_rec;
        l_teh_rec_in.sales_rep_name := l_sales_rep_acc_sources_csr.name;
      END LOOP;  -- c_sales_rep_acc_sources_csr
    END IF;
    --------------------------------------------------------------------------------
    -- Populating Investor Specfic Sources
    --------------------------------------------------------------------------------
    IF  l_accounting_event_class_code IN (G_INVESTOR)
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        ' POPULATING INVESTOR SPECIFIC Sources ' );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_inv_agrmnt_details_csr. l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_inv_agrmnt_details_csr( p_inv_agrmnt_id => l_khr_id )
      LOOP
        l_inv_agrmnt_details_rec := t_rec;
        l_teh_rec_in.inv_agrmnt_number         := l_inv_agrmnt_details_rec.inv_agrmnt_number;
        l_teh_rec_in.inv_agrmnt_synd_code      := l_inv_agrmnt_details_rec.inv_agrmnt_synd_code;
        l_teh_rec_in.inv_agrmnt_pool_number    := l_inv_agrmnt_details_rec.inv_agrmnt_pool_number;
        l_teh_rec_in.inv_agrmnt_currency_code  := l_inv_agrmnt_details_rec.inv_agrmnt_currency_code;
        l_teh_rec_in.inv_agrmnt_effective_from := l_inv_agrmnt_details_rec.inv_agrmnt_effective_from;
        -- Hard Code the Investor Agreement Status always to ACTIVE
        l_teh_rec_in.inv_agrmnt_status_code    := 'ACTIVE';

        FOR tl_sources_in in l_tehl_tbl_in.FIRST .. l_tehl_tbl_in.LAST
        LOOP
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'INV_AGRMNT_STATUS: Executing the Cursor c_get_status_meaning_csr. p_sts_code=' ||
            l_inv_agrmnt_details_rec.inv_agrmnt_status_code || 'p_led_lang= ' || l_tehl_tbl_in(tl_sources_in).language );
          FOR t_meaning_rec IN c_get_status_meaning_csr(
                                            p_sts_code  => l_inv_agrmnt_details_rec.inv_agrmnt_status_code
                                           ,p_led_lang  => l_tehl_tbl_in(tl_sources_in).language )
          LOOP
            l_get_status_meaning_rec        := t_meaning_rec;
            l_tehl_tbl_in(tl_sources_in).inv_agrmnt_status := l_get_status_meaning_rec.status_meaning;
          END LOOP; -- End for c_get_status_meaning_csr
        END LOOP;
      END LOOP; --
    END IF; -- G_INVESTOR SPECIFIC
    -- If Log is enabled, print all the sources fetched.
    IF (l_debug_enabled='Y' AND is_debug_statement_on)
    THEN
      write_ext_hdr_to_log(
         p_teh_rec  => l_teh_rec_in
        ,p_tehl_tbl => l_tehl_tbl_in
        ,p_module   => l_module);
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_TRX_EXTENSION_PVT.create_trx_extension API. ' || l_tehl_tbl_in.COUNT);
    okl_trx_extension_pvt.create_trx_extension(
       p_api_version     => p_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_teh_rec         => l_teh_rec_in
      ,p_tehl_tbl        => l_tehl_tbl_in
      ,x_teh_rec         => l_teh_rec_out
      ,x_tehl_tbl        => l_tehl_tbl_out
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After execution of OKL_TRX_EXTENSION_PVT.create_trx_extension API. l_return_status ' || l_return_status);
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Returning back the record structure
    px_trans_hdr_rec.header_extension_id := l_teh_rec_out.header_extension_id;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_TCN_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      IF c_tcn_basic_csr%ISOPEN THEN
        CLOSE c_tcn_basic_csr;
      END IF;
      IF c_khr_attributes_csr%ISOPEN THEN
        CLOSE c_khr_attributes_csr;
      END IF;
      IF c_kpl_attributes_csr%ISOPEN THEN
        CLOSE c_kpl_attributes_csr;
      END IF;
      IF c_termination_qte_csr%ISOPEN THEN
        CLOSE c_termination_qte_csr;
      END IF;
      IF c_cust_name_account_csr%ISOPEN THEN
        CLOSE c_cust_name_account_csr;
      END IF;
      IF c_insurance_csr%ISOPEN THEN
        CLOSE c_insurance_csr;
      END IF;
      IF c_sales_rep_acc_sources_csr%ISOPEN THEN
        CLOSE c_sales_rep_acc_sources_csr;
      END IF;
      IF c_creditline_master_lease_csr%ISOPEN THEN
        CLOSE c_creditline_master_lease_csr;
      END IF;
      IF c_creditline_sub_csr%ISOPEN THEN
        CLOSE c_creditline_sub_csr;
      END IF;
      IF c_vendor_program_number_csr%ISOPEN THEN
        CLOSE c_vendor_program_number_csr;
      END IF;
      IF c_investor_agreement_main_csr%ISOPEN THEN
        CLOSE c_investor_agreement_main_csr;
      END IF;
      IF c_investor_agree_acc_code_csr%ISOPEN THEN
        CLOSE c_investor_agree_acc_code_csr;
      END IF;
      IF c_rev_rec_int_calc_methods_csr%ISOPEN THEN
        CLOSE c_rev_rec_int_calc_methods_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      IF c_tcn_basic_csr%ISOPEN THEN
        CLOSE c_tcn_basic_csr;
      END IF;
      IF c_khr_attributes_csr%ISOPEN THEN
        CLOSE c_khr_attributes_csr;
      END IF;
      IF c_kpl_attributes_csr%ISOPEN THEN
        CLOSE c_kpl_attributes_csr;
      END IF;
      IF c_termination_qte_csr%ISOPEN THEN
        CLOSE c_termination_qte_csr;
      END IF;
      IF c_cust_name_account_csr%ISOPEN THEN
        CLOSE c_cust_name_account_csr;
      END IF;
      IF c_insurance_csr%ISOPEN THEN
        CLOSE c_insurance_csr;
      END IF;
      IF c_sales_rep_acc_sources_csr%ISOPEN THEN
        CLOSE c_sales_rep_acc_sources_csr;
      END IF;
      IF c_creditline_master_lease_csr%ISOPEN THEN
        CLOSE c_creditline_master_lease_csr;
      END IF;
      IF c_creditline_sub_csr%ISOPEN THEN
        CLOSE c_creditline_sub_csr;
      END IF;
      IF c_vendor_program_number_csr%ISOPEN THEN
        CLOSE c_vendor_program_number_csr;
      END IF;
      IF c_investor_agreement_main_csr%ISOPEN THEN
        CLOSE c_investor_agreement_main_csr;
      END IF;
      IF c_investor_agree_acc_code_csr%ISOPEN THEN
        CLOSE c_investor_agree_acc_code_csr;
      END IF;
      IF c_rev_rec_int_calc_methods_csr%ISOPEN THEN
        CLOSE c_rev_rec_int_calc_methods_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      IF c_tcn_basic_csr%ISOPEN THEN
        CLOSE c_tcn_basic_csr;
      END IF;
      IF c_khr_attributes_csr%ISOPEN THEN
        CLOSE c_khr_attributes_csr;
      END IF;
      IF c_kpl_attributes_csr%ISOPEN THEN
        CLOSE c_kpl_attributes_csr;
      END IF;
      IF c_termination_qte_csr%ISOPEN THEN
        CLOSE c_termination_qte_csr;
      END IF;
      IF c_cust_name_account_csr%ISOPEN THEN
        CLOSE c_cust_name_account_csr;
      END IF;
      IF c_insurance_csr%ISOPEN THEN
        CLOSE c_insurance_csr;
      END IF;
      IF c_sales_rep_acc_sources_csr%ISOPEN THEN
        CLOSE c_sales_rep_acc_sources_csr;
      END IF;
      IF c_creditline_master_lease_csr%ISOPEN THEN
        CLOSE c_creditline_master_lease_csr;
      END IF;
      IF c_creditline_sub_csr%ISOPEN THEN
        CLOSE c_creditline_sub_csr;
      END IF;
      IF c_vendor_program_number_csr%ISOPEN THEN
        CLOSE c_vendor_program_number_csr;
      END IF;
      IF c_investor_agreement_main_csr%ISOPEN THEN
        CLOSE c_investor_agreement_main_csr;
      END IF;
      IF c_investor_agree_acc_code_csr%ISOPEN THEN
        CLOSE c_investor_agree_acc_code_csr;
      END IF;
      IF c_rev_rec_int_calc_methods_csr%ISOPEN THEN
        CLOSE c_rev_rec_int_calc_methods_csr;
      END IF;
     x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_tcn_sources;

  ---------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_tcl_sources
  --      Pre-reqs        : None
  --      Function        : Creates records for OKL_TXL_EXTENSION_V
  --      Parameters      :
  --      IN              : px_trans_line_rec.source_id IN NUMBER  Required
  --                        Corresponds to the column ID
  --                           in the table OKL_TXL_CNTRCT_LNS.
  --                        px_trans_line_rec.source_table IN VARCHAR2 Required
  --                         Value  G_TXL_CONTRACTS
  --      Version         : 1.0
  --      History         : Ravi Gooty created
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE populate_tcl_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,px_trans_line_rec           IN OUT NOCOPY  telv_rec_type
   ,p_acc_sources_rec           IN             asev_rec_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version              CONSTANT NUMBER         := 1;
    l_api_name                 CONSTANT VARCHAR2(30)   := 'POPULATE_TCL_SOURCES';
    l_return_status            VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------------------------------
    -- Declare records: Extension Headers, Extension Lines
    ------------------------------------------------------------
    l_tel_rec_in        tel_rec_type;
    l_tel_rec_out       tel_rec_type;
    l_tell_tbl_in       tell_tbl_type;
    l_tell_tbl_out      tell_tbl_type;

    -- to fetch  kle_id,  event_class
    CURSOR c_tcl_basic_csr (p_source_id NUMBER)
    IS
      SELECT   tcl.kle_id
              ,tcl.khr_id
              ,tcl.id
              ,tcl.bkt_id
              ,tcl.sty_id
              ,tcn.set_of_books_id ledger_id
              ,try.accounting_event_class_code
        FROM   okl_txl_cntrct_lns_all tcl
              ,okl_trx_contracts_all  tcn
              ,okl_trx_types_b        try
       WHERE  tcl.id = p_source_id
         AND  tcl.tcn_id = tcn.id
         AND  try.id = tcn.try_id
         AND  try.accounting_event_class_code IS NOT NULL;
    l_tcl_basic_csr_rec  c_tcl_basic_csr%ROWTYPE;

    -- Record structures based on Cursor Definitions
    l_ledger_lang_rec               c_ledger_lang_csr%ROWTYPE;
    l_k_lines_rec                   c_k_lines_csr%ROWTYPE;
    l_vendor_name_csr_rec           c_vendor_name_csr%ROWTYPE;
    l_installed_site_csr_rec        c_installed_site_csr%ROWTYPE;
    l_inventory_item_name_csr_rec   c_inventory_item_name_csr%ROWTYPE;
    l_manufacture_model_csr_rec     c_manufacture_model_csr%ROWTYPE;
    l_location_id_csr_rec           c_location_id_csr%ROWTYPE;
    l_asset_location_name_csr_rec   c_asset_location_name_csr%ROWTYPE;
    l_asset_year_mfg_csr_rec        c_asset_year_manufactured_csr%ROWTYPE;
    l_aging_bucket_name_csr_rec     c_aging_bucket_name_csr%ROWTYPE;
    l_cust_trx_type_csr_rec         c_cust_trx_type_csr%ROWTYPE;
    l_acc_sources_rec               asev_rec_type;
    -- Local Variables
    i                               NUMBER := 0;
    tl_sources_in                   NUMBER := 1;
    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_TCL_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Start Activity l_return_status ' || l_return_status );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Copy the input parameters to the local variables and start using them.
    l_tel_rec_in.source_id := px_trans_line_rec.source_id;
    l_tel_rec_in.source_table := px_trans_line_rec.source_table;
    l_tel_rec_in.teh_id := px_trans_line_rec.teh_id;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      ' Input Parameters : p_api_version=' || TO_CHAR(p_api_version) ||
      ' p_init_msg_list=' || p_init_msg_list || 'line_id=' || to_char(l_tel_rec_in.source_id) ||
      ' line_table='|| l_tel_rec_in.source_table);

    IF l_tel_rec_in.source_table <> G_TXL_CONTRACTS
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'LINE.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Assign the AGS Record to the Local Record Structure
    l_acc_sources_rec := p_acc_sources_rec;
    -- Validation on the AGS Record
    IF l_acc_sources_rec.source_id IS NULL
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'ACCT_SOURCES.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_tcl_basic_csr. p_source_id = ' || TO_CHAR(l_tel_rec_in.source_id) );
    OPEN  c_tcl_basic_csr (l_tel_rec_in.source_id);
    FETCH c_tcl_basic_csr INTO l_tcl_basic_csr_rec;
    CLOSE c_tcl_basic_csr;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Closed Cursor c_tcl_basic_csr' );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'input parameter l_tel_rec_in.line_id='|| to_char(l_tel_rec_in.source_id) ||
      ' l_tcl_basic_csr_rec.khr_id='|| to_char(l_tcl_basic_csr_rec.khr_id) ||
      ' l_tcl_basic_csr_rec.kle_id='|| to_char(l_tcl_basic_csr_rec.kle_id) ||
      ' l_tcl_basic_csr_rec.accounting_event_class_code=' || l_tcl_basic_csr_rec.accounting_event_class_code ||
      ' l_tcl_basic_csr_rec.bkt_id=' || to_char(l_tcl_basic_csr_rec.bkt_id) ||
      ' l_tcl_basic_csr_rec.sty_id=' || to_char(l_tcl_basic_csr_rec.sty_id) ||
      ' l_tcl_basic_csr_rec.ledger_id=' || to_char(l_tcl_basic_csr_rec.ledger_id) );

    IF l_tcl_basic_csr_rec.accounting_event_class_code IS NULL
    THEN
      -- accounting_event_class_code is missing
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'ACCOUNTING_EVENT_CLASS_CODE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Store the Ledger Language so that its passed to the TAPI
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Picked Language | Ledger Language | USERENV Language p_ledger_id=' || TO_CHAR(l_tcl_basic_csr_rec.ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_tcl_basic_csr_rec.ledger_id )
    LOOP
      l_tell_tbl_in(tl_sources_in).language := t_rec.language_code;
    END LOOP;

    IF l_tcl_basic_csr_rec.kle_id IS NOT NULL
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_k_lines_csr. kle_id= ' || to_char(l_tcl_basic_csr_rec.kle_id) );
      FOR t_rec IN  c_k_lines_csr (l_tcl_basic_csr_rec.kle_id)
      LOOP
        l_k_lines_rec   := t_rec;
        l_tel_rec_in.contract_line_type       := l_k_lines_rec.contract_line_type;
        IF l_tcl_basic_csr_rec.accounting_event_class_code IN
            ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_PRINCIPAL_ADJUSTMENT )
        THEN
          l_tel_rec_in.fee_type_code          := l_k_lines_rec.fee_type;
        END IF;
        IF l_tcl_basic_csr_rec.accounting_event_class_code IN
             ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_PRINCIPAL_ADJUSTMENT,
               G_MISCELLANEOUS, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET )
        THEN
          l_tel_rec_in.asset_number           := l_k_lines_rec.asset_number;
        END IF;
        IF l_tcl_basic_csr_rec.accounting_event_class_code IN
           (G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET)
        THEN
          l_tel_rec_in.contract_line_number   := l_k_lines_rec.line_number;
        END IF;
        IF l_tcl_basic_csr_rec.accounting_event_class_code IN
             ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_RECEIPT_APPLICATION,
               G_PRINCIPAL_ADJUSTMENT, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET )
        THEN
          l_tel_rec_in.asset_delivered_date   := l_k_lines_rec.date_delivery_expected;
        END IF;
      END LOOP; -- c_k_lines_csr

      IF l_tcl_basic_csr_rec.accounting_event_class_code IN
          (G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_PRINCIPAL_ADJUSTMENT,
            G_MISCELLANEOUS, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET)
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_location_id_csr. kle_id= ' || to_char(l_tcl_basic_csr_rec.kle_id) ||
          ' khr_id=' || to_char(l_tcl_basic_csr_rec.khr_id) );
        OPEN c_location_id_csr(l_tcl_basic_csr_rec.kle_id,l_tcl_basic_csr_rec.khr_id );
        FETCH c_location_id_csr into l_location_id_csr_rec;
        CLOSE c_location_id_csr;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor l_vendor_name_csr_rec. kle_id= ' || to_char(l_tcl_basic_csr_rec.kle_id) ||
          ' khr_id=' || to_char(l_tcl_basic_csr_rec.khr_id) );
        FOR t_rec  IN c_vendor_name_csr(
                                         l_tcl_basic_csr_rec.kle_id
                                        ,l_tcl_basic_csr_rec.khr_id)
        LOOP
          l_vendor_name_csr_rec := t_rec;
          l_tel_rec_in.asset_vendor_name   := l_vendor_name_csr_rec.vendor_name;
          -- added by zrehman Bug#6707320 for Party Merge impact on transaction sources tables start
          l_tel_rec_in.asset_vendor_id   := l_vendor_name_csr_rec.vendor_id;
          -- added by zrehman Bug#6707320 for Party Merge impact on transaction sources tables end
        END LOOP;  -- c_vendor_name_csr
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_asset_location_name_csr. location_id=' ||
          TO_CHAR(l_location_id_csr_rec.location_id) );
        FOR t_rec  IN  c_asset_location_name_csr(l_location_id_csr_rec.location_id)
        LOOP
          l_asset_location_name_csr_rec := t_rec;
          l_tel_rec_in.fixed_asset_location_name := l_asset_location_name_csr_rec.asset_location_name;
        END LOOP;  -- c_asset_location_name_csr
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor l_installed_site_csr_rec. kle_id= ' || to_char(l_tcl_basic_csr_rec.kle_id) ||
          ' khr_id=' || to_char(l_tcl_basic_csr_rec.khr_id) );
        FOR t_rec  IN  c_installed_site_csr(
                                            l_tcl_basic_csr_rec.kle_id
                                           ,l_tcl_basic_csr_rec.khr_id)
        LOOP
          l_installed_site_csr_rec := t_rec;
          l_tel_rec_in.installed_site_id   := l_installed_site_csr_rec.installed_site_id;
        END LOOP;  -- c_installed_site_csr
      END IF;  -- accounting_event_class_code for 7 events

      IF l_tcl_basic_csr_rec.accounting_event_class_code IN
             ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_RECEIPT_APPLICATION,
               G_PRINCIPAL_ADJUSTMENT, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET )
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_manufacture_model_csr. kle_id= ' || to_char(l_tcl_basic_csr_rec.kle_id) ||
          ' khr_id=' || to_char(l_tcl_basic_csr_rec.khr_id) );
        FOR t_rec IN  c_manufacture_model_csr (
                                              l_tcl_basic_csr_rec.kle_id
                                             ,l_tcl_basic_csr_rec.khr_ID)
        LOOP
          l_manufacture_model_csr_rec := t_rec;
          IF l_tcl_basic_csr_rec.accounting_event_class_code NOT LIKE G_ACCRUAL
          THEN
            l_tel_rec_in.asset_manufacturer_name    :=  l_manufacture_model_csr_rec.manufacturer_name;
          END IF;
          l_tel_rec_in.asset_model_number         :=  l_manufacture_model_csr_rec.model_number;
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Executing the Cursor c_asset_year_manufactured_csr. kle_id= ' || to_char(l_tcl_basic_csr_rec.kle_id) ||
            ' khr_id=' || to_char(l_tcl_basic_csr_rec.khr_id) );
          FOR  t_year_man_rec IN c_asset_year_manufactured_csr (
                                             l_tcl_basic_csr_rec.kle_id
                                            ,l_tcl_basic_csr_rec.khr_id)
          LOOP
            l_asset_year_mfg_csr_rec := t_year_man_rec;
            l_tel_rec_in.asset_year_manufactured := l_asset_year_mfg_csr_rec.Year_of_manufacture;
          END LOOP; -- c_asset_year_manufactured_csr
          IF l_tcl_basic_csr_rec.accounting_event_class_code NOT IN
                 ( G_RECEIPT_APPLICATION, G_PRINCIPAL_ADJUSTMENT, G_ACCRUAL, G_MISCELLANEOUS )
          THEN
            l_tel_rec_in.asset_category_name        :=  l_manufacture_model_csr_rec.asset_category_name;
          END IF;
        END LOOP;  -- c_manufacture_model_csr
      END IF;  -- accounting_event_class_code for 5 events

    END IF; --     IF l_tcl_basic_csr_rec.kle_id IS NOT NULL

    IF l_tcl_basic_csr_rec.accounting_event_class_code IN
       (G_BOOKING, G_REBOOK, G_RE_LEASE,  G_ACCRUAL, G_MISCELLANEOUS)
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_cust_trx_type_csr rec_trx_types_pk=' || to_char(l_acc_sources_rec.rec_trx_types_pk) );
      FOR t_rec IN  c_cust_trx_type_csr( p_trx_id => l_acc_sources_rec.rec_trx_types_pk )
      LOOP
        l_cust_trx_type_csr_rec := t_rec;
        l_tel_rec_in.recievables_trx_type_name  :=l_cust_trx_type_csr_rec.trx_name;
      END LOOP;
    END IF;  -- c_cust_trx_type_csr

    IF l_tcl_basic_csr_rec.accounting_event_class_code IN (G_GLP)
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing cursor c_aging_bucket_name_csr bkt_id=' || l_tcl_basic_csr_rec.bkt_id );
      FOR t_rec IN c_aging_bucket_name_csr(l_tcl_basic_csr_rec.bkt_id)
      LOOP
        l_aging_bucket_name_csr_rec := t_rec;
        l_tel_rec_in.aging_bucket_name  :=l_aging_bucket_name_csr_rec.bucket_name;
      END LOOP;  -- c_aging_bucket_name_csr
    END IF;

    -- Populating MLS Sources at Transaction Line Level
    IF l_tcl_basic_csr_rec.accounting_event_class_code IN (G_ACCRUAL,G_ASSET_DISPOSITION, G_SPLIT_ASSET)
    THEN
      FOR tl_sources_in IN l_tell_tbl_in.FIRST .. l_tell_tbl_in.LAST
      LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_inventory_item_name_csr. p_inventory_item_id_pk1= ' ||
        to_char(l_acc_sources_rec.inventory_item_id_pk1) || ' p_inventory_org_id_pk2=' ||
        to_char(l_acc_sources_rec.inventory_org_id_pk2) || ' ledger_language=' ||
        l_tell_tbl_in(tl_sources_in).language );
      FOR t_rec IN c_inventory_item_name_csr(
                     p_inventory_item_id_pk1 => l_acc_sources_rec.inventory_item_id_pk1
                    ,p_inventory_org_id_pk2  => l_acc_sources_rec.inventory_org_id_pk2
                    ,p_ledger_language       => l_tell_tbl_in(tl_sources_in).language)
      LOOP
        l_inventory_item_name_csr_rec := t_rec;
        l_tell_tbl_in(tl_sources_in).inventory_item_name      := l_inventory_item_name_csr_rec.description;
        l_tel_rec_in.inventory_item_name_code := l_inventory_item_name_csr_rec.b_description;
      END LOOP;
      END LOOP;
    END IF; -- IF l_tcn_basic_csr_rec.accounting_event_class_code IN (G_ACCRUAL,G_ASSET_DISPOSITION, G_SPLIT_ASSET)

    -- Populating Common MLS Sources at Transaction Line Level
    IF l_tcl_basic_csr_rec.accounting_event_class_code NOT IN (G_UPFRONT_TAX)
    THEN
      -- Populate Inventory Organization Name
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '*** AGS Inventory Org ID used to fetch teh Inventory Organization Code : Org ID=' ||
      l_acc_sources_rec.inventory_org_id_pk2 );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_org_name_code_csr. p_org_id= ' || to_char(l_acc_sources_rec.inventory_org_id_pk2) );
      FOR t_rec IN c_org_name_code_csr(
                      p_org_id      => l_acc_sources_rec.inventory_org_id_pk2 )
      LOOP
        l_tel_rec_in.inventory_org_code := t_rec.org_name;
      END LOOP;

      FOR tl_sources_in IN l_tell_tbl_in.FIRST .. l_tell_tbl_in.LAST
      LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_org_name_csr. p_org_id= ' || to_char(l_acc_sources_rec.inventory_org_id_pk2) ||
        ' ledger_language=' || l_tell_tbl_in(tl_sources_in).language );
      FOR t_rec IN c_org_name_csr(
                      p_org_id      => l_acc_sources_rec.inventory_org_id_pk2
                     ,p_ledger_lang => l_tell_tbl_in(tl_sources_in).language )
      LOOP
        l_tell_tbl_in(tl_sources_in).inventory_org_name := t_rec.org_name;
      END LOOP;
      END LOOP;
    END IF; -- IF l_tcl_basic_csr_rec.accounting_event_class_code IN (G_UPFRONT_TAX)

    -- Assigning the Memo Indicator to the Extension Line Record structure ..
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '** AGS Memo Flag ' || l_acc_sources_rec.memo_yn );
    l_tel_rec_in.memo_flag := l_acc_sources_rec.memo_yn;

    -- If Log is enabled, print all the sources fetched.
    IF (l_debug_enabled='Y' AND is_debug_statement_on)
    THEN
      write_ext_line_to_log(
        p_tel_rec  => l_tel_rec_in
       ,p_tell_tbl => l_tell_tbl_in
       ,p_module   => l_module);
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_TRX_EXTENSION_PVT.create_txl_extension API.' );

    okl_trx_extension_pvt.create_txl_extension(
       p_api_version     => p_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_tel_rec         => l_tel_rec_in
      ,p_tell_tbl        => l_tell_tbl_in
      ,x_tel_rec         => l_tel_rec_out
      ,x_tell_tbl        => l_tell_tbl_out
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_trx_extension_pvt.create_txl_extension. l_return_status ' || l_return_status );
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Return the values
    px_trans_line_rec.line_extension_id := l_tel_rec_out.line_extension_id;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_TCL_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      IF  c_tcl_basic_csr%ISOPEN THEN
        CLOSE c_tcl_basic_csr;
      END IF;
      IF  c_k_lines_csr%ISOPEN THEN
        CLOSE c_k_lines_csr;
      END IF;
      IF  c_vendor_name_csr%ISOPEN THEN
        CLOSE c_vendor_name_csr;
      END IF;
      IF  c_manufacture_model_csr%ISOPEN THEN
        CLOSE c_manufacture_model_csr;
      END IF;
      IF  c_location_id_csr%ISOPEN THEN
        CLOSE c_location_id_csr;
      END IF;
      IF  c_asset_location_name_csr%ISOPEN THEN
        CLOSE c_asset_location_name_csr;
      END IF;
      IF  c_asset_year_manufactured_csr%ISOPEN THEN
        CLOSE c_asset_year_manufactured_csr;
      END IF;
      IF   c_installed_site_csr%ISOPEN THEN
        CLOSE c_installed_site_csr;
      END IF;
      IF  c_aging_bucket_name_csr%ISOPEN THEN
        CLOSE c_aging_bucket_name_csr;
      END IF;
      IF   c_cust_trx_type_csr%ISOPEN THEN
        CLOSE c_cust_trx_type_csr;
      END IF;
      IF   c_inventory_item_name_csr%ISOPEN THEN
        CLOSE c_inventory_item_name_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      IF  c_tcl_basic_csr%ISOPEN THEN
        CLOSE c_tcl_basic_csr;
      END IF;
      IF  c_k_lines_csr%ISOPEN THEN
        CLOSE c_k_lines_csr;
      END IF;
      IF  c_vendor_name_csr%ISOPEN THEN
        CLOSE c_vendor_name_csr;
      END IF;
      IF  c_manufacture_model_csr%ISOPEN THEN
        CLOSE c_manufacture_model_csr;
      END IF;
      IF  c_location_id_csr%ISOPEN THEN
        CLOSE c_location_id_csr;
      END IF;
      IF  c_asset_location_name_csr%ISOPEN THEN
        CLOSE c_asset_location_name_csr;
      END IF;
      IF  c_asset_year_manufactured_csr%ISOPEN THEN
        CLOSE c_asset_year_manufactured_csr;
      END IF;
      IF   c_installed_site_csr%ISOPEN THEN
        CLOSE c_installed_site_csr;
      END IF;
      IF  c_aging_bucket_name_csr%ISOPEN THEN
        CLOSE c_aging_bucket_name_csr;
      END IF;
      IF   c_cust_trx_type_csr%ISOPEN THEN
        CLOSE c_cust_trx_type_csr;
      END IF;
      IF   c_inventory_item_name_csr%ISOPEN THEN
        CLOSE c_inventory_item_name_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      IF  c_tcl_basic_csr%ISOPEN THEN
        CLOSE c_tcl_basic_csr;
      END IF;
      IF  c_k_lines_csr%ISOPEN THEN
        CLOSE c_k_lines_csr;
      END IF;
      IF  c_vendor_name_csr%ISOPEN THEN
        CLOSE c_vendor_name_csr;
      END IF;
      IF  c_manufacture_model_csr%ISOPEN THEN
        CLOSE c_manufacture_model_csr;
      END IF;
      IF  c_location_id_csr%ISOPEN THEN
        CLOSE c_location_id_csr;
      END IF;
      IF  c_asset_location_name_csr%ISOPEN THEN
        CLOSE c_asset_location_name_csr;
      END IF;
      IF  c_asset_year_manufactured_csr%ISOPEN THEN
        CLOSE c_asset_year_manufactured_csr;
      END IF;
      IF   c_installed_site_csr%ISOPEN THEN
        CLOSE c_installed_site_csr;
      END IF;
      IF  c_aging_bucket_name_csr%ISOPEN THEN
        CLOSE c_aging_bucket_name_csr;
      END IF;
      IF   c_cust_trx_type_csr%ISOPEN THEN
        CLOSE c_cust_trx_type_csr;
      END IF;
      IF   c_inventory_item_name_csr%ISOPEN THEN
        CLOSE c_inventory_item_name_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_tcl_sources;


  ---------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_tcl_sources
  --      Pre-reqs        : None
  --      Function        : Creates records for OKL_TXL_EXTENSION_V
  --                         This API will be called by Populate Sources
  --                         to do the bulk INSERTs of the Extension Line Sources
  --      Parameters      :
  --      IN              : p_trans_hdr_rec.source_id Required
  --                        p_trans_hdr_rec.source_table Required.
  --                          Value  G_TXL_CONTRACTS
  --      Version         : 1.0
  --      History         : Ravi Gooty created
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE populate_tcl_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_trans_hdr_rec             IN             tehv_rec_type
   ,p_acc_sources_tbl           IN             asev_tbl_type
   ,p_trans_line_tbl            IN             telv_tbl_type
   ,x_trans_line_tbl            OUT    NOCOPY  telv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version              CONSTANT NUMBER         := 1;
    l_api_name                 CONSTANT VARCHAR2(30)   := 'POPULATE_TCL_SOURCES';
    l_return_status            VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------------------------------
    -- Declare records: Extension Headers, Extension Lines
    ------------------------------------------------------------
    l_tel_tbl_tbl         tel_tbl_tbl_type;
    l_tel_tbl_tbl_out     tel_tbl_tbl_type;
    l_tell_tbl_in         tell_tbl_type;
    l_tell_tbl_in_base    tell_tbl_type;
    l_tel_tbl_in          tel_tbl_type;
    l_tel_tbl_out         tel_tbl_type;

    -- Performant Cursor to fetch all the Kle_ids in Order
    CURSOR c_tcl_tbl_csr (p_tcn_id NUMBER)
    IS
      SELECT   tcl.khr_id           khr_id
              ,tcl.kle_id           kle_id
              ,tcl.sty_id           sty_id
              ,tcl.bkt_id           bkt_id
              ,tcl.id               tcl_id
        FROM   okl_txl_cntrct_lns_all tcl
       WHERE   tcl.tcn_id = p_tcn_id
    ORDER BY   kle_id, sty_id, bkt_id;
    l_prev_tcl_rec    c_tcl_tbl_csr%ROWTYPE;
    l_curr_tcl_rec    c_tcl_tbl_csr%ROWTYPE;

    TYPE tcl_tbl_type IS TABLE OF c_tcl_tbl_csr%ROWTYPE INDEX BY BINARY_INTEGER;  -- Added by PRASJAIN Bug#6134235
    l_tcl_tbl       tcl_tbl_type;  -- Added by PRASJAIN Bug#6134235

    CURSOR c_tcn_basic_csr ( p_tcn_id NUMBER)
    IS
      SELECT   tcn.id                           tcn_id
              ,tcn.khr_id                       khr_id
              ,tcn.set_of_books_id              ledger_id
              ,try.accounting_event_class_code  accounting_event_class_code
        FROM   okl_trx_contracts_all  tcn
              ,okl_trx_types_b        try
       WHERE  tcn.id = p_tcn_id
         AND  tcn.try_id = try.id
         AND  try.accounting_event_class_code IS NOT NULL;
    l_tcn_basic_csr_rec    c_tcn_basic_csr%ROWTYPE;

    -- Record structures based on Cursor Definitions
    l_ledger_lang_rec               c_ledger_lang_csr%ROWTYPE;
    l_k_lines_rec                   c_k_lines_csr%ROWTYPE;
    l_vendor_name_csr_rec           c_vendor_name_csr%ROWTYPE;
    l_installed_site_csr_rec        c_installed_site_csr%ROWTYPE;
    l_inventory_item_name_csr_rec   c_inventory_item_name_csr%ROWTYPE;
    l_inventory_org_name_rec        c_org_name_csr%ROWTYPE;
    l_cust_trx_type_csr_rec         c_cust_trx_type_csr%ROWTYPE;
    l_location_id_csr_rec           c_location_id_csr%ROWTYPE;
    l_manufacture_model_csr_rec     c_manufacture_model_csr%ROWTYPE;
    l_asset_year_mfg_csr_rec        c_asset_year_manufactured_csr%ROWTYPE;
    l_asset_location_name_csr_rec   c_asset_location_name_csr%ROWTYPE;
    l_aging_bucket_name_csr_rec     c_aging_bucket_name_csr%ROWTYPE;
    l_inv_org_name_code_csr         c_org_name_code_csr%ROWTYPE;
    l_acc_sources_tbl               asev_tbl_type;
    l_acc_sources_rec               asev_rec_type;
    l_acc_sources_found             BOOLEAN;
    ags_index                       NUMBER;
    -- Local Variables
    tel_index             NUMBER  := 0;
    tcl_count             NUMBER  := 0;
    idx                   NUMBER  := 0;
    idx1                  NUMBER  := 0;
    tl_sources_in         NUMBER  := 1;
    l_capture_sources     VARCHAR2(3); -- Flag to decide whether to Capture Sources or Not !
    l_trans_line_tbl      telv_tbl_type;
    l_fetch_sources       BOOLEAN := FALSE;

    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug APOKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API okl_sla_acc_sources_pvt.POPULATE_TCL_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After Start Activity l_return_status ' || l_return_status );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_trans_hdr_rec.source_table <> G_TRX_CONTRACTS
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF p_trans_hdr_rec.header_extension_id IS NULL
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.HEADER_EXTENSION_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Assign the AGS Record to the Local Record Structure
    l_acc_sources_tbl := p_acc_sources_tbl;
    l_trans_line_tbl  := p_trans_line_tbl;
    -- Validation: Check whether the AGS Table is passed properly or not ..
    IF l_acc_sources_tbl.COUNT <= 0
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'ACCT_SOURCES.COUNT');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Assign the l_acc_sources_rec as the first one of the l_acc_sources_tbl
    --  so that we can reuse the Inventory Organization ID
    l_acc_sources_rec := l_acc_sources_tbl( l_acc_sources_tbl.FIRST );

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor  c_tcn_basic_csr, tcn_id = ' || TO_CHAR( p_trans_hdr_rec.source_id) );
    FOR t_rec IN c_tcn_basic_csr (p_tcn_id => p_trans_hdr_rec.source_id )
    LOOP
      l_tcn_basic_csr_rec := t_rec;
    END LOOP;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      ' l_tcn_basic_csr_rec.accounting_event_class_code=' || l_tcn_basic_csr_rec.accounting_event_class_code ||
      ' l_tcn_basic_csr_rec.ledger_id=' || to_char(l_tcn_basic_csr_rec.ledger_id) );

    IF l_tcn_basic_csr_rec.accounting_event_class_code IS NULL
    THEN
      -- accounting_event_class_code is missing
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'ACCOUNTING_EVENT_CLASS_CODE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Fetch the Ledger Language
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Picked Language | Ledger Language | USERENV Language p_ledger_id=' || TO_CHAR(l_tcn_basic_csr_rec.ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_tcn_basic_csr_rec.ledger_id )
    LOOP
      l_tell_tbl_in_base(tl_sources_in).language := t_rec.language_code;
      tl_sources_in := tl_sources_in + 1;
    END LOOP;

    -- Fetching Common Sources
    -- Populating MLS Sources at Transaction Line Level
    -- Populate Inventory Organization Name
    IF l_tcn_basic_csr_rec.accounting_event_class_code NOT IN (G_UPFRONT_TAX)
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '*** AGS Inventory Org ID used to fetch teh Inventory Organization Name: Org ID=' ||
      l_acc_sources_rec.inventory_org_id_pk2 );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '*** AGS Inventory Org ID used to fetch teh Inventory Organization Code : Org ID=' ||
      l_acc_sources_rec.inventory_org_id_pk2 );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_org_name_code_csr. p_org_id= ' || to_char(l_acc_sources_rec.inventory_org_id_pk2) );
      FOR t_rec IN c_org_name_code_csr(
                     p_org_id      => l_acc_sources_rec.inventory_org_id_pk2 )
      LOOP
        l_inv_org_name_code_csr := t_rec;
      END LOOP;

      FOR tl_sources_in IN l_tell_tbl_in_base.FIRST .. l_tell_tbl_in_base.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_org_name_csr. p_org_id= ' || to_char(l_acc_sources_rec.inventory_org_id_pk2) ||
          ' ledger_language=' || l_tell_tbl_in_base(tl_sources_in).language );
        FOR t_rec IN c_org_name_csr(
                        p_org_id      => l_acc_sources_rec.inventory_org_id_pk2
                       ,p_ledger_lang => l_tell_tbl_in_base(tl_sources_in).language )
        LOOP
          l_tell_tbl_in_base(tl_sources_in).inventory_org_name := t_rec.org_name;
        END LOOP;
      END LOOP;
    END IF;

    -- Fetch all the Transaction Lines for the given Transaction Header
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor  c_tcl_tbl_csr, tcn_id = ' || TO_CHAR( p_trans_hdr_rec.source_id) );
    -- Initialize the tel_index
    tel_index := 1;
    -- Initialize the tcl_count to ZERO
    tcl_count := 0;
    -- Start PRASJAIN Bug#6134235
    FOR t_rec IN c_tcl_tbl_csr( p_tcn_id => p_trans_hdr_rec.source_id )
    LOOP
      tcl_count := tcl_count + 1;
      l_tcl_tbl(tcl_count) := t_rec;
    END LOOP;
    -- End PRASJAIN Bug#6134235

    -- Start PRASJAIN Bug#6134235
    FOR idx IN l_tcl_tbl.FIRST .. l_tcl_tbl.LAST
    LOOP
      -- Logic Explanation:
      -- 1. Check for the Count of the Trx. Lines fetched from DB
      -- 2. Compare this count with the count of Trx. Lines passed to this API
      -- 3. If the count is same, then, capture sources for every Trx. Line
      --    otherwise, capture sources for only those transaction line, which have
      --    been passed by the Accounting Engine
      l_capture_sources := 'N';
      IF tcl_count = l_trans_line_tbl.COUNT
      THEN
        -- If count is same, then capture sources for every Transaction Detail Line
        l_capture_sources := 'Y';
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Case 1: Transaction Line Count in DB = Transaction Detail Line Count of the Input Param Table !' );
      ELSE
        idx1 := l_trans_line_tbl.FIRST;
        LOOP
          IF l_tcl_tbl(idx).tcl_id    = l_trans_line_tbl(idx1).source_id
          THEN
            l_capture_sources := 'Y';
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Case 2: Populate Sources has been asked to capture sources for the Current Transaction Detail by Accounting Engine ' ||
              ' TCL ID = ' || TO_CHAR( l_trans_line_tbl(idx1).source_id ) );
          END IF;
          -- Exit when this is the Last Record or the Transaction Details has been found
          EXIT WHEN ( idx1 = l_trans_line_tbl.LAST )  -- When reached End of the Table
                 OR ( l_capture_sources = 'Y'     ); -- Or When the TXD has been found
          -- Increment the rxl_index
          idx1 := l_trans_line_tbl.NEXT( idx1 );
        END LOOP; -- Loop on l_trans_line_tbl ..
      END IF; --  IF tcl_count = l_trans_line_tbl.COUNT ..

      IF (l_capture_sources = 'Y')
      THEN
        -- Store the iterative recrod to the Local variable
        l_curr_tcl_rec := l_tcl_tbl(idx);
        -- End PRASJAIN Bug#6134235

        -- Fetch the Sources using the cursors only if
        --  If this the First Transaction Line (Or)
        --  The previous Transation Line kle_id is different than the Current Transaction Line
        l_fetch_sources := FALSE;
        IF tel_index = 1
        THEN
          l_fetch_sources := TRUE;
        ELSE
          IF l_curr_tcl_rec.kle_id <> l_prev_tcl_rec.kle_id
          THEN
            l_fetch_sources := TRUE;
          END IF;
        END IF;

        IF l_fetch_sources
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            '**** Need to fetch the Sources Afresh ****** ' ||
            'Current Kle_id = ' || l_curr_tcl_rec.kle_id || '| Previous Kle_id = ' || l_prev_tcl_rec.kle_id );
        ELSE
          -- Store Previously Fetched Transaction Related Sources to the Current Transaction Line
--          l_tel_tbl_tbl(tel_index) := l_tel_tbl_tbl(tel_index - 1);
          l_tel_tbl_in(tel_index) := l_tel_tbl_in(tel_index - 1);
        END IF;
        -- For a given transaction Line fetch the corresponding Account Generator Sources
        -- Logic:
        --   Loop on the l_acc_sources_tbl till we find that
        --     l_acc_sources_tbl.source_id = l_curr_tcl_rec.tcl_id
        --   If the AGS record has been found assign it to l_acc_sources_rec
        --     else raise an exception.
        l_acc_sources_found := FALSE;
        l_acc_sources_rec   := NULL;
        ags_index := l_acc_sources_tbl.FIRST;
        LOOP
          IF l_acc_sources_tbl(ags_index).source_id = l_curr_tcl_rec.tcl_id
          THEN
            l_acc_sources_found := TRUE;
            l_acc_sources_rec := l_acc_sources_tbl(ags_index);
          END IF;
          EXIT WHEN l_acc_sources_found OR ( ags_index = l_acc_sources_tbl.LAST );
          ags_index := l_acc_sources_tbl.NEXT(ags_index);
        END LOOP;
        -- If the AGS Index is not found then return error
        IF l_acc_sources_found = FALSE
        THEN
          -- accounting_event_class_code is missing
          OKL_API.set_message(
             p_app_name      => G_APP_NAME
            ,p_msg_name      => G_INVALID_VALUE
            ,p_token1        => G_COL_NAME_TOKEN
            ,p_token1_value  => 'AGS_SOURCES.SOURCE_ID');
          l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF; -- IF l_acc_sources_found = FALSE
        -- Override the Source ID, Table and other related sources
        l_tel_tbl_in(tel_index).source_id    := l_curr_tcl_rec.tcl_id;
        l_tel_tbl_in(tel_index).source_table := G_TXL_CONTRACTS;
        l_tel_tbl_in(tel_index).teh_id       := p_trans_hdr_rec.header_extension_id;

        l_tell_tbl_in := l_tell_tbl_in_base;

        IF l_tcn_basic_csr_rec.accounting_event_class_code IN
           (G_BOOKING, G_REBOOK, G_RE_LEASE,  G_ACCRUAL, G_MISCELLANEOUS)
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Executing the Cursor c_cust_trx_type_csr rec_trx_types_pk=' || to_char(l_acc_sources_rec.rec_trx_types_pk) );
          FOR t_rec IN  c_cust_trx_type_csr( p_trx_id => l_acc_sources_rec.rec_trx_types_pk )
          LOOP
            l_cust_trx_type_csr_rec := t_rec;
            l_tel_tbl_in(tel_index).recievables_trx_type_name  :=l_cust_trx_type_csr_rec.trx_name;
          END LOOP; -- c_cust_trx_type_csr
        END IF;

        -- Store the Inventory Organization Code
        l_tel_tbl_in(tel_index).inventory_org_code := l_inv_org_name_code_csr.org_name;

        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          ' l_curr_tcl_rec.tcl_id=' || to_char(l_curr_tcl_rec.tcl_id) ||
          ' l_curr_tcl_rec.khr_id=' || to_char(l_curr_tcl_rec.khr_id) ||
          ' l_curr_tcl_rec.kle_id=' || to_char(l_curr_tcl_rec.kle_id) ||
          ' l_curr_tcl_rec.bkt_id=' || to_char(l_curr_tcl_rec.bkt_id) ||
          ' l_curr_tcl_rec.sty_id=' || to_char(l_curr_tcl_rec.sty_id) );

        -- If kle_id IS NOT NULL and l_fetch_sources is TRUE then ..
        IF l_fetch_sources AND
           l_curr_tcl_rec.kle_id IS NOT NULL
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Executing the curosr c_k_lines_csr. kle_id= ' || to_char(l_curr_tcl_rec.kle_id) );
          FOR t_rec IN  c_k_lines_csr (l_curr_tcl_rec.kle_id)
          LOOP
            l_k_lines_rec   := t_rec;
            l_tel_tbl_in(tel_index).contract_line_type       := l_k_lines_rec.contract_line_type;
            IF l_tcn_basic_csr_rec.accounting_event_class_code IN
                ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_PRINCIPAL_ADJUSTMENT )
            THEN
              l_tel_tbl_in(tel_index).fee_type_code          := l_k_lines_rec.fee_type;
            END IF;
            IF l_tcn_basic_csr_rec.accounting_event_class_code IN
                 ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_PRINCIPAL_ADJUSTMENT,
                   G_MISCELLANEOUS, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET )
            THEN
              l_tel_tbl_in(tel_index).asset_number           := l_k_lines_rec.asset_number;
            END IF;
            IF l_tcn_basic_csr_rec.accounting_event_class_code IN
               (G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET)
            THEN
              l_tel_tbl_in(tel_index).contract_line_number   := l_k_lines_rec.line_number;
            END IF;
            IF l_tcn_basic_csr_rec.accounting_event_class_code IN
                 ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_RECEIPT_APPLICATION,
                   G_PRINCIPAL_ADJUSTMENT, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET )
            THEN
              l_tel_tbl_in(tel_index).asset_delivered_date   := l_k_lines_rec.date_delivery_expected;
            END IF;
          END LOOP; -- c_k_lines_csr

          IF l_tcn_basic_csr_rec.accounting_event_class_code IN
              (G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_PRINCIPAL_ADJUSTMENT,
                G_MISCELLANEOUS, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET)
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Executing the Cursor c_location_id_csr. kle_id= ' || to_char(l_curr_tcl_rec.kle_id) ||
              ' khr_id=' || to_char(l_tcn_basic_csr_rec.khr_id) );
            OPEN c_location_id_csr(l_curr_tcl_rec.kle_id,l_tcn_basic_csr_rec.khr_id );
            FETCH c_location_id_csr into l_location_id_csr_rec;
            CLOSE c_location_id_csr;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Executing the Cursor l_vendor_name_csr_rec. kle_id= ' || to_char(l_curr_tcl_rec.kle_id) ||
              ' khr_id=' || to_char(l_tcn_basic_csr_rec.khr_id) );
            FOR t_rec  IN c_vendor_name_csr(
                             l_curr_tcl_rec.kle_id
                            ,l_tcn_basic_csr_rec.khr_id)
            LOOP
              l_vendor_name_csr_rec := t_rec;
              l_tel_tbl_in(tel_index).asset_vendor_name   := l_vendor_name_csr_rec.vendor_name;
	      -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
              l_tel_tbl_in(tel_index).asset_vendor_id   := l_vendor_name_csr_rec.vendor_id;
              -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
            END LOOP;  -- c_vendor_name_csr
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Executing the Cursor c_asset_location_name_csr. location_id=' ||
              TO_CHAR(l_location_id_csr_rec.location_id) );
            FOR t_rec  IN  c_asset_location_name_csr(l_location_id_csr_rec.location_id)
            LOOP
              l_asset_location_name_csr_rec := t_rec;
              l_tel_tbl_in(tel_index).fixed_asset_location_name := l_asset_location_name_csr_rec.asset_location_name;
            END LOOP;  -- c_asset_location_name_csr
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Executing the Cursor l_installed_site_csr_rec. kle_id= ' || to_char(l_curr_tcl_rec.kle_id) ||
              ' khr_id=' || to_char(l_tcn_basic_csr_rec.khr_id) );
            FOR t_rec  IN  c_installed_site_csr(
                                                l_curr_tcl_rec.kle_id
                                               ,l_tcn_basic_csr_rec.khr_id)
            LOOP
              l_installed_site_csr_rec := t_rec;
              l_tel_tbl_in(tel_index).installed_site_id   := l_installed_site_csr_rec.installed_site_id;
            END LOOP;  -- c_installed_site_csr
          END IF;  -- accounting_event_class_code for 7 events

          IF l_tcn_basic_csr_rec.accounting_event_class_code IN
                 ( G_TERMINATION, G_EVERGREEN, G_ACCRUAL, G_RECEIPT_APPLICATION,
                   G_PRINCIPAL_ADJUSTMENT, G_ASSET_DISPOSITION, G_UPFRONT_TAX, G_SPLIT_ASSET )
          THEN
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Executing the Cursor c_manufacture_model_csr. kle_id= ' || to_char(l_curr_tcl_rec.kle_id) ||
              ' khr_id=' || to_char(l_tcn_basic_csr_rec.khr_id) );
            FOR t_rec IN  c_manufacture_model_csr (
                            l_curr_tcl_rec.kle_id
                           ,l_tcn_basic_csr_rec.khr_ID)
            LOOP
              l_manufacture_model_csr_rec := t_rec;
              IF l_tcn_basic_csr_rec.accounting_event_class_code NOT LIKE G_ACCRUAL
              THEN
                l_tel_tbl_in(tel_index).asset_manufacturer_name    :=  l_manufacture_model_csr_rec.manufacturer_name;
              END IF;
              l_tel_tbl_in(tel_index).asset_model_number         :=  l_manufacture_model_csr_rec.model_number;
              put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
                'Executing the Cursor c_asset_year_manufactured_csr. kle_id= ' || to_char(l_curr_tcl_rec.kle_id) ||
                ' khr_id=' || to_char(l_tcn_basic_csr_rec.khr_id) );
              FOR  t_year_man_rec IN c_asset_year_manufactured_csr (
                                                 l_curr_tcl_rec.kle_id
                                                ,l_tcn_basic_csr_rec.khr_id)
              LOOP
                l_asset_year_mfg_csr_rec := t_year_man_rec;
                l_tel_tbl_in(tel_index).asset_year_manufactured := l_asset_year_mfg_csr_rec.Year_of_manufacture;
              END LOOP; -- c_asset_year_manufactured_csr
              IF l_tcn_basic_csr_rec.accounting_event_class_code NOT IN
                     ( G_RECEIPT_APPLICATION, G_PRINCIPAL_ADJUSTMENT, G_ACCRUAL, G_MISCELLANEOUS )
              THEN
                l_tel_tbl_in(tel_index).asset_category_name        :=  l_manufacture_model_csr_rec.asset_category_name;
              END IF;
            END LOOP;  -- c_manufacture_model_csr
          END IF;  -- accounting_event_class_code for 5 events
        END IF; -- IF l_tcn_basic_csr_rec.kle_id IS NOT NULL

        IF l_tcn_basic_csr_rec.accounting_event_class_code IN (G_ACCRUAL,G_ASSET_DISPOSITION, G_SPLIT_ASSET)
        THEN
          FOR tl_sources_in IN l_tell_tbl_in.FIRST .. l_tell_tbl_in.LAST
          LOOP
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Executing the Cursor c_asset_year_manufactured_csr. p_inventory_item_id_pk1= ' ||
              to_char(l_acc_sources_rec.inventory_item_id_pk1) || ' p_inventory_org_id_pk2=' ||
              to_char(l_acc_sources_rec.inventory_org_id_pk2) || ' ledger_language=' ||
              l_tell_tbl_in(tl_sources_in).language );
            FOR t_rec IN c_inventory_item_name_csr(
                         p_inventory_item_id_pk1 => l_acc_sources_rec.inventory_item_id_pk1
                        ,p_inventory_org_id_pk2  => l_acc_sources_rec.inventory_org_id_pk2
                        ,p_ledger_language       => l_tell_tbl_in(tl_sources_in).language)
            LOOP
              l_inventory_item_name_csr_rec := t_rec;
              l_tell_tbl_in(tl_sources_in).inventory_item_name      := l_inventory_item_name_csr_rec.description;
              l_tel_tbl_in(tel_index).inventory_item_name_code := l_inventory_item_name_csr_rec.b_description;
            END LOOP;
          END LOOP;
        END IF; -- IF l_tcn_basic_csr_rec.accounting_event_class_code IN (G_ACCRUAL,G_ASSET_DISPOSITION, G_SPLIT_ASSET)

        IF l_tcn_basic_csr_rec.accounting_event_class_code IN (G_GLP)
        THEN
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Executing cursor c_aging_bucket_name_csr bkt_id=' || l_curr_tcl_rec.bkt_id );
          FOR t_rec IN c_aging_bucket_name_csr(l_curr_tcl_rec.bkt_id)
          LOOP
            l_aging_bucket_name_csr_rec := t_rec;
            l_tel_tbl_in(tel_index).aging_bucket_name  :=l_aging_bucket_name_csr_rec.bucket_name;
          END LOOP;  -- c_aging_bucket_name_csr
        END IF;

        -- Assigning the Memo Indicator to the Extension Line Record structure ..
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          '** AGS Memo Flag ' || l_acc_sources_rec.memo_yn );
        l_tel_tbl_in(tel_index).memo_flag := l_acc_sources_rec.memo_yn;

        -- If Log is enabled, print all the sources fetched.
        IF (l_debug_enabled='Y' AND is_debug_statement_on)
        THEN
          write_ext_line_to_log(
            p_tel_rec  => l_tel_tbl_in(tel_index)
           ,p_tell_tbl => l_tell_tbl_in
           ,p_module   => l_module);
        END IF;

        -- Store khr_id, kle_id, sty_id, bkt_id of the current transaction line.
        -- This recrod will be used during comparision from next iteration onwards
        l_prev_tcl_rec := l_tcl_tbl(idx);
        -- Build the record strucutre now ..
        l_tel_tbl_tbl(tel_index).tel_rec  := l_tel_tbl_in(tel_index);
        l_tel_tbl_tbl(tel_index).tell_tbl := l_tell_tbl_in; -- Translatable Table capturing sources
        -- Increment the tel_index
        tel_index := tel_index + 1;
      END IF;
    END LOOP;


    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_TRX_EXTENSION_PVT.create_txl_extension API.' );

    okl_trx_extension_pvt.create_txl_extension(
       p_api_version     => p_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_tel_tbl_tbl     => l_tel_tbl_tbl
      ,x_tel_tbl_tbl     => l_tel_tbl_tbl_out
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_trx_extension_pvt.create_txl_extension-tbl. l_return_status ' || l_return_status );
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Return the values
    x_trans_line_tbl := p_trans_line_tbl;  --Added PRASJAIN Bug#6134235
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END okl_sla_acc_sources_pvt.POPULATE_TCL_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      IF  c_tcl_tbl_csr%ISOPEN THEN
        CLOSE c_tcl_tbl_csr;
      END IF;
      IF  c_k_lines_csr%ISOPEN THEN
        CLOSE c_k_lines_csr;
      END IF;
      IF  c_vendor_name_csr%ISOPEN THEN
        CLOSE c_vendor_name_csr;
      END IF;
      IF  c_manufacture_model_csr%ISOPEN THEN
        CLOSE c_manufacture_model_csr;
      END IF;
      IF  c_location_id_csr%ISOPEN THEN
        CLOSE c_location_id_csr;
      END IF;
      IF  c_asset_location_name_csr%ISOPEN THEN
        CLOSE c_asset_location_name_csr;
      END IF;
      IF  c_asset_year_manufactured_csr%ISOPEN THEN
        CLOSE c_asset_year_manufactured_csr;
      END IF;
      IF   c_installed_site_csr%ISOPEN THEN
        CLOSE c_installed_site_csr;
      END IF;
      IF  c_aging_bucket_name_csr%ISOPEN THEN
        CLOSE c_aging_bucket_name_csr;
      END IF;
      IF   c_cust_trx_type_csr%ISOPEN THEN
        CLOSE c_cust_trx_type_csr;
      END IF;
      IF   c_inventory_item_name_csr%ISOPEN THEN
        CLOSE c_inventory_item_name_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      IF  c_tcl_tbl_csr%ISOPEN THEN
        CLOSE c_tcl_tbl_csr;
      END IF;
      IF  c_k_lines_csr%ISOPEN THEN
        CLOSE c_k_lines_csr;
      END IF;
      IF  c_vendor_name_csr%ISOPEN THEN
        CLOSE c_vendor_name_csr;
      END IF;
      IF  c_manufacture_model_csr%ISOPEN THEN
        CLOSE c_manufacture_model_csr;
      END IF;
      IF  c_location_id_csr%ISOPEN THEN
        CLOSE c_location_id_csr;
      END IF;
      IF  c_asset_location_name_csr%ISOPEN THEN
        CLOSE c_asset_location_name_csr;
      END IF;
      IF  c_asset_year_manufactured_csr%ISOPEN THEN
        CLOSE c_asset_year_manufactured_csr;
      END IF;
      IF   c_installed_site_csr%ISOPEN THEN
        CLOSE c_installed_site_csr;
      END IF;
      IF  c_aging_bucket_name_csr%ISOPEN THEN
        CLOSE c_aging_bucket_name_csr;
      END IF;
      IF   c_cust_trx_type_csr%ISOPEN THEN
        CLOSE c_cust_trx_type_csr;
      END IF;
      IF   c_inventory_item_name_csr%ISOPEN THEN
        CLOSE c_inventory_item_name_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      IF  c_tcl_tbl_csr%ISOPEN THEN
        CLOSE c_tcl_tbl_csr;
      END IF;
      IF  c_k_lines_csr%ISOPEN THEN
        CLOSE c_k_lines_csr;
      END IF;
      IF  c_vendor_name_csr%ISOPEN THEN
        CLOSE c_vendor_name_csr;
      END IF;
      IF  c_manufacture_model_csr%ISOPEN THEN
        CLOSE c_manufacture_model_csr;
      END IF;
      IF  c_location_id_csr%ISOPEN THEN
        CLOSE c_location_id_csr;
      END IF;
      IF  c_asset_location_name_csr%ISOPEN THEN
        CLOSE c_asset_location_name_csr;
      END IF;
      IF  c_asset_year_manufactured_csr%ISOPEN THEN
        CLOSE c_asset_year_manufactured_csr;
      END IF;
      IF   c_installed_site_csr%ISOPEN THEN
        CLOSE c_installed_site_csr;
      END IF;
      IF  c_aging_bucket_name_csr%ISOPEN THEN
        CLOSE c_aging_bucket_name_csr;
      END IF;
      IF   c_cust_trx_type_csr%ISOPEN THEN
        CLOSE c_cust_trx_type_csr;
      END IF;
      IF   c_inventory_item_name_csr%ISOPEN THEN
        CLOSE c_inventory_item_name_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_tcl_sources;

  ---------------------------------------------------------------------------
  -- Start of comments
  -- API name    : populate_sources
  -- Pre-reqs    : None
  -- Function    : Use this API to populate sources at the Transaction Header
  --                level and at the Transaction Line level too.
  -- Parameters  :
  -- IN          : p_source_id  IN NUMBER  Required
  --                  Pass Transaction Header id.
  --               p_source_hdr_table IN VARCHAR2 Required
  --                 Pass the table name of the Transaction Header.
  --                 Eg. OKL_TRX_CONTRACTS, OKL_TRX_ASSETS ..
  --               p_trans_line_tbl  trans_line_tbl_type Required.
  --                 source_line_id     NUMBER Required
  --                   Pass the Transaction Line id
  --                 source_line_table  VARCHAR2(30) Required
  --                   Pass the table name of the Transaction Table.
  --                   Eg. OKL_TXL_CNTRCT_LNS ..
  -- Version     : 1.0
  -- History     : Ravindranath Gooty created
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_trans_hdr_rec             IN             tehv_rec_type
   ,p_trans_line_tbl            IN             telv_tbl_type
   ,p_acc_sources_tbl           IN             asev_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'POPULATE_SOURCES-OKL';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Local Variables for enabling the Debug Statements
    l_trans_hdr_rec       tehv_rec_type;
    l_acc_sources_tbl     asev_tbl_type;
    l_trans_line_tbl      telv_tbl_type; -- Added by PRASJAIN Bug#6134235
    x_trans_line_tbl      telv_tbl_type; -- Added by PRASJAIN Bug#6134235

    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug APOKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API okl_sla_acc_sources_pvt.POPULATE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Copy the input parameters to the local variables
    l_trans_hdr_rec   := p_trans_hdr_rec;
    l_acc_sources_tbl := p_acc_sources_tbl;
    l_trans_line_tbl  := p_trans_line_tbl; -- Added by PRASJAIN Bug#6134235
    IF l_acc_sources_tbl.COUNT <= 0
    THEN
      -- Raise an error message saying that the Sources should be passed !
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'P_ACC_SOURCES_TBL.COUNT');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Input Parameters p_source_hdr_id=' || to_char(l_trans_hdr_rec.source_id) || ' Header Table=' || l_trans_hdr_rec.source_table );
    IF l_trans_hdr_rec.source_table = G_TRX_CONTRACTS
    THEN
      -- Calling populate_tcn_sources for OKL Transactions..
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'Calling the populate_tcn_sources' );
      populate_tcn_sources(
         p_api_version     => l_api_version
        ,p_init_msg_list   => p_init_msg_list
        ,px_trans_hdr_rec  => l_trans_hdr_rec
        ,p_acc_sources_rec => l_acc_sources_tbl( l_acc_sources_tbl.FIRST )
        ,x_return_status   => l_return_status
        ,x_msg_count       => x_msg_count
        ,x_msg_data        => x_msg_data );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'After populate_tcn_sources: l_return_status ' || l_return_status );
    ELSE
      -- Return with an error message
      OKL_API.set_message(
        p_app_name      => G_APP_NAME
       ,p_msg_name      => G_INVALID_VALUE
       ,p_token1        => G_COL_NAME_TOKEN
       ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After populate_tcn_sources: HEADER_EXTENSION_ID= ' || l_trans_hdr_rec.header_extension_id );
    -- Call the Populate TCL Sources API to populate the Transaction Line Level Sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Before the Call to the Populate_tcl_sources_tbl version');
    populate_tcl_sources(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,p_trans_hdr_rec   => l_trans_hdr_rec
      ,p_acc_sources_tbl => l_acc_sources_tbl
      ,p_trans_line_tbl  => l_trans_line_tbl -- Added by PRASJAIN Bug#6134235
      ,x_trans_line_tbl  => x_trans_line_tbl -- Added by PRASJAIN Bug#6134235
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After the Call to the Populate_tcl_sources_tbl version' || l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END okl_sla_acc_sources_pvt.POPULATE_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_sources;

  PROCEDURE delete_trx_extension(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_trans_hdr_rec             IN             tehv_rec_type
   ,x_trans_line_tbl            OUT    NOCOPY  telv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'DELETE_TRX_EXTENSION';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    l_telv_tbl         okl_tel_pvt.telv_tbl_type;
    tel_index          BINARY_INTEGER;
    l_trans_hdr_rec    tehv_rec_type;
    -- Cursor Definitions
    CURSOR get_txl_ext_hdr_id( p_trx_hdr_id  NUMBER, p_trx_hdr_table VARCHAR2)
    IS
      SELECT   teh.header_extension_id  header_extension_id
        FROM   OKL_TRX_EXTENSION_B teh
       WHERE  teh.source_id = p_trx_hdr_id
         AND  teh.source_table = p_trx_hdr_table;

    CURSOR get_txl_ext_line_ids( p_teh_id  NUMBER)
    IS
      SELECT   tel.line_extension_id  line_extension_id
              ,tel.source_id          source_id
              ,tel.source_table       source_table
        FROM   OKL_TXL_EXTENSION_B tel
       WHERE  tel.teh_id = p_teh_id;
    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.DELETE_TRX_EXTENSION');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual Logic Starts Here ..
    l_trans_hdr_rec := p_trans_hdr_rec;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Source ID=' || to_char(l_trans_hdr_rec.source_id) || 'Source Header Table=' || l_trans_hdr_rec.source_table );
    IF ( l_trans_hdr_rec.source_id = OKL_API.G_MISS_NUM or l_trans_hdr_rec.source_id IS NULL )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF ( l_trans_hdr_rec.source_table = OKL_API.G_MISS_CHAR or l_trans_hdr_rec.source_table IS NULL
        OR l_trans_hdr_rec.source_table NOT IN ( G_TRX_CONTRACTS) )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Fetch the Extension Header ID by executing cursor get_txl_ext_hdr_id' );
    FOR t_rec IN get_txl_ext_hdr_id(
                    p_trx_hdr_id    => l_trans_hdr_rec.source_id
                   ,p_trx_hdr_table => l_trans_hdr_rec.source_table)
    LOOP
      l_trans_hdr_rec.header_extension_id := t_rec.header_extension_id;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Extension Header ID To be Deleted='  || TO_CHAR(l_trans_hdr_rec.header_extension_id));
    -- Fetch the Transaction Extension Line IDs to be deleted
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Extension Line ID(s) To be Deleted=');
    tel_index := 1;
    FOR t_rec IN get_txl_ext_line_ids( p_teh_id  => l_trans_hdr_rec.header_extension_id)
    LOOP
      l_telv_tbl(tel_index).line_extension_id  := t_rec.line_extension_id;
      l_telv_tbl(tel_index).source_id          := t_rec.source_id;
      l_telv_tbl(tel_index).source_table       := t_rec.source_table;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'LINE_EXTENSION_ID[' || tel_index || '] = ' || TO_CHAR(l_telv_tbl(tel_index).line_extension_id) );
      -- Increment i
      tel_index := tel_index + 1;
    END LOOP; -- End get_trans_line_ids
    -- Store the Transaction Line IDs and Line Source Tables so as to return back
    x_trans_line_tbl := l_telv_tbl;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling the okl_trx_extension_pvt.delete_trx_extension. HEADER_EXTENSION_ID = ' ||
      TO_CHAR(l_trans_hdr_rec.header_extension_id) );
    okl_trx_extension_pvt.delete_trx_extension(
       p_api_version     => p_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_tehv_rec        => l_trans_hdr_rec  -- Initalized with the HEADER_EXTENSION_ID
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After executing the okl_trx_extension_pvt.delete_trx_extension l_return_status' || l_return_status );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.DELETE_TRX_EXTENSION');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END delete_trx_extension;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : write_khr_sources_to_log
  --      Pre-reqs        : None
  --      Function        : log captured khr sources for FA/AR/AP OKL Transactions
  --      Parameters      :
  --      IN              : p_khr_source_rec     khr_source_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------

  PROCEDURE write_khr_sources_to_log(
    p_khr_source_rec  IN   khr_source_rec_type
   ,p_module          IN   fnd_log_messages.module%TYPE)
  AS
  BEGIN
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ID                  =' || p_khr_source_rec.KHR_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_NUMBER         =' || p_khr_source_rec.CONTRACT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_STATUS         =' || p_khr_source_rec.CONTRACT_STATUS );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUSTOMER_NAME           =' || p_khr_source_rec.CUSTOMER_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUSTOMER_ACCOUNT_NUMBER =' || p_khr_source_rec.CUSTOMER_ACCOUNT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_CURRENCY_CODE  =' || p_khr_source_rec.CONTRACT_CURRENCY_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_EFFECTIVE_FROM =' || p_khr_source_rec.CONTRACT_EFFECTIVE_FROM );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'PRODUCT_NAME            =' || p_khr_source_rec.PRODUCT_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'BOOK_CLASSIFICATION_CODE=' || p_khr_source_rec.BOOK_CLASSIFICATION_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'TAX_OWNER_CODE          =' || p_khr_source_rec.TAX_OWNER_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'REV_REC_METHOD_CODE     =' || p_khr_source_rec.REV_REC_METHOD_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INT_CALC_METHOD_CODE    =' || p_khr_source_rec.INT_CALC_METHOD_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'VENDOR_PROGRAM_NUMBER   =' || p_khr_source_rec.VENDOR_PROGRAM_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONVERTED_NUMBER        =' || p_khr_source_rec.CONVERTED_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONVERTED_ACCOUNT_FLAG  =' || p_khr_source_rec.CONVERTED_ACCOUNT_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSIGNABLE_FLAG         =' || p_khr_source_rec.ASSIGNABLE_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'PO_ORDER_NUMBER         =' || p_khr_source_rec.PO_ORDER_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ACCRUAL_OVERRIDE_FLAG   =' || p_khr_source_rec.ACCRUAL_OVERRIDE_FLAG );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RENT_IA_CONTRACT_NUMBER =' || p_khr_source_rec.RENT_IA_CONTRACT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RENT_IA_PRODUCT_NAME    =' || p_khr_source_rec.RENT_IA_PRODUCT_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RENT_IA_ACCOUNTING_CODE =' || p_khr_source_rec.RENT_IA_ACCOUNTING_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RES_IA_CONTRACT_NUMBER  =' || p_khr_source_rec.RES_IA_CONTRACT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RES_IA_PRODUCT_NAME     =' || p_khr_source_rec.RES_IA_PRODUCT_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'RES_IA_ACCOUNTING_CODE  =' || p_khr_source_rec.RES_IA_ACCOUNTING_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE_CATEGORY  =' || p_khr_source_rec.KHR_ATTRIBUTE_CATEGORY );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE1          =' || p_khr_source_rec.KHR_ATTRIBUTE1 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE2          =' || p_khr_source_rec.KHR_ATTRIBUTE2 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE3          =' || p_khr_source_rec.KHR_ATTRIBUTE3 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE4          =' || p_khr_source_rec.KHR_ATTRIBUTE4 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE5          =' || p_khr_source_rec.KHR_ATTRIBUTE5 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE6          =' || p_khr_source_rec.KHR_ATTRIBUTE6 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE7          =' || p_khr_source_rec.KHR_ATTRIBUTE7 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE8          =' || p_khr_source_rec.KHR_ATTRIBUTE8 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE9          =' || p_khr_source_rec.KHR_ATTRIBUTE9 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE10         =' || p_khr_source_rec.KHR_ATTRIBUTE10 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE11         =' || p_khr_source_rec.KHR_ATTRIBUTE11 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE12         =' || p_khr_source_rec.KHR_ATTRIBUTE12 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE13         =' || p_khr_source_rec.KHR_ATTRIBUTE13 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE14         =' || p_khr_source_rec.KHR_ATTRIBUTE14 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ATTRIBUTE15         =' || p_khr_source_rec.KHR_ATTRIBUTE15 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE_CATEGORY =' || p_khr_source_rec.CUST_ATTRIBUTE_CATEGORY );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE1         =' || p_khr_source_rec.CUST_ATTRIBUTE1 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE2         =' || p_khr_source_rec.CUST_ATTRIBUTE2 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE3         =' || p_khr_source_rec.CUST_ATTRIBUTE3 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE4         =' || p_khr_source_rec.CUST_ATTRIBUTE4 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE5         =' || p_khr_source_rec.CUST_ATTRIBUTE5 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE6         =' || p_khr_source_rec.CUST_ATTRIBUTE6 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE7         =' || p_khr_source_rec.CUST_ATTRIBUTE7 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE8         =' || p_khr_source_rec.CUST_ATTRIBUTE8 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE9         =' || p_khr_source_rec.CUST_ATTRIBUTE9 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE10        =' || p_khr_source_rec.CUST_ATTRIBUTE10 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE11        =' || p_khr_source_rec.CUST_ATTRIBUTE11 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE12        =' || p_khr_source_rec.CUST_ATTRIBUTE12 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE13        =' || p_khr_source_rec.CUST_ATTRIBUTE13 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE14        =' || p_khr_source_rec.CUST_ATTRIBUTE14 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CUST_ATTRIBUTE15        =' || p_khr_source_rec.CUST_ATTRIBUTE15 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'CONTRACT_STATUS_CODE    =' || p_khr_source_rec.CONTRACT_STATUS_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_NUMBER     =' || p_khr_source_rec.INV_AGRMNT_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_EFFECTIVE_FROM =' || p_khr_source_rec.INV_AGRMNT_EFFECTIVE_FROM );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_PRODUCT_NAME   =' || p_khr_source_rec.INV_AGRMNT_PRODUCT_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_CURRENCY_CODE  =' || p_khr_source_rec.INV_AGRMNT_CURRENCY_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_SYND_CODE      =' || p_khr_source_rec.INV_AGRMNT_SYND_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_POOL_NUMBER    =' || p_khr_source_rec.INV_AGRMNT_POOL_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_STATUS_CODE    =' || p_khr_source_rec.INV_AGRMNT_STATUS_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'INV_AGRMNT_STATUS         =' || p_khr_source_rec.INV_AGRMNT_STATUS );
    write_to_log(FND_LOG.LEVEL_STATEMENT,P_MODULE,'SCS_CODE                  =' || p_khr_source_rec.SCS_CODE );
  END write_khr_sources_to_log;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : write_kle_sources_to_log
  --      Pre-reqs        : None
  --      Function        : log captured kle sources for FA/AR/AP OKL Transactions
  --      Parameters      :
  --      IN              : p_kle_source_rec     kle_source_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------

  PROCEDURE write_kle_sources_to_log(
               p_kle_source_rec       IN      kle_source_rec_type
              ,p_module               IN      fnd_log_messages.module%TYPE)
  AS
  BEGIN
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KHR_ID                    =' || p_kle_source_rec.KHR_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'KLE_ID                    =' || p_kle_source_rec.KLE_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_NUMBER              =' || p_kle_source_rec.ASSET_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'CONTRACT_LINE_NUMBER      =' || p_kle_source_rec.CONTRACT_LINE_NUMBER );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'ASSET_VENDOR_NAME         =' || p_kle_source_rec.ASSET_VENDOR_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'INSTALLED_SITE_ID         =' || p_kle_source_rec.INSTALLED_SITE_ID );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'FIXED_ASSET_LOCATION_NAME =' || p_kle_source_rec.FIXED_ASSET_LOCATION_NAME );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_TYPE_CODE            =' || p_kle_source_rec.LINE_TYPE_CODE );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE_CATEGORY   =' || p_kle_source_rec.LINE_ATTRIBUTE_CATEGORY );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE1           =' || p_kle_source_rec.LINE_ATTRIBUTE1 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE2           =' || p_kle_source_rec.LINE_ATTRIBUTE2 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE3           =' || p_kle_source_rec.LINE_ATTRIBUTE3 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE4           =' || p_kle_source_rec.LINE_ATTRIBUTE4 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE5           =' || p_kle_source_rec.LINE_ATTRIBUTE5 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE6           =' || p_kle_source_rec.LINE_ATTRIBUTE6 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE7           =' || p_kle_source_rec.LINE_ATTRIBUTE7 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE8           =' || p_kle_source_rec.LINE_ATTRIBUTE8 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE9           =' || p_kle_source_rec.LINE_ATTRIBUTE9 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE10          =' || p_kle_source_rec.LINE_ATTRIBUTE10 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE11          =' || p_kle_source_rec.LINE_ATTRIBUTE11 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE12          =' || p_kle_source_rec.LINE_ATTRIBUTE12 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE13          =' || p_kle_source_rec.LINE_ATTRIBUTE13 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE14          =' || p_kle_source_rec.LINE_ATTRIBUTE14 );
    write_to_log(FND_LOG.LEVEL_STATEMENT,p_module,'LINE_ATTRIBUTE15          =' || p_kle_source_rec.LINE_ATTRIBUTE15 );
  END write_kle_sources_to_log;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : assign_khr_rec_to_fxhv_rec
  --      Pre-reqs        : None
  --      Function        : assign khr rec to fxhv rec for FA OKL Transactions
  --      Parameters      :
  --      IN              : p_khr_source_rec     khr_source_rec_type
  --      OUT             : x_fxhv_rec           fxhv_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------
  -- Changes for Bug# 6268782 : PRASJAIN
  -- 1. func name assign_khr_rec_to_fxhv_rec to assign_khr_rec_to_fxh_rec
  -- 2. out param fxhv_rec_type to fxh_rec_type
  ------------------------------------------------------------------------------
  PROCEDURE assign_khr_rec_to_fxh_rec(
    p_khr_source_rec  IN       khr_source_rec_type
   ,x_fxh_rec        IN OUT   NOCOPY fxh_rec_type
  )
  AS
  BEGIN
    x_fxh_rec.khr_id                  := p_khr_source_rec.khr_id;
    x_fxh_rec.contract_number         := p_khr_source_rec.contract_number;
    x_fxh_rec.customer_name           := p_khr_source_rec.customer_name;
    x_fxh_rec.customer_account_number := p_khr_source_rec.customer_account_number;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    x_fxh_rec.party_id		      := p_khr_source_rec.customer_id;
    x_fxh_rec.cust_account_id         := p_khr_source_rec.cust_account_id;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    x_fxh_rec.contract_currency_code  := p_khr_source_rec.contract_currency_code;
    x_fxh_rec.contract_effective_from := p_khr_source_rec.contract_effective_from;
    x_fxh_rec.product_name            := p_khr_source_rec.product_name;
    x_fxh_rec.book_classification_code:= p_khr_source_rec.book_classification_code;
    x_fxh_rec.tax_owner_code          := p_khr_source_rec.tax_owner_code;
    x_fxh_rec.rev_rec_method_code     := p_khr_source_rec.rev_rec_method_code;
    x_fxh_rec.int_calc_method_code    := p_khr_source_rec.int_calc_method_code;
    x_fxh_rec.vendor_program_number   := p_khr_source_rec.vendor_program_number;
    x_fxh_rec.converted_number        := p_khr_source_rec.converted_number;
    x_fxh_rec.converted_account_flag  := p_khr_source_rec.converted_account_flag;
    x_fxh_rec.assignable_flag         := p_khr_source_rec.assignable_flag;
    x_fxh_rec.po_order_number         := p_khr_source_rec.po_order_number;
    x_fxh_rec.accrual_override_flag   := p_khr_source_rec.accrual_override_flag;
    x_fxh_rec.rent_ia_contract_number := p_khr_source_rec.rent_ia_contract_number;
    x_fxh_rec.rent_ia_product_name    := p_khr_source_rec.rent_ia_product_name;
    x_fxh_rec.rent_ia_accounting_code := p_khr_source_rec.rent_ia_accounting_code;
    x_fxh_rec.res_ia_contract_number  := p_khr_source_rec.res_ia_contract_number;
    x_fxh_rec.res_ia_product_name     := p_khr_source_rec.res_ia_product_name;
    x_fxh_rec.res_ia_accounting_code  := p_khr_source_rec.res_ia_accounting_code;
    x_fxh_rec.khr_attribute_category  := p_khr_source_rec.khr_attribute_category;
    x_fxh_rec.khr_attribute1          := p_khr_source_rec.khr_attribute1;
    x_fxh_rec.khr_attribute2          := p_khr_source_rec.khr_attribute2;
    x_fxh_rec.khr_attribute3          := p_khr_source_rec.khr_attribute3;
    x_fxh_rec.khr_attribute4          := p_khr_source_rec.khr_attribute4;
    x_fxh_rec.khr_attribute5          := p_khr_source_rec.khr_attribute5;
    x_fxh_rec.khr_attribute6          := p_khr_source_rec.khr_attribute6;
    x_fxh_rec.khr_attribute7          := p_khr_source_rec.khr_attribute7;
    x_fxh_rec.khr_attribute8          := p_khr_source_rec.khr_attribute8;
    x_fxh_rec.khr_attribute9          := p_khr_source_rec.khr_attribute9;
    x_fxh_rec.khr_attribute10         := p_khr_source_rec.khr_attribute10;
    x_fxh_rec.khr_attribute11         := p_khr_source_rec.khr_attribute11;
    x_fxh_rec.khr_attribute12         := p_khr_source_rec.khr_attribute12;
    x_fxh_rec.khr_attribute13         := p_khr_source_rec.khr_attribute13;
    x_fxh_rec.khr_attribute14         := p_khr_source_rec.khr_attribute14;
    x_fxh_rec.khr_attribute15         := p_khr_source_rec.khr_attribute15;
    x_fxh_rec.cust_attribute_category := p_khr_source_rec.cust_attribute_category;
    x_fxh_rec.cust_attribute1         := p_khr_source_rec.cust_attribute1;
    x_fxh_rec.cust_attribute2         := p_khr_source_rec.cust_attribute2;
    x_fxh_rec.cust_attribute3         := p_khr_source_rec.cust_attribute3;
    x_fxh_rec.cust_attribute4         := p_khr_source_rec.cust_attribute4;
    x_fxh_rec.cust_attribute5         := p_khr_source_rec.cust_attribute5;
    x_fxh_rec.cust_attribute6         := p_khr_source_rec.cust_attribute6;
    x_fxh_rec.cust_attribute7         := p_khr_source_rec.cust_attribute7;
    x_fxh_rec.cust_attribute8         := p_khr_source_rec.cust_attribute8;
    x_fxh_rec.cust_attribute9         := p_khr_source_rec.cust_attribute9;
    x_fxh_rec.cust_attribute10        := p_khr_source_rec.cust_attribute10;
    x_fxh_rec.cust_attribute11        := p_khr_source_rec.cust_attribute11;
    x_fxh_rec.cust_attribute12        := p_khr_source_rec.cust_attribute12;
    x_fxh_rec.cust_attribute13        := p_khr_source_rec.cust_attribute13;
    x_fxh_rec.cust_attribute14        := p_khr_source_rec.cust_attribute14;
    x_fxh_rec.cust_attribute15        := p_khr_source_rec.cust_attribute15;
    x_fxh_rec.contract_status_code    := p_khr_source_rec.contract_status_code;
  END assign_khr_rec_to_fxh_rec;
  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : assign_kle_rec_to_fxlv_rec
  --      Pre-reqs        : None
  --      Function        : assign kle rec to fxlv rec for FA OKL Transactions
  --      Parameters      :
  --      IN              : p_kle_source_rec     kle_source_rec_type
  --      OUT             : x_fxlv_rec           fxlv_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------
  -- Changes for Bug# 6268782 : PRASJAIN
  -- 1. func name assign_kle_rec_to_fxlv_rec to assign_kle_rec_to_fxl_rec
  -- 2. out param fxlv_rec_type to fxl_rec_type
  ------------------------------------------------------------------------------
  PROCEDURE assign_kle_rec_to_fxl_rec(
    p_kle_source_rec  IN       kle_source_rec_type
   ,x_fxl_rec        IN OUT   NOCOPY fxl_rec_type
  )
  AS
  BEGIN
    x_fxl_rec.kle_id                    := p_kle_source_rec.kle_id;
    x_fxl_rec.asset_number              := p_kle_source_rec.asset_number;
    x_fxl_rec.contract_line_number      := p_kle_source_rec.contract_line_number;
    x_fxl_rec.asset_vendor_name         := p_kle_source_rec.asset_vendor_name;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    x_fxl_rec.asset_vendor_id           := p_kle_source_rec.asset_vendor_id;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    x_fxl_rec.installed_site_id         := p_kle_source_rec.installed_site_id;
    x_fxl_rec.line_attribute_category   := p_kle_source_rec.line_attribute_category;
    x_fxl_rec.line_attribute1           := p_kle_source_rec.line_attribute1;
    x_fxl_rec.line_attribute2           := p_kle_source_rec.line_attribute2;
    x_fxl_rec.line_attribute3           := p_kle_source_rec.line_attribute3;
    x_fxl_rec.line_attribute4           := p_kle_source_rec.line_attribute4;
    x_fxl_rec.line_attribute5           := p_kle_source_rec.line_attribute5;
    x_fxl_rec.line_attribute6           := p_kle_source_rec.line_attribute6;
    x_fxl_rec.line_attribute7           := p_kle_source_rec.line_attribute7;
    x_fxl_rec.line_attribute8           := p_kle_source_rec.line_attribute8;
    x_fxl_rec.line_attribute9           := p_kle_source_rec.line_attribute9;
    x_fxl_rec.line_attribute10          := p_kle_source_rec.line_attribute10;
    x_fxl_rec.line_attribute11          := p_kle_source_rec.line_attribute11;
    x_fxl_rec.line_attribute12          := p_kle_source_rec.line_attribute12;
    x_fxl_rec.line_attribute13          := p_kle_source_rec.line_attribute13;
    x_fxl_rec.line_attribute14          := p_kle_source_rec.line_attribute14;
    x_fxl_rec.line_attribute15          := p_kle_source_rec.line_attribute15;
  END assign_kle_rec_to_fxl_rec;
  -----------------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_khr_sources
  --      Pre-reqs        : None
  --      Function        : populate khr header sources for FA/AR/AP OKL Transactions
  --      Parameters      :
  --      IN              : x_khr_source_rec.khr_id          NUMBER                Required
  --                        -- Change for Bug# 6268782 : PRASJAIN
  --                        x_led_lang_tbl                   led_lang_tbl_type     Required
  --      OUT             : x_khr_source_rec                 khr_source_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  -----------------------------------------------------------------------------------------

  PROCEDURE populate_khr_sources(
    p_api_version               IN                NUMBER
   ,p_init_msg_list             IN                VARCHAR2
   ,x_khr_source_rec            IN OUT    NOCOPY  khr_source_rec_type
   ,x_led_lang_tbl              IN OUT    NOCOPY  led_lang_tbl_type
   ,x_return_status             OUT       NOCOPY  VARCHAR2
   ,x_msg_count                 OUT       NOCOPY  NUMBER
   ,x_msg_data                  OUT       NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version              CONSTANT NUMBER         := 1;
    l_api_name                 CONSTANT VARCHAR2(30)   := 'POPULATE_KHR_SOURCES';
    l_return_status                     VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    ----------------------------------------------
    -- Variables based on Cursor record structures
    ----------------------------------------------
    l_kpl_attributes_csr_rec          c_kpl_attributes_csr%ROWTYPE;
    l_khr_category_attr_csr_rec       c_khr_category_attributes_csr%ROWTYPE;
    l_khr_attributes_csr_rec          c_khr_attributes_csr%ROWTYPE;
    l_get_status_meaning_csr_rec      c_get_status_meaning_csr%ROWTYPE;
    l_insurance_csr_rec               c_insurance_csr%ROWTYPE;
    l_rev_rec_int_calc_mtd_csr_rec    c_rev_rec_int_calc_methods_csr%ROWTYPE;
    l_cust_name_account_csr_rec       c_cust_name_account_csr%ROWTYPE;
    l_inv_agree_acc_code_csr_rec      c_investor_agree_acc_code_csr%ROWTYPE;
    l_investor_agree_main_csr_rec     c_investor_agreement_main_csr%ROWTYPE;
    l_vendor_prg_number_csr_rec       c_vendor_program_number_csr%ROWTYPE;
    l_pdt_bc_to_icm_rrb_rec           c_pdt_bc_to_icm_rrb_csr%ROWTYPE;
    l_inv_agrmnt_details_rec     c_inv_agrmnt_details_csr%ROWTYPE;
    ---------------------------------------------------------------
    -- Local Variables for storing value used in another procedure
    ---------------------------------------------------------------
    l_khr_id               NUMBER;
    l_cust_acct_id         NUMBER;
    l_pdt_id               NUMBER;
    l_rent_ia_chr_id       NUMBER;
    l_res_ia_chr_id        NUMBER;
    l_ledger_language      VARCHAR2(12);
    tl_sources_in          NUMBER := 1;

    ----------------------------------------------------
    -- Local variables for enabling the debug statements
    ----------------------------------------------------
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN DEBUG OKLRSLAB.PLS CALL ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_KHR_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'CALLING OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'AFTER START ACTIVITY L_RETURN_STATUS ' || l_return_status );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Copy input parameter to local variable
    l_khr_id          := x_khr_source_rec.khr_id;

    -- fetch and populate contract attributes
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing Cursor l_khr_attributes_csr_rec : l_khr_id = ' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_khr_attributes_csr (l_khr_id)
    LOOP
      l_khr_attributes_csr_rec                 := t_rec;
      -- First Capture the scs_code of the Entity ..
      --  If its lease then capture contract related sources, other wise not !!
      x_khr_source_rec.scs_code := l_khr_attributes_csr_rec.scs_code;
      IF l_khr_attributes_csr_rec.scs_code = G_LEASE
      THEN
        x_khr_source_rec.contract_number         := l_khr_attributes_csr_rec.contract_number;
        x_khr_source_rec.contract_currency_code  := l_khr_attributes_csr_rec.currency_code;
        x_khr_source_rec.contract_effective_from := l_khr_attributes_csr_rec.start_date;
        x_khr_source_rec.converted_number        := l_khr_attributes_csr_rec.orig_system_reference1;
        x_khr_source_rec.assignable_flag         := l_khr_attributes_csr_rec.assignable_yn;
        x_khr_source_rec.converted_account_flag  := l_khr_attributes_csr_rec.converted_account_yn;
        x_khr_source_rec.po_order_number         := l_khr_attributes_csr_rec.cust_po_number;
        x_khr_source_rec.accrual_override_flag   := l_khr_attributes_csr_rec.generate_accrual_override_yn;
        l_cust_acct_id                           := l_khr_attributes_csr_rec.cust_acct_id;
        l_pdt_id                                 := l_khr_attributes_csr_rec.pdt_id;
        -- Assign the Contract Status Code
        x_khr_source_rec.contract_status_code    := l_khr_attributes_csr_rec.sts_code;

		-- MG uptake .. for secondary rep get the reporting product id.
		if G_REPRESENTATION_TYPE = 'SECONDARY' then
		  open c_rep_pdt_csr(l_pdt_id);
		  fetch c_rep_pdt_csr into l_pdt_id;
		  close c_rep_pdt_csr;
		end if;

        -- Fetch contract status wrt ledger language
        FOR tl_sources_in IN x_led_lang_tbl.FIRST .. x_led_lang_tbl.LAST
        LOOP
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Executing the Cursor c_get_status_meaning_csr. p_sts_code=' ||
            l_khr_attributes_csr_rec.sts_code || 'p_led_lang= ' || x_led_lang_tbl(tl_sources_in).language );
          FOR t_rec IN c_get_status_meaning_csr(
                      p_sts_code  => l_khr_attributes_csr_rec.sts_code
                     ,p_led_lang  => x_led_lang_tbl(tl_sources_in).language )
          LOOP
            l_get_status_meaning_csr_rec   := t_rec;
            x_led_lang_tbl(tl_sources_in).contract_status := l_get_status_meaning_csr_rec.status_meaning;
          END LOOP; -- End for c_get_status_meaning_csr
        END LOOP;
      ELSIF l_khr_attributes_csr_rec.scs_code = G_INVESTOR
      THEN
        x_khr_source_rec.inv_agrmnt_number         := l_khr_attributes_csr_rec.contract_number;
        x_khr_source_rec.inv_agrmnt_effective_from := l_khr_attributes_csr_rec.start_date;
        x_khr_source_rec.inv_agrmnt_currency_code  := l_khr_attributes_csr_rec.currency_code;
        x_khr_source_rec.inv_agrmnt_status_code    := l_khr_attributes_csr_rec.sts_code;
        -- Fetch Investor Agreement status wrt ledger language
        FOR tl_sources_in IN x_led_lang_tbl.FIRST .. x_led_lang_tbl.LAST
        LOOP
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
            'Executing the Cursor c_get_status_meaning_csr. p_sts_code=' ||
            l_khr_attributes_csr_rec.sts_code || 'p_led_lang= ' || x_led_lang_tbl(tl_sources_in).language );
          FOR t_rec IN c_get_status_meaning_csr(
                      p_sts_code  => l_khr_attributes_csr_rec.sts_code
                     ,p_led_lang  => x_led_lang_tbl(tl_sources_in).language )
          LOOP
            l_get_status_meaning_csr_rec   := t_rec;
            x_led_lang_tbl(tl_sources_in).inv_agrmnt_status := l_get_status_meaning_csr_rec.status_meaning;
          END LOOP; -- End for c_get_status_meaning_csr
        END LOOP;
      END IF;
    END LOOP; -- End for c_khr_attributes_csr

    IF l_khr_attributes_csr_rec.scs_code = G_LEASE
    THEN
      -- fetch and populate contract attribute category and attributes
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_khr_category_attributes_csr l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_khr_category_attributes_csr (l_khr_id)
      LOOP
        l_khr_category_attr_csr_rec := t_rec;
        x_khr_source_rec.khr_attribute_category := l_khr_category_attr_csr_rec.attribute_category;
        x_khr_source_rec.khr_attribute1  := l_khr_category_attr_csr_rec.attribute1;
        x_khr_source_rec.khr_attribute2  := l_khr_category_attr_csr_rec.attribute2;
        x_khr_source_rec.khr_attribute3  := l_khr_category_attr_csr_rec.attribute3;
        x_khr_source_rec.khr_attribute4  := l_khr_category_attr_csr_rec.attribute4;
        x_khr_source_rec.khr_attribute5  := l_khr_category_attr_csr_rec.attribute5;
        x_khr_source_rec.khr_attribute6  := l_khr_category_attr_csr_rec.attribute6;
        x_khr_source_rec.khr_attribute7  := l_khr_category_attr_csr_rec.attribute7;
        x_khr_source_rec.khr_attribute8  := l_khr_category_attr_csr_rec.attribute8;
        x_khr_source_rec.khr_attribute9  := l_khr_category_attr_csr_rec.attribute9;
        x_khr_source_rec.khr_attribute10 := l_khr_category_attr_csr_rec.attribute10;
        x_khr_source_rec.khr_attribute11 := l_khr_category_attr_csr_rec.attribute11;
        x_khr_source_rec.khr_attribute12 := l_khr_category_attr_csr_rec.attribute12;
        x_khr_source_rec.khr_attribute13 := l_khr_category_attr_csr_rec.attribute13;
        x_khr_source_rec.khr_attribute14 := l_khr_category_attr_csr_rec.attribute14;
        x_khr_source_rec.khr_attribute15 := l_khr_category_attr_csr_rec.attribute15;
      END LOOP; -- End for c_khr_category_attributes_csr

      -- Fetch and populate book classification code and tax owner code
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_pdt_bc_to_icm_rrb_csr. l_pdt_id = ' || TO_CHAR(l_pdt_id) );
      FOR t_rec IN c_pdt_bc_to_icm_rrb_csr (p_pdt_id => l_pdt_id)
      LOOP
        l_pdt_bc_to_icm_rrb_rec := t_rec;
        x_khr_source_rec.product_name             := l_pdt_bc_to_icm_rrb_rec.pdt_name;
        x_khr_source_rec.book_classification_code := l_pdt_bc_to_icm_rrb_rec.deal_type;
        x_khr_source_rec.tax_owner_code           := l_pdt_bc_to_icm_rrb_rec.tax_owner;
        x_khr_source_rec.int_calc_method_code     := l_pdt_bc_to_icm_rrb_rec.interest_calc_meth_code;
        x_khr_source_rec.rev_rec_method_code      := l_pdt_bc_to_icm_rrb_rec.revenue_recog_meth_code;
      END LOOP; -- End for c_book_tax_csr

      -- fetch and populate vendor program number
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor  c_vendor_program_number_csr p_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_vendor_program_number_csr (p_khr_id => l_khr_id)
      LOOP
        l_vendor_prg_number_csr_rec := t_rec;
        x_khr_source_rec.vendor_program_number  := l_vendor_prg_number_csr_rec.contract_number;
      END LOOP; -- End for c_vendor_program_number_csr

      -- fetch and populate customer account properties
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor l_cust_name_account_csr. p_khr_id = ' || TO_CHAR(l_khr_id)
        || ' p_cust_acct_id = ' || TO_CHAR(l_cust_acct_id ) );
      FOR t_rec IN  c_cust_name_account_csr (l_khr_id,l_cust_acct_id)
      LOOP
        l_cust_name_account_csr_rec := t_rec;
        x_khr_source_rec.customer_name            := l_cust_name_account_csr_rec.party_name;
        x_khr_source_rec.customer_account_number  := l_cust_name_account_csr_rec.account_number;
        -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
        x_khr_source_rec.cust_account_id  := l_cust_acct_id;
	x_khr_source_rec.customer_id      := l_cust_name_account_csr_rec.party_id;
        -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
      END LOOP; -- End for c_cust_name_account_csr

      -- fetch and populate customer attribute category and attributes
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_kpl_attributes_csr l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_kpl_attributes_csr (l_khr_id)
      LOOP
        l_kpl_attributes_csr_rec := t_rec;
        x_khr_source_rec.cust_attribute_category := l_kpl_attributes_csr_rec.attribute_category;
        x_khr_source_rec.cust_attribute1  := l_kpl_attributes_csr_rec.attribute1;
        x_khr_source_rec.cust_attribute2  := l_kpl_attributes_csr_rec.attribute2;
        x_khr_source_rec.cust_attribute3  := l_kpl_attributes_csr_rec.attribute3;
        x_khr_source_rec.cust_attribute4  := l_kpl_attributes_csr_rec.attribute4;
        x_khr_source_rec.cust_attribute5  := l_kpl_attributes_csr_rec.attribute5;
        x_khr_source_rec.cust_attribute6  := l_kpl_attributes_csr_rec.attribute6;
        x_khr_source_rec.cust_attribute7  := l_kpl_attributes_csr_rec.attribute7;
        x_khr_source_rec.cust_attribute8  := l_kpl_attributes_csr_rec.attribute8;
        x_khr_source_rec.cust_attribute9  := l_kpl_attributes_csr_rec.attribute9;
        x_khr_source_rec.cust_attribute10 := l_kpl_attributes_csr_rec.attribute10;
        x_khr_source_rec.cust_attribute11 := l_kpl_attributes_csr_rec.attribute11;
        x_khr_source_rec.cust_attribute12 := l_kpl_attributes_csr_rec.attribute12;
        x_khr_source_rec.cust_attribute13 := l_kpl_attributes_csr_rec.attribute13;
        x_khr_source_rec.cust_attribute14 := l_kpl_attributes_csr_rec.attribute14;
        x_khr_source_rec.cust_attribute15 := l_kpl_attributes_csr_rec.attribute15;
      END LOOP; -- End for c_kpl_attributes_csr

      -- fetch and populate rent investor agreement attributes
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'RENT: Executing the Cursor c_investor_agreement_main_csr l_khr_id = : ' || TO_CHAR(l_khr_id));
      FOR t_rec IN c_investor_agreement_main_csr(
                          p_khr_id   => l_khr_id
                         ,p_sty_type => 'RENT')
      LOOP
        l_investor_agree_main_csr_rec := t_rec;
        l_rent_ia_chr_id  := l_investor_agree_main_csr_rec.ia_chr_id;
        x_khr_source_rec.rent_ia_contract_number := l_investor_agree_main_csr_rec.ia_contract_number;
        x_khr_source_rec.rent_ia_product_name    := l_investor_agree_main_csr_rec.ia_product_name;
      END LOOP;  -- End for c_investor_agreement_main_csr

      -- fetch and populate residual investor agreement attributes
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'RESIDUAL VALUE: Executing the Cursor c_investor_agreement_main_csr l_khr_id = : ' || TO_CHAR(l_khr_id));
      FOR t_rec IN c_investor_agreement_main_csr(
                          p_khr_id   => l_khr_id
                         ,p_sty_type => 'RESIDUAL VALUE')
      LOOP
        l_investor_agree_main_csr_rec := t_rec;
        l_res_ia_chr_id := l_investor_agree_main_csr_rec.ia_chr_id;
        x_khr_source_rec.res_ia_contract_number  := l_investor_agree_main_csr_rec.ia_contract_number;
        x_khr_source_rec.res_ia_product_name     := l_investor_agree_main_csr_rec.ia_product_name;
      END LOOP;  -- Enf for c_investor_agreement_main_csr

      -- fetch and populate rent investor agreement account properties
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_investor_agree_acc_code_csr. p_rent_ia_chr_id = '
        || TO_CHAR(l_rent_ia_chr_id) || ' p_res_ia_chr_id = ' || TO_CHAR(l_res_ia_chr_id));
      FOR t_rec in c_investor_agree_acc_code_csr (l_rent_ia_chr_id, l_res_ia_chr_id)
      LOOP
        l_inv_agree_acc_code_csr_rec := t_rec;
        x_khr_source_rec.rent_ia_accounting_code    := l_inv_agree_acc_code_csr_rec.rent_ia_accounting_code;
        x_khr_source_rec.res_ia_accounting_code     := l_inv_agree_acc_code_csr_rec.res_ia_accounting_code;
      END LOOP;  -- End for c_investor_agree_acc_code_csr

    ELSIF l_khr_attributes_csr_rec.scs_code = G_INVESTOR
    THEN

      -- Code to fetch the Sources like
      -- Investor Agreement Type, Pool Number and Product Name
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_inv_agrmnt_details_csr. l_khr_id = ' || TO_CHAR(l_khr_id) );
      FOR t_rec IN c_inv_agrmnt_details_csr( p_inv_agrmnt_id => l_khr_id )
      LOOP
        l_inv_agrmnt_details_rec  := t_rec;
        x_khr_source_rec.inv_agrmnt_synd_code     := l_inv_agrmnt_details_rec.inv_agrmnt_synd_code;
        -- Commented out the Investor Pool Agreement Source, as this is not mentioned as Source by PMs
        -- x_khr_source_rec.inv_agrmnt_pool_number   := l_inv_agrmnt_details_rec.inv_agrmnt_pool_number;
      END LOOP; -- FOR t_rec IN c_inv_agrmnt_details_csr( p_inv_agrmnt_id => l_khr_id )
      FOR t_rec IN c_get_pdt_name_csr( p_pdt_id => l_khr_attributes_csr_rec.pdt_id )
      LOOP
        x_khr_source_rec.inv_agrmnt_product_name     := t_rec.pdt_name;
      END LOOP;

    END IF;  -- IF l_khr_attributes_csr_rec.scs_code = G_INVESTOR
    -- If Log is enabled, print all khr sources fetched.
    IF (l_debug_enabled='Y' AND is_debug_statement_on)
    THEN
      write_khr_sources_to_log(
        p_khr_source_rec => x_khr_source_rec
       ,p_module         => l_module);
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'CALLING OKL_API.END_ACTIVITY');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_KHR_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_khr_sources;
  ---------------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_kle_sources
  --      Pre-reqs        : None
  --      Function        : populate khr / kle line sources for FA/AR/AP OKL Transactions
  --      Parameters      :
  --      IN              : x_kle_source_rec.khr_id          NUMBER   Required
  --                        x_kle_source_rec.kle_id          NUMBER   Required
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ---------------------------------------------------------------------------------------

  PROCEDURE populate_kle_sources(
    p_api_version               IN                NUMBER
   ,p_init_msg_list             IN                VARCHAR2
   ,x_kle_source_rec            IN OUT    NOCOPY  kle_source_rec_type
   ,x_return_status             OUT       NOCOPY  VARCHAR2
   ,x_msg_count                 OUT       NOCOPY  NUMBER
   ,x_msg_data                  OUT       NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version              CONSTANT NUMBER         := 1;
    l_api_name                 CONSTANT VARCHAR2(30)   := 'POPULATE_KLE_SOURCES';
    l_return_status                     VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    ----------------------------------------------
    -- Variables based on cursor record structures
    ----------------------------------------------
    l_line_attributes_rec           c_line_attributes_csr%ROWTYPE;
    l_k_lines_rec                   c_k_lines_csr%ROWTYPE;
    l_vendor_name_rec               c_vendor_name_csr%ROWTYPE;
    l_installed_site_rec            c_installed_site_csr%ROWTYPE;
    l_location_id_rec               c_location_id_csr%ROWTYPE;
    l_asset_location_name_rec       c_asset_location_name_csr%ROWTYPE;
    l_khr_attributes_csr_rec        c_khr_attributes_csr%ROWTYPE;
    ---------------------------------------------------------------
    -- Local Variables for storing value used in another procedure
    ---------------------------------------------------------------
    l_khr_id               NUMBER;
    l_kle_id               NUMBER;
    l_ledger_language      VARCHAR2(12);

    ----------------------------------------------------
    -- Local Variables for enabling the Debug Statements
    ----------------------------------------------------
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN DEBUG OKLRSLAB.PLS CALL ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_KLE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'CALLING OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'AFTER START ACTIVITY L_RETURN_STATUS ' || l_return_status );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Copy input parameter to local variables
    l_khr_id          := x_kle_source_rec.khr_id;
    l_kle_id          := x_kle_source_rec.kle_id;

    -- fetch and populate line attribute category and attributes
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_line_attributes_csr l_kle_id = ' || TO_CHAR(l_kle_id) );
    FOR t_rec IN c_line_attributes_csr (l_kle_id)
    LOOP
      l_line_attributes_rec  := t_rec;
      x_kle_source_rec.line_attribute_category := l_line_attributes_rec.attribute_category;
      x_kle_source_rec.line_attribute1  := l_line_attributes_rec.attribute1;
      x_kle_source_rec.line_attribute2  := l_line_attributes_rec.attribute2;
      x_kle_source_rec.line_attribute3  := l_line_attributes_rec.attribute3;
      x_kle_source_rec.line_attribute4  := l_line_attributes_rec.attribute4;
      x_kle_source_rec.line_attribute5  := l_line_attributes_rec.attribute5;
      x_kle_source_rec.line_attribute6  := l_line_attributes_rec.attribute6;
      x_kle_source_rec.line_attribute7  := l_line_attributes_rec.attribute7;
      x_kle_source_rec.line_attribute8  := l_line_attributes_rec.attribute8;
      x_kle_source_rec.line_attribute9  := l_line_attributes_rec.attribute9;
      x_kle_source_rec.line_attribute10 := l_line_attributes_rec.attribute10;
      x_kle_source_rec.line_attribute11 := l_line_attributes_rec.attribute11;
      x_kle_source_rec.line_attribute12 := l_line_attributes_rec.attribute12;
      x_kle_source_rec.line_attribute13 := l_line_attributes_rec.attribute13;
      x_kle_source_rec.line_attribute14 := l_line_attributes_rec.attribute14;
      x_kle_source_rec.line_attribute15 := l_line_attributes_rec.attribute15;
    END LOOP; -- End for c_line_attributes_csr

    -- fetch and populate line type code, asset number and contract line number
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_k_lines_csr l_kle_id = ' || TO_CHAR(l_kle_id) );
    FOR t_rec IN c_k_lines_csr (l_kle_id)
    LOOP
      l_k_lines_rec  := t_rec;
      x_kle_source_rec.line_type_code       := l_k_lines_rec.contract_line_type;
      x_kle_source_rec.asset_number         := l_k_lines_rec.asset_number;
      x_kle_source_rec.contract_line_number := l_k_lines_rec.line_number;
    END LOOP; -- End for c_k_lines_csr

    -- fetch and populate assest vendor name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_vendor_name_csr l_kle_id = ' || TO_CHAR(l_kle_id) ||
      ' l_khr_id = ' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_vendor_name_csr (
                        p_kle_id => l_kle_id
                       ,p_khr_id => l_khr_id)
    LOOP
      l_vendor_name_rec  := t_rec;
      x_kle_source_rec.asset_vendor_name       := l_vendor_name_rec.vendor_name;
      -- added by zrehman Bug#6707320 as part of Party Merge impact on transaction sources tables start
      x_kle_source_rec.asset_vendor_id         := l_vendor_name_rec.vendor_id;
      -- added by zrehman Bug#6707320 as part of Party Merge impact on transaction sources tables end
    END LOOP; -- End for c_vendor_name_csr

    -- fetch and populate installed site
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_installed_site_csr l_kle_id = ' || TO_CHAR(l_kle_id) ||
      ' l_khr_id = ' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_installed_site_csr (
                        p_kle_id => l_kle_id
                       ,p_khr_id => l_khr_id)
    LOOP
      l_installed_site_rec  := t_rec;
      x_kle_source_rec.installed_site_id       := l_installed_site_rec.installed_site_id;
    END LOOP; -- End for c_installed_site_csr

    -- fetch and populate fixed asset location name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_location_id_csr l_kle_id = ' || TO_CHAR(l_kle_id) ||
      ' l_khr_id = ' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_location_id_csr (
                        p_kle_id => l_kle_id
                       ,p_khr_id => l_khr_id)
    LOOP
      l_location_id_rec  := t_rec;

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_asset_location_name_csr location_id = ' || TO_CHAR(l_location_id_rec.location_id));
      FOR t_rec IN c_asset_location_name_csr (p_fdh_location_id => l_location_id_rec.location_id)
      LOOP
        l_asset_location_name_rec  := t_rec;
        x_kle_source_rec.fixed_asset_location_name   := l_asset_location_name_rec.asset_location_name;
      END LOOP; -- End for c_asset_location_name_csr
    END LOOP; -- End for c_location_id_csr

    -- fetch and populate product id
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing Cursor c_khr_attributes_csr : l_khr_id = ' ||to_char(l_khr_id));
    FOR t_rec IN c_khr_attributes_csr (l_khr_id)
    LOOP
      l_khr_attributes_csr_rec := t_rec;
    END LOOP; -- End for c_khr_attributes_csr

    -- If log is enabled, print all the sources fetched.
    IF (l_debug_enabled='Y' AND is_debug_statement_on)
    THEN
      write_kle_sources_to_log(
        p_kle_source_rec => x_kle_source_rec
       ,p_module         => l_module);
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'CALLING OKL_API.END_ACTIVITY');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_KLE_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_kle_sources;
  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL FA Transactions
  --      Parameters      :
  --      IN              :
  --                        fxhv_rec_type.source_id            IN NUMBER    Required
  --                        fxhv_rec_type.source_table         IN VARCHAR2  Required
  --                        fxhv_rec_type.khr_id               IN NUMBER    Required
  --                        fxhv_rec_type.try_id               IN NUMBER    Required
  --                        fxlv_rec_type.source_id            IN NUMBER    Required
  --                        fxlv_rec_type.source_table         IN VARCHAR2  Required
  --                        fxlv_rec_type.kle_id               IN NUMBER    Required
  --                        fxlv_rec_type.asset_id             IN NUMBER    Required
  --                        fxlv_rec_type.fa_transaction_id    IN NUMBER    Required
  --                        fxlv_rec_type.asset_book_type_name IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --                      : Dec 11 2007 Rkuttiya modfied for bug# 6674730
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------

  PROCEDURE populate_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_fxhv_rec              IN        fxhv_rec_type
   ,p_fxlv_rec              IN        fxlv_rec_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'POPULATE_SOURCES-FA';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_khr_id               NUMBER;
    l_kle_id               NUMBER;
    l_try_id               NUMBER;
    l_ledger_id            NUMBER;
    l_ledger_language      VARCHAR2(12);
    l_header_extension_id  NUMBER;
    l_txl_id               NUMBER;
    l_pk_attributes        VARCHAR2(1000);
    l_line_style           VARCHAR2(100);
    -- KHR and KLE Based Record Structures
    l_khr_source_rec       khr_source_rec_type;
    l_kle_source_rec       kle_source_rec_type;
    -- Record structures based on FA Extension Header and Line Tables
    l_fxh_rec             okl_fxh_pvt.fxh_rec_type;
    lx_fxh_rec            okl_fxh_pvt.fxh_rec_type;
    -- for capture header translatable sources
    l_fxhl_tbl            okl_fxh_pvt.fxhl_tbl_type;
    lx_fxhl_tbl           okl_fxh_pvt.fxhl_tbl_type;

    l_fxl_rec             okl_fxl_pvt.fxl_rec_type;
    lx_fxl_rec            okl_fxl_pvt.fxl_rec_type;
    -- for capture header translatable sources
    l_fxll_tbl            okl_fxl_pvt.fxll_tbl_type;
    lx_fxll_tbl           okl_fxl_pvt.fxll_tbl_type;

    l_led_lang_tbl        led_lang_tbl_type;

    -- Record structures based on the Cursor defintions
    l_sales_rep_csr_rec    c_sales_rep_csr%ROWTYPE;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    tl_sources_in         NUMBER := 1;

	l_rep_code            VARCHAR2(30);
	l_rep_name            VARCHAR2(30);
	l_rep_type            VARCHAR2(20);
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Performing validations');
    -- Validations to be done:
    --  1. The following should be NOT NULL
    --     dnz_khr_id, kle_id, try_id, asset_id, fa_transaction_id, source_id,
    --     source_table and asset_book_type_code
    l_pk_attributes := NULL;
    IF p_fxhv_rec.source_id IS NULL OR
       p_fxhv_rec.source_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'FXH.SOURCE_ID';
    END IF;
    IF p_fxhv_rec.source_table IS NULL OR
       p_fxhv_rec.source_table = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'FXH.SOURCE_TABLE';
    END IF;
    IF p_fxhv_rec.khr_id IS NULL OR
       p_fxhv_rec.khr_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'KHR_ID';
    END IF;
    IF p_fxlv_rec.kle_id IS NULL OR
       p_fxlv_rec.kle_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'KLE_ID';
    END IF;
    IF p_fxhv_rec.try_id IS NULL OR
       p_fxhv_rec.try_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'TRY_ID';
    END IF;
    IF p_fxlv_rec.asset_id IS NULL OR
       p_fxlv_rec.asset_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'ASSET_ID';
    END IF;

    IF p_fxlv_rec.fa_transaction_id IS NULL OR
       p_fxlv_rec.fa_transaction_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'FA_TRANSACTION_ID';
    END IF;
    IF p_fxlv_rec.asset_book_type_name IS NULL OR
       p_fxlv_rec.asset_book_type_name = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'ASSET_BOOK_TYPE_NAME';
    END IF;
    IF p_fxlv_rec.source_id IS NULL OR
       p_fxlv_rec.source_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'FXL.SOURCE_ID';
    END IF;
    IF p_fxlv_rec.source_table IS NULL OR
       p_fxlv_rec.source_table = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'FXL.SOURCE_TABLE';
    END IF;
    IF LENGTH(l_pk_attributes) > 0
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => l_pk_attributes);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 1 Successfull !');
    -- Validation 2: Source Table should be OKL_TXL_ASSETS_B/OKL_TXD_ASSETS_B only
    IF p_fxhv_rec.source_table <> G_TRX_ASSETS
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 2 Successfull !');
    -- Validation 3: Source Table should be OKL_TXL_ASSETS_B/OKL_TXD_ASSETS_B only
    IF p_fxlv_rec.source_table NOT IN ( G_TXL_ASSETS, G_TXD_ASSETS )
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 3 Successfull !');
    -- Validation 4: The kle_id value passed should be the Id of the Line with
    --               line style as FREE_FORM1
    FOR t_rec IN get_line_style_csr ( p_kle_id  => p_fxlv_rec.kle_id )
    LOOP
      l_line_style := t_rec.line_style;
    END LOOP;
    IF l_line_style IS NULL OR
       l_line_style <> 'FREE_FORM1'
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'KLE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 4 Successfull !');
    -- Copy the Input Parameters to the Local Variables
    l_khr_id  := p_fxhv_rec.khr_id;
    l_kle_id  := p_fxlv_rec.kle_id;
    l_try_id  := p_fxhv_rec.try_id;

    -- initialize the local l_fxlv_rec to the input record values
    l_fxh_rec.source_id     := p_fxhv_rec.source_id;
    l_fxh_rec.source_table  := p_fxhv_rec.source_table;
    l_fxh_rec.khr_id        := p_fxhv_rec.khr_id;
    l_fxh_rec.try_id        := p_fxhv_rec.try_id;

    l_fxl_rec.source_id            := p_fxlv_rec.source_id;
    l_fxl_rec.source_table         := p_fxlv_rec.source_table;
    l_fxl_rec.kle_id               := p_fxlv_rec.kle_id;
    l_fxl_rec.asset_id             := p_fxlv_rec.asset_id;
    l_fxl_rec.fa_transaction_id    := p_fxlv_rec.fa_transaction_id;
    l_fxl_rec.asset_book_type_code := p_fxlv_rec.asset_book_type_name;

	-- get the book type code based on asset_book_type_name .. MG uptake
	OPEN get_book_type_name(l_fxl_rec.asset_book_type_code);
	FETCH get_book_type_name INTO l_fxl_rec.asset_book_type_name;
	CLOSE get_book_type_name;

	-- get the ledger based on the asset_book_type_name. MG uptake
    OPEN  get_reps_csr(l_fxl_rec.asset_book_type_code);
	FETCH get_reps_csr into l_ledger_id, l_fxh_rec.representation_code,
	                            l_fxh_rec.representation_name, l_rep_type;
	CLOSE get_reps_csr;

    if l_rep_type is not null then
	  G_REPRESENTATION_TYPE := l_rep_type;
    else
	  G_REPRESENTATION_TYPE := 'PRIMARY';
    end if;

	  /* -- commented as the ledger is obtained above. MG uptake.
      -- Fetch Ledger ID to fetch the Ledger Language associated to the contracts
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_khr_to_ledger_id_csr. p_khr_id=' || TO_CHAR(l_khr_id));
      FOR t_rec IN c_khr_to_ledger_id_csr( p_khr_id => l_khr_id )
      LOOP
        l_ledger_id := t_rec.ledger_id;
      END LOOP;
      */

    -- Using the Ledger ID fetch the Ledger Language
    -- Fetch the ledger language in order to populate the sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_ledger_lang_csr. p_ledger_id=' || TO_CHAR(l_ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_ledger_id )
    LOOP
      l_led_lang_tbl(tl_sources_in).language := t_rec.language_code;
      l_fxll_tbl(tl_sources_in).language     := t_rec.language_code;
    END LOOP;

    -- Prepare khr_source_rec_type with khr_id and ledger_language
    l_khr_source_rec.khr_id            := l_khr_id;

    -- Calling populate_khr_sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the populate_khr_sources' );
    populate_khr_sources(
       p_api_version      => l_api_version
      ,p_init_msg_list    => p_init_msg_list
      ,x_khr_source_rec   => l_khr_source_rec
      ,x_led_lang_tbl     => l_led_lang_tbl
      ,x_return_status    => l_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After populate_khr_sources: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --calling assign_khr_rec_to_fxhv_rec
    assign_khr_rec_to_fxh_rec(
       p_khr_source_rec => l_khr_source_rec
      ,x_fxh_rec       => l_fxh_rec );

    FOR tl_sources_in IN l_led_lang_tbl.FIRST .. l_led_lang_tbl.LAST
    LOOP
      l_fxhl_tbl(tl_sources_in).language             := l_led_lang_tbl(tl_sources_in).language;
      l_fxhl_tbl(tl_sources_in).contract_status      := l_led_lang_tbl(tl_sources_in).contract_status;

      -- Fetch transaction type name wrt ledger language
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_trx_type_name_csr. p_try_id=' || l_try_id || 'p_led_lang= ' || l_fxhl_tbl(tl_sources_in).language );
      FOR t_rec IN c_trx_type_name_csr(
                      p_try_id    => l_try_id
                     ,p_led_lang  => l_fxhl_tbl(tl_sources_in).language )
      LOOP
        l_fxhl_tbl(tl_sources_in).transaction_type_name := t_rec.transaction_type_name;
        -- Assign the Trx. Type Class Code also.
        l_fxh_rec.trx_type_class_code  := t_rec.trx_type_class_code;
      END LOOP; -- End for c_trx_type_name_csr
    END LOOP;

    IF l_fxh_rec.trx_type_class_code = 'OFFLEASE_AMORTIZATION'
    THEN
      -- Fetch Termination Quote related Sources during Offlease Amortization
      FOR t_rec IN c_tq_dtls_offlease( p_kle_id => l_kle_id )
      LOOP
        l_fxh_rec.term_quote_num         := t_rec.quote_number;
        l_fxh_rec.term_quote_accept_date := t_rec.quote_accepted_date;
        l_fxh_rec.term_quote_type_code   := t_rec.quote_type;
      END LOOP;
    ELSIF l_fxh_rec.trx_type_class_code = 'SPLIT_ASSET'
    THEN
      -- Fetch Termination Quote related Sources during Split Asset
      FOR t_rec IN c_tq_dtls_split_ast(
                      p_kle_id              => l_kle_id
                     ,p_split_asset_trx_id  => l_fxh_rec.source_id )
      LOOP
        l_fxh_rec.term_quote_num         := t_rec.quote_number;
        l_fxh_rec.term_quote_accept_date := t_rec.quote_accepted_date;
        l_fxh_rec.term_quote_type_code   := t_rec.quote_type;
      END LOOP;
    ELSIF l_fxh_rec.trx_type_class_code = 'RELEASE'
    THEN
      -- Fetch Termination Quote related Sources during Release
      FOR t_rec IN c_tq_dtls_release( p_khr_id  => l_khr_id )
      LOOP
        l_fxh_rec.term_quote_num         := t_rec.quote_number;
        l_fxh_rec.term_quote_accept_date := t_rec.quote_accepted_date;
        l_fxh_rec.term_quote_type_code   := t_rec.quote_type;
      END LOOP;
   --rkuttiya added for bug#6674730  Loans Repossession
    ELSIF l_fxh_rec.trx_type_class_code = 'INTERNAL_ASSET_CREATION' AND
          p_fxhv_rec.repossess_flag = 'Y' THEN
    --Fetch Termination Quote related Sources during Repossession
      l_fxh_rec.term_quote_num := p_fxhv_rec.term_quote_num;
      l_fxh_rec.term_quote_accept_date := p_fxhv_rec.term_quote_accept_date;
      l_fxh_rec.term_quote_type_code   := p_fxhv_rec.term_quote_type_code;
      l_fxh_rec.repossess_flag         := p_fxhv_rec.repossess_flag;
    END IF;

    -- Start populating the FXLV Record Structure
    -- Fetch transaction number
    IF p_fxlv_rec.source_table = 'OKL_TXL_ASSETS_B'
    THEN
      -- if source table is OKL_TXL_ASSETS_B
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_txl_trans_number_csr. p_source_id=' || p_fxlv_rec.source_id);
      FOR t_rec IN c_txl_trans_number_csr(
                    p_source_id    => p_fxlv_rec.source_id )
      LOOP
        l_fxh_rec.trans_number  := t_rec.trans_number;
        l_txl_id                := t_rec.txl_id;
        l_fxh_rec.source_id     := t_rec.tas_id;
      END LOOP; -- End for c_txl_trans_number_csr
    ELSIF p_fxlv_rec.source_table = 'OKL_TXD_ASSETS_B'
    THEN
      --if source table is OKL_TXD_ASSETS_B
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_txd_trans_number_csr. p_source_id=' || p_fxlv_rec.source_id);
      FOR t_rec IN c_txd_trans_number_csr(
                    p_source_id    => p_fxlv_rec.source_id )
      LOOP
        l_fxh_rec.trans_number  := t_rec.trans_number;
        l_txl_id                := t_rec.txl_id;
        l_fxh_rec.source_id     := t_rec.tas_id;
      END LOOP; -- End for c_txd_trans_number_csr
    END IF;

    -- Fetch and Populate Sales Representative Name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor  c_sales_rep_csr. p_khr_id = ' || TO_CHAR(l_khr_id) );
    FOR t_rec IN  c_sales_rep_csr (l_khr_id)
    LOOP
      l_sales_rep_csr_rec := t_rec;
      l_fxh_rec.sales_rep_name := l_sales_rep_csr_rec.name;
    END LOOP; -- End for c_sales_rep_csr

    -- Calling insert_row
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_fa_extension_pvt.create_fxh_extension ' || l_fxh_rec.source_id );
    okl_fa_extension_pvt.create_fxh_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_fxh_rec         => l_fxh_rec
      ,p_fxhl_tbl        => l_fxhl_tbl
      ,x_fxh_rec         => lx_fxh_rec
      ,x_fxhl_tbl        => lx_fxhl_tbl
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_fa_extension_pvt.create_fxh_extension: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_header_extension_id := lx_fxh_rec.header_extension_id;
    -- Prepare kle_source_rec_type with khr_id, kle_id and ledger_language
    l_kle_source_rec.khr_id            := l_khr_id;
    l_kle_source_rec.kle_id            := l_kle_id;
    -- Calling populate_kle_sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the populate_kle_sources' );
    populate_kle_sources(
      p_api_version      => l_api_version
     ,p_init_msg_list    => p_init_msg_list
     ,x_kle_source_rec   => l_kle_source_rec
     ,x_return_status    => l_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After populate_kle_sources: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Assin the KLE Sources to the FA Extension Line
    assign_kle_rec_to_fxl_rec(
       p_kle_source_rec => l_kle_source_rec
      ,x_fxl_rec => l_fxl_rec );

    -- Fetch and Populate Inventory Organization Name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing Cursor c_inventory_org_id_csr : l_khr_id = ' ||to_char(l_khr_id));
    FOR t_rec IN c_inventory_org_id_csr (l_khr_id)
    LOOP
      -- Assign the Inventory Organization Code
      l_fxl_rec.inventory_org_code := t_rec.hrb_name;
      FOR tl_sources_in IN l_fxll_tbl.FIRST .. l_fxll_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing Cursor c_org_name_csr : p_org_id = ' ||to_char(t_rec.inv_organization_id)
          || ' p_ledger_lang = ' || to_char(l_fxll_tbl(tl_sources_in).language));
        FOR t_org_rec IN c_org_name_csr (
                     p_org_id        => t_rec.inv_organization_id
                    ,p_ledger_lang   => l_fxll_tbl(tl_sources_in).language)
        LOOP
          l_fxll_tbl(tl_sources_in).inventory_org_name := t_org_rec.org_name;
        END LOOP; -- End for c_org_name_csr

        -- Fetch transaction line description
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor get_txl_line_desc_csr. p_txl_id=' || l_txl_id
          || ' p_ledger_language=' || l_fxll_tbl(tl_sources_in).language);
        FOR t_rec IN get_txl_line_desc_csr(
                     p_txl_id        => l_txl_id
                    ,p_ledger_lang   => l_fxll_tbl(tl_sources_in).language )
        LOOP
          l_fxll_tbl(tl_sources_in).trans_line_description := t_rec.trans_line_description;
        END LOOP; -- End for get_txl_line_desc_csr
      END LOOP;
    END LOOP; -- End for c_inventory_org_id_csr

    -- Stamp the FA Extension Header ID on the FA Extension Line Table also
    l_fxl_rec.header_extension_id := l_header_extension_id;
    -- Calling insert_row
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_fa_extension_pvt.create_fxl_extension' );
    okl_fa_extension_pvt.create_fxl_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_fxl_rec         => l_fxl_rec
      ,p_fxll_tbl        => l_fxll_tbl
      ,x_fxl_rec         => lx_fxl_rec
      ,x_fxll_tbl        => lx_fxll_tbl
     );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_fa_extension_pvt.create_fxl_extension: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_sources;

  PROCEDURE delete_fa_extension(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_fxhv_rec                  IN             fxhv_rec_type
   ,x_fxlv_tbl                  OUT    NOCOPY  fxlv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'DELETE_TRX_EXTENSION';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    fxl_index          BINARY_INTEGER;
    l_fxhv_rec         okl_fxh_pvt.fxhv_rec_type;
    l_fxlv_tbl         okl_fxl_pvt.fxlv_tbl_type;
    lx_fxhv_rec        okl_fxh_pvt.fxhv_rec_type;
    lx_fxlv_tbl        okl_fxl_pvt.fxlv_tbl_type;
    -- Cursor Definitions
    CURSOR get_fa_ext_hdr_id( p_source_id  NUMBER, p_source_table VARCHAR2)
    IS
      SELECT   fxh.header_extension_id      header_extension_id
        FROM   okl_ext_fa_header_sources_b	fxh
       WHERE   fxh.source_id = p_source_id
         AND   fxh.source_table = p_source_table;

    CURSOR get_fa_ext_lns_id( p_hdr_ext_id  NUMBER)
    IS
      SELECT   fxl.line_extension_id     line_extension_id
              ,fxl.source_id             source_id
              ,fxl.source_table          source_table
        FROM   okl_ext_fa_line_sources_b fxl
       WHERE   fxl.header_extension_id = p_hdr_ext_id;
    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.DELETE_TRX_EXTENSION');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual Logic Starts Here ..
    l_fxhv_rec := p_fxhv_rec;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Source ID=' || to_char(l_fxhv_rec.source_id) || 'Source Header Table=' || l_fxhv_rec.source_table );
    IF ( l_fxhv_rec.source_id = OKL_API.G_MISS_NUM or l_fxhv_rec.source_id IS NULL )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'FXH.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF ( l_fxhv_rec.source_table = OKL_API.G_MISS_CHAR OR l_fxhv_rec.source_table IS NULL
        OR l_fxhv_rec.source_table NOT IN ( G_TRX_ASSETS) )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'FXH.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Fetch the Extension Header ID by executing cursor get_txl_ext_hdr_id' );
    FOR t_rec IN get_fa_ext_hdr_id(
                    p_source_id     => l_fxhv_rec.source_id
                   ,p_source_table  => l_fxhv_rec.source_table)
    LOOP
      l_fxhv_rec.header_extension_id := t_rec.header_extension_id;
    END LOOP;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Extension Header ID To be Deleted='  || TO_CHAR(l_fxhv_rec.header_extension_id));

    -- Fetch the Transaction Extension Line IDs to be deleted
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Extension Line ID(s) To be Deleted=');
    fxl_index := 1;
    FOR t_rec IN get_fa_ext_lns_id( p_hdr_ext_id  => l_fxhv_rec.header_extension_id)
    LOOP
      l_fxlv_tbl(fxl_index).line_extension_id  := t_rec.line_extension_id;
      l_fxlv_tbl(fxl_index).source_id          := t_rec.source_id;
      l_fxlv_tbl(fxl_index).source_table       := t_rec.source_table;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'LINE_EXTENSION_ID[' || fxl_index || '] = ' || TO_CHAR(l_fxlv_tbl(fxl_index).line_extension_id) );
      -- Increment i
      fxl_index := fxl_index + 1;
    END LOOP; -- End get_trans_line_ids
    -- Store the Transaction Line IDs and Line Source Tables so as to return back
    x_fxlv_tbl := l_fxlv_tbl;

    -- Delete the FA Extension Lines by calling the TAPI first
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'calling the okl_fa_extension_pvt okl_fxl_pvt.delete_row Line Count=' || l_fxlv_tbl.COUNT );
    okl_fa_extension_pvt.delete_fxh_extension(
      p_api_version     => p_api_version
     ,p_init_msg_list   => p_init_msg_list
     ,x_return_status   => x_return_status
     ,x_msg_count       => x_msg_count
     ,x_msg_data        => x_msg_data
     ,p_fxhv_rec        => l_fxhv_rec
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_fa_extension_pvt.delete_fxh_extension: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.DELETE_TRX_EXTENSION');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END delete_fa_extension;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : assign_khr_rec_to_rxhv_rec
  --      Pre-reqs        : None
  --      Function        : assign khr rec to rxhv rec for AR OKL Transactions
  --      Parameters      :
  --      IN              : p_khr_source_rec     khr_source_rec_type
  --      OUT             : x_rxhv_rec           rxhv_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------
  -- Changes for Bug# 6268782 : PRASJAIN
  -- 1. func name assign_khr_rec_to_rxhv_rec to assign_khr_rec_to_rxh_rec
  -- 2. out param rxhv_rec_type to rxh_rec_type
  ------------------------------------------------------------------------------
  PROCEDURE assign_khr_rec_to_rxh_rec(
    p_khr_source_rec  IN       khr_source_rec_type
   ,x_rxh_rec         IN OUT   NOCOPY rxh_rec_type
  )
  AS
  BEGIN
    x_rxh_rec.khr_id                  := p_khr_source_rec.khr_id;
    x_rxh_rec.contract_number         := p_khr_source_rec.contract_number;
    x_rxh_rec.contract_currency_code  := p_khr_source_rec.contract_currency_code;
    x_rxh_rec.contract_effective_from := p_khr_source_rec.contract_effective_from;
    x_rxh_rec.product_name            := p_khr_source_rec.product_name;
    x_rxh_rec.book_classification_code:= p_khr_source_rec.book_classification_code;
    x_rxh_rec.tax_owner_code          := p_khr_source_rec.tax_owner_code;
    x_rxh_rec.rev_rec_method_code     := p_khr_source_rec.rev_rec_method_code;
    x_rxh_rec.int_calc_method_code    := p_khr_source_rec.int_calc_method_code;
    x_rxh_rec.vendor_program_number   := p_khr_source_rec.vendor_program_number;
    x_rxh_rec.converted_number        := p_khr_source_rec.converted_number;
    x_rxh_rec.converted_account_flag  := p_khr_source_rec.converted_account_flag;
    x_rxh_rec.assignable_flag         := p_khr_source_rec.assignable_flag;
    x_rxh_rec.po_order_number         := p_khr_source_rec.po_order_number;
    x_rxh_rec.accrual_override_flag   := p_khr_source_rec.accrual_override_flag;
    x_rxh_rec.rent_ia_contract_number := p_khr_source_rec.rent_ia_contract_number;
    x_rxh_rec.rent_ia_product_name    := p_khr_source_rec.rent_ia_product_name;
    x_rxh_rec.rent_ia_accounting_code := p_khr_source_rec.rent_ia_accounting_code;
    x_rxh_rec.res_ia_contract_number  := p_khr_source_rec.res_ia_contract_number;
    x_rxh_rec.res_ia_product_name     := p_khr_source_rec.res_ia_product_name;
    x_rxh_rec.res_ia_accounting_code  := p_khr_source_rec.res_ia_accounting_code;
    x_rxh_rec.khr_attribute_category  := p_khr_source_rec.khr_attribute_category;
    x_rxh_rec.khr_attribute1          := p_khr_source_rec.khr_attribute1;
    x_rxh_rec.khr_attribute2          := p_khr_source_rec.khr_attribute2;
    x_rxh_rec.khr_attribute3          := p_khr_source_rec.khr_attribute3;
    x_rxh_rec.khr_attribute4          := p_khr_source_rec.khr_attribute4;
    x_rxh_rec.khr_attribute5          := p_khr_source_rec.khr_attribute5;
    x_rxh_rec.khr_attribute6          := p_khr_source_rec.khr_attribute6;
    x_rxh_rec.khr_attribute7          := p_khr_source_rec.khr_attribute7;
    x_rxh_rec.khr_attribute8          := p_khr_source_rec.khr_attribute8;
    x_rxh_rec.khr_attribute9          := p_khr_source_rec.khr_attribute9;
    x_rxh_rec.khr_attribute10         := p_khr_source_rec.khr_attribute10;
    x_rxh_rec.khr_attribute11         := p_khr_source_rec.khr_attribute11;
    x_rxh_rec.khr_attribute12         := p_khr_source_rec.khr_attribute12;
    x_rxh_rec.khr_attribute13         := p_khr_source_rec.khr_attribute13;
    x_rxh_rec.khr_attribute14         := p_khr_source_rec.khr_attribute14;
    x_rxh_rec.khr_attribute15         := p_khr_source_rec.khr_attribute15;
    x_rxh_rec.cust_attribute_category := p_khr_source_rec.cust_attribute_category;
    x_rxh_rec.cust_attribute1         := p_khr_source_rec.cust_attribute1;
    x_rxh_rec.cust_attribute2         := p_khr_source_rec.cust_attribute2;
    x_rxh_rec.cust_attribute3         := p_khr_source_rec.cust_attribute3;
    x_rxh_rec.cust_attribute4         := p_khr_source_rec.cust_attribute4;
    x_rxh_rec.cust_attribute5         := p_khr_source_rec.cust_attribute5;
    x_rxh_rec.cust_attribute6         := p_khr_source_rec.cust_attribute6;
    x_rxh_rec.cust_attribute7         := p_khr_source_rec.cust_attribute7;
    x_rxh_rec.cust_attribute8         := p_khr_source_rec.cust_attribute8;
    x_rxh_rec.cust_attribute9         := p_khr_source_rec.cust_attribute9;
    x_rxh_rec.cust_attribute10        := p_khr_source_rec.cust_attribute10;
    x_rxh_rec.cust_attribute11        := p_khr_source_rec.cust_attribute11;
    x_rxh_rec.cust_attribute12        := p_khr_source_rec.cust_attribute12;
    x_rxh_rec.cust_attribute13        := p_khr_source_rec.cust_attribute13;
    x_rxh_rec.cust_attribute14        := p_khr_source_rec.cust_attribute14;
    x_rxh_rec.cust_attribute15        := p_khr_source_rec.cust_attribute15;
    x_rxh_rec.contract_status_code    := p_khr_source_rec.contract_status_code;
    x_rxh_rec.inv_agrmnt_number         := p_khr_source_rec.inv_agrmnt_number;
    x_rxh_rec.inv_agrmnt_effective_from := p_khr_source_rec.inv_agrmnt_effective_from;
    x_rxh_rec.inv_agrmnt_product_name   := p_khr_source_rec.inv_agrmnt_product_name;
    x_rxh_rec.inv_agrmnt_currency_code  := p_khr_source_rec.inv_agrmnt_currency_code;
    x_rxh_rec.inv_agrmnt_synd_code      := p_khr_source_rec.inv_agrmnt_synd_code;
    x_rxh_rec.inv_agrmnt_pool_number    := p_khr_source_rec.inv_agrmnt_pool_number;
    x_rxh_rec.inv_agrmnt_status_code    := p_khr_source_rec.inv_agrmnt_status_code;
    x_rxh_rec.scs_code                  := p_khr_source_rec.scs_code;
  END assign_khr_rec_to_rxh_rec;

 ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : assign_kle_rec_to_rxlv_rec
  --      Pre-reqs        : None
  --      Function        : assign kle rec to rxlv rec for AR OKL Transactions
  --      Parameters      :
  --      IN              : p_kle_source_rec     kle_source_rec_type
  --      OUT             : x_rxlv_rec           rxlv_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------
  -- Changes for Bug# 6268782 : PRASJAIN
  -- 1. func name assign_kle_rec_to_rxlv_rec to assign_kle_rec_to_rxl_rec
  -- 2. out param rxlv_rec_type to rxl_rec_type
  ------------------------------------------------------------------------------
  PROCEDURE assign_kle_rec_to_rxl_rec(
    p_kle_source_rec  IN       kle_source_rec_type
   ,x_rxl_rec        IN OUT   NOCOPY rxl_rec_type
  )
  AS
  BEGIN
    x_rxl_rec.kle_id                    := p_kle_source_rec.kle_id;
    x_rxl_rec.asset_number              := p_kle_source_rec.asset_number;
    x_rxl_rec.contract_line_number      := p_kle_source_rec.contract_line_number;
    x_rxl_rec.asset_vendor_name         := p_kle_source_rec.asset_vendor_name;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    x_rxl_rec.asset_vendor_id           := p_kle_source_rec.asset_vendor_id;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    x_rxl_rec.installed_site_id         := p_kle_source_rec.installed_site_id;
    x_rxl_rec.fixed_asset_location_name := p_kle_source_rec.fixed_asset_location_name;
    x_rxl_rec.contract_line_type        := p_kle_source_rec.line_type_code;
    x_rxl_rec.line_attribute_category   := p_kle_source_rec.line_attribute_category;
    x_rxl_rec.line_attribute1           := p_kle_source_rec.line_attribute1;
    x_rxl_rec.line_attribute2           := p_kle_source_rec.line_attribute2;
    x_rxl_rec.line_attribute3           := p_kle_source_rec.line_attribute3;
    x_rxl_rec.line_attribute4           := p_kle_source_rec.line_attribute4;
    x_rxl_rec.line_attribute5           := p_kle_source_rec.line_attribute5;
    x_rxl_rec.line_attribute6           := p_kle_source_rec.line_attribute6;
    x_rxl_rec.line_attribute7           := p_kle_source_rec.line_attribute7;
    x_rxl_rec.line_attribute8           := p_kle_source_rec.line_attribute8;
    x_rxl_rec.line_attribute9           := p_kle_source_rec.line_attribute9;
    x_rxl_rec.line_attribute10          := p_kle_source_rec.line_attribute10;
    x_rxl_rec.line_attribute11          := p_kle_source_rec.line_attribute11;
    x_rxl_rec.line_attribute12          := p_kle_source_rec.line_attribute12;
    x_rxl_rec.line_attribute13          := p_kle_source_rec.line_attribute13;
    x_rxl_rec.line_attribute14          := p_kle_source_rec.line_attribute14;
    x_rxl_rec.line_attribute15          := p_kle_source_rec.line_attribute15;
  END assign_kle_rec_to_rxl_rec;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_ar_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AR Transactions
  --      Parameters      :
  --      IN              : rxhv_rec_type.source_id            IN NUMBER    Required
  --                        rxhv_rec_type.source_table         IN VARCHAR2  Required

  --                        rxhv_rec_type.khr_id               IN NUMBER    Required
  --                        rxlv_rec_type.kle_id               IN NUMBER    Optional
  --                        rxhv_rec_type.try_id               IN NUMBER    Required
  --                        rxlv_rec_type.sty_id               IN NUMBER    Optional
  --                        rxlv_rec_type.source_id            IN NUMBER    Required
  --                        rxlv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_ar_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_rxhv_rec              IN        rxhv_rec_type
   ,p_rxlv_rec              IN        rxlv_rec_type
   ,p_acc_sources_rec       IN        asev_rec_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  )
  IS
    -- Cursor to fetch header_extension_id
    CURSOR c_header_extension_id_csr (
             p_header_source_id    NUMBER
            ,p_header_source_table VARCHAR2
            ,p_khr_id              NUMBER)
    IS
      SELECT    hdr.header_extension_id     header_extension_id
        FROM    okl_ext_ar_header_sources_b hdr
       WHERE    hdr.source_id = p_header_source_id
         AND    hdr.khr_id    = p_khr_id;

    -- Cursor to fetch trans number
    CURSOR c_trans_number_csr (p_header_source_id NUMBER)
    IS
      SELECT    tai.trx_number trans_number
               ,tai.tcn_id     tai_tcn_id
        FROM    okl_trx_ar_invoices_b tai
       WHERE    tai.id = p_header_source_id;

    -- Cursor to fetch the Qte_id from the AR Transaction Header
    --
    CURSOR get_tai_tcn_qte_id_csr( p_tcn_id NUMBER)
    IS
      SELECT   tcn.qte_id  qte_id
        FROM   okl_trx_contracts_all tcn
       WHERE   tcn.id = p_tcn_id;
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'populate_ar_sources';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_khr_id               NUMBER;
    l_try_id               NUMBER;
    l_kle_id               NUMBER;
    l_sty_id               NUMBER;
    l_ledger_id            NUMBER;
    l_ledger_language      VARCHAR2(12);
    l_header_source_id     NUMBER;
    l_header_source_table  VARCHAR2(30);
    l_template_id          NUMBER;
    l_source_id            NUMBER;
    l_source_table         VARCHAR2(30);
    l_header_extension_id  NUMBER;
    l_pk_attributes        VARCHAR2(1000);
    l_tcn_id               NUMBER;
    l_line_style           VARCHAR2(30);
    l_parent_line_id       NUMBER;
    -- KHR and KLE Based Record Structures
    l_khr_source_rec       khr_source_rec_type;
    l_kle_source_rec       kle_source_rec_type;
    -- Record structures based on the Cursor Definitions
    l_termination_qte_csr_rec   c_termination_qte_csr%ROWTYPE;
    -- Record Structures based on OKL AR Extension Header and Line Tables
    -- Start : PRASJAIN : Bug# 6268782
    l_rxh_rec              rxh_rec_type;
    lx_rxh_rec             rxh_rec_type;
    l_rxhl_tbl             rxhl_tbl_type;
    lx_rxhl_tbl            rxhl_tbl_type;
    l_rxl_rec              rxl_rec_type;
    lx_rxl_rec             rxl_rec_type;
    l_rxll_tbl             rxll_tbl_type;
    lx_rxll_tbl            rxll_tbl_type;
    l_led_lang_tbl         led_lang_tbl_type;
    -- End : PRASJAIN : Bug# 6268782
    l_ledger_lang_rec      c_ledger_lang_csr%ROWTYPE;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    tl_sources_in         NUMBER := 1;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.populate_ar_sources');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validations to be done
    -- Validation 1:
    --   The following attributes should not be NULL
    --    hdr.source_id, hdr.source_table, khr_id, try_id
    --    line.source_id, line.source_table
    -- Bug 6328168: sty_id is made optional as for On-Account Credit Memo
    --                its not mandatory at all
    l_pk_attributes := NULL;
    IF p_rxhv_rec.source_id IS NULL OR
       p_rxhv_rec.source_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'RXH.SOURCE_ID';
    END IF;
    IF p_rxhv_rec.source_table IS NULL OR
       p_rxhv_rec.source_table = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'RXH.SOURCE_TABLE';
    END IF;
    IF p_rxhv_rec.khr_id IS NULL OR
       p_rxhv_rec.khr_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'KHR_ID';
    END IF;
    IF p_rxhv_rec.try_id IS NULL OR
       p_rxhv_rec.try_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'TRY_ID';
    END IF;
    -- For few Transactions kle_id is not mandatory at all ..
    -- hence knocking off kle_id as the mandatory parameter
    IF p_rxlv_rec.source_id IS NULL OR
       p_rxlv_rec.source_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'RXL.SOURCE_ID';
    END IF;
    IF p_rxlv_rec.source_table IS NULL OR
       p_rxlv_rec.source_table = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'RXL.SOURCE_TABLE';
    END IF;
    IF LENGTH(l_pk_attributes) > 0
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => l_pk_attributes);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 1 Successfull !');
    -- Validation 2:
    --   Source Table should be OKL_TXD_AR_LN_DTLS_B/OKL_TXL_ADJSTS_LNS_B
    -- Comparing with the Upper(Source_table) as billing is passing the value in the
    --  lower cases currently, need to knock this upper once billing passes it correctly
    IF UPPER(p_rxlv_rec.source_table) NOT IN ( G_TXD_AR_LN_DTLS_B, G_TXL_ADJSTS_LNS_B )
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 2 Successfull !');
    -- Copy input rec to local variable
    -- Start : PRASJAIN : Bug# 6268782
    l_rxh_rec.source_id    := p_rxhv_rec.source_id;
    l_rxh_rec.source_table := p_rxhv_rec.source_table;
    l_rxh_rec.khr_id       := p_rxhv_rec.khr_id;
    l_rxh_rec.try_id       := p_rxhv_rec.try_id;

    l_rxl_rec.kle_id       := p_rxlv_rec.kle_id;
    l_rxl_rec.sty_id       := p_rxlv_rec.sty_id;
    l_rxl_rec.source_id    := p_rxlv_rec.source_id;
    l_rxl_rec.source_table := p_rxlv_rec.source_table;
    -- End : PRASJAIN : Bug# 6268782
    -- Make sure that the source_tables are in upper case
    l_rxh_rec.source_table := UPPER(l_rxh_rec.source_table);
    l_rxl_rec.source_table := UPPER(l_rxl_rec.source_table);
    -- Copy the input parameters to the local variables
    l_header_source_id    := l_rxh_rec.source_id;
    l_header_source_table := l_rxh_rec.source_table;
    l_khr_id              := l_rxh_rec.khr_id;
    l_try_id              := l_rxh_rec.try_id;
    l_source_id           := l_rxl_rec.source_id;
    l_source_table        := l_rxl_rec.source_table;
    l_kle_id              := l_rxl_rec.kle_id;  -- For Subsidy this is will be a SUBSIDY Line but not the Asset
    l_sty_id              := l_rxl_rec.sty_id;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '**** KLE_ID = ' || l_kle_id );
    IF l_kle_id IS NOT NULL OR l_kle_id <> OKL_API.G_MISS_NUM
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor get_line_style_csr kle_id=' || l_rxl_rec.kle_id );
      FOR t_rec IN get_line_style_csr(p_kle_id => l_rxl_rec.kle_id )
      LOOP
        l_line_style       := t_rec.line_style;
        IF l_line_style = 'SUBSIDY'
        THEN
          l_parent_line_id := t_rec.parent_line_id;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '**** LINE STYLE = ' || l_line_style || ' PARENT LINE ID = ' || l_parent_line_id );
    END IF; -- IF l_kle_id IS NOT NULL OR l_kle_id <> OKL_API.G_MISS_NUM

    -- Fetch ledger id and ledger language associated to the contracts
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_khr_to_ledger_id_csr. p_khr_id=' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_khr_to_ledger_id_csr( p_khr_id => l_khr_id )
    LOOP
      l_ledger_id := t_rec.ledger_id;
    END LOOP;

    -- Fetch the ledger language in order to populate the sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_ledger_lang_csr. p_ledger_id=' || TO_CHAR(l_ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_ledger_id )
    LOOP
      l_ledger_lang_rec := t_rec;
      -- Start : PRASJAIN : Bug# 6268782
      l_led_lang_tbl(tl_sources_in).language := t_rec.language_code;
      l_rxll_tbl(tl_sources_in).language     := t_rec.language_code;
      tl_sources_in := tl_sources_in + 1;
      -- End : PRASJAIN : Bug# 6268782
    END LOOP;

    -- Logic Description:
    --   1. The OKL AR Extension Header _B/_TL sources will be captured only once
    --       for a KHR_ID.
    --   2. For every AR Transaction Line, there will be a single record in the
    --       OKL AR Extension Line _B/_TL
    --  For Eg., if a Transaction is having 10 transaction lines with two different khr_id1, khr_id2
    --  there will be only two records in the Header but 10 transaction lines in Extension Line.
    --  Hence, for every Transaction Line check whether the KHR Sources have been captured
    --  already or not by passing the Transaction ID and KHR_ID
    -- Fetch header extension id
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_header_extension_id_csr.
         p_header_source_id=' || TO_CHAR(l_header_source_id)
        || ' p_header_source_table=' || l_header_source_table
        || ' p_khr_id= ' || TO_CHAR(l_khr_id));
    l_header_extension_id := NULL;
    FOR t_rec IN c_header_extension_id_csr(
                          p_header_source_id    => l_header_source_id
                         ,p_header_source_table => l_header_source_table
                         ,p_khr_id              => l_khr_id )
    LOOP
      l_header_extension_id := t_rec.header_extension_id;
    END LOOP; -- End for c_header_extension_id_csr

    -- If l_header_extension_id is NOT NULL, then it means the KHR sources are already captured
    --   So, populate extension line sources only.
    -- Else Populate both the Extension Header and Line Sources.
    IF l_header_extension_id IS NULL
    THEN
      -- Prepare khr_source_rec_type with khr_id and ledger_language
      l_khr_source_rec.khr_id            := l_khr_id;
      -- Calling populate_khr_sources to fetch the KHR Sources
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Calling the populate_khr_sources' );
      populate_khr_sources(     -- Change : PRASJAIN : Bug# 6268782
         p_api_version      => l_api_version
        ,p_init_msg_list    => p_init_msg_list
        ,x_khr_source_rec   => l_khr_source_rec
        ,x_led_lang_tbl     => l_led_lang_tbl
        ,x_return_status    => l_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After populate_khr_sources: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Assign the KHR Sources to the rxhv_rec
      assign_khr_rec_to_rxh_rec(
         p_khr_source_rec => l_khr_source_rec
        ,x_rxh_rec => l_rxh_rec );

      -- Start : PRASJAIN : Bug# 6268782
      FOR tl_sources_in IN l_led_lang_tbl.FIRST .. l_led_lang_tbl.LAST
      LOOP
        l_rxhl_tbl(tl_sources_in).language          := l_led_lang_tbl(tl_sources_in).language;
        l_rxhl_tbl(tl_sources_in).contract_status   := l_led_lang_tbl(tl_sources_in).contract_status;
        l_rxhl_tbl(tl_sources_in).inv_agrmnt_status := l_led_lang_tbl(tl_sources_in).inv_agrmnt_status;

        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_trx_type_name_csr. p_try_id=' ||
          l_try_id || 'p_led_lang= ' || l_rxhl_tbl(tl_sources_in).language );
        FOR t_rec IN c_trx_type_name_csr(
                      p_try_id    => l_try_id
                     ,p_led_lang  => l_rxhl_tbl(tl_sources_in).language ) -- Change : PRASJAIN : Bug# 6268782
        LOOP
          l_rxhl_tbl(tl_sources_in).transaction_type_name := t_rec.transaction_type_name;-- Change : PRASJAIN : Bug# 6268782
          -- Assign the Trx. Type Class Code also.
          l_rxh_rec.trx_type_class_code  := t_rec.trx_type_class_code;
        END LOOP; -- End for c_trx_type_name_csr
      END LOOP;
      -- End : PRASJAIN : Bug# 6268782


      -- Fetch the Transaction Number
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_trans_number_csr. p_header_source_id=' || l_header_source_id );
      FOR t_rec IN c_trans_number_csr( p_header_source_id => l_header_source_id )
      LOOP
        l_rxh_rec.trans_number  := t_rec.trans_number;
        l_tcn_id                := t_rec.tai_tcn_id;
      END LOOP; -- End for c_trans_number_csr

      -- Fetch the Transaction Number
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor get_tai_tcn_qte_id_csr. p_tcn_id=' || l_tcn_id );
      FOR t_rec IN get_tai_tcn_qte_id_csr(p_tcn_id => l_tcn_id )
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_termination_qte_csr. l_qte_id=' || t_rec.qte_id );
        -- Cursor to fetch termination quote attr
        FOR l_termination_qte_csr_rec IN  c_termination_qte_csr (l_qte_id => t_rec.qte_id)
        LOOP
          l_rxh_rec.term_quote_accept_date := l_termination_qte_csr_rec.date_effective_from;
          l_rxh_rec.term_quote_num         := l_termination_qte_csr_rec.quote_number;
          l_rxh_rec.term_quote_type_code   := l_termination_qte_csr_rec.qtp_code;
        END LOOP;  -- c_termination_qte_csr
      END LOOP;

      IF(p_acc_sources_rec.jtf_sales_reps_pk IS NOT NULL AND
         p_acc_sources_rec.jtf_sales_reps_pk <> OKL_API.G_MISS_CHAR) THEN
         -- Need to populate the Sales Representative Name
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Executing the Cursor  c_sales_rep_acc_sources_csr. l_sales_rep_id = ' ||
             TO_CHAR(p_acc_sources_rec.jtf_sales_reps_pk) );
         FOR t_rec IN  c_sales_rep_acc_sources_csr (p_jtf_sales_rep_pk => p_acc_sources_rec.jtf_sales_reps_pk)
         LOOP
           l_rxh_rec.sales_rep_name := t_rec.name;

         END LOOP;  -- c_sales_rep_acc_sources_csr
      END IF;

      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'Calling the okl_ar_extension_pvt.create_rxh_extension ' || l_rxh_rec.source_id );
      okl_ar_extension_pvt.create_rxh_extension(      -- Change : PRASJAIN : Bug# 6268782
         p_api_version     => l_api_version
        ,p_init_msg_list   => p_init_msg_list
        ,x_return_status   => l_return_status
        ,x_msg_count       => x_msg_count
        ,x_msg_data        => x_msg_data
        ,p_rxh_rec         => l_rxh_rec
        ,p_rxhl_tbl        => l_rxhl_tbl
        ,x_rxh_rec         => lx_rxh_rec
        ,x_rxhl_tbl        => lx_rxhl_tbl
      );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After okl_ar_extension_pvt.create_rxh_extension: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store the Header Extension ID into the Local Variable l_header_extension_id
      l_header_extension_id := lx_rxh_rec.header_extension_id;
    END IF;
    IF l_kle_id IS NOT NULL AND
       l_kle_id <> OKL_API.G_MISS_NUM
    THEN
      -- Start populating the Sources at the Extension Line Level
      -- Prepare kle_source_rec_type with khr_id, kle_id and ledger_language
      l_kle_source_rec.khr_id            := l_khr_id;
      l_kle_source_rec.kle_id            := l_kle_id;
      IF l_line_style = 'SUBSIDY'
      THEN
        -- If the Line Style is SUBSIDY, then pass the Asset line id to the
        --  Populate KLE Sources to fetch the Asset Details
        l_kle_source_rec.kle_id            := l_parent_line_id;
      END IF;
      -- Calling populate_kle_sources only when kle_id is not NULL or G_MISS_NUM
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Before Calling the populate_kle_sources' );
      populate_kle_sources(
        p_api_version      => l_api_version
       ,p_init_msg_list    => p_init_msg_list
       ,x_kle_source_rec   => l_kle_source_rec
       ,x_return_status    => l_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After populate_kle_sources: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- calling assign_kle_rec_to_rxlv_rec
      assign_kle_rec_to_rxl_rec(
         p_kle_source_rec => l_kle_source_rec
         ,x_rxl_rec => l_rxl_rec );
      -- Fetch fee type code
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_k_lines_csr. p_kle_id= ' || TO_CHAR(l_kle_id));
      FOR t_rec  IN c_k_lines_csr ( p_kle_id => l_kle_id )
      LOOP
        l_rxl_rec.fee_type_code := t_rec.fee_type;
      END LOOP;  -- End for c_k_lines_csr

      -- Fetch asset category name
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_manufacture_model_csr. p_kle_id= ' || TO_CHAR(l_kle_id)
        || ' p_khr_id= ' || TO_CHAR(l_khr_id));
      FOR t_rec  IN c_manufacture_model_csr ( p_kle_id => l_kle_id, p_khr_id => l_khr_id )
      LOOP
        l_rxl_rec.asset_category_name := t_rec.asset_category_name;
      END LOOP;  -- End for c_manufacture_model_csr

      FOR tl_sources_in IN l_rxll_tbl.FIRST .. l_rxll_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_inventory_item_name_csr. p_inventory_item_id_pk1= ' ||
          to_char(p_acc_sources_rec.inventory_item_id_pk1) || ' p_inventory_org_id_pk2=' ||
          to_char(p_acc_sources_rec.inventory_org_id_pk2) || ' ledger_language=' ||
          l_rxll_tbl(tl_sources_in).language );
        FOR t_rec IN c_inventory_item_name_csr(
                     p_inventory_item_id_pk1 => p_acc_sources_rec.inventory_item_id_pk1
                    ,p_inventory_org_id_pk2  => p_acc_sources_rec.inventory_org_id_pk2
                    ,p_ledger_language       => l_rxll_tbl(tl_sources_in).language)
        LOOP
          l_rxll_tbl(tl_sources_in).inventory_item_name      := t_rec.description;
          l_rxl_rec.inventory_item_name_code := t_rec.b_description;
        END LOOP;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Fetching the Subsidy Sources LINE_STYLE =' || l_line_style );
      IF l_line_style = 'SUBSIDY'
      THEN
        -- Fetch Subsidy Name and Subsidy Party Name
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the curosr get_subsidy_details_csr. p_kle_id= ' || TO_CHAR(l_kle_id));
        FOR t_rec  IN get_subsidy_details_csr ( p_kle_id => l_kle_id )
        LOOP
          l_rxl_rec.subsidy_name       := t_rec.subsidy_name;
          l_rxl_rec.subsidy_party_name := t_rec.subsidy_party_name;
          -- added by zrehman Bug#6707320 for Party Merge impact on Transaction sources tables start
	  l_rxl_rec.subsidy_vendor_id := t_rec.subsidy_vendor_id;
          -- added by zrehman Bug#6707320 for Party Merge impact on Transaction sources tables end
        END LOOP;  -- End for c_k_lines_csr
      END IF;
    --ELSE
      -- Populate the l_pxlv_rec with the khr_id, ledger_language
      -- but not with the kle_id
      -- l_rxl_rec.language := l_ledger_language ;
    END IF; -- IF l_kle_id IS NOT NULL OR l_kle_id <> OKL_API.G_MISS_NUM

    -- Stamp the Header Extension ID on the Extension Line Table
    l_rxl_rec.header_extension_id := l_header_extension_id;

    -- Fetch the Account Template ID
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the curosr c_account_dist_csr. p_source_id= ' || to_char(l_source_id)
      || ' p_source_table= ' || to_char(l_source_table));
    FOR t_rec  IN c_account_dist_csr (
                    p_source_id    => l_source_id
                   ,p_source_table => l_source_table)
    LOOP
      l_template_id := t_rec.template_id;
    END LOOP;  -- End for c_account_dist_csr

    -- Assigning the Memo Indicator to the Extension Line Record structure ..
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '** AGS Memo Flag ' || p_acc_sources_rec.memo_yn );
    l_rxl_rec.memo_flag := p_acc_sources_rec.memo_yn;

    -- Fetch Memo Flag and Accounting Template Name using the template_id
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the curosr c_ae_templates_csr. template_id= ' || to_char(l_template_id) );
    FOR t_rec  IN c_ae_templates_csr (p_template_id => l_template_id)
    LOOP
      l_rxl_rec.accounting_template_name := t_rec.name;
    END LOOP;  -- End for c_ae_templates_csr

    -- Bug 6328168: STY_ID is Optional
    IF l_sty_id IS NOT NULL
    THEN
      -- Fetch contingency code and stream type name
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_contingency_strm_b_csr. p_sty_id= ' || TO_CHAR(l_sty_id)
        || ' Ledger Language = ' || l_ledger_language);
      FOR t_rec  IN c_contingency_strm_b_csr ( p_sty_id => l_sty_id )
      LOOP
        l_rxl_rec.contingency_code         := t_rec.contingency_code;
        l_rxl_rec.stream_type_code         := t_rec.stream_type_code;
        l_rxl_rec.stream_type_purpose_code := t_rec.stream_type_purpose;
      END LOOP;  -- End for c_contingency_strm_b_csr
    END IF; -- IF l_sty_id IS NOT NULL

    -- Fetch contingency code and stream type name
    FOR tl_sources_in IN l_rxll_tbl.FIRST .. l_rxll_tbl.LAST
    LOOP
      -- Bug 6328168: STY_ID is Optional
      IF l_sty_id IS NOT NULL
      THEN
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the curosr c_strm_name_tl_csr. p_sty_id= ' || TO_CHAR(l_sty_id)
          || ' Ledger Language = ' || l_rxll_tbl(tl_sources_in).language);
        FOR t_rec  IN c_strm_name_tl_csr ( p_sty_id => l_sty_id, p_lang => l_rxll_tbl(tl_sources_in).language )
        LOOP
          l_rxll_tbl(tl_sources_in).stream_type_name := t_rec.stream_type_name;
        END LOOP;  -- End for c_strm_name_tl_csr
      END IF; --  IF l_sty_id IS NOT NULL
      -- Unable to find the corresponding Transaction Line Description Column in okl_txl_adjsts_lns_all_tl Table
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_tld_line_description. p_tld_tl_id= ' || TO_CHAR(l_source_id)
        || ' p_lang = ' || l_rxll_tbl(tl_sources_in).language);
      FOR t_rec IN c_tld_line_description (
                     p_tld_tl_id => l_source_id
                    ,p_lang      => l_rxll_tbl(tl_sources_in).language )
      LOOP
        l_rxll_tbl(tl_sources_in).trans_line_description := t_rec.trans_line_description;
      END LOOP;
    END LOOP; -- Loop on l_rxll_tbl

    IF(p_acc_sources_rec.inventory_org_id_pk2 IS NOT NULL AND
       p_acc_sources_rec.inventory_org_id_pk2 <> OKL_API.G_MISS_CHAR) THEN
       -- Populate Inventory Organization Name
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
         '*** AGS Inventory Org ID used to fetch teh Inventory Organization Code : Org ID=' ||
         p_acc_sources_rec.inventory_org_id_pk2 );
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
         'Executing the Cursor c_org_name_code_csr. p_org_id= ' || TO_CHAR(p_acc_sources_rec.inventory_org_id_pk2) );
       FOR t_rec IN c_org_name_code_csr(
                       p_org_id      => p_acc_sources_rec.inventory_org_id_pk2 )
       LOOP
         l_rxl_rec.inventory_org_code := t_rec.org_name;
       END LOOP;

       FOR tl_sources_in IN l_rxll_tbl.FIRST .. l_rxll_tbl.LAST
       LOOP
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Executing the Cursor c_org_name_csr. p_org_id= ' || TO_CHAR(p_acc_sources_rec.inventory_org_id_pk2) ||
           ' ledger_language=' || l_rxll_tbl(tl_sources_in).language );
         FOR t_rec IN c_org_name_csr(
                         p_org_id      => p_acc_sources_rec.inventory_org_id_pk2
                        ,p_ledger_lang => l_rxll_tbl(tl_sources_in).language )
         LOOP
           l_rxll_tbl(tl_sources_in).inventory_org_name := t_rec.org_name;
         END LOOP;
       END LOOP;
    END IF;

    -- Calling insert_row
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_ar_extension_pvt.create_rxl_extension source_id=' || l_rxl_rec.source_id );
    okl_ar_extension_pvt.create_rxl_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_rxl_rec         => l_rxl_rec
      ,p_rxll_tbl        => l_rxll_tbl
      ,x_rxl_rec         => lx_rxl_rec
      ,x_rxll_tbl        => lx_rxll_tbl
     );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_ar_extension_pvt.create_rxl_extension: l_return_status ' || l_return_status );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.populate_ar_sources');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_ar_sources;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AR Transactions
  --      Parameters      :
  --      IN              :
  --                        rxhv_rec_type.source_id            IN NUMBER    Required
  --                        rxhv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_rxhv_rec              IN        rxhv_rec_type
   ,p_rxlv_tbl              IN        rxlv_tbl_type
   ,p_acc_sources_tbl       IN        asev_tbl_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  )
  IS
    -- Cursor to fetch source_id, khr_id, kle_id,
    -- sty_id, try_id
    CURSOR c_trx_ar_inv_lines_csr (p_header_source_id NUMBER)
    IS
      SELECT    tld.id                 source_id
               ,'OKL_TXD_AR_LN_DTLS_B' source_table
               ,tld.khr_id             khr_id
               ,tld.kle_id             kle_id
               ,tld.sty_id             sty_id
               ,tai.try_id             try_id
       FROM     okl_trx_ar_invoices_b tai
               ,okl_txl_ar_inv_lns_b  til
               ,okl_txd_ar_ln_dtls_b  tld
      WHERE     tld.til_id_details = til.id
        AND     til.tai_id = tai.id
        AND     tai.id = p_header_source_id;

    -- Cursor to fetch source_id, khr_id, kle_id,
    -- sty_id, try_id
    CURSOR c_trx_ar_adj_lines_csr (p_header_source_id NUMBER)
     IS
      SELECT    adjl.id                                 source_id
               ,'OKL_TXL_ADJSTS_LNS_B'                  source_table
               ,adjl.khr_id                             khr_id
               ,adjl.kle_id                             kle_id
               ,adjl.sty_id                             sty_id
               ,adj.try_id                              try_id
       FROM     okl_trx_ar_adjsts_all_b   adj
               ,okl_txl_adjsts_lns_all_b  adjl
      WHERE     adj.id = adjl.adj_id
        AND     adj.id = p_header_source_id;

    -- Data structures based on the Cursor Variables
    TYPE c_trx_ar_inv_lines_tbl IS TABLE OF c_trx_ar_inv_lines_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_trx_ar_inv_lines_tbl     c_trx_ar_inv_lines_tbl;
    TYPE c_trx_ar_adj_lines_tbl IS TABLE OF c_trx_ar_adj_lines_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_trx_ar_adj_lines_tbl     c_trx_ar_adj_lines_tbl;
    tld_count                  NUMBER; -- Count of the l_trx_ar_inv_lines_tbl
    tld_index                  NUMBER; -- Index for the l_trx_ar_inv_lines_tbl
    rxl_index                  NUMBER; -- Index for the l_rxlv_tbl
    l_acc_srcs_index           NUMBER; -- Index for the p_acc_sources_tbl
    l_capture_sources          VARCHAR2(3); -- Flag to decide whether to Capture Sources or Not !
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'POPULATE_SOURCES-AR';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_header_source_id            NUMBER;
    l_header_source_table         VARCHAR2(30);
    l_rxhv_rec                    rxhv_rec_type;
    l_rxlv_rec                    rxlv_rec_type;
    l_rxlv_tbl                    rxlv_tbl_type;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Validation 1: Source ID and Source Table should not be NULL in the
    --   AR Extension Header Record Structure
    IF (p_rxhv_rec.source_id      IS NULL OR
        p_rxhv_rec.source_table   IS NULL)
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_ID_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Header SOURCE_ID= ' || p_rxhv_rec.source_id || '  SOURCE_TABLE=' || p_rxhv_rec.source_table );
    -- Validation 2: The Header Source Table should be either the
    --  OKL AR Invoice Trx Header or OKL AR Adjustment Trx. Header table only
    --   ie. it should be either OKL_TRX_AR_INVOICES_B or OKL_TRX_AR_ADJSTS_B only
    IF UPPER(p_rxhv_rec.source_table) NOT IN ( G_TRX_AR_INVOICES_B, G_TRX_AR_ADJSTS_B)
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Copy to local variables
    l_rxhv_rec              := p_rxhv_rec;
    l_rxhv_rec.source_table := UPPER(p_rxhv_rec.source_table);
    l_header_source_id      := p_rxhv_rec.source_id;
    l_header_source_table   := UPPER(p_rxhv_rec.source_table);
    l_rxlv_tbl              := p_rxlv_tbl;
    -- Validation 3: There should be atleast one Transaction Detail Line
    --  for which the Populate AR Sources should be called
    IF l_rxlv_tbl.COUNT = 0
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'RXLV_TBL.COUNT()');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Validation 4: p_rxlv_tbl.COUNT should be equal to the p_acc_sources_tbl.COUNT
    IF l_rxlv_tbl.COUNT <> p_acc_sources_tbl.COUNT
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'P_ACC_SOURCES_TBL.COUNT()');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Loop on the details for the current transaction header
    -- Call the populate_tld_sources
    IF l_header_source_table = 'OKL_TRX_AR_INVOICES_B'
    THEN
      -- As we wanted to store the records in the PL/SQL table starting from 1
      -- and after the loop, the tld_index should be nothing but the count of the
      -- Transaction Detail Lines fetched ...
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_trx_ar_inv_lines_csr. p_header_source_id=' ||
           TO_CHAR(l_header_source_id));
      -- Initialize the tld_count to ZERO
      tld_count  := 0;
      FOR t_rec IN c_trx_ar_inv_lines_csr( p_header_source_id => l_header_source_id )
      LOOP
        -- Increment the tld_count
        tld_count := tld_count + 1;
        -- Store the Current Record in the PL/SQL Table for further usage
        l_trx_ar_inv_lines_tbl(tld_count) := t_rec;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Number of Transaction Detail Lines present in DB     = ' || TO_CHAR(tld_count) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Number of Transaction Detail Lines passed to the API = ' || TO_CHAR(l_rxlv_tbl.COUNT) );
      FOR tld_index IN l_trx_ar_inv_lines_tbl.FIRST .. l_trx_ar_inv_lines_tbl.LAST
      LOOP
        -- Logic Explanation:
        -- 1. Check for the Count of the Trx. Detail Lines fetched from DB
        -- 2. Compare this count with the count of Trx. Detail Lines passed to this API
        -- 3. If the count is same, then, capture sources for every Trx. Detail Line
        --    otherwise, capture sources for only those transaction detail line, which have
        --    been passed by the Accounting Engine
        l_capture_sources := 'N';
        l_acc_srcs_index  := NULL;
        rxl_index := l_rxlv_tbl.FIRST;
        LOOP
          IF l_rxlv_tbl(rxl_index).source_id    = l_trx_ar_inv_lines_tbl(tld_index).source_id AND
             l_rxlv_tbl(rxl_index).source_table = l_trx_ar_inv_lines_tbl(tld_index).source_table
          THEN
            -- Need to the Call the Populate AR Sources for this Transaction Detail Line
            l_capture_sources := 'Y';
            -- Assumption: p_rxlv_tbl and p_acc_sources_tbl are populated using the Same Index.
            l_acc_srcs_index  := rxl_index;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Case 2: Populate Sources has been asked to capture sources for the Current Transaction Detail by Accounting Engine ' ||
              ' TXD ID = ' || TO_CHAR( l_trx_ar_inv_lines_tbl(tld_index).source_id ) );
          END IF;
          -- Exit when this is the Last Record or the Transaction Details has been found
          EXIT WHEN ( rxl_index = l_rxlv_tbl.LAST )  -- When reached End of the Table
                 OR ( l_capture_sources = 'Y'     ); -- Or When the TXD has been found
          -- Increment the rxl_index
          rxl_index := l_rxlv_tbl.NEXT( rxl_index );
        END LOOP; -- Loop on l_rxlv_tbl ..

        IF l_capture_sources = 'Y'
        THEN
          -- If the AGS Index is not found then return error
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'Account Generator Sources Index =' || TO_CHAR(l_acc_srcs_index)  );
          IF l_acc_srcs_index IS NULL OR
             ( p_acc_sources_tbl.EXISTS(l_acc_srcs_index) = FALSE )
          THEN
            -- accounting_event_class_code is missing
            OKL_API.set_message(
               p_app_name      => G_APP_NAME
              ,p_msg_name      => G_INVALID_VALUE
              ,p_token1        => G_COL_NAME_TOKEN
              ,p_token1_value  => 'AGS_SOURCES_INDEX');
            l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF; -- IF l_acc_sources_found = FALSE

          -- l_rxhv_rec.source_id and l_rxhv_rec.source_table are already assigned
          l_rxhv_rec.khr_id    := l_trx_ar_inv_lines_tbl(tld_index).khr_id;
          l_rxhv_rec.try_id    := l_trx_ar_inv_lines_tbl(tld_index).try_id;
          -- Id of Detail Line Table
          l_rxlv_rec.source_id := l_trx_ar_inv_lines_tbl(tld_index).source_id;
          l_rxlv_rec.source_table := l_trx_ar_inv_lines_tbl(tld_index).source_table;
          l_rxlv_rec.kle_id    := l_trx_ar_inv_lines_tbl(tld_index).kle_id;
          l_rxlv_rec.sty_id    := l_trx_ar_inv_lines_tbl(tld_index).sty_id;
          -- The populate_tld_sources will capture sources at extension line level always
          -- If the extension header sources with the l_rxlv_rec.source_id and l_rxhv_rec.khr_id is not captured
          -- Then only capture the extension header sources
          -- Calling populate_tld_sources
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'Calling the populate_ar_sources' );
          populate_ar_sources(
            p_api_version       => l_api_version
           ,p_init_msg_list     => p_init_msg_list
           ,p_rxhv_rec          => l_rxhv_rec
           ,p_rxlv_rec          => l_rxlv_rec
           ,p_acc_sources_rec   => p_acc_sources_tbl(l_acc_srcs_index)
           ,x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'After populate_ar_sources: l_return_status ' || l_return_status );
          -- Check the return status and if errored, return the error back
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- IF l_capture_sources = 'Y'
      END LOOP; -- Loop on l_trx_ar_inv_lines_tbl ..
    ELSE
      -- As we wanted to store the records in the PL/SQL table starting from 1
      -- and after the loop, the tld_index should be nothing but the count of the
      -- Transaction Detail Lines fetched ...
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_trx_ar_adj_lines_csr. p_header_source_id=' ||
           TO_CHAR(l_header_source_id));
      -- Initialize the tld_count to ZERO
      tld_count  := 0;
      FOR t_rec IN c_trx_ar_adj_lines_csr( p_header_source_id => l_header_source_id )
      LOOP
        -- Increment the tld_count
        tld_count := tld_count + 1;
        -- Store the Current Record in the PL/SQL Table for further usage
        l_trx_ar_adj_lines_tbl(tld_count) := t_rec;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Number of Transaction Detail Lines present in DB     = ' || TO_CHAR(tld_count) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Number of Transaction Detail Lines passed to the API = ' || TO_CHAR(l_rxlv_tbl.COUNT) );
      FOR tld_index IN l_trx_ar_adj_lines_tbl.FIRST .. l_trx_ar_adj_lines_tbl.LAST
      LOOP
        -- Logic Explanation:
        -- 1. Check for the Count of the Trx. Detail Lines fetched from DB
        -- 2. Compare this count with the count of Trx. Detail Lines passed to this API
        -- 3. If the count is same, then, capture sources for every Trx. Detail Line
        --    otherwise, capture sources for only those transaction detail line, which have
        --    been passed by the Accounting Engine
        l_capture_sources := 'N';
        l_acc_srcs_index  := NULL;
        rxl_index := l_rxlv_tbl.FIRST;
        LOOP
          IF l_rxlv_tbl(rxl_index).source_id    = l_trx_ar_adj_lines_tbl(tld_index).source_id AND
             l_rxlv_tbl(rxl_index).source_table = l_trx_ar_adj_lines_tbl(tld_index).source_table
          THEN
            -- Need to the Call the Populate AR Sources for this Transaction Detail Line
            l_capture_sources := 'Y';
            -- Assumption: p_rxlv_tbl and p_acc_sources_tbl are populated using the Same Index.
            l_acc_srcs_index  := rxl_index;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Case 2: Populate Sources has been asked to capture sources for the Current Transaction Detail by Accounting Engine ' ||
              ' TXD ID = ' || TO_CHAR( l_trx_ar_adj_lines_tbl(tld_index).source_id ) );
          END IF;
          -- Exit when this is the Last Record or the Transaction Details has been found
          EXIT WHEN ( rxl_index = l_rxlv_tbl.LAST )  -- When reached End of the Table
                 OR ( l_capture_sources = 'Y'     ); -- Or When the TXD has been found
          -- Increment the rxl_index
          rxl_index := l_rxlv_tbl.NEXT( rxl_index );
        END LOOP; -- Loop on l_rxlv_tbl ..

        IF l_capture_sources = 'Y'
        THEN
          -- If the AGS Index is not found then return error
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'Account Generator Sources Index =' || TO_CHAR(l_acc_srcs_index)  );
          IF l_acc_srcs_index IS NULL OR
             ( p_acc_sources_tbl.EXISTS(l_acc_srcs_index) = FALSE )
          THEN
            -- accounting_event_class_code is missing
            OKL_API.set_message(
               p_app_name      => G_APP_NAME
              ,p_msg_name      => G_INVALID_VALUE
              ,p_token1        => G_COL_NAME_TOKEN
              ,p_token1_value  => 'AGS_SOURCES_INDEX');
            l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF; -- IF l_acc_sources_found = FALSE

          -- l_rxhv_rec.source_id and l_rxhv_rec.source_table are already assigned
          l_rxhv_rec.khr_id    := l_trx_ar_adj_lines_tbl(tld_index).khr_id;
          l_rxhv_rec.try_id    := l_trx_ar_adj_lines_tbl(tld_index).try_id;
          -- Id of Detail Line Table
          l_rxlv_rec.source_id := l_trx_ar_adj_lines_tbl(tld_index).source_id;
          l_rxlv_rec.source_table := l_trx_ar_adj_lines_tbl(tld_index).source_table;
          l_rxlv_rec.kle_id    := l_trx_ar_adj_lines_tbl(tld_index).kle_id;
          l_rxlv_rec.sty_id    := l_trx_ar_adj_lines_tbl(tld_index).sty_id;
--          l_rxlv_rec.trans_line_description := l_trx_ar_adj_lines_tbl(tld_index).trans_line_description;
          -- The populate_tld_sources will capture sources at extension line level always
          -- If the extension header sources with the l_rxlv_rec.source_id and l_rxhv_rec.khr_id is not captured
          -- Then only capture the extension header sources
          -- Calling populate_tld_sources
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'Calling the populate_ar_sources' );
          populate_ar_sources(
            p_api_version       => l_api_version
           ,p_init_msg_list     => p_init_msg_list
           ,p_rxhv_rec          => l_rxhv_rec
           ,p_rxlv_rec          => l_rxlv_rec
           ,p_acc_sources_rec   => p_acc_sources_tbl(l_acc_srcs_index)
           ,x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'After populate_ar_sources: l_return_status ' || l_return_status );
          -- Check the return status and if errored, return the error back
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- IF l_capture_sources = 'Y'
      END LOOP; -- Loop on l_trx_ar_adj_lines_tbl ..
    END IF; -- IF l_header_source_table = 'OKL_TRX_AR_INVOICES_B'
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                           p_api_name  => l_api_name
                          ,p_pkg_name  => G_PKG_NAME
                          ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                          ,x_msg_count  => x_msg_count
                          ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_sources;

  PROCEDURE delete_ar_extension(
    p_api_version               IN              NUMBER
   ,p_init_msg_list             IN              VARCHAR2
   ,p_rxhv_rec                  IN              rxhv_rec_type
   ,x_rxlv_tbl                  OUT    NOCOPY   rxlv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'DELETE_TRX_EXTENSION';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    rxl_index          BINARY_INTEGER;
    l_rxhv_rec         okl_rxh_pvt.rxhv_rec_type;
    l_rxlv_tbl         okl_rxl_pvt.rxlv_tbl_type;
    lx_rxhv_rec        okl_rxh_pvt.rxhv_rec_type;
    lx_rxlv_tbl        okl_rxl_pvt.rxlv_tbl_type;
    -- Cursor Definitions
    CURSOR get_ar_ext_hdr_id( p_source_id  NUMBER, p_source_table VARCHAR2)
    IS
      SELECT   rxh.header_extension_id      header_extension_id
        FROM   okl_ext_ar_header_sources_b	rxh
       WHERE   rxh.source_id = p_source_id
         AND   rxh.source_table = p_source_table;

    CURSOR get_ar_ext_lns_id( p_hdr_ext_id  NUMBER)
    IS
      SELECT   rxl.line_extension_id     line_extension_id
              ,rxl.source_id             source_id
              ,rxl.source_table          source_table
        FROM   okl_ext_ar_line_sources_b rxl
       WHERE   rxl.header_extension_id = p_hdr_ext_id;
    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.DELETE_TRX_EXTENSION');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual Logic Starts Here ..
    l_rxhv_rec := p_rxhv_rec;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Source ID=' || to_char(l_rxhv_rec.source_id) || 'Source Header Table=' || l_rxhv_rec.source_table );
    IF ( l_rxhv_rec.source_id = OKL_API.G_MISS_NUM or l_rxhv_rec.source_id IS NULL )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF ( l_rxhv_rec.source_table = OKL_API.G_MISS_CHAR or l_rxhv_rec.source_table IS NULL
        OR l_rxhv_rec.source_table NOT IN ( G_TRX_AR_INVOICES_B, G_TRX_AR_ADJSTS_B) )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Initialize the rxl_index
    rxl_index := 1;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Fetch the Extension Header ID by executing cursor get_txl_ext_hdr_id' );
    FOR t_rec IN get_ar_ext_hdr_id(
                    p_source_id     => l_rxhv_rec.source_id
                   ,p_source_table  => l_rxhv_rec.source_table)
    LOOP
      -- Note that for a given Source ID and Source Table in OKL_EXT_AR_HEADER_SOURCES_B
      --  there can be multiple records each having different KHR_ID ..
      l_rxhv_rec.header_extension_id := t_rec.header_extension_id;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Extension Header ID To be Deleted='  || TO_CHAR(l_rxhv_rec.header_extension_id));
      -- Fetch the Transaction Extension Line IDs to be deleted
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Extension Line ID(s) To be Deleted=');
      FOR t_rec IN get_ar_ext_lns_id( p_hdr_ext_id  => l_rxhv_rec.header_extension_id)
      LOOP
        l_rxlv_tbl(rxl_index).line_extension_id  := t_rec.line_extension_id;
        l_rxlv_tbl(rxl_index).source_id          := t_rec.source_id;
        l_rxlv_tbl(rxl_index).source_table       := t_rec.source_table;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'LINE_EXTENSION_ID[' || rxl_index || '] = ' || TO_CHAR(l_rxlv_tbl(rxl_index).line_extension_id) );
        -- Increment i
        rxl_index := rxl_index + 1;
      END LOOP; -- End get_trans_line_ids
      -- Call the Wrapper API to delete the Extension Lines and then Header
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'calling the okl_ar_extension_pvt.delete_rxh_extension Line Count=' || l_rxlv_tbl.COUNT );
      okl_ar_extension_pvt.delete_rxh_extension(
        p_api_version     => p_api_version
       ,p_init_msg_list   => p_init_msg_list
       ,x_return_status   => x_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
       ,p_rxhv_rec        => l_rxhv_rec
      );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'After okl_ar_extension_pvt.delete_rxh_extension: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP; -- Loop on the get_ar_ext_hdr_id
    -- Store the Transaction Line IDs and Line Source Tables so as to return back
    x_rxlv_tbl := l_rxlv_tbl;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.DELETE_TRX_EXTENSION');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END delete_ar_extension;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : assign_khr_rec_to_pxhv_rec
  --      Pre-reqs        : None
  --      Function        : assign khr rec to pxhv rec for AP OKL Transactions
  --      Parameters      :
  --      IN              : p_khr_source_rec     khr_source_rec_type
  --      OUT             : x_pxhv_rec           pxhv_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------
  -- Changes for Bug# 6268782 : PRASJAIN
  -- 1. func name assign_khr_rec_to_pxhv_rec to assign_khr_rec_to_pxh_rec
  -- 2. out param pxhv_rec_type to pxh_rec_type
  ------------------------------------------------------------------------------
  PROCEDURE assign_khr_rec_to_pxh_rec(
    p_khr_source_rec  IN       khr_source_rec_type
   ,x_pxh_rec         IN OUT   NOCOPY pxh_rec_type
  )
  AS
  BEGIN
    x_pxh_rec.khr_id                  := p_khr_source_rec.khr_id;
    x_pxh_rec.contract_number         := p_khr_source_rec.contract_number;
    x_pxh_rec.customer_name           := p_khr_source_rec.customer_name;
    x_pxh_rec.cust_account_number     := p_khr_source_rec.customer_account_number;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    x_pxh_rec.party_id                := p_khr_source_rec.customer_id;
    x_pxh_rec.cust_account_id         := p_khr_source_rec.cust_account_id;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    x_pxh_rec.contract_currency_code  := p_khr_source_rec.contract_currency_code;
    x_pxh_rec.contract_effective_from := p_khr_source_rec.contract_effective_from;
    x_pxh_rec.product_name            := p_khr_source_rec.product_name;
    x_pxh_rec.book_classification_code:= p_khr_source_rec.book_classification_code;
    x_pxh_rec.tax_owner_code          := p_khr_source_rec.tax_owner_code;
    x_pxh_rec.rev_rec_method_code     := p_khr_source_rec.rev_rec_method_code;
    x_pxh_rec.int_calc_method_code    := p_khr_source_rec.int_calc_method_code;
    x_pxh_rec.vendor_program_number   := p_khr_source_rec.vendor_program_number;
    x_pxh_rec.converted_number        := p_khr_source_rec.converted_number;
    x_pxh_rec.converted_account_flag  := p_khr_source_rec.converted_account_flag;
    x_pxh_rec.assignable_flag         := p_khr_source_rec.assignable_flag;
    x_pxh_rec.po_order_number         := p_khr_source_rec.po_order_number;
    x_pxh_rec.accrual_override_flag   := p_khr_source_rec.accrual_override_flag;
    x_pxh_rec.rent_ia_contract_number := p_khr_source_rec.rent_ia_contract_number;
    x_pxh_rec.rent_ia_product_name    := p_khr_source_rec.rent_ia_product_name;
    x_pxh_rec.rent_ia_accounting_code := p_khr_source_rec.rent_ia_accounting_code;
    x_pxh_rec.res_ia_contract_number  := p_khr_source_rec.res_ia_contract_number;
    x_pxh_rec.res_ia_product_name     := p_khr_source_rec.res_ia_product_name;
    x_pxh_rec.res_ia_accounting_code  := p_khr_source_rec.res_ia_accounting_code;
    x_pxh_rec.khr_attribute_category  := p_khr_source_rec.khr_attribute_category;
    x_pxh_rec.khr_attribute1          := p_khr_source_rec.khr_attribute1;
    x_pxh_rec.khr_attribute2          := p_khr_source_rec.khr_attribute2;
    x_pxh_rec.khr_attribute3          := p_khr_source_rec.khr_attribute3;
    x_pxh_rec.khr_attribute4          := p_khr_source_rec.khr_attribute4;
    x_pxh_rec.khr_attribute5          := p_khr_source_rec.khr_attribute5;
    x_pxh_rec.khr_attribute6          := p_khr_source_rec.khr_attribute6;
    x_pxh_rec.khr_attribute7          := p_khr_source_rec.khr_attribute7;
    x_pxh_rec.khr_attribute8          := p_khr_source_rec.khr_attribute8;
    x_pxh_rec.khr_attribute9          := p_khr_source_rec.khr_attribute9;
    x_pxh_rec.khr_attribute10         := p_khr_source_rec.khr_attribute10;
    x_pxh_rec.khr_attribute11         := p_khr_source_rec.khr_attribute11;
    x_pxh_rec.khr_attribute12         := p_khr_source_rec.khr_attribute12;
    x_pxh_rec.khr_attribute13         := p_khr_source_rec.khr_attribute13;
    x_pxh_rec.khr_attribute14         := p_khr_source_rec.khr_attribute14;
    x_pxh_rec.khr_attribute15         := p_khr_source_rec.khr_attribute15;
    x_pxh_rec.cust_attribute_category := p_khr_source_rec.cust_attribute_category;
    x_pxh_rec.cust_attribute1         := p_khr_source_rec.cust_attribute1;
    x_pxh_rec.cust_attribute2         := p_khr_source_rec.cust_attribute2;
    x_pxh_rec.cust_attribute3         := p_khr_source_rec.cust_attribute3;
    x_pxh_rec.cust_attribute4         := p_khr_source_rec.cust_attribute4;
    x_pxh_rec.cust_attribute5         := p_khr_source_rec.cust_attribute5;
    x_pxh_rec.cust_attribute6         := p_khr_source_rec.cust_attribute6;
    x_pxh_rec.cust_attribute7         := p_khr_source_rec.cust_attribute7;
    x_pxh_rec.cust_attribute8         := p_khr_source_rec.cust_attribute8;
    x_pxh_rec.cust_attribute9         := p_khr_source_rec.cust_attribute9;
    x_pxh_rec.cust_attribute10        := p_khr_source_rec.cust_attribute10;
    x_pxh_rec.cust_attribute11        := p_khr_source_rec.cust_attribute11;
    x_pxh_rec.cust_attribute12        := p_khr_source_rec.cust_attribute12;
    x_pxh_rec.cust_attribute13        := p_khr_source_rec.cust_attribute13;
    x_pxh_rec.cust_attribute14        := p_khr_source_rec.cust_attribute14;
    x_pxh_rec.cust_attribute15        := p_khr_source_rec.cust_attribute15;
    x_pxh_rec.contract_status_code    := p_khr_source_rec.contract_status_code;
    x_pxh_rec.inv_agrmnt_number         := p_khr_source_rec.inv_agrmnt_number;
    x_pxh_rec.inv_agrmnt_effective_from := p_khr_source_rec.inv_agrmnt_effective_from;
    x_pxh_rec.inv_agrmnt_product_name   := p_khr_source_rec.inv_agrmnt_product_name;
    x_pxh_rec.inv_agrmnt_currency_code  := p_khr_source_rec.inv_agrmnt_currency_code;
    x_pxh_rec.inv_agrmnt_synd_code      := p_khr_source_rec.inv_agrmnt_synd_code;
    x_pxh_rec.inv_agrmnt_pool_number    := p_khr_source_rec.inv_agrmnt_pool_number;
    x_pxh_rec.inv_agrmnt_status_code    := p_khr_source_rec.inv_agrmnt_status_code;
    x_pxh_rec.scs_code                  := p_khr_source_rec.scs_code;
  END assign_khr_rec_to_pxh_rec;

 ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : assign_kle_rec_to_pxlv_rec
  --      Pre-reqs        : None
  --      Function        : assign kle rec to pxlv rec for AP OKL Transactions
  --      Parameters      :
  --      IN              : p_kle_source_rec     kle_source_rec_type
  --      OUT             : x_pxlv_rec           pxlv_rec_type
  --      Version         : 1.0
  --      History         : Prashant Jain created
  -- End of comments
  ------------------------------------------------------------------------------
  -- Changes for Bug# 6268782 : PRASJAIN
  -- 1. func name assign_kle_rec_to_pxlv_rec to assign_kle_rec_to_pxl_rec
  -- 2. out param pxlv_rec_type to pxl_rec_type
  ------------------------------------------------------------------------------
  PROCEDURE assign_kle_rec_to_pxl_rec(
    p_kle_source_rec  IN       kle_source_rec_type
   ,x_pxl_rec         IN OUT   NOCOPY pxl_rec_type
  )
  AS
  BEGIN
    x_pxl_rec.kle_id                    := p_kle_source_rec.kle_id;
    x_pxl_rec.asset_number              := p_kle_source_rec.asset_number;
    x_pxl_rec.contract_line_number      := p_kle_source_rec.contract_line_number;
    x_pxl_rec.asset_vendor_name         := p_kle_source_rec.asset_vendor_name;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables start
    x_pxl_rec.asset_vendor_id           := p_kle_source_rec.asset_vendor_id;
    -- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables end
    x_pxl_rec.installed_site_id         := p_kle_source_rec.installed_site_id;
    x_pxl_rec.fixed_asset_location_name := p_kle_source_rec.fixed_asset_location_name;
    x_pxl_rec.contract_line_type        := p_kle_source_rec.line_type_code;
    x_pxl_rec.line_attribute_category   := p_kle_source_rec.line_attribute_category;
    x_pxl_rec.line_attribute1           := p_kle_source_rec.line_attribute1;
    x_pxl_rec.line_attribute2           := p_kle_source_rec.line_attribute2;
    x_pxl_rec.line_attribute3           := p_kle_source_rec.line_attribute3;
    x_pxl_rec.line_attribute4           := p_kle_source_rec.line_attribute4;
    x_pxl_rec.line_attribute5           := p_kle_source_rec.line_attribute5;
    x_pxl_rec.line_attribute6           := p_kle_source_rec.line_attribute6;
    x_pxl_rec.line_attribute7           := p_kle_source_rec.line_attribute7;
    x_pxl_rec.line_attribute8           := p_kle_source_rec.line_attribute8;
    x_pxl_rec.line_attribute9           := p_kle_source_rec.line_attribute9;
    x_pxl_rec.line_attribute10          := p_kle_source_rec.line_attribute10;
    x_pxl_rec.line_attribute11          := p_kle_source_rec.line_attribute11;
    x_pxl_rec.line_attribute12          := p_kle_source_rec.line_attribute12;
    x_pxl_rec.line_attribute13          := p_kle_source_rec.line_attribute13;
    x_pxl_rec.line_attribute14          := p_kle_source_rec.line_attribute14;
    x_pxl_rec.line_attribute15          := p_kle_source_rec.line_attribute15;
  END assign_kle_rec_to_pxl_rec;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_ap_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              : pxhv_rec_type.source_id            IN NUMBER    Required
  --                        pxhv_rec_type.source_table         IN VARCHAR2  Required

  --                        pxhv_rec_type.khr_id               IN NUMBER    Required
  --                        pxlv_rec_type.kle_id               IN NUMBER    Required
  --                        pxhv_rec_type.try_id               IN NUMBER    Required
  --                        pxlv_rec_type.sty_id               IN NUMBER    Required
  --                        pxlv_rec_type.source_id            IN NUMBER    Required
  --                        pxlv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_ap_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_pxhv_rec              IN        pxhv_rec_type
   ,p_pxlv_rec              IN        pxlv_rec_type
   ,p_acc_sources_rec       IN        asev_rec_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  )
  IS
    -- Cursor to fetch header_extension_id
    CURSOR c_header_extension_id_csr (p_header_source_id NUMBER, p_khr_id NUMBER)
    IS
      SELECT    hdr.header_extension_id header_extension_id
        FROM    okl_ext_ap_header_sources_b hdr
       WHERE    hdr.source_id = p_header_source_id
         AND    hdr.khr_id    = p_khr_id;
    -- Cursor to fetch trans number
    CURSOR c_trans_number_csr (p_header_source_id NUMBER)
    IS
      SELECT    tap.vendor_invoice_number trans_number
        FROM    okl_trx_ap_invoices_b tap
       WHERE    tap.id = p_header_source_id;

    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'populate_ap_sources';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_khr_id               NUMBER;
    l_try_id               NUMBER;
    l_kle_id               NUMBER;
    l_sty_id               NUMBER;
    l_ledger_id            NUMBER;
    l_ledger_language      VARCHAR2(12);
    l_header_source_id     NUMBER;
    l_header_source_table  VARCHAR2(30);
    l_template_id          NUMBER;
    l_source_id            NUMBER;
    l_source_table         VARCHAR2(30);
    l_header_extension_id  NUMBER;
    l_pk_attributes        VARCHAR2(1000);
    l_tcn_id               NUMBER;
    l_line_style           VARCHAR2(30);
    l_parent_line_id       NUMBER;
    -- KHR and KLE Based Record Structures
    l_khr_source_rec       khr_source_rec_type;
    l_kle_source_rec       kle_source_rec_type;
    -- Record structures based on the Cursor Definitions
    l_termination_qte_csr_rec   c_termination_qte_csr%ROWTYPE;
    -- Record Structures based on OKL AP Extension Header and Line Tables
    l_pxh_rec              pxh_rec_type;
    lx_pxh_rec             pxh_rec_type;

    l_pxhl_tbl             pxhl_tbl_type;
    lx_pxhl_tbl            pxhl_tbl_type;

    l_pxl_rec              pxl_rec_type;
    lx_pxl_rec             pxl_rec_type;

    l_pxll_tbl             pxll_tbl_type;
    lx_pxll_tbl            pxll_tbl_type;

    l_led_lang_tbl        led_lang_tbl_type;

    l_ledger_lang_rec      c_ledger_lang_csr%ROWTYPE;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    tl_sources_in         NUMBER := 1;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.populate_ap_sources');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validations to be done
    -- Validation 1:
    --   The following attributes should not be NULL
    --    dnz_khr_id, kle_id, try_id, source_id, sty_id
    l_pk_attributes := NULL;
    IF p_pxhv_rec.source_id IS NULL OR
       p_pxhv_rec.source_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'PXH.SOURCE_ID';
    END IF;
    IF p_pxhv_rec.source_table IS NULL OR
       p_pxhv_rec.source_table = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'PXH.SOURCE_TABLE';
    END IF;
    IF p_pxhv_rec.khr_id IS NULL OR
       p_pxhv_rec.khr_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'KHR_ID';
    END IF;
    IF p_pxhv_rec.try_id IS NULL OR
       p_pxhv_rec.try_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'TRY_ID';
    END IF;
    IF p_pxlv_rec.source_id IS NULL OR
       p_pxlv_rec.source_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'PXL.SOURCE_ID';
    END IF;
    IF p_pxlv_rec.source_table IS NULL OR
       p_pxlv_rec.source_table = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'PXL.SOURCE_TABLE';
    END IF;
    IF p_pxlv_rec.sty_id IS NULL OR
       p_pxlv_rec.sty_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'STY_ID';
    END IF;
    IF LENGTH(l_pk_attributes) > 0
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => l_pk_attributes);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 1 Successfull !');
    -- Validation 2:
    --   Source Table should be OKL_TXL_AP_INV_LNS_B
    IF p_pxlv_rec.source_table NOT IN ( G_TXL_AP_INV_LNS_B )
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 2 Successfull !');
    -- Copy input rec to local variable
    l_pxh_rec.source_id    := p_pxhv_rec.source_id;
    l_pxh_rec.source_table := p_pxhv_rec.source_table;
    l_pxh_rec.khr_id       := p_pxhv_rec.khr_id;
    l_pxh_rec.try_id       := p_pxhv_rec.try_id;

    l_pxl_rec.source_id    := p_pxlv_rec.source_id;
    l_pxl_rec.source_table := p_pxlv_rec.source_table;
    l_pxl_rec.kle_id       := p_pxlv_rec.kle_id;
    l_pxl_rec.sty_id       := p_pxlv_rec.sty_id;
    -- Copy the input parameters to the local variables
    l_header_source_id    := l_pxh_rec.source_id;
    l_header_source_table := l_pxh_rec.source_table;
    l_khr_id              := l_pxh_rec.khr_id;
    l_try_id              := l_pxh_rec.try_id;
    l_source_id           := l_pxl_rec.source_id;
    l_source_table        := l_pxl_rec.source_table;
    l_kle_id              := l_pxl_rec.kle_id;  -- For Subsidy this is will be a SUBSIDY Line but not the Asset
    l_sty_id              := l_pxl_rec.sty_id;

    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '**** KLE_ID = ' || l_kle_id );
    IF l_kle_id IS NOT NULL OR
       l_kle_id <> OKL_API.G_MISS_NUM
    THEN
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor get_line_style_csr kle_id=' || l_pxl_rec.kle_id );
      FOR t_rec IN get_line_style_csr(p_kle_id => l_pxl_rec.kle_id )
      LOOP
        l_line_style       := t_rec.line_style;
        IF l_line_style = 'SUBSIDY'
        THEN
          l_parent_line_id := t_rec.parent_line_id;
        END IF;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        '**** LINE STYLE = ' || l_line_style || ' PARENT LINE ID = ' || l_parent_line_id );
    END IF; -- IF l_kle_id IS NOT NULL OR l_kle_id <> OKL_API.G_MISS_NUM

    -- Fetch ledger id and ledger language associated to the contracts
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_khr_to_ledger_id_csr. p_khr_id=' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_khr_to_ledger_id_csr( p_khr_id => l_khr_id )
    LOOP
      l_ledger_id := t_rec.ledger_id;
    END LOOP;

    -- Fetch the ledger language in order to populate the sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_ledger_lang_csr. p_ledger_id=' || TO_CHAR(l_ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_ledger_id )
    LOOP
      l_ledger_lang_rec := t_rec;
      l_led_lang_tbl(tl_sources_in).language := t_rec.language_code;
      l_pxll_tbl(tl_sources_in).language     := t_rec.language_code;
      tl_sources_in := tl_sources_in + 1;
    END LOOP;

    -- Logic Description:
    --   1. The OKL AP Extension Header _B/_TL sources will be captured only once
    --       for a KHR_ID.
    --   2. For every AP Transaction Line, there will be a single record in the
    --       OKL AP Extension Line _B/_TL
    --  For Eg., if a Transaction is having 10 transaction lines with two different khr_id1, khr_id2
    --  there will be only two records in the Header but 10 transaction lines in Extension Line.
    --  Hence, for every Transaction Line check whether the KHR Sources have been captured
    --  already or not by passing the Transaction ID and KHR_ID
    -- Fetch header extension id
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_header_extension_id_csr.
         p_header_source_id=' || TO_CHAR(l_header_source_id)
        || ' p_khr_id= ' || TO_CHAR(l_khr_id));
    l_header_extension_id := NULL;
    FOR t_rec IN c_header_extension_id_csr(
                          p_header_source_id    => l_header_source_id
                         ,p_khr_id              => l_khr_id )
    LOOP
      l_header_extension_id := t_rec.header_extension_id;
    END LOOP; -- End for c_header_extension_id_csr

    -- If l_header_extension_id is NOT NULL, then it means the KHR sources are already captured
    --   So, populate extension line sources only.
    -- Else Populate both the Extension Header and Line Sources.
    IF l_header_extension_id IS NULL
    THEN
      -- Prepare khr_source_rec_type with khr_id and ledger_language
      l_khr_source_rec.khr_id            := l_khr_id;
      -- Calling populate_khr_sources to fetch the KHR Sources
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Calling the populate_khr_sources' );
      populate_khr_sources(
         p_api_version      => l_api_version
        ,p_init_msg_list    => p_init_msg_list
        ,x_khr_source_rec   => l_khr_source_rec
        ,x_led_lang_tbl     => l_led_lang_tbl
        ,x_return_status    => l_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After populate_khr_sources: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Assign the KHR Sources to the pxhv_rec
      assign_khr_rec_to_pxh_rec(
         p_khr_source_rec => l_khr_source_rec
        ,x_pxh_rec => l_pxh_rec );

      FOR tl_sources_in IN l_led_lang_tbl.FIRST .. l_led_lang_tbl.LAST
      LOOP
        l_pxhl_tbl(tl_sources_in).language          := l_led_lang_tbl(tl_sources_in).language;
        l_pxhl_tbl(tl_sources_in).contract_status   := l_led_lang_tbl(tl_sources_in).contract_status;
        l_pxhl_tbl(tl_sources_in).inv_agrmnt_status := l_led_lang_tbl(tl_sources_in).inv_agrmnt_status;

        -- Fetch transaction type name wrt ledger language
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_trx_type_name_csr. p_try_id=' ||
          l_try_id || 'p_led_lang= ' || l_pxhl_tbl(tl_sources_in).language );
        FOR t_rec IN c_trx_type_name_csr(
                      p_try_id    => l_try_id
                     ,p_led_lang  => l_pxhl_tbl(tl_sources_in).language )
        LOOP
          l_pxhl_tbl(tl_sources_in).transaction_type_name := t_rec.transaction_type_name;
          -- Assign the Trx. Type Class Code also.
          l_pxh_rec.trx_type_class_code  := t_rec.trx_type_class_code;
        END LOOP; -- End for c_trx_type_name_csr
      END LOOP;

      IF(p_acc_sources_rec.jtf_sales_reps_pk IS NOT NULL AND
         p_acc_sources_rec.jtf_sales_reps_pk <> OKL_API.G_MISS_CHAR) THEN
         -- Need to populate the Sales Representative Name
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Executing the Cursor  c_sales_rep_acc_sources_csr. l_sales_rep_id = ' ||
             TO_CHAR(p_acc_sources_rec.jtf_sales_reps_pk) );
         FOR t_rec IN  c_sales_rep_acc_sources_csr (p_jtf_sales_rep_pk => p_acc_sources_rec.jtf_sales_reps_pk)
         LOOP
           l_pxh_rec.sales_rep_name := t_rec.name;
         END LOOP;  -- c_sales_rep_acc_sources_csr
      END IF;

      -- Fetch the Transaction Number
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_trans_number_csr. p_header_source_id=' || l_header_source_id );
      FOR t_rec IN c_trans_number_csr( p_header_source_id => l_header_source_id )
      LOOP
        l_pxh_rec.trans_number := t_rec.trans_number;
      END LOOP; -- End for c_trans_number_csr
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'Calling the okl_ap_extension_pvt.create_pxh_extension ' || l_pxh_rec.source_id );
      okl_ap_extension_pvt.create_pxh_extension(
         p_api_version     => l_api_version
        ,p_init_msg_list   => p_init_msg_list
        ,x_return_status   => l_return_status
        ,x_msg_count       => x_msg_count
        ,x_msg_data        => x_msg_data
        ,p_pxh_rec         => l_pxh_rec
        ,p_pxhl_tbl        => l_pxhl_tbl
        ,x_pxh_rec         => lx_pxh_rec
        ,x_pxhl_tbl        => lx_pxhl_tbl
      );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After okl_ap_extension_pvt.create_pxh_extension: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Store the Header Extension ID into the Local Variable l_header_extension_id
      l_header_extension_id := lx_pxh_rec.header_extension_id;
    END IF;
    IF l_kle_id IS NOT NULL OR
       l_kle_id <> OKL_API.G_MISS_NUM
    THEN
      -- Start populating the Sources at the Extension Line Level
      -- Prepare kle_source_rec_type with khr_id, kle_id and ledger_language
      l_kle_source_rec.khr_id            := l_khr_id;
      l_kle_source_rec.kle_id            := l_kle_id;
      IF l_line_style = 'SUBSIDY'
      THEN
        -- If the Line Style is SUBSIDY, then pass the Asset line id to the
        --  Populate KLE Sources to fetch the Asset Details
        l_kle_source_rec.kle_id            := l_parent_line_id;
      END IF;
      -- l_kle_source_rec.ledger_language   := l_ledger_language;
      -- Calling populate_kle_sources
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Before Calling the populate_kle_sources' );
      populate_kle_sources(
        p_api_version      => l_api_version
       ,p_init_msg_list    => p_init_msg_list
       ,x_kle_source_rec   => l_kle_source_rec
       ,x_return_status    => l_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'After populate_kle_sources: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- calling assign_kle_rec_to_pxlv_rec
      assign_kle_rec_to_pxl_rec(
         p_kle_source_rec => l_kle_source_rec
         ,x_pxl_rec => l_pxl_rec );

      -- Fetch fee type code
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_k_lines_csr. p_kle_id= ' || TO_CHAR(l_kle_id));
      FOR t_rec  IN c_k_lines_csr ( p_kle_id => l_kle_id )
      LOOP
        l_pxl_rec.fee_type_code := t_rec.fee_type;
      END LOOP;  -- End for c_k_lines_csr
    --ELSE
      -- Populate the l_pxlv_rec with the khr_id, ledger_language
      -- but not with the kle_id
      --l_pxlv_rec.language := l_ledger_language ;
    END IF; -- IF l_kle_id IS NOT NULL OR l_kle_id <> OKL_API.G_MISS_NUM

    -- Stamp the Header Extension ID on the Extension Line Table
    l_pxl_rec.header_extension_id := l_header_extension_id;

    -- Fetch the Account Template ID
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the curosr c_account_dist_csr. p_source_id= ' || to_char(l_source_id)
      || ' p_source_table= ' || to_char(l_source_table));
    FOR t_rec  IN c_account_dist_csr (
                    p_source_id    => l_source_id
                   ,p_source_table => l_source_table)
    LOOP
      l_template_id := t_rec.template_id;
    END LOOP;  -- End for c_account_dist_csr

    -- Assigning the Memo Indicator to the Extension Line Record structure ..
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      '** AGS Memo Flag ' || p_acc_sources_rec.memo_yn );
    l_pxl_rec.memo_flag := p_acc_sources_rec.memo_yn;

    -- Fetch Memo Flag and Accounting Template Name using the template_id
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the curosr c_ae_templates_csr. template_id= ' || to_char(l_template_id) );
    FOR t_rec  IN c_ae_templates_csr (p_template_id => l_template_id)
    LOOP
      l_pxl_rec.accounting_template_name := t_rec.name;
    END LOOP;  -- End for c_ae_templates_csr

    -- Fetch stream type code and stream type purpose code
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the curosr c_contingency_strm_b_csr. p_sty_id= ' || TO_CHAR(l_sty_id));
    FOR t_rec  IN c_contingency_strm_b_csr ( p_sty_id => l_sty_id )
    LOOP
      l_pxl_rec.stream_type_code         := t_rec.stream_type_code;
      l_pxl_rec.stream_type_purpose_code := t_rec.stream_type_purpose;
    END LOOP;  -- End for c_contingency_strm_b_csr

    -- Fetch stream type name
    FOR tl_sources_in IN l_pxll_tbl.FIRST .. l_pxll_tbl.LAST
    LOOP
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_strm_name_tl_csr. p_sty_id= ' || TO_CHAR(l_sty_id)
        || ' Ledger Language = ' || l_pxll_tbl(tl_sources_in).language);
      FOR t_rec  IN c_strm_name_tl_csr ( p_sty_id => l_sty_id, p_lang => l_pxll_tbl(tl_sources_in).language )
      LOOP
        l_pxll_tbl(tl_sources_in).stream_type_name := t_rec.stream_type_name;
      END LOOP;  -- End for c_strm_name_tl_csr
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the curosr c_txl_ap_inv_desc_csr. p_tpld_id= ' || TO_CHAR(l_source_id)
        || ' p_lang = ' || l_pxll_tbl(tl_sources_in).language);
      FOR t_rec IN c_txl_ap_inv_desc_csr (
                     p_tpld_id   => l_source_id
                    ,p_lang      => l_pxll_tbl(tl_sources_in).language )
      LOOP
        l_pxll_tbl(tl_sources_in).trans_line_description := t_rec.trans_line_description;
      END LOOP;
    END LOOP;

    -- Fetch asset category name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the curosr c_manufacture_model_csr. p_kle_id= ' || TO_CHAR(l_kle_id)
      || ' p_khr_id= ' || TO_CHAR(l_khr_id));
    FOR t_rec  IN c_manufacture_model_csr ( p_kle_id => l_kle_id, p_khr_id => l_khr_id )
    LOOP
      l_pxl_rec.asset_category_name := t_rec.asset_category_name;
    END LOOP;  -- End for c_manufacture_model_csr

    IF(p_acc_sources_rec.inventory_org_id_pk2 IS NOT NULL AND
       p_acc_sources_rec.inventory_org_id_pk2 <> OKL_API.G_MISS_CHAR AND
       p_acc_sources_rec.inventory_item_id_pk1 IS NOT NULL AND
       p_acc_sources_rec.inventory_item_id_pk1 <> OKL_API.G_MISS_CHAR) THEN
      FOR tl_sources_in IN l_pxll_tbl.FIRST .. l_pxll_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing the Cursor c_inventory_item_name_csr. p_inventory_item_id_pk1= ' ||
          to_char(p_acc_sources_rec.inventory_item_id_pk1) || ' p_inventory_org_id_pk2=' ||
          to_char(p_acc_sources_rec.inventory_org_id_pk2) || ' ledger_language=' ||
          l_pxll_tbl(tl_sources_in).language );
        FOR t_rec IN c_inventory_item_name_csr(
                     p_inventory_item_id_pk1 => p_acc_sources_rec.inventory_item_id_pk1
                    ,p_inventory_org_id_pk2  => p_acc_sources_rec.inventory_org_id_pk2
                    ,p_ledger_language       => l_pxll_tbl(tl_sources_in).language)
        LOOP
          l_pxll_tbl(tl_sources_in).inventory_item_name      := t_rec.description;
          l_pxl_rec.inventory_item_name_code := t_rec.b_description;
        END LOOP;
      END LOOP;
    END IF;
    IF(p_acc_sources_rec.inventory_org_id_pk2 IS NOT NULL AND
       p_acc_sources_rec.inventory_org_id_pk2 <> OKL_API.G_MISS_CHAR) THEN
       -- Populate Inventory Organization Name
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
         '*** AGS Inventory Org ID used to fetch teh Inventory Organization Code : Org ID=' ||
         p_acc_sources_rec.inventory_org_id_pk2 );
       put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
         'Executing the Cursor c_org_name_code_csr. p_org_id= ' || TO_CHAR(p_acc_sources_rec.inventory_org_id_pk2) );
       FOR t_rec IN c_org_name_code_csr(
                       p_org_id      => p_acc_sources_rec.inventory_org_id_pk2 )
       LOOP
         l_pxl_rec.inventory_org_code := t_rec.org_name;
       END LOOP;

       FOR tl_sources_in IN l_pxll_tbl.FIRST .. l_pxll_tbl.LAST
       LOOP
         put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
           'Executing the Cursor c_org_name_csr. p_org_id= ' || TO_CHAR(p_acc_sources_rec.inventory_org_id_pk2) ||
           ' ledger_language=' || l_pxll_tbl(tl_sources_in).language );
         FOR t_rec IN c_org_name_csr(
                         p_org_id      => p_acc_sources_rec.inventory_org_id_pk2
                        ,p_ledger_lang => l_pxll_tbl(tl_sources_in).language )
         LOOP
           l_pxll_tbl(tl_sources_in).inventory_org_name := t_rec.org_name;
         END LOOP;
       END LOOP;
    END IF;

    -- Calling insert_row
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_ap_extension_pvt.create_pxl_extension source_id=' || l_pxl_rec.source_id );
    okl_ap_extension_pvt.create_pxl_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_pxl_rec         => l_pxl_rec
      ,p_pxll_tbl        => l_pxll_tbl
      ,x_pxl_rec         => lx_pxl_rec
      ,x_pxll_tbl        => lx_pxll_tbl
     );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_ap_extension_pvt.create_pxl_extension: l_return_status ' || l_return_status );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.populate_ap_sources');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_ap_sources;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :
  --                        pxhv_rec_type.source_id            IN NUMBER    Required
  --                        pxhv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_pxhv_rec              IN        pxhv_rec_type
   ,p_pxlv_tbl              IN        pxlv_tbl_type
   ,p_acc_sources_tbl       IN        asev_tbl_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  )
  IS
    -- Cursor to fetch source_id, khr_id, kle_id,
    -- sty_id, try_id
    CURSOR c_ap_fcase_csr (p_header_source_id NUMBER)
    IS
      SELECT    tpl.id                    source_id
               ,'OKL_TXL_AP_INV_LNS_B'    source_table
               ,tpl.khr_id                khr_id
               ,tpl.kle_id                kle_id
               ,tpl.sty_id                sty_id
               ,tap.try_id                try_id
               ,tap.vendor_invoice_number trans_number
       FROM     okl_trx_ap_invoices_b tap
               ,okl_txl_ap_inv_lns_b  tpl
      WHERE     tap.id = tpl.tap_id
        AND     tap.id = p_header_source_id;

    -- Data structures based on the Cursor Variables
    TYPE c_ap_fcase_tbl IS TABLE OF c_ap_fcase_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_ap_fcase_tbl             c_ap_fcase_tbl;
    tld_count                  NUMBER; -- Count of the l_ap_fcase_tbl
    tld_index                  NUMBER; -- Index for the l_ap_fcase_tbl
    pxl_index                  NUMBER; -- Index for the l_pxlv_tbl
    l_acc_srcs_index           NUMBER; -- Index for the p_acc_sources_tbl
    l_capture_sources          VARCHAR2(3); -- Flag to decide whether to Capture Sources or Not !
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'POPULATE_SOURCES-AP';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;

    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_header_source_id            NUMBER;
    l_header_source_table         VARCHAR2(30);
    l_pxhv_rec                    pxhv_rec_type;
    l_pxlv_rec                    pxlv_rec_type;
    l_pxlv_tbl                    pxlv_tbl_type;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Validation 1: Source ID and Source Table should not be NULL in the
    --   AP Extension Header Record Structure
    IF (p_pxhv_rec.source_id      IS NULL OR
        p_pxhv_rec.source_table   IS NULL)
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_ID_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Validation 2: The Header Source Table should be the
    --  OKL AP Invoice Trx Header . Header table only
    --   ie. it should be okl_trx_ap_invoices_b only
    IF (p_pxhv_rec.source_table <> G_TRX_AP_INVOICES_B)
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Copy to local variables
    l_pxhv_rec            := p_pxhv_rec;
    l_header_source_id    := p_pxhv_rec.source_id;
    l_header_source_table := p_pxhv_rec.source_table;
    l_pxlv_tbl            := p_pxlv_tbl;
    -- Validation 3: There should be atleast one Transaction Detail Line
    --  for which the Populate AP Sources should be called
    IF l_pxlv_tbl.COUNT = 0
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'PXLV_TBL.COUNT()');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Validation 4: p_pxlv_tbl.COUNT should be equal to the p_acc_sources_tbl.COUNT
    IF l_pxlv_tbl.COUNT <> p_acc_sources_tbl.COUNT
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'P_ACC_SOURCES_TBL.COUNT()');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Loop on the details for the current transaction header
    -- Call the populate_ap_sources
      -- As we wanted to store the records in the PL/SQL table starting from 1
      -- and after the loop, the tld_index should be nothing but the count of the
      -- Transaction Detail Lines fetched ...
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Executing the Cursor c_ap_fcase_csr. p_header_source_id=' ||
           TO_CHAR(l_header_source_id));
      -- Initialize the tld_count to ZERO
      tld_count  := 0;
      FOR t_rec IN c_ap_fcase_csr( p_header_source_id => l_header_source_id )
      LOOP
        -- Increment the tld_count
        tld_count := tld_count + 1;
        -- Store the Current Record in the PL/SQL Table for further usage
        l_ap_fcase_tbl(tld_count) := t_rec;
      END LOOP;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Number of Transaction Detail Lines present in DB     = ' || TO_CHAR(tld_count) );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Number of Transaction Detail Lines passed to the API = ' || TO_CHAR(l_pxlv_tbl.COUNT) );
      FOR tld_index IN l_ap_fcase_tbl.FIRST .. l_ap_fcase_tbl.LAST
      LOOP
        -- Logic Explanation:
        -- 1. Check for the Count of the Trx. Detail Lines fetched from DB
        -- 2. Compare this count with the count of Trx. Detail Lines passed to this API
        -- 3. If the count is same, then, capture sources for every Trx. Detail Line
        --    otherwise, capture sources for only those transaction detail line, which have
        --    been passed by the Accounting Engine
        l_capture_sources := 'N';
        l_acc_srcs_index  := NULL;
        pxl_index := l_pxlv_tbl.FIRST;
        LOOP
          IF l_pxlv_tbl(pxl_index).source_id    = l_ap_fcase_tbl(tld_index).source_id AND
             l_pxlv_tbl(pxl_index).source_table = l_ap_fcase_tbl(tld_index).source_table
          THEN
            -- Need to the Call the Populate AP Sources for this Transaction Detail Line
            l_capture_sources := 'Y';
            -- Assumption: p_pxlv_tbl and p_acc_sources_tbl are populated using the Same Index.
            l_acc_srcs_index  := pxl_index;
            put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
              'Case 2: Populate Sources has been asked to capture sources for the Current Transaction Detail by Accounting Engine ' ||
              ' TXD ID = ' || TO_CHAR( l_ap_fcase_tbl(tld_index).source_id ) );
          END IF;
          -- Exit when this is the Last Record or the Transaction Details has been found
          EXIT WHEN ( pxl_index = l_pxlv_tbl.LAST )  -- When reached End of the Table
                 OR ( l_capture_sources = 'Y'     ); -- Or When the TXD has been found
          -- Increment the pxl_index
          pxl_index := l_pxlv_tbl.NEXT( pxl_index );
        END LOOP; -- Loop on l_pxlv_tbl ..

        IF l_capture_sources = 'Y'
        THEN
          -- If the AGS Index is not found then return error
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'Account Generator Sources Index =' || TO_CHAR(l_acc_srcs_index)  );
          IF l_acc_srcs_index IS NULL OR
             ( p_acc_sources_tbl.EXISTS(l_acc_srcs_index) = FALSE )
          THEN
            -- accounting_event_class_code is missing
            OKL_API.set_message(
               p_app_name      => G_APP_NAME
              ,p_msg_name      => G_INVALID_VALUE
              ,p_token1        => G_COL_NAME_TOKEN
              ,p_token1_value  => 'AGS_SOURCES_INDEX');
            l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF; -- IF l_acc_sources_found = FALSE

          l_pxhv_rec.try_id       := l_ap_fcase_tbl(tld_index).try_id;
          l_pxhv_rec.khr_id       := l_ap_fcase_tbl(tld_index).khr_id;
          -- l_pxhv_rec.source_id and l_pxhv_rec.source_table are already assigned
          -- Id of Detail Line Table
          l_pxlv_rec.source_id := l_ap_fcase_tbl(tld_index).source_id;
          l_pxlv_rec.source_table := l_ap_fcase_tbl(tld_index).source_table;
          l_pxlv_rec.kle_id    := l_ap_fcase_tbl(tld_index).kle_id;
          l_pxlv_rec.sty_id    := l_ap_fcase_tbl(tld_index).sty_id;
          --l_pxhv_rec.trans_number := l_ap_fcase_tbl(tld_index).trans_number;
          -- The populate_ap_sources will capture sources at extension line level always
          -- If the extension header sources with the l_pxlv_rec.source_id and l_pxhv_rec.khr_id is not captured
          -- Then only capture the extension header sources
          -- Calling populate_ap_sources
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'Calling the populate_ap_sources' );
          populate_ap_sources(
            p_api_version       => l_api_version
           ,p_init_msg_list     => p_init_msg_list
           ,p_pxhv_rec          => l_pxhv_rec
           ,p_pxlv_rec          => l_pxlv_rec
           ,p_acc_sources_rec   => p_acc_sources_tbl(l_acc_srcs_index)
           ,x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data);
          put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
            'After populate_ap_sources: l_return_status ' || l_return_status );
          -- Check the return status and if errored, return the error back
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF; -- IF l_capture_sources = 'Y'
      END LOOP; -- Loop on l_ap_fcase_tbl ..
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                           p_api_name  => l_api_name
                          ,p_pkg_name  => G_PKG_NAME
                          ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                          ,x_msg_count  => x_msg_count
                          ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_sources;

  PROCEDURE delete_ap_extension(
    p_api_version               IN              NUMBER
   ,p_init_msg_list             IN              VARCHAR2
   ,p_pxhv_rec                  IN              pxhv_rec_type
   ,x_pxlv_tbl                  OUT    NOCOPY   pxlv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version      CONSTANT NUMBER         := 1;
    l_api_name         CONSTANT VARCHAR2(30)   := 'DELETE_AP_EXTENSION';
    l_return_status    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    pxl_index          BINARY_INTEGER;
    l_pxhv_rec         okl_pxh_pvt.pxhv_rec_type;
    l_pxlv_tbl         okl_pxl_pvt.pxlv_tbl_type;
    lx_pxhv_rec        okl_pxh_pvt.pxhv_rec_type;
    lx_pxlv_tbl        okl_pxl_pvt.pxlv_tbl_type;
    -- Cursor Definitions
    CURSOR get_ap_ext_hdr_id( p_source_id  NUMBER, p_source_table VARCHAR2)
    IS
      SELECT   pxh.header_extension_id      header_extension_id
        FROM   okl_ext_ap_header_sources_b	pxh
       WHERE   pxh.source_id = p_source_id
         AND   pxh.source_table = p_source_table;

    CURSOR get_ap_ext_lns_id( p_hdr_ext_id  NUMBER)
    IS
      SELECT   pxl.line_extension_id     line_extension_id
              ,pxl.source_id             source_id
              ,pxl.source_table          source_table
        FROM   okl_ext_ap_line_sources_b pxl
       WHERE   pxl.header_extension_id = p_hdr_ext_id;
    -- Local Variables for enabling the Debug Statements
    l_module              CONSTANT     fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled                    VARCHAR2(10);
    is_debug_procedure_on              BOOLEAN;
    is_debug_statement_on              BOOLEAN;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.DELETE_AP_EXTENSION');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Actual Logic Starts Here ..
    l_pxhv_rec := p_pxhv_rec;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Source ID=' || to_char(l_pxhv_rec.source_id) || 'Source Header Table=' || l_pxhv_rec.source_table );
    IF ( l_pxhv_rec.source_id = OKL_API.G_MISS_NUM or l_pxhv_rec.source_id IS NULL )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    IF ( l_pxhv_rec.source_table = OKL_API.G_MISS_CHAR or l_pxhv_rec.source_table IS NULL
        OR l_pxhv_rec.source_table NOT IN ( G_TRX_AP_INVOICES_B) )
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'HEADER.SOURCE_TABLE');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Initialize the pxl_index
    pxl_index := 1;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Fetch the Extension Header ID by executing cursor get_ap_ext_hdr_id' );
    FOR t_rec IN get_ap_ext_hdr_id(
                    p_source_id     => l_pxhv_rec.source_id
                   ,p_source_table  => l_pxhv_rec.source_table)
    LOOP
      -- Note that for a given Source ID and Source Table in OKL_EXT_AP_HEADER_SOURCES_B
      --  there can be multiple records each having different KHR_ID ..
      l_pxhv_rec.header_extension_id := t_rec.header_extension_id;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Extension Header ID To be Deleted='  || TO_CHAR(l_pxhv_rec.header_extension_id));
      -- Fetch the Transaction Extension Line IDs to be deleted
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'Extension Line ID(s) To be Deleted=');
      FOR t_rec IN get_ap_ext_lns_id( p_hdr_ext_id  => l_pxhv_rec.header_extension_id)
      LOOP
        l_pxlv_tbl(pxl_index).line_extension_id  := t_rec.line_extension_id;
        l_pxlv_tbl(pxl_index).source_id          := t_rec.source_id;
        l_pxlv_tbl(pxl_index).source_table       := t_rec.source_table;
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'LINE_EXTENSION_ID[' || pxl_index || '] = ' || TO_CHAR(l_pxlv_tbl(pxl_index).line_extension_id) );
        -- Increment i
        pxl_index := pxl_index + 1;
      END LOOP; -- End get_trans_line_ids
      -- Call the Wrapper API to delete the Extension Lines and then Header
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'calling the okl_ap_extension_pvt.delete_pxh_extension Line Count=' || l_pxlv_tbl.COUNT );
      okl_ap_extension_pvt.delete_pxh_extension(
        p_api_version     => p_api_version
       ,p_init_msg_list   => p_init_msg_list
       ,x_return_status   => x_return_status
       ,x_msg_count       => x_msg_count
       ,x_msg_data        => x_msg_data
       ,p_pxhv_rec        => l_pxhv_rec
      );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'After okl_ap_extension_pvt.delete_pxh_extension: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END LOOP; -- Loop on the get_ap_ext_hdr_id
    -- Store the Transaction Line IDs and Line Source Tables so as to return back
    x_pxlv_tbl := l_pxlv_tbl;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.DELETE_AP_EXTENSION');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END delete_ap_extension;
  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL FA Depreciation Transactions
  --      Parameters      :
  --      IN              :
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_khr_id                    IN             NUMBER
   ,p_deprn_asset_tbl           IN             deprn_asset_tbl_type
   ,p_deprn_run_id              IN             NUMBER
   ,p_book_type_code            IN             VARCHAR2
   ,p_period_counter            IN             NUMBER
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'POPULATE_SOURCES-DEPRN';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_khr_id               NUMBER;
    l_kle_id               NUMBER;
    l_asset_id             NUMBER;
    l_try_id               NUMBER;
    l_ledger_id            NUMBER;
    l_ledger_language      VARCHAR2(12);
    l_header_extension_id  NUMBER;
    l_pk_attributes        VARCHAR2(1000);
    l_deprn_asset_tbl      deprn_asset_tbl_type;
    l_inventory_org_name   VARCHAR2(240);
    l_inventory_org_code   VARCHAR2(240);
    l_line_index           NUMBER;
    -- KHR and KLE Based Record Structures
    l_khr_source_rec       khr_source_rec_type;
    l_kle_source_rec       kle_source_rec_type;
    -- Record structures based on FA Extension Header and Line Tables
    l_fxh_rec              okl_fxh_pvt.fxh_rec_type;
    lx_fxh_rec             okl_fxh_pvt.fxh_rec_type;
    l_fxhl_tbl             okl_fxh_pvt.fxhl_tbl_type;
    lx_fxhl_tbl            okl_fxh_pvt.fxhl_tbl_type;
    l_fxl_tbl_tbl          fxl_tbl_tbl_type;
    lx_fxl_tbl_tbl         fxl_tbl_tbl_type;
    l_fxl_tbl_tbl_out      fxl_tbl_tbl_type;
    l_fxl_rec              okl_fxl_pvt.fxl_rec_type;
    l_fxll_tbl             okl_fxl_pvt.fxll_tbl_type;
    l_null_fxl_rec         okl_fxl_pvt.fxl_rec_type;
    l_null_fxll_tbl        okl_fxl_pvt.fxll_tbl_type;
    l_led_lang_tbl         led_lang_tbl_type;
    -- Record structures based on the Cursor defintions
    l_sales_rep_csr_rec    c_sales_rep_csr%ROWTYPE;
    l_ledger_lang_rec      c_ledger_lang_csr%ROWTYPE;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    tl_sources_in         NUMBER := 1;

	l_rep_type            VARCHAR2(20);
	l_book_type_name      VARCHAR2(30);

  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before Performing validations');
    -- Validations to be done:
    --  1. The following should be NOT NULL
    --     KHR_ID, Depreciation Run ID, Book Type Code, Period Name and Period Counter
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Parameters Passed: ');
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'KHR_ID | DEPRN_RUN_ID ' );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      p_khr_id || ' | ' || p_deprn_run_id);

    l_pk_attributes := NULL;
    IF p_khr_ID IS NULL OR
       p_khr_ID = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'P_KHR_ID';
    END IF;
    IF p_deprn_run_id IS NULL OR
       p_deprn_run_id = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'P_DEPRN_RUN_ID';
    END IF;
    IF p_book_type_code IS NULL OR
       p_book_type_code = OKL_API.G_MISS_CHAR
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'P_BOOK_TYPE_CODE';
    END IF;
    IF p_period_counter IS NULL OR
       p_period_counter = OKL_API.G_MISS_NUM
    THEN
      IF l_pk_attributes IS NOT NULL
      THEN
        l_pk_attributes := l_pk_attributes || ' , ';
      END IF;
      l_pk_attributes := l_pk_attributes || 'P_PERIOD_COUNTER';
    END IF;
    IF LENGTH(l_pk_attributes) > 0
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => l_pk_attributes);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Validation 1 Successfull !');
    -- Assign the p_deprn_asset_tbl to l_deprn_asset_tbl
    l_deprn_asset_tbl := p_deprn_asset_tbl;
    -- Validation 2: Atleast one KLE_ID has to be there to populate the source for ..
    IF l_deprn_asset_tbl.COUNT = 0
    THEN
      -- Raise an Exception
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'P_DEPRN_ASSET_TBL.COUNT');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- Copy the Input Parameters to the Local Variables
    l_khr_id  := p_khr_id;
    --l_try_id  := NULL;

    -- Need to stamp the Mandatory Columns Like
    -- KHR_ID, TRY_ID, SOURCE_ID, SOURCE_TABLE,
    -- initialize the local l_fxlv_rec to the input record values
    l_fxh_rec.khr_id := l_khr_id;
    l_fxh_rec.try_id := NULL;  -- Not sure what to be stamped here
    l_fxh_rec.source_id := p_deprn_run_id; -- For time being stamping the Deprn Run ID
    l_fxh_rec.source_table := G_FA_DEPRN_SUMMARY;

	-- get the representation details based on book_type_code. MG uptake
	OPEN get_reps_csr(p_book_type_code);
	FETCH get_reps_csr INTO l_ledger_id, l_fxh_rec.representation_code,
	                        l_fxh_rec.representation_name, l_rep_type;
    CLOSE get_reps_csr;

    IF l_rep_type is not null then
	   g_representation_type := l_rep_type;
    ELSE
	   g_representation_type := 'PRIMARY';
	END IF;

	/* commented as the ledger is obtained above.. MG Uptake.
    -- Fetch Ledger ID to fetch the Ledger Language associated to the contracts
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_khr_to_ledger_id_csr. p_khr_id=' || TO_CHAR(l_khr_id));

      FOR t_rec IN c_khr_to_ledger_id_csr( p_khr_id => l_khr_id )
      LOOP
        l_ledger_id := t_rec.ledger_id;
      END LOOP;
	*/

    -- Using the Ledger ID fetch the Ledger Language
    -- Fetch the ledger language in order to populate the sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_ledger_lang_csr. p_ledger_id=' || TO_CHAR(l_ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_ledger_id )
    LOOP
      l_ledger_lang_rec := t_rec;
      l_led_lang_tbl(tl_sources_in).language := t_rec.language_code;
      l_fxll_tbl(tl_sources_in).language     := t_rec.language_code;
      tl_sources_in := tl_sources_in + 1;
    END LOOP;

    -- Prepare khr_source_rec_type with khr_id and ledger_language
    l_khr_source_rec.khr_id            := l_khr_id;

    -- Calling populate_khr_sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the populate_khr_sources' );
    populate_khr_sources(
       p_api_version      => l_api_version
      ,p_init_msg_list    => p_init_msg_list
      ,x_khr_source_rec   => l_khr_source_rec
      ,x_led_lang_tbl     => l_led_lang_tbl
      ,x_return_status    => l_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After populate_khr_sources: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --calling assign_khr_rec_to_fxhv_rec
    assign_khr_rec_to_fxh_rec(
       p_khr_source_rec => l_khr_source_rec
      ,x_fxh_rec        => l_fxh_rec );

    FOR tl_sources_in IN l_led_lang_tbl.FIRST .. l_led_lang_tbl.LAST
    LOOP
      l_fxhl_tbl(tl_sources_in).language          := l_led_lang_tbl(tl_sources_in).language;
      l_fxhl_tbl(tl_sources_in).contract_status   := l_led_lang_tbl(tl_sources_in).contract_status;
      -- l_fxhl_tbl(tl_sources_in).inv_agrmnt_status := l_led_lang_tbl(tl_sources_in).inv_agrmnt_status;
    END LOOP;

    -- Fetch and Populate Sales Representative Name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor  c_sales_rep_csr. p_khr_id = ' || TO_CHAR(l_khr_id) );
    FOR t_rec IN  c_sales_rep_csr (l_khr_id)
    LOOP
      l_sales_rep_csr_rec := t_rec;
      l_fxh_rec.sales_rep_name := l_sales_rep_csr_rec.name;
    END LOOP; -- End for c_sales_rep_csr

    -- Fetch and Populate Inventory Organization Name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing Cursor c_inventory_org_id_csr : l_khr_id = ' ||to_char(l_khr_id));
    FOR t_rec IN c_inventory_org_id_csr (l_khr_id)
    LOOP
      -- Assign the Inventory Organization Code
      l_inventory_org_code := t_rec.hrb_name;
      FOR tl_sources_in IN l_fxll_tbl.FIRST .. l_fxll_tbl.LAST
      LOOP
        put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
          'Executing Cursor c_org_name_csr : p_org_id = ' ||to_char(t_rec.inv_organization_id)
          || ' p_ledger_lang = ' || to_char(l_fxll_tbl(tl_sources_in).language));
        FOR t_org_rec IN c_org_name_csr (
                     p_org_id        => t_rec.inv_organization_id
                    ,p_ledger_lang   => l_fxll_tbl(tl_sources_in).language)
        LOOP
          l_fxll_tbl(tl_sources_in).inventory_org_name := t_org_rec.org_name;
        END LOOP; -- End for c_org_name_csr
      END LOOP;
    END LOOP; -- End for c_inventory_org_id_csr

    -- Calling insert_row
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_fa_extension_pvt.create_fxh_extension ' || l_fxh_rec.source_id );
    okl_fa_extension_pvt.create_fxh_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_fxh_rec         => l_fxh_rec
      ,x_fxh_rec         => lx_fxh_rec
      ,p_fxhl_tbl        => l_fxhl_tbl
      ,x_fxhl_tbl        => lx_fxhl_tbl
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_fa_extension_pvt.create_fxh_extension: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Store the Header Extension ID in to the Local Variable: l_header_extension_id
    l_header_extension_id := lx_fxh_rec.header_extension_id;
    -- Initialize the l_line_index
    l_line_index := 1;
    -- Now Loop on the Depreciated Assets Table and Capture Sources at Line Level
    FOR i IN l_deprn_asset_tbl.FIRST .. l_deprn_asset_tbl.LAST
    LOOP
      -- First of all Nullify the l_fxlv_rec
      l_fxl_rec := l_null_fxl_rec;
      --l_fxll_tbl := l_null_fxll_tbl;
      -- Assign the Mandatory Fields first like header_extension_id, fa_transaction_id [Deprn Run Id]
      -- kle_id, Asset ID, Source ID and Source ID.
      l_fxl_rec.source_id           := p_deprn_run_id; -- For time bing stamping the Deprn Run ID
      l_fxl_rec.source_table        := G_FA_DEPRN_SUMMARY;
      l_fxl_rec.header_extension_id := l_header_extension_id;
      l_fxl_rec.fa_transaction_id   := p_deprn_run_id;
      l_fxl_rec.kle_id              := l_deprn_asset_tbl(i).kle_id;
      l_fxl_rec.asset_id            := l_deprn_asset_tbl(i).asset_id;

      -- Store now the optional columns [But predicates for Deprn Ref. Views] like
      -- Book Type Code, Period Name, Period Counter
      l_fxl_rec.asset_book_type_code := p_book_type_code;
      l_fxl_rec.period_counter       := p_period_counter;

      -- MG uptake.
	  OPEN get_book_type_name(p_book_type_code);
	  FETCH get_book_type_name into l_fxl_rec.asset_book_type_name;
	  CLOSE get_book_type_name;

      -- Store the Asset and KLE_ID in the Local Varaibles for further Use
      l_kle_id   := l_deprn_asset_tbl(i).kle_id;
      l_asset_id := l_deprn_asset_tbl(i).asset_id;
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
        'KLE_ID= ' || TO_CHAR( l_kle_id) || ' ASSET_ID= ' || l_asset_id );

      -- Prepare kle_source_rec_type with khr_id, kle_id and ledger_language
      l_kle_source_rec.khr_id            := l_khr_id;
      l_kle_source_rec.kle_id            := l_kle_id;

      -- Calling populate_kle_sources
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'Calling the populate_kle_sources' );
      populate_kle_sources(
        p_api_version      => l_api_version
       ,p_init_msg_list    => p_init_msg_list
       ,x_kle_source_rec   => l_kle_source_rec
       ,x_return_status    => l_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data );
      put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
        'After populate_kle_sources: l_return_status ' || l_return_status );
      -- Check the return status and if errored, return the error back
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Assin the KLE Sources to the FA Extension Line
      assign_kle_rec_to_fxl_rec(
         p_kle_source_rec => l_kle_source_rec
        ,x_fxl_rec => l_fxl_rec );

      -- Stamp the Inventory Org Code and Name on the Asset Line
      l_fxl_rec.inventory_org_code := l_inventory_org_code;
      --l_fxl_rec.inventory_org_name := l_inventory_org_name;
      -- Store the Record Structure into the table
      l_fxl_tbl_tbl(l_line_index).fxl_rec := l_fxl_rec;
      l_fxl_tbl_tbl(l_line_index).fxll_tbl := l_fxll_tbl;
      -- l_fxlv_tbl(l_line_index) := l_fxlv_rec;
      -- Increment the l_line_index
      l_line_index := l_line_index + 1;
    END LOOP; -- FOR l_line_index IN l_deprn_asset_tbl.FIRST .. l_deprn_asset_tbl.LAST
    -- Calling insert_row
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_fa_extension_pvt.create_fxl_extension-tbl Version' );
    okl_fa_extension_pvt.create_fxl_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_fxl_tbl_tbl     => l_fxl_tbl_tbl
      ,x_fxl_tbl_tbl     => lx_fxl_tbl_tbl
     );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'After okl_fa_extension_pvt.create_fxl_extension-tbl Version: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    okl_api.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_sources;

  PROCEDURE log_msg(
              p_destination  IN NUMBER
             ,p_msg          IN VARCHAR2)
  IS
  BEGIN
   FND_FILE.PUT_LINE(p_destination, p_msg );
  END;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_deprn_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :  Asset Book Type Code      Mandatory
  --                         Period Counter            Mandatory
  --                         Worker ID                 Mandatory
  --                         Max. Deprn. Run ID        Mandatory
  --
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  --      Description: API called by the Parallel worker for the
  --                   OKL: FA Capture Sources for Depreciation Transaction
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_deprn_sources(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_book_type_code          IN               VARCHAR2
   ,p_period_counter          IN               VARCHAR2
   ,p_worker_id               IN               VARCHAR2
   ,p_max_deprn_run_id        IN               VARCHAR2
  )
  IS
    CURSOR get_okl_assets_csr(
       p_book_type_code       VARCHAR2
      ,p_period_counter       NUMBER
      ,p_max_deprn_run_id     NUMBER
      ,p_worker_id            VARCHAR2
    )
    IS
      SELECT  fa_dep.deprn_run_id     deprn_run_id
              ,ast.dnz_chr_id         khr_id
              ,ast.cle_id             kle_id
              ,fa_dep.asset_id        asset_id
        FROM   fa_deprn_summary       fa_dep
              ,okc_k_items            okc_item
              ,okc_k_lines_b          ast
              ,okl_parallel_processes opp
       WHERE   fa_dep.book_type_code    = p_book_type_code
         AND   fa_dep.period_counter    = p_period_counter
         AND   fa_dep.deprn_source_code = 'DEPRN'
         AND   fa_dep.deprn_run_id IS NOT NULL
        AND   ( fa_dep.deprn_run_id > p_max_deprn_run_id OR
                 p_max_deprn_run_id IS NULL )
         AND   NVL(okc_item.object1_id2, '#') = '#'
         AND   okc_item.jtot_object1_code = 'OKX_ASSET'
         AND   okc_item.object1_id1 = fa_dep.asset_id
         AND   okc_item.cle_id  = ast.id
         AND   ast.lse_id = 42 -- FIXED_ASSET Line Style ID
         AND   opp.assigned_process = p_worker_id -- Fetch only Current Workers Contracts
         AND   ast.dnz_chr_id = opp.khr_id
    ORDER BY   fa_dep.deprn_run_id, ast.dnz_chr_id, ast.cle_id
    ; -- End of Cursor: get_okl_assets_csr

    -- Type Declaration based on the Cursor Record Structure
    TYPE okl_deprn_assets_tbl IS TABLE OF get_okl_assets_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;

    CURSOR get_max_deprn_run_id(
       p_asset_book_type_code    VARCHAR2
      ,p_period_counter          NUMBER
    )
    IS
      SELECT  MAX(fa_transaction_id)  max_deprn_run_id
        FROM  okl_ext_fa_line_sources_b  fxl
       WHERE  fxl.source_table = 'FA_DEPRN_SUMMARY'
         AND  fxl.asset_book_type_code = p_asset_book_type_code
         AND  fxl.period_counter = p_period_counter
    ; -- End of Cursor get_max_deprn_run_id

    -- Local Variable Declaration
    l_outer_error_msg_tbl        Okl_Accounting_Util.Error_Message_Type;
    l_book_type_code             VARCHAR2(240);
    l_period_counter             NUMBER;
    l_max_deprn_run_id           NUMBER;
    l_fa_deprn_assets_tbl        okl_deprn_assets_tbl;
    l_deprn_asset_tbl            deprn_asset_tbl_type;
    l_khr_id                     NUMBER;
    l_curr_deprn_run_id          NUMBER;
    ast_index                    NUMBER; -- Index for the l_deprn_asset_tbl
    -- Common Local Variables
    l_api_name                   CONSTANT VARCHAR2(30) := 'POPULATE_DEPRN_SOURCES';
    l_init_msg_list              VARCHAR2(2000)        := OKL_API.G_FALSE;
    l_return_status              VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_api_version                CONSTANT NUMBER := 1.0;
    l_khr_id_tbl                 Okl_Streams_Util.NumberTabTyp;
    khr_index                    NUMBER;
  BEGIN
    -- Assign the input params to the Local Variables
    l_book_type_code := p_book_type_code;
    l_period_counter := TO_NUMBER(p_period_counter);
    log_msg(FND_FILE.LOG, 'Parameters: ' );
    log_msg(FND_FILE.LOG, ' Book Type Code = ' || l_book_type_code );
    log_msg(FND_FILE.LOG, ' Period Counter = ' || l_period_counter );
    log_msg(FND_FILE.LOG, ' Worker ID      = ' || p_worker_id );
    log_msg(FND_FILE.LOG, ' Max. Deprn. ID = ' || p_max_deprn_run_id );
    -- Find the Last Depreciation Run for which the Sources are captured
    --  for the inputted Book Type Code and Period
    l_max_deprn_run_id := TO_NUMBER( p_max_deprn_run_id );
    -- Initialize the khr_index
    khr_index := 0;
    -- Fetch all the OKL Assets for which FA has generated Depreciation Transactions
    --  in the inputted Asset Book and Period
    log_msg(FND_FILE.LOG, 'Before Executing the Cursor get_okl_assets_csr' );
    OPEN get_okl_assets_csr(
       p_book_type_code       => l_book_type_code
      ,p_period_counter       => l_period_counter
      ,p_max_deprn_run_id     => l_max_deprn_run_id
      ,p_worker_id            => p_worker_id
    );
    LOOP
      FETCH get_okl_assets_csr BULK COLLECT INTO l_fa_deprn_assets_tbl
        LIMIT 10000;
      log_msg(FND_FILE.LOG, 'After Executing the Cursor get_okl_assets_csr' );
      -- Exit when there are no Assets to be Processed
      EXIT WHEN get_okl_assets_csr%ROWCOUNT = 0;
      IF l_fa_deprn_assets_tbl.COUNT > 0
      THEN
        log_msg(FND_FILE.LOG, 'Total Number of Assets to be Processed in this iteration=' || l_fa_deprn_assets_tbl.COUNT );
        l_curr_deprn_run_id := l_fa_deprn_assets_tbl(l_fa_deprn_assets_tbl.FIRST).deprn_run_id;
        l_khr_id := l_fa_deprn_assets_tbl(l_fa_deprn_assets_tbl.FIRST).khr_id;
        -- Increment the khr_index and store the contract number in the l_khr_id_tbl
        khr_index := khr_index + 1;
        l_khr_id_tbl(khr_index) := l_khr_id; -- Store the Contract ID Already processed
        l_deprn_asset_tbl.DELETE;
        -- Initialize the ast_index
        ast_index := 1;
        log_msg(FND_FILE.OUTPUT, '-------------------------------------------------------------------' );
        log_msg(FND_FILE.OUTPUT, 'Capturing Sources for Deprn Run ID: ' || l_curr_deprn_run_id );
        log_msg(FND_FILE.OUTPUT, '-------------------------------------------------------------------' );
        log_msg(FND_FILE.OUTPUT, '  Capture Sources for ' );
        log_msg(FND_FILE.OUTPUT, '    KHR_ID=' || l_khr_id );
        FOR i IN l_fa_deprn_assets_tbl.FIRST .. l_fa_deprn_assets_tbl.LAST
        LOOP
          -- Logic:
          --  Loop on the OKL Assets Table [Ordered by KHR_ID]
          --  Once a break on the KHR_ID or Deprn. Run ID comes up .. Call the Populate Sources API
          --   Till then .. store all the assets in a collection ..
          IF l_curr_deprn_run_id = l_fa_deprn_assets_tbl(i).deprn_run_id AND
             l_khr_id = l_fa_deprn_assets_tbl(i).khr_id
          THEN
            -- Keep Storing the KLE_ID and ASSET_ID in the l_deprn_asset_tbl
            l_deprn_asset_tbl(ast_index).kle_id   := l_fa_deprn_assets_tbl(i).kle_id;
            l_deprn_asset_tbl(ast_index).asset_id := l_fa_deprn_assets_tbl(i).asset_id;
            log_msg(FND_FILE.OUTPUT, '      KLE_ID=' || l_fa_deprn_assets_tbl(i).kle_id ||
              ' ASSET_ID=' || l_fa_deprn_assets_tbl(i).asset_id );
            -- Increment the Index
            ast_index := ast_index + 1;
          ELSE
            -- Call the Populate Sources
            log_msg(FND_FILE.LOG, 'Before Calling Populate Sources - Contract/Deprn Run Break' );
            log_msg(FND_FILE.LOG, ' khr_id=' || l_khr_id );
            log_msg(FND_FILE.LOG, ' Asset Count=' || l_deprn_asset_tbl.COUNT );
            log_msg(FND_FILE.LOG, ' Book Type=' || l_book_type_code );
            log_msg(FND_FILE.LOG, ' Period Counter=' || l_period_counter );
            populate_sources(
              p_api_version     => l_api_version
             ,p_init_msg_list   => l_init_msg_list
             ,p_khr_id          => l_khr_id
             ,p_deprn_asset_tbl => l_deprn_asset_tbl
             ,p_deprn_run_id    => l_curr_deprn_run_id
             ,p_book_type_code  => l_book_type_code
             ,p_period_counter  => l_period_counter
             ,x_return_status   => l_return_status
             ,x_msg_count       => l_msg_count
             ,x_msg_data        => l_msg_data
            );
            log_msg(FND_FILE.LOG, ' After Calling the Populate Sources return_status=' || l_return_status );
            IF l_return_status = OKL_API.G_RET_STS_ERROR
            THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            log_msg(FND_FILE.OUTPUT, '---------------------------------------------------------' );
            -- Reset the Khr_id to the current KHR_ID
            l_khr_id := l_fa_deprn_assets_tbl(i).khr_id;
            -- Increment the khr_index and store the contract number in the l_khr_id_tbl
            khr_index := khr_index + 1;
            l_khr_id_tbl(khr_index) := l_khr_id; -- Store the Contract ID Already processed
            IF l_curr_deprn_run_id <> l_fa_deprn_assets_tbl(i).deprn_run_id
            THEN
              -- Break Happened on the Deprn Run ID itself .. Hence,
              -- Reset the Depreciation Run ID
              l_curr_deprn_run_id := l_fa_deprn_assets_tbl(i).deprn_run_id;
              log_msg(FND_FILE.OUTPUT, '-------------------------------------------------------------------' );
              log_msg(FND_FILE.OUTPUT, 'Capturing Sources for Deprn Run ID: ' || l_curr_deprn_run_id );
              log_msg(FND_FILE.OUTPUT, '-------------------------------------------------------------------' );
            END IF; -- Break on the Deprn Run ID
            -- Delete the l_deprn_asset_tbl
            l_deprn_asset_tbl.DELETE;
            -- Initialize teh ast_index
            ast_index := 1;
            -- Store the kle_id and asset_id in the current index of the l_deprn_asset_tbl
            l_deprn_asset_tbl(ast_index).kle_id   := l_fa_deprn_assets_tbl(i).kle_id;
            l_deprn_asset_tbl(ast_index).asset_id := l_fa_deprn_assets_tbl(i).asset_id;
            log_msg(FND_FILE.OUTPUT, 'Capture Sources for ' );
            log_msg(FND_FILE.OUTPUT, '  KHR_ID=' || l_khr_id );
            log_msg(FND_FILE.OUTPUT, '    KLE_ID=' || l_fa_deprn_assets_tbl(i).kle_id ||
              ' ASSET_ID=' || l_fa_deprn_assets_tbl(i).asset_id );
            -- Increment the Index
            ast_index := ast_index + 1;
          END IF;
        END LOOP; -- FOR i IN l_deprn_assets_tbl.FIRST .. l_deprn_assets_tbl.LAST
        -- Call the Populate Sources at the End too for the lastly Populated Records
        log_msg(FND_FILE.OUTPUT, '---------------------------------------------------------' );
        -- Call the Populate Sources
        log_msg(FND_FILE.LOG, 'Before Calling Populate Sources - At the End of the Loop' );
        log_msg(FND_FILE.LOG, ' khr_id=' || l_khr_id );
        log_msg(FND_FILE.LOG, ' Asset Count=' || l_deprn_asset_tbl.COUNT );
        log_msg(FND_FILE.LOG, ' Book Type=' || l_book_type_code );
        log_msg(FND_FILE.LOG, ' Period Counter=' || l_period_counter );
        populate_sources(
          p_api_version     => l_api_version
         ,p_init_msg_list   => l_init_msg_list
         ,p_khr_id          => l_khr_id
         ,p_deprn_asset_tbl => l_deprn_asset_tbl
         ,p_deprn_run_id    => l_curr_deprn_run_id
         ,p_book_type_code  => l_book_type_code
         ,p_period_counter  => l_period_counter
         ,x_return_status   => l_return_status
         ,x_msg_count       => l_msg_count
         ,x_msg_data        => l_msg_data
        );
        log_msg(FND_FILE.LOG, ' After Calling the Populate Sources return_status=' || l_return_status );
        IF l_return_status = OKL_API.G_RET_STS_ERROR
        THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- IF l_deprn_assets_tbl.COUNT > 0
      -- Exit When Cursor Has been Exhausted fetching all the Records
      EXIT WHEN get_okl_assets_csr%NOTFOUND;
    END LOOP; -- Loop on get_okl_assets_csr
    CLOSE get_okl_assets_csr;  -- Close the Cursor
    -- Now Delete all the processed records from parallel process table
    FORALL khr_index IN l_khr_id_tbl.FIRST .. l_khr_id_tbl.LAST
      DELETE  OKL_PARALLEL_PROCESSES
       WHERE  khr_id = l_khr_id_tbl(khr_index);
    -- Return the Proper Return status
    retcode := 0; -- 0 Indicates 'S'uccess Status
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN Okl_Api.G_EXCEPTION_ERROR
    THEN
      l_return_status := Okl_Api.G_RET_STS_ERROR;
      -- print the error message in the log file and output files
      log_msg(FND_FILE.OUTPUT,'');
      log_msg(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      log_msg(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0) THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
           log_msg(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;
      retcode := 2;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- print the error message in the log file
      log_msg(FND_FILE.OUTPUT,'');
      log_msg(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      log_msg(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0)
      THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          log_msg(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;
      retcode := 2;

    WHEN OTHERS
    THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      -- print the error message in the log file
      log_msg(FND_FILE.OUTPUT,'');
      log_msg(FND_FILE.OUTPUT,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_ERROR'));
      log_msg(FND_FILE.LOG,FND_MESSAGE.GET_STRING('OKL','OKL_AGN_RPT_PROGRAM_STATUS')
	                    ||' '||l_return_status);
      Okl_Accounting_Util.GET_ERROR_MESSAGE(l_outer_error_msg_tbl);
      IF (l_outer_error_msg_tbl.COUNT > 0)
      THEN
        FOR i IN l_outer_error_msg_tbl.FIRST..l_outer_error_msg_tbl.LAST
        LOOP
          log_msg(FND_FILE.LOG, l_outer_error_msg_tbl(i));
        END LOOP;
      END IF;
      errbuf := SQLERRM;
      retcode := 2;
  END populate_deprn_sources;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_deprn_sources_conc
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :  Asset Book Type Code      Mandatory
  --                         Period Counter            Mandatory
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  --      Description: API called by the Master Program of the conc. job
  --                   OKL: FA Capture Sources for Depreciation Transaction
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_deprn_sources_conc(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_book_type_code          IN               VARCHAR2
   ,p_period_counter          IN               NUMBER
  )
  IS
    CURSOR get_deprn_contracts_csr(
       p_book_type_code       VARCHAR2
      ,p_period_counter       NUMBER
      ,p_max_deprn_run_id     NUMBER
    )
    IS
      SELECT   chr.id                 khr_id
              ,chr.contract_number    contract_number
              ,COUNT(fa_dep.asset_id) no_of_assets
        FROM   fa_deprn_summary       fa_dep
              ,fa_books               fa_books
              ,okc_k_headers_all_b    chr
       WHERE   -- Predicates on fa_deprn_summary
               fa_dep.book_type_code    = p_book_type_code
         AND   fa_dep.period_counter    = p_period_counter
         AND   fa_dep.deprn_source_code = 'DEPRN'
         AND   fa_dep.deprn_run_id IS NOT NULL
         AND   ( fa_dep.deprn_run_id > p_max_deprn_run_id OR
                 p_max_deprn_run_id IS NULL )
         -- Predicates on fa_books
         AND   fa_books.transaction_header_id_out IS NULL
         AND   fa_books.date_ineffective IS NULL
         AND   fa_books.contract_id IS NOT NULL
         -- Join Conditions between fa_deprn_summary and fa_books
         AND   fa_dep.asset_id = fa_books.asset_id
         AND   fa_dep.book_type_code = fa_books.book_type_code
         -- Join conditions between fa_books and okc_k_headers_all_b
         AND   fa_books.contract_id = chr.id
    GROUP BY   chr.id, CHR.contract_number
    ORDER BY   COUNT(fa_dep.asset_id) DESC;

    -- Cursor to fetch the Maximum Deprecation ID from the FA Extension Line Table
    CURSOR get_max_deprn_run_id(
       p_asset_book_type_code    VARCHAR2
      ,p_period_counter          NUMBER
    )
    IS
      SELECT  MAX(fa_transaction_id)  max_deprn_run_id
        FROM  okl_ext_fa_line_sources_b  fxl
       WHERE  fxl.source_table = 'FA_DEPRN_SUMMARY'
         AND  fxl.asset_book_type_code = p_asset_book_type_code
         AND  fxl.period_counter = p_period_counter
    ; -- End of Cursor get_max_deprn_run_id

    -- Local Record and Table Variables based on Cursors/Tables
    get_deprn_contracts_rec           get_deprn_contracts_csr%ROWTYPE;
    TYPE deprn_contracts_tbl_type  IS TABLE OF get_deprn_contracts_csr%ROWTYPE
      INDEX BY BINARY_INTEGER;
    l_deprn_contracts_tbl         deprn_contracts_tbl_type;
    l_temp_deprn_contracts_tbl    deprn_contracts_tbl_type;
    l_object_value_tbl            Okl_Streams_Util.Var240TabTyp;
    l_assigned_process_tbl        Okl_Streams_Util.Var30TabTyp;
    l_khr_id_tbl                  Okl_Streams_Util.NumberTabTyp;
    l_volume_tbl                  Okl_Streams_Util.NumberTabTyp;
    -- Local Variable Declaration
    dep_index                     NUMBER; -- Index for the l_deprn_contracts_tbl
    req_data                      VARCHAR2(10);
    l_book_type_code              VARCHAR2(240);
    l_period_counter              NUMBER;
    l_max_deprn_run_id            NUMBER;
    l_num_workers                 NUMBER;
    l_seq_next                    NUMBER;
    l_data_found                  BOOLEAN := FALSE;
    l_worker_id                   VARCHAR2(2000);
    l_worker_load                 worker_load_tab;
    l_lightest_worker             NUMBER;
    l_lightest_load               NUMBER;
    l_reqid                       FND_CONCURRENT_REQUESTS.request_id%TYPE;
  BEGIN
    req_data := fnd_conc_global.request_data;
    log_msg(FND_FILE.LOG, 'Request Data= ' || req_data );
    IF req_data IS NOT NULL
    THEN
      errbuf:='Done';
      retcode := 0;
      log_msg(FND_FILE.LOG, 'Returning Out Successfully !' );
      RETURN;
    ELSE
      -- When the req_data is NULL, it means that this is the first run of the Program ..
      -- in the Sense, the current request is the run before triggerring off any parallel workers
      -- Fetch the Number of Workers to be Assigned
      l_num_workers := FND_PROFILE.VALUE(G_OKL_DEPRN_WORKERS);
      log_msg(FND_FILE.LOG, 'Number of Workers ' || TO_CHAR(l_num_workers) );
      IF l_num_workers IS NULL OR l_num_workers <= 0
      THEN
        OKL_API.set_message(
           p_app_name     => G_APP_NAME
	        ,p_msg_name     => G_OKL_DEPRN_WORKER_ERROR);
        log_msg(FND_FILE.LOG, 'Please specify positive value for the profile option OKL: Capture Sources for Asset Depreciation Concurrent Workers');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Select sequence for marking processes
      SELECT  okl_opp_seq.NEXTVAL
        INTO  l_seq_next
        FROM  DUAL;
      -- Assign the input params to the Local Variables
      l_book_type_code := p_book_type_code;
      l_period_counter := p_period_counter;
      -- Log the Input Variables
      log_msg(FND_FILE.LOG, 'Parameters: ' );
      log_msg(FND_FILE.LOG, ' Book Type Code =' || l_book_type_code );
      log_msg(FND_FILE.LOG, ' Period Counter =' || l_period_counter );
      -- Find the Last Depreciation Run for which the Sources are captured
      --  for the inputted Book Type Code and Period
      log_msg(FND_FILE.LOG, 'Before Executing the Cursor get_max_deprn_run_id' );
      l_max_deprn_run_id := NULL;
      FOR t_rec IN get_max_deprn_run_id(
         p_asset_book_type_code    => l_book_type_code
        ,p_period_counter          => l_period_counter
      )
      LOOP
        -- Store the Max. Deprn Run ID in the l_max_deprn_run_id
        l_max_deprn_run_id := t_rec.max_deprn_run_id;
      END LOOP; -- FOR t_rec IN get_max_deprn_run_id(
      log_msg(FND_FILE.LOG, 'After Executing the Cursor get_max_deprn_run_id. Max Deprn Run ID= ' || l_max_deprn_run_id );
      -- Initialize the dep_index first
      dep_index := 1;
      -- Fetch all the OKL Assets for which FA has generated Depreciation Transactions
      --  in the inputted Asset Book and Period
      log_msg(FND_FILE.LOG, 'Before Executing the Cursor get_deprn_contracts_csr' );
      OPEN get_deprn_contracts_csr(
         p_book_type_code       => l_book_type_code
        ,p_period_counter       => l_period_counter
        ,p_max_deprn_run_id     => l_max_deprn_run_id
      );
      LOOP
        -- Bulk Collect the Contracts which has Assets depreciated in the inputted
        --  Book Type and Period
        FETCH get_deprn_contracts_csr BULK COLLECT INTO l_temp_deprn_contracts_tbl
          LIMIT G_LIMIT_SIZE;
        log_msg(FND_FILE.LOG, 'After Executing the fetch on the Cursor get_okl_assets_csr' );
        log_msg(FND_FILE.LOG, 'Distinct Contracts fetched in this Loop ' || l_temp_deprn_contracts_tbl.COUNT );
        -- Exit without setting the l_data_found to TRUE as no records found here
        EXIT WHEN get_deprn_contracts_csr%ROWCOUNT = 0;
        -- Assign the flag to indicate that there are few records found
        l_data_found := TRUE;
        -- Loop on the l_temp_deprn_contracts_tbl and append the records at the end of the
        -- l_deprn_contracts_tbl
        FOR i IN l_temp_deprn_contracts_tbl.FIRST .. l_temp_deprn_contracts_tbl.LAST
        LOOP
          l_deprn_contracts_tbl(dep_index) := l_temp_deprn_contracts_tbl(i);
          -- Increment the dep_index
          dep_index := dep_index + 1;
        END LOOP;
        -- Delete the Temporary Table now ..
        l_temp_deprn_contracts_tbl.DELETE;
        -- Exit when there are no Assets to be Processed
        EXIT WHEN get_deprn_contracts_csr%NOTFOUND;
      END LOOP; -- Loop on get_deprn_contracts_csr
      CLOSE get_deprn_contracts_csr;  -- Close the Cursor

      IF l_data_found = TRUE
      THEN
        log_msg(FND_FILE.LOG, 'Total Number of records fetched=' || l_deprn_contracts_tbl.COUNT );
        -- Assign the data from the l_deprn_contracts_tbl to l_pp_deprn_khrs_tbl
        FOR dep_index IN l_deprn_contracts_tbl.FIRST .. l_deprn_contracts_tbl.LAST
        LOOP
          l_object_value_tbl(dep_index)     := l_deprn_contracts_tbl(dep_index).contract_number;
          l_khr_id_tbl(dep_index)           := l_deprn_contracts_tbl(dep_index).khr_id;
          l_volume_tbl(dep_index)           := l_deprn_contracts_tbl(dep_index).no_of_assets;
          l_assigned_process_tbl(dep_index) := TO_CHAR(l_seq_next);
        END LOOP;
        log_msg(FND_FILE.LOG, 'Successfully Populated the Individual Collection Tables object_value, khr_id, volume tables');
        -- Bulk Insert all the records into the OKL_PARALLEL_PROCESSES
        log_msg(FND_FILE.LOG, 'Before calling the Bulk Insert into the OKL_PARALLEL_PROCESSES' );
        FORALL dep_index IN l_deprn_contracts_tbl.FIRST .. l_deprn_contracts_tbl.LAST
          INSERT INTO OKL_PARALLEL_PROCESSES (
             OBJECT_TYPE
            ,OBJECT_VALUE
            ,ASSIGNED_PROCESS
            ,PROCESS_STATUS
            ,CREATION_DATE
            ,KHR_ID
            ,VOLUME
          )
          VALUES (
             G_OBJECT_TYPE_DEP_KHR             -- Object Type
            ,l_object_value_tbl(dep_index)     -- Object Value
            ,l_assigned_process_tbl(dep_index) -- Assigned Process
            ,'PENDING_ASSIGNMENT'              -- Process Status
            ,SYSDATE                           -- Creation Date
            ,l_khr_id_tbl(dep_index)           -- KHR_ID
            ,l_volume_tbl(dep_index)           -- Volume
          );
        log_msg(FND_FILE.LOG, 'After calling the Bulk Insert into the OKL_PARALLEL_PROCESSES' );
        -- Commit the Records
        COMMIT;
        log_msg(FND_FILE.LOG, 'Committed the Insertion of the OKL_PARALLEL_PROCESSES Records' );
        -- Create l_num_workers number of Workers
        FOR i in 1..l_num_workers
        LOOP -- put all workers into a table
          l_worker_load(i).worker_number := i;
          l_worker_load(i).worker_load := 0; -- initialize load with zero
          l_worker_load(i).used := FALSE; -- Initialize with FALSE as none are assigned to this
        END LOOP;
        log_msg(FND_FILE.LOG, 'Initialized totally ' || l_num_workers || ' workers ' );
        log_msg(FND_FILE.LOG, 'Allocation of Workers for every contract is in Progress .. ' );
        l_lightest_worker := 1;
        -- Loop through the Depreciation Contracts and Assign the Workers
        FOR dep_index IN l_deprn_contracts_tbl.FIRST .. l_deprn_contracts_tbl.LAST
        LOOP
          l_assigned_process_tbl(dep_index) := l_lightest_worker;
          -- put current contract into the lightest worker
          IF l_worker_load.EXISTS(l_lightest_worker)
          THEN
            -- Increment the Assigned Worker Load by Number of Assets
            l_worker_load(l_lightest_worker).worker_load :=
              l_worker_load(l_lightest_worker).worker_load +
              l_deprn_contracts_tbl(dep_index).no_of_assets;
            -- Update the used flag of the current lightest worker to indicate that its used.
            l_worker_load(l_lightest_worker).used := TRUE;
          END IF;
          -- default the lighest load with the first element as a starting point
          IF l_worker_load.EXISTS(1)
          THEN
            l_lightest_load := l_worker_load(1).worker_load;
            l_lightest_worker := l_worker_load(1).worker_number;
            -- logic to find lightest load
            FOR i in 1..l_worker_load.COUNT
            LOOP
              IF (l_worker_load(i).worker_load = 0)
                 OR (l_worker_load(i).worker_load < l_lightest_load)
              THEN
                l_lightest_load   := l_worker_load(i).worker_load;
                l_lightest_worker := l_worker_load(i).worker_number;
              END IF;
            END LOOP;
          END IF;
        END LOOP; -- FOR dep_index IN l_deprn_contracts_tbl.FIRST .. l_deprn_contracts_tbl.LAST
        log_msg(FND_FILE.LOG, 'Done with allocation of Workers for every contract.' );
        log_msg(FND_FILE.LOG, 'Process Sequence Number =' || l_seq_next );
        log_msg(FND_FILE.LOG, 'G_OBJECT_TYPE_DEP_KHR   =' || G_OBJECT_TYPE_DEP_KHR );
        log_msg(FND_FILE.LOG, 'Assigned Process              Contract Number                         KHR_ID                           Volume           ');
        log_msg(FND_FILE.LOG, '------------------------------------------------------------------------------------------------------------------------');
        FOR dep_index in l_deprn_contracts_tbl.FIRST .. l_deprn_contracts_tbl.LAST
        LOOP
          log_msg(FND_FILE.LOG, RPAD(l_assigned_process_tbl(dep_index),30, ' ') ||
                                RPAD(l_object_value_tbl(dep_index),40, ' ')  ||
                                RPAD(l_khr_id_tbl(dep_index),32, ' ' ) ||
                                LPAD(l_volume_tbl(dep_index),15, ' ') );
        END LOOP;
        -- Now Bulk Update the Contract Numbers in Parallel Processes with the
        -- Assigned Worker Number
        FORALL dep_index in l_deprn_contracts_tbl.FIRST .. l_deprn_contracts_tbl.LAST
          UPDATE  OKL_PARALLEL_PROCESSES
             SET  assigned_process =  l_seq_next || '-' || l_assigned_process_tbl(dep_index)
                 ,process_status   = 'ASSIGNED'
           WHERE  object_type      = G_OBJECT_TYPE_DEP_KHR
             AND  object_value     = l_object_value_tbl(dep_index)
             AND  process_status   = 'PENDING_ASSIGNMENT'
             AND  khr_id           = l_khr_id_tbl(dep_index);
        log_msg(FND_FILE.LOG, 'Updated the Records in OKL_PARALLEL_PROCESSES with the Assigned Process' );
        -- COMMIT the Updation;
        COMMIT;
        log_msg(FND_FILE.LOG, 'Committed the Updation Changes' );
        FOR i in l_worker_load.FIRST .. l_worker_load.LAST
        LOOP
          -- Request only if the Worker is used and has some load to process ..
          IF l_worker_load(i).used
          THEN
            l_worker_id := TO_CHAR(l_seq_next)||'-'||TO_CHAR(i);
            -- FND_REQUEST.set_org_id(MO_GLOBAL.get_current_org_id); --MOAC- Concurrent request
            log_msg(FND_FILE.LOG, 'Submitted the Request with worker_id=' || l_worker_id );
            l_reqid := FND_REQUEST.submit_request(
                          application  => 'OKL'
                         ,program      => 'OKLCAPFADEPRNW' -- Parallel Worker Conc. Program
                         ,sub_request  => TRUE
                         ,argument1    => p_book_type_code
                         ,argument2    => p_period_counter
                         ,argument3    => l_worker_id
                         ,argument4    => l_max_deprn_run_id);
            log_msg(FND_FILE.LOG, '  Returned request_id=' || l_reqid );
            IF l_reqid = 0
            THEN
              -- Request Submission failed with Error .. Hence, Exit with Error
              errbuf := fnd_message.get;
              retcode := 2;
            ELSE
              errbuf := 'Sub-Request submitted successfully';
              retcode := 0 ;
            END IF;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Launching Process '||l_worker_id||' with Request ID '||l_reqid);
          END IF; -- IF l_worker_load(i).used
        END LOOP; -- FOR j in 1 .. l_worker_load.LAST
        -- Set the Request Data to be used in the re-run of the Master Program ..
        FND_CONC_GLOBAL.set_req_globals(
            conc_status => 'PAUSED'
           ,request_data => '2 RUN'); -- Instead of NULL, it was i here ..
      ELSE
        log_msg(FND_FILE.LOG, 'No workers assigned due to no data found for prcocesing');
      END IF; -- IF l_data_found = TRUE
    END IF;
  END populate_deprn_sources_conc;

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL Receipt Transactions
  --      Parameters      :
  --      IN              :
  --      History         : Ravindranath Gooty Created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_rxh_rec                   IN             rxh_rec_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  )
  IS
    -----------------------------------------------------------------
    -- Declare Process Variable
    -----------------------------------------------------------------
    l_api_version          CONSTANT NUMBER         := 1;
    l_api_name             CONSTANT VARCHAR2(30)   := 'POPULATE_SOURCES-RECEIPT';
    l_return_status        VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    -- Local Variables for enabling the Debug Statements
    l_module CONSTANT fnd_log_messages.module%TYPE := G_MODULE || l_api_name;
    l_debug_enabled       VARCHAR2(10);
    is_debug_procedure_on BOOLEAN;
    is_debug_statement_on BOOLEAN;
    -----------------------------------------------------------------
    -- Local Variables
    -----------------------------------------------------------------
    l_ar_receipt_id               NUMBER;
    l_khr_id                      NUMBER;
    l_ledger_id                   NUMBER;
    l_rxh_rec                     rxh_rec_type;
    lx_rxh_rec                    rxh_rec_type;
    l_rxhl_tbl                    rxhl_tbl_type;
    lx_rxhl_tbl                   rxhl_tbl_type;
    tl_indx                       NUMBER; -- Index for the l_rxhl_tbl
    l_khr_source_rec              khr_source_rec_type;
    l_led_lang_tbl                led_lang_tbl_type;
  BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on PROCEDURE level
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'begin debug OKLRSLAB.pls call ' || l_api_name);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
               'BEGIN API OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES');
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Calling OKL_API.START_ACTIVITY');
    l_return_status := OKL_API.START_ACTIVITY(
                         p_api_name       => l_api_name
                        ,p_pkg_name       => g_pkg_name
                        ,p_init_msg_list  => p_init_msg_list
                        ,l_api_version    => l_api_version
                        ,p_api_version    => p_api_version
                        ,p_api_type       => '_PVT'
                        ,x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Assign the Input Parameters to the Local Variables
    l_ar_receipt_id := p_rxh_rec.source_id;
    l_khr_id        := p_rxh_rec.khr_id;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'L_AR_RECEIPT_ID= ' || TO_CHAR(l_ar_receipt_id) || ' L_KHR_ID= ' || TO_CHAR(l_khr_id) );
    -- Validation 1: p_ar_receipt_id Should not be NULL
    IF l_ar_receipt_id IS NULL
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'P_RXH_REC.SOURCE_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Validation 2: p_khr_id Should not be NULL
    IF l_khr_id IS NULL
    THEN
      OKL_API.set_message(
         p_app_name      => G_APP_NAME
        ,p_msg_name      => G_INVALID_VALUE
        ,p_token1        => G_COL_NAME_TOKEN
        ,p_token1_value  => 'P_RXH_REC.KHR_ID');
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    -- Assign the AR Receipt ID to the Header Extension Source ID Column
    l_rxh_rec := p_rxh_rec; -- Source ID and KHR_ID will be initalized
    l_rxh_rec.source_table := G_AR_CASH_RECEIPTS;

    -- Now, fetch ledger id and ledger language associated to the contracts
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_khr_to_ledger_id_csr. p_khr_id=' || TO_CHAR(l_khr_id));
    FOR t_rec IN c_khr_to_ledger_id_csr( p_khr_id => l_khr_id )
    LOOP
      l_ledger_id := t_rec.ledger_id;
    END LOOP;

    -- Initialize the tl_indx
    tl_indx := 1;
    -- Fetch the ledger language in order to populate the sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor c_ledger_lang_csr. p_ledger_id=' || TO_CHAR(l_ledger_id));
    FOR t_rec IN c_ledger_lang_csr( p_ledger_id => l_ledger_id )
    LOOP
      l_led_lang_tbl(tl_indx).language := t_rec.language_code;
      -- Increment the tl_indx
      tl_indx := tl_indx + 1;
    END LOOP;
    -- Call the Populate Sources to fetch the Lease Contract/IA related Sources
    l_khr_source_rec.khr_id  := l_khr_id;
    -- Calling populate_khr_sources to fetch the KHR Sources
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Before calling the populate_khr_sources' );
    populate_khr_sources(
       p_api_version      => l_api_version
      ,p_init_msg_list    => p_init_msg_list
      ,x_khr_source_rec   => l_khr_source_rec
      ,x_led_lang_tbl     => l_led_lang_tbl
      ,x_return_status    => l_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After populate_khr_sources: l_return_status ' || l_return_status );
    -- Check the return status and if errored, return the error back
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Assign the KHR Sources to the AR Extension Header Table Record
    assign_khr_rec_to_rxh_rec(
       p_khr_source_rec => l_khr_source_rec
      ,x_rxh_rec        => l_rxh_rec );
    -- Fetch and Populate Sales Representative Name
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'Executing the Cursor  c_sales_rep_csr. p_khr_id = ' || TO_CHAR(l_khr_id) );
    FOR t_rec IN  c_sales_rep_csr (l_khr_id)
    LOOP
      l_rxh_rec.sales_rep_name := t_rec.name;
    END LOOP; -- End for c_sales_rep_csr

    FOR tl_indx IN l_led_lang_tbl.FIRST .. l_led_lang_tbl.LAST
    LOOP
      l_rxhl_tbl(tl_indx).language          := l_led_lang_tbl(tl_indx).language;
      l_rxhl_tbl(tl_indx).contract_status   := l_led_lang_tbl(tl_indx).contract_status;
      l_rxhl_tbl(tl_indx).inv_agrmnt_status := l_led_lang_tbl(tl_indx).inv_agrmnt_status;
    END LOOP;

    -- Now call the API to insert the Sources in the OKL_EXT_AR_HEADER_SOURCES_B/_TL table
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling the okl_ar_extension_pvt.create_rxh_extension ' || l_rxh_rec.source_id );
    okl_ar_extension_pvt.create_rxh_extension(
       p_api_version     => l_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,x_return_status   => l_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
      ,p_rxh_rec         => l_rxh_rec
      ,p_rxhl_tbl        => l_rxhl_tbl
      ,x_rxh_rec         => lx_rxh_rec
      ,x_rxhl_tbl        => lx_rxhl_tbl
    );
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'S',
      'After call to okl_ar_extension_pvt.create_rxh_extension: l_return_status ' || l_return_status );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'Calling okl_api.end_activity');
    OKL_API.end_activity(
       x_msg_count => x_msg_count
      ,x_msg_data  => x_msg_data);
    put_in_log(l_debug_enabled,is_debug_procedure_on,is_debug_statement_on,l_module, 'P',
      'END OKL_SLA_ACC_SOURCES_PVT.POPULATE_SOURCES_RECEIPT');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => OKL_API.G_RET_STS_ERROR
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                           p_api_name  => l_api_name
                          ,p_pkg_name  => G_PKG_NAME
                          ,p_exc_name  => OKL_API.G_RET_STS_UNEXP_ERROR
                          ,x_msg_count  => x_msg_count
                          ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                            p_api_name  => l_api_name
                           ,p_pkg_name  => G_PKG_NAME
                           ,p_exc_name  => 'OTHERS'
                           ,x_msg_count  => x_msg_count
                           ,x_msg_data  => x_msg_data
                           ,p_api_type  => '_PVT');
  END populate_sources;

END okl_sla_acc_sources_pvt;

/
