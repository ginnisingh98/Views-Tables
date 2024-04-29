--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_STREAMS_PVT" AS
 /* $Header: OKLRCSMB.pls 120.30.12010000.8 2009/11/28 03:44:30 sechawla ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_create_streams_pvt'; -- 'LEASE.STREAMS';
  L_DEBUG_ENABLED VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  ---------------------------------------------------------------------------
  -- FUNCTION initialize
  ---------------------------------------------------------------------------
 PROCEDURE initialize
 IS
 BEGIN
	 g_asset_ids.DELETE;
	 g_periodic_expenses_indexes.DELETE;
         g_periodic_incomes_indexes.DELETE;
         g_rents_indexes.DELETE;
	 g_sfe_ids.DELETE;
	 g_sil_ids.DELETE;
	 g_siy_names.DELETE;




 END initialize;

  ---------------------------------------------------------------------
  -- PROCEDURE adjust_get_sil_id for adjusting indices
  -- for g_sil_idS.
  -- Private procedure called from get_sil_id.
  -- Created by sgorantl
  ----------------------------------------------------------------------

   PROCEDURE adjust_get_sil_id(
             p_array_table IN OUT NOCOPY sil_id_tbl_type
        ) IS
        l_tbl_count NUMBER:=0;
        l_nxt_row   NUMBER:=0;
        BEGIN

     l_tbl_count := p_array_table.COUNT;
     For i in 1..l_tbl_count
     LOOP
      IF p_array_table.EXISTS(i) THEN

       NULL;
      ELSE
       l_nxt_row := p_array_table.NEXT(i);
       p_array_table(i) :=  p_array_table(l_nxt_row);

       p_array_table.DELETE(l_nxt_row);
      END IF;
     END LOOP;
   END;

   ---------------------------------------------------------------------------
  -- FUNCTION get_sil_id
  -- Gets the SIL_ID for a corresponding Asset_ID passed
  ---------------------------------------------------------------------------
  PROCEDURE get_sil_id(p_asset_id IN NUMBER
                      ,x_sil_id OUT NOCOPY NUMBER)
  IS
	j NUMBER;
  BEGIN
  -- adjust indices for g_sil_idS.
  adjust_get_sil_id(g_sil_idS);
    x_sil_id := 0;

	IF g_sil_ids IS NOT NULL THEN

		FOR j IN 1..g_sil_ids.count
		LOOP
			IF p_asset_id = g_sil_ids(j).kle_asset_id
			THEN
				x_sil_id := g_sil_ids(j).sil_id;
			END IF;
                    EXIT WHEN(x_sil_id <> 0);
		END LOOP;
	END IF;
  END get_sil_id;

    ---------------------------------------------------------------------------
    -- FUNCTION get_sfe_id
    -- Gets the SFE_ID for a corresponding Fee_ID passed
  ---------------------------------------------------------------------------
  PROCEDURE get_sfe_id(p_fee_id IN NUMBER
                       ,p_stream_type_id IN NUMBER
                       ,x_sfe_id OUT NOCOPY NUMBER)
  IS
	j NUMBER;
	l_xfe_id NUMBER;
	l_sfe_count NUMBER;
  BEGIN
    x_sfe_id := 0;
	l_xfe_id := 0;
	l_sfe_count := g_sfe_ids.COUNT;
	IF g_sfe_ids IS NOT NULL THEN
		FOR j IN 1..g_sfe_ids.COUNT LOOP
			IF p_fee_id = g_sfe_ids(j).kle_fee_id AND
               g_sfe_ids(j).stream_type_id IS NULL THEN-- smahapat added for fee type solution
				x_sfe_id := g_sfe_ids(j).sfe_id;
				g_sfe_ids(j).stream_type_id := p_stream_type_id; -- smahapat added for fee type solution
			ELSIF p_fee_id = g_sfe_ids(j).kle_fee_id AND
			   g_sfe_ids(j).stream_type_id IS NOT NULL THEN
			   l_xfe_id := g_sfe_ids(j).sfe_id;
			END IF;
		EXIT WHEN(x_sfe_id <> 0);
		END LOOP;
        -- special fix for amortized fee income
		-- addition of a new line for sfe - sty combination

		-- apart from sfe - sty combination for income fee payment
		IF x_sfe_id = 0 AND l_xfe_id <> 0 THEN
		  g_sfe_ids(l_sfe_count+1).sfe_id := l_xfe_id;
		  x_sfe_id := l_xfe_id;
		  g_sfe_ids(l_sfe_count+1).stream_type_id := p_stream_type_id;
		END IF;
	END IF;
  END get_sfe_id;
  ---------------------------------------------------------------------------
  -- FUNCTION get_line_index
  -- Gets a Unique Index for a corresponding Asset_ID passed
  ---------------------------------------------------------------------------
  PROCEDURE get_line_index(p_line_id IN NUMBER,

                           x_line_index OUT NOCOPY NUMBER)

  IS

  BEGIN
	-- Populate a table to hold asset_ids and the corresponding indices
	-- so that same asset_id will use the same Asset_index
	x_line_index := -1; -- Initialize
	-- If exists, Get the Assigned Index and Use
	FOR j IN 1..g_asset_ids.COUNT
	LOOP
		IF g_asset_ids(j).id = p_line_id
		THEN
			x_line_index := g_asset_ids(j).idx;
		END IF;
	EXIT WHEN(x_line_index >= 0);
	END LOOP;
	-- If Not Exists, Assign a New Index and Use
	IF x_line_index < 0 THEN
		x_line_index := g_asset_ids.COUNT;
		g_asset_ids(x_line_index+1).id := p_line_id;
		g_asset_ids(x_line_index+1).idx  := x_line_index;
	END IF;
  END get_line_index;
  ---------------------------------------------------------------------------

  -- FUNCTION get_fee_index
  -- Gets a Unique Index for a corresponding Fee_Index_Key passed
  ---------------------------------------------------------------------------
  PROCEDURE get_fee_index(p_fee_index_key IN VARCHAR2,
                                          p_index_tbl IN OUT NOCOPY periodic_index_tbl_type,

                                          x_fee_index OUT NOCOPY NUMBER)
  IS
  BEGIN
		x_fee_index := -1;
		-- Populate a table to hold fee_ids and the corresponding indices
		-- so that same fee_id will use the same Fee_index
		-- If exists, Get the Assigned Index and Use

		FOR j IN 1..p_index_tbl.COUNT
		LOOP

			IF p_index_tbl(j).description = p_fee_index_key
			THEN
				x_fee_index := p_index_tbl(j).idx;
			END IF;
		EXIT WHEN(x_fee_index >= 0);
		END LOOP;

		-- If Not Exists, Assign a New Index and Use
		IF x_fee_index < 0 THEN
			x_fee_index := p_index_tbl.COUNT;
			p_index_tbl(x_fee_index+1).description := p_fee_index_key;
			p_index_tbl(x_fee_index+1).idx  := x_fee_index;
		END IF;
  END get_fee_index;
  ---------------------------------------------------------------------------
  -- FUNCTION get_siy_index
  -- Gets a Unique Index for a corresponding SIY_Index_Key passed
  ---------------------------------------------------------------------------
  PROCEDURE get_siy_index(p_siy_index_key IN VARCHAR2,
                           x_siy_index OUT NOCOPY NUMBER)
  IS
  BEGIN
	-- Populate a table to hold asset_ids and the corresponding indices
	-- so that same asset_id will use the same Asset_index
	x_siy_index := -1; -- Initialize
	-- If exists, Get the Assigned Index and Use
	FOR j IN 1..g_siy_names.COUNT
	LOOP
		IF g_siy_names(j).description = p_siy_index_key
		THEN
			x_siy_index := g_siy_names(j).idx;
		END IF;
	EXIT WHEN(x_siy_index >= 0);
	END LOOP;
	-- If Not Exists, Assign a New Index and Use
	IF x_siy_index < 0 THEN
		x_siy_index := g_siy_names.COUNT;
		g_siy_names(x_siy_index+1).description := p_siy_index_key;
		g_siy_names(x_siy_index+1).idx  := x_siy_index;
	END IF;
  END get_siy_index;


  ---------------------------------------------------------------------
  -- PROCEDURE adjust_index_one_off_fee for adjusting indices
  -- for One off fee table.
  -- Private procedure called from insert_finance_fee_for_lease AND
  -- insert_finance_fee_for_loan.
  -- Created by sgorantl
  ----------------------------------------------------------------------

   PROCEDURE adjust_index_one_off_fee(
             p_array_table IN OUT NOCOPY csm_one_off_fee_tbl_type
      ) IS
     l_tbl_count NUMBER:=0;
     l_nxt_row   NUMBER:=0;
    BEGIN

     l_tbl_count := p_array_table.COUNT;
     For i in 1..l_tbl_count

     LOOP
      IF p_array_table.EXISTS(i) THEN

       NULL;
      ELSE
       l_nxt_row := p_array_table.NEXT(i);
       p_array_table(i) :=  p_array_table(l_nxt_row);
       p_array_table.DELETE(l_nxt_row);
      END IF;
     END LOOP;
    END;

  ---------------------------------------------------------------------
  -- PROCEDURE adjust_index_one_off_fee for adjusting indices
  -- for perodic expences table.
  -- Private procedure called from insert_finance_fee_for_lease AND
  -- insert_finance_fee_for_loan.
  -- Created by sgorantl
  ----------------------------------------------------------------------

    PROCEDURE adjust_index_periodic_expense(
              p_array_table IN OUT NOCOPY csm_periodic_expenses_tbl_type
         ) IS
     l_tbl_count number:=0;
     l_nxt_row   number:=0;

    BEGIN
     l_tbl_count := p_array_table.COUNT;
     For i IN 1..l_tbl_count
     LOOP
      IF p_array_table.EXISTS(i) THEN
       NULL;

      ELSE
       l_nxt_row := p_array_table.NEXT(i);
       p_array_table(i) :=  p_array_table(l_nxt_row);
       p_array_table.DELETE(l_nxt_row);
      END IF;
     END LOOP;
    END;

  ---------------------------------------------------------------------------
  -- FUNCTION assign_header_details
  -- Assigns the Header related data for LEASE TYPE Header Rec.

  ---------------------------------------------------------------------------
  FUNCTION assign_header_details(
       	p_lease_header_rec	IN 	csm_lease_rec_type
       ,x_return_status                		OUT NOCOPY VARCHAR2
  ) RETURN sifv_rec_type
  IS
    CURSOR l_okl_prc_template_csr(p_pdt_id NUMBER, l_date DATE)
    IS
      SELECT template_name,template_path
      FROM OKL_PRD_PRICE_TMPLS
      WHERE pdt_id = p_pdt_id
      AND l_date BETWEEN start_date AND NVL(end_date,l_date);

	--smahapat 11/10/02 multi-gaap - addition
	CURSOR l_sif_csr(l_contract_id NUMBER, l_trx_number NUMBER)
	IS
	  SELECT id
	  FROM okl_stream_interfaces
	  WHERE khr_id = l_contract_id AND transaction_number = l_trx_number
	        AND sis_code IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED,G_SIS_PROCESS_COMPLETE);
	--smahapat addition end

    --sechawla 27-nov-09 9001267 : begin
     CURSOR l_get_report_pdt_csr(p_khr_id NUMBER)
    IS
     SELECT pdt.reporting_pdt_id
       FROM okl_k_headers khr,
            okl_products_v pdt
      WHERE khr.id = p_khr_id
        AND khr.pdt_id = pdt.id(+);

    l_report_pdt_id   NUMBER;
    --sechawla 27-nov-09 9001267 : end

    lp_sifv_rec		sifv_rec_type;
    l_sys_date DATE := TRUNC(SYSDATE);
  ---------------------------------------------------------------------------
  -- FUNCTION get_deal_type
  -- Gets the Corresponding Deal Type based on the ORP Code
  ---------------------------------------------------------------------------
  FUNCTION get_deal_type(p_orp_code IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_deal_type VARCHAR2(4) := '';
  BEGIN
	   IF p_orp_code IN ( G_ORP_CODE_BOOKING, G_ORP_CODE_UPGRADE ) THEN
  	     l_deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LS_BOOK_OUT;
       ELSIF p_orp_code = G_ORP_CODE_RESTRUCTURE_AM

       OR    p_orp_code = G_ORP_CODE_RESTRUCTURE_CS
       OR    p_orp_code = G_ORP_CODE_RENEWAL
	   OR p_orp_code = G_ORP_CODE_VARIABLE_INTEREST
       THEN
          l_deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LS_REST_OUT;
	   ELSIF p_orp_code = G_ORP_CODE_QUOTE  THEN
	      l_deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LS_QUOT_OUT;
       END IF;
	   RETURN l_deal_type;
  END get_deal_type;
  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
  	lp_sifv_rec.khr_id := p_lease_header_rec.khr_id;
    lp_sifv_rec.sif_mode := p_lease_header_rec.sif_mode;
  	lp_sifv_rec.country := p_lease_header_rec.country;

  	lp_sifv_rec.sis_code := G_SIS_HDR_INSERTED;
  	lp_sifv_rec.orp_code := p_lease_header_rec.orp_code;
  	lp_sifv_rec.date_payments_commencement := p_lease_header_rec.date_payments_commencement;

  	lp_sifv_rec.security_deposit_amount := p_lease_header_rec.security_deposit_amount;
  	lp_sifv_rec.date_sec_deposit_collected := p_lease_header_rec.date_sec_deposit_collected;
  	lp_sifv_rec.fasb_acct_treatment_method := p_lease_header_rec.fasb_acct_treatment_method;

  	lp_sifv_rec.adjust := p_lease_header_rec.adjust;
  	lp_sifv_rec.adjustment_method := p_lease_header_rec.adjustment_method;
  	lp_sifv_rec.date_processed := SYSDATE;
  	lp_sifv_rec.irs_tax_treatment_method := p_lease_header_rec.irs_tax_treatment_method;
	lp_sifv_rec.date_delivery := p_lease_header_rec.date_delivery;
  	lp_sifv_rec.implicit_interest_rate := p_lease_header_rec.implicit_interest_rate;
  	lp_sifv_rec.rvi_rate := p_lease_header_rec.rvi_rate;
	lp_sifv_rec.rvi_yn := p_lease_header_rec.rvi_yn;
  	lp_sifv_rec.date_delivery := p_lease_header_rec.date_payments_commencement;
  	lp_sifv_rec.term := p_lease_header_rec.term;
  	lp_sifv_rec.structure := p_lease_header_rec.structure;
	/*
  	-- If "Booking"
	IF p_lease_header_rec.orp_code = G_ORP_CODE_BOOKING THEN
  	   lp_sifv_rec.deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LS_BOOK_OUT;
  	-- Else If "ReStructure"
  	ELSIF p_lease_header_rec.orp_code = G_ORP_CODE_RESTRUCTURE_AM
  	OR    p_lease_header_rec.orp_code = G_ORP_CODE_RESTRUCTURE_CS THEN
  	   lp_sifv_rec.deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LS_REST_OUT;
  	END IF;
	*/
  	lp_sifv_rec.deal_type := get_deal_type(p_lease_header_rec.orp_code);
  	lp_sifv_rec.pricing_template_name := 'DEFAULT';

     -- sechawla 27-nov-09 9001267 : begin
    IF p_lease_header_rec.purpose_code = 'REPORT' THEN
       OPEN l_get_report_pdt_csr(p_lease_header_rec.khr_id);
       FETCH l_get_report_pdt_csr INTO l_report_pdt_id;
       CLOSE l_get_report_pdt_csr;

       FOR l_okl_prc_template IN l_okl_prc_template_csr(l_report_pdt_id,l_sys_date)
       LOOP
          lp_sifv_rec.pricing_template_name := l_okl_prc_template.template_path || l_okl_prc_template.template_name;
       END LOOP;
    ELSE
       FOR l_okl_prc_template IN l_okl_prc_template_csr(p_lease_header_rec.pdt_id,l_sys_date)
       LOOP
          lp_sifv_rec.pricing_template_name := l_okl_prc_template.template_path || l_okl_prc_template.template_name;
       END LOOP;
    END IF;
    -- sechawla 27-nov-09 9001267 : end


    -- mvasudev , 07/08/2002
    -- Mandatory Checks moved here from TAPI(OKL_SIF_PVT) to get rid of
    -- cyclic dependancy of OKL_SIF_PVT with OKL_INVOKE_PRICING_ENGINE_PVT

       IF lp_sifv_rec.deal_type = OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LS_REST_OUT
       AND (p_lease_header_rec.Jtot_Object1_Code IS NULL OR p_lease_header_rec.Jtot_Object1_Code = OKC_API.G_MISS_CHAR)
       THEN
	   lp_sifv_rec.jtot_object1_code := p_lease_header_rec.jtot_object1_code;
	   /* smahapat for fee type soln
    	OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
    				p_msg_name	=>	G_REQUIRED_VALUE,
    				p_token1	=>	G_COL_NAME_TOKEN,
    				p_token1_value	=>	'JTOT_OBJECT1_CODE'
    				);
    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	  RAISE G_EXCEPTION_ERROR;

		*/
       ELSE
	lp_sifv_rec.jtot_object1_code := p_lease_header_rec.jtot_object1_code;
       END IF;
  	   IF lp_sifv_rec.deal_type = OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LS_REST_OUT
  	   AND (p_lease_header_rec.object1_id1 IS NULL OR p_lease_header_rec.object1_id1 = OKC_API.G_MISS_CHAR)
  	   THEN
	     lp_sifv_rec.object1_id1 := p_lease_header_rec.object1_id1;
	   /* smahapat for fee type soln
        	OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
					p_msg_name	=>	G_REQUIRED_VALUE,
					p_token1	=>	G_COL_NAME_TOKEN,
					p_token1_value	=>	'OBJECT1_ID1'
					);
	      x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	      RAISE G_EXCEPTION_ERROR;
		*/
    	   ELSE
	     lp_sifv_rec.object1_id1 := p_lease_header_rec.object1_id1;
  	   END IF;
      -- mvasudev, Bug#2650599
       --lp_sifv_rec.sif_id := p_lease_header_rec.sif_id;
       lp_sifv_rec.purpose_code := p_lease_header_rec.purpose_code;
      -- end, mvasudev, Bug#2650599
  	  --smahapat 11/10/02 multi-gaap - addition
	   IF (p_lease_header_rec.purpose_code = G_PURPOSE_CODE_REPORT)
	   THEN
	  --the parent transaction number is being passed in sif_id by caller currently
	     FOR l_sif_data IN l_sif_csr(p_lease_header_rec.khr_id,p_lease_header_rec.sif_id)
		 LOOP

		   IF l_sif_csr%ROWCOUNT = 1 THEN
		     lp_sifv_rec.sif_id := l_sif_data.id;
		   ELSE
        	 OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
					             p_msg_name	=>	G_REQUIRED_VALUE,
					             p_token1	=>	G_COL_NAME_TOKEN,
					             p_token1_value	=>	'SIF_ID');
  	         x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	     RAISE G_EXCEPTION_ERROR;
		   END IF;
		 END LOOP;
	   END IF;
	  --smahapat addition end
	RETURN lp_sifv_rec;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN

	   x_return_status := G_RET_STS_ERROR;
           IF l_okl_prc_template_csr%ISOPEN THEN
             CLOSE l_okl_prc_template_csr;
           END IF;

           IF l_sif_csr%ISOPEN THEN
             CLOSE l_sif_csr;
           END IF;
	   RETURN NULL;

	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
           IF l_okl_prc_template_csr%ISOPEN THEN
             CLOSE l_okl_prc_template_csr;
           END IF;
	   RETURN NULL;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
           IF l_okl_prc_template_csr%ISOPEN THEN
             CLOSE l_okl_prc_template_csr;
           END IF;
	   RETURN NULL;
  END assign_header_details;
  ---------------------------------------------------------------------------
  -- FUNCTION assign_header_details
  ---------------------------------------------------------------------------
  FUNCTION assign_header_details(

	p_loan_header_rec	IN 	csm_loan_rec_type
   ,x_return_status      OUT NOCOPY VARCHAR2
  ) RETURN sifv_rec_type
  IS
    CURSOR l_okl_prc_template_csr(p_pdt_id NUMBER, l_date DATE)
    IS
      SELECT template_name,template_path
      FROM OKL_PRD_PRICE_TMPLS

      WHERE pdt_id = p_pdt_id
      AND l_date BETWEEN start_date AND NVL(end_date,l_date);
	--smahapat 11/10/02 multi-gaap - addition
	CURSOR l_sif_csr(l_contract_id NUMBER, l_trx_number NUMBER)
	IS
	  SELECT id
	  FROM okl_stream_interfaces
	  WHERE khr_id = l_contract_id AND transaction_number = l_trx_number
	        AND sis_code IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED,G_SIS_PROCESS_COMPLETE);
	--smahapat addition end
  	lp_sifv_rec		sifv_rec_type;
	l_sys_date DATE := TRUNC(SYSDATE);
  ---------------------------------------------------------------------------

  -- FUNCTION get_deal_type
  -- Gets the Corresponding Deal Type based on the ORP Code
  ---------------------------------------------------------------------------
  FUNCTION get_deal_type(p_orp_code IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_deal_type VARCHAR2(4) := '';
  BEGIN
       IF p_orp_code IN ( G_ORP_CODE_BOOKING, G_ORP_CODE_UPGRADE ) THEN
  	     l_deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LN_BOOK_OUT;
       ELSIF p_orp_code = G_ORP_CODE_RESTRUCTURE_AM
       OR    p_orp_code = G_ORP_CODE_RESTRUCTURE_CS
       OR    p_orp_code = G_ORP_CODE_RENEWAL
       THEN
          l_deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LN_REST_OUT;
	   ELSIF p_orp_code = G_ORP_CODE_QUOTE  OR p_orp_code = G_ORP_CODE_VARIABLE_INTEREST THEN
	      l_deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LN_QUOT_OUT;
       END IF;
	   RETURN l_deal_type;
  END get_deal_type;
  BEGIN
  	lp_sifv_rec.khr_id := p_loan_header_rec.khr_id;
        lp_sifv_rec.sif_mode := G_MODE_LENDER;
  	lp_sifv_rec.sis_code := G_SIS_HDR_INSERTED;

  	lp_sifv_rec.country := p_loan_header_rec.country;
  	lp_sifv_rec.orp_code := p_loan_header_rec.orp_code;
  	lp_sifv_rec.date_payments_commencement := p_loan_header_rec.date_payments_commencement;
  	lp_sifv_rec.security_deposit_amount := p_loan_header_rec.security_deposit_amount;
  	lp_sifv_rec.date_sec_deposit_collected := p_loan_header_rec.date_sec_deposit_collected;
	--smahapat 10/30/03 for loan quote
  	lp_sifv_rec.adjust := p_loan_header_rec.adjust;
  	lp_sifv_rec.adjustment_method := p_loan_header_rec.adjustment_method;
  	lp_sifv_rec.date_processed := SYSDATE;
  	-- Need to removed once FASB Attribute is made NULLABLE
  	lp_sifv_rec.fasb_acct_treatment_method := 'Unknown';
  	lp_sifv_rec.irs_tax_treatment_method := 'Unknown';
  	lp_sifv_rec.total_funding := p_loan_header_rec.total_lending;
  	lp_sifv_rec.date_delivery := p_loan_header_rec.date_start;
  	lp_sifv_rec.lending_rate := p_loan_header_rec.lending_rate;
  	lp_sifv_rec.pricing_template_name := 'DEFAULT';
    FOR l_okl_prc_template IN l_okl_prc_template_csr(p_loan_header_rec.pdt_id,l_sys_date)

    LOOP
      lp_sifv_rec.pricing_template_name := l_okl_prc_template.template_path || l_okl_prc_template.template_name;
    END LOOP;
	/*
  	-- If "Booking"

	IF p_loan_header_rec.orp_code = G_ORP_CODE_BOOKING THEN
  	   lp_sifv_rec.deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LN_BOOK_OUT;
  	-- Else If "ReStructure"
  	ELSIF p_loan_header_rec.orp_code = G_ORP_CODE_RESTRUCTURE_AM
  	OR    p_loan_header_rec.orp_code = G_ORP_CODE_RESTRUCTURE_CS THEN

  	   lp_sifv_rec.deal_type := Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_SUBTYPE_LN_REST_OUT;
  	END IF;
	*/
  	lp_sifv_rec.deal_type := get_deal_type(p_loan_header_rec.orp_code);
    -- mvasudev , 07/08/2002
    -- Mandatory Checks moved here from TAPI(OKL_SIF_PVT) to get rid of
    -- cyclic dependancy of OKL_SIF_PVT with OKL_INVOKE_PRICING_ENGINE_PVT
       IF lp_sifv_rec.deal_type = OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LS_REST_OUT
       AND (p_loan_header_rec.Jtot_Object1_Code IS NULL OR p_loan_header_rec.Jtot_Object1_Code = OKC_API.G_MISS_CHAR)
       THEN
    	OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
    				p_msg_name	=>	G_REQUIRED_VALUE,
    				p_token1	=>	G_COL_NAME_TOKEN,
    				p_token1_value	=>	'JTOT_OBJECT1_CODE'
    				);
    	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	  RAISE G_EXCEPTION_ERROR;
       ELSE
	lp_sifv_rec.jtot_object1_code := p_loan_header_rec.jtot_object1_code;
       END IF;
  	   IF lp_sifv_rec.deal_type = OKL_INVOKE_PRICING_ENGINE_PVT.G_XMLG_TRX_SUBTYPE_LS_REST_OUT
  	   AND (p_loan_header_rec.object1_id1 IS NULL OR p_loan_header_rec.object1_id1 = OKC_API.G_MISS_CHAR)
  	   THEN
        	OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
					p_msg_name	=>	G_REQUIRED_VALUE,

					p_token1	=>	G_COL_NAME_TOKEN,
					p_token1_value	=>	'OBJECT1_ID1'
					);
	      x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	      RAISE G_EXCEPTION_ERROR;
    	   ELSE
	     lp_sifv_rec.object1_id1 := p_loan_header_rec.object1_id1;
  	   END IF;
      -- mvasudev, Bug#2650599

       --lp_sifv_rec.sif_id := p_loan_header_rec.sif_id;
       lp_sifv_rec.purpose_code := p_loan_header_rec.purpose_code;
      -- end, mvasudev, Bug#2650599
  	  --smahapat 11/10/02 multi-gaap - addition
	   IF (p_loan_header_rec.purpose_code = G_PURPOSE_CODE_REPORT)
	   THEN
	  --the parent transaction number is being passed in sif_id by caller currently
	     FOR l_sif_data IN l_sif_csr(p_loan_header_rec.khr_id,p_loan_header_rec.sif_id)
		 LOOP
		   IF l_sif_csr%ROWCOUNT = 1 THEN
		     lp_sifv_rec.sif_id := l_sif_data.id;
		   ELSE
        	 OKL_API.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
					             p_msg_name	=>	G_REQUIRED_VALUE,

					             p_token1	=>	G_COL_NAME_TOKEN,
					             p_token1_value	=>	'SIF_ID');
  	         x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	     RAISE G_EXCEPTION_ERROR;
		   END IF;
		 END LOOP;
	   END IF;
	  --smahapat addition end

	RETURN lp_sifv_rec;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
           IF l_okl_prc_template_csr%ISOPEN THEN
             CLOSE l_okl_prc_template_csr;
           END IF;
	   RETURN NULL;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	   x_return_status := G_RET_STS_UNEXP_ERROR;
           IF l_okl_prc_template_csr%ISOPEN THEN
             CLOSE l_okl_prc_template_csr;
           END IF;
	   RETURN NULL;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
           IF l_okl_prc_template_csr%ISOPEN THEN
             CLOSE l_okl_prc_template_csr;
           END IF;
	   RETURN NULL;

  END assign_header_details;
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_asset_lines
  -- Assigns and Inserts Asset Line details for this Contract
  ---------------------------------------------------------------------------
  PROCEDURE insert_asset_lines(

	p_api_version	IN NUMBER
   ,p_init_msg_list IN  VARCHAR2 DEFAULT G_FALSE
   ,p_sif_id	IN NUMBER
   ,p_csm_line_details_tbl IN csm_line_details_tbl_type
   ,x_return_status                		OUT NOCOPY VARCHAR2
   ,x_msg_count                    		OUT NOCOPY NUMBER

   ,x_msg_data                     		OUT NOCOPY VARCHAR2
  ) IS

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

	lp_silv_rec 			  silv_rec_type;
	lx_silv_rec 			  silv_rec_type;
	i 				NUMBER := 0;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_index NUMBER := -1;
  BEGIN
     l_return_status := G_RET_STS_SUCCESS;

     --sechawla 10-jul-09 PRB ESG enhancements : begin
	 OPEN  get_rebook_type;
     FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
     CLOSE get_rebook_type;
     --sechawla 10-jul-09 PRB ESG enhancements : end

    FOR i IN 1..p_csm_line_details_tbl.COUNT
    LOOP
  		--lp_silv_rec.index_number := i;
  		l_index := i-1;
  		lp_silv_rec.index_number := l_index;
		lp_silv_rec.sif_id := p_sif_id;
		lp_silv_rec.kle_id := p_csm_line_details_tbl(i).kle_asset_id;

		--sechawla 10-jul-09 PRB ESG enhancements : begin
	    IF l_PROSPECTIVE_REBOOK_YN = 'Y' then
            lp_silv_rec.orig_contract_line_id := p_csm_line_details_tbl(i).orig_contract_line_id;
        END IF;
       --sechawla 10-jul-09 PRB ESG enhancements : end

		lp_silv_rec.sil_type := G_SIL_TYPE_LEASE;
		lp_silv_rec.description := p_csm_line_details_tbl(i).description;
		lp_silv_rec.asset_cost := p_csm_line_details_tbl(i).asset_cost;
		lp_silv_rec.date_delivery := p_csm_line_details_tbl(i).date_delivery;
		lp_silv_rec.date_funding := p_csm_line_details_tbl(i).date_funding;
		lp_silv_rec.residual_amount := p_csm_line_details_tbl(i).residual_amount;
		lp_silv_rec.residual_date := p_csm_line_details_tbl(i).residual_date;
		lp_silv_rec.fed_depre_method := p_csm_line_details_tbl(i).fed_depre_method;
		lp_silv_rec.fed_depre_basis_percent := p_csm_line_details_tbl(i).fed_depre_basis_percent;
		lp_silv_rec.date_fed_depre := p_csm_line_details_tbl(i).date_fed_depre;
		lp_silv_rec.fed_depre_term := p_csm_line_details_tbl(i).fed_depre_term;
		lp_silv_rec.fed_depre_salvage := p_csm_line_details_tbl(i).fed_depre_salvage;
		lp_silv_rec.fed_depre_adr_conve := p_csm_line_details_tbl(i).fed_depre_adr_conve;
		lp_silv_rec.fed_depre_dmnshing_value_rate := p_csm_line_details_tbl(i).fed_depre_dmnshing_value_rate;
		lp_silv_rec.state_depre_method := p_csm_line_details_tbl(i).state_depre_method;
		lp_silv_rec.state_depre_basis_percent := p_csm_line_details_tbl(i).state_depre_basis_percent;
		lp_silv_rec.date_state_depre := p_csm_line_details_tbl(i).date_state_depre;
		lp_silv_rec.state_depre_term := p_csm_line_details_tbl(i).state_depre_term;
		lp_silv_rec.state_depre_salvage := p_csm_line_details_tbl(i).state_depre_salvage;
		lp_silv_rec.state_depre_adr_convent := p_csm_line_details_tbl(i).state_depre_adr_convent;
		lp_silv_rec.state_depre_dmnshing_value_rt := p_csm_line_details_tbl(i).state_depre_dmnshing_value_rt;

		lp_silv_rec.book_method := p_csm_line_details_tbl(i).book_method;
		lp_silv_rec.book_basis_percent := p_csm_line_details_tbl(i).book_basis_percent;
		lp_silv_rec.date_book := p_csm_line_details_tbl(i).date_book;
		lp_silv_rec.book_term := p_csm_line_details_tbl(i).book_term;
		lp_silv_rec.book_salvage := p_csm_line_details_tbl(i).book_salvage;
		lp_silv_rec.book_adr_convention := p_csm_line_details_tbl(i).book_adr_convention;
		lp_silv_rec.book_depre_dmnshing_value_rt := p_csm_line_details_tbl(i).book_depre_dmnshing_value_rt;
		lp_silv_rec.residual_guarantee_method := p_csm_line_details_tbl(i).residual_guarantee_method;
		lp_silv_rec.residual_guarantee_amount := p_csm_line_details_tbl(i).residual_guarantee_amount;
		lp_silv_rec.purchase_option := p_csm_line_details_tbl(i).purchase_option;
		lp_silv_rec.purchase_option_amount := p_csm_line_details_tbl(i).purchase_option_amount;
		lp_silv_rec.residual_guarantee_type := p_csm_line_details_tbl(i).guarantee_type;
  lp_silv_rec.down_payment_amount := p_csm_line_details_tbl(i).down_payment_amount;
  lp_silv_rec.capitalize_down_payment_yn := p_csm_line_details_tbl(i).capitalize_down_payment_yn;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Lines_Pub.insert_sif_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;

    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Lines_Pub.insert_sif_lines ');
    END;
  END IF;
		Okl_Sif_Lines_Pub.insert_sif_lines(
        		p_api_version => p_api_version
		       ,p_init_msg_list => p_init_msg_list
		       ,x_return_status => l_return_status

		       ,x_msg_count => x_msg_count
		       ,x_msg_data => x_msg_data
		       ,p_silv_rec => lp_silv_rec
		       ,x_silv_rec => lx_silv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Lines_Pub.insert_sif_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Lines_Pub.insert_sif_lines
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;
		g_sil_ids(i).kle_asset_id := p_csm_line_details_tbl(i).kle_asset_id;
		g_sil_ids(i).sil_id := lx_silv_rec.id;
	END LOOP;

	x_return_status := l_return_status;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN

		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);

	   x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_asset_lines;



