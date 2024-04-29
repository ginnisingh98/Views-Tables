--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_TRANS_PVT" AS
/* $Header: OKLRPIIB.pls 120.25.12010000.2 2009/12/01 01:18:38 sachandr ship $ */

--start:| 16-Oct-2007 cklee -- Fixed bug:6502786                                     |
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
--end:| 16-Oct-2007 cklee -- Fixed bug:6502786                                     |
	-----------------------------------------------------------------
    --30/May/02 Added vendor_id and line type for NVL
	-----------------------------------------------------------------

PROCEDURE transfer
    (p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY      VARCHAR2
	,x_msg_count		OUT NOCOPY      NUMBER
	,x_msg_data		    OUT NOCOPY      VARCHAR2)
IS

/* rkuttiya modified removed old code */

    l_xpi_id  			okl_ext_pay_invs_b.id%type;
    v_description 		ap_invoices_interface.description%type;

    l_api_version	    CONSTANT NUMBER         := 1;
    l_api_name	        CONSTANT VARCHAR2(30)   := 'TRANSFER';
    l_return_status	    VARCHAR2(1)             := OKL_API.G_RET_STS_SUCCESS;
    l_self_bill_invnum  VARCHAR2(150);
    l_contract_number   VARCHAR2(120);
    l_vendor_id			po_vendor_sites_all.vendor_id%TYPE;
    l_amount_includes_tax_flag po_vendor_sites_all.amount_includes_tax_flag%TYPE;
    l_taxable_yn          VARCHAR2(1);

--start:| 16-Oct-2007 cklee -- Fixed bug:6502786                                     |
    CURSOR c_account_derivation IS
     select account_derivation,
	        PAY_DIST_SET_ID
     from OKL_SYS_ACCT_OPTS;

     l_account_derivation OKL_SYS_ACCT_OPTS_ALL.account_derivation%type := NULL;
     l_PAY_DIST_SET_ID    OKL_SYS_ACCT_OPTS_ALL.PAY_DIST_SET_ID%type := NULL;
--end:| 16-Oct-2007 cklee -- Fixed bug:6502786                                     |

    CURSOR c_invoice_hdr IS
    SELECT *
    FROM okl_ext_pay_invs_b
    WHERE trx_status_code = 'ENTERED'
    FOR UPDATE OF TRX_STATUS_CODE;


    CURSOR c_invoice_lines(p_xpi_id NUMBER) IS
    SELECT *
    FROM okl_xtl_pay_invs_b
    WHERE xpi_id_details = p_xpi_id;

    cursor c_cnsld_hdr(p_cnsld_ap_inv_id IN NUMBER) IS
    SELECT self_bill_inv_num
    FROM okl_cnsld_ap_invs
    WHERE cnsld_ap_inv_id = p_cnsld_ap_inv_id;

    CURSOR c_taxable_yn(p_tpl_id IN NUMBER) IS
    SELECT taxable_yn
    FROM okl_txl_ap_inv_lns_b
    WHERE id = p_tpl_id;

 -- sjalasut, modified code to refer khr_id from okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b
 -- changes made as part of OKLR12B disbursements project
	CURSOR 	c_num_csr ( p_id NUMBER ) IS
    	 SELECT CHR.CONTRACT_NUMBER
    	 FROM okc_k_headers_b 			 chr
    		 ,okl_txl_ap_inv_lns_all_b 		 tpl
    		 ,okl_xtl_pay_invs_all_b 		 xlp
         WHERE XLP.ID = p_id
    	 AND   XLP.tpl_id 		  = TPL.id
    	 AND   TPL.khr_id 		  = chr.id;


	-- XLP.tpl_id has tap_id
 -- sjalasut, modified code to refer khr_id from okl_txl_ap_inv_lns_all_b instead of okl_trx_ap_invoices_b
 -- changes made as part of OKLR12B disbursements project
