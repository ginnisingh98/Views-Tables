--------------------------------------------------------
--  DDL for Package Body OKL_UBB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UBB_PVT" AS
/* $Header: OKLRUBBB.pls 120.11 2007/08/13 11:53:57 zrehman noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
  G_DEBUG         NUMBER := 1;
  ubb_failed     EXCEPTION;

-- Start of wraper code generated automatically by Debug code generator

  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

    ------------------------------------------------------------------
  -- Function GET_TRX_TYPE to extract transaction type
  ------------------------------------------------------------------

  FUNCTION get_trx_type
	(p_name		VARCHAR2,
	p_language	VARCHAR2)
	RETURN		NUMBER IS

	CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
		SELECT	id
		FROM	okl_trx_types_tl
		WHERE	name	= cp_name
		AND	LANGUAGE	= cp_language;

	l_trx_type	okl_trx_types_v.id%TYPE;

  BEGIN

	l_trx_type := NULL;

	OPEN	c_trx_type (p_name, p_language);
	FETCH	c_trx_type INTO l_trx_type;
	CLOSE	c_trx_type;

	RETURN	l_trx_type;

  END get_trx_type;

  PROCEDURE calculate_ubb_amount(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
     ) IS

    l_hd_id							NUMBER;
    i                               NUMBER;
    l_found							BOOLEAN;
    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'calculate_ubb_amount';
    l_return_status                 VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_init_msg_list                 VARCHAR2(1) ;
    l_msg_count                     NUMBER ;

    i                               NUMBER := 0;
    l_oks_khr_id                    okc_k_rel_objs.object1_id1%type;
    l_okl_khr_id                    okc_k_rel_objs.chr_id%type;
    l_cle_id                        okc_k_lines_v.cle_id%type;
    l_btn_id                        OKS_BILL_CONT_LINES_V.BTN_ID%type;
    l_date_billed_from              OKS_BILL_CONT_LINES_V.DATE_BILLED_FROM%TYPE;
    l_date_billed_to                OKS_BILL_CONT_LINES_V.DATE_BILLED_TO%TYPE;
    l_amount                        OKS_BILL_CONT_LINES_V.AMOUNT%TYPE;
    l_currency_code                 OKS_BILL_CONT_LINES_V.CURRENCY_CODE%TYPE;
    l_cont_id                       OKS_BILL_CONT_LINES_V.ID%TYPE;
    l_try_id                        okl_trx_types_tl.id%TYPE;
    l_clg_id                        okl_trx_ar_invoices_v.clg_id%TYPE;
    l_sty_id                        okl_strm_type_v.id%TYPE;
    l_first_line	                CONSTANT NUMBER		    := 1;
    l_line_step	                    CONSTANT NUMBER		        := 1;
    l_detail_number	                okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;
    l_fin_asset_id                  NUMBER;
    l_cov_asset_id                  NUMBER;
    l_taiv_rec                      taiv_rec_type;
    lx_taiv_rec                     taiv_rec_type;
    l_tilv_rec                      tilv_rec_type;
    lx_tilv_rec                     tilv_rec_type;
    l_tldv_rec                      tldv_rec_type;
    lx_tldv_rec                     tldv_rec_type;
 	------------------------------------------------------------
	-- Declare variables to call Billing Engine.
	------------------------------------------------------------
    l_tilv_tbl                       okl_til_pvt.tilv_tbl_type;
    l_tldv_tbl                       okl_tld_pvt.tldv_tbl_type;
    x_taiv_rec                       okl_tai_pvt.taiv_rec_type;
    x_tilv_tbl                       okl_til_pvt.tilv_tbl_type;
    x_tldv_tbl                       okl_tld_pvt.tldv_tbl_type;
	------------------------------------------------------------
	-- Declare variables to call Accounting Engine.
	------------------------------------------------------------
	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;
	l_def_desc	CONSTANT VARCHAR2(30)	    := 'OKS Usage';

    line_validation_failed exception;
    l_msg_index_out             NUMBER;


CURSOR l_fin_asset_id_cur(c_khr_id in NUMBER, c_kle_id in NUMBER) IS
select cle_inst.cle_id    financial_asset_id
from
       okc_k_lines_b      cle_inst,
       okc_k_lines_b      cle_ib,
       okc_k_items        cim_ib,
       csi_item_instances cii,
       cs_csi_counter_groups  ccg,
       csi_counters_vl        cc,
       okc_k_items        cim,
       okc_k_lines_b      cleb,
       okc_line_styles_b  lseb,
       okc_k_headers_b    chrb
where  cle_ib.id              = cim_ib.cle_id
and    cle_ib.dnz_chr_id      = cim_ib.dnz_chr_id
--
and    cle_inst.id            = cle_ib.cle_id
and    cle_inst.dnz_chr_id    = cle_ib.dnz_chr_id
--
and    cim_ib.object1_id1     = to_char(cii.instance_id)
and    cim_ib.object1_id2     = '#'
and    cim_ib.jtot_object1_code = 'OKX_IB_ITEM'
--
and    cii.instance_id        = ccg.source_object_id
and    ccg.counter_group_id   = cc.group_id
and    cc.counter_id          = cim.object1_id1
and    cim.object1_id2        = '#'
and    cim.jtot_object1_code  = 'OKX_COUNTER'
and    cim.cle_id             = cleb.id
and    cim.dnz_chr_id         = cleb.dnz_chr_id
and    cleb.dnz_chr_id        = chrb.id
and    lseb.id                = cleb.lse_id
and    lseb.lty_code          = 'INST_CTR'
and    chrb.id                = c_khr_id
and    cleb.id                = c_kle_id;

    CURSOR l_khr_cur IS
            select  distinct rel.object1_id1 oks_khr_id, rel.chr_id okl_khr_id, cov_asset.id cov_asset_id, lns.id cle_id,
                    oks_cont.id oks_line_id, oks_cont.btn_id BTN_ID, oks_cont.amount LINE_AMOUNT,
                    oks_cont.CURRENCY_CODE, oks_cont.CLE_ID OKS_CLE_ID,
                    oks_lns.bcl_id BCL_ID, OKS_LNS.DATE_BILLED_FROM DATE_BILLED_FROM,
                    OKS_LNS.DATE_BILLED_TO DATE_BILLED_TO, CNTR.CLG_ID,
                    OKS_LNS.AMOUNT ASSET_AMOUNT, OKS_LNS.ID OKS_DETAIL_ID,
                    chr.contract_number contract_number
            from    okc_k_rel_objs rel, okc_k_lines_v lns, oks_bill_cont_lines_v oks_cont,
                    OKS_BILL_SUB_LINES_V OKS_LNS, OKC_K_HEADERS_B chr,
                    OKC_K_ITEMS ITEMS, OKL_CNTR_LVLNG_LNS_V CNTR, okc_k_lines_v cov_asset
            where   rel.rty_code = 'OKLUBB'
            and     lns.chr_id = rel.object1_id1
            and     lns.id = cov_asset.cle_id
            and     lns.id = oks_cont.cle_id
            and     OKS_LNS.BCL_ID = oks_cont.ID
            AND     cov_asset.id = oks_lns.cle_id   -- Fix for bug 4659666
			AND		ITEMS.CLE_ID = OKS_LNS.CLE_ID
			AND		ITEMS.OBJECT1_ID1 = CNTR.KLE_ID(+)
            AND     OKS_LNS.amount > 0
            AND     rel.chr_id = chr.id
            AND     OKS_LNS.DATE_BILLED_FROM > (select NVL(max(tai.date_invoiced),add_months(sysdate,-1000))
                                    from okl_trx_ar_invoices_v tai where tai.khr_id = rel.chr_id
                                    and tai.description = 'OKS Usage')
            AND     not exists(select 'x' from okl_trx_ar_invoices_v tai, OKL_CNTR_LVLNG_LNS_V CNTR
                                where tai.khr_id = rel.chr_id
                                and CNTR.clg_id = tai.clg_id);



    CURSOR l_try_id_cur IS
            SELECT ID FROM okl_trx_types_tl WHERE NAME = 'Billing' and LANGUAGE = 'US';
/*
    CURSOR l_sty_id_cur IS
            SELECT ID FROM okl_strm_type_v WHERE NAME = 'USAGE CHARGE';
*/
    BEGIN
      IF (G_DEBUG_ENABLED = 'Y') THEN
        G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
      END IF;

      l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);


      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in Starting Activity => '||l_return_status);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in Starting Activity => '||l_return_status);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
    l_msg_count := x_msg_count ;
    l_msg_data := x_msg_data ;


   FOR l_okl_khr_cur IN l_khr_cur
    LOOP
    BEGIN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing: OKS Contract ID => '||l_okl_khr_cur.oks_khr_id||
					  ' ,OKL Contract ID=> '||l_okl_khr_cur.contract_number
                      ||' ,Contract Line Id=> '||l_okl_khr_cur.cle_id);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Processing: OKS Contract ID => '||l_okl_khr_cur.oks_khr_id||
                       ' ,OKL Contract ID=> '||l_okl_khr_cur.contract_number
                      ||' ,Contract Line Id=> '||l_okl_khr_cur.cle_id);
    END IF;


        l_oks_khr_id                    :=  l_okl_khr_cur.oks_khr_id;
        l_okl_khr_id                    :=  l_okl_khr_cur.okl_khr_id;
        l_cle_id                        :=  l_okl_khr_cur.cle_id;
        l_cov_asset_id                  :=  l_okl_khr_cur.cov_asset_id;

        OPEN l_try_id_cur;
        FETCH l_try_id_cur INTO l_try_id;
        CLOSE l_try_id_cur;

        OPEN l_fin_asset_id_cur(l_oks_khr_id, l_cov_asset_id);
        FETCH l_fin_asset_id_cur INTO l_fin_asset_id;
        CLOSE l_fin_asset_id_cur;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Transaction Type => '||l_try_id);

        l_taiv_rec.trx_status_code              := 'SUBMITTED';
        l_taiv_rec.sfwt_flag                    := 'Y';
        l_taiv_rec.khr_id                       := l_okl_khr_id;
        l_taiv_rec.try_id                       := l_try_id;
      	l_taiv_rec.date_invoiced               	:= l_okl_khr_cur.DATE_BILLED_TO; -- Bug 5077458
        l_taiv_rec.date_entered                 := sysdate;
        l_taiv_rec.amount                       := 0;
        l_taiv_rec.description		            := l_def_desc;
      	l_taiv_rec.CLG_ID                    := l_okl_khr_cur.CLG_ID;

       --20-jun-07 ansethur added for R12B Billing Architecture project
       l_taiv_rec.OKL_SOURCE_BILLING_TRX    := 'UBB';
       --20-jun-07 ansethur added for R12B Billing Architecture project