---------------------------------------------------------------------------
  -- FUNCTION assign_one_off_fees
  -- Assigns One Off Fee details for this Contract
  -- Can Occur both at the Header and Asset but always unique
  ---------------------------------------------------------------------------
  FUNCTION assign_one_off_fees(
	p_sif_id	IN NUMBER,
	p_csm_one_off_fee_tbl IN csm_one_off_fee_tbl_type,
       x_return_status  OUT NOCOPY VARCHAR2
  ) RETURN sfev_tbl_type
  IS
	CURSOR l_okl_sil_pk_csr(p_kle_id IN OKL_SIF_LINES_V.KLE_ID%TYPE) IS
	  SELECT ID
	  FROM  OKL_SIF_LINES
	  WHERE kle_id = p_kle_id;
	l_sfev_one_off_tbl sfev_tbl_type;

	-- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from okl_sys_acct_opts;

    --sechawla 24-Jul-09 PRB ESG Enhancements : get orig_contract_line_id for the subsidy line
    cursor get_orig_subsidy_line_id(cp_subsidy_line_id in number) is
    select orig_contract_line_id
    from   okl_k_lines
    where  id = cp_subsidy_line_id;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

	i 				NUMBER := 0;
	j 				NUMBER := 0;
	fee_index NUMBER := 0;
	sec_dep_index NUMBER := 0;
        subsidy_index NUMBER := 0;
        s_count NUMBER := 0;
  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;

    --sechawla 10-jul-09 PRB ESG enhancements : begin
    OPEN  get_rebook_type;
    FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
    CLOSE get_rebook_type;
    --sechawla 10-jul-09 PRB ESG enhancements : end

    FOR i IN 1..p_csm_one_off_fee_tbl.COUNT
    LOOP
		l_sfev_one_off_tbl(i).sif_id := p_sif_id;
		l_sfev_one_off_tbl(i).kle_id := p_csm_one_off_fee_tbl(i).kle_fee_id;

		--sechawla 15-jul-09 PRB ESG Enhancements : assign orig_contract_line_id
		IF l_PROSPECTIVE_REBOOK_YN = 'Y' then
		   l_sfev_one_off_tbl(i).orig_contract_line_id := p_csm_one_off_fee_tbl(i).orig_contract_line_id;
		END IF;

		-- smahapat for fee type solution - sec deposit
		l_sfev_one_off_tbl(i).DESCRIPTION := p_csm_one_off_fee_tbl(i).description;
		IF p_csm_one_off_fee_tbl(i).fee_type =  'SECDEPOSIT' THEN
		  l_sfev_one_off_tbl(i).sfe_type := G_SFE_TYPE_SECURITY_DEPOSIT;
        	  l_sfev_one_off_tbl(i).date_start := p_csm_one_off_fee_tbl(i).date_start;
		  l_sfev_one_off_tbl(i).fee_index_number := sec_dep_index; --smahapat added for fee type soln

		  sec_dep_index := sec_dep_index + 1;
                 ELSIF p_csm_one_off_fee_tbl(i).other_type =  G_SFE_TYPE_SUBSIDY THEN
		  --suresh gorantla
                  l_sfev_one_off_tbl(i).sfe_type := G_SFE_TYPE_SUBSIDY;
                  --l_sfev_one_off_tbl(i).DESCRIPTION := 'SUBSIDY INCOME ACCRUAL';
		  l_sfev_one_off_tbl(i).DESCRIPTION := p_csm_one_off_fee_tbl(i).description;
 		  l_sfev_one_off_tbl(i).kle_id := p_csm_one_off_fee_tbl(i).other_type_id;

 		  --sechawla 15-jul-09 PRB ESG Enhancements : assign orig_contract_line_id
 		  IF l_PROSPECTIVE_REBOOK_YN = 'Y' then
 		     --sechawla 24-jul-09 For subsidy line in okl_sif_fees, orig_contract_line_id
 		     -- should be the orig_contract_line_id corresponding to subsidy line, not financial asset line
			 open  get_orig_subsidy_line_id(p_csm_one_off_fee_tbl(i).other_type_id);
 		     fetch get_orig_subsidy_line_id into l_sfev_one_off_tbl(i).orig_contract_line_id;
 		     close get_orig_subsidy_line_id;

 		     --l_sfev_one_off_tbl(i).orig_contract_line_id := p_csm_one_off_fee_tbl(i).orig_contract_line_id; --sechawla 24-jul-09
		  END IF;
		  --l_sfev_one_off_tbl(i).kle_id := p_csm_one_off_fee_tbl(i).kle_asset_id;
          l_sfev_one_off_tbl(i).date_start := p_csm_one_off_fee_tbl(i).date_start;
		  l_sfev_one_off_tbl(i).rate := p_csm_one_off_fee_tbl(i).rate;
		  l_sfev_one_off_tbl(i).fee_index_number := subsidy_index;
 		  subsidy_index := subsidy_index + 1;
		else
		  l_sfev_one_off_tbl(i).sfe_type := G_SFE_TYPE_ONE_OFF;
		/* Populate FEE_INDEX
		-- Same FeeID is not going to occur twice
		-- across the Assets or across the Hierarchy(Header and Asset)
		-- So TBL index is good enough

		*/
		--l_sfev_one_off_tbl(i).fee_index_number := i-1;
		l_sfev_one_off_tbl(i).fee_index_number := fee_index; -- smahapat added for fee type

		fee_index := fee_index + 1; -- smahapat added for fee type
		END IF;
		---l_sfev_one_off_tbl(i).description := p_csm_one_off_fee_tbl(i).description;
		l_sfev_one_off_tbl(i).date_paid := p_csm_one_off_fee_tbl(i).date_paid;
		l_sfev_one_off_tbl(i).amount := p_csm_one_off_fee_tbl(i).amount;
		l_sfev_one_off_tbl(i).idc_accounting_flag := p_csm_one_off_fee_tbl(i).idc_accounting_flag ;
		l_sfev_one_off_tbl(i).income_or_expense := p_csm_one_off_fee_tbl(i).income_or_expense;
		l_sfev_one_off_tbl(i).advance_or_arrears := G_ADVANCE;

		/*
		-- If the Fee is for a specific Asset, Store the corresponding SIL_ID.
		-- Useful for Inbound API to map it back to the specific Asset
		*/
		IF p_csm_one_off_fee_tbl(i).kle_asset_id IS NOT NULL
		AND p_csm_one_off_fee_tbl(i).kle_asset_id <> Okc_Api.G_MISS_NUM
		THEN

	        get_sil_id(p_csm_one_off_fee_tbl(i).kle_asset_id,l_sfev_one_off_tbl(i).sil_id);
			IF l_sfev_one_off_tbl(i).sil_id = 0 THEN


		             Okl_Api.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
							p_msg_name	=>	G_INVALID_VALUE,
							p_token1	=>	G_COL_NAME_TOKEN,
							p_token1_value	=>	'KLE_ASSET_ID'
							);
				RAISE G_EXCEPTION_ERROR;
			END IF;
		END IF;

s_count := s_count + 1;
    END LOOP;
 	RETURN l_sfev_one_off_tbl;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	   l_sfev_one_off_tbl.DELETE;
	   RETURN l_sfev_one_off_tbl;

	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_one_off_tbl.DELETE;
	   RETURN l_sfev_one_off_tbl;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_one_off_tbl.DELETE;
	   RETURN l_sfev_one_off_tbl;
  END assign_one_off_fees;