/* rkuttiya commented this cursor as no longer  required */
/*	CURSOR 	c_fun_csr ( p_id NUMBER ) IS
    	 SELECT CHR.CONTRACT_NUMBER
    	 FROM okc_k_headers_b 			 chr
    	 	 ,okl_trx_ap_invoices_b 	 tap
        ,okl_txl_ap_inv_lns_all_b tpl
    		 ,okl_xtl_pay_invs_all_b 		 xlp
         WHERE XLP.XPI_ID_DETAILS = p_id
    	 AND XLP.tap_id 		  = TAP.id
      AND tpl.tap_id = tap.id
    	 AND tpl.khr_id 		  = chr.id; */

    CURSOR v_id_csr( p_site_id NUMBER ) IS
        SELECT povs.vendor_id
        FROM po_vendor_sites_all povs
        WHERE povs.vendor_site_id = p_site_id;

--start:| 19-Jun-2007 cklee -- 1. Revert Tax call back                               |
--|                      2. Fixed try_id, kle_id issues                        |

    CURSOR c_try_name(p_tpl_id IN NUMBER) IS
        SELECT try.name try_name,
               tpl.sty_id
        FROM    okl_txl_ap_inv_lns_b tpl
	           , okl_trx_ap_invoices_b tap
    		   , okl_trx_types_v try
        WHERE tpl.id = p_tpl_id
				AND   tpl.tap_id = tap.id
				AND   tap.try_id = try.id;

    CURSOR get_top_line_name ( p_cle_id NUMBER ) IS
      select cle.name
      from OKC_K_LINES_V cle
      where cle.id = p_cle_id;

    CURSOR c_stream_type_purpose (p_sty_id NUMBER ) IS
	select stream_type_purpose
	from OKL_STRM_TYPE_B
	 where id = p_sty_id;

    l_asset_number OKC_K_LINES_V.name%type;
    l_stream_type_purpose OKL_STRM_TYPE_B.stream_type_purpose%type;
    l_sty_id OKL_STRM_TYPE_B.id%type;

--end:| 19-Jun-2007 cklee -- 1. Revert Tax call back                               |
--|                      2. Fixed try_id, kle_id issues                        |

    CURSOR c_top_line(p_tpl_id IN NUMBER) IS
        SELECT NVL(kle.cle_id, kle.id) top_kle_id
        , kle.dnz_chr_id khr_id
--        , try.name try_name -- cklee 06/19/2007
        FROM OKC_K_LINES_B kle
           , okl_txl_ap_inv_lns_b tpl
           , okl_trx_ap_invoices_b tap
           , okl_trx_types_v try
        WHERE tpl.id = p_tpl_id
				AND   tpl.kle_id = kle.id
				AND   tpl.tap_id = tap.id
				AND   tap.try_id = try.id;

/*
    CURSOR Ship_to_csr( p_top_kle_id IN NUMBER ) IS
        SELECT csi.install_location_id
             , csi.location_id
        FROM  csi_item_instances csi,
       	      okc_k_items cim,
       	      okc_k_lines_b   inst,
       	      okc_k_lines_b   ib,
       	      okc_line_styles_b lse
      WHERE  csi.instance_id = TO_NUMBER(cim.object1_id1)
	    AND    cim.cle_id = ib.id
	    AND    ib.cle_id = inst.id
	    AND    inst.lse_id = lse.id
	    AND    lse.lty_code = 'FREE_FORM2'
	    AND    inst.cle_id = p_top_kle_id;
	    */
--start:07-May-2008 cklee -- Fixed bug:7015970
    CURSOR Ship_to_csr( p_top_kle_id IN NUMBER ) IS
        SELECT csi.install_location_id
             , csi.location_id
             , csi.install_location_type_code