-- Start of wraper code generated automatically by Debug code generator for Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices
/*  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRUBBB.pls call Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices ');
    END;
  END IF;
        Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices(
                                                        l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_taiv_rec
                                                        ,lx_taiv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRUBBB.pls call Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices

			IF 	(l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ... Internal TXN Header Created.');
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' ... Internal TXN Header Created.');
              END IF;
			END IF;

        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	        RAISE ubb_failed;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in creating Transaction => '||l_msg_data);
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	        RAISE ubb_failed;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in creating Transaction => '||l_msg_data);
        END IF;*/
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside Lines Cursor.');
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Processing: BTN ID => '||l_okl_khr_cur.BTN_ID
                      ||' ,date billed from=> '||l_okl_khr_cur.DATE_BILLED_FROM
                      ||' ,date billed to=> '||l_okl_khr_cur.DATE_BILLED_TO
                      ||' ,Cont ID=> '||l_okl_khr_cur.oks_line_id
                      ||' ,Currency Code=> '||l_okl_khr_cur.CURRENCY_CODE
                      ||' ,Amount=> '||l_okl_khr_cur.LINE_AMOUNT);
    END IF;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Processing: BTN ID => '||l_okl_khr_cur.BTN_ID
                      ||' ,date billed from=> '||l_okl_khr_cur.DATE_BILLED_FROM
                      ||' ,date billed to=> '||l_okl_khr_cur.DATE_BILLED_TO
                      ||' ,Cont ID=> '||l_okl_khr_cur.oks_line_id
                      ||' ,Currency Code=> '||l_okl_khr_cur.CURRENCY_CODE
                      ||' ,Amount=> '||l_okl_khr_cur.LINE_AMOUNT);

        l_btn_id                                :=  l_okl_khr_cur.BTN_ID;
        l_date_billed_from                      :=  l_okl_khr_cur.DATE_BILLED_FROM;
        l_date_billed_to                        :=  l_okl_khr_cur.DATE_BILLED_TO;
        l_amount                                :=  l_okl_khr_cur.LINE_AMOUNT;
        l_currency_code                         :=  l_okl_khr_cur.CURRENCY_CODE;
        l_cont_id                               :=  l_okl_khr_cur.oks_line_id;

        l_tilv_rec.sfwt_flag                    := 'Y';
        l_tilv_rec.amount                       := l_okl_khr_cur.LINE_AMOUNT;
       -- l_tilv_rec.tai_id                       := lx_taiv_rec.id;
        l_tilv_rec.INV_RECEIV_LINE_CODE         := 'LINE';
        l_tilv_rec.LINE_NUMBER                  := 1;
        l_tilv_rec.KLE_ID                       := l_fin_asset_id;
       --20-jun-07 ansethur added for R12B Billing Architecture project
        l_tilv_rec.TXL_AR_LINE_NUMBER           :=1;
       --20-jun-07 ansethur added for R12B Billing Architecture project