---suresh



  ---------------------------------------------------------------------------

  -- FUNCTION assign_periodic_expenses
  -- Assigns Recurring Fee Details for this Contract
  -- Can Occur both at the Header and Asset but always unique
  ---------------------------------------------------------------------------
  FUNCTION assign_periodic_expenses(
	p_sif_id	IN NUMBER ,
	p_csm_periodic_expenses_tbl IN csm_periodic_expenses_tbl_type,
        x_return_status                		OUT NOCOPY VARCHAR2
  ) RETURN sfev_tbl_type
  IS
	l_sfev_periodic_tbl sfev_tbl_type;
	i		NUMBER := 0;
	-- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

  BEGIN

    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    OPEN  get_rebook_type ;
    FETCh get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN ;
    CLOSE get_rebook_type;


	FOR i IN 1..p_csm_periodic_expenses_tbl.COUNT
    	LOOP
		l_sfev_periodic_tbl(i).sif_id := p_sif_id;
		l_sfev_periodic_tbl(i).kle_id := p_csm_periodic_expenses_tbl(i).kle_fee_id;

		--sechawla 16-JUL-09 PRB ESG enhancements : assign orig_contract_line_id
		IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
	    	l_sfev_periodic_tbl(i).orig_contract_line_id := p_csm_periodic_expenses_tbl(i).orig_contract_line_id;
		END IF;

		l_sfev_periodic_tbl(i).description := p_csm_periodic_expenses_tbl(i).description;
		l_sfev_periodic_tbl(i).income_or_expense := p_csm_periodic_expenses_tbl(i).income_or_expense;
		l_sfev_periodic_tbl(i).date_start := p_csm_periodic_expenses_tbl(i).date_start;
		l_sfev_periodic_tbl(i).level_index_number := p_csm_periodic_expenses_tbl(i).level_index_number-1;
		l_sfev_periodic_tbl(i).level_type := p_csm_periodic_expenses_tbl(i).level_type;
		l_sfev_periodic_tbl(i).number_of_periods := p_csm_periodic_expenses_tbl(i).number_of_periods;
		l_sfev_periodic_tbl(i).amount := p_csm_periodic_expenses_tbl(i).amount;
		l_sfev_periodic_tbl(i).period := p_csm_periodic_expenses_tbl(i).period;
		l_sfev_periodic_tbl(i).advance_or_arrears := p_csm_periodic_expenses_tbl(i).advance_or_arrears;
		l_sfev_periodic_tbl(i).lock_level_step := p_csm_periodic_expenses_tbl(i).lock_level_step;
		-- 06/13/2002
		l_sfev_periodic_tbl(i).structure := p_csm_periodic_expenses_tbl(i).structure;
		l_sfev_periodic_tbl(i).cash_effect_yn := p_csm_periodic_expenses_tbl(i).cash_effect_yn;
		l_sfev_periodic_tbl(i).tax_effect_yn := p_csm_periodic_expenses_tbl(i).tax_effect_yn;
		l_sfev_periodic_tbl(i).days_in_month := p_csm_periodic_expenses_tbl(i).days_in_month;
		l_sfev_periodic_tbl(i).days_in_year := p_csm_periodic_expenses_tbl(i).days_in_year;
                -- RGOOTY: Bug 7552496: Start
                l_sfev_periodic_tbl(i).date_paid := p_csm_periodic_expenses_tbl(i).date_paid;
                -- RGOOTY: Bug 7552496: End
		/*
		-- If the Fee is for a specific Asset, Store the corresponding SIL_ID
		-- and the Asset Index as well.
		-- Useful for Inbound API to map it back to the specific Asset
		*/
		IF p_csm_periodic_expenses_tbl(i).kle_asset_id IS NOT NULL


		AND p_csm_periodic_expenses_tbl(i).kle_asset_id <> Okc_Api.G_MISS_NUM
		THEN
	        get_sil_id(p_csm_periodic_expenses_tbl(i).kle_asset_id,l_sfev_periodic_tbl(i).sil_id);
			IF l_sfev_periodic_tbl(i).sil_id = 0 THEN
		             Okl_Api.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
							p_msg_name	=>	G_INVALID_VALUE,
							p_token1	=>	G_COL_NAME_TOKEN,
							p_token1_value	=>	'KLE_ASSET_ID'
							);
				RAISE G_EXCEPTION_ERROR;
			END IF;
			get_line_index(p_csm_periodic_expenses_tbl(i).kle_asset_id,l_sfev_periodic_tbl(i).level_line_number);
		END IF;
		/* Assign Fee_Index
		-- Each of these Levels is grouped under specific Fee
		-- which is again ,if under an Asset, grouped under specific AssetID.
		--  Levels --> Fees --> (Assets) --> Header
		*/
		-- 04/21/2002
		--l_sfev_periodic_tbl(i).sfe_type := G_SFE_TYPE_PERIODIC_EXPENSE;

		IF p_csm_periodic_expenses_tbl(i).income_or_expense = G_EXPENSE
		THEN
    		    l_sfev_periodic_tbl(i).sfe_type := G_SFE_TYPE_PERIODIC_EXPENSE;
                    get_fee_index(p_csm_periodic_expenses_tbl(i).description || p_csm_periodic_expenses_tbl(i).kle_asset_id || p_csm_periodic_expenses_tbl(i).kle_fee_id,  -- added for fee type soln to take care of duplicate streams
                                        g_periodic_expenses_indexes,
                                        l_sfev_periodic_tbl(i).fee_index_number);
		ELSIF p_csm_periodic_expenses_tbl(i).income_or_expense = G_INCOME THEN
    		   l_sfev_periodic_tbl(i).sfe_type := G_SFE_TYPE_PERIODIC_INCOME;
                   get_fee_index(p_csm_periodic_expenses_tbl(i).description || p_csm_periodic_expenses_tbl(i).kle_asset_id || p_csm_periodic_expenses_tbl(i).kle_fee_id,  -- added for fee type soln to take care of duplicate streams

                                        g_periodic_incomes_indexes,
                                        l_sfev_periodic_tbl(i).fee_index_number);
		END IF;
		-- END, 04/21/2002
	END LOOP;
	RETURN l_sfev_periodic_tbl;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;

	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
  END assign_periodic_expenses;
  ---------------------------------------------------------------------------
  -- FUNCTION assign_rent_details
  -- Assigns the Rent Details for this Contract (for Assets only)
  ---------------------------------------------------------------------------
  FUNCTION assign_rent_details(

	p_sif_id	IN NUMBER ,
	p_csm_periodic_expenses_tbl IN csm_periodic_expenses_tbl_type,
        x_return_status                		OUT NOCOPY VARCHAR2
  ) RETURN sfev_tbl_type
  IS
	l_sfev_periodic_tbl sfev_tbl_type;
	i		NUMBER := 0;
        --Added bu kthiruva on 02-Dec-2005
        --Bug 4766555 - Start of Changes
        j               NUMBER := 0;
        --Bug 4766555 - End of Changes

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
        --Added bu kthiruva on 02-Dec-2005
        --The p_csm_periodic_expenses_tbl should be traversed from FIRST to LAST
        --and not from 1 to tbl.COUNT
        --Bug 4766555 - Start of Changes
        j := p_csm_periodic_expenses_tbl.FIRST;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    OPEN  get_rebook_type;
    FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN ;
    CLOSE get_rebook_type;

	FOR i IN 1..p_csm_periodic_expenses_tbl.COUNT
    	LOOP
		l_sfev_periodic_tbl(i).sif_id := p_sif_id;
		l_sfev_periodic_tbl(i).kle_id := p_csm_periodic_expenses_tbl(j).kle_fee_id;
		l_sfev_periodic_tbl(i).sfe_type := G_SFE_TYPE_RENT;
		l_sfev_periodic_tbl(i).description := p_csm_periodic_expenses_tbl(j).description;
		l_sfev_periodic_tbl(i).income_or_expense := p_csm_periodic_expenses_tbl(j).income_or_expense;
		l_sfev_periodic_tbl(i).date_start := p_csm_periodic_expenses_tbl(j).date_start;
		l_sfev_periodic_tbl(i).level_index_number := p_csm_periodic_expenses_tbl(j).level_index_number-1;
		l_sfev_periodic_tbl(i).level_type := p_csm_periodic_expenses_tbl(j).level_type;
		l_sfev_periodic_tbl(i).number_of_periods := p_csm_periodic_expenses_tbl(j).number_of_periods;
		l_sfev_periodic_tbl(i).amount := p_csm_periodic_expenses_tbl(j).amount;
		l_sfev_periodic_tbl(i).period := p_csm_periodic_expenses_tbl(j).period;
		l_sfev_periodic_tbl(i).advance_or_arrears := p_csm_periodic_expenses_tbl(j).advance_or_arrears ;
		l_sfev_periodic_tbl(i).lock_level_step := p_csm_periodic_expenses_tbl(j).lock_level_step;
		l_sfev_periodic_tbl(i).query_level_yn := p_csm_periodic_expenses_tbl(j).query_level_yn;
		-- 06/13/2002
		l_sfev_periodic_tbl(i).structure := p_csm_periodic_expenses_tbl(j).structure;
  l_sfev_periodic_tbl(i).rate := p_csm_periodic_expenses_tbl(j).rate;
  l_sfev_periodic_tbl(i).days_in_month := p_csm_periodic_expenses_tbl(j).days_in_month;
  l_sfev_periodic_tbl(i).days_in_year := p_csm_periodic_expenses_tbl(j).days_in_year;
  l_sfev_periodic_tbl(i).down_payment_amount := p_csm_periodic_expenses_tbl(j).down_payment_amount;

  --sechawla 14-JUL-09 PRB ESG enhancements : assign orig_contract_line_id
  IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
     l_sfev_periodic_tbl(i).orig_contract_line_id := p_csm_periodic_expenses_tbl(j).orig_contract_line_id;
  END IF;

		/*
		-- For each Rent, Store the corresponding SIL_ID.
		-- Useful for Inbound API to map it back to the specific Asset
		*/

		IF p_csm_periodic_expenses_tbl(j).kle_asset_id IS NOT NULL
		AND p_csm_periodic_expenses_tbl(j).kle_asset_id <> Okc_Api.G_MISS_NUM
		THEN
	        get_sil_id(p_csm_periodic_expenses_tbl(j).kle_asset_id,l_sfev_periodic_tbl(i).sil_id);
			IF l_sfev_periodic_tbl(i).sil_id = 0 THEN
		             Okl_Api.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
							p_msg_name	=>	G_INVALID_VALUE,

							p_token1	=>	G_COL_NAME_TOKEN,
							p_token1_value	=>	'KLE_ASSET_ID'
							);
				RAISE G_EXCEPTION_ERROR;
			END IF;
			get_line_index(p_csm_periodic_expenses_tbl(j).kle_asset_id,l_sfev_periodic_tbl(i).level_line_number);
		END IF;
		get_fee_index(p_csm_periodic_expenses_tbl(j).description || p_csm_periodic_expenses_tbl(j).kle_asset_id,
		                     g_rents_indexes,
                                     l_sfev_periodic_tbl(i).fee_index_number);
                j := p_csm_periodic_expenses_tbl.NEXT(j);
        --Bug 4766555 - End of Changes
	END LOOP;
	RETURN l_sfev_periodic_tbl;
  EXCEPTION

	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
	WHEN OTHERS THEN
		-- store SQL error message on message stack

		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
  END assign_rent_details;

  ---------------------------------------------------------------------------
  -- FUNCTION assign_yield_details
  ---------------------------------------------------------------------------
  FUNCTION assign_yield_details(
	p_sif_id	IN NUMBER ,
	p_csm_yields_tbl IN csm_yields_tbl_type,
        x_return_status                		OUT NOCOPY VARCHAR2
  ) RETURN siyv_tbl_type
  IS
	l_siyv_tbl siyv_tbl_type;
	i 	   NUMBER := 0;
  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
    FOR i IN 1..p_csm_yields_tbl.COUNT
    LOOP
	l_siyv_tbl(i).sif_id 		:= p_sif_id;
	l_siyv_tbl(i).yield_name 	:= p_csm_yields_tbl(i).yield_name;
	l_siyv_tbl(i).method 		:= p_csm_yields_tbl(i).method;
	l_siyv_tbl(i).array_type 	:= p_csm_yields_tbl(i).array_type;
	l_siyv_tbl(i).roe_type 		:= p_csm_yields_tbl(i).roe_type;
	l_siyv_tbl(i).roe_base 		:= p_csm_yields_tbl(i).roe_base;
	l_siyv_tbl(i).compounded_method := p_csm_yields_tbl(i).compounded_method;
	l_siyv_tbl(i).target_value 	:= p_csm_yields_tbl(i).target_value;
	l_siyv_tbl(i).nominal_yn 	:= p_csm_yields_tbl(i).nominal_yn;
	/* Translate Nominal_yn

	IF p_csm_yields_tbl(i).nominal_yn IS NOT NULL
	AND p_csm_yields_tbl(i).nominal_yn <> OKC_API.G_MISS_CHAR
	THEN
		IF p_csm_yields_tbl(i).nominal_yn = G_FND_YES
		THEN
			l_siyv_tbl(i).nominal_yn := G_CSM_TRUE;
		ELSIF p_csm_yields_tbl(i).nominal_yn = G_FND_NO
		THEN
			l_siyv_tbl(i).nominal_yn := G_CSM_FALSE;
		END IF;
	END IF;
        */
	-- mvasudev, 06/26/2002, sno
	l_siyv_tbl(i).siy_type 	:= p_csm_yields_tbl(i).siy_type;
	get_siy_index(p_csm_yields_tbl(i).siy_type || p_csm_yields_tbl(i).yield_name

	              ,l_siyv_tbl(i).index_number);
    END LOOP;
    RETURN l_siyv_tbl;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	   l_siyv_tbl.DELETE;
	   RETURN l_siyv_tbl;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_siyv_tbl.DELETE;
	   RETURN l_siyv_tbl;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_siyv_tbl.DELETE;
	   RETURN l_siyv_tbl;
  END assign_yield_details;
  ---------------------------------------------------------------------------

  -- FUNCTION assign_stream_types
  ---------------------------------------------------------------------------
  FUNCTION assign_stream_types(
	p_sif_id	IN NUMBER ,
	p_csm_stream_types_tbl IN csm_stream_types_tbl_type,
	x_return_status OUT NOCOPY VARCHAR2
  ) RETURN sitv_tbl_type
  IS
  	CURSOR l_okl_sfe_ids_csr(p_sif_id IN OKL_SIF_FEES.sif_id%TYPE)

  	IS
  	SELECT DISTINCT
  	KLE_ID, ID
  	FROM OKL_SIF_FEES
  	WHERE SIF_ID = p_sif_id
	AND kle_id IS NOT NULL;
	-- gboomina commented Bug#4508077
	/*
        -- bug 3548593 smahapat added to filter out one time expenses
	--          since streams are not generated
	AND id NOT IN (
	  SELECT id FROM OKL_SIF_FEES
	  WHERE sfe_type = 'SFO'

	  AND INCOME_OR_EXPENSE = 'EXPENSE'
	);
	*/
	-- satya commented
	--AND SFE_TYPE NOT IN ('SFO');  -- smahapat added for fee type soln
	CURSOR l_okl_sty_name_csr(p_sty_id IN okl_strm_type_tl.id%TYPE)
	IS
	SELECT NAME
	FROM OKL_STRM_TYPE_TL
	WHERE ID = p_sty_id
        AND LANGUAGE = USERENV('LANG'); -- smahapat fixed bug# 3323146
  	CURSOR l_okl_sil_sfe_ids_csr(p_sif_id IN OKL_SIF_FEES.sif_id%TYPE,

  	                             p_sil_id IN OKL_SIF_FEES.sil_id%TYPE,
  	                             p_description IN OKL_SIF_FEES.description%TYPE)
  	IS
	SELECT
	ID
	FROM OKL_SIF_FEES
	WHERE SIF_ID = p_sif_id
	AND SIL_ID = p_sil_id
	AND (level_index_number = 0 OR level_index_number IS NULL)
	AND DESCRIPTION = p_description
	-- bug 3548593 smahapat added to filter out one time expenses
	--          since streams are not generated
	AND id NOT IN (
	  SELECT id FROM OKL_SIF_FEES
	  WHERE sfe_type = 'SFO'
	  AND INCOME_OR_EXPENSE = 'EXPENSE'
	);
	l_sitv_tbl sitv_tbl_type;
	i 	   NUMBER := 0;
	l_sty_name VARCHAR2(150);
	l_token1_value VARCHAR2(150);
  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;

    FOR l_okl_sfe_ids IN l_okl_sfe_ids_csr(p_sif_id)
    LOOP
     	i := i + 1;
     	g_sfe_ids(i).kle_fee_id := l_okl_sfe_ids.kle_id;
     	g_sfe_ids(i).sfe_id := l_okl_sfe_ids.id;


    END LOOP;


    FOR i IN 1..p_csm_stream_types_tbl.COUNT
    LOOP
	    l_sty_name := NULL;
 	    l_sitv_tbl(i).sif_id := p_sif_id;
	    l_sitv_tbl(i).sty_id := p_csm_stream_types_tbl(i).stream_type_id;
		l_sitv_tbl(i).pricing_name := p_csm_stream_types_tbl(i).pricing_name;
    IF p_csm_stream_types_tbl(i).kle_asset_id IS NOT NULL
	AND p_csm_stream_types_tbl(i).kle_asset_id <> Okc_Api.G_MISS_NUM
	THEN

        get_sil_id(p_csm_stream_types_tbl(i).kle_asset_id,l_sitv_tbl(i).sil_id);

		IF l_sitv_tbl(i).sil_id = 0 THEN
	             Okl_Api.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
						p_msg_name	=>	G_INVALID_VALUE,
						p_token1	=>	G_COL_NAME_TOKEN,

						p_token1_value	=>	'KLE_ASSET_ID'
						);
			RAISE G_EXCEPTION_ERROR;
		END IF;
	        -- While given an 'AssetLineID', the api looks for the corresponding fee entries
	        -- in SFE tables looking up with SFE.DESCRIPTION
	        -- (which is actually the "StreamTypeName" got from the sty_id of this rec).
		-- 05/03/2002,mvasudev

		OPEN  l_okl_sty_name_csr(p_csm_stream_types_tbl(i).stream_type_id);
		FETCH l_okl_sty_name_csr INTO l_sty_name;
		CLOSE l_okl_sty_name_csr;
                /* -- 06/13/2002
		-- assign sfe_id
		SELECT
		ID
		INTO l_sitv_tbl(i).sfe_id
		FROM OKL_SIF_FEES
		WHERE SIF_ID = p_sif_id
		AND SIL_ID = l_sitv_tbl(i).sil_id
		--AND SFE_TYPE = 'SFR'  -- 04/10/2002
		-- 04/23/2002,mvasudev
		AND (level_index_number = 0 OR level_index_number IS NULL)
		-- 05/03/2002,mvasudev
		AND DESCRIPTION = l_sty_name;

		*/
		OPEN  l_okl_sil_sfe_ids_csr(p_sif_id, l_sitv_tbl(i).sil_id,l_sty_name);
		FETCH l_okl_sil_sfe_ids_csr INTO l_sitv_tbl(i).sfe_id;
		CLOSE l_okl_sil_sfe_ids_csr;
	ELSIF p_csm_stream_types_tbl(i).kle_fee_id IS NOT NULL
	AND p_csm_stream_types_tbl(i).kle_fee_id <> Okc_Api.G_MISS_NUM
	THEN
	      get_sfe_id(p_csm_stream_types_tbl(i).kle_fee_id,p_csm_stream_types_tbl(i).stream_type_id,l_sitv_tbl(i).sfe_id);
		                                                  -- smahapat added for fee type soln
		  IF l_sitv_tbl(i).sfe_id = 0 THEN
                  -- akjain added for bug # 2442036, getting token value from AK Prompts
		  l_token1_value := Okl_Accounting_Util.Get_Message_Token(p_region_code      => G_AK_REGION_NAME,

	                                                                  p_attribute_code    => 'OKL_FEE_LINE_ID'

	                                                                  );

                  Okl_Api.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
                        	      p_msg_name	=>	G_INVALID_VALUE,
				      p_token1	=>	G_COL_NAME_TOKEN,
				      p_token1_value	=>	l_token1_value
							);
			RAISE G_EXCEPTION_ERROR;
	      END IF;
	END IF;

    END LOOP;
    RETURN l_sitv_tbl;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	   l_sitv_tbl.DELETE;
	   IF l_okl_sty_name_csr%isopen THEN
    	   CLOSE l_okl_sty_name_csr;
	   END IF;
	   IF l_okl_sil_sfe_ids_csr%isopen THEN
	      CLOSE l_okl_sty_name_csr;
	   END IF;
	   IF l_okl_sfe_ids_csr%isopen THEN
	     CLOSE l_okl_sty_name_csr;
	   END IF;
	   RETURN l_sitv_tbl;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sitv_tbl.DELETE;
	   IF l_okl_sty_name_csr%isopen THEN
	     CLOSE l_okl_sty_name_csr;

	   END IF;
	   IF l_okl_sil_sfe_ids_csr%isopen THEN
	      CLOSE l_okl_sty_name_csr;
	   END IF;
	   IF l_okl_sfe_ids_csr%isopen THEN
    	   CLOSE l_okl_sty_name_csr;
	   END IF;
	   RETURN l_sitv_tbl;
	WHEN OTHERS THEN

		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sitv_tbl.DELETE;
	   IF l_okl_sty_name_csr%isopen THEN
	     CLOSE l_okl_sty_name_csr;
	   END IF;
	   IF l_okl_sil_sfe_ids_csr%isopen THEN
	     CLOSE l_okl_sty_name_csr;
	   END IF;
	   IF l_okl_sfe_ids_csr%isopen THEN
	     CLOSE l_okl_sty_name_csr;

	   END IF;
	   RETURN l_sitv_tbl;
  END assign_stream_types;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_loan_lines
  -- Assigns and Inserts Loan Line details for this Contract
  ---------------------------------------------------------------------------
  PROCEDURE insert_loan_lines(
    p_api_version IN NUMBER
   ,p_init_msg_list IN  VARCHAR2 DEFAULT G_FALSE
   ,p_sif_id IN NUMBER
   ,p_csm_loan_lines_tbl IN csm_loan_line_tbl_type
   ,x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                      OUT NOCOPY NUMBER
   ,x_msg_data                       OUT NOCOPY VARCHAR2
  ) IS

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

    lp_silv_rec      silv_rec_type;
    lx_silv_rec      silv_rec_type;
    i     NUMBER := 0;
    l_return_status VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_index NUMBER := -1;
    l_sil_index NUMBER := 0;
    l_count NUMBER := 0;

  BEGIN
    l_return_status := G_RET_STS_SUCCESS;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    OPEN  get_rebook_type ;
    FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
    CLOSE get_rebook_type;

    FOR i IN 1..p_csm_loan_lines_tbl.COUNT
    LOOP
      --lp_silv_rec.index_number := i;
      l_index := i-1;
      lp_silv_rec.index_number := l_index;
      lp_silv_rec.sif_id := p_sif_id;
      lp_silv_rec.kle_id := p_csm_loan_lines_tbl(i).kle_loan_id;


      --sechawla 10-jul-09 : PRB ESG enhancements : begin
      IF l_PROSPECTIVE_REBOOK_YN = 'Y' then
         lp_silv_rec.orig_contract_line_id := p_csm_loan_lines_tbl(i).orig_contract_line_id;
      END IF;
      --sechawla 10-jul-09 : PRB ESG enhancements : end

      lp_silv_rec.sil_type := G_SIL_TYPE_LOAN;
      --Added by kthiruva on 15-Nov-2005 for the Down Payment CR
      --Bug 4738011 - Start of Changes
      lp_silv_rec.down_payment_amount := p_csm_loan_lines_tbl(i).down_payment_amount;
      lp_silv_rec.capitalize_down_payment_yn := p_csm_loan_lines_tbl(i).capitalize_down_payment_yn;
      --Bug 4738011 - End of Changes
      -- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Lines_Pub.insert_sif_lines
      IF(L_DEBUG_ENABLED='Y') THEN
        L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
        IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
      END IF;
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Lines_Pub.insert_sif_lines ');
        END;
      END IF;
      Okl_Sif_Lines_Pub.insert_sif_lines(
          p_api_version => p_api_version
         ,p_init_msg_list => p_init_msg_list
         ,x_return_status => l_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
         ,p_silv_rec => lp_silv_rec
         ,x_silv_rec => lx_silv_rec);
      IF(IS_DEBUG_PROCEDURE_ON) THEN
        BEGIN
          OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Lines_Pub.insert_sif_lines ');
        END;
      END IF;
      -- End of wraper code generated automatically by Debug code generator for Okl_Sif_Lines_Pub.insert_sif_lines
      IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
      ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      --satya changed 08/28 for fin fee
      --l_count := g_sil_ids.count;
      l_count := g_sil_ids.count + 1;
      IF i = 1 then
        l_sil_index := l_count + 1;
      ELSE
        l_sil_index := l_count + i;
      END IF;
      g_sil_ids(l_sil_index).kle_asset_id := p_csm_loan_lines_tbl(i).kle_loan_id;
      g_sil_ids(l_sil_index).sil_id := lx_silv_rec.id;
      --g_sil_ids(l_sil_index).kle_asset_id := p_csm_loan_lines_tbl(i).kle_loan_id;
       --g_sil_ids(l_sil_index).sil_id := lx_silv_rec.id;
    --satya change end 08/28 for fin fee
    END LOOP;
    x_return_status := l_return_status;
  EXCEPTION
     WHEN G_EXCEPTION_ERROR THEN
        x_return_status := G_RET_STS_ERROR;
     WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
      -- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name => G_APP_NAME,
           p_msg_name => G_UNEXPECTED_ERROR,
           p_token1 => G_SQLCODE_TOKEN,
           p_token1_value => SQLCODE,
           p_token2 => G_SQLERRM_TOKEN,
           p_token2_value => SQLERRM);
        x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_loan_lines;
  -- 04/21/2002
  ---------------------------------------------------------------------------
  -- FUNCTION assign_loan_lines
  -- Assigns Loan Line Details for this Contract
  ---------------------------------------------------------------------------
  FUNCTION assign_loan_levels(
	p_sif_id	IN NUMBER,
	p_csm_loan_levels_tbl IN csm_loan_level_tbl_type,
	p_object1_id1 IN NUMBER DEFAULT 0,
    x_return_status                		OUT NOCOPY VARCHAR2
  ) RETURN sfev_tbl_type
  IS
	l_sfev_periodic_tbl sfev_tbl_type;
	i		NUMBER := 0;
	l_object1_id1 NUMBER;
        --Added by kthiruva on 07-Dec-2005
        --Bug 4766555 - Start of Changes
        j               NUMBER := 0;
        --Bug 4766555 - End of Changes

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    OPEN  get_rebook_type ;
    FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
    CLOSE get_rebook_type;

        --Added by kthiruva on 07-Dec-2005
        --The p_csm_loan_levels_tbl should be traversed from FIRST to LAST
        --and not from 1 to tbl.COUNT
        --Bug 4766555 - Start of Changes
        j := p_csm_loan_levels_tbl.FIRST;
        FOR i IN 1..p_csm_loan_levels_tbl.COUNT
   	LOOP
		l_sfev_periodic_tbl(i).sif_id := p_sif_id;

        --sechawla 15-Jul-09 ESG PRB Enhancements : populate orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_sfev_periodic_tbl(i).orig_contract_line_id := p_csm_loan_levels_tbl(j).orig_contract_line_id;
        END IF;

		l_sfev_periodic_tbl(i).sfe_type := G_SFE_TYPE_LOAN;
		l_sfev_periodic_tbl(i).description := p_csm_loan_levels_tbl(j).description;
		l_sfev_periodic_tbl(i).level_type := p_csm_loan_levels_tbl(j).level_type;
		l_sfev_periodic_tbl(i).amount := p_csm_loan_levels_tbl(j).amount;
		l_sfev_periodic_tbl(i).days_in_month := p_csm_loan_levels_tbl(j).days_in_month;
		l_sfev_periodic_tbl(i).days_in_year := p_csm_loan_levels_tbl(j).days_in_year;
        --Added by mansrini for the VR build
        l_sfev_periodic_tbl(i).balance_type_code := p_csm_loan_levels_tbl(j).balance_type_code;

		IF p_csm_loan_levels_tbl(j).level_type <> G_SFE_LEVEL_FUNDING THEN
			l_sfev_periodic_tbl(i).income_or_expense := p_csm_loan_levels_tbl(j).income_or_expense;
			l_sfev_periodic_tbl(i).level_index_number := p_csm_loan_levels_tbl(j).level_index_number-1;
			l_sfev_periodic_tbl(i).number_of_periods := p_csm_loan_levels_tbl(j).number_of_periods;
			l_sfev_periodic_tbl(i).period := p_csm_loan_levels_tbl(j).period;
			--04/23/2002
			l_sfev_periodic_tbl(i).date_start := p_csm_loan_levels_tbl(j).date_start;
			l_sfev_periodic_tbl(i).advance_or_arrears := p_csm_loan_levels_tbl(j).advance_or_arrears;
			l_sfev_periodic_tbl(i).lock_level_step := p_csm_loan_levels_tbl(j).lock_level_step;
	                l_sfev_periodic_tbl(i).rate := p_csm_loan_levels_tbl(j).rate;

	                -- 06/13/2002
		        l_sfev_periodic_tbl(i).structure := p_csm_loan_levels_tbl(j).structure;
		        --08/20/02 akjain
		        l_sfev_periodic_tbl(i).query_level_yn := p_csm_loan_levels_tbl(j).query_level_yn;
		ELSE
		    -- Default the mandatory attributes to some value and Disregard it while Map-Processing
			-- as These are not useful in case of "Funding" Level
			l_sfev_periodic_tbl(i).income_or_expense := G_EXPENSE;
			---satya changed for PPD oct 2004

			l_sfev_periodic_tbl(i).level_index_number := p_csm_loan_levels_tbl(j).level_index_number-1;

			l_sfev_periodic_tbl(i).number_of_periods := 0;
			l_sfev_periodic_tbl(i).period := 'M';
			l_sfev_periodic_tbl(i).date_start := SYSDATE;
  		        l_sfev_periodic_tbl(i).date_start := p_csm_loan_levels_tbl(j).date_start;
			l_sfev_periodic_tbl(i).advance_or_arrears := G_ADVANCE;

                        --Added by kthiruva on 13-Apr-2006
                        --Retaining the value of query_level_yn that has been set already
                        --Bug 5090060 - Start of Changes
                        l_sfev_periodic_tbl(i).query_level_yn := p_csm_loan_levels_tbl(j).query_level_yn;
                        --Bug 5090060 - End of Changes

		END IF;
		/*
		-- For each Rent, Store the corresponding SIL_ID.
		-- Useful for Inbound API to map it back to the specific Asset
		*/

		IF p_csm_loan_levels_tbl(j).kle_loan_id IS NOT NULL
		AND p_csm_loan_levels_tbl(j).kle_loan_id <> Okc_Api.G_MISS_NUM
		THEN

	        get_sil_id(p_csm_loan_levels_tbl(j).kle_loan_id,l_sfev_periodic_tbl(i).sil_id);



			IF l_sfev_periodic_tbl(i).sil_id = 0 THEN

		             Okl_Api.SET_MESSAGE(p_app_name	=>	G_OKC_APP,
							p_msg_name	=>	G_INVALID_VALUE,
							p_token1	=>	G_COL_NAME_TOKEN,
							p_token1_value	=>	'KLE_ASSET_ID'
							);
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
			/* Assign Line_Index
			-- Each of these Levels is , necessarily, grouped under specific AssetID.
			--  LoanLevels --> LoanLines --> Header
			*/
			get_line_index(p_csm_loan_levels_tbl(j).kle_loan_id,l_sfev_periodic_tbl(i).level_line_number);
			-- make asset_index and fee_index same, assuming one-to-one correspondence
			l_sfev_periodic_tbl(i).fee_index_number := l_sfev_periodic_tbl(i).level_line_number;
		ELSE
		  --smahapat for quotes only 10/30/03
		  l_sfev_periodic_tbl(i).fee_index_number := 0;
		END IF;
                j := p_csm_loan_levels_tbl.NEXT(j);
	END LOOP;
        --Bug 4766555 - End of Changes

	RETURN l_sfev_periodic_tbl;

  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_periodic_tbl.DELETE;
	   RETURN l_sfev_periodic_tbl;
	WHEN OTHERS THEN

		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_sfev_periodic_tbl.DELETE;

	   RETURN l_sfev_periodic_tbl;
  END assign_loan_levels;
