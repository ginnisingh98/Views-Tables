--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_MAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_MAN_PVT" AS
/* $Header: OKLRPIMB.pls 120.5 2007/02/08 11:55:53 sjalasut noship $ */

--------------------------------------------------------------------
-- PROCEDURE manual_entry
--------------------------------------------------------------------

PROCEDURE manual_entry (
	 p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	--DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_man_inv_rec		IN  man_inv_rec_type
	,x_man_inv_rec		OUT NOCOPY man_inv_rec_type) IS

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------
   	l_api_version	CONSTANT NUMBER     := 1;
	l_api_name	CONSTANT VARCHAR2(30)   := 'MANUAL_ENTRY';
	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

	-----------------------------------------------------------------
	-- Declare Process Variable
	-----------------------------------------------------------------
	l_okl_application_id NUMBER(3) := 540;
	l_document_category VARCHAR2(100):= 'OKL Lease Pay Invoices';
	lX_dbseqnm          VARCHAR2(2000):= '';
	lX_dbseqid          NUMBER(38):= NULL;

	------------------------------------------------------------
	-- Declare records: Payable Invoice Headers, Lines and Distributions
	------------------------------------------------------------
	lp_tapv_rec             okl_tap_pvt.tapv_rec_type;
	lx_tapv_rec     	okl_tap_pvt.tapv_rec_type;
	lp_tplv_rec     	okl_tpl_pvt.tplv_rec_type;
	lx_tplv_rec     	okl_tpl_pvt.tplv_rec_type;

        /* ankushar 23-JAN-2007
           added table definitions
           start changes
        */
        lp_tplv_tbl     	      okl_tpl_pvt.tplv_tbl_type;
        lx_tplv_tbl     	      okl_tpl_pvt.tplv_tbl_type;
        /* ankushar end changes*/

	G_EXCEPTION_HALT_VALIDATION  	EXCEPTION;

	CURSOR org_id_csr ( p_khr_id NUMBER ) IS
    	   SELECT chr.authoring_org_id
    	   FROM okc_k_headers_b chr
    	   WHERE id =  p_khr_id;

	CURSOR sob_csr ( p_org_id  NUMBER ) IS
    	   SELECT hru.set_of_books_id
    	   FROM HR_OPERATING_UNITS HRU
    	   WHERE ORGANIZATION_ID = p_org_id;

	CURSOR try_id_csr IS
     	   SELECT id
    	   FROM okl_trx_types_tl
    	   WHERE name = 'Disbursement'
    	   AND language= 'US';

	CURSOR pdt_id_csr ( p_khr_id NUMBER ) IS
     	   SELECT khr.pdt_id
     	   FROM okl_k_headers khr
     	   WHERE khr.id =  p_khr_id;

	-- Temp Variable
	l_kle_id 	 NUMBER;

     -- Multi Currency Compliance
    l_currency_code            okl_ext_sell_invs_b.currency_code%type;
    l_currency_conversion_type okl_ext_sell_invs_b.currency_conversion_type%type;
    l_currency_conversion_rate okl_ext_sell_invs_b.currency_conversion_rate%type;
    l_currency_conversion_date okl_ext_sell_invs_b.currency_conversion_date%type;

    CURSOR l_curr_conv_csr( cp_khr_id  NUMBER ) IS
        SELECT  currency_code
               ,currency_conversion_type
               ,currency_conversion_rate
               ,currency_conversion_date
        FROM    okl_k_headers_full_v
        WHERE   id = cp_khr_id;

BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	l_return_status := OKL_API.START_ACTIVITY (
		p_api_name	=> l_api_name,
		p_pkg_name	=> g_pkg_name,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> x_return_status);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    IF (p_man_inv_rec.vendor_id IS NULL OR
        p_man_inv_rec.khr_id IS NULL OR
        p_man_inv_rec.sty_id IS NULL OR
        p_man_inv_rec.invoice_date IS NULL OR
        p_man_inv_rec.amount IS NULL) THEN
      OKL_Api.SET_MESSAGE
            ( p_app_name     => 'OKL',
              p_msg_name     => 'OKL_ENTER_REQD_FIELDS'
            ) ;
      x_return_status := OKL_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  	------------------------------------------------------------
	-- Derive Organization and Set of Books
	------------------------------------------------------------

	lp_tapv_rec.org_id := NULL;

	OPEN 	org_id_csr ( p_man_inv_rec.khr_id) ;
	FETCH	org_id_csr INTO lp_tapv_rec.org_id;
	CLOSE	org_id_csr;

	SELECT	hru.set_of_books_id
	INTO	lp_tapv_rec.set_of_books_id
	FROM	HR_OPERATING_UNITS HRU
	WHERE	ORGANIZATION_ID = lp_tapv_rec.org_id;

	lp_tapv_rec.set_of_books_id := NULL;

	OPEN	sob_csr ( lp_tapv_rec.org_id );
	FETCH	sob_csr INTO lp_tapv_rec.set_of_books_id;
	CLOSE	sob_csr;

	------------------------------------------------------------
	-- Derive Invoice Number
	------------------------------------------------------------

	IF p_man_inv_rec.Vendor_Invoice_Number IS NULL
	OR p_man_inv_rec.Vendor_Invoice_Number = OKL_API.G_MISS_CHAR THEN

		lp_tapv_rec.invoice_number := NULL;

		lp_tapv_rec.invoice_number := fnd_seqnum.get_next_sequence
			(appid      =>  l_okl_application_id,
			cat_code    =>  l_document_category,
			sobid       =>  lp_tapv_rec.set_of_books_id,
			met_code    =>  'A',
			trx_date    =>  SYSDATE,
			dbseqnm     =>  lx_dbseqnm,
			dbseqid     =>  lx_dbseqid);

		lp_tapv_rec.vendor_invoice_number  := lp_tapv_rec.invoice_number;

	ELSE

		lp_tapv_rec.vendor_invoice_number  := p_man_inv_rec.vendor_invoice_number;
		lp_tapv_rec.invoice_number	   := p_man_inv_rec.vendor_invoice_number;

	END IF;

  	------------------------------------------------------------
	-- FETCH try_id
	------------------------------------------------------------

	lp_tapv_rec.try_id := NULL;

	OPEN  try_id_csr;
	FETCH try_id_csr INTO lp_tapv_rec.try_id;
	CLOSE try_id_csr;

  	------------------------------------------------------------
	-- Populate internal AP invoice header Record
	------------------------------------------------------------

	lp_tapv_rec.amount			:=  p_man_inv_rec.amount;

	IF NVL(p_man_inv_rec.invoice_type, 'STANDARD') = 'CREDIT' THEN
		lp_tapv_rec.amount		:= - lp_tapv_rec.amount;
	END IF;

	lp_tapv_rec.vendor_id		:=  p_man_inv_rec.vendor_id;
	lp_tapv_rec.ipvs_id			:=  p_man_inv_rec.ipvs_id;
 -- sjalasut, commented the khr_id assignment at the internal transaction table
 -- header level. khr_id would be referred at the internal transaction lines table
 -- changes made as part of OKLR12B disbursements project
	-- lp_tapv_rec.khr_id			:=  p_man_inv_rec.khr_id;
 lp_tapv_rec.khr_id			:=  NULL;
	lp_tapv_rec.currency_code	:=  p_man_inv_rec.currency;
	lp_tapv_rec.payment_method_code		:=  p_man_inv_rec.payment_method_code;
	lp_tapv_rec.date_entered	:=  sysdate;
	lp_tapv_rec.date_invoiced	:=  p_man_inv_rec.invoice_date;
	lp_tapv_rec.invoice_category_code	:=  p_man_inv_rec.invoice_category_code;
	lp_tapv_rec.ippt_id			:=  p_man_inv_rec.pay_terms;
	lp_tapv_rec.invoice_type	:=  p_man_inv_rec.invoice_type;
	lp_tapv_rec.Pay_Group_lookup_code	:=  p_man_inv_rec.Pay_Group_lookup_code;
	lp_tapv_rec.trx_status_code	:=  'ENTERED';
	lp_tapv_rec.nettable_yn		:=  'N';

 -- 02-NOV-2006 ANSETHUR  R12B - Legal Entity
 lp_tapv_rec.legal_entity_id	:= okl_legal_entity_util.get_khr_le_id
                                    (p_man_inv_rec.khr_id);

    -- Multi Currency Code, stmathew

    l_currency_code            := NULL;
    l_currency_conversion_type := NULL;
    l_currency_conversion_rate := NULL;
    l_currency_conversion_date := NULL;

    OPEN  l_curr_conv_csr (p_man_inv_rec.khr_id);
    FETCH l_curr_conv_csr INTO  l_currency_code,
                                l_currency_conversion_type,
                                l_currency_conversion_rate,
                                l_currency_conversion_date;
    CLOSE l_curr_conv_csr;

    lp_tapv_rec.currency_code               := l_currency_code;
	lp_tapv_rec.CURRENCY_CONVERSION_TYPE    := l_currency_conversion_type;
	lp_tapv_rec.CURRENCY_CONVERSION_RATE    := l_currency_conversion_rate;
	lp_tapv_rec.CURRENCY_CONVERSION_DATE    := l_currency_conversion_date;


    -- If the type were not captured in authoring
    IF 	lp_tapv_rec.currency_conversion_type IS NULL THEN
        lp_tapv_rec.currency_conversion_type := 'User';
		lp_tapv_rec.currency_conversion_rate := 1;
        lp_tapv_rec.currency_conversion_date := SYSDATE;
    END IF;

    -- For date
    IF lp_tapv_rec.currency_conversion_date IS NULL THEN
	   lp_tapv_rec.currency_conversion_date := SYSDATE;
    END IF;

    -- For rate -- Work out the rate in a Spot or Corporate
    IF (lp_tapv_rec.currency_conversion_type = 'User') THEN
        IF lp_tapv_rec.currency_conversion_rate IS NULL THEN
            lp_tapv_rec.currency_conversion_rate := 1;
        END IF;
    END IF;
    IF (lp_tapv_rec.currency_conversion_type = 'Spot'
            OR lp_tapv_rec.currency_conversion_type = 'Corporate') THEN

             lp_tapv_rec.currency_conversion_rate
                    := okl_accounting_util.get_curr_con_rate
                   (p_from_curr_code => lp_tapv_rec.currency_code,
	                p_to_curr_code => okl_accounting_util.get_func_curr_code,
	                p_con_date => lp_tapv_rec.currency_conversion_date,
	                p_con_type => lp_tapv_rec.currency_conversion_type);
     END IF;

		----------------------------------------------------
		-- Populate internal AP invoice Lines Record
		----------------------------------------------------

  -- sjalasut, added assignment of khr_id to the lines table. changes made as part
  -- of OKLR12B disbursements project
  lp_tplv_rec.khr_id := p_man_inv_rec.khr_id;
		lp_tplv_rec.amount		:=  lp_tapv_rec.amount;
		lp_tplv_rec.sty_id		:=  p_man_inv_rec.sty_id;
		lp_tplv_rec.inv_distr_line_code	:=  'MANUAL';
		lp_tplv_rec.line_number		:=  1;
		lp_tplv_rec.org_id		:=  lp_tapv_rec.org_id;
		lp_tplv_rec.disbursement_basis_code :=  'BILL_DATE';

        -- ----------------------------------------
        -- added sel_id to record def 14-sep-2004
        -- ----------------------------------------
        lp_tplv_rec.id          :=  p_man_inv_rec.sel_id;


  /* ankushar 23-JAN-2007
   Call to the common Disbursement API
   start changes
  */

      -- Add tpl_rec to table
         lp_tplv_tbl(1) := lp_tplv_rec;

      --Call the commong disbursement API to create transactions
        Okl_Create_Disb_Trans_Pvt.create_disb_trx(
             p_api_version      =>   p_api_version
            ,p_init_msg_list    =>   p_init_msg_list
            ,x_return_status    =>   x_return_status
            ,x_msg_count        =>   x_msg_count
            ,x_msg_data         =>   x_msg_data
            ,p_tapv_rec         =>   lp_tapv_rec
            ,p_tplv_tbl         =>   lp_tplv_tbl
            ,x_tapv_rec         =>   lx_tapv_rec
            ,x_tplv_tbl         =>   lx_tplv_tbl);

  /* ankushar end changes */

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN

	 --------------------------------------------
	 -- Populate inserted record details back
	 --------------------------------------------
	 x_man_inv_rec  := p_man_inv_rec;
         --cklee..bug# 5012438..08-Mar-2006
         --populating invoice number into OUT param
         x_man_inv_rec.invoice_number := lp_tapv_rec.invoice_number;
         x_man_inv_rec.vendor_invoice_number := lp_tapv_rec.vendor_invoice_number;

    END IF; -- disbursement API call

EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OKL_API.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS (
  					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');
END manual_entry;

--------------------------------------------------------------------
-- PROCEDURE manual_entry
--------------------------------------------------------------------

PROCEDURE manual_entry (
	 p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	--DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_man_inv_tbl		IN  man_inv_tbl_type
	,x_man_inv_tbl		OUT NOCOPY man_inv_tbl_type) IS

	l_api_version		CONSTANT NUMBER := 1;
	l_api_name		CONSTANT VARCHAR2(30) := 'MANUAL_ENTRY';
	l_return_status		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER := 0;

BEGIN

	-- Enter further code below as specified in the Package spec.
	-- Make sure PL/SQL table has records in it before passing

	IF (p_man_inv_tbl.COUNT > 0) THEN

		i := p_man_inv_tbl.FIRST;

		LOOP

			manual_entry (
				p_api_version	=> l_api_version,
				p_init_msg_list	=> OKL_API.G_FALSE,
				x_return_status	=> x_return_status,
				x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data,
				p_man_inv_rec	=> p_man_inv_tbl(i),
				x_man_inv_rec	=> x_man_inv_tbl(i));

			IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
			    IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			    END IF;
			END IF;

			EXIT WHEN (i = p_man_inv_tbl.LAST);
			i := p_man_inv_tbl.NEXT(i);

		END LOOP;

		x_return_status := l_overall_status;

	END IF;

END manual_entry;

END OKL_PAY_INVOICES_MAN_PVT;

/