--             , csi.location_type_code
        FROM  csi_item_instances csi,
       	      okc_k_items cim,
       	      okc_k_lines_b   inst,
       	      okc_k_lines_b   ib,
       	      okc_line_styles_b lse
      WHERE  csi.instance_id = TO_NUMBER(cim.object1_id1)
	    AND    cim.cle_id = ib.id
	    AND    ib.cle_id = inst.id
	    AND    inst.lse_id = lse.id
	    AND    lse.lty_code = 'FREE_FORM2'
	    AND    inst.cle_id = p_top_kle_id;

	    Cursor location_csr(p_party_site_id IN number) is
	    select hps.location_id
	    from   hz_party_sites hps
	    where  hps.party_site_id = p_party_site_id;

	    --Following Logic Applicable only for after Book:
        --If install_location_type_code = 'HZ_LOCATIONS'
	    --then take the install_location_id from Ship_to_csr
	    --Else If install_location_type_code = 'HZ_PARTY_SITES'
	    --then execute  location_csr  by passing install_location_id
        --as p_party_site_id parameter and take location_id from
        -- location_csr
--end: 07-May-2008 cklee -- Fixed bug:7015970

--
--start:| 06-Jul-2007 cklee -- Fixed ship to issue                                   |
    CURSOR Ship_to_csr_before_booked( p_top_kle_id IN NUMBER ) IS
  select  hps.party_site_id install_location_id,
          hl.location_id
   from   hz_locations       hl,
          hz_party_sites     hps,
          hz_party_site_uses hpsu,
          okl_txl_itm_insts  tii,
          okc_k_lines_b      cleb_ib,
          okc_k_lines_b      cleb_inst,
          okc_line_styles_b  lse1,
          okc_line_styles_b  lse2
  where   hl.location_id     = hps.location_id
  and     hps.party_site_id    = hpsu.party_site_id
  and     hpsu.party_site_use_id  = tii.object_id1_new
  and     tii.jtot_object_code_new = 'OKX_PARTSITE'
  and     tii.kle_id               = cleb_ib.id
  and     cleb_ib.dnz_chr_id       = cleb_inst.dnz_chr_id
  and     cleb_ib.cle_id           = cleb_inst.id
  and     cleb_ib.lse_id           = lse1.id
  and     lse1.lty_code            = 'INST_ITEM'
  and     cleb_inst.cle_id         = p_top_kle_id
  and     cleb_inst.lse_id         = lse2.id
  and     lse2.lty_code            = 'FREE_FORM2';

--end:| 06-Jul-2007 cklee -- Fixed ship to issue                                   |
--

    CURSOR get_khr_id_csr ( p_khr_id VARCHAR2 ) IS
           SELECT cust_acct_id,
		          sts_code --07-May-2008 cklee -- Fixed bug:7015970
           FROM okc_k_headers_b khr
           where khr.id  = p_khr_id;

/*--07-May-2008 cklee -- Fixed bug:7015970
    CURSOR Ship_to_csr2( p_customer_num NUMBER, p_install_location NUMBER, p_location NUMBER) IS
       SELECT a.CUST_ACCT_SITE_ID
       FROM   hz_cust_acct_sites_all a,
              hz_cust_site_uses_all  b,
              hz_party_sites      c
       WHERE  a.CUST_ACCT_SITE_ID = b.CUST_ACCT_SITE_ID AND
              b.site_use_code     = 'SHIP_TO'           AND
              a.party_site_id     = c.party_site_id     AND
              a.cust_account_id   = p_customer_num      AND
              c.party_site_id     = p_install_location  AND
              c.location_id       = p_location;
--07-May-2008 cklee -- Fixed bug:7015970*/


    l_top_kle_id NUMBER;
    l_khr_id NUMBER;
    l_install_location_id NUMBER;
    l_location_id         NUMBER;
    l_install_location_type_code csi_item_instances.install_location_type_code%type; -- 07-May-2008 cklee -- Fixed bug:7015970
    l_customer_id         NUMBER;
    l_sts_code okc_k_headers_all_b.sts_code%type; -- 07-May-2008 cklee -- Fixed bug:7015970
   	l_ship_to		   NUMBER;
   	l_try_name okl_trx_types_v.name%type;

    --Get the inventory for a financial asset line or service line.
    --A line can either be a fin asset or service line
    CURSOR get_inv_item_id ( p_cle_id NUMBER ) IS
        SELECT c.OBJECT1_ID1
        FROM okc_k_lines_b a,
             okc_line_styles_b b,
             okc_k_items c
        WHERE a.cle_id   = p_cle_id
        AND   a.lse_id   = b.id
        AND   b.lty_code = 'ITEM'
        AND   a.id       = c.cle_id
        UNION
        SELECT c.object1_id1
        FROM okc_k_lines_v a,
             okc_line_styles_v b,
             okc_k_items c
        WHERE a.id = p_cle_id
        AND a.lse_id = b.id
        AND b.lty_code = 'SOLD_SERVICE'
        AND c.cle_id = a.id;

   	l_inventory_item_id  NUMBER;