/*-- Start of wraper code generated automatically by Debug code generator for okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRUBBB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns ');
    END;
  END IF;
        okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns(
                                                        l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_tilv_rec
                                                        ,lx_tilv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRUBBB.pls call okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns

			IF 	(l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ... Internal TXN Lines Created.');
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' ... Internal TXN Lines Created.');
              END IF;
			END IF;

        IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in creating Transaction Lines => '||l_msg_data);
	        RAISE ubb_failed;
        ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in creating Transaction Lines=> '||l_msg_data);
	        RAISE ubb_failed;
        END IF;*/

        Okl_Streams_Util.get_primary_stream_type(
		               p_khr_id => l_okl_khr_id,
		               p_primary_sty_purpose => 'USAGE_PAYMENT',
		               x_return_status => l_return_status,
		               x_primary_sty_id => l_sty_id );

        IF 	(l_return_status = 'S' ) THEN
         	FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream Id for purpose USAGE_PAYMENT retrieved.');
       	ELSE
         	FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Could not retrieve Stream Id for purpose USAGE_PAYMENT.');
      	END IF;

      	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        	RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        	RAISE Okl_Api.G_EXCEPTION_ERROR;
      	END IF;

/*
        OPEN l_sty_id_cur;
        FETCH l_sty_id_cur INTO l_sty_id;
        CLOSE l_sty_id_cur;
*/
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Type => '||l_sty_id);

         l_detail_number := l_first_line;

         l_tldv_rec.sty_id                       := l_sty_id;
         l_tldv_rec.sfwt_flag                    := 'Y';
         l_tldv_rec.amount                       := l_okl_khr_cur.ASSET_AMOUNT;
        -- l_tldv_rec.til_id_details               := lx_tilv_rec.id;
         l_tldv_rec.BSL_ID                       := l_okl_khr_cur.OKS_DETAIL_ID;
         l_tldv_rec.BCL_ID                       := l_cont_id;
         l_tldv_rec.line_detail_number           := l_detail_number;
       --20-jun-07 ansethur added for R12B Billing Architecture project
         l_tldv_rec.TXL_AR_LINE_NUMBER           := 1;
       --20-jun-07 ansethur added for R12B Billing Architecture project
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Line Detail Number => '||l_tldv_rec.line_detail_number);

/*-- Start of wraper code generated automatically by Debug code generator for Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRUBBB.pls call Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls ');
    END;
  END IF;
        	Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls(
                                                        l_api_version
                                                        ,l_init_msg_list
                                                        ,l_return_status
                                                        ,l_msg_count
                                                        ,l_msg_data
                                                        ,l_tldv_rec
                                                        ,lx_tldv_rec);
			l_detail_number	:= l_detail_number + l_line_step;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRUBBB.pls call Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls

			IF 	(l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ... Details Created.');
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' ... Details Created.');
              END IF;
			END IF;*/
  ---------------------------------------------------------------------------
  -- Call to Billing Centralized API
  ---------------------------------------------------------------------------
  		--Initialize The Table
        l_tilv_tbl(1) := l_tilv_rec;
        l_tldv_tbl(1) := l_tldv_rec;
	 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'++Begin : Call to Billing Centralized API');
         END IF;
		okl_internal_billing_pvt.create_billing_trx(p_api_version,
							    p_init_msg_list,
							    x_return_status,
							    x_msg_count,
							    x_msg_data,
							    l_taiv_rec,
							    l_tilv_tbl,
							    l_tldv_tbl,
							    x_taiv_rec,
							    x_tilv_tbl,
							    x_tldv_tbl);
         IF x_return_status <> 'S' THEN
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                           OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' -- ERROR: Creating Billing Transactions using Billing Engine');
                  END IF;
                 IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	         ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		    RAISE Okl_Api.G_EXCEPTION_ERROR;
	         END IF;
	 END IF;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'--End : Call to Billing Centralized API');
         END IF;

	--	p_bpd_acc_rec.id 		   := lx_tldv_rec.id;
	--	p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';
	/*	----------------------------------------------------
		-- Create Accounting Distributions
		----------------------------------------------------
-- Start of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRUBBB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' ... Acc Call Initiated.');
              END IF;
		Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
     			p_api_version
    		   ,p_init_msg_list
    		   ,x_return_status
    		   ,x_msg_count
    		   ,x_msg_data
  			   ,p_bpd_acc_rec
		);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRUBBB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS

			IF 	(x_return_status = 'S' ) THEN
                commit;
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' ... ACCOUNTING Created.');
            ELSE
               IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,' ... Accounting Failed.');
               END IF;
			END IF;
    FOR i in 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => l_msg_index_out
                     );
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||to_char(i)||': '||x_msg_data);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Message Index: '||l_msg_index_out);
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error '||to_char(i)||': '||x_msg_data);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Message Index: '||l_msg_index_out);
      END IF;
    END LOOP;

		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in Accounting => '||x_msg_data);
	        RAISE ubb_failed;
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error in Accounting => '||x_msg_data);
	        RAISE ubb_failed;
		END IF;*/
  EXCEPTION
    WHEN ubb_failed THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error In UBB, Processing Next Record  ');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Rolling Back Transaction');
        ROLLBACK;
