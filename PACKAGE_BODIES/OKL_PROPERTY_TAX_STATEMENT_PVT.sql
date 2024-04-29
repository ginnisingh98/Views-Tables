--------------------------------------------------------
--  DDL for Package Body OKL_PROPERTY_TAX_STATEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROPERTY_TAX_STATEMENT_PVT" AS
/* $Header: OKLRPTSB.pls 120.9.12010000.3 2009/06/03 04:21:50 racheruv ship $ */

  -- Function for length formatting
  -------------------------------------------------------------------------------
  -- FUNCTION get_proper_length
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : get_proper_length
  -- Description     : This function formats the columns in the report
  --                 :
  -- Business Rules  :
  -- Parameters      : p_input_data, p_input_length, p_input_type
  -- Version         : 1.0
  -- History         : 20-OCT-2004 GIRAO created
  -- End of comments

  FUNCTION get_proper_length(p_input_data          IN   VARCHAR2,
                             p_input_length        IN   NUMBER,
                             p_input_type          IN   VARCHAR2)
    RETURN VARCHAR2 IS
    x_return_data VARCHAR2(1000);
  BEGIN
    IF(p_input_type = 'TITLE') THEN
      IF(p_input_data IS NOT NULL) THEN
        x_return_data := RPAD(SUBSTR(ltrim(rtrim(p_input_data)),1,p_input_length),p_input_length,' ');
      ELSE
        x_return_data := RPAD(' ',p_input_length,' ');
      END IF;
    ELSE
      IF(p_input_data IS NOT NULL) THEN
        IF(length(p_input_data) > p_input_length) THEN
          x_return_data := RPAD(SUBSTR(p_input_data,1,p_input_length-3),3,'.');
        ELSE
          x_return_data := RPAD(p_input_data,p_input_length,' ');
        END IF;
      ELSE
        x_return_data := RPAD(' ',p_input_length,' ');
      END IF;
    END IF;
    RETURN x_return_data;
  END GET_PROPER_LENGTH;


  -------------------------------------------------------------------------------
  -- PROCEDURE do_report
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : do_report
  -- Description     : This procedure generates the report for estimated property tax
  --                 :
  -- Business Rules  :
  -- Parameters      : p_errbuf, p_retcode, p_cont_num_from, p_cont_num_to, p_asset_name_from, p_asset_name_to
  -- Version         : 1.0
  -- History         : 20-OCT-2004 GIRAO created
  -- End of comments

  PROCEDURE do_report(p_errbuf            OUT  NOCOPY VARCHAR2,
                      p_retcode           OUT  NOCOPY NUMBER,
                      p_cont_num_from     IN   VARCHAR2,
                      p_cont_num_to       IN   VARCHAR2,
                      p_asset_name_from   IN   VARCHAR2,
                      p_asset_name_to     IN   VARCHAR2)
    IS
    --Cursor to get the Contract id and Asset id from the given contract number and asset number range
    CURSOR c_cntrct_asst_id_csr(cp_cont_num_from okc_k_headers_b.contract_number%TYPE,
                           cp_cont_num_to okc_k_headers_b.contract_number%TYPE,
                           cp_asset_name_from okx_asset_lines_v.name%TYPE,
                           cp_asset_name_to okx_asset_lines_v.name%TYPE) IS
     SELECT asset.chr_id CHR_ID,
            asset.id KLE_ID
       FROM okc_k_headers_b chr,
            okl_k_lines_full_v asset ,
            okc_line_styles_b ls
      WHERE chr.contract_number BETWEEN NVL(cp_cont_num_from,chr.contract_number) AND NVL(cp_cont_num_to,chr.contract_number)
        AND asset.chr_id = chr.id
        AND asset.name BETWEEN NVL(cp_asset_name_from,asset.name) AND NVL(cp_asset_name_to,asset.name)
        AND ls.id = asset.lse_id
        AND ls.lty_code = 'FREE_FORM1';


    -- Cursor to get the actual property tax.