-- end,04/21/2002



/*=========================================================================================+
|   -- PROCEDURE insert_rollover_fee_for_lease                                             |
|   -- This procedure takes care of inserting rollover fee loan lines with in              |
|   -- a lease. It checks for the fee type 'FINACED' to identify rollover fee.              |
|   -- Assigns and Inserts Loan Line AND LOAN LEVEL details for this Contract              |
+==========================================================================================*/

 PROCEDURE insert_rollover_fee_for_lease(
    p_api_version	IN NUMBER
   ,p_init_msg_list     IN  VARCHAR2 DEFAULT G_FALSE

   ,p_sif_id	        IN NUMBER
   ,p_csm_one_off_fee_tbl       IN csm_one_off_fee_tbl_type
   ,p_csm_periodic_expenses_tbl IN csm_periodic_expenses_tbl_type
   ,x_csm_one_off_fee_tbl       OUT NOCOPY csm_one_off_fee_tbl_type
   ,x_csm_periodic_expenses_tbl OUT NOCOPY csm_periodic_expenses_tbl_type
   ,x_return_status            	OUT NOCOPY VARCHAR2
   ,x_msg_count                	OUT NOCOPY NUMBER
   ,x_msg_data                 	OUT NOCOPY VARCHAR2
   ) IS

    lp_silv_rec 	       silv_rec_type;
    lx_silv_rec 	       silv_rec_type;
    l_return_status	       VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_csm_loan_lines_tbl       csm_loan_line_tbl_type;
    l_csm_loan_levels_tbl      csm_loan_level_tbl_type;

    lp_sfev_loan_levels_tbl    sfev_tbl_type;

    lx_sfev_loan_levels_tbl    sfev_tbl_type;

    l_index                    NUMBER := -1;
    l_periodic_expense_count   NUMBER:=0;
    l_periodic_expense_counter NUMBER:=0;
    l_loan_line_counter        NUMBER:=0;
    l_loan_level_counter       NUMBER:=0;
    l_rec_count		       NUMBER:=0;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);
  BEGIN
  l_return_status := G_RET_STS_SUCCESS;

   -- assgning the input structures to local structures
   x_csm_one_off_fee_tbl := p_csm_one_off_fee_tbl;

   x_csm_periodic_expenses_tbl := p_csm_periodic_expenses_tbl;

   -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
   OPEN  get_rebook_type;
   FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
   CLOSE get_rebook_type;

   FOR i IN 1..x_csm_one_off_fee_tbl.COUNT
   LOOP
    IF x_csm_one_off_fee_tbl(i).fee_type = 'ROLLOVER' THEN
    l_rec_count := l_rec_count + 1;

        -- fill the loan line table
 	l_loan_line_counter := l_loan_line_counter + 1;
        l_csm_loan_lines_tbl(l_loan_line_counter).kle_loan_id := x_csm_one_off_fee_tbl(i).kle_fee_id;

        --sechawla 17-Jul-09 : PRB ESG Enhancements : assign orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_csm_loan_lines_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_one_off_fee_tbl(i).orig_contract_line_id;
        END IF;

        -- fill the loan level funding part from one off fee table
        l_loan_level_counter := l_loan_level_counter + 1;

        l_csm_loan_levels_tbl(l_loan_level_counter).description := x_csm_one_off_fee_tbl(i).description;
        l_csm_loan_levels_tbl(l_loan_level_counter).date_start	:= x_csm_one_off_fee_tbl(i).date_paid;
        l_csm_loan_levels_tbl(l_loan_level_counter).kle_loan_id :=  x_csm_one_off_fee_tbl(i).kle_fee_id;

        --sechawla 17-Jul-09 : PRB ESG Enhancements : assign orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_csm_loan_levels_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_one_off_fee_tbl(i).orig_contract_line_id;
        END IF;

        l_csm_loan_levels_tbl(l_loan_level_counter).level_index_number := 	1;
        l_csm_loan_levels_tbl(l_loan_level_counter).level_type := 	G_SFE_LEVEL_FUNDING;
        l_csm_loan_levels_tbl(l_loan_level_counter).amount := x_csm_one_off_fee_tbl(i).amount;
        l_csm_loan_levels_tbl(l_loan_level_counter).income_or_expense := x_csm_one_off_fee_tbl(i).income_or_expense;

    -- get the matching row in periodic expense table
    l_periodic_expense_count   := x_csm_periodic_expenses_tbl.last;
    l_periodic_expense_counter := x_csm_periodic_expenses_tbl.first;
    loop
    IF  x_csm_periodic_expenses_tbl(l_periodic_expense_counter).kle_fee_id =  x_csm_one_off_fee_tbl(i).kle_fee_id THEN

        -- fill the loan level payment part from periodic expense table
        l_loan_level_counter := l_loan_level_counter + 1;
        l_csm_loan_levels_tbl(l_loan_level_counter).description := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).description;
        l_csm_loan_levels_tbl(l_loan_level_counter).date_start  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).date_start;
        l_csm_loan_levels_tbl(l_loan_level_counter).kle_loan_id := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).kle_fee_id;

        --sechawla 17-Jul-09 : PRB ESG Enhancements : assign orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_csm_loan_levels_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).orig_contract_line_id;
        END IF;

        l_csm_loan_levels_tbl(l_loan_level_counter).level_index_number	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).level_index_number + 1;

        l_csm_loan_levels_tbl(l_loan_level_counter).level_type	:= G_SFE_LEVEL_PAYMENT;
        l_csm_loan_levels_tbl(l_loan_level_counter).number_of_periods := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).number_of_periods;
        l_csm_loan_levels_tbl(l_loan_level_counter).amount	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).amount;
        l_csm_loan_levels_tbl(l_loan_level_counter).lock_level_step  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).lock_level_step;
        --l_csm_loan_levels_tbl(l_loan_level_counter).rate	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).rate;
        l_csm_loan_levels_tbl(l_loan_level_counter).period	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).period;
        l_csm_loan_levels_tbl(l_loan_level_counter).advance_or_arrears  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).advance_or_arrears;
        l_csm_loan_levels_tbl(l_loan_level_counter).income_or_expense  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).income_or_expense;
        l_csm_loan_levels_tbl(l_loan_level_counter).structure := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).structure;
        l_csm_loan_levels_tbl(l_loan_level_counter).query_level_yn  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).query_level_yn;

        -- delete processed rows from periodic expense table
        x_csm_periodic_expenses_tbl.delete(l_periodic_expense_counter);
      END IF;

      IF l_periodic_expense_counter = l_periodic_expense_count then
       EXIT;
      ELSE
       l_periodic_expense_counter := x_csm_periodic_expenses_tbl.next(l_periodic_expense_counter);
      END  IF;

     End loop;

     -- delete processed rows from one off fee
     x_csm_one_off_fee_tbl.DELETE(i);
     END IF;
   END LOOP;

   IF (l_rec_count > 0) THEN

   -- adjust the indices for one off AND perodic expence tables

   adjust_index_one_off_fee(x_csm_one_off_fee_tbl);
   adjust_index_periodic_expense(x_csm_periodic_expenses_tbl);

   IF l_csm_loan_lines_tbl IS NOT NULL THEN

 		insert_loan_lines(p_api_version		=> p_api_version,
 	   		    	  p_init_msg_list	=> p_init_msg_list,
  				  p_sif_id		=> p_sif_id,
 				  p_csm_loan_lines_tbl 	=> l_csm_loan_lines_tbl,
 				  x_return_status	=> l_return_status,
 				  x_msg_count		=> x_msg_count,
				  x_msg_data            => x_msg_data);

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN


	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
   END IF;

   IF l_csm_loan_levels_tbl IS NOT NULL THEN
    		lp_sfev_loan_levels_tbl := assign_loan_levels(p_sif_id		=> p_sif_id,
	     					      p_csm_loan_levels_tbl	=> l_csm_loan_levels_tbl,
	 					      x_return_status		=> l_return_status
	 					     );

		IF l_return_status = G_RET_STS_ERROR THEN
		  RAISE G_EXCEPTION_ERROR;
		ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list

	 	       ,x_return_status => l_return_status

	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_loan_levels_tbl
	     	       ,x_sfev_tbl => lx_sfev_loan_levels_tbl);


	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;

	     	END IF;
   END IF;
   END IF;

   EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_rollover_fee_for_lease;





