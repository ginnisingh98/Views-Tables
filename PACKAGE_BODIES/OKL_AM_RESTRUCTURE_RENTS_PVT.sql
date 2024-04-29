--------------------------------------------------------
--  DDL for Package Body OKL_AM_RESTRUCTURE_RENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RESTRUCTURE_RENTS_PVT" AS
 /* $Header: OKLRRSRB.pls 120.2 2005/10/30 04:36:28 appldev noship $ */


  -- Start of comments
  --
  -- Procedure Name	: initiate_request
  -- Description	: Initiates the out bound request to super trump after
  --			  getting the contract details that supertrump needs along
  --			  with new restructure details for the contract
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  --
  -- End of comments

  PROCEDURE initiate_request(
	p_api_version               IN  NUMBER,
	p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	p_quote_id                  IN  OKL_TRX_QUOTES_B.ID%TYPE,
	x_return_status             OUT NOCOPY VARCHAR2,
	x_msg_count                 OUT NOCOPY NUMBER,
	x_msg_data                  OUT NOCOPY VARCHAR2,
	x_request_id                OUT NOCOPY NUMBER,
	x_trans_status              OUT NOCOPY VARCHAR2) IS

    CURSOR l_qtev_csr (p_quote_id IN OKL_TRX_QUOTES_B.ID%TYPE) IS
	SELECT	qte.id,
		qte.khr_id,
		qte.term,
		qte.pop_code_end,
		qte.purchase_amount,
		qte.purchase_formula,
		khr.after_tax_yield,
		khr.term_duration
	FROM	okl_trx_quotes_v	qte,
		okl_k_headers		khr
	WHERE	qte.id			= p_quote_id
	AND	khr.id			= qte.khr_id;

     -- SMODUGA 11-Oct-04 Bug 3925469
     -- Modified cursor by passing sty_id based on the purspose and
     -- removed reference to stream type view.
    CURSOR l_stream_csr (cp_contract_id IN NUMBER,cp_sty_id IN NUMBER) IS
	SELECT	ste.stream_element_date	start_date,
		SUM (ste.amount)	amount
	FROM	okl_strm_elements	ste,
		okl_streams		stm,
		okc_k_lines_b		kle,
		okc_statuses_b		kls
	WHERE stm.khr_id		= cp_contract_id
	AND	stm.sty_id		= cp_sty_id
	AND	stm.active_yn		= 'Y'
	AND	stm.say_code		= 'CURR'
	AND	kle.id			= stm.kle_id
	AND	kls.code		= kle.sts_code
	AND	kls.ste_code		= 'ACTIVE'
	AND	ste.stm_id		= stm.id
	GROUP	BY ste.stream_element_date
	ORDER	BY ste.stream_element_date;

    l_qtev_rec                  l_qtev_csr%ROWTYPE;

    -- extracted parameters from LA proc for the contract
    lx_csm_lease_header          csm_lease_rec_type;
    lx_csm_one_off_fee_tbl       csm_one_off_fee_tbl_type;
    lx_csm_periodic_expenses_tbl csm_periodic_expenses_tbl_type;
    lx_csm_yields_tbl            csm_yields_tbl_type;
    lx_req_stream_types_tbl      csm_stream_types_tbl_type;
    lx_csm_line_details_tbl      csm_line_details_tbl_type;
    lx_rents_tbl                 csm_periodic_expenses_tbl_type;

    l_skip_prc_engine	VARCHAR2(1) := OKL_API.G_FALSE;

    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name		CONSTANT VARCHAR2(30):= 'initiate_request';
    l_api_version	CONSTANT NUMBER      := 1;
    l_overall_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id		NUMBER;
    l_ind		NUMBER := 0;
    l_advance_or_arrears OKL_SIF_FEES_V.advance_or_arrears%TYPE;
    l_structure		OKL_SIF_FEES_V.structure%TYPE;
    l_period		OKL_SIF_FEES_V.period%TYPE;
    l_amount		NUMBER := OKC_API.G_MISS_NUM;
    l_number_of_periods	NUMBER;
    l_new_periods	NUMBER;
    l_next_billing_date	DATE	:= NULL;
    l_last_billing_date	DATE	:= NULL;
    l_add_months	INTEGER;

     -- SMODUGA added variable for userdefined streams 3925469
     lx_sty_id NUMBER;


  BEGIN
    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
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

    OPEN  l_qtev_csr (p_quote_id);
    FETCH l_qtev_csr INTO l_qtev_rec;

    IF (l_qtev_csr%NOTFOUND) THEN
        OKC_API.SET_MESSAGE (
    			 p_app_name	=> 'OKC'
     			,p_msg_name	=> G_INVALID_VALUE
    			,p_token1	=> G_COL_NAME_TOKEN
    			,p_token1_value	=> 'p_quote_id');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    CLOSE l_qtev_csr;

    l_chr_id := l_qtev_rec.khr_id;
    l_new_periods := l_qtev_rec.term_duration + l_qtev_rec.term;

    -- Call the OKL_LA_STREAM_PUB to get the contract parameters
    OKL_LA_STREAM_PUB.extract_params_lease(
		p_api_version               => p_api_version,
		p_init_msg_list             => p_init_msg_list,
		p_chr_id                    => l_chr_id,
		x_return_status             => l_return_status,
		x_msg_count                 => x_msg_count,
		x_msg_data                  => x_msg_data,
		x_csm_lease_header          => lx_csm_lease_header,
		x_csm_one_off_fee_tbl       => lx_csm_one_off_fee_tbl,
		x_csm_periodic_expenses_tbl => lx_csm_periodic_expenses_tbl,
		x_csm_yields_tbl            => lx_csm_yields_tbl,
		x_req_stream_types_tbl      => lx_req_stream_types_tbl,
		x_csm_line_details_tbl      => lx_csm_line_details_tbl,
		x_rents_tbl                 => lx_rents_tbl);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- Set the restructure values
    lx_csm_lease_header.jtot_object1_code	:= 'OKL_TRX_QUOTES_B';
    lx_csm_lease_header.object1_id1		:= l_qtev_rec.id;
    lx_csm_lease_header.orp_code		:=
		Okl_Create_Streams_Pub.G_ORP_CODE_RESTRUCTURE_AM;
    -- Update the original contract term
    lx_csm_lease_header.term			:= l_new_periods;
    -- What to adjust
    lx_csm_lease_header.adjust			:=
		OKL_CREATE_STREAMS_PUB.G_ADJUST; --'Rent';
    lx_csm_lease_header.adjustment_method	:=
		OKL_CREATE_STREAMS_PUB.G_ADJUSTMENT_METHOD; --'Proportional';

    -- Delete this table, not required
    lx_req_stream_types_tbl.DELETE;

    -- Rents
    l_advance_or_arrears	:= lx_rents_tbl(1).advance_or_arrears;
    l_structure			:= lx_rents_tbl(1).structure;
    l_period			:= lx_rents_tbl(1).period;
    lx_rents_tbl.DELETE;

    -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
    OKL_STREAMS_UTIL.get_primary_stream_type(l_chr_id,
                                             'RENT',
                                              l_return_status,
                                              lx_sty_id);
    -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++

    FOR l_str_rec IN l_stream_csr (l_chr_id,lx_sty_id) LOOP


	IF l_str_rec.start_date < SYSDATE THEN

	    IF l_amount <> l_str_rec.amount THEN
		l_ind := l_ind + 1;
		l_amount := l_str_rec.amount;
		lx_rents_tbl(l_ind).level_index_number	:= l_ind;
		lx_rents_tbl(l_ind).advance_or_arrears	:= l_advance_or_arrears;
		lx_rents_tbl(l_ind).structure		:= l_structure;
		lx_rents_tbl(l_ind).period		:= l_period;
		lx_rents_tbl(l_ind).description		:= 'RENT';
		lx_rents_tbl(l_ind).level_type		:= OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
		lx_rents_tbl(l_ind).income_or_expense	:= OKL_CREATE_STREAMS_PUB.G_INCOME;
		lx_rents_tbl(l_ind).query_level_yn	:= OKL_CREATE_STREAMS_PUB.G_FND_YES;
		lx_rents_tbl(l_ind).lock_level_step	:= OKL_CREATE_STREAMS_PUB.G_LOCK_AMOUNT;
		lx_rents_tbl(l_ind).date_start		:= l_str_rec.start_date;
		lx_rents_tbl(l_ind).amount		:= l_str_rec.amount;
		lx_rents_tbl(l_ind).number_of_periods	:= 1;
	    ELSE
		lx_rents_tbl(l_ind).number_of_periods	:=
			lx_rents_tbl(l_ind).number_of_periods + 1;
	    END IF;
	    l_new_periods	:= l_new_periods - 1;
	    l_last_billing_date	:= l_str_rec.start_date;

	ELSE
	    IF l_next_billing_date IS NULL THEN
		l_next_billing_date := l_str_rec.start_date;
	    END IF;
	END IF;

    END LOOP;

    IF l_new_periods > 0 THEN

	IF l_next_billing_date IS NULL THEN

	    IF l_last_billing_date IS NULL THEN
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> 'OKL_LLA_NO_STREAM_ELEMENT');
		RAISE OKL_API.G_EXCEPTION_ERROR;
	    ELSE

		IF    l_period = 'A' THEN
			l_add_months := 12;
		ELSIF l_period = 'S' THEN
			l_add_months := 6;
		ELSIF l_period = 'Q' THEN
			l_add_months := 3;
		ELSE -- l_period = 'M'
			l_add_months := 1;
		END IF;

		LOOP
			EXIT WHEN l_last_billing_date >= SYSDATE;
			l_last_billing_date := ADD_MONTHS (l_last_billing_date, l_add_months);
		END LOOP;
		l_next_billing_date	:= l_last_billing_date;

	    END IF;

	END IF;

	IF l_next_billing_date IS NOT NULL THEN

		l_ind := l_ind + 1;
		lx_rents_tbl(l_ind).level_index_number	:= l_ind;
		lx_rents_tbl(l_ind).advance_or_arrears	:= l_advance_or_arrears;
		lx_rents_tbl(l_ind).structure		:= l_structure;
		lx_rents_tbl(l_ind).period		:= l_period;
		lx_rents_tbl(l_ind).description		:= 'RENT';
		lx_rents_tbl(l_ind).level_type		:= OKL_CREATE_STREAMS_PUB.G_SFE_LEVEL_PAYMENT;
		lx_rents_tbl(l_ind).income_or_expense	:= OKL_CREATE_STREAMS_PUB.G_INCOME;
		lx_rents_tbl(l_ind).query_level_yn	:= OKL_CREATE_STREAMS_PUB.G_FND_YES;
		lx_rents_tbl(l_ind).lock_level_step	:= NULL;
		lx_rents_tbl(l_ind).date_start		:= l_next_billing_date;
		lx_rents_tbl(l_ind).amount		:= 0;
		lx_rents_tbl(l_ind).number_of_periods	:= l_new_periods;

	ELSE
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    ELSE
	      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Yields
    FOR i IN lx_csm_yields_tbl.FIRST..lx_csm_yields_tbl.LAST LOOP
	IF lx_csm_yields_tbl(i).yield_name = 'Booking' THEN
		lx_csm_yields_tbl(i).target_value := l_qtev_rec.after_tax_yield;
	END IF;
    END LOOP;

    -- Purchase Option
    FOR i IN lx_csm_line_details_tbl.FIRST..lx_csm_line_details_tbl.LAST LOOP

	lx_csm_line_details_tbl(i).purchase_option := l_qtev_rec.pop_code_end;

	IF  l_qtev_rec.purchase_amount IS NOT NULL
	AND l_qtev_rec.purchase_amount <> OKL_API.G_MISS_NUM THEN
		lx_csm_line_details_tbl(i).purchase_option_amount := l_qtev_rec.purchase_amount;

	ELSIF l_qtev_rec.purchase_formula IS NOT NULL
	AND   l_qtev_rec.purchase_formula <> OKL_API.G_MISS_CHAR THEN

		okl_am_util_pvt.get_formula_value (
			p_formula_name	=> l_qtev_rec.purchase_formula,
			p_chr_id	=> l_chr_id,
			p_cle_id	=> lx_csm_line_details_tbl(i).kle_asset_id,
			x_formula_value	=> lx_csm_line_details_tbl(i).purchase_option_amount,
			x_return_status	=> l_return_status);

		IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
		ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
			RAISE OKL_API.G_EXCEPTION_ERROR;
		END IF;

	ELSE
		lx_csm_line_details_tbl(i).purchase_option_amount := 0;
	END IF;

    END LOOP;

    -- Call OKL_CREATE_STREAMS_PUB with the modified parameters which calls supertrump
    OKL_CREATE_STREAMS_PUB.create_streams_lease_restr (
		p_api_version               => p_api_version,
		p_init_msg_list             => p_init_msg_list,
		p_skip_prc_engine           => l_skip_prc_engine,
		p_csm_lease_header          => lx_csm_lease_header,
		p_csm_one_off_fee_tbl       => lx_csm_one_off_fee_tbl, --one time fee
		p_csm_periodic_expenses_tbl => lx_csm_periodic_expenses_tbl, --fee and service
		p_csm_yields_tbl            => lx_csm_yields_tbl,
		p_csm_stream_types_tbl      => lx_req_stream_types_tbl,
		p_csm_line_details_tbl      => lx_csm_line_details_tbl,
		p_rents_tbl                 => lx_rents_tbl,
		x_trans_id                  => x_request_id, -- correct***
		x_trans_status              => x_trans_status,
		x_return_status             => l_return_status,
		x_msg_count                 => x_msg_count,
		x_msg_data                  => x_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF (l_qtev_csr%ISOPEN) THEN
        CLOSE l_qtev_csr;
      END IF;
      IF (l_stream_csr%ISOPEN) THEN
        CLOSE l_stream_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (l_qtev_csr%ISOPEN) THEN
        CLOSE l_qtev_csr;
      END IF;
      IF (l_stream_csr%ISOPEN) THEN
        CLOSE l_stream_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OTHERS THEN
      IF (l_qtev_csr%ISOPEN) THEN
        CLOSE l_qtev_csr;
      END IF;
      IF (l_stream_csr%ISOPEN) THEN
        CLOSE l_stream_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END initiate_request;


  -- Start of comments
  --
  -- Procedure Name	: populate_rent_levels
  -- Description	: Save stream returns as quote lines
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  --
  -- End of comments

PROCEDURE populate_rent_levels (
	p_quote_id	IN  NUMBER,
	p_rent_tbl	IN  srlv_tbl_type,
	p_yield_tbl	IN  yields_tbl_type,
	x_tqlv_tbl OUT NOCOPY tqlv_tbl_type,
	x_return_status	OUT NOCOPY VARCHAR2) IS

	l_tqlv_rec1		tqlv_rec_type;
	l_tqlv_rec2		tqlv_rec_type;
	l_tqlv_tbl		tqlv_tbl_type;
	lx_tqlv_tbl		tqlv_tbl_type;
	l_qtev_rec		qtev_rec_type;
	lx_qtev_rec		qtev_rec_type;

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_api_version		CONSTANT NUMBER	:= G_API_VERSION;
	l_msg_count		NUMBER		:= G_MISS_NUM;
	l_msg_data		VARCHAR2(2000);

	l_ind			INTEGER;
	l_seq			INTEGER;

BEGIN

	-- *******************
	-- Update quote status
	-- *******************

	l_qtev_rec.id		:= p_quote_id;
	l_qtev_rec.qst_code	:= 'DRAFTED';

	OKL_TRX_QUOTES_PUB.update_trx_quotes (
		p_api_version	=> l_api_version,
		p_init_msg_list	=> OKL_API.G_FALSE,
		x_return_status	=> l_return_status,
		x_msg_count	=> l_msg_count,
		x_msg_data	=> l_msg_data,
		p_qtev_rec	=> l_qtev_rec,
		x_qtev_rec	=> lx_qtev_rec);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
		l_overall_status := l_return_status;
	    END IF;
	END IF;

	-- ******************************
	-- Save Rent Stream Return Levels
	-- ******************************

	IF p_rent_tbl.COUNT > 0 THEN

		l_ind := p_rent_tbl.FIRST;

		LOOP

			l_seq	:= NVL (l_tqlv_tbl.LAST, 0)  + 1;

			l_tqlv_rec1.qte_id		:= p_quote_id;
			l_tqlv_rec1.qlt_code		:= G_RENTS_LINE;
			l_tqlv_rec1.org_id		:= lx_qtev_rec.org_id;
			l_tqlv_rec1.line_number		:= p_rent_tbl(l_ind).level_index_number;
			l_tqlv_rec1.amount		:= p_rent_tbl(l_ind).amount;
			l_tqlv_rec1.start_date		:= p_rent_tbl(l_ind).first_payment_date;
			l_tqlv_rec1.period		:= p_rent_tbl(l_ind).period;
			l_tqlv_rec1.number_of_periods	:= p_rent_tbl(l_ind).number_of_periods;
			l_tqlv_rec1.lock_level_step	:= p_rent_tbl(l_ind).lock_level_step;
			l_tqlv_rec1.advance_or_arrears	:= p_rent_tbl(l_ind).advance_or_arrears;

			-- Set mandatory TAPI defaults
			l_tqlv_rec1.modified_yn		:= G_NO;
			l_tqlv_rec1.taxed_yn		:= G_NO;

			l_tqlv_tbl(l_seq)		:= l_tqlv_rec1;

		    EXIT WHEN (l_ind = p_rent_tbl.LAST);
		    l_ind := p_rent_tbl.NEXT (l_ind);

		END LOOP;

	END IF;

	-- ******************************
	-- Save Rent Stream Return Yields
	-- ******************************

	IF p_yield_tbl.COUNT > 0 THEN

		l_ind := p_yield_tbl.FIRST;

		LOOP

			l_seq	:= NVL (l_tqlv_tbl.LAST, 0)  + 1;

			l_tqlv_rec2.qte_id		:= p_quote_id;
			l_tqlv_rec2.qlt_code		:= G_YIELDS_LINE;
			l_tqlv_rec2.org_id		:= lx_qtev_rec.org_id;
			l_tqlv_rec2.line_number		:= l_seq;
			l_tqlv_rec2.amount		:= 0;
			l_tqlv_rec2.yield_name		:= p_yield_tbl(l_ind).yield_name;
			l_tqlv_rec2.yield_value		:= 100 * p_yield_tbl(l_ind).value;
			l_tqlv_rec2.implicit_interest_rate :=
						100 * p_yield_tbl(l_ind).implicit_interest_rate;

			-- Set mandatory TAPI defaults
			l_tqlv_rec2.modified_yn		:= G_NO;
			l_tqlv_rec2.taxed_yn		:= G_NO;

			l_tqlv_tbl(l_seq)		:= l_tqlv_rec2;

		    EXIT WHEN (l_ind = p_yield_tbl.LAST);
		    l_ind := p_yield_tbl.NEXT (l_ind);

		END LOOP;

	END IF;

	-- **********************************
	-- Save quote lines into the database
	-- **********************************

	IF  l_tqlv_tbl.COUNT > 0 THEN

		OKL_TXL_QUOTE_LINES_PUB.insert_txl_quote_lines (
			p_api_version	=> l_api_version,
			p_init_msg_list	=> OKL_API.G_FALSE,
			x_return_status	=> l_return_status,
			x_msg_count	=> l_msg_count,
			x_msg_data	=> l_msg_data,
			p_tqlv_tbl	=> l_tqlv_tbl,
			x_tqlv_tbl	=> lx_tqlv_tbl);

		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		    IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		    END IF;
		END IF;

	END IF;

	-- **************
	-- Return results
	-- **************

	x_tqlv_tbl	:= lx_tqlv_tbl;
	x_return_status := l_overall_status;

EXCEPTION

	WHEN OTHERS THEN

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);

		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END;


  -- Start of comments
  --
  -- Procedure Name	: process_results
  -- Description	:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  --
  -- End of comments


  PROCEDURE process_results(
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2,
              p_generation_context  IN  VARCHAR2,
              p_jtot_object1_code   IN  VARCHAR2,
              p_object1_id1         IN  VARCHAR2,
              p_chr_id              IN  NUMBER,
              p_rent_tbl            IN  srlv_tbl_type,
              p_yield_tbl           IN  yields_tbl_type,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2) IS

	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_api_name		CONSTANT VARCHAR2(30):= 'process_results';
	l_api_version		CONSTANT NUMBER      := 1;
	l_overall_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_tqlv_tbl		tqlv_tbl_type;

  BEGIN

    --Check API version, initialize message list and create savepoint.
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
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

     populate_rent_levels (
	p_quote_id	=> p_object1_id1,
	p_rent_tbl	=> p_rent_tbl,
	p_yield_tbl	=> p_yield_tbl,
	x_tqlv_tbl	=> l_tqlv_tbl,
	x_return_status	=> l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    -- end the transaction
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END process_results;

END OKL_AM_RESTRUCTURE_RENTS_PVT;

/