--     	DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || '_PVT');
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error '||x_msg_data);
    END;

    END LOOP;
      OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END calculate_ubb_amount;

  PROCEDURE billing_status(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_bill_stat_tbl                OUT NOCOPY bill_stat_tbl_type
    ,p_khr_id                       IN  NUMBER
    ,p_transaction_date             IN  DATE
     ) IS

CURSOR c_last_bill_date(c_khr_id in NUMBER, c_transaction_date in DATE) IS
select max(AR.DUE_DATE) last_bill_date, tai.description transaction_type
from    okl_cnsld_ar_strms_b cnsld,
        AR_PAYMENT_SCHEDULES_ALL AR,
        OKL_XTL_SELL_INVS_V XTL,
        okl_trx_ar_invoices_v tai,
        okl_txl_ar_inv_lns_v til,
        okl_txd_ar_ln_dtls_v tld
where   cnsld.receivables_invoice_id    = AR.customer_trx_id
and     cnsld.khr_id                    = c_khr_id
and     cnsld.id                        = XTL.lsm_id
and     xtl.tld_id                     = tld.id
and     til.tai_id                      = tai.id
and     til.id                          = tld.til_id_details
and     tai.description                 in ('Regular Stream Billing')
and     cnsld.sel_id                    in (SELECT SEL.id
                                        FROM    OKL_STREAMS_V STM,
                                                OKL_STRM_ELEMENTS_V SEL,
                                                OKC_K_HEADERS_V KHR,
                                                OKL_STRM_TYPE_V STY
                                        WHERE  KHR.id                           = c_khr_id
                                        AND    SEL.stream_element_date          <= c_transaction_date
                                        AND    KHR.id                           = STM.khr_id
                                        AND    STM.id                           = SEL.stm_id
                                        AND    STM.say_code                     = 'CURR'
                                        AND    STM.active_yn                    = 'Y'
                                        AND    STM.sty_id                       = STY.id
                                        AND    NVL(STY.billable_yn,'N')         = 'Y'
                                        AND    STY.stream_type_purpose          = 'RENT'
                                        AND    SEL.amount                       > 0)
group by tai.description;

/*
CURSOR c_last_sch_bill_date(c_khr_id in NUMBER, c_transaction_date DATE) IS
SELECT max(SEL.stream_element_date) last_sche_bill_date, sel.id
FROM   OKL_STREAMS_V STM,
       OKL_STRM_ELEMENTS_V SEL,
       OKC_K_HEADERS_V KHR,
       OKL_STRM_TYPE_B STY
WHERE  KHR.id                           = c_khr_id
AND    SEL.stream_element_date          <= c_transaction_date
AND    KHR.id                           = STM.khr_id
AND    STM.id                           = SEL.stm_id
AND    STM.say_code                     = 'CURR'
AND    STM.active_yn                    = 'Y'
AND    SEL.date_billed                  IS NULL
AND    STM.sty_id                       = STY.id
AND    NVL(STY.billable_yn,'N')         = 'Y'
AND    SEL.amount                       > 0
AND    ROWNUM                           < 2;
*/

CURSOR c_last_sch_bill_date(c_khr_id in NUMBER, c_transaction_date DATE) IS
SELECT  sel.id stream_id,
        sel.stream_element_date last_sche_bill_date
FROM   OKL_STREAMS_V STM,
       OKL_STRM_ELEMENTS_V SEL,
       OKL_STRM_TYPE_V STY
WHERE  sel.stream_element_date = (SELECT max(SEL.stream_element_date) last_sche_bill_date
FROM   OKL_STREAMS_V STM,
       OKL_STRM_ELEMENTS_V SEL,
       OKC_K_HEADERS_V KHR,
       OKL_STRM_TYPE_V STY
WHERE  KHR.id                           = c_khr_id
AND    SEL.stream_element_date          <= c_transaction_date
AND    KHR.id                           = STM.khr_id
AND    STM.id                           = SEL.stm_id
AND    STM.say_code                     = 'CURR'
AND    STM.active_yn                    = 'Y'
AND    STM.sty_id                       = STY.id
AND    NVL(STY.billable_yn,'N')         = 'Y'
AND    STY.stream_type_purpose          = 'RENT'
AND    SEL.amount                       > 0)
AND    STM.id                           = SEL.stm_id
AND    STM.sty_id                       = STY.id
AND    STY.stream_type_purpose          = 'RENT'
AND     STM.khr_id                      = c_khr_id
AND    STM.say_code                     = 'CURR'
AND    STM.active_yn                    = 'Y'
AND    NVL(STY.billable_yn,'N')         = 'Y'
AND  ROWNUM < 2;


CURSOR c_oks_last_sch_bill_date_10(c_khr_id in NUMBER, c_transaction_date DATE) IS
select  max(schd.date_to_interface) last_sche_bill_date
from    okc_k_rel_objs rel,
        okc_k_headers_b hdr,
        okc_k_headers_b oks,
        okc_k_lines_b oks_line,
        OKS_LEVEL_ELEMENTS_V schd, OKS_STREAM_LEVELS_B strm
where 	hdr.id                          = c_khr_id
and     rty_code                        = 'OKLSRV'
and		rel.jtot_object1_code           = 'OKL_SERVICE'
and     rel.cle_id                      is null
and		rel.chr_id                      = hdr.id
and     rel.object1_id1                 = to_char(oks.id)
and     oks.id                          = oks_line.dnz_chr_id
and     oks_line.lse_id                 in (7,8,9,10,11,35)
and     oks_line.id                     = strm.cle_id
and     strm.id                         = schd.rul_id
and     schd.date_to_interface          <= c_transaction_date;

CURSOR c_oks_last_sch_bill_date_9(c_khr_id in NUMBER, c_transaction_date DATE) IS
select  max(schd.date_to_interface) last_sche_bill_date
from    okc_k_rel_objs rel,
        okc_k_headers_b hdr,
        okc_k_headers_b oks,
        okc_k_lines_b oks_line,
        OKS_LEVEL_ELEMENTS_V schd,
        okc_rules_b rules,
        okc_rule_groups_b rgp