--fix for bug 4003861
    CURSOR c_act_ppt_tax(cp_khr_id OKC_K_HEADERS_B.ID%TYPE,cp_kle_id OKX_ASSET_LINES_V.ID1%TYPE) IS
    SELECT  khr.contract_number,
           asset.name,
           ptv.JURSDCTN_NAME  ,
           trunc(stream_element_date) lien_date ,
           sty.STREAM_TYPE_PURPOSE ,
           sty.name STREAM_TYPE,
           trunc(ste.stream_element_date) stream_element_date,
           ste.amount amount_imp ,
           decode(date_billed,NULL,0,ste.amount) amount_billed,
           decode(date_billed,NULL,0,ste.amount) amount
     FROM  okl_strm_elements    ste,
           okl_streams    stm,
           okl_strm_type_v    sty,
           okc_k_headers_b    khr,
           okl_k_headers    khl,
           okl_k_lines_full_v asset,
           okc_line_styles_b ls,
           okl_property_tax_v ptv,
           okc_k_lines_b    kle,
           okc_statuses_b    khs,
           okc_statuses_b    kls
     WHERE ste.amount             <> 0
       AND    stm.id    = ste.stm_id
--       AND    stm.active_yn    = 'Y'
--       AND    stm.say_code    = 'CURR'
       AND    sty.id    = stm.sty_id
       AND    sty.billable_yn        = 'Y'
       AND sty.STREAM_TYPE_PURPOSE = 'ACTUAL_PROPERTY_TAX'
       AND    khr.id    = stm.khr_id
       AND    khr.scs_code    IN ('LEASE', 'LOAN')
       AND khr.id = cp_khr_id
       AND asset.chr_id = khr.id
-- Add
       AND asset.id = stm.kle_id
-- Add
       AND asset.id = cp_kle_id
       AND ls.id = asset.lse_id
       AND ls.lty_code = 'FREE_FORM1'
       AND ptv.id = ste.source_id
       AND ste.source_table = 'OKL_PROPERTY_TAX_V'
       AND    khl.id    = stm.khr_id
       AND    khl.deal_type        IS NOT NULL
       AND    khs.code    = khr.sts_code
--       AND    khs.ste_code    = 'ACTIVE'
       AND    kle.id(+)    = stm.kle_id
       AND    kls.code(+)    = kle.sts_code
       AND    NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED');

   -- Cursor to get the estimated property tax.
   CURSOR c_estm_ppt_tax(cp_khr_id OKC_K_HEADERS_B.ID%TYPE,cp_kle_id OKX_ASSET_LINES_V.ID1%TYPE) IS
     SELECT khr.contract_number,
            asset.name,
            sty.STREAM_TYPE_PURPOSE ,
            sty.name STREAM_TYPE,
            trunc(ste.stream_element_date) stream_element_date,
            ste.amount  amount
       FROM	okl_strm_elements	ste,
            okl_streams			    stm,
            okl_strm_type_v			sty,
            okc_k_headers_all_b			khr,
            okl_k_lines_full_v    asset,
            okc_line_styles_b        ls,
            okl_k_headers			khl,
            okc_k_lines_b			kle,
            okc_statuses_b			khs,
            okc_statuses_b			kls
      WHERE ste.amount 			<> 0
            AND	stm.id				= ste.stm_id
            AND	ste.date_billed		IS NOT NULL
--            AND	stm.active_yn		= 'Y'
          --AND stm.kle_id          = cp_kle_id
--            AND	stm.say_code		= 'CURR'
            AND	sty.id				= stm.sty_id
            AND	sty.billable_yn		= 'Y'
            AND sty.STREAM_TYPE_PURPOSE = 'ESTIMATED_PROPERTY_TAX'
            AND	khr.id				= stm.khr_id
            AND	khr.scs_code		IN ('LEASE', 'LOAN')
          --AND khr.sts_code        IN ( 'TERMINATED')
            AND khr.id              = cp_khr_id
            AND asset.chr_id = khr.id
-- Add
            AND asset.id = stm.kle_id