/*=========================================================================================+
|   -- PROCEDURE insert_finance_fee_for_lease                                              |
|   -- This procedure takes care of inserting finance fee loan lines with in               |
|   -- a lease. It checks for the fee type 'FINACED' to identify finance fee.              |
|   -- Assigns and Inserts Loan Line AND LOAN LEVEL details for this Contract              |
+==========================================================================================*/

 PROCEDURE insert_finance_fee_for_lease(
    p_api_version	IN NUMBER
   ,p_init_msg_list     IN  VARCHAR2 DEFAULT G_FALSE
   ,p_sif_id	        IN NUMBER
   ,p_csm_one_off_fee_tbl       IN csm_one_off_fee_tbl_type  --this should have orig_contract_line_id populated
   ,p_csm_periodic_expenses_tbl IN csm_periodic_expenses_tbl_type
   ,x_csm_one_off_fee_tbl       OUT NOCOPY csm_one_off_fee_tbl_type
   ,x_csm_periodic_expenses_tbl OUT NOCOPY csm_periodic_expenses_tbl_type
   ,x_return_status            	OUT NOCOPY VARCHAR2
   ,x_msg_count                	OUT NOCOPY NUMBER
   ,x_msg_data                 	OUT NOCOPY VARCHAR2
   ) IS

    lp_silv_rec 	       silv_rec_type;
    lx_silv_rec 	       silv_rec_type;
    l_return_status	       VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_csm_loan_lines_tbl       csm_loan_line_tbl_type;
    l_csm_loan_levels_tbl      csm_loan_level_tbl_type;

    lp_sfev_loan_levels_tbl    sfev_tbl_type;
    lx_sfev_loan_levels_tbl    sfev_tbl_type;

    l_index                    NUMBER := -1;
    l_periodic_expense_count   NUMBER:=0;
    l_periodic_expense_counter NUMBER:=0;
    l_loan_line_counter        NUMBER:=0;
    l_loan_level_counter       NUMBER:=0;
    l_rec_count		       NUMBER:=0;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);


  BEGIN

  l_return_status := G_RET_STS_SUCCESS;



   -- assgning the input structures to local structures
   x_csm_one_off_fee_tbl := p_csm_one_off_fee_tbl;

   x_csm_periodic_expenses_tbl := p_csm_periodic_expenses_tbl;

   -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
   OPEN  get_rebook_type ;
   FETCH get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
   CLOSE get_rebook_type;

   FOR i IN 1..x_csm_one_off_fee_tbl.COUNT
   LOOP
    IF x_csm_one_off_fee_tbl(i).fee_type in(okl_maintain_fee_pvt.G_FT_FINANCED,'ROLLOVER') THEN
    l_rec_count := l_rec_count + 1;

        -- fill the loan line table
 	l_loan_line_counter := l_loan_line_counter + 1;
        l_csm_loan_lines_tbl(l_loan_line_counter).kle_loan_id := x_csm_one_off_fee_tbl(i).kle_fee_id;

        --sechawla 17-Jul-09 : PRB ESG Enhancements : assign orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_csm_loan_lines_tbl(l_loan_line_counter).orig_contract_line_id := x_csm_one_off_fee_tbl(i).orig_contract_line_id;
        END IF;
        -- fill the loan level funding part from one off fee table
        l_loan_level_counter := l_loan_level_counter + 1;

        l_csm_loan_levels_tbl(l_loan_level_counter).description := x_csm_one_off_fee_tbl(i).description;
        l_csm_loan_levels_tbl(l_loan_level_counter).date_start	:= x_csm_one_off_fee_tbl(i).date_paid;
        l_csm_loan_levels_tbl(l_loan_level_counter).kle_loan_id :=  x_csm_one_off_fee_tbl(i).kle_fee_id;

        --sechawla 17-Jul-09 : PRb ESG Enhancements : assign orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_csm_loan_levels_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_one_off_fee_tbl(i).orig_contract_line_id;
        END IF;

        l_csm_loan_levels_tbl(l_loan_level_counter).level_index_number := 	1;
        l_csm_loan_levels_tbl(l_loan_level_counter).level_type := 	G_SFE_LEVEL_FUNDING;
        l_csm_loan_levels_tbl(l_loan_level_counter).amount := x_csm_one_off_fee_tbl(i).amount;
        l_csm_loan_levels_tbl(l_loan_level_counter).income_or_expense := x_csm_one_off_fee_tbl(i).income_or_expense;

    -- get the matching row in periodic expense table
    l_periodic_expense_count   := x_csm_periodic_expenses_tbl.last;
    l_periodic_expense_counter := x_csm_periodic_expenses_tbl.first;
    loop
    IF  x_csm_periodic_expenses_tbl(l_periodic_expense_counter).kle_fee_id =  x_csm_one_off_fee_tbl(i).kle_fee_id THEN

        -- fill the loan level payment part from periodic expense table
        l_loan_level_counter := l_loan_level_counter + 1;
        l_csm_loan_levels_tbl(l_loan_level_counter).description := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).description;
        l_csm_loan_levels_tbl(l_loan_level_counter).date_start  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).date_start;
        l_csm_loan_levels_tbl(l_loan_level_counter).kle_loan_id := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).kle_fee_id;

        --sechawla 17-Jul-09 : PRb ESG Enhancements : assign orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           l_csm_loan_levels_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).orig_contract_line_id;
        END IF;
        l_csm_loan_levels_tbl(l_loan_level_counter).level_index_number	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).level_index_number + 1;

        l_csm_loan_levels_tbl(l_loan_level_counter).level_type	:= G_SFE_LEVEL_PAYMENT;
        l_csm_loan_levels_tbl(l_loan_level_counter).number_of_periods := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).number_of_periods;
        l_csm_loan_levels_tbl(l_loan_level_counter).amount	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).amount;
        l_csm_loan_levels_tbl(l_loan_level_counter).lock_level_step  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).lock_level_step;
        --l_csm_loan_levels_tbl(l_loan_level_counter).rate	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).rate;
        l_csm_loan_levels_tbl(l_loan_level_counter).period	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).period;
        l_csm_loan_levels_tbl(l_loan_level_counter).advance_or_arrears  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).advance_or_arrears;
        l_csm_loan_levels_tbl(l_loan_level_counter).income_or_expense  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).income_or_expense;
        l_csm_loan_levels_tbl(l_loan_level_counter).structure := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).structure;
        l_csm_loan_levels_tbl(l_loan_level_counter).query_level_yn  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).query_level_yn;

        -- delete processed rows from periodic expense table
        x_csm_periodic_expenses_tbl.delete(l_periodic_expense_counter);
      END IF;

      IF l_periodic_expense_counter = l_periodic_expense_count then
       EXIT;
      ELSE
       l_periodic_expense_counter := x_csm_periodic_expenses_tbl.next(l_periodic_expense_counter);
      END  IF;

     End loop;

     -- delete processed rows from one off fee
     x_csm_one_off_fee_tbl.DELETE(i);
     END IF;
   END LOOP;

   IF (l_rec_count > 0) THEN

   -- adjust the indices for one off AND perodic expence tables
   adjust_index_one_off_fee(x_csm_one_off_fee_tbl);
   adjust_index_periodic_expense(x_csm_periodic_expenses_tbl);

   IF l_csm_loan_lines_tbl IS NOT NULL THEN

 		insert_loan_lines(p_api_version		=> p_api_version, --come back here
 	   		    	  p_init_msg_list	=> p_init_msg_list,
  				  p_sif_id		=> p_sif_id,
 				  p_csm_loan_lines_tbl 	=> l_csm_loan_lines_tbl,
 				  x_return_status	=> l_return_status,
 				  x_msg_count		=> x_msg_count,
				  x_msg_data            => x_msg_data);

/*insert into err_msgs_log values ('insert_loan_lines x_return_status'||x_return_status);
commit;
*/
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;

	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
   END IF;

   IF l_csm_loan_levels_tbl IS NOT NULL THEN
    		lp_sfev_loan_levels_tbl := assign_loan_levels(p_sif_id		=> p_sif_id, --here 333
	     					      p_csm_loan_levels_tbl	=> l_csm_loan_levels_tbl,
	 					      x_return_status		=> l_return_status

	 					     );

/*
insert into err_msgs_log values ('assign_loan_levels x_return_status'||x_return_status);
commit;
*/
		IF l_return_status = G_RET_STS_ERROR THEN
		  RAISE G_EXCEPTION_ERROR;
		ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version

	 	       ,p_init_msg_list => p_init_msg_list

	 	       ,x_return_status => l_return_status

	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_loan_levels_tbl
	     	       ,x_sfev_tbl => lx_sfev_loan_levels_tbl);


/*insert into err_msgs_log values ('Okl_Sif_Fees_Pub.insert_sif_fees x_return_status'||x_return_status);
commit;
*/

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;

	     	END IF;
   END IF;
   END IF;

   EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_finance_fee_for_lease;


/*========================================================================================+
|   -- PROCEDURE insert_finance_fee_for_loan                                              |
|   -- This procedure takes care of inserting finance fee loan lines with in              |
|   -- a loan. It checks for the fee type 'FINACED' to identify finance fee.              |
|   -- Assigns and Inserts Loan Line AND LOAN LEVEL details for this Contract             |
+=========================================================================================*/

 PROCEDURE insert_finance_fee_for_loan(
    p_api_version	IN NUMBER
   ,p_init_msg_list     IN  VARCHAR2 DEFAULT G_FALSE
   ,p_sif_id	        IN NUMBER
   ,p_csm_one_off_fee_tbl       IN  csm_one_off_fee_tbl_type
   ,p_csm_periodic_expenses_tbl IN  csm_periodic_expenses_tbl_type
   ,p_csm_loan_lines_tbl        IN  csm_loan_line_tbl_type
   ,p_csm_loan_levels_tbl       IN  csm_loan_level_tbl_type
   ,x_csm_one_off_fee_tbl       OUT NOCOPY csm_one_off_fee_tbl_type
   ,x_csm_periodic_expenses_tbl OUT NOCOPY csm_periodic_expenses_tbl_type
   ,x_csm_loan_lines_tbl        OUT NOCOPY csm_loan_line_tbl_type
   ,x_csm_loan_levels_tbl       OUT NOCOPY csm_loan_level_tbl_type
   ,x_return_status            	OUT NOCOPY VARCHAR2
   ,x_msg_count                	OUT NOCOPY NUMBER

   ,x_msg_data                 	OUT NOCOPY VARCHAR2
   ) IS

    lp_silv_rec 	       silv_rec_type;
    lx_silv_rec 	       silv_rec_type;
    l_return_status	       VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    lp_sfev_loan_levels_tbl    sfev_tbl_type;
    lx_sfev_loan_levels_tbl    sfev_tbl_type;

    l_index                    NUMBER := -1;
    l_periodic_expense_count   NUMBER:=0;
    l_periodic_expense_counter NUMBER:=0;
    l_loan_line_counter        NUMBER := p_csm_loan_lines_tbl.LAST;
    l_loan_level_counter       NUMBER := p_csm_loan_levels_tbl.LAST;

    l_rec_count		       NUMBER:=0;

    -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
    cursor get_rebook_type is
    select nvl(amort_inc_adj_rev_dt_yn, 'N')
    from   okl_sys_acct_opts;

    l_PROSPECTIVE_REBOOK_YN   VARCHAR2(1);

  BEGIN
  l_return_status := G_RET_STS_SUCCESS;



   -- assgning the input structures to local structures
   x_csm_one_off_fee_tbl := p_csm_one_off_fee_tbl;
   x_csm_periodic_expenses_tbl := p_csm_periodic_expenses_tbl;

   x_csm_loan_lines_tbl := p_csm_loan_lines_tbl;
   x_csm_loan_levels_tbl := p_csm_loan_levels_tbl;

   -- sechawla 20-Jul-09 PRB ESG Enhancements : check rebook option
   OPEN  get_rebook_type ;
   FETCh get_rebook_type INTO l_PROSPECTIVE_REBOOK_YN;
   CLOSE get_rebook_type;


   FOR i IN 1..x_csm_one_off_fee_tbl.COUNT
   LOOP

    IF x_csm_one_off_fee_tbl(i).fee_type in(okl_maintain_fee_pvt.G_FT_FINANCED,'ROLLOVER') THEN
    l_rec_count := l_rec_count + 1;

        -- fill the loan line table
 	l_loan_line_counter := l_loan_line_counter + 1;
        x_csm_loan_lines_tbl(l_loan_line_counter).kle_loan_id := x_csm_one_off_fee_tbl(i).kle_fee_id;

        --sechawla 24-JUL-09 PRB ESG Enhancements : populate orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN

        --sechawla 12-aug-09 8788914 : changed table index l_loan_level_counter to l_loan_line_counter
           x_csm_loan_lines_tbl(l_loan_line_counter).orig_contract_line_id := x_csm_one_off_fee_tbl(i).orig_contract_line_id;
        END IF;

        -- fill the loan level funding part from one off fee table
        l_loan_level_counter := l_loan_level_counter + 1;


        x_csm_loan_levels_tbl(l_loan_level_counter).description := x_csm_one_off_fee_tbl(i).description;
        x_csm_loan_levels_tbl(l_loan_level_counter).date_start	:= x_csm_one_off_fee_tbl(i).date_paid;

        x_csm_loan_levels_tbl(l_loan_level_counter).kle_loan_id :=  x_csm_one_off_fee_tbl(i).kle_fee_id;

        --sechawla 15-JUL-09 PRB ESG Enhancements : populate orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           x_csm_loan_levels_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_one_off_fee_tbl(i).orig_contract_line_id;
        END IF;


        x_csm_loan_levels_tbl(l_loan_level_counter).level_index_number := 	1;
        x_csm_loan_levels_tbl(l_loan_level_counter).level_type := 	G_SFE_LEVEL_FUNDING;
        x_csm_loan_levels_tbl(l_loan_level_counter).amount := x_csm_one_off_fee_tbl(i).amount;

        x_csm_loan_levels_tbl(l_loan_level_counter).income_or_expense := x_csm_one_off_fee_tbl(i).income_or_expense;
    -- get the matching row in periodic expense table
    l_periodic_expense_count   := x_csm_periodic_expenses_tbl.last;
    l_periodic_expense_counter := x_csm_periodic_expenses_tbl.first;
    loop
    IF  x_csm_periodic_expenses_tbl(l_periodic_expense_counter).kle_fee_id =  x_csm_one_off_fee_tbl(i).kle_fee_id THEN
        -- fill the loan level payment part from periodic expense table
        l_loan_level_counter := l_loan_level_counter + 1;
        x_csm_loan_levels_tbl(l_loan_level_counter).description := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).description;
        x_csm_loan_levels_tbl(l_loan_level_counter).date_start  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).date_start;
        x_csm_loan_levels_tbl(l_loan_level_counter).kle_loan_id := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).kle_fee_id;

        --sechawla 15-JUL-09 PRB ESG Enhancements : populate orig_contract_line_id
        IF l_PROSPECTIVE_REBOOK_YN = 'Y' THEN
           x_csm_loan_levels_tbl(l_loan_level_counter).orig_contract_line_id := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).orig_contract_line_id;
        END IF;

        x_csm_loan_levels_tbl(l_loan_level_counter).level_index_number	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).level_index_number + 1;
        x_csm_loan_levels_tbl(l_loan_level_counter).level_type	:= G_SFE_LEVEL_PAYMENT;
        x_csm_loan_levels_tbl(l_loan_level_counter).number_of_periods := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).number_of_periods;
        x_csm_loan_levels_tbl(l_loan_level_counter).amount	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).amount;
        --x_csm_loan_levels_tbl(l_loan_level_counter).lock_level_step  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).lock_level_step;
		x_csm_loan_levels_tbl(l_loan_level_counter).lock_level_step  := 'AMOUNT';
        --l_csm_loan_levels_tbl(l_loan_level_counter).rate	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).rate;
        x_csm_loan_levels_tbl(l_loan_level_counter).period	:= x_csm_periodic_expenses_tbl(l_periodic_expense_counter).period;
        x_csm_loan_levels_tbl(l_loan_level_counter).advance_or_arrears  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).advance_or_arrears;
        x_csm_loan_levels_tbl(l_loan_level_counter).income_or_expense  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).income_or_expense;
        x_csm_loan_levels_tbl(l_loan_level_counter).structure := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).structure;
        x_csm_loan_levels_tbl(l_loan_level_counter).query_level_yn  := x_csm_periodic_expenses_tbl(l_periodic_expense_counter).query_level_yn;
        -- delete processed rows from periodic expense table
        x_csm_periodic_expenses_tbl.delete(l_periodic_expense_counter);
      END IF;

      IF l_periodic_expense_counter = l_periodic_expense_count then
       EXIT;
      ELSE
       l_periodic_expense_counter := x_csm_periodic_expenses_tbl.next(l_periodic_expense_counter);

      END  IF;
     End loop;

     -- delete processed rows from one off fee
     x_csm_one_off_fee_tbl.DELETE(i);
     END IF;
   END LOOP;
   IF (l_rec_count > 0) THEN

   -- adjust the indices for one off AND perodic expence tables.
   adjust_index_one_off_fee(x_csm_one_off_fee_tbl);
   adjust_index_periodic_expense(x_csm_periodic_expenses_tbl);

   END IF;
   x_return_status := l_return_status;

   EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN

		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_finance_fee_for_loan;

  PROCEDURE Update_Pricing_Param (
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
	   ,p_trans_id                          IN  NUMBER
	   ,x_sif_id                            OUT NOCOPY NUMBER
	   ,x_khr_id                            OUT NOCOPY NUMBER
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
      )
	  IS

	CURSOR update_sif_id_csr(p_trans_id NUMBER)
	IS
	SELECT id, khr_id
	FROM okl_stream_interfaces
	WHERE transaction_number = p_trans_id;

	l_sif_id NUMBER;
	l_khr_id NUMBER;
  BEGIN
    x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

    OPEN update_sif_id_csr(p_trans_id);
	FETCH update_sif_id_csr into l_sif_id, l_khr_id;
    IF update_sif_id_csr%NOTFOUND THEN
      okl_api.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'Transaction Number Not Found');

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	CLOSE update_sif_id_csr;

	IF (l_sif_id IS NOT NULL) AND (l_khr_id IS NOT NULL) THEN
	  UPDATE OKL_SIF_PRICING_PARAMS
	  SET SIF_ID = l_sif_id
	  WHERE SIF_ID IS NULL AND KHR_ID = l_khr_id;
	  x_sif_id := l_sif_id;
	  x_khr_id := l_khr_id;
	END IF;

    EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
       IF update_sif_id_csr%ISOPEN THEN
	      CLOSE update_sif_id_csr;
	   END IF;
       x_return_status := Okl_Api.G_RET_STS_ERROR ;

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
       IF update_sif_id_csr%ISOPEN THEN
	      CLOSE update_sif_id_csr;
	   END IF;
       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
       IF update_sif_id_csr%ISOPEN THEN
	      CLOSE update_sif_id_csr;
	   END IF;
       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;


  END;




  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Lease_Book
  ---------------------------------------------------------------------------
  PROCEDURE Create_Streams_Lease_Book (

        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE

       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header					IN 	csm_lease_rec_type
       ,p_csm_one_off_fee_tbl						IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl				IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl						IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl				IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     				IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   						OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
      )
  IS
    	l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Lease_Book';
  	lp_sifv_rec					sifv_rec_type;
  	lx_sifv_rec					sifv_rec_type;
  	lx_sifv_status_rec			sifv_rec_type;
  	lp_sfev_rent_tbl			sfev_tbl_type;

  	lx_sfev_rent_tbl			sfev_tbl_type;
  	lp_sfev_one_off_tbl			sfev_tbl_type;
  	lx_sfev_one_off_tbl			sfev_tbl_type;

  	lp_sfev_periodic_tbl		sfev_tbl_type;
  	lx_sfev_periodic_tbl		sfev_tbl_type;
  	lp_siyv_tbl					siyv_tbl_type;
  	lx_siyv_tbl 				siyv_tbl_type;
  	lp_sitv_tbl					sitv_tbl_type;
  	lx_sitv_tbl 				sitv_tbl_type;
	 -- new structures for finance fee

        x_csm_one_off_fee_tbl           csm_one_off_fee_tbl_type;
        x_csm_periodic_expenses_tbl     csm_periodic_expenses_tbl_type;
    	l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_api_version     CONSTANT NUMBER := 1;
	l_sif_id NUMBER;
	l_khr_id NUMBER;
	l_pending BOOLEAN := FALSE;
	  ---------------------------------------------------------------------------
	  -- FUNCTION pending_request_exists
	  -- Checks if any request is pending for the specified ContractNumber
	  ---------------------------------------------------------------------------
	  FUNCTION pending_request_exists(
		p_khr_id	IN 	NUMBER
	--smahapat 11/10/02 multi-gaap - addition
	   ,p_purpose_code IN OKL_STREAM_INTERFACES_V.PURPOSE_CODE%TYPE
	--smahapat addition end
	   ,x_return_status                		OUT NOCOPY VARCHAR2
	  ) RETURN BOOLEAN
	  IS
		CURSOR l_okl_sif_status_csr(p_khr_id IN OKL_STREAM_INTERFACES_V.KHR_ID%TYPE) IS
		SELECT '1' FROM dual
		WHERE EXISTS
		(SELECT '1'
		 FROM OKL_STREAM_INTERFACES
		 WHERE khr_id = p_khr_id
		 AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED)
		);
	--smahapat 11/10/02 multi-gaap - addition
		CURSOR l_okl_sif_rpt_status_csr(p_khr_id IN OKL_STREAM_INTERFACES_V.KHR_ID%TYPE) IS

		SELECT '1' FROM dual
		WHERE EXISTS
		(SELECT '1'
		 FROM OKL_STREAM_INTERFACES
		 WHERE khr_id = p_khr_id AND purpose_code = G_PURPOSE_CODE_REPORT
		 AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED)
		);
	--smahapat addition end
	    l_pending BOOLEAN DEFAULT FALSE;
	  BEGIN
	    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
	    IF p_khr_id IS NOT NULL THEN
	--smahapat 11/10/02 multi-gaap - addition
		  IF p_purpose_code IS NOT NULL AND p_purpose_code = G_PURPOSE_CODE_REPORT THEN
	        FOR l_sif_rpt_csr IN l_okl_sif_rpt_status_csr(p_khr_id)
	        LOOP
	            l_pending := TRUE;
	        END LOOP;
		  ELSE
	--smahapat addition end
	        FOR l_sif_csr IN l_okl_sif_status_csr(p_khr_id)
	        LOOP
	            l_pending := TRUE;

	        END LOOP;
		  END IF; 	--smahapat 11/10/02 multi-gaap - addition
	    END IF;
	    RETURN(l_pending);
	  EXCEPTION
		WHEN OTHERS THEN
			-- store SQL error message on message stack
			Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
								p_msg_name	=>	G_UNEXPECTED_ERROR,
								p_token1	=>	G_SQLCODE_TOKEN,

								p_token1_value	=>	SQLCODE,
								p_token2	=>	G_SQLERRM_TOKEN,
								p_token2_value	=>	SQLERRM);

		   x_return_status := G_RET_STS_UNEXP_ERROR;
		   RETURN NULL;
	  END pending_request_exists;
  BEGIN
     --Added by kthiruva for Logging Purposes
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside procedure create_streams_lease_book');
     END IF;
     l_return_status := G_RET_STS_SUCCESS;
	 initialize;


     -- Check for any pending request for this Contract and
	 -- Error out if there does exist a request that is not completed
	 l_pending := pending_request_exists(p_khr_id => p_csm_lease_header.khr_id
	                       --smahapat 11/10/02 multi-gaap - addition
	                        ,p_purpose_code       => p_csm_lease_header.purpose_code
	 	                    ,x_return_status		=> l_return_status);
          --Added by kthiruva
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to pending_request_exists, the return status is :'||l_return_status);
          END IF;
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	 IF(l_pending) THEN
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
				    p_msg_name	=>	G_OKL_CSM_PENDING

							);
		l_return_status := G_RET_STS_ERROR;
        RAISE G_EXCEPTION_ERROR;
	 ELSE
        --Added by kthiruva for Debugging
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Prior to the call to assign_header_details');
        END IF;
		/* assign Transaction Header Data */
	 	lp_sifv_rec := assign_header_details( p_lease_header_rec	=> p_csm_lease_header
	 					     ,x_return_status		=> l_return_status
	 					     );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_header_details, the return status is :'||l_return_status);
          END IF;
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	   	-- Insert Transaction Header Data