where 	hdr.id                          = c_khr_id
and     rty_code                        = 'OKLSRV'
and		rel.jtot_object1_code           = 'OKL_SERVICE'
and     rel.cle_id                      is null
and		rel.chr_id                      = hdr.id
and     rel.object1_id1                 = to_char(oks.id)
and     oks.id                          = oks_line.dnz_chr_id
and     oks_line.lse_id                 in (7,8,9,10,11,35)
and     oks_line.id                     = rgp.cle_id
and     rules.rgp_id                    = rgp.id
and     rules.id                        = schd.rul_id
and     rules.rule_information_category = 'SLL'
and     schd.date_to_interface          <= c_transaction_date;


CURSOR check_oks_ver IS
   SELECT 1
   FROM   okc_class_operations
   WHERE  cls_code = 'SERVICE'
   AND    opn_code = 'CHECK_RULE';

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'billing_status';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stream_id                           NUMBER;

--     l_khr_id                           NUMBER;
     i                                  NUMBER;
     l_bill_stat_rec                    bill_stat_rec_type;
     l_bill_stat_tbl                    bill_stat_tbl_type;
     l_oks_ver                          VARCHAR2(10);
     BEGIN

      l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);


      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

--     select id into l_khr_id from okc_k_headers_b where contract_number = p_contract_number;

           i := 0;

   FOR l_last_sch_bill_date IN c_last_sch_bill_date(p_khr_id, p_transaction_date)
    LOOP
        l_bill_stat_rec.last_schedule_bill_date := l_last_sch_bill_date.last_sche_bill_date;
        l_stream_id := l_last_sch_bill_date.stream_id;
        l_bill_stat_rec.transaction_type := 'RENTAL';
--        dbms_output.put_line('Stream :'||l_stream_id);
--        dbms_output.put_line('last_schedule_bill_date :'||l_bill_stat_rec.last_schedule_bill_date);

    FOR l_last_bill_date IN c_last_bill_date(p_khr_id, p_transaction_date)
        LOOP

            l_bill_stat_rec.last_bill_date := l_last_bill_date.last_bill_date;
--            l_bill_stat_rec.transaction_type := l_last_bill_date.transaction_type;
--        dbms_output.put_line('last_bill_date :'||l_bill_stat_rec.last_bill_date);

        END LOOP;

        l_bill_stat_tbl(i) := l_bill_stat_rec;

        i := i + 1;
    END LOOP;


         l_oks_ver := '?';
         OPEN check_oks_ver;
         FETCH check_oks_ver INTO l_oks_ver;

         IF check_oks_ver%NOTFOUND THEN
            l_oks_ver := '9';
         ELSE
            l_oks_ver := '10';
         END IF;

         CLOSE check_oks_ver;


   IF (l_oks_ver = '10') THEN
   FOR l_oks_last_sch_bill_date IN c_oks_last_sch_bill_date_10(p_khr_id, p_transaction_date)
    LOOP
        l_bill_stat_rec.last_schedule_bill_date := l_oks_last_sch_bill_date.last_sche_bill_date;
--        l_stream_id := l_last_sch_bill_date.stream_id;
        l_bill_stat_rec.transaction_type := 'RENTAL';
--        dbms_output.put_line('Stream :'||l_stream_id);
--        dbms_output.put_line('last_schedule_bill_date :'||l_bill_stat_rec.last_schedule_bill_date);

    FOR l_last_bill_date IN c_last_bill_date(p_khr_id, p_transaction_date)
        LOOP

            l_bill_stat_rec.last_bill_date := l_last_bill_date.last_bill_date;
--            l_bill_stat_rec.transaction_type := l_last_bill_date.transaction_type;
--        dbms_output.put_line('last_bill_date :'||l_bill_stat_rec.last_bill_date);

        END LOOP;

        l_bill_stat_tbl(i) := l_bill_stat_rec;

        i := i + 1;
    END LOOP;
   ELSE -- oks_ver = 9
   FOR l_oks_last_sch_bill_date IN c_oks_last_sch_bill_date_9(p_khr_id, p_transaction_date)
    LOOP
        l_bill_stat_rec.last_schedule_bill_date := l_oks_last_sch_bill_date.last_sche_bill_date;
--        l_stream_id := l_last_sch_bill_date.stream_id;
        l_bill_stat_rec.transaction_type := 'RENTAL';
--        dbms_output.put_line('Stream :'||l_stream_id);
--        dbms_output.put_line('last_schedule_bill_date :'||l_bill_stat_rec.last_schedule_bill_date);

    FOR l_last_bill_date IN c_last_bill_date(p_khr_id, p_transaction_date)
        LOOP

            l_bill_stat_rec.last_bill_date := l_last_bill_date.last_bill_date;
--            l_bill_stat_rec.transaction_type := l_last_bill_date.transaction_type;
--        dbms_output.put_line('last_bill_date :'||l_bill_stat_rec.last_bill_date);

        END LOOP;

        l_bill_stat_tbl(i) := l_bill_stat_rec;

        i := i + 1;
    END LOOP;
    END IF;

    x_bill_stat_tbl := l_bill_stat_tbl;
	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END billing_status;

PROCEDURE bill_service_contract(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_contract_number              IN  VARCHAR2
     ) IS


	------------------------------------------------------------
	-- Initialise constants
	------------------------------------------------------------

	l_def_desc	CONSTANT VARCHAR2(30)	    := 'OKS Billing';
	l_line_code	CONSTANT VARCHAR2(30)	    := 'LINE';