-- Add
            AND asset.id = cp_kle_id
            AND ls.id = asset.lse_id
            AND ls.lty_code = 'FREE_FORM1'
            AND	khl.id				= stm.khr_id
            AND	khl.deal_type		IS NOT NULL
            AND	khs.code			= khr.sts_code
--            AND	khs.ste_code		= 'ACTIVE'
            AND	kle.id			(+)	= stm.kle_id
            AND	kls.code		(+)	= kle.sts_code
            AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED')
       UNION
     SELECT khr.contract_number,
            asset.name,
            sty.STREAM_TYPE_PURPOSE ,
            sty.name STREAM_TYPE,
            tai.date_invoiced,
            til.amount amount
       FROM okc_k_headers_all_b khr,
            okl_trx_ar_invoices_b tai,
            okl_txl_ar_inv_lns_b til,
            okl_strm_type_v sty,
            okl_k_lines_full_v asset,
            okc_line_styles_b ls
      WHERE khr.id = cp_khr_id
        AND asset.chr_id = khr.id
        AND asset.id = til.kle_id
        AND ls.id = asset.lse_id
        AND ls.lty_code = 'FREE_FORM1'
     -- AND khr.sts_code        IN ( 'TERMINATED')
        AND tai.khr_id = khr.id
        AND tai.id = til.tai_id
        AND tai.qte_id IS NOT NULL
        AND til.sty_id = sty.id
        AND til.kle_id = cp_kle_id
        AND sty.STREAM_TYPE_PURPOSE = 'AMPRTX';

   -- Cursor to get the adjusted property tax.
--fix for bug 4003861
   CURSOR c_adjst_ppt_tax(cp_khr_id OKC_K_HEADERS_B.ID%TYPE,cp_kle_id OKX_ASSET_LINES_V.ID1%TYPE) IS
     SELECT khr.contract_number,
            asset.name,
            sty.STREAM_TYPE_PURPOSE ,
            sty.name STREAM_TYPE,
            trunc(ste.stream_element_date) stream_element_date,
            ste.amount amount
      FROM	 okl_strm_elements	ste,
            okl_streams stm,
            okl_strm_type_v	sty,
            okc_k_headers_b	khr,
            okl_k_headers	khl,
            okl_k_lines_full_v asset,
            okc_line_styles_b ls,
            okc_k_lines_b	kle,
            okc_statuses_b	khs,
            okc_statuses_b	kls
      WHERE ste.amount 			<> 0
        AND	ste.date_billed		IS NOT NULL
        AND	stm.id				= ste.stm_id
        AND	stm.active_yn		= 'Y'
     -- AND stm.kle_id          = cp_kle_id
        AND	stm.say_code		= 'CURR'
        AND	sty.id				= stm.sty_id
        AND	sty.billable_yn		= 'Y'
        AND sty.STREAM_TYPE_PURPOSE = 'ADJUSTED_PROPERTY_TAX'
        AND	khr.id				= stm.khr_id
        AND	khr.scs_code		IN ('LEASE', 'LOAN')
    --  AND khr.sts_code        IN ( 'TERMINATED')
        AND khr.id = cp_khr_id
        AND asset.chr_id = khr.id
-- Add
        AND asset.id = stm.kle_id