-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;

	 	Okl_Stream_Interfaces_Pub.insert_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	 	       ,p_sifv_rec => lp_sifv_rec
	 	       ,x_sifv_rec => lx_sifv_rec);
        --Added by kthiruva for Debugging
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Stream_Interfaces_Pub.insert_stream_interfaces, return status is:'||l_return_status);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The transaction number of the request is :'||lx_sifv_rec.transaction_number);
        END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;

-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;
	 	-- Get the Interface Header ID

	     l_sif_id := lx_sifv_rec.id;
	 	/* Assign line Level Transaction Details*/

		IF p_csm_line_details_tbl IS NOT NULL THEN
	 		insert_asset_lines(p_api_version				=> p_api_version,
	 							p_init_msg_list				=> p_init_msg_list,
	 							p_sif_id					=> l_sif_id,
	 							p_csm_line_details_tbl 			=> p_csm_line_details_tbl,
	 							x_return_status				=> l_return_status,
	 							x_msg_count					=> x_msg_count,
	 							x_msg_data               	=> x_msg_data);
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to insert_asset_lines, the return status is :'||l_return_status);
            END IF;

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;


	 	END IF;

		          /*Create Finance fee for lease booking*/
	 	IF p_csm_one_off_fee_tbl IS NOT NULL and p_csm_periodic_expenses_tbl IS NOT NULL THEN

		insert_finance_fee_for_lease(p_api_version				=> p_api_version,
	 				   p_init_msg_list				=> p_init_msg_list,
	 				   p_sif_id					=> l_sif_id,
	 				   p_csm_one_off_fee_tbl 			=> p_csm_one_off_fee_tbl,
					   p_csm_periodic_expenses_tbl                  => p_csm_periodic_expenses_tbl,

	 				   x_csm_one_off_fee_tbl 			=> x_csm_one_off_fee_tbl,
					   x_csm_periodic_expenses_tbl                  => x_csm_periodic_expenses_tbl,
	 				   x_return_status				=> l_return_status,
	 				   x_msg_count					=> x_msg_count,
	 				   x_msg_data               			=> x_msg_data);
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to insert_finance_fee_for_lease, the return status is :'||l_return_status);
            END IF;


	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;

	 	/* Assign Rent Details*/
	 	IF p_rents_tbl IS NOT NULL THEN
	     	lp_sfev_rent_tbl := assign_rent_details(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_expenses_tbl	=> p_rents_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_rent_details, the return status is :'||l_return_status);
            END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		     	-- Insert Rent Details
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN

    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;


	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_rent_tbl
	     	       ,x_sfev_tbl => lx_sfev_rent_tbl);
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Fees_Pub.insert_sif_fees, the return status is :'||l_return_status);
            END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees


	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;

	 	/* Assign One-Off Fee Details */

/*
FOR i IN  x_csm_one_off_fee_tbl.FIRST..x_csm_one_off_fee_tbl.LAST LOOP
  IF x_csm_one_off_fee_tbl(i).kle_asset_id IS NOT NULL OR
     x_csm_one_off_fee_tbl(i).kle_asset_id <> OKL_API.G_MISS_NUM THEN
  END IF;
  IF x_csm_one_off_fee_tbl(i).kle_fee_id IS NOT NULL OR
     x_csm_one_off_fee_tbl(i).kle_fee_id <> OKL_API.G_MISS_NUM THEN
  END IF;
  IF x_csm_one_off_fee_tbl(i).other_type_id IS NOT NULL OR
     x_csm_one_off_fee_tbl(i).other_type_id <> OKL_API.G_MISS_NUM THEN
  END IF;
END LOOP;
*/

	 	IF p_csm_one_off_fee_tbl IS NOT NULL THEN

	     	lp_sfev_one_off_tbl := assign_one_off_fees(p_sif_id				=> l_sif_id,
	     						   p_csm_one_off_fee_tbl	=> x_csm_one_off_fee_tbl,
	 					           x_return_status		=> l_return_status
	 					     );
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_one_off_fees, the return status is :'||l_return_status);
            END IF;


		  IF l_return_status = G_RET_STS_ERROR THEN

			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

   	Okl_Sif_Fees_Pub.insert_sif_fees(

	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_one_off_tbl
	     	       ,x_sfev_tbl => lx_sfev_one_off_tbl);
    --Added by kthiruva for Debugging
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Fees_Pub.insert_sif_fees, the return status is :'||l_return_status);
    END IF;



  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;

	 	/* Assign Periodic Fee Details*/
	 	IF p_csm_periodic_expenses_tbl IS NOT NULL THEN

	     	lp_sfev_periodic_tbl := assign_periodic_expenses(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_expenses_tbl	=> x_csm_periodic_expenses_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_periodic_expenses, the return status is :'||l_return_status);
            END IF;


		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;

		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version

	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_periodic_tbl
	     	       ,x_sfev_tbl => lx_sfev_periodic_tbl);
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Fees_Pub.insert_sif_fees, the return status is :'||l_return_status);
            END IF;


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Yield Data */
	 	IF p_csm_yields_tbl IS NOT NULL THEN
	     	lp_siyv_tbl := assign_yield_details(p_sif_id		=> l_sif_id,
	     					    p_csm_yields_tbl	=> p_csm_yields_tbl
	 					     ,x_return_status	=> l_return_status

	 					     );
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_yield_details, the return status is :'||l_return_status);
            END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;

		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	     	-- Insert Yield Data corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
     	Okl_Sif_Yields_Pub.insert_sif_yields(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_siyv_tbl => lp_siyv_tbl

	     	       ,x_siyv_tbl => lx_siyv_tbl);
        --Added by kthiruva for Debugging
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Yields_Pub.insert_sif_yields, the return status is :'||l_return_status);
        END IF;


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;

-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign StreamTypes needed for this Transaction */

	 	IF p_csm_stream_types_tbl IS NOT NULL THEN
			lp_sitv_tbl := assign_stream_types(p_sif_id					=> l_sif_id,
							    p_csm_stream_types_tbl		=> p_csm_stream_types_tbl
	 					     ,x_return_status		=> l_return_status
	 					     );
           --Added by kthiruva for Debugging
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_stream_types, the return status is :'||l_return_status);
           END IF;


		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		  -- Insert StreamTypes corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;

			Okl_Sif_Stream_Types_Pub.insert_sif_stream_types(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list

	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
			       ,p_sitv_tbl => lp_sitv_tbl
			       ,x_sitv_tbl => lx_sitv_tbl);
           --Added by kthiruva for Debugging
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Stream_Types_Pub.insert_sif_stream_types, the return status is :'||l_return_status);
           END IF;



  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
	 	END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;


  Update_Pricing_Param (
        p_api_version                  		=> p_api_version
       ,p_init_msg_list                		=> p_init_msg_list
	   ,p_trans_id                          => lx_sifv_rec.transaction_number
	   ,x_sif_id                            => l_sif_id
	   ,x_khr_id                            => l_khr_id
       ,x_return_status                		=> l_return_status
       ,x_msg_count                    		=> x_msg_count
       ,x_msg_data                     		=> x_msg_data
      );
   --Added by kthiruva for Debugging
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Update_Pricing_Param, the return status is :'||l_return_status);
   END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF l_return_status = G_RET_STS_ERROR THEN
	RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;



	 	IF p_skip_prc_engine <> G_TRUE THEN
             --Added by kthiruva for Debugging
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The value of p_skip_prc_engine is :'||p_skip_prc_engine);
             END IF;
             Invoke_Pricing_Engine(
			                        p_api_version				=> p_api_version,
									p_init_msg_list				=> p_init_msg_list,
									p_sifv_rec					=> lx_sifv_rec,
									x_sifv_rec					=> lx_sifv_status_rec,
									x_return_status				=> l_return_status,
									x_msg_count					=> x_msg_count,
									x_msg_data               	=> x_msg_data);
            --Added by kthiruva for Debugging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Invoke_Pricing_Engine, the return status is :'||l_return_status);
            END IF;

			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;

			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
		    x_trans_id     := lx_sifv_status_rec.transaction_number;

    	 	   x_trans_status := lx_sifv_status_rec.sis_code;
		ELSE
		    x_trans_id     := lx_sifv_rec.transaction_number;
    	 	    x_trans_status := lx_sifv_rec.sis_code;
	 	END IF;
 	END IF;
	x_return_status := l_return_status;

  EXCEPTION

	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;

  END Create_Streams_Lease_Book;

  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Loan_Book
  ---------------------------------------------------------------------------
  PROCEDURE Create_Streams_Loan_Book (

        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header			IN  csm_loan_rec_type
 -- 04/21/2002
       ,p_csm_loan_lines_tbl			IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl			IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl		IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl	IN  csm_periodic_expenses_tbl_type
 -- end,04/21/2002
       ,p_csm_yields_tbl			IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl		IN  csm_stream_types_tbl_type
       ,x_trans_id	   			    OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       )
  IS
    	l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Loan_Book';
        l_api_version     CONSTANT NUMBER := 1;
  	lp_sifv_rec			          sifv_rec_type;
  	lx_sifv_rec			          sifv_rec_type;
  	lx_sifv_status_rec			sifv_rec_type;
  	lp_sfev_loan_levels_tbl		      sfev_tbl_type;

  	lx_sfev_loan_levels_tbl		      sfev_tbl_type;
  	lp_sfev_one_off_tbl			  sfev_tbl_type;
  	lx_sfev_one_off_tbl			  sfev_tbl_type;
  	lp_sfev_periodic_expenses_tbl sfev_tbl_type;
  	lx_sfev_periodic_expenses_tbl sfev_tbl_type;
  	lp_sfev_periodic_incomes_tbl  sfev_tbl_type;
  	lx_sfev_periodic_incomes_tbl  sfev_tbl_type;
  	lp_siyv_tbl		              siyv_tbl_type;

  	lx_siyv_tbl 		          siyv_tbl_type;
  	lp_sitv_tbl			          sitv_tbl_type;
  	lx_sitv_tbl 			      sitv_tbl_type;
	    -- new structures for finance fee

        x_csm_one_off_fee_tbl           csm_one_off_fee_tbl_type;
        x_csm_periodic_expenses_tbl     csm_periodic_expenses_tbl_type;
        x_csm_loan_lines_tbl       csm_loan_line_tbl_type;
        x_csm_loan_levels_tbl      csm_loan_level_tbl_type;
	l_sif_id NUMBER;
	l_khr_id NUMBER;

	l_pending BOOLEAN := FALSE;
   	l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	  ---------------------------------------------------------------------------
	  -- FUNCTION pending_request_exists
	  -- Checks if any request is pending for the specified ContractNumber
	  ---------------------------------------------------------------------------
	  FUNCTION pending_request_exists(
        p_khr_id IN 	NUMBER
	--smahapat 11/10/02 multi-gaap - addition
	   ,p_purpose_code IN OKL_STREAM_INTERFACES_V.PURPOSE_CODE%TYPE
	--smahapat addition end
	   ,x_return_status                		OUT NOCOPY VARCHAR2
	  ) RETURN BOOLEAN
	  IS
	      CURSOR l_okl_sif_status_csr(p_khr_id IN OKL_STREAM_INTERFACES_V.KHR_ID%TYPE) IS
	      SELECT '1' FROM dual
	      WHERE EXISTS
	      (SELECT '1'
	       FROM OKL_STREAM_INTERFACES
	       WHERE khr_id = p_khr_id
	       AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED)
	      );
	--smahapat 11/10/02 multi-gaap - addition


		CURSOR l_okl_sif_rpt_status_csr(p_khr_id IN OKL_STREAM_INTERFACES_V.KHR_ID%TYPE) IS
		SELECT '1' FROM dual
		WHERE EXISTS
		(SELECT '1'
		 FROM OKL_STREAM_INTERFACES
		 WHERE khr_id = p_khr_id AND purpose_code = G_PURPOSE_CODE_REPORT
		 AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED)
		);
	--smahapat addition end
	    l_pending BOOLEAN DEFAULT FALSE;
	  BEGIN
	    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
	    IF p_khr_id IS NOT NULL THEN

	--smahapat 11/10/02 multi-gaap - addition
		  IF p_purpose_code IS NOT NULL AND p_purpose_code = G_PURPOSE_CODE_REPORT THEN
	        FOR l_sif_rpt_csr IN l_okl_sif_rpt_status_csr(p_khr_id)
	        LOOP
	            l_pending := TRUE;
	        END LOOP;
		  ELSE
	--smahapat addition end
	        FOR l_sif_csr IN l_okl_sif_status_csr(p_khr_id)
	        LOOP
	            l_pending := TRUE;
	        END LOOP;
		  END IF; 	--smahapat 11/10/02 multi-gaap - addition
	    END IF;
	    RETURN(l_pending);
	  EXCEPTION

		WHEN OTHERS THEN
			-- store SQL error message on message stack
			Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
								p_msg_name	=>	G_UNEXPECTED_ERROR,
								p_token1	=>	G_SQLCODE_TOKEN,
								p_token1_value	=>	SQLCODE,
								p_token2	=>	G_SQLERRM_TOKEN,
								p_token2_value	=>	SQLERRM);
		   x_return_status := G_RET_STS_UNEXP_ERROR;
		   RETURN NULL;
	  END pending_request_exists;
  BEGIN
    --Added by kthiruva for Debug Logging
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside the call to create_Streams_loan_book');
    END IF;

    l_return_status := G_RET_STS_SUCCESS;
	initialize;
        -- Check for any pending request for this Contract and
	 -- Error out if there does exist a request that is not completed
	 l_pending := pending_request_exists(p_khr_id => p_csm_loan_header.khr_id
	                       --smahapat 11/10/02 multi-gaap - addition
	                        ,p_purpose_code       => p_csm_loan_header.purpose_code
	 	                    ,x_return_status		=> l_return_status);
    --Added by kthiruva for Debug Logging
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to pending_request_exists,return status is :'||l_return_status);
    END IF;
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	 IF(l_pending) THEN

	    Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
				    p_msg_name	=>	G_OKL_CSM_PENDING
							);
	    l_return_status := G_RET_STS_ERROR;
            RAISE G_EXCEPTION_ERROR;
	 ELSE
		/* assign Transaction Header Data */
	 	lp_sifv_rec := assign_header_details( p_loan_header_rec	=> p_csm_loan_header
	 					     ,x_return_status		=> l_return_status

	 					     );
        --Added by kthiruva for Debug Logging
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_header_details,return status is :'||l_return_status);
        END IF;
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		  END IF;
	   	-- Insert Transaction Header Data
-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;
	 	Okl_Stream_Interfaces_Pub.insert_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	 	       ,p_sifv_rec => lp_sifv_rec
	 	       ,x_sifv_rec => lx_sifv_rec);
        --Added by kthiruva for Debug Logging
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Stream_Interfaces_Pub.insert_stream_interfaces,return status is :'||l_return_status);
        END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;

  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;
	 	-- Get the Interface Header ID
	     l_sif_id := lx_sifv_rec.id;
-- 04/21/2002

   IF p_csm_one_off_fee_tbl IS NOT NULL and p_csm_periodic_expenses_tbl IS NOT NULL THEN

		insert_finance_fee_for_loan(p_api_version			=> p_api_version,
	 				   p_init_msg_list			=> p_init_msg_list,
	 				   p_sif_id				=> l_sif_id,
	 				   p_csm_one_off_fee_tbl 		=> p_csm_one_off_fee_tbl,
					   p_csm_periodic_expenses_tbl          => p_csm_periodic_expenses_tbl,
					   p_csm_loan_lines_tbl 		=> p_csm_loan_lines_tbl, --input param

					   p_csm_loan_levels_tbl                => p_csm_loan_levels_tbl,
	 				   x_csm_one_off_fee_tbl 		=> x_csm_one_off_fee_tbl,
					   x_csm_periodic_expenses_tbl          => x_csm_periodic_expenses_tbl,
					   x_csm_loan_lines_tbl 		=> x_csm_loan_lines_tbl, --output param
					   x_csm_loan_levels_tbl                => x_csm_loan_levels_tbl,
	 				   x_return_status			=> l_return_status,
	 				   x_msg_count				=> x_msg_count,
	 				   x_msg_data               		=> x_msg_data);
        --Added by kthiruva for Debug Logging
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to insert_finance_fee_for_loan,return status is :'||l_return_status);
        END IF;

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;

	 	END IF;

	 	/* Assign Loan Line Details*/
	 	IF p_csm_loan_lines_tbl IS NOT NULL THEN
	 		insert_loan_lines(p_api_version				=> p_api_version,
	 					    	p_init_msg_list				=> p_init_msg_list,
	 							p_sif_id					=> l_sif_id,
	 							p_csm_loan_lines_tbl 			=> x_csm_loan_lines_tbl,
	 							x_return_status				=> l_return_status,
	 							x_msg_count					=> x_msg_count,
	 							x_msg_data               	=> x_msg_data);
           --Added by kthiruva for Debug Logging
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to insert_loan_lines,return status is :'||l_return_status);
           END IF;

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Loan Levels*/
	 	IF p_csm_loan_levels_tbl IS NOT NULL THEN
	     	lp_sfev_loan_levels_tbl := assign_loan_levels(p_sif_id			=> l_sif_id,
	     					      p_csm_loan_levels_tbl	=> x_csm_loan_levels_tbl,
	 					      x_return_status		=> l_return_status
	 					     );
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_loan_levels,return status is :'||l_return_status);
            END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN

			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		     	-- Insert Loan Levels
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;

  END IF;

	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count

	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_loan_levels_tbl
	     	       ,x_sfev_tbl => lx_sfev_loan_levels_tbl);
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Fees_Pub.insert_sif_fees,return status is :'||l_return_status);
            END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign One-Off Fee Details */
	 	IF p_csm_one_off_fee_tbl IS NOT NULL THEN
	     	  lp_sfev_one_off_tbl := assign_one_off_fees(p_sif_id				=> l_sif_id,
	     						   p_csm_one_off_fee_tbl	=> x_csm_one_off_fee_tbl,
	 					           x_return_status		=> l_return_status

	 					     );
              --Added by kthiruva for Debug Logging
              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_one_off_fees,return status is :'||l_return_status);
              END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');

    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_one_off_tbl
	     	       ,x_sfev_tbl => lx_sfev_one_off_tbl);
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Fees_Pub.insert_sif_fees,return status is :'||l_return_status);
            END IF;


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;

	 	END IF;
	 	/* Assign Periodic Expense Details*/
	 	IF p_csm_periodic_expenses_tbl IS NOT NULL THEN
	     	lp_sfev_periodic_expenses_tbl := assign_periodic_expenses(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_expenses_tbl	=> x_csm_periodic_expenses_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_periodic_expenses,return status is :'||l_return_status);
            END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_periodic_expenses_tbl
	     	       ,x_sfev_tbl => lx_sfev_periodic_expenses_tbl);
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Fees_Pub.insert_sif_fees,return status is :'||l_return_status);
            END IF;


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Periodic Income Details*

	 	IF p_csm_periodic_incomes_tbl IS NOT NULL THEN
	     	lp_sfev_periodic_incomes_tbl := assign_periodic_incomes(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_incomes_tbl	=> p_csm_periodic_incomes_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;

		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	     	OKL_SIF_FEES_PUB.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_periodic_incomes_tbl
	     	       ,x_sfev_tbl => lx_sfev_periodic_incomes_tbl);
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;

	 	END IF;
		*/
-- end, 04/21/2002
	 	/* Assign Yield Data */
	 	IF p_csm_yields_tbl IS NOT NULL THEN
	     	lp_siyv_tbl := assign_yield_details(p_sif_id		=> l_sif_id,
	     					    p_csm_yields_tbl	=> p_csm_yields_tbl
	 					     ,x_return_status	=> l_return_status
	 					     );
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_yield_details,return status is :'||l_return_status);
            END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	     	-- Insert Yield Data corresponding to this Transaction