--	l_init_status	CONSTANT VARCHAR2(30)	:= 'ENTERED';
	l_final_status	CONSTANT VARCHAR2(30)	:= 'SUBMITTED';
	l_trx_type_name	CONSTANT VARCHAR2(30)	:= 'Billing';
	l_trx_type_lang	CONSTANT VARCHAR2(30)	:= 'US';
	l_date_entered	CONSTANT DATE		    := SYSDATE;
	l_zero_amount	CONSTANT NUMBER		    := 0;
	l_first_line	CONSTANT NUMBER		    := 1;
	l_line_step	CONSTANT NUMBER		        := 1;
	l_def_no_val	CONSTANT NUMBER		    := -1;
	l_null_kle_id	CONSTANT NUMBER		    := -2;
    l_sty_id                        okl_strm_type_v.id%TYPE;

	------------------------------------------------------------
	-- Declare records: i - insert, u - update, r - result
	------------------------------------------------------------

	-- Transaction headers
	i_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
	u_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
	r_taiv_rec	Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;

	-- Transaction lines
	i_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
	u_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
	r_tilv_rec	Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;

	-- Transaction line details
	i_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
	u_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
    l_init_tldv_rec     Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;
	r_tldv_rec	        Okl_Txd_Ar_Ln_Dtls_Pub.tldv_rec_type;

	-- Stream elements
	u_selv_rec	        Okl_Streams_Pub.selv_rec_type;
	l_init_selv_rec	    Okl_Streams_Pub.selv_rec_type;
	r_selv_rec	        Okl_Streams_Pub.selv_rec_type;

	------------------------------------------------------------
	-- Declare local variables used in the program
	------------------------------------------------------------

	l_khr_id	okl_trx_ar_invoices_v.khr_id%TYPE;
	l_bill_date	okl_trx_ar_invoices_v.date_invoiced%TYPE;
	l_trx_type	okl_trx_ar_invoices_v.try_id%TYPE;
	l_kle_id	okl_txl_ar_inv_lns_v.kle_id%TYPE;

    l_curr_code     okc_k_headers_b.currency_code%TYPE;
    l_ste_amount    okl_strm_elements.amount%type;


	l_line_number	okl_txl_ar_inv_lns_v.line_number%TYPE;
	l_detail_number	okl_txd_ar_ln_dtls_v.line_detail_number%TYPE;

	l_header_amount	okl_trx_ar_invoices_v.amount%TYPE;
	l_line_amount	okl_txl_ar_inv_lns_v.amount%TYPE;

	l_header_id	okl_trx_ar_invoices_v.id%TYPE;
	l_line_id	okl_txl_ar_inv_lns_v.id%TYPE;

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'bill_service_contract';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

	------------------------------------------------------------
	-- Declare variables to call Accounting Engine.
	------------------------------------------------------------
	p_bpd_acc_rec					Okl_Acc_Call_Pub.bpd_acc_rec_type;


	------------------------------------------------------------
	-- Variables for Error Processing and Committing Stream Billing
    -- Transactions
	------------------------------------------------------------

    l_error_status               VARCHAR2(1);
    l_error_message              VARCHAR2(2000);


	------------------------------------------------------------
	-- Extract all OKS Covered Product Lines to be billed
	------------------------------------------------------------

CURSOR c_oks_bill(c_contract_number in VARCHAR2) IS
select  chr.contract_number contract_number, hdr.id khr_id, lns.id kle_id,
        rel.object1_id1 oks_line_id, OKS_LNS.DATE_BILLED_FROM DATE_BILLED_FROM,
        OKS_LNS.DATE_BILLED_TO DATE_BILLED_TO, OKS_LNS.AMOUNT asset_amount,
        OKS_CONT.AMOUNT line_amount, OKS_CONT.CURRENCY_CODE CURRENCY_CODE,
		okll.sty_id sty_id
from    okc_k_rel_objs rel, okl_k_headers hdr, okc_k_headers_b chr, okc_k_lines_b lns,
		okc_line_styles_b lse, okc_k_lines_b lnsb, OKS_BILL_CONT_LINES_V OKS_CONT,
		OKS_BILL_SUB_LINES_V OKS_LNS, okl_k_lines okll
where 	rty_code = 'OKLSRV'
and		rel.jtot_object1_code = 'OKL_COV_PROD'
and		rel.chr_id = hdr.id
and 	hdr.id = chr.id
and		chr.contract_number = NVL(c_contract_number,chr.contract_number)
and		lse.lty_code = 'SOLD_SERVICE'
and 	lns.lse_id = lse.id
and		lns.id = lnsb.cle_id
and     rel.cle_id = lnsb.id
and     lns.id = okll.id
and 	OKS_LNS.CLE_ID = rel.object1_id1
and		OKS_CONT.ID = OKS_LNS.BCL_ID
--and     OKS_LNS.DATE_BILLED_TO <= sysdate
and     OKS_LNS.DATE_BILLED_FROM > (select NVL(max(tai.date_invoiced),add_months(sysdate,-1000))
                                    from okl_trx_ar_invoices_v tai where tai.khr_id = hdr.id
                                    and tai.description = 'OKS Billing')