--start:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |
   	lx_tax_det_rec OKL_PROCESS_SALES_TAX_PVT.tax_det_rec_type;
--end:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |
   	l_tax_call_success_flag varchar2(1) := 'Y';
    x_msg_index_out     NUMBER;
BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY(
		p_api_name	=> l_api_name,
    	p_pkg_name	=> g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
/*rkuttiya 02-Feb-2007
    Start Changes*/

--start:| 16-Oct-2007 cklee -- Fixed bug:6502786                                     |
    OPEN c_account_derivation;
    FETCH c_account_derivation INTO
          l_account_derivation,
	      l_PAY_DIST_SET_ID;
	CLOSE c_account_derivation;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Account derivation: ' || l_account_derivation || '. Distribution set id: ' || l_PAY_DIST_SET_ID);
    IF l_account_derivation = 'AMB' THEN
      IF l_PAY_DIST_SET_ID IS NULL THEN
        -- log error message
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Distribution set id is missing, please setup accordingly.');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
--end:| 16-Oct-2007 cklee -- Fixed bug:6502786                                     |

-----------------------------------------------------------------------------
--    Pick up Invoice Headers from the External table
-----------------------------------------------------------------------------
    FOR r_invoice_hdr in c_invoice_hdr LOOP

    	SAVEPOINT C_INVOICE_POINT;

    --Get the Supplier Tax Invoice Number
    	OPEN c_cnsld_hdr(r_invoice_hdr.cnsld_ap_inv_id);
    	FETCH c_cnsld_hdr INTO l_self_bill_invnum;
    	CLOSE c_cnsld_hdr;


    	/*OPEN  v_id_csr( r_invoice_hdr.vendor_site_id );
      FETCH v_id_csr INTO l_vendor_id;
      CLOSE v_id_csr;*/


    BEGIN
   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '==================================================================');