-- Add
        AND asset.id = cp_kle_id
        AND ls.id = asset.lse_id
        AND ls.lty_code = 'FREE_FORM1'
        AND	khl.id	= stm.khr_id
        AND	khl.deal_type		IS NOT NULL
        AND	khs.code	= khr.sts_code
        AND	khs.ste_code		= 'ACTIVE'
        AND	kle.id	(+)	= stm.kle_id
        AND	kls.code(+)	= kle.sts_code
        AND	NVL (kls.ste_code, 'ACTIVE') IN ('ACTIVE', 'TERMINATED');

    CURSOR get_operating_unit_csr IS
      SELECT name
        FROM hr_operating_units
       WHERE organization_id = mo_global.get_current_org_id() ;
    --local variables
    l_op_unit             HR_OPERATING_UNITS.name%type;
    l_curr_code           VARCHAR2(30) DEFAULT NULL;
    l_request_id          NUMBER DEFAULT 0;
    l_cont_id             OKC_K_HEADERS_B.id%TYPE DEFAULT NULL;
    l_asset_id            OKX_ASSET_LINES_V.id1%TYPE DEFAULT NULL;
    l_act_amt             NUMBER DEFAULT 0;
    -- added by stmathew
    l_imp_amt             NUMBER DEFAULT 0;

    l_est_amt             NUMBER DEFAULT 0;
    l_adjst_amt           NUMBER DEFAULT 0;
    l_excs_amt            NUMBER DEFAULT 0;

    --length
    l_Contract#_len		     CONSTANT NUMBER DEFAULT 30;
    l_asset_name_len      CONSTANT NUMBER DEFAULT 18;
    l_jurisd_name_len     CONSTANT NUMBER DEFAULT 18;
    l_lien_date_len       CONSTANT NUMBER DEFAULT 10;
    l_apt_amount_len      CONSTANT NUMBER DEFAULT 16;
    l_amt_billable_len    CONSTANT NUMBER DEFAULT 13;
    l_strm_purpose_len    CONSTANT NUMBER DEFAULT 25;
    l_strm_type_len       CONSTANT NUMBER DEFAULT 40;
    l_date_len            CONSTANT NUMBER DEFAULT 12;
    l_bill_amount_len     CONSTANT NUMBER DEFAULT 10;
    l_lim_length_len      CONSTANT NUMBER DEFAULT 116;
    l_total_length_len    CONSTANT NUMBER DEFAULT 193;

    -- added by Stmathew
    -- to decide whether or print the trailing line
    some_data             VARCHAR2(1);

  BEGIN
    -- one time initializations
    l_curr_code := okl_accounting_util.get_func_curr_code;
    l_request_id := Fnd_Global.CONC_REQUEST_ID;

    --Product Title for the report: Oracle Lease and Finance Management
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ', 63 , ' ' ) ||  fnd_message.get_string('OKL','OKL_TITLE') || RPAD(' ', 63 , ' ' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

    --Title of the report: Property Tax Statement
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ', 64 , ' ' ) || fnd_message.get_string('OKL','OKL_BPD_PTAX_RPT_TITLE') || RPAD(' ', 53 , ' ' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length_len, '-' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

    --Fetch Operating unit from the profile
    OPEN get_operating_unit_csr;
    FETCH get_operating_unit_csr INTO l_op_unit;
    CLOSE get_operating_unit_csr;

    --Display Operating unit, Request Id and input parameters. Display the input parameters only if they have been passed
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(fnd_message.get_string( 'OKL', 'OKL_OPERATING_UNIT')|| ':',l_Contract#_len,' ')
                      || RPAD(l_op_unit,30,' ') || RPAD( ' ', 72 , ' ') || RPAD(fnd_message.get_string('FND', 'REQUEST ID'),25,' ') ||':'|| l_request_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string( 'AR', 'AR_NLS_AAP_REPORT_PARAMETERS')||':' );

    IF(p_cont_num_from IS NOT NULL) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',l_Contract#_len, ' ')  || RPAD(fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_CNTRCT_FRM'),22,' ') ||':'|| p_cont_num_from );
    END IF;
    IF(p_cont_num_to IS NOT NULL) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',l_Contract#_len, ' ')  || RPAD(fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_CNTRCT_TO'),22,' ') ||':'|| p_cont_num_to);
    END IF;
    IF(p_asset_name_from IS NOT NULL) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',l_Contract#_len, ' ')  || RPAD(fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_ASSET_FRM'),22,' ')||':' ||p_asset_name_from);
    END IF;
    IF(p_asset_name_to IS NOT NULL) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',l_Contract#_len, ' ')  || RPAD(fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_ASSET_TO'),22,' ')||':'||p_asset_name_to );
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

    --Display the Titles Actual Property Tax and Billing Details
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',l_Contract#_len, ' ')  || fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_ACT_TITLE') || RPAD(' ',58, ' ') || fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_BILL_TITLE') );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 105, '-')||'  '||RPAD('-',86,'-'));

    --Display all the column headers in the table
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_CTR_NUM'),l_Contract#_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_ASSET_NUMBER' ),l_asset_name_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_JURISDCTN') ,l_jurisd_name_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_LIEN_DATE') ,l_lien_date_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_AMT_IMP' ) ,l_apt_amount_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_AMT_BILL') ,l_amt_billable_len,'TITLE')||
                                      RPAD( ' ', 2, ' ') ||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_STRM_PURP' ) ,l_strm_purpose_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL', 'OKL_BPD_PTAX_RPT_STRM_TYPE') ,l_strm_type_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL','OKL_BPD_PTAX_RPT_DATE'),l_date_len,'TITLE')||
                                      GET_PROPER_LENGTH( fnd_message.get_string('OKL','OKL_BPD_PTAX_RPT_AMT' ) ,l_bill_amount_len,'TITLE'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 105, '-' )||'  '||RPAD('-',86,'-' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 105, '-' )||'  '||RPAD('-',86,'-' ));

    --Open the cursor and fetch all contracts and assets in the specified range
    FOR r_cntrct_asst_id_csr IN c_cntrct_asst_id_csr(p_cont_num_from,p_cont_num_to,p_asset_name_from,p_asset_name_to) LOOP
      --get  single contract and its asset from cursor
      l_cont_id  := r_cntrct_asst_id_csr.chr_id;
      l_asset_id := r_cntrct_asst_id_csr.kle_id;
      --initialise the amounts to zero
      l_act_amt  := 0;
      l_imp_amt  := 0;
      l_est_amt  := 0;
      l_adjst_amt:= 0;
      l_excs_amt := 0;

      -- added by stmathew
      some_data := 'N';
      --Fetch Actual property tax for the asset
      FOR p_act_ppt_tax IN c_act_ppt_tax(l_cont_id,l_asset_id) LOOP
        some_data := 'Y';
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(p_act_ppt_tax.contract_number,l_Contract#_len,'DATA')||
                                          GET_PROPER_LENGTH(p_act_ppt_tax.name,l_asset_name_len,'DATA')||
                                          GET_PROPER_LENGTH(p_act_ppt_tax.JURSDCTN_NAME ,l_jurisd_name_len,'DATA')||
                                          GET_PROPER_LENGTH(p_act_ppt_tax.lien_date ,l_lien_date_len,'DATA')||
                                          GET_PROPER_LENGTH(okl_accounting_util.format_amount(p_act_ppt_tax.amount_imp,l_curr_code) ,l_apt_amount_len,'DATA')||
                                          GET_PROPER_LENGTH(okl_accounting_util.format_amount(p_act_ppt_tax.amount_billed,l_curr_code),l_amt_billable_len,'DATA')||
                                          RPAD( ' ', 2, ' ') ||
                                          GET_PROPER_LENGTH(p_act_ppt_tax.STREAM_TYPE_PURPOSE,l_strm_purpose_len,'DATA')||
                                          GET_PROPER_LENGTH(p_act_ppt_tax.STREAM_TYPE,l_strm_type_len,'DATA')||
                                          GET_PROPER_LENGTH(p_act_ppt_tax.stream_element_date,l_date_len,'DATA')||
                                          GET_PROPER_LENGTH(okl_accounting_util.format_amount(p_act_ppt_tax.amount,l_curr_code) ,l_bill_amount_len,'DATA'));
        l_act_amt :=  l_act_amt +  p_act_ppt_tax.amount;
        l_imp_amt := l_imp_amt  +  p_act_ppt_tax.amount_imp;
      END LOOP;
      --Fetch Estimated property tax for the asset
      FOR p_estm_ppt_tax IN c_estm_ppt_tax(l_cont_id,l_asset_id) LOOP
        some_data := 'Y';
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(p_estm_ppt_tax.contract_number,l_Contract#_len,'DATA')||
                                          GET_PROPER_LENGTH(p_estm_ppt_tax.name,l_asset_name_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL ,l_jurisd_name_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL ,l_lien_date_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL,l_apt_amount_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL ,l_amt_billable_len,'DATA')||
                                          RPAD( ' ', 2, ' ') ||
                                          GET_PROPER_LENGTH(p_estm_ppt_tax.STREAM_TYPE_PURPOSE ,l_strm_purpose_len,'DATA')||
                                          GET_PROPER_LENGTH(p_estm_ppt_tax.STREAM_TYPE ,l_strm_type_len,'DATA')||
                                          GET_PROPER_LENGTH(p_estm_ppt_tax.stream_element_date,l_date_len,'DATA')||
                                          GET_PROPER_LENGTH(okl_accounting_util.format_amount(p_estm_ppt_tax.amount,l_curr_code) ,l_bill_amount_len,'DATA'));
        l_est_amt :=  l_est_amt +  p_estm_ppt_tax.amount;
      END LOOP;
      --Fetch Adjusted property tax for the asset
      FOR p_adjst_ppt_tax IN c_adjst_ppt_tax(l_cont_id,l_asset_id) LOOP
        some_data := 'Y';
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,GET_PROPER_LENGTH(p_adjst_ppt_tax.contract_number,l_Contract#_len,'DATA')||
                                          GET_PROPER_LENGTH(p_adjst_ppt_tax.name,l_asset_name_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL ,l_jurisd_name_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL ,l_lien_date_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL,l_apt_amount_len,'DATA')||
                                          GET_PROPER_LENGTH(NULL ,l_amt_billable_len,'DATA')||
                                          RPAD( ' ', 2, ' ') ||
                                          GET_PROPER_LENGTH(p_adjst_ppt_tax.STREAM_TYPE_PURPOSE ,l_strm_purpose_len,'DATA')||
                                          GET_PROPER_LENGTH(p_adjst_ppt_tax.STREAM_TYPE ,l_strm_type_len,'DATA')||
                                          GET_PROPER_LENGTH(p_adjst_ppt_tax.stream_element_date,l_date_len,'DATA')||
                                          GET_PROPER_LENGTH(okl_accounting_util.format_amount(p_adjst_ppt_tax.amount,l_curr_code) ,l_bill_amount_len,'DATA'));
        l_adjst_amt :=  l_adjst_amt +  p_adjst_ppt_tax.amount;
      END LOOP;

      -- To avoid unnecessary printing of lines
      IF some_data = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 105, '-' )||'  '||RPAD('-',86,'-' ));