order by chr.contract_number, OKS_LNS.date_billed_from, lns.id;
/*
CURSOR l_sty_id_cur IS
SELECT ID FROM okl_strm_type_v WHERE NAME = 'SERVICE FEE';
*/
    BEGIN
      IF (G_DEBUG_ENABLED = 'Y') THEN
        G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
      END IF;
	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.LOG, '=========================================================================================');
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

	------------------------------------------------------------
	-- Initialise local variables
	------------------------------------------------------------

	l_khr_id	:= l_def_no_val;
	l_kle_id	:= l_def_no_val;
	l_trx_type	:= get_trx_type (l_trx_type_name, l_trx_type_lang);

	------------------------------------------------------------
	-- Process every COVERED ASSET LINE to be billed
	------------------------------------------------------------

    FND_FILE.PUT_LINE (FND_FILE.LOG, '=========================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '             ** Start Processing. Please See Error Log for any errored transactions **   ');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '=========================================================================================');


   FOR l_oks_bill_rec IN c_oks_bill(p_contract_number)
    LOOP

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '       Processing: Contract Number=> '||l_oks_bill_rec.contract_number
					  ||' ,for date=> '||l_oks_bill_rec.DATE_BILLED_FROM||' and Amount=> '||l_ste_amount);
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract Number'||l_oks_bill_rec.contract_number);
    END IF;

        l_ste_amount := l_oks_bill_rec.asset_amount;

        FND_FILE.PUT_LINE (FND_FILE.LOG, '===============================================================================');
        FND_FILE.PUT_LINE (FND_FILE.LOG, '       Processing: Contract Number=> '||l_oks_bill_rec.contract_number
					  ||' ,for date=> '||l_oks_bill_rec.DATE_BILLED_FROM||' and Amount=> '||l_ste_amount);

		----------------------------------------------------
		-- Create new transaction header for every
		-- contract and bill_date combination
		----------------------------------------------------

    IF l_khr_id	<> l_oks_bill_rec.khr_id
    OR l_bill_date	<> l_oks_bill_rec.DATE_BILLED_FROM THEN

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract ID '||l_oks_bill_rec.khr_id||'Date Billed '||l_oks_bill_rec.DATE_BILLED_FROM);
    END IF;
			---------------------------------------------
			-- Save previous header amount except first record
			---------------------------------------------
			IF l_khr_id <> l_def_no_val THEN


				u_taiv_rec.id			:= l_header_id;
				u_taiv_rec.amount		:= l_header_amount;

				Okl_Trx_Ar_Invoices_Pub.update_trx_ar_invoices
					(p_api_version
					,p_init_msg_list
					,l_return_status
					,x_msg_count
					,x_msg_data
					,u_taiv_rec
					,r_taiv_rec);

				IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
					RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
					RAISE Okl_Api.G_EXCEPTION_ERROR;
				END IF;

			END IF;


			---------------------------------------------
			-- Populate required columns
			---------------------------------------------
			i_taiv_rec.khr_id		    := l_oks_bill_rec.khr_id;
			i_taiv_rec.date_invoiced	:= l_oks_bill_rec.DATE_BILLED_FROM;
			i_taiv_rec.try_id		    := l_trx_type;
			i_taiv_rec.date_entered		:= l_date_entered;
			i_taiv_rec.description		:= l_def_desc;
			i_taiv_rec.trx_status_code	:= l_final_status;
			i_taiv_rec.amount		    := l_zero_amount;

			---------------------------------------------
			-- Columns to be populated later based on CONTRACT_ID
			---------------------------------------------
			i_taiv_rec.currency_code	:= NULL;
			i_taiv_rec.set_of_books_id	:= NULL;
			i_taiv_rec.ibt_id		:= NULL;
			i_taiv_rec.ixx_id		:= NULL;
			i_taiv_rec.irm_id		:= NULL;
			i_taiv_rec.irt_id		:= NULL;
			i_taiv_rec.org_id		:= NULL;


			---------------------------------------------
			-- Insert transaction header record
			---------------------------------------------
			Okl_Trx_Ar_Invoices_Pub.insert_trx_ar_invoices
				(p_api_version
				,p_init_msg_list
				,l_return_status
				,x_msg_count
				,x_msg_data
				,i_taiv_rec
				,r_taiv_rec);

			IF 	(l_return_status = 'S' ) THEN
              				FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Internal TXN Header Created.');
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  				OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Internal TXN Header Created.');
                  END IF;
            			ELSE
              				FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Internal TXN Header.');
			END IF;

			IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
				RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
				RAISE Okl_Api.G_EXCEPTION_ERROR;
			END IF;

			---------------------------------------------
			-- Adjust header variables
			---------------------------------------------
			l_line_number	:= l_first_line;
			l_header_amount	:= l_zero_amount;
			l_header_id	    := r_taiv_rec.id;

		END IF;


		----------------------------------------------------
		-- Create new transaction line for every
		-- contract line and bill_date combination
		----------------------------------------------------

		IF l_kle_id	<> NVL (l_oks_bill_rec.kle_id, l_null_kle_id)
		OR l_bill_date	<> l_oks_bill_rec.DATE_BILLED_FROM THEN

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '       Processing: Contract LINE=> '||l_oks_bill_rec.kle_id);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract Line'||l_oks_bill_rec.kle_id);
  END IF;
			---------------------------------------------
			-- Save previous line amount except first record
			---------------------------------------------
			IF l_kle_id <> l_def_no_val THEN

				u_tilv_rec.id		:= l_line_id;
				u_tilv_rec.amount	:= l_line_amount;

				Okl_Txl_Ar_Inv_Lns_Pub.update_txl_ar_inv_lns
					(p_api_version
					,p_init_msg_list
					,l_return_status
					,x_msg_count
					,x_msg_data
					,u_tilv_rec
					,r_tilv_rec);

				IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
					RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
				ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
					RAISE Okl_Api.G_EXCEPTION_ERROR;
				END IF;

			END IF;

			---------------------------------------------
			-- Populate required columns
			---------------------------------------------
			i_tilv_rec.kle_id		            := l_oks_bill_rec.kle_id;
			i_tilv_rec.line_number		        := l_line_number;
			i_tilv_rec.tai_id		            := l_header_id;
			i_tilv_rec.description		        := l_def_desc;
			i_tilv_rec.inv_receiv_line_code	    := l_line_code;
			i_tilv_rec.amount		            := l_zero_amount;
			i_tilv_rec.date_bill_period_end	    := l_oks_bill_rec.DATE_BILLED_TO;
			i_tilv_rec.date_bill_period_start   := l_oks_bill_rec.DATE_BILLED_FROM;

			---------------------------------------------
			-- Columns which are not used by stream billing
			---------------------------------------------
			i_tilv_rec.til_id_reverses	:= NULL;
			i_tilv_rec.tpl_id		    := NULL;
			i_tilv_rec.acn_id_cost		:= NULL;
			i_tilv_rec.sty_id		    := NULL;
			i_tilv_rec.quantity		    := NULL;
			i_tilv_rec.amount_applied	:= NULL;
			i_tilv_rec.org_id		    := NULL;
			i_tilv_rec.receivables_invoice_id := NULL;

			---------------------------------------------
			-- Insert transaction line record
			---------------------------------------------
			Okl_Txl_Ar_Inv_Lns_Pub.insert_txl_ar_inv_lns
				(p_api_version
				,p_init_msg_list
				,l_return_status
				,x_msg_count
				,x_msg_data
				,i_tilv_rec
				,r_tilv_rec);

			IF 	(l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Internal TXN Line Created.');
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Internal TXN Line Created.');
       END IF;
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.LOG, '        -- ERROR: Creating Internal TXN Line.');
			END IF;


			IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
				RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
				RAISE Okl_Api.G_EXCEPTION_ERROR;
			END IF;

			---------------------------------------------
			-- Adjust line variables
			---------------------------------------------
			l_detail_number	:= l_first_line;
			l_line_amount	:= l_zero_amount;
			l_line_id	    := r_tilv_rec.id;
			l_line_number	:= l_line_number + l_line_step;

		END IF;

		----------------------------------------------------
		-- Create new transaction line detail for every stream
		----------------------------------------------------

		----------------------------------------------------
		-- Populate required columns
		----------------------------------------------------