-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
	     	Okl_Sif_Yields_Pub.insert_sif_yields(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_siyv_tbl => lp_siyv_tbl
	     	       ,x_siyv_tbl => lx_siyv_tbl);
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Yields_Pub.insert_sif_yields,return status is :'||l_return_status);
            END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');

    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign StreamTypes needed for this Transaction */
	 	IF p_csm_stream_types_tbl IS NOT NULL THEN
			lp_sitv_tbl := assign_stream_types(p_sif_id					=> l_sif_id,
							    p_csm_stream_types_tbl		=> p_csm_stream_types_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to assign_stream_types,return status is :'||l_return_status);
            END IF;

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		  -- Insert StreamTypes corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
			Okl_Sif_Stream_Types_Pub.insert_sif_stream_types(
	 	        p_api_version => p_api_version

	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
			       ,p_sitv_tbl => lp_sitv_tbl
			       ,x_sitv_tbl => lx_sitv_tbl);
            --Added by kthiruva for Debug Logging
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Okl_Sif_Stream_Types_Pub.insert_sif_stream_types,return status is :'||l_return_status);
            END IF;


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types

			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
	 	END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;


  Update_Pricing_Param (
        p_api_version                  		=> p_api_version
       ,p_init_msg_list                		=> p_init_msg_list
	   ,p_trans_id                          => lx_sifv_rec.transaction_number
	   ,x_sif_id                            => l_sif_id
	   ,x_khr_id                            => l_khr_id
       ,x_return_status                		=> l_return_status
       ,x_msg_count                    		=> x_msg_count
       ,x_msg_data                     		=> x_msg_data
      );
   --Added by kthiruva for Debug Logging
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Update_Pricing_Param,return status is :'||l_return_status);
   END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF l_return_status = G_RET_STS_ERROR THEN
	RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

	 	IF p_skip_prc_engine <> G_TRUE THEN
             --Added by kthiruva for Debug Logging
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'The value of p_skip_prc_engine is '||p_skip_prc_engine);
             END IF;
             Invoke_Pricing_Engine(

			                        p_api_version				=> p_api_version,
									p_init_msg_list				=> p_init_msg_list,
									p_sifv_rec					=> lx_sifv_rec,
									x_sifv_rec					=> lx_sifv_status_rec,
									x_return_status				=> l_return_status,
									x_msg_count					=> x_msg_count,
									x_msg_data               	=> x_msg_data);
             --Added by kthiruva for Debug Logging
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After the call to Invoke_Pricing_Engine,return status is :'||l_return_status);
             END IF;

			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;

		    x_trans_id     := lx_sifv_status_rec.transaction_number;
    	 	   x_trans_status := lx_sifv_status_rec.sis_code;
		ELSE
		    x_trans_id     := lx_sifv_rec.transaction_number;
    	 	    x_trans_status := lx_sifv_rec.sis_code;
	 	END IF;
 	END IF;
	x_return_status := l_return_status;
  EXCEPTION
  	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,

							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
  END Create_Streams_Loan_Book;
   PROCEDURE Invoke_Pricing_Engine(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_sifv_rec							IN  sifv_rec_type
       ,x_sifv_rec							OUT NOCOPY sifv_rec_type
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
   )
   IS
     lp_sifv_rec sifv_rec_type;

     lx_sifv_rec sifv_rec_type;
     l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Invoke_Pricing_Engine';
	 l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

	 l_api_version     CONSTANT NUMBER := 1;
	 l_trx_sub_type VARCHAR2(20);
   BEGIN
        lp_sifv_rec := p_sifv_rec;
		-- get the deal type / trx sub type to be passed to the invoke pricing engine api
		l_trx_sub_type := lp_sifv_rec.deal_type;
    	-- Set Status before Calling PrcEngine API
		lp_sifv_rec.date_processed := TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD
HH24MISS'), 'YYYYMMDD HH24MISS');
--srsreeni Bug5996152 start
--		lp_sifv_rec.sis_code :=	G_SIS_DATA_ENTERED;
		lp_sifv_rec.sis_code :=	G_SIS_PROCESSING_REQUEST;
--srsreeni Bug5996152 end
-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.update_stream_interfaces
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.update_stream_interfaces ');
    END;
  END IF;

	 	Okl_Stream_Interfaces_Pub.update_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data

	 	       ,p_sifv_rec => lp_sifv_rec
	 	       ,x_sifv_rec => lx_sifv_rec);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.update_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.update_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;

        lp_sifv_rec := lx_sifv_rec;
       	-- Call STTA Invocation API
-- Start of wraper code generated automatically by Debug code generator for Okl_Invoke_Pricing_Engine_Pub.generate_streams_st
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Invoke_Pricing_Engine_Pub.generate_streams_st ');
    END;
  END IF;

		Okl_Invoke_Pricing_Engine_Pub.generate_streams_st(

		                        p_api_version				=> p_api_version,
								p_init_msg_list				=> p_init_msg_list,
								p_xmlg_trx_type             => Okl_Invoke_Pricing_Engine_Pvt.G_XMLG_TRX_TYPE,
								p_xmlg_trx_sub_type         => l_trx_sub_type,
								p_sifv_rec					=> lp_sifv_rec,
								x_return_status				=> l_return_status,
								x_msg_count					=> x_msg_count,
								x_msg_data               	=> x_msg_data);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Invoke_Pricing_Engine_Pub.generate_streams_st ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Invoke_Pricing_Engine_Pub.generate_streams_st
		IF l_return_status = G_RET_STS_ERROR THEN
			RAISE G_EXCEPTION_ERROR;
		ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		END IF;
--srsreeni Bug 5996152 start
/*		lp_sifv_rec.date_processed := TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD
HH24MISS'), 'YYYYMMDD HH24MISS');
		lp_sifv_rec.sis_code :=	G_SIS_PROCESSING_REQUEST;
-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.update_stream_interfaces
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.update_stream_interfaces ');
    END;
  END IF;

	 	Okl_Stream_Interfaces_Pub.update_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count

	 	       ,x_msg_data => x_msg_data
	 	       ,p_sifv_rec => lp_sifv_rec
	 	       ,x_sifv_rec => lx_sifv_rec);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.update_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.update_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN

	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;*/