--   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Contract: '||l_contract_number|| 'Vendor Id: ' || r_invoice_hdr.vendor_id); -- removed by 12/04/2007 cklee
   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Vendor Id: ' || r_invoice_hdr.vendor_id);
   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++ Invoice #: '||r_invoice_hdr.INVOICE_NUM||' Vendor Invoice Number: '||r_invoice_hdr.VENDOR_INVOICE_NUMBER);
   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '++++++++++ Invoice Date: '||r_invoice_hdr.INVOICE_DATE||' Invoice Amount: '||r_invoice_hdr.INVOICE_AMOUNT);
   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '==================================================================');

        INSERT INTO AP_INVOICES_INTERFACE(
            Invoice_type_lookup_code
            ,accts_pay_code_combination_id
            ,attribute1
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute_category
            ,created_by
            ,creation_date
            ,description
            ,doc_category_code
            ,gl_date
            ,invoice_amount
            ,invoice_currency_code
            ,exchange_rate
            ,exchange_rate_type
            ,exchange_date
            ,invoice_date
            ,invoice_id
            ,invoice_num
            ,voucher_num
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,org_id
            ,payment_method_lookup_code
--start: 01-May-2007 cklee Fixed the following for R12 Disbursement project         |
            ,payment_method_code
--end: 01-May-2007 cklee Fixed the following for R12 Disbursement project         |
            ,request_id
            ,source
            ,terms_id
            ,vendor_id
            ,vendor_site_id
            ,workflow_flag
            ,PAY_GROUP_LOOKUP_CODE
-- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,legal_entity_id
            ,application_id
            ,product_table
            ,reference_key1
            ,supplier_tax_invoice_number
            ,CALC_TAX_DURING_IMPORT_FLAG
             )
            values(
             r_invoice_hdr.invoice_type
            ,r_invoice_hdr.accts_pay_cc_id
            ,r_invoice_hdr.attribute1
            ,r_invoice_hdr.attribute10
            ,r_invoice_hdr.attribute11
            ,r_invoice_hdr.attribute12
            ,r_invoice_hdr.attribute13
            ,r_invoice_hdr.attribute14
            ,r_invoice_hdr.attribute15
            ,r_invoice_hdr.attribute2
            ,r_invoice_hdr.attribute3
            ,r_invoice_hdr.attribute4
            ,r_invoice_hdr.attribute5
            ,r_invoice_hdr.attribute6
            ,r_invoice_hdr.attribute7
            ,r_invoice_hdr.attribute8
            ,r_invoice_hdr.attribute9
            ,r_invoice_hdr.attribute_category
            ,fnd_global.user_id
            ,sysdate
            ,null
            ,r_invoice_hdr.doc_category_code
            ,r_invoice_hdr.gl_date
            ,r_invoice_hdr.invoice_amount
            ,r_invoice_hdr.invoice_currency_code
            ,r_invoice_hdr.CURRENCY_CONVERSION_RATE
            ,r_invoice_hdr.CURRENCY_CONVERSION_TYPE
            ,r_invoice_hdr.CURRENCY_CONVERSION_DATE
            ,r_invoice_hdr.invoice_date
            ,r_invoice_hdr.invoice_id
            ,r_invoice_hdr.vendor_invoice_number
            ,r_invoice_hdr.invoice_num
            ,fnd_global.user_id
            ,sysdate
            ,fnd_global.login_id
            ,r_invoice_hdr.org_id
            ,r_invoice_hdr.payment_method
--start: 01-May-2007 cklee Fixed the following for R12 Disbursement project         |
            ,r_invoice_hdr.payment_method
--end: 01-May-2007 cklee Fixed the following for R12 Disbursement project         |
            ,fnd_global.conc_request_id
            ,'OKL'
            ,r_invoice_hdr.terms_id
            ,r_invoice_hdr.vendor_id
            ,r_invoice_hdr.vendor_site_id
            ,r_invoice_hdr.workflow_flag
            ,r_invoice_hdr.pay_group_lookup_code
  -- 01-NOV-2006 ANSETHUR  R12B - Legal Entity
            ,r_invoice_hdr.legal_entity_id
            ,fnd_global.prog_appl_id
            ,'OKL_CNSLD_AP_INVS_ALL'
            ,r_invoice_hdr.cnsld_ap_inv_id
            ,l_self_bill_invnum
            ,'Y'
            );

