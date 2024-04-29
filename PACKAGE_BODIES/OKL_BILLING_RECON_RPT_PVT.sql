--------------------------------------------------------
--  DDL for Package Body OKL_BILLING_RECON_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILLING_RECON_RPT_PVT" AS
/* $Header: OKLRBREB.pls 120.8.12010000.3 2009/06/03 04:17:58 racheruv ship $ */

------------------------------------------------------------------
-- Procedure recon_report to print status of transaction in OKL
-- and AR for reconciliation purposes
------------------------------------------------------------------
PROCEDURE recon_report
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2
	,p_from_bill_date	IN  DATE
	,p_to_bill_date		IN  DATE) IS

	-- ----------------------------------------------------------
	-- Declare variables required by APIs
	-- ----------------------------------------------------------
	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	    CONSTANT VARCHAR2(30)  := 'OKL_BILLING_RECON_RPT_PVT';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

	-- ----------------------------------------------------------
	-- Record Type for reconciliation report format
	-- ----------------------------------------------------------
    TYPE recon_fmt_rec_type IS RECORD (
     CONTRACT_NUMBER  okl_k_headers_full_v.contract_number%TYPE,
	 currency_code    fnd_currencies_vl.currency_code%TYPE,
	 okl_count  	  NUMBER,
	 okl_amount   	  NUMBER,
	 ar_count  	      NUMBER,
	 ar_amount   	  NUMBER,
	 int_count  	  NUMBER,
	 int_amount   	  NUMBER
	);

	-- --------------------------------------------------------
	-- Record Table Type for reconciliation report format
	-- --------------------------------------------------------
    TYPE recon_fmt_tbl_type IS TABLE OF recon_fmt_rec_type
	     INDEX BY BINARY_INTEGER;

	recon_tbl 				 recon_fmt_tbl_type;
    l_init_recon_tbl         recon_fmt_tbl_type;
    l_tab_index              NUMBER;

    -- --------------------------------------------
    -- OKL Reconciliation Invoice Summary
    -- --------------------------------------------
    CURSOR okl_summary_csr ( p_in_contract_number VARCHAR2 )IS
       SELECT sum(cnt) Number_of_invoices
             ,sum(invoice_amount) Value
             ,currency_code
       FROM
        (SELECT
        COUNT(*) cnt,
        SUM (NVL(xls.amount,0)) invoice_amount,
        xsi.currency_code
        FROM
             okl_trx_ar_invoices_v tai,
             okl_txl_ar_inv_lns_v  til,
             okl_txd_ar_ln_dtls_v  tld,
             okl_ext_sell_invs_v   xsi,
             okl_xtl_sell_invs_v   xls,
             okl_k_headers_full_v  khr
        WHERE tai.id = til.tai_id
        AND til.id = tld.til_id_details
        AND xsi.id = xls.xsi_id_details
        AND xls.tld_id = tld.id
        AND tai.trx_status_code <> 'ERROR'
        AND tai.khr_id = khr.id
        AND khr.contract_number = NVL(p_in_contract_number, khr.contract_number)
        GROUP BY xsi.currency_code)
        GROUP BY currency_code;

    CURSOR okl_wo_summary_csr ( p_in_contract_number VARCHAR2, p_currency_code VARCHAR2 )IS
       SELECT sum(cnt) Number_of_invoices
             ,sum(invoice_amount) Value
             ,currency_code
       FROM
       (SELECT
        COUNT(*) cnt,
        SUM (NVL(xls.amount,0)) invoice_amount,
        xsi.currency_code
        FROM okl_ext_sell_invs_v xsi,
             okl_xtl_sell_invs_v xls,
             okl_trx_ar_invoices_v tai,
             okl_txl_ar_inv_lns_v til,
             okl_k_headers_full_v khr
        WHERE tai.id = til.tai_id
        AND xsi.id = xls.xsi_id_details
        AND xls.til_id = til.id
        AND xsi.currency_code = p_currency_code
        AND tai.trx_status_code <> 'ERROR'
        AND tai.khr_id = khr.id
        AND khr.contract_number = NVL(p_in_contract_number, khr.contract_number)
        GROUP BY xsi.currency_code
        )
        GROUP BY currency_code;

    -- --------------------------------------------
    -- AR Reconciliation Invoice Summary
    -- --------------------------------------------
    CURSOR ar_summary_csr( p_in_contract_number VARCHAR2, p_currency_code VARCHAR2) IS
        SELECT
        count(*) cnt,
        SUM(NVL(line.EXTENDED_AMOUNT,0)) Invoice_Amount,
        hdr.invoice_currency_code
      	FROM ra_customer_trx_all   hdr,
             ra_customer_trx_lines_all line,
             ra_batch_sources_all   batch,
             RA_CUST_TRX_TYPES_ALL trx_type
       	WHERE  line.customer_trx_id = hdr.customer_trx_id
        AND hdr.batch_source_id = batch.batch_source_id
        AND batch.name = 'OKL_CONTRACTS'
        AND line.line_type = 'LINE'
        AND hdr.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID
        AND hdr.invoice_currency_code = p_currency_code
        AND hdr.interface_header_attribute6
             = NVL(p_in_contract_number,hdr.interface_header_attribute6)
        GROUP BY
            hdr.invoice_currency_code
        ORDER BY 3;

    -- --------------------------------------------
    -- Interface Reconciliation Summary
    -- --------------------------------------------
    CURSOR intf_summary_csr( p_in_contract_number VARCHAR2, p_currency_code VARCHAR2) IS
        SELECT count(*) cnt,
               SUM(AMOUNT) Invoice_amt,
               hdr.currency_code
        FROM ra_interface_lines_all hdr,
             RA_CUST_TRX_TYPES_ALL trx_type
        WHERE hdr.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID
        AND   hdr.currency_code = p_currency_code
        AND   hdr.batch_source_name = 'OKL_CONTRACTS'
        AND   hdr.interface_line_attribute6
             = NVL(p_in_contract_number,hdr.interface_line_attribute6)
        GROUP BY
            hdr.currency_code
        ORDER BY 3;

	------------------------------------------------------------
	-- Contract Number Cursor
	------------------------------------------------------------
    CURSOR khr_csr ( p_contract_number VARCHAR2 ) IS
        SELECT *
        FROM OKL_K_HEADERS_FULL_V
        WHERE contract_number = NVL( p_contract_number, contract_number );

	------------------------------------------------------------
	-- OKL Generated Invoices
	------------------------------------------------------------
    CURSOR okl_invs_csr( p_in_contract_number VARCHAR2
                        ,p_in_from_bill_date  DATE
                        ,p_in_to_bill_date    DATE) IS
       SELECT CURRENCY_CODE
              ,XTRX_CONTRACT
              --,TAI
              --,TRX_STATUS_CODE
              ,sum(cnt) Number_of_invoices
              ,sum(amt) Value
       FROM
       (SELECT
        COUNT(*) cnt,
        SUM (NVL(xls.amount,0)) amt,
        xsi.currency_code,
        xls.xtrx_contract,
        tai.trx_status_code tai,
        xsi.trx_status_code
        FROM
             okl_trx_ar_invoices_v tai,
             okl_txl_ar_inv_lns_v  til,
             okl_txd_ar_ln_dtls_v  tld,
             okl_ext_sell_invs_v   xsi,
             okl_xtl_sell_invs_v   xls
        WHERE tai.id = til.tai_id
        AND til.id = tld.til_id_details
        AND xsi.id = xls.xsi_id_details
        AND xls.tld_id = tld.id
        AND tai.trx_status_code <> 'ERROR'
        AND xls.xtrx_contract = NVL ( p_in_contract_number, xls.xtrx_contract )
        AND xsi.trx_date >= NVL( p_in_from_bill_date, xsi.trx_date )
        AND xsi.trx_date <= NVL( p_in_to_bill_date, xsi.trx_date )
        GROUP BY
        xsi.currency_code,
        xls.xtrx_contract,
        xsi.trx_status_code,
        tai.trx_status_code)
        GROUP BY  currency_code,XTRX_CONTRACT;

    CURSOR okl_wo_invs_csr( p_in_contract_number VARCHAR2
                        ,p_in_from_bill_date  DATE
                        ,p_in_to_bill_date    DATE
                        ,p_currency           VARCHAR2) IS
       SELECT CURRENCY_CODE
              ,XTRX_CONTRACT
              --,TAI
              --,TRX_STATUS_CODE
              ,sum(cnt) Number_of_invoices
              ,sum(amt) Value
       FROM
      ( SELECT
        COUNT(*) cnt,
        SUM (NVL(xls.amount,0)) amt,
        xsi.currency_code,
        xls.xtrx_contract,
        tai.trx_status_code tai,
        xsi.trx_status_code
        FROM okl_ext_sell_invs_v xsi,
             okl_xtl_sell_invs_v xls,
             okl_trx_ar_invoices_v tai,
             okl_txl_ar_inv_lns_v til
        WHERE tai.id = til.tai_id
        AND xsi.id = xls.xsi_id_details
        AND xsi.currency_code = p_currency
        AND xls.til_id = til.id
        AND tai.trx_status_code <> 'ERROR'
        AND xls.xtrx_contract = NVL ( p_in_contract_number, xls.xtrx_contract )
        AND xsi.trx_date >= NVL( p_in_from_bill_date, xsi.trx_date )
        AND xsi.trx_date <= NVL( p_in_to_bill_date, xsi.trx_date )
        GROUP BY
        xsi.currency_code,
        xls.xtrx_contract,
        xsi.trx_status_code,
        tai.trx_status_code)
        GROUP BY  currency_code,XTRX_CONTRACT;

    -- ------------------------------------------
    -- Created in AR
    -- ------------------------------------------
    CURSOR ar_invs_csr( p_in_contract_number VARCHAR2
                       ,p_in_from_bill_date  DATE
                       ,p_in_to_bill_date    DATE
                       ,p_currency           VARCHAR2) IS
        SELECT
        count(*) cnt,
        SUM(NVL(line.EXTENDED_AMOUNT,0)) Invoice_Amount,
        hdr.invoice_currency_code,
        hdr.INTERFACE_HEADER_ATTRIBUTE6 Contract_Number--,