--srsreeni Bug5996152 ends
		x_sifv_rec := lx_sifv_rec;
		x_return_status := l_return_status;

    EXCEPTION
  	WHEN G_EXCEPTION_ERROR THEN

	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	END Invoke_Pricing_Engine;
  ---------------------------------------------------------------------------
  -- FUNCTION assign_target_details
  ---------------------------------------------------------------------------
  FUNCTION assign_target_details(
	p_sif_id	IN NUMBER ,
	p_csm_yields_tbl IN csm_yields_tbl_type,
        x_return_status                		OUT NOCOPY VARCHAR2
  ) RETURN siyv_tbl_type
  IS

	l_siyv_tbl siyv_tbl_type;
	i 	   NUMBER := 0;
	l_target_count NUMBER := 0;
  BEGIN
    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
    FOR i IN 1..p_csm_yields_tbl.COUNT
    LOOP
	l_siyv_tbl(i).sif_id 		:= p_sif_id;
	l_siyv_tbl(i).yield_name 	:= p_csm_yields_tbl(i).yield_name;
	l_siyv_tbl(i).method 		:= p_csm_yields_tbl(i).method;
	l_siyv_tbl(i).array_type 	:= p_csm_yields_tbl(i).array_type;
	l_siyv_tbl(i).roe_type 		:= p_csm_yields_tbl(i).roe_type;
	l_siyv_tbl(i).roe_base 		:= p_csm_yields_tbl(i).roe_base;
	l_siyv_tbl(i).compounded_method := p_csm_yields_tbl(i).compounded_method;

	l_siyv_tbl(i).nominal_yn 	:= p_csm_yields_tbl(i).nominal_yn;
	l_siyv_tbl(i).target_value 	:= p_csm_yields_tbl(i).target_value;
	l_siyv_tbl(i).pre_tax_yn 	:= p_csm_yields_tbl(i).pre_tax_yn;
	IF p_csm_yields_tbl(i).target_value IS NOT NULL AND
	   p_csm_yields_tbl(i).target_value <> OKC_API.G_MISS_NUM
	THEN
	   l_target_count := l_target_count + 1;
	END IF;
	IF l_target_count > 1 THEN
		OKL_API.SET_MESSAGE(p_app_name	=> G_APP_NAME,

		                    p_msg_name	=> G_OKL_MULTIPLE_TARGET_VALUES);
	       RAISE G_EXCEPTION_ERROR;
	END IF;
	-- mvasudev, 06/26/2002, sno

	l_siyv_tbl(i).siy_type 	:= p_csm_yields_tbl(i).siy_type;
	get_siy_index(p_csm_yields_tbl(i).siy_type || p_csm_yields_tbl(i).yield_name
	              ,l_siyv_tbl(i).index_number);
    END LOOP;
    RETURN l_siyv_tbl;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	   l_siyv_tbl.DELETE;
	   RETURN l_siyv_tbl;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_siyv_tbl.DELETE;
	   RETURN l_siyv_tbl;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	   l_siyv_tbl.DELETE;
	   RETURN l_siyv_tbl;
  END assign_target_details;
  PROCEDURE Create_Streams_Lease_Restr (
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE

       ,p_csm_lease_header			IN 	csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type

       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       )
  IS
    	l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Lease_Restr';
  	lp_sifv_rec					sifv_rec_type;
  	lx_sifv_rec					sifv_rec_type;
  	lx_sifv_status_rec			sifv_rec_type;
  	lp_sfev_rent_tbl			sfev_tbl_type;

  	lx_sfev_rent_tbl			sfev_tbl_type;
  	lp_sfev_one_off_tbl			sfev_tbl_type;
  	lx_sfev_one_off_tbl			sfev_tbl_type;
  	lp_sfev_periodic_tbl		sfev_tbl_type;
  	lx_sfev_periodic_tbl		sfev_tbl_type;
  	lp_siyv_tbl					siyv_tbl_type;
  	lx_siyv_tbl 				siyv_tbl_type;
  	lp_sitv_tbl					sitv_tbl_type;
  	lx_sitv_tbl 				sitv_tbl_type;
    	l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
	l_sif_id NUMBER;
	l_khr_id NUMBER;
	l_pending BOOLEAN := FALSE;
        l_pricing_engine okl_st_gen_tmpt_sets.pricing_engine%TYPE;
	   ---------------------------------------------------------------------------
	  -- FUNCTION pending_request_exists
	  -- Checks if any request is pending for the specified ContractNumber
	  ---------------------------------------------------------------------------
	  FUNCTION pending_request_exists(

            p_csm_lease_header	IN 	csm_lease_rec_type
	   ,x_return_status                		OUT NOCOPY VARCHAR2
	  ) RETURN BOOLEAN
	  IS
	      CURSOR l_okl_sif_status_csr(p_csm_lease_header csm_lease_rec_type) IS
	      SELECT '1' FROM dual
	      WHERE EXISTS
	      (SELECT '1'
	       FROM OKL_STREAM_INTERFACES
    	   WHERE jtot_object1_code = p_csm_lease_header.jtot_object1_code
		   AND object1_id1 = p_csm_lease_header.object1_id1
           AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST)
	      );
	    l_pending BOOLEAN DEFAULT FALSE;
	  BEGIN

	    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
	    --IF p_csm_lease_header IS NOT NULL THEN
	        FOR l_sif_csr IN l_okl_sif_status_csr(p_csm_lease_header)
	        LOOP
	            l_pending := TRUE;
	        END LOOP;
	    --END IF;
	    RETURN(l_pending);
	  EXCEPTION
		WHEN OTHERS THEN
			-- store SQL error message on message stack


			Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
								p_msg_name	=>	G_UNEXPECTED_ERROR,
								p_token1	=>	G_SQLCODE_TOKEN,
								p_token1_value	=>	SQLCODE,
								p_token2	=>	G_SQLERRM_TOKEN,
								p_token2_value	=>	SQLERRM);
		   x_return_status := G_RET_STS_UNEXP_ERROR;
		   RETURN NULL;
	  END pending_request_exists;
  BEGIN
     l_return_status := G_RET_STS_SUCCESS;
	 initialize;
     -- Check for any pending request for this Contract and
	 -- Error out if there does exist a request that is not completed
	 l_pending := pending_request_exists(p_csm_lease_header => p_csm_lease_header
	 	                    ,x_return_status		=> l_return_status);
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	 IF(l_pending) THEN
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
				    p_msg_name	=>	G_OKL_CSM_PENDING
							);
		l_return_status := G_RET_STS_ERROR;
        RAISE G_EXCEPTION_ERROR;
	 ELSE
              -- gboomina Bug 4659724 start
              OKL_STREAMS_UTIL.get_pricing_engine(
	                                     p_khr_id => p_csm_lease_header.khr_id,
	                                     x_pricing_engine => l_pricing_engine,
	                                     x_return_status => x_return_status);

	     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
	       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
	       raise OKL_API.G_EXCEPTION_ERROR;
	     END IF;

	     IF ( l_pricing_engine  = 'INTERNAL') THEN
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
		                    p_msg_name	=>	G_OKL_INT_PRIC_RESTR_NA
							);
		l_return_status := G_RET_STS_ERROR;
                RAISE G_EXCEPTION_ERROR;
	     END IF;
              -- gboomina Bug 4659724 end

	 	/* assign Transaction Header Data */
	 	lp_sifv_rec := assign_header_details( p_lease_header_rec	=> p_csm_lease_header
	 					     ,x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;

	   	-- Insert Transaction Header Data
-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;
	 	Okl_Stream_Interfaces_Pub.insert_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	 	       ,p_sifv_rec => lp_sifv_rec

	 	       ,x_sifv_rec => lx_sifv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;
	 	-- Get the Interface Header ID
	     l_sif_id := lx_sifv_rec.id;

	 	/* Assign line Level Transaction Details*/
	 	IF p_csm_line_details_tbl IS NOT NULL THEN
	 		insert_asset_lines(p_api_version				=> p_api_version,
	 							p_init_msg_list				=> p_init_msg_list,
	 							p_sif_id					=> l_sif_id,
	 							p_csm_line_details_tbl 			=> p_csm_line_details_tbl,
	 							x_return_status				=> l_return_status,
	 							x_msg_count					=> x_msg_count,
	 							x_msg_data               	=> x_msg_data);
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Rent Details*/

	 	IF p_rents_tbl IS NOT NULL THEN
	     	lp_sfev_rent_tbl := assign_rent_details(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_expenses_tbl	=> p_rents_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		  END IF;
		     	-- Insert Rent Details
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_rent_tbl
	     	       ,x_sfev_tbl => lx_sfev_rent_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign One-Off Fee Details */
	 	IF p_csm_one_off_fee_tbl IS NOT NULL THEN
	     	lp_sfev_one_off_tbl := assign_one_off_fees(p_sif_id				=> l_sif_id,
	     						   p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
	 					           x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		  END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_one_off_tbl
	     	       ,x_sfev_tbl => lx_sfev_one_off_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN

	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Periodic Fee Details*/
	 	IF p_csm_periodic_expenses_tbl IS NOT NULL THEN
	     	lp_sfev_periodic_tbl := assign_periodic_expenses(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
	 					        x_return_status		=> l_return_status

	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count

	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_periodic_tbl
	     	       ,x_sfev_tbl => lx_sfev_periodic_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');

    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;

	     	END IF;
	 	END IF;
	 	/* Assign Yield Data */
	 	IF p_csm_yields_tbl IS NOT NULL THEN
	     	lp_siyv_tbl := assign_target_details(p_sif_id		=> l_sif_id,
	     					    p_csm_yields_tbl	=> p_csm_yields_tbl
	 					     ,x_return_status	=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		END IF;
	     	-- Insert Yield Data corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
	     	Okl_Sif_Yields_Pub.insert_sif_yields(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_siyv_tbl => lp_siyv_tbl
	     	       ,x_siyv_tbl => lx_siyv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;

  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign StreamTypes needed for this Transaction */
	 	IF p_csm_stream_types_tbl IS NOT NULL THEN
			lp_sitv_tbl := assign_stream_types(p_sif_id					=> l_sif_id,
							    p_csm_stream_types_tbl		=> p_csm_stream_types_tbl
	 					     ,x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		  -- Insert StreamTypes corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
			Okl_Sif_Stream_Types_Pub.insert_sif_stream_types(

	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
			       ,p_sitv_tbl => lp_sitv_tbl

			       ,x_sitv_tbl => lx_sitv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
	 	END IF;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;


  Update_Pricing_Param (
        p_api_version                  		=> p_api_version
       ,p_init_msg_list                		=> p_init_msg_list
	   ,p_trans_id                          => lx_sifv_rec.transaction_number
	   ,x_sif_id                            => l_sif_id
	   ,x_khr_id                            => l_khr_id
       ,x_return_status                		=> l_return_status
       ,x_msg_count                    		=> x_msg_count
       ,x_msg_data                     		=> x_msg_data
      );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF l_return_status = G_RET_STS_ERROR THEN
	RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

	 	IF p_skip_prc_engine <> G_TRUE THEN
             Invoke_Pricing_Engine(
			                        p_api_version				=> p_api_version,
									p_init_msg_list				=> p_init_msg_list,
									p_sifv_rec					=> lx_sifv_rec,

									x_sifv_rec					=> lx_sifv_status_rec,
									x_return_status				=> l_return_status,
									x_msg_count					=> x_msg_count,

									x_msg_data               	=> x_msg_data);
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
		    x_trans_id     := lx_sifv_status_rec.transaction_number;
    	 	   x_trans_status := lx_sifv_status_rec.sis_code;
		ELSE
		    x_trans_id     := lx_sifv_rec.transaction_number;
    	 	    x_trans_status := lx_sifv_rec.sis_code;

	 	END IF;
 	END IF;
	x_return_status := l_return_status;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
  END Create_Streams_Lease_Restr;
-- This api is common for the Loan Restructures, Variable Interest Rate and Quote scenarios.
-- akjain 08-20-2002
  PROCEDURE Create_Streams_Loan_Restr (
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header			IN  csm_loan_rec_type
       ,p_csm_loan_lines_tbl			IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl			IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl		IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl	IN  csm_periodic_expenses_tbl_type

       ,p_csm_yields_tbl			IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl		IN  csm_stream_types_tbl_type
       ,x_trans_id	   			    OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
	)
   IS

    	l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Loan_Restr';
        l_api_version     CONSTANT NUMBER := 1;
  	lp_sifv_rec			          sifv_rec_type;
  	lx_sifv_rec			          sifv_rec_type;
  	lx_sifv_status_rec			sifv_rec_type;
  	lp_sfev_loan_levels_tbl		      sfev_tbl_type;
  	lx_sfev_loan_levels_tbl		      sfev_tbl_type;
  	lp_sfev_one_off_tbl			  sfev_tbl_type;
  	lx_sfev_one_off_tbl			  sfev_tbl_type;
  	lp_sfev_periodic_expenses_tbl sfev_tbl_type;
  	lx_sfev_periodic_expenses_tbl sfev_tbl_type;
  	lp_sfev_periodic_incomes_tbl  sfev_tbl_type;
  	lx_sfev_periodic_incomes_tbl  sfev_tbl_type;
  	lp_siyv_tbl		              siyv_tbl_type;
  	lx_siyv_tbl 		          siyv_tbl_type;
  	lp_sitv_tbl			          sitv_tbl_type;
  	lx_sitv_tbl 			      sitv_tbl_type;
	l_sif_id NUMBER;
	l_khr_id NUMBER;
	l_pending BOOLEAN := FALSE;
   	l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_pricing_engine okl_st_gen_tmpt_sets.pricing_engine%TYPE;

    -- new structures for financed fee
    x_csm_one_off_fee_tbl           csm_one_off_fee_tbl_type;
    x_csm_periodic_expenses_tbl     csm_periodic_expenses_tbl_type;
    x_csm_loan_lines_tbl       csm_loan_line_tbl_type;
    x_csm_loan_levels_tbl      csm_loan_level_tbl_type;
	  ---------------------------------------------------------------------------
	  -- FUNCTION pending_request_exists
	  -- Checks if any request is pending for the specified ContractNumber

	  ---------------------------------------------------------------------------
	  FUNCTION pending_request_exists(

	            p_csm_loan_header	IN 	csm_loan_rec_type
		   ,x_return_status                		OUT NOCOPY VARCHAR2
		  ) RETURN BOOLEAN
		  IS
		    CURSOR l_okl_sif_restr_status_csr(p_csm_loan_header csm_loan_rec_type) IS
		    SELECT '1' FROM dual
		    WHERE EXISTS
		    (SELECT '1'
		     FROM OKL_STREAM_INTERFACES
	    	 WHERE jtot_object1_code = p_csm_loan_header.jtot_object1_code
			 AND   object1_id1 = p_csm_loan_header.object1_id1
			 AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST)
		    );
			CURSOR l_okl_sif_quote_status_csr(p_csm_loan_header csm_loan_rec_type) IS
			SELECT '1' FROM dual
			WHERE EXISTS
			(SELECT '1'
			 FROM OKL_STREAM_INTERFACES
			 WHERE khr_id = p_csm_loan_header.khr_id


			 AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED)
			);
		    l_pending BOOLEAN DEFAULT FALSE;
		  BEGIN
		    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
		   IF p_csm_loan_header.orp_code IN( G_ORP_CODE_RESTRUCTURE_AM,G_ORP_CODE_RESTRUCTURE_CS,G_ORP_CODE_RENEWAL)
	       THEN
		        FOR l_sif_csr IN l_okl_sif_restr_status_csr(p_csm_loan_header)
		        LOOP
		            l_pending := TRUE;
		        END LOOP;
		   ELSIF p_csm_loan_header.orp_code IN (G_ORP_CODE_QUOTE,G_ORP_CODE_VARIABLE_INTEREST) THEN
		        FOR l_sif_csr IN l_okl_sif_quote_status_csr(p_csm_loan_header)
		        LOOP
		            l_pending := TRUE;

		        END LOOP;
	       END IF;
		    RETURN(l_pending);
		  EXCEPTION
			WHEN OTHERS THEN
				-- store SQL error message on message stack
				Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
									p_msg_name	=>	G_UNEXPECTED_ERROR,
									p_token1	=>	G_SQLCODE_TOKEN,
									p_token1_value	=>	SQLCODE,
									p_token2	=>	G_SQLERRM_TOKEN,
									p_token2_value	=>	SQLERRM);
			   x_return_status := G_RET_STS_UNEXP_ERROR;
			   RETURN NULL;
		  END pending_request_exists;
  BEGIN

     l_return_status := G_RET_STS_SUCCESS;
	 initialize;
        -- Check for any pending request for this Contract and
	 -- Error out if there does exist a request that is not completed
	 l_pending := pending_request_exists(p_csm_loan_header => p_csm_loan_header
	 	                    ,x_return_status		=> l_return_status);
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	 IF(l_pending) THEN
	    Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
				    p_msg_name	=>	G_OKL_CSM_PENDING
							);
	    l_return_status := G_RET_STS_ERROR;
            RAISE G_EXCEPTION_ERROR;
	 ELSE

              -- gboomina Bug 4659724 start
              OKL_STREAMS_UTIL.get_pricing_engine(
	                                     p_khr_id => p_csm_loan_header.khr_id,
	                                     x_pricing_engine => l_pricing_engine,
	                                     x_return_status => x_return_status);

	     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
	       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
	       raise OKL_API.G_EXCEPTION_ERROR;
	     END IF;

	     IF ( l_pricing_engine  = 'INTERNAL') THEN
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
		                    p_msg_name	=>	G_OKL_INT_PRIC_RESTR_NA
							);
		l_return_status := G_RET_STS_ERROR;
                RAISE G_EXCEPTION_ERROR;
	     END IF;
              -- gboomina Bug 4659724 end

		/* assign Transaction Header Data */
	 	lp_sifv_rec := assign_header_details( p_loan_header_rec	=> p_csm_loan_header
	 					     ,x_return_status		=> l_return_status
	 					     );

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	   	-- Insert Transaction Header Data
-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;

	 	Okl_Stream_Interfaces_Pub.insert_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data

	 	       ,p_sifv_rec => lp_sifv_rec

	 	       ,x_sifv_rec => lx_sifv_rec);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;
	 	-- Get the Interface Header ID
	     l_sif_id := lx_sifv_rec.id;

		 --smahapat for bug 4131347 start
   IF p_csm_one_off_fee_tbl IS NOT NULL and p_csm_periodic_expenses_tbl IS NOT NULL THEN

		insert_finance_fee_for_loan(p_api_version  => p_api_version,
	 				   p_init_msg_list			   => p_init_msg_list,
	 				   p_sif_id				       => l_sif_id,
	 				   p_csm_one_off_fee_tbl 	   => p_csm_one_off_fee_tbl,
					   p_csm_periodic_expenses_tbl => p_csm_periodic_expenses_tbl,
					   p_csm_loan_lines_tbl 	   => p_csm_loan_lines_tbl,
					   p_csm_loan_levels_tbl       => p_csm_loan_levels_tbl,
	 				   x_csm_one_off_fee_tbl 	   => x_csm_one_off_fee_tbl,
					   x_csm_periodic_expenses_tbl => x_csm_periodic_expenses_tbl,
					   x_csm_loan_lines_tbl 	   => x_csm_loan_lines_tbl,
					   x_csm_loan_levels_tbl       => x_csm_loan_levels_tbl,
	 				   x_return_status			   => l_return_status,
	 				   x_msg_count				   => x_msg_count,
	 				   x_msg_data                  => x_msg_data);
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;

	 	END IF;
		 --smahapat for bug 4131347 end

	 	IF p_csm_loan_lines_tbl IS NOT NULL THEN

	 	/* Assign Loan Line Details*/
	 		insert_loan_lines(p_api_version				    => p_api_version,
	 					    	p_init_msg_list				=> p_init_msg_list,
	 							p_sif_id					=> l_sif_id,
	 							p_csm_loan_lines_tbl 		=> x_csm_loan_lines_tbl,
								                                   --smahapat changed for bug 4131347
	 							x_return_status				=> l_return_status,
	 							x_msg_count					=> x_msg_count,
	 							x_msg_data               	=> x_msg_data);

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Loan Levels*/
	 	IF p_csm_loan_levels_tbl IS NOT NULL THEN


	     	lp_sfev_loan_levels_tbl := assign_loan_levels(p_sif_id			=> l_sif_id,
	     					      p_csm_loan_levels_tbl	=> x_csm_loan_levels_tbl,
								  p_object1_id1 => lx_sifv_rec.object1_id1,
	 					      x_return_status		=> l_return_status
	 					     );

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		     	-- Insert Loan Levels
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

        --Added by kthiruva for populating the method to be used by the Balance Tag
        -- In the case of Reamortization, we always balance for Payments
        -- In the caes of a Paydown we can balance for Term or for Payments.
        add_balance_information(x_sfev_tbl => lp_sfev_loan_levels_tbl,
                                x_return_status       => l_return_status );

		IF l_return_status = G_RET_STS_ERROR THEN
		   RAISE G_EXCEPTION_ERROR;
  	    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;
        --End of Changes



	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status

	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_loan_levels_tbl
	     	       ,x_sfev_tbl => lx_sfev_loan_levels_tbl);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;

	 	/* Assign One-Off Fee Details */
	 	IF p_csm_one_off_fee_tbl IS NOT NULL THEN
	     	  lp_sfev_one_off_tbl := assign_one_off_fees(p_sif_id				=> l_sif_id,
	     						   p_csm_one_off_fee_tbl	=> x_csm_one_off_fee_tbl,
	 					           x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list

	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_one_off_tbl
	     	       ,x_sfev_tbl => lx_sfev_one_off_tbl);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;

	     	END IF;
	 	END IF;
	 	/* Assign Periodic Expense Details*/
	 	IF p_csm_periodic_expenses_tbl IS NOT NULL THEN
	     	lp_sfev_periodic_expenses_tbl := assign_periodic_expenses(p_sif_id			=> l_sif_id,

	     						p_csm_periodic_expenses_tbl	=> x_csm_periodic_expenses_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list

	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_periodic_expenses_tbl
	     	       ,x_sfev_tbl => lx_sfev_periodic_expenses_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Yield Data */
	 	IF p_csm_yields_tbl IS NOT NULL THEN
	     	lp_siyv_tbl := assign_yield_details(p_sif_id		=> l_sif_id,

	     					    p_csm_yields_tbl	=> p_csm_yields_tbl
	 					     ,x_return_status	=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	     	-- Insert Yield Data corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
	     	Okl_Sif_Yields_Pub.insert_sif_yields(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data

	     	       ,p_siyv_tbl => lp_siyv_tbl
	     	       ,x_siyv_tbl => lx_siyv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign StreamTypes needed for this Transaction */
	 	IF p_csm_stream_types_tbl IS NOT NULL THEN
			lp_sitv_tbl := assign_stream_types(p_sif_id					=> l_sif_id,

							    p_csm_stream_types_tbl		=> p_csm_stream_types_tbl,
	 					        x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		  -- Insert StreamTypes corresponding to this Transaction

-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');

    END;
  END IF;
			Okl_Sif_Stream_Types_Pub.insert_sif_stream_types(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data

			       ,p_sitv_tbl => lp_sitv_tbl
			       ,x_sitv_tbl => lx_sitv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
	 	END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;


  Update_Pricing_Param (
        p_api_version                  		=> p_api_version
       ,p_init_msg_list                		=> p_init_msg_list
	   ,p_trans_id                          => lx_sifv_rec.transaction_number
	   ,x_sif_id                            => l_sif_id
	   ,x_khr_id                            => l_khr_id
       ,x_return_status                		=> l_return_status
       ,x_msg_count                    		=> x_msg_count
       ,x_msg_data                     		=> x_msg_data
      );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Update_Pricing_Param ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF l_return_status = G_RET_STS_ERROR THEN
	RAISE G_EXCEPTION_ERROR;
  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

	 	IF p_skip_prc_engine <> G_TRUE THEN
             Invoke_Pricing_Engine(
			                        p_api_version				=> p_api_version,
									p_init_msg_list				=> p_init_msg_list,

									p_sifv_rec					=> lx_sifv_rec,
									x_sifv_rec					=> lx_sifv_status_rec,
									x_return_status				=> l_return_status,
									x_msg_count					=> x_msg_count,
									x_msg_data               	=> x_msg_data);
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
		    x_trans_id     := lx_sifv_status_rec.transaction_number;
    	 	   x_trans_status := lx_sifv_status_rec.sis_code;
		ELSE
		    x_trans_id     := lx_sifv_rec.transaction_number;
    	 	    x_trans_status := lx_sifv_rec.sis_code;
	 	END IF;
 	END IF;

	x_return_status := l_return_status;
  EXCEPTION
  	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;
   END Create_Streams_Loan_Restr;
  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Lease_Quote
  ---------------------------------------------------------------------------
  PROCEDURE Create_Streams_Lease_Quote (
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header					IN 	csm_lease_rec_type
       ,p_csm_one_off_fee_tbl						IN  csm_one_off_fee_tbl_type

       ,p_csm_periodic_expenses_tbl				IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl						IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl				IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     				IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   						OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
   )
  IS
    	l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Lease_Quote';
  	lp_sifv_rec					sifv_rec_type;

  	lx_sifv_rec					sifv_rec_type;
  	lx_sifv_status_rec			sifv_rec_type;
  	lp_sfev_rent_tbl			sfev_tbl_type;
  	lx_sfev_rent_tbl			sfev_tbl_type;
  	lp_sfev_one_off_tbl			sfev_tbl_type;
  	lx_sfev_one_off_tbl			sfev_tbl_type;
  	lp_sfev_periodic_tbl		sfev_tbl_type;
  	lx_sfev_periodic_tbl		sfev_tbl_type;
  	lp_siyv_tbl					siyv_tbl_type;
  	lx_siyv_tbl 				siyv_tbl_type;
  	lp_sitv_tbl					sitv_tbl_type;
  	lx_sitv_tbl 				sitv_tbl_type;

    	l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

        -- new structures for Rollover fee
        x_csm_one_off_fee_tbl           csm_one_off_fee_tbl_type;
        x_csm_periodic_expenses_tbl     csm_periodic_expenses_tbl_type;

    l_api_version     CONSTANT NUMBER := 1;
	l_sif_id NUMBER;
	l_pending BOOLEAN := FALSE;
	  ---------------------------------------------------------------------------
	  -- FUNCTION pending_request_exists
	  -- Checks if any request is pending for the specified ContractNumber
	  ---------------------------------------------------------------------------
	  FUNCTION pending_request_exists(
		p_khr_id	IN 	NUMBER

	   ,x_return_status                		OUT NOCOPY VARCHAR2
	  ) RETURN BOOLEAN
	  IS
		CURSOR l_okl_sif_status_csr(p_khr_id IN OKL_STREAM_INTERFACES_V.KHR_ID%TYPE) IS
		SELECT '1' FROM dual
		WHERE EXISTS
		(SELECT '1'
		 FROM OKL_STREAM_INTERFACES
		 WHERE khr_id = p_khr_id
		 AND SIS_CODE IN (G_SIS_HDR_INSERTED, G_SIS_DATA_ENTERED, G_SIS_PROCESSING_REQUEST,G_SIS_RET_DATA_RECEIVED)
		);
	    l_pending BOOLEAN DEFAULT FALSE;
	  BEGIN
	    x_return_status	:= Okc_Api.G_RET_STS_SUCCESS;
	    IF p_khr_id IS NOT NULL THEN
	        FOR l_sif_csr IN l_okl_sif_status_csr(p_khr_id)
	        LOOP
	            l_pending := TRUE;
	        END LOOP;

	    END IF;
	    RETURN(l_pending);
	  EXCEPTION
		WHEN OTHERS THEN
			-- store SQL error message on message stack
			Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
								p_msg_name	=>	G_UNEXPECTED_ERROR,
								p_token1	=>	G_SQLCODE_TOKEN,
								p_token1_value	=>	SQLCODE,
								p_token2	=>	G_SQLERRM_TOKEN,

								p_token2_value	=>	SQLERRM);
		   x_return_status := G_RET_STS_UNEXP_ERROR;
		   RETURN NULL;
	  END pending_request_exists;
  BEGIN
     l_return_status := G_RET_STS_SUCCESS;
	 initialize;
     -- Check for any pending request for this Contract and
	 -- Error out if there does exist a request that is not completed
	 l_pending := pending_request_exists(p_khr_id => p_csm_lease_header.khr_id
	 	                    ,x_return_status		=> l_return_status);
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	 IF(l_pending) THEN
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
				    p_msg_name	=>	G_OKL_CSM_PENDING
							);
		l_return_status := G_RET_STS_ERROR;
        RAISE G_EXCEPTION_ERROR;
	 ELSE
	 	/* assign Transaction Header Data */
	 	lp_sifv_rec := assign_header_details( p_lease_header_rec	=> p_csm_lease_header
	 					     ,x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	   	-- Insert Transaction Header Data

-- Start of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;

	 	Okl_Stream_Interfaces_Pub.insert_stream_interfaces(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data

	 	       ,p_sifv_rec => lp_sifv_rec
	 	       ,x_sifv_rec => lx_sifv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Stream_Interfaces_Pub.insert_stream_interfaces ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Stream_Interfaces_Pub.insert_stream_interfaces
	 	IF l_return_status = G_RET_STS_ERROR THEN
	 		RAISE G_EXCEPTION_ERROR;
	 	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	 		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	 	END IF;
	 	-- Get the Interface Header ID
	     l_sif_id := lx_sifv_rec.id;
	 	/* Assign line Level Transaction Details*/
	 	IF p_csm_line_details_tbl IS NOT NULL THEN

	 		insert_asset_lines(p_api_version				=> p_api_version,
	 							p_init_msg_list				=> p_init_msg_list,
	 							p_sif_id					=> l_sif_id,
	 							p_csm_line_details_tbl 			=> p_csm_line_details_tbl,
	 							x_return_status				=> l_return_status,
	 							x_msg_count					=> x_msg_count,
	 							x_msg_data               	=> x_msg_data);
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;



          	/*Create rollover fee for lease quote*/
	 	IF p_csm_one_off_fee_tbl IS NOT NULL and p_csm_periodic_expenses_tbl IS NOT NULL THEN

		insert_finance_fee_for_lease(p_api_version				=> p_api_version,
	 				   p_init_msg_list				=> p_init_msg_list,
	 				   p_sif_id					=> l_sif_id,
	 				   p_csm_one_off_fee_tbl 			=> p_csm_one_off_fee_tbl,
					   p_csm_periodic_expenses_tbl                  => p_csm_periodic_expenses_tbl,
	 				   x_csm_one_off_fee_tbl 			=> x_csm_one_off_fee_tbl,
					   x_csm_periodic_expenses_tbl                  => x_csm_periodic_expenses_tbl,
	 				   x_return_status				=> l_return_status,
	 				   x_msg_count					=> x_msg_count,

	 				   x_msg_data               			=> x_msg_data);

	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;


	 	/* Assign Rent Details*/
	 	IF p_rents_tbl IS NOT NULL THEN
	     	lp_sfev_rent_tbl := assign_rent_details(p_sif_id			=> l_sif_id,
	     						p_csm_periodic_expenses_tbl	=> p_rents_tbl,
	 					        x_return_status		=> l_return_status
	 					     );

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		     	-- Insert Rent Details
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;

	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_rent_tbl
	     	       ,x_sfev_tbl => lx_sfev_rent_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;

  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;

	 	/* Assign One-Off Fee Details */
	 	IF p_csm_one_off_fee_tbl IS NOT NULL THEN
	     	lp_sfev_one_off_tbl := assign_one_off_fees(p_sif_id				=> l_sif_id,
	     						   p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
	 					           x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_one_off_tbl
	     	       ,x_sfev_tbl => lx_sfev_one_off_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Periodic Fee Details*/
	 	IF p_csm_periodic_expenses_tbl IS NOT NULL THEN
	     	lp_sfev_periodic_tbl := assign_periodic_expenses(p_sif_id			=> l_sif_id, --here 222

	     						p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
	 					        x_return_status		=> l_return_status
	 					     );

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;

		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
	     	Okl_Sif_Fees_Pub.insert_sif_fees(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_sfev_tbl => lp_sfev_periodic_tbl
	     	       ,x_sfev_tbl => lx_sfev_periodic_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Fees_Pub.insert_sif_fees ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Fees_Pub.insert_sif_fees
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign Yield Data */
	 	IF p_csm_yields_tbl IS NOT NULL THEN
	     	lp_siyv_tbl := assign_target_details(p_sif_id		=> l_sif_id,
	     					    p_csm_yields_tbl	=> p_csm_yields_tbl
	 					     ,x_return_status	=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
	     	-- Insert Yield Data corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
	     	Okl_Sif_Yields_Pub.insert_sif_yields(

	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	     	       ,p_siyv_tbl => lp_siyv_tbl
	     	       ,x_siyv_tbl => lx_siyv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Yields_Pub.insert_sif_yields ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Yields_Pub.insert_sif_yields
	     	IF l_return_status = G_RET_STS_ERROR THEN
	     		RAISE G_EXCEPTION_ERROR;
	     	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN

	     		RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	     	END IF;
	 	END IF;
	 	/* Assign StreamTypes needed for this Transaction */
	 	IF p_csm_stream_types_tbl IS NOT NULL THEN
			lp_sitv_tbl := assign_stream_types(p_sif_id					=> l_sif_id,
							    p_csm_stream_types_tbl		=> p_csm_stream_types_tbl
	 					     ,x_return_status		=> l_return_status
	 					     );
		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		  -- Insert StreamTypes corresponding to this Transaction
-- Start of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
			Okl_Sif_Stream_Types_Pub.insert_sif_stream_types(
	 	        p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
			       ,p_sitv_tbl => lp_sitv_tbl
			       ,x_sitv_tbl => lx_sitv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN



    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRCSMB.pls call Okl_Sif_Stream_Types_Pub.insert_sif_stream_types ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Sif_Stream_Types_Pub.insert_sif_stream_types
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;
			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
	 	END IF;
	 	IF p_skip_prc_engine <> G_TRUE THEN
             Invoke_Pricing_Engine(
			                        p_api_version				=> p_api_version,
									p_init_msg_list				=> p_init_msg_list,
									p_sifv_rec					=> lx_sifv_rec,
									x_sifv_rec					=> lx_sifv_status_rec,
									x_return_status				=> l_return_status,
									x_msg_count					=> x_msg_count,
									x_msg_data               	=> x_msg_data);
			IF l_return_status = G_RET_STS_ERROR THEN
				RAISE G_EXCEPTION_ERROR;

			ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE G_EXCEPTION_UNEXPECTED_ERROR;
			END IF;
		    x_trans_id     := lx_sifv_status_rec.transaction_number;
    	 	   x_trans_status := lx_sifv_status_rec.sis_code;
		ELSE
		    x_trans_id     := lx_sifv_rec.transaction_number;
    	 	    x_trans_status := lx_sifv_rec.sis_code;
	 	END IF;
 	END IF;
	x_return_status := l_return_status;
  EXCEPTION
	WHEN G_EXCEPTION_ERROR THEN
	   x_return_status := G_RET_STS_ERROR;
	WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	   x_return_status := G_RET_STS_UNEXP_ERROR;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,

							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_return_status := G_RET_STS_UNEXP_ERROR;

   END Create_Streams_Lease_Quote;

   PROCEDURE add_balance_information(x_sfev_tbl  IN OUT NOCOPY sfev_tbl_type,
                                     x_return_status        OUT NOCOPY VARCHAR2)
   IS
   	l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
   BEGIN
     FOR i in x_sfev_tbl.FIRST .. x_sfev_tbl.LAST
     LOOP
       IF x_sfev_tbl(i).balance_type_code is NULL
          THEN x_sfev_tbl(i).balance_type_code := G_BALANCE_PAYMENT;
       END IF;
     END LOOP;
     x_return_status := l_return_status;
   END add_balance_information;


END Okl_Create_Streams_Pvt  ;

/