-----------------------------------------------------------------------------
--    Pick up Invoice Lines from the External Lines table
-----------------------------------------------------------------------------

           FOR r_invoice_lines IN c_invoice_lines(r_invoice_hdr.id) LOOP

            --Get the value of the taxable yn column from the lines transaction table
               OPEN c_taxable_yn(r_invoice_lines.tpl_id);
               FETCH c_taxable_yn INTO l_taxable_yn;
               CLOSE c_taxable_yn;

              l_contract_number := null;
				    -- Get the Contract Number
				    	OPEN c_num_csr(r_invoice_lines.id);
				    	FETCH c_num_csr INTO l_contract_number;
				    	CLOSE c_num_csr;

            --Set the value of the amount includes tax flag  based on the taxable yn flag
               IF l_taxable_yn = 'N' THEN
                 l_amount_includes_tax_flag := 'Y';
               ELSE
                 l_amount_includes_tax_flag := 'N';
               END IF;

              l_top_kle_id := null;
					    l_khr_id := null;
					    l_install_location_id := null;
					    l_location_id := null;
					    l_install_location_type_code := null; --cklee 7015970
              l_customer_id := null;
              l_sts_code := null; -- 07-May-2008 cklee -- Fixed bug:7015970
              l_ship_to := null;
              l_inventory_item_id := null;

              OPEN c_top_line(r_invoice_lines.tpl_id);
              FETCH c_top_line INTO l_top_kle_id, l_khr_id;--, l_try_name; cklee 06/20/07
              CLOSE c_top_line;

--start:| 19-Jun-2007 cklee -- 1. Revert Tax call back                               |
--|                      2. Fixed try_id, kle_id issues                        |
              OPEN c_try_name(r_invoice_lines.tpl_id);
              FETCH c_try_name INTO l_try_name, l_sty_id;
              CLOSE c_try_name;

              OPEN get_top_line_name(l_top_kle_id);
              FETCH get_top_line_name INTO l_asset_number;
              CLOSE get_top_line_name;

              OPEN c_stream_type_purpose(l_sty_id);
              FETCH c_stream_type_purpose INTO l_stream_type_purpose;
              CLOSE c_stream_type_purpose;

--end:| 19-Jun-2007 cklee -- 1. Revert Tax call back                               |
--|                      2. Fixed try_id, kle_id issues                        |

              OPEN Ship_to_csr(l_top_kle_id);
              FETCH Ship_to_csr INTO l_install_location_id,
			                         l_location_id,
									 l_install_location_type_code; -- cklee
              CLOSE Ship_to_csr;

--start:| 06-Jul-2007 cklee -- Fixed ship to issue                                   |
              IF l_install_location_id is null and l_location_id is null THEN
                OPEN Ship_to_csr_before_booked(l_top_kle_id);
                FETCH Ship_to_csr_before_booked INTO l_install_location_id, l_location_id;
                CLOSE Ship_to_csr_before_booked;

-- start: 07-May-2008 cklee -- Fixed bug:7015970
                 l_ship_to := l_location_id;

              ELSE -- other than before booked case

        	    --Following Logic Applicable only for after Book:
                --If install_location_type_code = 'HZ_LOCATIONS'
        	    --then take the install_location_id from Ship_to_csr
        	    --Else If install_location_type_code = 'HZ_PARTY_SITES'
         	    --then execute  location_csr  by passing install_location_id
                --as p_party_site_id parameter and take location_id from
                -- location_csr
                IF l_install_location_type_code = 'HZ_LOCATIONS' THEN
                  l_ship_to := l_install_location_id;
                ELSIF l_install_location_type_code = 'HZ_PARTY_SITES' THEN
                  OPEN location_csr(l_install_location_id);
                  FETCH location_csr INTO l_ship_to;
                  CLOSE location_csr;
                ELSE
                  -- error log
                  l_ship_to := null;
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'install_location_type_code is other than HZ_LOCATIONS or HZ_PARTY_SITES');
                END IF;
-- end: 07-May-2008 cklee -- Fixed bug:7015970
              END IF;
--end:| 06-Jul-2007 cklee -- Fixed ship to issue                                   |


              OPEN get_khr_id_csr(l_khr_id);
              FETCH get_khr_id_csr INTO l_customer_id,
			                            l_sts_code; --07-May-2008 cklee -- Fixed bug:7015970
              CLOSE get_khr_id_csr;



-- Note: okl_txl_ap_inv_lns_all_b.kle_id may be null, so the l_ship_to and l_inventory_item_id
-- may also null