--        decode(trx_type.TYPE,'INV','Invoice','CM','Credit Memo') Invoice_Type
      	FROM ra_customer_trx_all   hdr,
             ra_customer_trx_lines_all line,
             ra_batch_sources_all   batch,
             RA_CUST_TRX_TYPES_ALL trx_type
       	WHERE  line.customer_trx_id = hdr.customer_trx_id
        AND hdr.batch_source_id = batch.batch_source_id
        AND batch.name = 'OKL_CONTRACTS'
        AND line.line_type = 'LINE'
        AND hdr.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID
        AND hdr.INTERFACE_HEADER_ATTRIBUTE6 =
           NVL(rtrim(ltrim( p_in_contract_number)),hdr.INTERFACE_HEADER_ATTRIBUTE6)
        AND hdr.trx_date >= NVL( p_in_from_bill_date , hdr.trx_date )
        AND hdr.trx_date <= NVL( p_in_to_bill_date , hdr.trx_date)
        AND hdr.invoice_currency_code = p_currency
        GROUP BY
            hdr.invoice_currency_code,
            hdr.INTERFACE_HEADER_ATTRIBUTE6--,
            --decode(trx_type.TYPE,'INV','Invoice','CM','Credit Memo')
        ORDER BY 3;

    -- ---------------------------------------------
    -- Unprocessed, stuck in ra_interface_lines_all
    -- ---------------------------------------------
    CURSOR ar_interface_invs_csr( p_in_contract_number VARCHAR2
                                 ,p_in_from_bill_date  DATE
                                 ,p_in_to_bill_date    DATE
                                 ,p_currency           VARCHAR2) IS
        SELECT count(*) cnt,
               SUM(AMOUNT) Invoice_amt,
               hdr.currency_code,
               interface_line_attribute6--,
               --decode(trx_type.TYPE,'INV','Invoice','CM','Credit Memo') Invoice_Type
        FROM ra_interface_lines_all hdr,
             RA_CUST_TRX_TYPES_ALL trx_type
        WHERE hdr.batch_source_name = 'OKL_CONTRACTS'
        AND hdr.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID
        AND hdr.INTERFACE_LINE_ATTRIBUTE6 =
            NVL(rtrim(ltrim( p_in_contract_number)),hdr.INTERFACE_LINE_ATTRIBUTE6)
        AND hdr.trx_date >= NVL( p_in_from_bill_date , hdr.trx_date )
        AND hdr.trx_date <= NVL( p_in_to_bill_date , hdr.trx_date )
        AND hdr.currency_code = p_currency
        GROUP BY
            hdr.currency_code,
            hdr.interface_line_attribute6--,
            --decode(trx_type.TYPE,'INV','Invoice','CM','Credit Memo')
        ORDER BY 3;

        ------------------------------------------------------
        -- Local Variables
        ------------------------------------------------------
        l_okl_currency_code     okl_k_headers_full_v.currency_code%TYPE;
        l_okl_contract          okl_k_headers_full_v.contract_number%TYPE;
        l_okl_invoice_count     NUMBER;
        l_okl_invoice_amount    NUMBER;

        l_okl_wo_currency_code  okl_k_headers_full_v.currency_code%TYPE;
        l_okl_wo_contract       okl_k_headers_full_v.contract_number%TYPE;
        l_okl_wo_invoice_count  NUMBER;
        l_okl_wo_invoice_amount NUMBER;

        l_ar_currency_code      okl_k_headers_full_v.currency_code%TYPE;
        l_ar_contract           okl_k_headers_full_v.contract_number%TYPE;
        l_ar_invoice_count      NUMBER;
        l_ar_invoice_amount     NUMBER;

        l_int_currency_code     okl_k_headers_full_v.currency_code%TYPE;
        l_int_contract          okl_k_headers_full_v.contract_number%TYPE;
        l_int_invoice_count     NUMBER;
        l_int_invoice_amount    NUMBER;

        l_cnt_diff 		        NUMBER;
        l_amt_diff 		        NUMBER;

        l_output_var            VARCHAR2(2000);
        l_no_precision_format   VARCHAR2(25) := '99,999,999,999';
        l_two_precision_format  VARCHAR2(25) := '99,999,999,990.99';
        l_three_precision_format  VARCHAR2(25) := '999,999,999,990.999';

        l_number_format         VARCHAR2(25) := '99,999,999,999';
        l_amount_format         VARCHAR2(25) := '999,999,999,990.999';

        CURSOR curr_precision_csr( p_curr_code VARCHAR2 ) IS
            SELECT precision
            FROM fnd_currencies_vl
            WHERE CURRENCY_CODE = p_curr_code;

        l_precision    fnd_currencies_vl.precision%TYPE;

        CURSOR int_err_csr( p_in_contract_number VARCHAR2
                           ,p_in_from_bill_date  DATE
                           ,p_in_to_bill_date    DATE) IS
        SELECT AMOUNT Invoice_amt,
               hdr.currency_code,
               interface_line_attribute6 contract_number,
               INTERFACE_LINE_ATTRIBUTE7 asset,
               INTERFACE_LINE_ATTRIBUTE9 stream_type,
               decode(trx_type.TYPE,'INV','Invoice','CM','Credit Memo') Invoice_Type,
               trx_date due_date,
               err.MESSAGE_TEXT remarks
        FROM ra_interface_lines_all hdr,
             RA_CUST_TRX_TYPES_ALL trx_type,
             ra_interface_errors_all err
        WHERE hdr.batch_source_name = 'OKL_CONTRACTS'
        AND hdr.CUST_TRX_TYPE_ID = trx_type.CUST_TRX_TYPE_ID
        AND hdr.INTERFACE_LINE_ATTRIBUTE6 =
            NVL(rtrim(ltrim( p_in_contract_number)),hdr.INTERFACE_LINE_ATTRIBUTE6)
        AND hdr.trx_date >= NVL( p_in_from_bill_date , hdr.trx_date )
        AND hdr.trx_date <= NVL( p_in_to_bill_date , hdr.trx_date )
        AND hdr.interface_line_id (+) = err.interface_line_id
        ORDER BY 3,4,5,6;

        CURSOR op_unit_csr IS
        SELECT NAME
        FROM hr_operating_units
	WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID; --MOAC- Concurrent request


        l_op_unit_name       hr_operating_units.name%TYPE;

BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	    => l_api_name,
		p_pkg_name	    => G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	    => '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

    ---------------------------------------
    -- Get operating unit name
    ---------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    l_output_var    := NULL;
    l_output_var    := l_output_var||rPAD(' ', 63, ' ');
    l_output_var    := l_output_var||' Oracle Lease and Finance Management';
    l_output_var    := l_output_var||rPAD(' ', 63, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||rPAD(' ', 150, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||rPAD(' ', 60, ' ');
    l_output_var    := l_output_var||' Billing Reconciliation Report';
    l_output_var    := l_output_var||rPAD(' ', 60, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||rPAD(' ', 150, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Run Date: ';
    l_output_var    := l_output_var||to_char(sysdate,'DD-MON-YYYY');
    l_output_var    := l_output_var||rPAD(' ', 107, ' ');
    l_output_var    := l_output_var||'Request Id: ';
    l_output_var    := l_output_var||SUBSTR(lpad(Fnd_Global.CONC_REQUEST_ID,10,' '),1,10);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Operating Unit: ';
    l_output_var    := l_output_var||rpad(l_op_unit_name,134,' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('-', 150, '-'));


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Parameters ';
    l_output_var    := l_output_var||rpad(' ',139,' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    l_output_var    := NULL;
    l_output_var    := l_output_var||'From Date: ';
    l_output_var    := l_output_var||rpad(NVL(to_char(p_from_bill_date,'DD-MON-YYYY'),'Not Supplied'),12,' ');
    l_output_var    := l_output_var||rPAD(' ', 106, ' ');
    l_output_var    := l_output_var||'To Date: ';
    l_output_var    := l_output_var||rpad(NVL(to_char(p_to_bill_date,'DD-MON-YYYY'),'Not Supplied'),12,' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Contract Number: '||NVL(p_contract_number,'Not Supplied'), 150, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('-', 150, '-'));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Invoice Summary';
    l_output_var    := l_output_var||rPAD(' ', 135, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Summary                     Currency          Streams Billed        Bill w/o Streams        Billed in Oracle       Receivables              Difference', 150, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('---------------             --------          in Lease and Finance Management   in Lease and Finance Management     Receivables            Interface             -------------', 150, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('                                              -------------------   --------------------    ----------------       --------------                     ', 150, ' '));

    -- --------------------------------------
    -- OKL Invoice Summary
    -- --------------------------------------
    FOR okl_summary_rec IN okl_summary_csr ( p_contract_number ) LOOP

        ------------------------------------
        -- Null out local variables
        ------------------------------------
        l_okl_currency_code     := NULL;
        l_okl_contract          := NULL;
        l_okl_invoice_count     := NULL;
        l_okl_invoice_amount    := NULL;

        l_okl_wo_invoice_count  := NULL;
        l_okl_wo_invoice_amount := NULL;
        l_okl_wo_currency_code  := NULL;

        l_ar_currency_code      := NULL;
        l_ar_contract           := NULL;
        l_ar_invoice_count      := NULL;
        l_ar_invoice_amount     := NULL;

        l_int_currency_code     := NULL;
        l_int_contract          := NULL;
        l_int_invoice_count     := NULL;
        l_int_invoice_amount    := NULL;

        l_okl_currency_code  := okl_summary_rec.currency_code;
        l_okl_invoice_count  := okl_summary_rec.Number_of_invoices;
        l_okl_invoice_amount := okl_summary_rec.Value;

        OPEN  okl_wo_summary_csr ( p_contract_number, okl_summary_rec.currency_code);
        FETCH okl_wo_summary_csr INTO l_okl_wo_invoice_count,
                                      l_okl_wo_invoice_amount,
                                      l_okl_wo_currency_code;
        CLOSE okl_wo_summary_csr;

        IF l_okl_wo_invoice_count IS NULL THEN
            l_okl_wo_invoice_count := 0;
        END IF;

        IF l_okl_wo_invoice_amount IS NULL THEN
            l_okl_wo_invoice_amount := 0;
        END IF;

        -- --------------------------------------
        -- AR Invoice Summary by Currency
        -- --------------------------------------
        OPEN  ar_summary_csr( p_contract_number, okl_summary_rec.currency_code );
        FETCH ar_summary_csr INTO l_ar_invoice_count,
                                  l_ar_invoice_amount,
                                  l_ar_currency_code;
        CLOSE ar_summary_csr;

        IF l_ar_invoice_count IS NULL THEN
           l_ar_invoice_count := 0;
        END IF;

        IF l_ar_invoice_amount IS NULL THEN
           l_ar_invoice_amount := 0;
        END IF;

        -- --------------------------------------
        -- Interface Invoice Summary by Currency
        -- --------------------------------------
        OPEN  intf_summary_csr( p_contract_number, okl_summary_rec.currency_code );
        FETCH intf_summary_csr INTO l_int_invoice_count,
                                    l_int_invoice_amount,
                                    l_int_currency_code;
        CLOSE intf_summary_csr;

        IF l_int_invoice_count IS NULL THEN
           l_int_invoice_count := 0;
        END IF;

        IF l_int_invoice_amount IS NULL THEN
           l_int_invoice_amount := 0;
        END IF;

        l_cnt_diff 		:= l_okl_invoice_count+l_okl_wo_invoice_count-l_ar_invoice_count-l_int_invoice_count;
        l_amt_diff 		:= l_okl_invoice_amount+l_okl_wo_invoice_amount -l_ar_invoice_amount-l_int_invoice_amount;

        -- ----------------------------------
        -- Fetch currency precision into local
        -- variable
        -- ----------------------------------
        l_precision := NULL;
        OPEN  curr_precision_csr( okl_summary_rec.currency_code );
        FETCH curr_precision_csr INTO l_precision;
        CLOSE curr_precision_csr;

        -- ---------------------------------------
        -- Format Variable Precision for printing
        -- ---------------------------------------
        IF l_precision = 0 THEN
            l_amount_format := l_no_precision_format;
        ELSIF l_precision > 2 THEN
            l_amount_format := l_three_precision_format;
        ELSE
            l_amount_format := l_two_precision_format;
        END IF;

        l_output_var    := NULL;

        l_output_var    := l_output_var||'Number of Invoices:         ';
        l_output_var    := l_output_var||SUBSTR(l_okl_currency_code,1,8);
        l_output_var    := l_output_var||'              ';
        l_output_var    := l_output_var||LPAD(to_char(l_okl_invoice_count,l_number_format),20,' ');
        l_output_var    := l_output_var||'   ';
        l_output_var    := l_output_var||LPAD(to_char(l_okl_wo_invoice_count,l_number_format),20,' ');
--        l_output_var    := l_output_var||' ';
        l_output_var    := l_output_var||LPAD(to_char(l_ar_invoice_count,l_number_format),20,' ');
        l_output_var    := l_output_var||' ';
        l_output_var    := l_output_var||LPAD(to_char(l_int_invoice_count,l_number_format),20,' ');
        l_output_var    := l_output_var||' ';
        l_output_var    := l_output_var||LPAD(to_char(l_cnt_diff,l_number_format),20,' ');
        -- -------------------------------------------------------
        -- Print out the Count of Invoices
        -- -------------------------------------------------------
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

        l_output_var    := NULL;

        l_output_var    := l_output_var||'Value of Invoices :         ';
        l_output_var    := l_output_var||SUBSTR(l_okl_currency_code,1,8);
        l_output_var    := l_output_var||'              ';
        l_output_var    := l_output_var||LPAD(to_char(l_okl_invoice_amount,l_amount_format),20,' ');
        l_output_var    := l_output_var||'   ';
        l_output_var    := l_output_var||LPAD(to_char(l_okl_wo_invoice_amount,l_amount_format),20,' ');
--        l_output_var    := l_output_var||'';
        l_output_var    := l_output_var||LPAD(to_char(l_ar_invoice_amount,l_amount_format),20,' ');
        l_output_var    := l_output_var||' ';
        l_output_var    := l_output_var||LPAD(to_char(l_int_invoice_amount,l_amount_format),20,' ');
        l_output_var    := l_output_var||' ';
        l_output_var    := l_output_var||LPAD(to_char(l_amt_diff,l_amount_format),20,' ');

        -- -------------------------------------------------------
        -- Print out the Value of Invoices
        -- -------------------------------------------------------
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    END LOOP;


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('-', 150, '-'));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Details of Contract having Reconciliation Difference';
    l_output_var    := l_output_var||rPAD(' ', 98, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Contract Number             Currency          Streams Billed        Bill w/o Streams        Billed in Oracle       Receivables              Difference', 150, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('---------------             --------          in Lease and Finance Management   in Lease and Finance Management     Receivables            Interface             -------------', 150, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('                                              -------------------   --------------------    ----------------       --------------                     ', 150, ' '));


    FOR khr_rec IN khr_csr( p_contract_number ) LOOP

        ----------------------------------------------
        -- For invoices generated in OKL
        ----------------------------------------------
        FOR  okl_invs_rec IN okl_invs_csr( khr_rec.contract_number
                                          ,p_from_bill_date
                                          ,p_to_bill_date) LOOP

            ----------------------------------------------
            -- Initialize Variables
            ----------------------------------------------
            l_okl_currency_code     := NULL;
            l_okl_contract          := NULL;
            l_okl_invoice_count     := NULL;
            l_okl_invoice_amount    := NULL;

            l_okl_wo_invoice_count  := NULL;
            l_okl_wo_contract       := NULL;
            l_okl_wo_invoice_amount := NULL;
            l_okl_wo_currency_code  := NULL;

            l_ar_currency_code      := NULL;
            l_ar_contract           := NULL;
            l_ar_invoice_count      := NULL;
            l_ar_invoice_amount     := NULL;

            l_int_currency_code     := NULL;
            l_int_contract          := NULL;
            l_int_invoice_count     := NULL;
            l_int_invoice_amount    := NULL;

            l_okl_currency_code     := okl_invs_rec.currency_code;
            l_okl_contract          := okl_invs_rec.XTRX_CONTRACT;
            l_okl_invoice_count     := okl_invs_rec.Number_of_invoices;
            l_okl_invoice_amount    := okl_invs_rec.Value;

            OPEN  okl_wo_invs_csr( khr_rec.contract_number
                                 ,p_from_bill_date
                                 ,p_to_bill_date
                                 ,okl_invs_rec.currency_code);
            FETCH okl_wo_invs_csr INTO l_okl_wo_currency_code,
                                       l_okl_wo_contract,
                                       l_okl_wo_invoice_count,
                                       l_okl_wo_invoice_amount;
            CLOSE okl_wo_invs_csr;

            IF l_okl_wo_invoice_count IS NULL THEN
                l_okl_wo_invoice_count := 0;
            END IF;

            IF l_okl_wo_invoice_amount IS NULL THEN
                l_okl_wo_invoice_amount := 0;
            END IF;

            -- --------------------------------------------
            -- For OKL invoices Created in AR
            -- --------------------------------------------
            OPEN  ar_invs_csr( khr_rec.contract_number
                              ,p_from_bill_date
                              ,p_to_bill_date
                              ,l_okl_currency_code);
            FETCH ar_invs_csr INTO l_ar_invoice_count,
                                   l_ar_invoice_amount,
                                   l_ar_currency_code,
                                   l_ar_contract;

            CLOSE ar_invs_csr;

            IF l_ar_invoice_count IS NULL THEN
                l_ar_invoice_count := 0;
            END IF;

            IF l_ar_invoice_amount IS NULL THEN
                l_ar_invoice_amount := 0;
            END IF;

            -- --------------------------------------------
            -- For Interface Records
            -- --------------------------------------------
            OPEN  ar_interface_invs_csr( khr_rec.contract_number
                                        ,p_from_bill_date
                                        ,p_to_bill_date
                                        ,l_okl_currency_code);
            FETCH ar_interface_invs_csr INTO l_int_invoice_count,
                                             l_int_invoice_amount,
                                             l_int_currency_code,
                                             l_int_contract;
            CLOSE ar_interface_invs_csr;


            IF l_int_invoice_count IS NULL THEN
                l_int_invoice_count := 0;
            END IF;

            IF l_int_invoice_amount IS NULL THEN
                l_int_invoice_amount := 0;
            END IF;

            l_cnt_diff 		:= l_okl_invoice_count+ l_okl_wo_invoice_count-l_ar_invoice_count-l_int_invoice_count;
            l_amt_diff 		:= l_okl_invoice_amount+l_okl_wo_invoice_amount-l_ar_invoice_amount-l_int_invoice_amount;

            -- ----------------------------------
            -- Fetch currency precision into local
            -- variable
            -- ----------------------------------
            l_precision := NULL;
            OPEN  curr_precision_csr( l_okl_currency_code );
            FETCH curr_precision_csr INTO l_precision;
            CLOSE curr_precision_csr;

           -- ---------------------------------------
           -- Format Variable Precision for printing
           -- ---------------------------------------
           IF l_precision = 0 THEN
             l_amount_format := l_no_precision_format;
           ELSIF l_precision > 2 THEN
             l_amount_format := l_three_precision_format;
           ELSE
             l_amount_format := l_two_precision_format;
           END IF;


            IF (l_cnt_diff <> 0 OR l_amt_diff <> 0) THEN

                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(khr_rec.contract_number||':', 150, ' '));

                l_output_var    := NULL;

                l_output_var    := l_output_var||'   Number of Invoices  :    ';
                l_output_var    := l_output_var||SUBSTR(l_okl_currency_code,1,8);
                l_output_var    := l_output_var||'              ';
                l_output_var    := l_output_var||LPAD(to_char(l_okl_invoice_count,l_number_format),20,' ');
                l_output_var    := l_output_var||'   ';
                l_output_var    := l_output_var||LPAD(to_char(l_okl_wo_invoice_count,l_number_format),20,' ');
--                l_output_var    := l_output_var||'';
                l_output_var    := l_output_var||LPAD(to_char(l_ar_invoice_count,l_number_format),20,' ');
                l_output_var    := l_output_var||' ';
                l_output_var    := l_output_var||LPAD(to_char(l_int_invoice_count,l_number_format),20,' ');
                l_output_var    := l_output_var||' ';
                l_output_var    := l_output_var||LPAD(to_char(l_cnt_diff,l_number_format),20,' ');
                -- -------------------------------------------------------
                -- Print out the Count of Invoices
                -- -------------------------------------------------------
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

                l_output_var    := NULL;

                l_output_var    := l_output_var||'   Value of Invoices   :    ';
                l_output_var    := l_output_var||SUBSTR(l_okl_currency_code,1,8);
                l_output_var    := l_output_var||'              ';
                l_output_var    := l_output_var||LPAD(to_char(l_okl_invoice_amount,l_amount_format),20,' ');
                l_output_var    := l_output_var||'   ';
                l_output_var    := l_output_var||LPAD(to_char(l_okl_wo_invoice_amount,l_amount_format),20,' ');
--                l_output_var    := l_output_var||'';
                l_output_var    := l_output_var||LPAD(to_char(l_ar_invoice_amount,l_amount_format),20,' ');
                l_output_var    := l_output_var||' ';
                l_output_var    := l_output_var||LPAD(to_char(l_int_invoice_amount,l_amount_format),20,' ');
                l_output_var    := l_output_var||' ';
                l_output_var    := l_output_var||LPAD(to_char(l_amt_diff,l_amount_format),20,' ');
                -- -------------------------------------------------------
                -- Print out the Value of Invoices
                -- -------------------------------------------------------
                FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

                FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
            END IF;

        END LOOP;

    END LOOP;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('-', 150, '-'));

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Note: Above contracts may be reconciled by running following reports';
    l_output_var    := l_output_var||rPAD(' ', 82, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||'1)	Prepare Receivables Bills';
    l_output_var    := l_output_var||rPAD(' ', 122, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||'2)	Receivables Bills Consolidation';
    l_output_var    := l_output_var||rPAD(' ', 116, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    l_output_var    := NULL;
    l_output_var    := l_output_var||'3)	Receivables Invoices Transfer to AR';
    l_output_var    := l_output_var||rPAD(' ', 112, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    -- --------------------------------------------
    -- Print Interface Errors
    -- --------------------------------------------
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    l_output_var    := NULL;
    l_output_var    := l_output_var||'Details of Contracts not processed from Receivables Interface';
    l_output_var    := l_output_var||rPAD(' ', 89, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('Contract Number             Asset             Invoice Date              Amount             Stream Type                  Remarks   ', 150, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('---------------             --------          -------------             -------------      -------------               -------------', 150, ' '));

    FOR khr_rec IN khr_csr( p_contract_number ) LOOP

        FOR interface_rec IN int_err_csr( khr_rec.contract_number
                                     	 ,p_from_bill_date
	                                     ,p_to_bill_date ) LOOP

             -- ----------------------------------
             -- Fetch currency precision into local
             -- variable
             -- ----------------------------------
             l_precision := NULL;
             OPEN  curr_precision_csr( interface_rec.currency_code );
             FETCH curr_precision_csr INTO l_precision;
             CLOSE curr_precision_csr;

            -- ---------------------------------------
            -- Format Variable Precision for printing
            -- ---------------------------------------
            IF l_precision = 0 THEN
              l_amount_format := l_no_precision_format;
            ELSIF l_precision > 2 THEN
              l_amount_format := l_three_precision_format;
            ELSE
              l_amount_format := l_two_precision_format;
            END IF;

            l_output_var    := NULL;

            l_output_var    := l_output_var||RPAD(SUBSTR(interface_rec.contract_number,1,25),28,' ');
            l_output_var    := l_output_var||RPAD(SUBSTR(NVL(interface_rec.asset,'None'),1,15),22,' ');
            l_output_var    := l_output_var||SUBSTR(NVL(to_char(interface_rec.due_date,'DD-MON-YYYY'),'None'),1,13);
            l_output_var    := l_output_var||LPAD(to_char(NVL(interface_rec.Invoice_amt,0),l_amount_format),26,' ');
            l_output_var    := l_output_var||'      ';
            l_output_var    := l_output_var||SUBSTR(NVL(interface_rec.stream_type,'None'),1,25);
            l_output_var    := l_output_var||RPAD(' ',17,' ');
            l_output_var    := l_output_var||NVL(interface_rec.remarks,'None');

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, l_output_var);
        END LOOP;
    END LOOP;
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD('-', 150, '-'));

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
    l_output_var    := NULL;
    l_output_var    := l_output_var||'NOTE: Invoices in Receivables interfaces can be cleared by resolving errors in the interface,';
    l_output_var    := l_output_var||' if any, and running Autoinvoice program.';
    l_output_var    := l_output_var||rPAD(' ', 16, ' ');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,l_output_var);


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
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (EXCP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (UNEXP) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END recon_report;


PROCEDURE recon_report_conc (
          errbuf  OUT NOCOPY VARCHAR2
         ,retcode OUT NOCOPY NUMBER
         ,p_from_bill_date  IN VARCHAR2
         ,p_to_bill_date  IN VARCHAR2
         ,p_contract_number  IN VARCHAR2) IS

  l_api_version	   CONSTANT NUMBER := 1;
  l_msg_count      NUMBER;
  l_return_status  VARCHAR2(1):= 'S';

  l_from_bill_date DATE;
  l_to_bill_date   DATE;

BEGIN

    IF p_from_bill_date IS NOT NULL THEN
        l_from_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_bill_date);
    END IF;

    IF p_to_bill_date IS NOT NULL THEN
        l_to_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_bill_date);
    END IF;

      OKL_BILLING_RECON_RPT_PVT.recon_report(
                p_api_version     => l_api_version,
                p_init_msg_list   => Okl_Api.G_FALSE,
                x_return_status   => l_return_status,
                x_msg_count       => l_msg_count,
                x_msg_data        => errbuf,
                p_contract_number => p_contract_number,
                p_from_bill_date  => l_from_bill_date,
	            p_to_bill_date	  => l_to_bill_date);

EXCEPTION
   WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
END recon_report_conc;


END OKL_BILLING_RECON_RPT_PVT;

/
