--------------------------------------------------------
--  DDL for Package Body OKL_PROP_TAX_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROP_TAX_ADJ_PVT" AS
/* $Header: OKLREPRB.pls 120.12.12010000.5 2009/06/03 04:18:35 racheruv ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  -- ----------------------------------------------------------------
  -- Procedure create_adjustment_invoice to reconcile actual and
  -- estimated property tax
  -- ----------------------------------------------------------------

  PROCEDURE create_adjustment_invoice
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2
    ,p_asset_number     IN  VARCHAR2
    ) IS

--start changed by abhsaxen for Bug#6174484
    CURSOR term_contracts_csr( p_contract_number IN VARCHAR2, p_asset_number IN VARCHAR2 ) IS
	SELECT khr.id,
	  khr.contract_number,
	  khr.currency_code,
	  astb.id kle_id
	FROM okc_k_headers_all_b khr,
	  okc_k_lines_b astb,
	  okc_k_lines_tl astl
	WHERE astb.sts_code = 'TERMINATED'
	 AND khr.contract_number = nvl(p_contract_number,   khr.contract_number)
	 AND astl.name = nvl(p_asset_number,   astl.name)
	 AND astb.dnz_chr_id = khr.id
	 AND astb.id = astl.id
	 AND astl.LANGUAGE = userenv('LANG')
	 AND NOT EXISTS
	  (SELECT khr_id
	   FROM okl_trx_contracts trx
	   WHERE trx.khr_id = khr.id
	   AND(source_trx_id IS NULL OR source_trx_id = astb.id)
	   AND trx.tcn_type = 'EPT'
	   AND trx.tsu_code = 'PROCESSED'
           --rkuttiya added for 12.1.1 Muti GAAP
           AND trx.representation_type = 'PRIMARY');
           --
--end changed by abhsaxen for Bug#6174484

    CURSOR asset_csr ( p_khr_id IN NUMBER, p_kle_id IN NUMBER ) IS
        SELECT *
        FROM okl_k_lines_full_v
        WHERE DNZ_CHR_ID = p_khr_id
        AND id = p_kle_id;

	------------------------------------------------------------
	-- Extract all actual property tax billable
	------------------------------------------------------------
	CURSOR actual_property_tax_csr ( p_khr_id IN NUMBER, p_kle_id IN NUMBER ) IS
		SELECT	NVL(SUM(ste.amount),0)	amount
	   	FROM	okl_strm_elements	ste,
			okl_streams			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			okl_k_headers			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
        AND stm.kle_id          = p_kle_id
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
        AND sty.STREAM_TYPE_PURPOSE = 'ACTUAL_PROPERTY_TAX'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
        AND khr.id              = p_khr_id
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
        AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED');

	------------------------------------------------------------
	-- Extract all estimated property tax billable
	------------------------------------------------------------
	CURSOR est_property_tax_csr ( p_khr_id IN NUMBER, p_kle_id IN NUMBER ) IS
        SELECT SUM(AMOUNT)
        FROM (
		SELECT	NVL(SUM(ste.amount),0)	amount
	   	FROM	okl_strm_elements	ste,
			okl_streams			    stm,
			okl_strm_type_v			sty,
			okc_k_headers_b			khr,
			okl_k_headers			khl,
			okc_k_lines_b			kle,
			okc_statuses_b			khs,
			okc_statuses_b			kls
		WHERE ste.amount 			<> 0
		AND	stm.id				= ste.stm_id
		AND	ste.date_billed		IS NOT NULL
        AND stm.kle_id          = p_kle_id
		AND	sty.id				= stm.sty_id
		AND	sty.billable_yn		= 'Y'
        AND sty.STREAM_TYPE_PURPOSE = 'ESTIMATED_PROPERTY_TAX'
		AND	khr.id				= stm.khr_id
		AND	khr.scs_code		IN ('LEASE', 'LOAN')
        AND khr.id              = p_khr_id
		AND	khl.id				= stm.khr_id
		AND	khl.deal_type		IS NOT NULL
		AND	khs.code			= khr.sts_code
		AND	kle.id			(+)	= stm.kle_id
		AND	kls.code		(+)	= kle.sts_code
        AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
        UNION
        SELECT NVL(SUM(til.amount),0) amount
        FROM okc_k_headers_b khr,
             okl_trx_ar_invoices_v tai,
             okl_txl_ar_inv_lns_v til,
             okl_strm_type_v sty
        WHERE khr.id = p_khr_id
        AND tai.khr_id = khr.id
        AND tai.id = til.tai_id
        AND tai.qte_id IS NOT NULL
        AND til.sty_id = sty.id
        AND til.kle_id = p_kle_id
        AND sty.STREAM_TYPE_PURPOSE = 'AMPRTX');

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
	l_api_name	    CONSTANT VARCHAR2(30) := 'CREATE_ADJUSTMENT_INVOICE';
 	l_api_version	CONSTANT NUMBER       := 1;
	l_return_status	VARCHAR2(1)           := Okl_Api.G_RET_STS_SUCCESS;
    l_error_status  VARCHAR2(1);
    l_error_message VARCHAR2(2000);
    l_op_unit_name  hr_operating_units.name%TYPE;
    l_request_id    VARCHAR2(100);

	------------------------------------------------------------
	-- Local Variables
	------------------------------------------------------------
    l_try_id             NUMBER;
    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_actual_tax_amt     NUMBER;
    l_estimated_tax_amt  NUMBER;
    l_adjusted_amt       NUMBER;
    l_sty_id             NUMBER;
    l_stm_id             NUMBER;
    l_max_line_num       NUMBER;
    l_actual_tax_count   NUMBER;
    l_adjust_flag        okc_rules_b.rule_information3%TYPE;
    l_prev_contract      okc_k_headers_b.contract_number%TYPE;
    l_display_contract   okc_k_headers_b.contract_number%TYPE;

    -- -------------------------------------------------
    -- Streams Record
    -- -------------------------------------------------
    l_stmv_rec          Okl_Streams_Pub.stmv_rec_type;
    lx_stmv_rec         Okl_Streams_Pub.stmv_rec_type;
    l_init_stmv_rec     Okl_Streams_Pub.stmv_rec_type;

    -- -------------------------------------------------
    -- Stream Elements Record
    -- -------------------------------------------------
	p_selv_rec	        Okl_Sel_Pvt.selv_rec_type;
	x_selv_rec	        Okl_Sel_Pvt.selv_rec_type;
    l_init_selv_rec     Okl_Sel_Pvt.selv_rec_type;

 	------------------------------------------------------------
	-- Get try_id for Estimated Property Tax Transaction Type
	------------------------------------------------------------
    CURSOR try_id_csr is
        SELECT id
        FROM OKL_TRX_TYPES_V
        WHERE NAME = 'Estimated Property Tax';

 	------------------------------------------------------------
	-- Get Count of specific stream type
	------------------------------------------------------------
	CURSOR c_sty_count_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_name VARCHAR2 ) IS
		   SELECT count(*)
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
           AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y'
           AND   sty.stream_type_purpose = p_sty_name;

	------------------------------------------------------------
	-- Transaction Number Cursor
	------------------------------------------------------------
    CURSOR c_tran_num_csr IS
        SELECT  okl_sif_seq.nextval
        FROM    dual;

	------------------------------------------------------------
	-- Stream Type Cursor
	------------------------------------------------------------
    CURSOR sty_csr IS
        SELECT id
        FROM okl_strm_type_v
        WHERE STREAM_TYPE_PURPOSE = 'ADJUSTED_PROPERTY_TAX';

 	------------------------------------------------------------
	-- Get stm_id of Adjusted Property Tax record
	------------------------------------------------------------
	CURSOR c_stm_id_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_name VARCHAR2 ) IS
		   SELECT stm.id
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
           AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y'
           AND   sty.STREAM_TYPE_PURPOSE = p_sty_name;

	------------------------------------------------------------
	-- Max Line Number
	------------------------------------------------------------
    CURSOR max_line_num_csr (p_stm_id NUMBER) IS
           SELECT max(se_line_number)
           FROM okl_strm_elements
           WHERE stm_id = p_stm_id;

	------------------------------------------------------------
	-- Operating Unit
	------------------------------------------------------------
    CURSOR op_unit_csr IS
           SELECT NAME
           FROM hr_operating_units
           WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID;	   -- MOAC fix - Bug#5378114 --varangan- 29-9-06

	------------------------------------------------------------
	-- Request Id
	------------------------------------------------------------
    CURSOR req_id_csr IS
           SELECT
	  	   RPAD(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),25,' ')
           FROM DUAL;

	------------------------------------------------------------
	-- Bill Property Tax Rule Attribute Value
	------------------------------------------------------------
    CURSOR bill_tax_csr( p_chr_id IN NUMBER, p_cle_id IN NUMBER ) IS
           SELECT rul.RULE_INFORMATION3
           FROM okc_rule_groups_b rgp,
                okc_rules_b rul
           WHERE rgp.id = rul.rgp_id
           AND rgp.rgd_code = 'LAASTX'
           AND rul.RULE_INFORMATION_CATEGORY = 'LAPRTX'
           AND rul.rule_information3 is not null
           AND rgp.dnz_chr_id = p_chr_id
           AND rgp.cle_id = p_cle_id;

    l_f_actual_tax_amt              VARCHAR2(50);
    l_f_estimated_tax_amt           VARCHAR2(50);
    l_f_adjusted_amt                VARCHAR2(50);

    TYPE succ_rec_type IS RECORD (
	 l_display_contract	okl_k_headers_full_v.contract_number%TYPE,
	 asset_name 		okx_asset_lines_v.NAME%TYPE,
	 actual_tax			VARCHAR2(50),
	 est_tax			VARCHAR2(50),
	 adj_tax			VARCHAR2(50)
	);

    TYPE succ_tbl_type IS TABLE OF succ_rec_type
	     INDEX BY BINARY_INTEGER;

	succ_tbl   	        succ_tbl_type;
    l_init_succ_tbl     succ_tbl_type;
	succ_tbl_idx	  	NUMBER;

BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_return_status := Okl_Api.START_ACTIVITY(
		                      p_api_name	   => l_api_name,
		                      p_pkg_name	   => G_PKG_NAME,
		                      p_init_msg_list  => p_init_msg_list,
		                      l_api_version	   => l_api_version,
		                      p_api_version	   => p_api_version,
		                      p_api_type	   => '_PVT',
		                      x_return_status  => l_return_status);

	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    ------------------------------------------
    -- Get try_id for estimated property tax
    ------------------------------------------
    l_try_id := NULL;
    OPEN  try_id_csr;
    FETCH try_id_csr INTO l_try_id;
    CLOSE try_id_csr;

    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    ----------------------------------------
    -- Get request id cursor
    ----------------------------------------
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;


	-- ----------------------------------------------------------
	-- Property Tax Header lines for the report
	-- ----------------------------------------------------------
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 54, ' ')||'Oracle Lease and Finance Management'||lpad(' ', 55, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 48, ' ')||'Property Tax Reconciliation Program'||lpad(' ', 49, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 48, ' ')||'-----------------------------------'||lpad(' ', 49, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Operating Unit: '||l_op_unit_name);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Request Id: '||l_request_id||lpad(' ',74,' ') ||'Run Date: '||to_char(sysdate));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Number: '||p_contract_number);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Asset Number   : '||p_asset_number);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad('-', 132, '-'));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Contract Number'||RPAD(' ',25,' ')||
                                    'Asset Number'||RPAD(' ',20,' ')||
                                    'Actual Property Tax'||RPAD(' ',7,' ')||
                                    'Property Tax'||RPAD(' ',12,' ')||
                                    'Adjustment');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'               '||RPAD(' ',25,' ')||
                                    '            '||RPAD(' ',24,' ')||
                                    '            '||RPAD(' ',10,' ')||
                                    '   Billed   '||RPAD(' ',11,' ')||
                                    '    Amount ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad('=', 132, '='));

	------------------------------------------------------------
	-- For each Contract and Asset
	------------------------------------------------------------

    l_prev_contract := NULL;

    FOR term_contracts_rec IN term_contracts_csr ( p_contract_number, p_asset_number ) LOOP

    ----------------------------------------
    -- Get sty_id for adjusted property tax
    ----------------------------------------
    l_sty_id := NULL;
    OKL_STREAMS_UTIL.get_dependent_stream_type
     ( term_contracts_rec.ID,
       'ACTUAL_PROPERTY_TAX',
       'ADJUSTED_PROPERTY_TAX',
       x_return_status,
       l_sty_id);


    FND_FILE.PUT_LINE (FND_FILE.LOG,'Processing Contract :'||term_contracts_rec.contract_number);

    ---------------------------------------------
    -- Reset error message and error status for
    -- each record
    ---------------------------------------------
    l_error_status  := 'S';
    l_error_message := NULL;

    ---------------------------------------------
    -- Reset local tax amounts for each tax type
    ---------------------------------------------
    l_actual_tax_amt     := NULL;
    l_estimated_tax_amt  := NULL;
    l_adjusted_amt       := NULL;

	------------------------------------------------------------
	-- Create Contract Transaction Header and Line
    -- in Submitted Status
	------------------------------------------------------------
    l_trxH_in_rec.tcn_type                   := 'EPT';
    l_trxH_in_rec.tsu_code                   := 'SUBMITTED';
    l_trxH_in_rec.description                := 'Estimated Property Tax';
    l_trxH_in_rec.date_transaction_occurred  := SYSDATE;
    l_trxH_in_rec.khr_id                     := term_contracts_rec.ID;
    l_trxH_in_rec.try_id                     := l_try_id;
    l_trxH_in_rec.SOURCE_TRX_ID              := term_contracts_rec.kle_id;
    l_trxH_in_rec.SOURCE_TRX_TYPE            := 'KLE';

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Creating Contract Transaction.');
    Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => l_api_version
            ,p_init_msg_list    => p_init_msg_list
            ,x_return_status    => l_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            l_error_status  := 'E';
            l_error_message := 'Error: Creating header record in OKL_TRX_CONTRACTS';
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: Creating header record in OKL_TRX_CONTRACTS');
    ELSIF (l_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
            l_error_status  := 'E';
            l_error_message := 'Error: Creating header record in OKL_TRX_CONTRACTS';
            FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: Creating header record in OKL_TRX_CONTRACTS');
    END IF;


    -- -------------------------------------------------
    -- For printing the result only in case of success
    -- -------------------------------------------------
    succ_tbl_idx := 1;
   	succ_tbl   	 := l_init_succ_tbl;

	------------------------------------------------------------
	-- For each asset line process a summary of records
	------------------------------------------------------------
    FOR asset_rec IN asset_csr( term_contracts_rec.ID, term_contracts_rec.kle_id ) LOOP

        l_actual_tax_amt := NULL;
        OPEN  actual_property_tax_csr ( term_contracts_rec.ID, asset_rec.id );
        FETCH actual_property_tax_csr INTO l_actual_tax_amt;
        CLOSE actual_property_tax_csr;

        l_estimated_tax_amt := NULL;
        OPEN  est_property_tax_csr ( term_contracts_rec.ID, asset_rec.id );
        FETCH est_property_tax_csr INTO l_estimated_tax_amt;
        CLOSE est_property_tax_csr;

        l_adjusted_amt := 0;

        l_adjust_flag := NULL;
        OPEN  bill_tax_csr( term_contracts_rec.ID, asset_rec.id );
        FETCH bill_tax_csr INTO l_adjust_flag;
        CLOSE bill_tax_csr;

        IF l_adjust_flag = 'ESTIMATED_AND_ACTUAL' THEN

        l_adjusted_amt := l_actual_tax_amt - l_estimated_tax_amt;

        ----------------------------------------------------
        -- Check if there exists a stream for
        ----------------------------------------------------
        l_actual_tax_count := 0;
        OPEN  c_sty_count_csr ( term_contracts_rec.ID, asset_rec.id, 'ADJUSTED_PROPERTY_TAX' );
        FETCH c_sty_count_csr INTO l_actual_tax_count;
        CLOSE c_sty_count_csr;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Creating Adjusted Property Tax Streams.');

        IF l_actual_tax_count > 0 THEN -- check for ADJUSTED property tax stream
              NULL;
        ELSE -- check for ADJUSTED property tax stream
              -- -------------------------
              -- Null out records
              -- -------------------------
              l_stmv_rec    := l_init_stmv_rec;
              lx_stmv_rec   := l_init_stmv_rec;

              OPEN  c_tran_num_csr;
              FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
              CLOSE c_tran_num_csr;

              l_stmv_rec.sty_id                := l_sty_id;
              l_stmv_rec.khr_id                := term_contracts_rec.ID;
              l_stmv_rec.kle_id                := asset_rec.id;
              l_stmv_rec.sgn_code              := 'MANL';
              l_stmv_rec.say_code              := 'CURR';
              l_stmv_rec.active_yn             := 'Y';
              l_stmv_rec.date_current          := sysdate;
              l_stmv_rec.comments              := 'Adjusted Property Tax';

              FND_FILE.PUT_LINE (FND_FILE.LOG, 'Creating Adjusted Property Tax Streams');

              Okl_Streams_Pub.create_streams(
                      p_api_version    =>     p_api_version,
                      p_init_msg_list  =>     p_init_msg_list,
                      x_return_status  =>     x_return_status,
                      x_msg_count      =>     x_msg_count,
                      x_msg_data       =>     x_msg_data,
                      p_stmv_rec       =>     l_stmv_rec,
                      x_stmv_rec       =>     lx_stmv_rec);

              IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := 'Error: Creating header record in OKL_TRX_CONTRACTS';
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: Creating Streams for Adjusted Property Tax');
	          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := 'Error: Creating Streams for Adjusted Property Tax';
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: Creating Streams for Adjusted Property Tax');
              END IF;
        END IF; -- check for adjusted property tax stream
        -- --------------------------------------------------------
        -- Create stream elements, if there were no error messages
        -- --------------------------------------------------------
        IF l_error_status <> 'E' THEN

                p_selv_rec := l_init_selv_rec;

                -- Create Stream Element
                l_stm_id := NULL;
                OPEN  c_stm_id_csr ( term_contracts_rec.ID, asset_rec.id, 'ADJUSTED_PROPERTY_TAX' );
                FETCH c_stm_id_csr INTO l_stm_id;
                CLOSE c_stm_id_csr;

                l_max_line_num := 0;
                OPEN  max_line_num_csr ( l_stm_id );
                FETCH max_line_num_csr INTO l_max_line_num;
                CLOSE max_line_num_csr;

			  	p_selv_rec.stm_id 				   := l_stm_id;
				p_selv_rec.SE_LINE_NUMBER          := NVL( l_max_line_num, 0 ) + 1;
				p_selv_rec.STREAM_ELEMENT_DATE     := SYSDATE;
				p_selv_rec.AMOUNT                  := l_adjusted_amt;
				p_selv_rec.COMMENTS                := 'Adjusted Property Tax';

                FND_FILE.PUT_LINE (FND_FILE.LOG, 'Creating Adjustment Stream Element.');

                -- Create adjustment stream element only if the adjustment
                -- amount is non-zero
                IF l_adjusted_amt <> 0 THEN
			     Okl_Sel_Pvt.insert_row(
    		 			p_api_version,
    		 			p_init_msg_list,
    		 			x_return_status,
    		 			x_msg_count,
    		 			x_msg_data,
    		 			p_selv_rec,
    		 			x_selv_rec);
                ELSE
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Adjustment Stream Element not created because adjustment amount is zero.');
                END IF;

	             IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := 'Error: Creating Adjusted Property Tax stream element';
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: Creating Adjusted Property Tax stream element');
	             ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    l_error_status  := 'E';
                    l_error_message := 'Error: Creating Adjusted Property Tax stream element';
                    FND_FILE.PUT_LINE (FND_FILE.LOG,'Error: Creating Adjusted Property Tax stream element');
                 END IF;
        END IF; -- Process Error
        END IF; -- Check if Bill Property Tax is 'ESTIMATED_ACTUAL'

    -- -----------------------------------------------------
    -- Get currency precision
    -- -----------------------------------------------------
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_actual_tax_amt: '||l_actual_tax_amt);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_estimated_tax_amt: '||l_estimated_tax_amt);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_adjusted_amt: '||l_adjusted_amt);

    l_f_actual_tax_amt     := okl_accounting_util.format_amount(l_actual_tax_amt, term_contracts_rec.currency_code);
    l_f_estimated_tax_amt  := okl_accounting_util.format_amount(l_estimated_tax_amt, term_contracts_rec.currency_code);
    l_f_adjusted_amt       := okl_accounting_util.format_amount(l_adjusted_amt, term_contracts_rec.currency_code);

    IF (term_contracts_rec.contract_number = l_prev_contract) THEN
        l_display_contract := ' ';
    ELSE
        l_display_contract := term_contracts_rec.contract_number;
    END IF;
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'l_display_contract: '||l_display_contract);
    -- --------------------------
    -- Record successful records
    -- --------------------------
    succ_tbl(succ_tbl_idx).l_display_contract := l_display_contract;
    succ_tbl(succ_tbl_idx).asset_name         := asset_rec.name;
    succ_tbl(succ_tbl_idx).actual_tax         := l_f_actual_tax_amt;
    succ_tbl(succ_tbl_idx).est_tax            := l_f_estimated_tax_amt;
    succ_tbl(succ_tbl_idx).adj_tax            := l_f_adjusted_amt;

    succ_tbl_idx := succ_tbl_idx + 1;

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'asset_rec.name: '||asset_rec.name);
/*      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD(SUBSTR(l_display_contract,1,25),25,' ' )||  */
/*                                      RPAD(' ',15,' ')||  */
/*                                      RPAD(SUBSTR(asset_rec.name,1,20),20,' ')||  */
/*                                      RPAD(' ',6,' ')||  */
/*                                      lpad(SUBSTR(l_f_actual_tax_amt,1,22),22,' ')||  */
/*                                      lpad(SUBSTR(l_f_estimated_tax_amt,1,22),22,' ')||  */
/*                                      lpad(SUBSTR(l_f_adjusted_amt,1,22),22,' ')  */
/*                                      );  */
        -- ---------------------
        -- Save Contract Number
        -- ---------------------
        l_prev_contract := term_contracts_rec.contract_number;

    END LOOP; -- loop for each asset

	------------------------------------------------------------
	-- Update Contract transaction status to be Success or error
	------------------------------------------------------------
    IF l_error_status = 'S' THEN
        -- If there was no adjustment amounts to process
        -- mark the record as ERROR to indicate nothing was processed.
        -- This allows for future runs when actual property tax info
        -- is uploaded at a later date
        IF (    (l_actual_tax_amt = 0)
            AND (l_estimated_tax_amt = 0)
            AND (l_adjusted_amt = 0)
           )
        THEN
            UPDATE OKL_TRX_CONTRACTS
            SET TSU_CODE = 'ERROR'
            WHERE ID = l_trxH_out_rec.ID;
        ELSE
            UPDATE OKL_TRX_CONTRACTS
            SET TSU_CODE = 'PROCESSED'
            WHERE ID = l_trxH_out_rec.ID;
        END IF;
        -- -------------------------------
        -- Loop thru the success records
        -- -------------------------------
        FOR i IN succ_tbl.FIRST..succ_tbl.LAST LOOP
         FND_FILE.PUT_LINE (FND_FILE.OUTPUT, RPAD(SUBSTR(succ_tbl(i).l_display_contract,1,25),25,' ' )||
                                    RPAD(' ',15,' ')||
                                    RPAD(SUBSTR(succ_tbl(i).asset_name,1,20),20,' ')||
                                    RPAD(' ',6,' ')||
                                    lpad(SUBSTR(succ_tbl(i).actual_tax,1,22),22,' ')||
                                    lpad(SUBSTR(succ_tbl(i).est_tax,1,22),22,' ')||
                                    lpad(SUBSTR(succ_tbl(i).adj_tax,1,22),22,' ')
                                    );
        END LOOP;
    ELSE
        UPDATE OKL_TRX_CONTRACTS
        SET TSU_CODE = 'ERROR'
        WHERE ID = l_trxH_out_rec.ID;
    END IF;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    -- Start Bug 4520466
    OKL_BILLING_CONTROLLER_PVT.track_next_bill_date( term_contracts_rec.id );
    -- End Bug 4520466

    END LOOP; -- loop for each contract

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad('=', 132, '='));
	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------
	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error (EXCP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error (UNEXP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, 'Error (OTHERS) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

  END create_adjustment_invoice;


END OKL_PROP_TAX_ADJ_PVT;

/