/*--07-May-2008 cklee -- Fixed bug:7015970
              OPEN  Ship_to_csr2( l_customer_id, l_install_location_id, l_location_id);
              FETCH Ship_to_csr2 INTO l_ship_to;
              CLOSE Ship_to_csr2;
--07-May-2008 cklee -- Fixed bug:7015970*/

              OPEN get_inv_item_id(l_top_kle_id);
              FETCH get_inv_item_id INTO l_inventory_item_id;
              CLOSE get_inv_item_id;

				   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '--Contract id: ' || l_khr_id || ' Line id: ' || l_top_kle_id);
				   		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '--Install location id: ' || l_install_location_id || ' Location id: ' || l_location_id || ' Ship to id: ' || l_ship_to);
							FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '--Inventory item id: ' || l_inventory_item_id);

    --Call to the Tax API to get the tax determinants.
    -- Trx Business Category, Product Fiscal Classification, Product Type, Ship To Location Id
    -- This code has been commented since this API is not available yet. This will be uncommented once eb Tax impacts are coded.
    -- Please remove these comments then.
              l_tax_call_success_flag := 'Y';
--start:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |

              OKL_PROCESS_SALES_TAX_PVT.get_tax_determinants(p_api_version => p_api_version
							      ,p_init_msg_list  => p_init_msg_list
										,x_return_status => x_return_status
										,x_msg_count => x_msg_count
										,x_msg_data => x_msg_data
										,p_source_trx_id => r_invoice_lines.tpl_id
										,p_source_trx_name => l_try_name
										,p_source_table => 'OKL_TXL_AP_INV_LNS_B'
										,x_tax_det_rec => lx_tax_det_rec);


               IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
							   l_tax_call_success_flag := 'N';
								 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Tax call failed for invoice line id: ' || r_invoice_lines.invoice_line_id || ' of invoice id: ' || r_invoice_hdr.invoice_id);
--start| 20-Sep-2007 cklee -- Fixed error message display issue for tax call        |
                  FOR j in 1..x_msg_count
                    LOOP
                      FND_MSG_PUB.GET(
                       p_msg_index     => j,
                       p_encoded       => FND_API.G_FALSE,
                       p_data          => x_msg_data,
                       p_msg_index_out => x_msg_index_out
                      );

                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Tax call failed:' || to_char(j)||': '||x_msg_data);
                  END LOOP;
--end| 20-Sep-2007 cklee -- Fixed error message display issue for tax call        |

								 --deleting invoice lines
								 DELETE FROM ap_invoice_lines_interface
								 WHERE invoice_id = r_invoice_hdr.invoice_id;

								 --deleting invoice header
								 DELETE FROM AP_INVOICES_INTERFACE
								 WHERE invoice_id = r_invoice_hdr.invoice_id;

								 EXIT;
               END IF;