/*
        OPEN l_sty_id_cur;
        FETCH l_sty_id_cur INTO l_sty_id;
        CLOSE l_sty_id_cur;
*/

        l_sty_id := l_oks_bill_rec.sty_id;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Stream Type => '||l_sty_id);

		i_tldv_rec.sty_id                   := l_sty_id;
		i_tldv_rec.amount			        := l_oks_bill_rec.asset_amount;
/*  Find the values of these
		i_tldv_rec.description		        := c_streams_rec.comments;
		i_tldv_rec.sel_id			        := c_streams_rec.sel_id;
  Find the values of these */
		i_tldv_rec.til_id_details	        := l_line_id;
		i_tldv_rec.line_detail_number		:= l_detail_number;

		----------------------------------------------------
		-- Columns which are not used by stream billing
		----------------------------------------------------
		i_tldv_rec.tld_id_reverses		:= NULL;
		i_tldv_rec.idx_id			    := NULL;
		i_tldv_rec.late_charge_yn		:= NULL;
		i_tldv_rec.date_calculation		:= NULL;
		i_tldv_rec.fixed_rate_yn		:= NULL;
		i_tldv_rec.receivables_invoice_id	:= NULL;
		i_tldv_rec.amount_applied		:= NULL;
		i_tldv_rec.bch_id			:= NULL;
		i_tldv_rec.bgh_id			:= NULL;
		i_tldv_rec.bcl_id			:= NULL;
		i_tldv_rec.bsl_id			:= NULL;
		i_tldv_rec.org_id			:= NULL;



    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Amount'||i_tldv_rec.amount);
    END IF;
		----------------------------------------------------
		-- Insert transaction line detail record
		----------------------------------------------------
		Okl_Txd_Ar_Ln_Dtls_Pub.insert_txd_ar_ln_dtls
			(p_api_version
			,p_init_msg_list
			,l_return_status
			,x_msg_count
			,x_msg_data
			,i_tldv_rec
			,r_tldv_rec);

   			IF 	(l_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Internal TXN Details Created.');
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Internal TXN details Created.');
       END IF;
            ELSE
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Internal TXN Details.');
			END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Internal TXN details Created.');
       END IF;

		    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			    RAISE Okl_Api.G_EXCEPTION_ERROR;
		    END IF;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Internal TXN details Created.');
       END IF;

		p_bpd_acc_rec.id 		   := r_tldv_rec.id;
		p_bpd_acc_rec.source_table := 'OKL_TXD_AR_LN_DTLS_B';
		----------------------------------------------------
		-- Create Accounting Distributions
		----------------------------------------------------
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- In Accounting Distributions '||p_bpd_acc_rec.id);
       END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRUBBB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
		Okl_Acc_Call_Pub.CREATE_ACC_TRANS(
     			p_api_version
    		   ,p_init_msg_list
    		   ,x_return_status
    		   ,x_msg_count
    		   ,x_msg_data
  			   ,p_bpd_acc_rec
		);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRUBBB.pls call Okl_Acc_Call_Pub.CREATE_ACC_TRANS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Acc_Call_Pub.CREATE_ACC_TRANS

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Accounting Distributions Created.');
       END IF;
   		IF 	(x_return_status = 'S' ) THEN
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Accounting Distributions Created.');
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Accounting Distributions Created.');
       END IF;
        ELSE
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'        -- Accounting Distributions Errored.');
       		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error Message'||x_msg_data);
       END IF;
              FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Accounting Distributions NOT Created.');
		END IF;


		IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_ERROR;
		END IF;

		----------------------------------------------------
		-- Adjust line variables
		----------------------------------------------------

		l_khr_id 	    := l_oks_bill_rec.khr_id;
		l_bill_date	    := l_oks_bill_rec.DATE_BILLED_FROM;
		l_kle_id 	    := NVL (l_oks_bill_rec.kle_id, l_null_kle_id);
		l_header_amount	:= l_header_amount + l_ste_amount;
		l_line_amount	:= l_line_amount   + l_ste_amount;
 		l_detail_number	:= l_detail_number + l_line_step;


        ---------------------------------------------------
        -- Commit the present record
        ---------------------------------------------------
        COMMIT;

        FND_FILE.PUT_LINE (FND_FILE.LOG, '       DONE Processing: Contract Number=> '||l_oks_bill_rec.contract_number||' ,Stream Name=> '
					  ||' ,for date=> '||l_oks_bill_rec.DATE_BILLED_FROM||' and Amount=> '||l_ste_amount);

        FND_FILE.PUT_LINE (FND_FILE.LOG, '===============================================================================');

END LOOP;

	------------------------------------------------------------
	-- Save amount for the last transaction header
	------------------------------------------------------------

IF l_khr_id <> l_def_no_val THEN


		u_taiv_rec.id		:= l_header_id;
		u_taiv_rec.amount		:= l_header_amount;

		Okl_Trx_Ar_Invoices_Pub.update_trx_ar_invoices
			(p_api_version
			,p_init_msg_list
			,l_return_status
			,x_msg_count
			,x_msg_data
			,u_taiv_rec
			,r_taiv_rec);

		IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_ERROR;
		END IF;

END IF;


	------------------------------------------------------------
	-- Save amount for the last transaction line
	------------------------------------------------------------

	IF l_kle_id <> l_def_no_val THEN

		u_tilv_rec.id			:= l_line_id;
		u_tilv_rec.amount		:= l_line_amount;

		Okl_Txl_Ar_Inv_Lns_Pub.update_txl_ar_inv_lns
			(p_api_version
			,p_init_msg_list
			,l_return_status
			,x_msg_count
			,x_msg_data
			,u_tilv_rec
			,r_tilv_rec);

		IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
			RAISE Okl_Api.G_EXCEPTION_ERROR;
		END IF;

	END IF;

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXCP) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (Others) => '||SQLERRM);
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END bill_service_contract;

END OKL_UBB_PVT;

/