--      IF(l_act_amt <> 0 OR l_est_amt <>0 OR l_adjst_amt <> 0) THEN
--        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 105, '-' )||'  '||RPAD('-',86,'-' ));
        --l_excs_amt := l_act_amt - l_est_amt - l_adjst_amt;
        l_excs_amt :=  (l_act_amt + l_est_amt)- l_imp_amt; -- l_act_amt - l_est_amt - l_adjst_amt;
        IF( l_excs_amt < 0) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',132, ' ')  || RPAD(fnd_message.get_string('OKL','OKL_BPD_PTAX_RPT_SHORT'),l_strm_type_len,' ') ||RPAD(' ',l_date_len,' ')||okl_accounting_util.format_amount(l_excs_amt,l_curr_code));
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(' ',132, ' ')  || RPAD(fnd_message.get_string('OKL','OKL_BPD_PTAX_RPT_EXCESS'),l_strm_type_len,' ') ||RPAD(' ',l_date_len,' ')||okl_accounting_util.format_amount(l_excs_amt,l_curr_code));
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 105, '-' )||'  '||RPAD('-',86,'-' ));
--      END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_errbuf := SQLERRM;
      p_retcode := 2;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);
      IF(SQLCODE <> -20001) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        RAISE;
      ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
  END do_report;

END okl_property_tax_statement_pvt;

/