--end:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |

                INSERT INTO ap_invoice_lines_interface(
                accounting_date
                ,amount
                ,amount_includes_tax_flag
                ,attribute1
                ,attribute10
                ,attribute11
                ,attribute12
                ,attribute13
                ,attribute14
                ,attribute15
                ,attribute2
                ,attribute3
                ,attribute4
                ,attribute5
                ,attribute6
                ,attribute7
                ,attribute8
                ,attribute9
                ,attribute_category
                ,created_by
                ,creation_date
                ,dist_code_combination_id
                ,invoice_id
                ,invoice_line_id
                ,last_updated_by
                ,last_update_date
                ,last_update_login
                ,line_number
                ,line_type_lookup_code
                ,org_id
                ,tax_code
                ,application_id
                ,product_table
                ,reference_key1
                ,description
                ,TAX_CLASSIFICATION_CODE
                ,TRX_BUSINESS_CATEGORY
                ,PRODUCT_CATEGORY
                ,PRODUCT_TYPE
                ,PRIMARY_INTENDED_USE
                ,USER_DEFINED_FISC_CLASS
                ,ASSESSABLE_VALUE
                ,SHIP_TO_LOCATION_ID
                ,INVENTORY_ITEM_ID
                ,DISTRIBUTION_SET_ID--:| 16-Oct-2007 cklee -- Fixed bug:6502786
				)
                values(
                r_invoice_lines.accounting_date
                ,r_invoice_lines.amount
                ,l_amount_includes_tax_flag
                ,r_invoice_lines.attribute1
                ,r_invoice_lines.attribute10
                ,r_invoice_lines.attribute11
                ,r_invoice_lines.attribute12
                ,r_invoice_lines.attribute13
                ,r_invoice_lines.attribute14
                ,r_invoice_lines.attribute15
                ,r_invoice_lines.attribute2
                ,r_invoice_lines.attribute3
                ,r_invoice_lines.attribute4
                ,r_invoice_lines.attribute5
                ,r_invoice_lines.attribute6
                ,r_invoice_lines.attribute7
                ,r_invoice_lines.attribute8
                ,r_invoice_lines.attribute9
                ,r_invoice_lines.attribute_category
                ,fnd_global.user_id
                ,sysdate
--start:| 15-Oct-2007 cklee -- Fixed bug:6502786                                     |
--                ,NVL(r_invoice_lines.dist_code_combination_id, -1) --change for SLA impact
                ,r_invoice_lines.dist_code_combination_id
--end:| 15-Oct-2007 cklee -- Fixed bug:6502786                                     |
                ,r_invoice_hdr.invoice_id
                ,r_invoice_lines.invoice_line_id
                ,fnd_global.user_id
                ,sysdate
                ,fnd_global.login_id
                ,r_invoice_lines.line_number
                ,r_invoice_lines.line_type
                ,r_invoice_lines.org_id
                ,r_invoice_lines.tax_code
                ,fnd_global.prog_appl_id
                ,'OKL_TXL_AP_INV_LNS_ALL_B'
                ,r_invoice_lines.tpl_id
                ,trim(substr(trim(substr(l_contract_number,1,100)) || '/' || trim(substr(l_asset_number,1,100)) || '/' || trim(substr(l_stream_type_purpose,1,38)), 1,240))
--start:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |

                ,lx_tax_det_rec.x_tax_code
                ,lx_tax_det_rec.x_trx_business_category
                ,lx_tax_det_rec.x_product_category
                ,lx_tax_det_rec.x_product_type
                ,lx_tax_det_rec.x_line_intended_use
                ,lx_tax_det_rec.x_user_defined_fisc_class
                ,lx_tax_det_rec.x_assessable_value
/*
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,NULL
                ,NULL
*/
--start:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |
                ,l_ship_to
                ,l_inventory_item_id
                ,l_PAY_DIST_SET_ID --:| 16-Oct-2007 cklee -- Fixed bug:6502786
				);
            -- added 12/04/2007 cklee
     		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing Contract: '||l_contract_number|| '/Asset or Fee: ' ||
		    l_asset_number || '/Stream Type Purpose: ' || l_stream_type_purpose);

            END LOOP;

            IF (l_tax_call_success_flag = 'Y') THEN
	            UPDATE okl_ext_pay_invs_b
	            SET trx_status_code = 'PROCESSED'
	            WHERE CURRENT OF c_invoice_hdr;

--start:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |

	            UPDATE ap_invoices_interface
	            SET TAXATION_COUNTRY = lx_tax_det_rec.X_DEFAULT_TAXATION_COUNTRY
	            WHERE invoice_id = r_invoice_hdr.invoice_id;

--end:| 03-May-2007 cklee -- Commented out OKL_PROCESS_SALES_TAX_PVT related code. |
            END IF;

    EXCEPTION

        WHEN OTHERS THEN
  		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
            ROLLBACK TO C_INVOICE_POINT;
    END;
END LOOP;

EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
  		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
  		FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '*=> ERROR: '||SQLERRM);
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END transfer;

END OKL_PAY_INVOICES_TRANS_PVT;

/
