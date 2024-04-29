--------------------------------------------------------
--  DDL for Package Body OKL_EVERGREEN_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EVERGREEN_BILLING_PVT" AS
/* $Header: OKLREGBB.pls 120.17 2007/12/07 10:03:24 varangan noship $ */

  ------------------------------------------------------------------
  -- Procedure BIL_EVERGREEN_STREAMS to bill for Evergreen Streams
  ------------------------------------------------------------------

  PROCEDURE BILL_EVERGREEN_STREAMS
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL) IS

	------------------------------------------------------------
	-- Pick Evergreen Contract Id's
	------------------------------------------------------------
	CURSOR evergreen_contracts_csr ( p_contract_number VARCHAR2 ) IS
		   SELECT oklh.id khr_id,
                  okch.contract_number,
                  nvl(stm.kle_id, -99) kle_id
		   FROM okl_k_headers	  oklh,
		   	 	okc_k_headers_b   okch,
	 			okc_statuses_b	  khs,
                okl_streams	   	  stm
		   WHERE  oklh.id 			    = okch.id
		   AND    okch.contract_number	= NVL (p_contract_number,	okch.contract_number)
		   AND	  okch.scs_code			IN ('LEASE', 'LOAN')
		   AND    okch.sts_code 		= 'EVERGREEN'
		   AND	  khs.code			    = okch.sts_code
           AND    oklh.id               = stm.khr_id
           AND EXISTS (SELECT 1 FROM okl_strm_type_v sty
                       WHERE    stm.sty_id            = sty.id
                       --change for User Defined Streams, by pjgomes, on 18 Oct 2004
                       --AND    sty.name              IN ('RENT', 'SERVICE AND MAINTENANCE', 'ESTIMATED PERSONAL PROPERTY TAX'))
                       AND    sty.stream_type_purpose IN ('RENT', 'SERVICE_PAYMENT', 'ESTIMATED_PROPERTY_TAX', 'FEE_PAYMENT'))
           AND (stm.kle_id is not null and EXISTS (SELECT 1 FROM  OKC_K_LINES_B CLE
                                WHERE cle.dnz_chr_id = oklh.id
                                AND   cle.id = stm.kle_id
                                AND   cle.sts_code = 'EVERGREEN') OR stm.kle_id IS NULL)
           GROUP BY  oklh.id,
                     okch.contract_number,
                     nvl(stm.kle_id, -99);

	------------------------------------------------------------
	-- Extract all streams to be billed
	------------------------------------------------------------
	CURSOR c_stm_id ( p_khr_id NUMBER, p_kle_id NUMBER) IS
		   SELECT khr.contract_number contract_number,
                  stm.kle_id,  --added by pgomes
                  stm.id   stm_id,
		   		        sty.stream_type_purpose sty_name
		   FROM okl_k_headers_full_v  khr,
                okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE khr.id = p_khr_id
           AND   stm.khr_id = khr.id
           AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
       --change for User Defined Streams, by pjgomes, on 18 Oct 2004
       --AND 	 sty.name IN ('SERVICE AND MAINTENANCE EVERGREEN', 'EVERGREEN RENT', 'ESTIMATED PERSONAL PROPERTY TAX EVERGREEN')
		   AND 	 sty.stream_type_purpose IN ('SERVICE_RENEWAL', 'RENEWAL_RENT', 'RENEWAL_PROPERTY_TAX', 'FEE_RENEWAL')
       AND   stm.say_code = 'CURR'
       AND   stm.active_yn = 'Y';

	------------------------------------------------------------
	-- Get Count of all streams
	------------------------------------------------------------
	CURSOR c_stm_count_csr ( p_khr_id NUMBER, p_kle_id NUMBER) IS
		   SELECT count(*)
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
           AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
       --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		   --AND 	 sty.name IN ('SERVICE AND MAINTENANCE EVERGREEN', 'EVERGREEN RENT', 'ESTIMATED PERSONAL PROPERTY TAX EVERGREEN')
		   AND 	 sty.stream_type_purpose IN ('SERVICE_RENEWAL', 'RENEWAL_RENT', 'RENEWAL_PROPERTY_TAX', 'FEE_RENEWAL')
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y';

	------------------------------------------------------------
	-- Get Count of specific stream type
	------------------------------------------------------------
	CURSOR c_sty_count_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2 ) IS
		   SELECT count(*)
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
           AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y'
		   AND 	 sty.stream_type_purpose = p_sty_purpose;

	------------------------------------------------------------
	-- Get Copy parameters
	------------------------------------------------------------
	/*CURSOR c_copy_params_csr ( p_khr_id NUMBER) IS
		   SELECT stm.kle_id, stm.say_code, stm.active_yn
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
		   AND 	 stm.sty_id = sty.id
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y'
		   AND 	 sty.name IN ('RENT');*/

	------------------------------------------------------------
	-- Get Sty Id
	------------------------------------------------------------
	/*CURSOR get_sty_id_csr ( p_sty_purpose VARCHAR2 ) IS
		   SELECT id
		   FROM okl_strm_type_v
		   WHERE stream_type_purpose = p_sty_purpose; */

	------------------------------------------------------------
	-- Get Sty Id for a line and purpose
	------------------------------------------------------------
	CURSOR get_prim_sty_id_csr( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2 ) IS
		   SELECT stm.sty_id
		   FROM okl_streams	   		  stm,
		   		  okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
       AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		   AND 	 stm.sty_id = sty.id
       AND   stm.say_code = 'CURR'
       AND   stm.active_yn = 'Y'
		   AND 	 sty.stream_type_purpose = p_sty_purpose;

	------------------------------------------------------------
	-- Get Stm attributes
	------------------------------------------------------------
	/*CURSOR get_stm_attrs_csr ( p_khr_id NUMBER, p_sty_name VARCHAR2 ) IS
		   SELECT stm.kle_id
		   FROM okl_streams	   		  stm,
		   		okl_strm_type_v 	  sty
		   WHERE stm.khr_id = p_khr_id
		   AND 	 stm.sty_id = sty.id
           AND   stm.say_code = 'CURR'
           AND   stm.active_yn = 'Y'
		   AND 	 sty.name = p_sty_name; */

	------------------------------------------------------------
	-- Upper Bound for Rental/S And M Date
	------------------------------------------------------------
	CURSOR upper_rental_date_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2) IS
		SELECT	TRUNC(MAX( ste.STREAM_ELEMENT_DATE )) upper_stream_date
		FROM okl_strm_elements ste
		WHERE ste.stm_id IN (
			  SELECT stm.id
		      FROM okl_streams	   	  stm,
		   		   okl_strm_type_v 	  sty
		      WHERE stm.khr_id = p_khr_id
              AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		      AND 	stm.sty_id = sty.id
              AND   stm.say_code = 'CURR'
              AND   stm.active_yn = 'Y'
		      AND 	sty.stream_type_purpose = p_sty_purpose);

	------------------------------------------------------------
	-- Lower Bound for Rental/S And M Date
	------------------------------------------------------------
	CURSOR lower_rental_date_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2, p_max_date DATE) IS
		SELECT	TRUNC(MAX( ste.STREAM_ELEMENT_DATE )) lower_stream_date
		FROM okl_strm_elements ste
		WHERE ste.stream_element_date <= p_max_date
		AND   ste.stm_id IN (
			  SELECT stm.id
		      FROM okl_streams	   	  stm,
		   		   okl_strm_type_v 	  sty
		      WHERE stm.khr_id = p_khr_id
              AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		      AND 	stm.sty_id = sty.id
              AND   stm.say_code = 'CURR'
              AND   stm.active_yn = 'Y'
		      AND 	sty.stream_type_purpose = p_sty_purpose);

	------------------------------------------------------------
	-- Billing Amount
	------------------------------------------------------------
	CURSOR bill_amt_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2) IS
	/*bug#6060813  27-Sep-2007 bill_amt_csr changed to pick the last billed stream for each
          contract line  and not the least amount billed during the life of the
          contract line. Ordered the stream element dates in descending order and picked the
	  the amount for the max stream element date excluding the stream element for stub
	  payment  */
         SELECT ste.amount
         FROM okl_strm_elements ste,
         (
          SELECT stm.id, to_number(rule_information6) amt
          FROM okc_rules_b a,
               okc_rule_groups_b b,
               okl_streams stm,
               okl_strm_type_v sty
          WHERE a.dnz_chr_id = p_khr_id
          AND a.rgp_id = b.id
          AND b.rgd_code = 'LALEVL'
          AND a.rule_information_category = 'LASLL'
          AND stm.kle_id = b.cle_id
          AND NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
          AND   stm.sty_id = sty.id
          AND   stm.say_code = 'CURR'
          AND   stm.active_yn = 'Y'
          AND   sty.stream_type_purpose = p_sty_purpose
          AND rule_information6 IS NOT NULL
        ) strules
        WHERE ste.stm_id = strules.id
        AND ste.amount = strules.amt
	AND ste.date_billed IS NOT NULL
        ORDER BY ste.stream_element_date DESC;

	/*
	CURSOR bill_amt_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2) IS
		SELECT	MIN (ste.amount) amount
		FROM okl_strm_elements ste
		WHERE ste.stm_id IN (
			  SELECT stm.id
		      FROM okl_streams	   	  stm,
		   		   okl_strm_type_v 	  sty
		      WHERE stm.khr_id = p_khr_id
              AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		      AND 	stm.sty_id = sty.id
              AND   stm.say_code = 'CURR'
              AND   stm.active_yn = 'Y'
		      AND 	sty.stream_type_purpose = p_sty_purpose);

*/
	------------------------------------------------------------
	-- Check Evergreen elements exist
	------------------------------------------------------------
	CURSOR evergreen_element_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2) IS
		SELECT	MAX( ste.STREAM_ELEMENT_DATE ) evergreen_element_date
		FROM okl_strm_elements ste
		WHERE ste.stm_id IN (
			  SELECT stm.id
		      FROM okl_streams	   	  stm,
		   		   okl_strm_type_v 	  sty
		      WHERE stm.khr_id = p_khr_id
              AND   NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
		      AND 	stm.sty_id = sty.id
              AND   stm.say_code = 'CURR'
              AND   stm.active_yn = 'Y'
		      AND 	sty.stream_type_purpose = p_sty_purpose);

	------------------------------------------------------------
	-- Transaction Number Cursor
	------------------------------------------------------------
    CURSOR c_tran_num_csr IS
        SELECT  okl_sif_seq.nextval
        FROM    dual;

	------------------------------------------------------------
	-- Billing Frequency Cursor
	------------------------------------------------------------
    --changed for rules migration
    CURSOR c_bill_freq_csr( p_khr_id   NUMBER ) IS
        SELECT  object1_id1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LALEVL'                AND
              rgp.chr_id   IS NULL                     AND
              rul.rule_information_category = 'LASLL'    AND
              rgp.dnz_chr_id = p_khr_id;

	-----------------------------------------------------------
	-- Max Line Number
	------------------------------------------------------------
    CURSOR max_line_num_csr (p_stm_id NUMBER) IS
           SELECT max(se_line_number)
           FROM okl_strm_elements
           WHERE stm_id = p_stm_id;

	------------------------------------------------------------
	-- To Check if a stream element already exists
	------------------------------------------------------------
    CURSOR stm_rec_exists_csr (p_stm_id NUMBER, p_sel_date DATE) IS
           SELECT count(*)
           FROM okl_strm_elements
           WHERE stm_id = p_stm_id
           AND trunc(STREAM_ELEMENT_DATE) = trunc(p_sel_date);

	------------------------------------------------------------
	-- To Check if previously unbilled stream elements exist
	------------------------------------------------------------
    CURSOR prev_unbilled_csr (p_stm_id NUMBER, p_sel_date DATE) IS
           SELECT count(*)
           FROM okl_strm_elements
           WHERE stm_id = p_stm_id
           AND trunc(STREAM_ELEMENT_DATE) <= trunc(p_sel_date)
           AND date_billed is NULL;

	----------------------------------------------------------------------------------------------------
	-- To get last stream element for RENT or SERVICE AND MAINTENANCE or ESTIMATED PERSONAL PROPERTY TAX
  -- or FEE
	----------------------------------------------------------------------------------------------------
    CURSOR c_last_strm_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_purpose VARCHAR2) IS
            SELECT * FROM (
            SELECT  ste.id
                  ,ste.stream_element_date
                  ,stm.khr_id
                  ,stm.kle_id
                  ,stm.sty_id
            FROM   okl_strm_elements_v ste
                  ,okl_streams_v stm
                  ,okl_strm_type_v sty
            WHERE   ste.stm_id = stm.id
            AND     stm.khr_id = p_khr_id
            AND     NVL(stm.kle_id, -99) = NVL(p_kle_id, -99)
            AND     stm.sty_id = sty.id
            AND     sty.stream_type_purpose = p_sty_purpose
            ORDER BY ste.stream_element_date DESC
            )
            WHERE ROWNUM = 1;

	------------------------------------------------------------
	-- Find out whether the stream was securitized
	------------------------------------------------------------
    CURSOR c_sec_strm_csr ( p_khr_id NUMBER, p_kle_id NUMBER, p_sty_id NUMBER, p_stream_element_date DATE) IS
            select distinct khr.id khr_id
            from  okl_pool_contents_v pol
            , OKL_POOLS pool
            ,okl_k_headers_full_v khr
            where pol.khr_id = p_khr_id
            and   nvl(pol.kle_id, -99) = nvl(p_kle_id, -99)
            and   pol.sty_id = p_sty_id
            and   trunc(p_stream_element_date) between trunc(pol.streams_from_date) and trunc(pol.streams_to_date)
            and   pol.pol_id = pool.id
            and   pool.khr_id = khr.id
	    AND  pol.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE; --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

	------------------------------------------------------------
	-- Stream Cursor
	------------------------------------------------------------
    CURSOR l_stream_csr(cp_khr_id IN NUMBER
                   ,cp_kle_id IN NUMBER
                   ,cp_sty_id IN NUMBER) IS
            SELECT stm.id
            FROM   okl_streams_v stm
            WHERE  stm.khr_id = cp_khr_id
            AND    nvl(stm.kle_id, -99) = nvl(cp_kle_id, -99)
            AND    stm.sty_id = cp_sty_id
            AND    stm.say_code = 'CURR'
            AND    stm.active_yn = 'Y';

	------------------------------------------------------------
	-- Stream Element Line Number Cursor
	------------------------------------------------------------
    CURSOR l_stream_line_nbr_csr(cp_stm_id IN NUMBER) IS
            SELECT max(se_line_number) se_line_number
            FROM okl_strm_elements_v
            WHERE stm_id = cp_stm_id;

	------------------------------------------------------------
	-- Initialise constants
	------------------------------------------------------------

	l_def_desc	    CONSTANT VARCHAR2(30)	:= 'Regular Stream Billing';
	l_line_code	    CONSTANT VARCHAR2(30)	:= 'LINE';
	l_init_status	CONSTANT VARCHAR2(30)	:= 'ENTERED';
	l_final_status	CONSTANT VARCHAR2(30)	:= 'SUBMITTED';
	l_trx_type_name	CONSTANT VARCHAR2(30)	:= 'Billing';
	l_trx_type_lang	CONSTANT VARCHAR2(30)	:= 'US';
	l_date_entered	CONSTANT DATE		:= SYSDATE;
	l_zero_amount	CONSTANT NUMBER		:= 0;
	l_first_line	CONSTANT NUMBER		:= 1;
	l_line_step	    CONSTANT NUMBER		:= 1;
	l_def_no_val	CONSTANT NUMBER		:= -1;
	l_null_kle_id	CONSTANT NUMBER		:= -2;

  --change for User Defined Streams, by pjgomes, on 18 Oct 2004
  cns_inv_evrgrn_rent_pay constant  varchar2(50) := 'INVESTOR_EVERGREEN_RENT_PAY';
  --not used since Service and Maintenance is not disbursed to investors
  cns_inv_sm_pay constant varchar2(50) := 'INVESTOR SERVICE AND MAINTENANCE PAY';

  --change for User Defined Streams, by pjgomes, on 18 Oct 2004
  cns_evergreen_rent constant varchar2(50) := 'RENEWAL_RENT';
  cns_rent constant varchar2(50) := 'RENT';

  --change for User Defined Streams, by pjgomes, on 18 Oct 2004
  cns_sm_evergreen constant varchar2(50) := 'SERVICE_RENEWAL';
  cns_sm constant varchar2(50) := 'SERVICE_PAYMENT';

  --change for User Defined Streams, by pjgomes, on 18 Oct 2004
  cns_ept_evergreen constant varchar2(50) := 'RENEWAL_PROPERTY_TAX';
  cns_ept constant varchar2(50) := 'ESTIMATED_PROPERTY_TAX';

  --change for User Defined Streams, by pjgomes, on 22 Feb 2005
  cns_fee_evergreen constant varchar2(50) := 'FEE_RENEWAL';
  cns_fee constant varchar2(50) := 'FEE_PAYMENT';

	-- Stream elements
	p_selv_rec	Okl_Streams_Pub.selv_rec_type;
	x_selv_rec	Okl_Streams_Pub.selv_rec_type;

  l_selv_rec          Okl_Sel_Pvt.selv_rec_type;
  lx_selv_rec         Okl_Sel_Pvt.selv_rec_type;
  l_init_selv_rec     Okl_Sel_Pvt.selv_rec_type;

	------------------------------------------------------------
	-- Declare local variables used in the program
	------------------------------------------------------------

	l_khr_id	        okl_k_headers.id%TYPE;
  l_kle_id            okl_streams.kle_id%TYPE;
  l_sty_id            okl_strm_type_v.id%TYPE;
  l_evrgrn_strm_purpose  okl_strm_type_v.stream_type_purpose%TYPE;
  l_evrgrn_prim_strm_purpose  okl_strm_type_v.stream_type_purpose%TYPE;
  l_se_line_number                OKL_STRM_ELEMENTS_V.SE_LINE_NUMBER%TYPE;
  l_stm_id                        OKL_STREAMS_V.ID%TYPE;
  l_sel_id            Okl_strm_elements_v.sel_id%TYPE;

	l_amount	        NUMBER;

	l_billing_frequency NUMBER;

	l_Stream_bill_date 	DATE;
  l_last_Stream_bill_date DATE;

	l_upper_date		DATE;
	l_lower_date		DATE;

	l_evergreen_date 	DATE;

	create_flag 		VARCHAR2(1);
	create_payable_flag	VARCHAR2(1) := 'N';

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	    CONSTANT NUMBER := 1;
	l_api_name	        CONSTANT VARCHAR2(30)  := 'BILL_EVERGREEN_STREAMS';
	l_return_status	    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  -- Streams Record
  l_stmv_rec          Okl_Streams_Pub.stmv_rec_type;
  lx_stmv_rec         Okl_Streams_Pub.stmv_rec_type;
  l_init_stmv_rec     Okl_Streams_Pub.stmv_rec_type;

  -- Temporary variables
  l_evergreen_rent_count  NUMBER;
  l_contract_rent_count   NUMBER;
  l_evergreen_sm_count    NUMBER;
  l_contract_sm_count     NUMBER;
  l_evergreen_ept_count   NUMBER;
  l_contract_ept_count    NUMBER;
  l_evergreen_fee_count   NUMBER;
  l_contract_fee_count    NUMBER;

  l_count                 NUMBER;
  l_max_line_num          NUMBER;
  l_rec_exists_cnt        NUMBER;
  l_prev_unbilled_cnt     NUMBER;
  l_investor_agrmt_id     NUMBER;
  l_bill_freq             OKC_RULES_B.object1_id1%TYPE;
  l_primary_sty_id        NUMBER;
  l_primary_for_dep_sty_id        NUMBER;
  l_prev_khr_id           okl_k_headers.id%TYPE;     --dkagrawa added for bug# 4728636

  -----------------------------------------------------
  -- Error Processing Variables
  -----------------------------------------------------
  l_error_message         VARCHAR2(1000);
  l_error_status          VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  -- fmiao for bug 4961860
  -- Cursor to check if the residual value exists in the pool or not
  CURSOR check_res_in_pool(p_khr_id NUMBER) IS
  SELECT 'Y'
  FROM dual
  WHERE EXISTS(
     SELECT 1
     FROM OKL_POOLS pool,
          okl_pool_contents_v poc,
          okl_strm_type_v sty
     WHERE pool.khr_id = p_khr_id AND
           pool.id = poc.pol_id AND
           poc.sty_id = sty.id AND
           sty.stream_type_purpose = 'RESIDUAL_VALUE'
          AND   poc.status_code = Okl_Pool_Pvt.G_POC_STS_ACTIVE  );  --Added by VARANGAN -Pool Contents Impact(Bug#6658065)

  l_res_in_pool           VARCHAR2(1);
  l_evrgrn_psthrgh_flg    NUMBER := 0;
  -- end fmiao for bug 4961860


  BEGIN

	  ------------------------------------------------------------
	  -- Start processing
	  ------------------------------------------------------------

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

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=========================================================================================');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '             ******* Start Evergreen Processing  *******');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=========================================================================================');


  	FOR evergreen_contracts IN evergreen_contracts_csr ( p_contract_number ) LOOP
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------------------------------');
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, ' Processing Contract: '||evergreen_contracts.contract_number);
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '-----------------------------------------------------------------------------------------');

  		l_khr_id := NULL;
      l_kle_id := NULL;
		  l_khr_id := evergreen_contracts.khr_id;
      l_kle_id := evergreen_contracts.kle_id;

	    ------------------------------------------------
  		-- Check if this contract has evergreen streams
  		------------------------------------------------
      l_count := 0;
      OPEN  c_stm_count_csr ( l_khr_id, l_kle_id );
      FETCH c_stm_count_csr INTO l_count;
      CLOSE c_stm_count_csr;

      --check to see if evergreen rent, evergreen s and m, evergreen ept, evergreen fee exist for khr, kle
      IF l_count < 4 THEN

	         -- Check and insert Evergreen Rent record
           l_evergreen_rent_count := 0;
           --change for User Defined Streams, by pjgomes, on 18 Oct 2004
           OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_evergreen_rent );
           FETCH c_sty_count_csr INTO l_evergreen_rent_count;
           CLOSE c_sty_count_csr;

           IF l_evergreen_rent_count > 0 THEN
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ' || cns_evergreen_rent || ' Streams exist for this contract.');
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Proceeding to creation of stream elements.');
	         ELSE
             l_contract_rent_count := 0;

             --change for User Defined Streams, by pjgomes, on 18 Oct 2004
             OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_rent );
             FETCH c_sty_count_csr INTO l_contract_rent_count;
             CLOSE c_sty_count_csr;

             IF l_contract_rent_count > 0 THEN
               -- Null out records
               l_stmv_rec    := l_init_stmv_rec;
               lx_stmv_rec   := l_init_stmv_rec;
               l_sty_id      := NULL;
               l_primary_sty_id := NULL;
               --l_kle_id      := NULL;

               ----------------------------------
               -- Evergreen Billing
               ----------------------------------
               /*OPEN  get_sty_id_csr ( cns_evergreen_rent );
	             FETCH get_sty_id_csr INTO l_sty_id;
	             CLOSE get_sty_id_csr;*/

               ------------------------------------------------------
               --Get the sty id for RENT
               --This sty id will be used as the primary sty id for
               --obtaining the sty id for EVERGREEN RENT
               ------------------------------------------------------
               OPEN get_prim_sty_id_csr(l_khr_id, l_kle_id, cns_rent);
               FETCH get_prim_sty_id_csr INTO l_primary_sty_id;
               CLOSE get_prim_sty_id_csr;
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Sty id for RENT: ' || l_primary_sty_id);

               --change for User Defined Streams, by pjgomes, on 18 Oct 2004
               OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id => l_khr_id
                     ,p_primary_sty_id => l_primary_sty_id
                     ,p_dependent_sty_purpose => cns_evergreen_rent
                     ,x_return_status => l_return_status
                     ,x_dependent_sty_id => l_sty_id);

               IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_evergreen_rent);
      					 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  	           ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_evergreen_rent);
      					 RAISE Okl_Api.G_EXCEPTION_ERROR;
  	           END IF;
               --OPEN  get_stm_attrs_csr ( l_khr_id , 'RENT' );
               --LOOP
	             --  FETCH get_stm_attrs_csr INTO l_kle_id;

               /*IF get_stm_attrs_csr%NOTFOUND THEN
                   CLOSE get_stm_attrs_csr;
                   EXIT;
               END IF;*/

               OPEN  c_tran_num_csr;
               FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
               CLOSE c_tran_num_csr;


               l_stmv_rec.sty_id                := l_sty_id;
               l_stmv_rec.khr_id                := l_khr_id;
               IF (l_kle_id <> -99) THEN
                 l_stmv_rec.kle_id              := l_kle_id;
               ELSE
                 l_stmv_rec.kle_id              := null;
               END IF;

               l_stmv_rec.sgn_code              := 'MANL';
               l_stmv_rec.say_code              := 'CURR';
               l_stmv_rec.active_yn             := 'Y';
               l_stmv_rec.date_current          := sysdate;
               l_stmv_rec.comments              := 'Evergreen Billing';

               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating EVERGREEN RENT Streams');

               Okl_Streams_Pub.create_streams(
                      p_api_version    =>     p_api_version,
                      p_init_msg_list  =>     p_init_msg_list,
                      x_return_status  =>     x_return_status,
                      x_msg_count      =>     x_msg_count,
                      x_msg_data       =>     x_msg_data,
                      p_stmv_rec       =>     l_stmv_rec,
                      x_stmv_rec       =>     lx_stmv_rec);

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for EVERGREEN RENT');
      					      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	             ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for EVERGREEN RENT');
      					      RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;
               /*END LOOP;
	             CLOSE get_stm_attrs_csr;*/
             ELSE
		           NULL;
             END IF;
           END IF;

	         -- Check and insert Evergreen Service and Maintenance record
           l_evergreen_sm_count := 0;
           --change for User Defined Streams, by pjgomes, on 18 Oct 2004
           OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_sm_evergreen);
           FETCH c_sty_count_csr INTO l_evergreen_sm_count;
           CLOSE c_sty_count_csr;

           IF l_evergreen_sm_count > 0 THEN
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ' || cns_sm_evergreen || ' Streams exist for this contract.');
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Proceeding to creation of stream elements.');
    	     ELSE
             l_contract_sm_count  := 0;

             --change for User Defined Streams, by pjgomes, on 18 Oct 2004
             OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_sm );
             FETCH c_sty_count_csr INTO l_contract_sm_count;
             CLOSE c_sty_count_csr;

		         IF l_contract_sm_count > 0 THEN

               -- Null out records
               l_stmv_rec    := l_init_stmv_rec;
               lx_stmv_rec   := l_init_stmv_rec;
               l_sty_id      := NULL;
               l_primary_sty_id := NULL;
               --l_kle_id      := NULL;

               ----------------------------------
               -- Evergreen Billing
               ----------------------------------
	             /*OPEN  get_sty_id_csr ( cns_sm_evergreen );
	             FETCH get_sty_id_csr INTO l_sty_id;
	             CLOSE get_sty_id_csr;*/

               ------------------------------------------------------
               --Get the sty id for SERVICE AND MAINTENANCE
               --This sty id will be used as the primary sty id for
               --obtaining the sty id for EVERGREEN SERVICE AND MAINTENANCE
               ------------------------------------------------------
               OPEN get_prim_sty_id_csr(l_khr_id, l_kle_id, cns_sm);
               FETCH get_prim_sty_id_csr INTO l_primary_sty_id;
               CLOSE get_prim_sty_id_csr;
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Sty id for SERVICE AND MAINTENANCE: ' || l_primary_sty_id);

               --change for User Defined Streams, by pjgomes, on 18 Oct 2004
               OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id => l_khr_id
                     ,p_primary_sty_id => l_primary_sty_id
                     ,p_dependent_sty_purpose => cns_sm_evergreen
                     ,x_return_status => l_return_status
                     ,x_dependent_sty_id => l_sty_id);

               IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_sm_evergreen);
      					 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  	           ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_sm_evergreen);
      					 RAISE Okl_Api.G_EXCEPTION_ERROR;
  	           END IF;

               /*OPEN  get_stm_attrs_csr ( l_khr_id , 'SERVICE AND MAINTENANCE' );
               LOOP
	             FETCH get_stm_attrs_csr INTO l_kle_id;

               IF get_stm_attrs_csr%NOTFOUND THEN
	               CLOSE get_stm_attrs_csr;
                 EXIT;
               END IF;*/

               OPEN  c_tran_num_csr;
               FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
               CLOSE c_tran_num_csr;


               l_stmv_rec.sty_id                := l_sty_id;
               l_stmv_rec.khr_id                := l_khr_id;
               IF (l_kle_id <> -99) THEN
                 l_stmv_rec.kle_id              := l_kle_id;
               ELSE
                 l_stmv_rec.kle_id              := null;
               END IF;
               l_stmv_rec.sgn_code              := 'MANL';
               l_stmv_rec.say_code              := 'CURR';
               l_stmv_rec.active_yn             := 'Y';
               l_stmv_rec.date_current          := sysdate;
               l_stmv_rec.comments              := 'Evergreen Billing';


               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating SERVICE AND MAINTENANCE EVERGREEN Streams');
               Okl_Streams_Pub.create_streams(
                      p_api_version    =>     p_api_version,
                      p_init_msg_list  =>     p_init_msg_list,
                      x_return_status  =>     x_return_status,
                      x_msg_count      =>     x_msg_count,
                      x_msg_data       =>     x_msg_data,
                      p_stmv_rec       =>     l_stmv_rec,
                      x_stmv_rec       =>     lx_stmv_rec);

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for SERVICE AND MAINTENANCE EVERGREEN');
      					      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for SERVICE AND MAINTENANCE EVERGREEN');
      					      RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;
               /*END LOOP;
               CLOSE c_tran_num_csr;*/
             ELSE
			         null;
		         END IF;
           END IF;

	         -- Check and insert Estimated Personal Property Tax Evergreen record
           l_evergreen_ept_count := 0;
           --change for User Defined Streams, by pjgomes, on 18 Oct 2004
           OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_ept_evergreen );
           FETCH c_sty_count_csr INTO l_evergreen_ept_count;
           CLOSE c_sty_count_csr;

           IF l_evergreen_ept_count > 0 THEN
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ' || cns_ept_evergreen || ' Streams exist for this contract.');
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Proceeding to creation of stream elements.');
	         ELSE
             l_contract_ept_count := 0;

             --change for User Defined Streams, by pjgomes, on 18 Oct 2004
             OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_ept );
             FETCH c_sty_count_csr INTO l_contract_ept_count;
             CLOSE c_sty_count_csr;

             IF l_contract_ept_count > 0 THEN
               -- Null out records
               l_stmv_rec    := l_init_stmv_rec;
               lx_stmv_rec   := l_init_stmv_rec;
               l_sty_id      := NULL;
               l_primary_sty_id := NULL;
               --l_kle_id      := NULL;

               ----------------------------------
               -- Evergreen Billing
               ----------------------------------
               /*OPEN  get_sty_id_csr ( cns_ept_evergreen );
	             FETCH get_sty_id_csr INTO l_sty_id;
	             CLOSE get_sty_id_csr;*/

               ------------------------------------------------------
               --Get the sty id for ESTIMATED PROPERTY TAX
               --This sty id will be used as the primary sty id for
               --obtaining the sty id for EVERGREEN ESTIMATED PROPERTY TAX
               ------------------------------------------------------
               OPEN get_prim_sty_id_csr(l_khr_id, l_kle_id, cns_ept);
               FETCH get_prim_sty_id_csr INTO l_primary_sty_id;
               CLOSE get_prim_sty_id_csr;
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Sty id for ESTIMATED PROPERTY TAX: ' || l_primary_sty_id);


               --change for User Defined Streams, by pjgomes, on 18 Oct 2004
               OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id => l_khr_id
                     ,p_primary_sty_id => l_primary_sty_id
                     ,p_dependent_sty_purpose => cns_ept_evergreen
                     ,x_return_status => l_return_status
                     ,x_dependent_sty_id => l_sty_id);

               IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_ept_evergreen);
      					 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  	           ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_ept_evergreen);
      					 RAISE Okl_Api.G_EXCEPTION_ERROR;
  	           END IF;

               OPEN  c_tran_num_csr;
               FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
               CLOSE c_tran_num_csr;


               l_stmv_rec.sty_id                := l_sty_id;
               l_stmv_rec.khr_id                := l_khr_id;
               IF (l_kle_id <> -99) THEN
                 l_stmv_rec.kle_id              := l_kle_id;
               ELSE
                 l_stmv_rec.kle_id              := null;
               END IF;

               l_stmv_rec.sgn_code              := 'MANL';
               l_stmv_rec.say_code              := 'CURR';
               l_stmv_rec.active_yn             := 'Y';
               l_stmv_rec.date_current          := sysdate;
               l_stmv_rec.comments              := 'Evergreen Billing';

               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating ESTIMATED PERSONAL PROPERTY TAX EVERGREEN Streams');

               Okl_Streams_Pub.create_streams(
                      p_api_version    =>     p_api_version,
                      p_init_msg_list  =>     p_init_msg_list,
                      x_return_status  =>     x_return_status,
                      x_msg_count      =>     x_msg_count,
                      x_msg_data       =>     x_msg_data,
                      p_stmv_rec       =>     l_stmv_rec,
                      x_stmv_rec       =>     lx_stmv_rec);

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for ESTIMATED PERSONAL PROPERTY TAX EVERGREEN');
      					      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	             ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for ESTIMATED PERSONAL PROPERTY TAX EVERGREEN');
      					      RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;
               /*END LOOP;
	             CLOSE get_stm_attrs_csr;*/
             ELSE
		           NULL;
             END IF;
           END IF;

           -- Check and insert Evergreen Fee record
           l_evergreen_fee_count := 0;

           OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_fee_evergreen);
           FETCH c_sty_count_csr INTO l_evergreen_fee_count;
           CLOSE c_sty_count_csr;

           IF l_evergreen_fee_count > 0 THEN
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ' || cns_fee_evergreen || ' Streams exist for this contract.');
             FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Proceeding to creation of stream elements.');
    	     ELSE
             l_contract_fee_count  := 0;

             OPEN  c_sty_count_csr ( l_khr_id, l_kle_id, cns_fee );
             FETCH c_sty_count_csr INTO l_contract_fee_count;
             CLOSE c_sty_count_csr;

		         IF l_contract_fee_count > 0 THEN

               -- Null out records
               l_stmv_rec    := l_init_stmv_rec;
               lx_stmv_rec   := l_init_stmv_rec;
               l_sty_id      := NULL;
               l_primary_sty_id := NULL;
               --l_kle_id      := NULL;

               ----------------------------------
               -- Evergreen Billing
               ----------------------------------

               ------------------------------------------------------
               --Get the sty id for FEE
               --This sty id will be used as the primary sty id for
               --obtaining the sty id for EVERGREEN FEE
               ------------------------------------------------------
               OPEN get_prim_sty_id_csr(l_khr_id, l_kle_id, cns_fee);
               FETCH get_prim_sty_id_csr INTO l_primary_sty_id;
               CLOSE get_prim_sty_id_csr;
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Sty id for FEE: ' || l_primary_sty_id);

               --change for User Defined Streams, by pjgomes, on 18 Oct 2004
               OKL_STREAMS_UTIL.get_dependent_stream_type(p_khr_id => l_khr_id
                     ,p_primary_sty_id => l_primary_sty_id
                     ,p_dependent_sty_purpose => cns_fee_evergreen
                     ,x_return_status => l_return_status
                     ,x_dependent_sty_id => l_sty_id);

               IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_fee_evergreen);
      					 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  	           ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || cns_fee_evergreen);
      					 RAISE Okl_Api.G_EXCEPTION_ERROR;
  	           END IF;


               OPEN  c_tran_num_csr;
               FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
               CLOSE c_tran_num_csr;


               l_stmv_rec.sty_id                := l_sty_id;
               l_stmv_rec.khr_id                := l_khr_id;
               IF (l_kle_id <> -99) THEN
                 l_stmv_rec.kle_id              := l_kle_id;
               ELSE
                 l_stmv_rec.kle_id              := null;
               END IF;
               l_stmv_rec.sgn_code              := 'MANL';
               l_stmv_rec.say_code              := 'CURR';
               l_stmv_rec.active_yn             := 'Y';
               l_stmv_rec.date_current          := sysdate;
               l_stmv_rec.comments              := 'Evergreen Billing';


               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating FEE EVERGREEN Streams');
               Okl_Streams_Pub.create_streams(
                      p_api_version    =>     p_api_version,
                      p_init_msg_list  =>     p_init_msg_list,
                      x_return_status  =>     x_return_status,
                      x_msg_count      =>     x_msg_count,
                      x_msg_data       =>     x_msg_data,
                      p_stmv_rec       =>     l_stmv_rec,
                      x_stmv_rec       =>     lx_stmv_rec);

               IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for FEE EVERGREEN');
      					      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Streams for FEE EVERGREEN');
      					      RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;
               /*END LOOP;
               CLOSE c_tran_num_csr;*/
             ELSE
			         null;
		         END IF;
           END IF;

      ELSE
           FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Streams for Evergreen Billing exist for this contract.');
           FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Proceeding to creation of stream elements for Evergreen Billing.');
      END IF;

      FOR stms IN c_stm_id( l_khr_id, l_kle_id ) LOOP

        l_error_message         := NULL;
        l_error_status          := Okl_Api.G_RET_STS_SUCCESS;

        -----------------------------------------
		    -- Initialize the date fields to null
		    -----------------------------------------

		    l_amount           := NULL;
		    l_Stream_bill_date := NULL;
		    l_upper_date 		 := NULL;
		    l_lower_date 		 := NULL;
		    l_evrgrn_strm_purpose := NULL;
        l_evrgrn_prim_strm_purpose := NULL;
        create_payable_flag := 'N';

        --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		    IF (stms.sty_name = cns_evergreen_rent) THEN

          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
	  	 	  OPEN  upper_rental_date_csr ( l_khr_id , l_kle_id, cns_rent );
				  FETCH upper_rental_date_csr INTO l_upper_date;
				  CLOSE upper_rental_date_csr;

          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		  	 	OPEN  lower_rental_date_csr ( l_khr_id , l_kle_id,  cns_rent, l_upper_date );
				  FETCH lower_rental_date_csr INTO l_lower_date;
				  CLOSE lower_rental_date_csr;

				  -------------------------------
				  -- Fetch Billing Amount
				  -------------------------------
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
				  OPEN  bill_amt_csr ( l_khr_id , l_kle_id, cns_rent );
				  FETCH bill_amt_csr INTO l_amount;
				  CLOSE bill_amt_csr;

          ----------------------------------------------------------------
          --GET THE LAST RENT STREAM ELEMENT DETAILS
          ----------------------------------------------------------------
          create_payable_flag := 'N';
          l_evrgrn_strm_purpose := null;
          l_evrgrn_prim_strm_purpose := null;
          l_investor_agrmt_id := null;

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Contract id: ' || l_khr_id || ' Line id: ' || l_kle_id);
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
          FOR cur_last_strm IN c_last_strm_csr ( l_khr_id , l_kle_id,  cns_rent) LOOP
            ----------------------------------------------------------------
            --CHECK IF THE LAST RENT STREAM WAS SECURITIZED
            ----------------------------------------------------------------
            FOR cur_sec_strm IN c_sec_strm_csr ( cur_last_strm.khr_id , cur_last_strm.kle_id , cur_last_strm.sty_id , cur_last_strm.stream_element_date ) LOOP
              create_payable_flag := 'Y';
              --change for User Defined Streams, by pjgomes, on 18 Oct 2004
              l_evrgrn_strm_purpose := cns_inv_evrgrn_rent_pay;
              l_evrgrn_prim_strm_purpose := cns_evergreen_rent;
              l_investor_agrmt_id := cur_sec_strm.khr_id;
              exit;
            END LOOP;
            exit;
          END LOOP;
        --change for User Defined Streams, by pjgomes, on 18 Oct 2004
        ELSIF (stms.sty_name = cns_sm_evergreen) THEN -- The stream is 'SERVICE AND MAINTENANCE EVERGREEN'
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		  	 	OPEN  upper_rental_date_csr ( l_khr_id , l_kle_id , cns_sm );
				  FETCH upper_rental_date_csr INTO l_upper_date;
				  CLOSE upper_rental_date_csr;

          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		  	 	OPEN  lower_rental_date_csr ( l_khr_id , l_kle_id , cns_sm, l_upper_date );
				  FETCH lower_rental_date_csr INTO l_lower_date;
				  CLOSE lower_rental_date_csr;

          -------------------------------
				  -- Fetch Billing Amount
				  -------------------------------
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
				  OPEN  bill_amt_csr ( l_khr_id , l_kle_id , cns_sm );
				  FETCH bill_amt_csr INTO l_amount;
				  CLOSE bill_amt_csr;

          ----------------------------------------------------------------
          --GET THE LAST SERVICE AND MAINTENANCE STREAM ELEMENT DETAILS
          ----------------------------------------------------------------
          create_payable_flag := 'N';
          l_evrgrn_strm_purpose := null;
          l_evrgrn_prim_strm_purpose := null;
          l_investor_agrmt_id := null;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Contract id: ' || l_khr_id || ' Line id: ' || l_kle_id);
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
          FOR cur_last_strm IN c_last_strm_csr ( l_khr_id , l_kle_id,  cns_sm) LOOP
            ----------------------------------------------------------------
            --CHECK IF THE LAST SERVICE AND MAINTENANCE STREAM WAS SECURITIZED
            ----------------------------------------------------------------
            FOR cur_sec_strm IN c_sec_strm_csr ( cur_last_strm.khr_id , cur_last_strm.kle_id , cur_last_strm.sty_id , cur_last_strm.stream_element_date ) LOOP
              create_payable_flag := 'Y';
              --change for User Defined Streams, by pjgomes, on 18 Oct 2004
              l_evrgrn_strm_purpose := cns_inv_sm_pay;
              l_evrgrn_prim_strm_purpose := cns_sm_evergreen;
              l_investor_agrmt_id := cur_sec_strm.khr_id;
              exit;
            END LOOP;
            exit;
          END LOOP;
        ELSIF (stms.sty_name = cns_ept_evergreen) THEN-- The stream is 'ESTIMATED PERSONAL PROPERTY TAX EVERGREEN'

          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
	  	 	  OPEN  upper_rental_date_csr ( l_khr_id , l_kle_id, cns_ept );
				  FETCH upper_rental_date_csr INTO l_upper_date;
				  CLOSE upper_rental_date_csr;

          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		  	 	OPEN  lower_rental_date_csr ( l_khr_id , l_kle_id,  cns_ept, l_upper_date );
				  FETCH lower_rental_date_csr INTO l_lower_date;
				  CLOSE lower_rental_date_csr;

				  -------------------------------
				  -- Fetch Billing Amount
				  -------------------------------
          --change for User Defined Streams, by pjgomes, on 18 Oct 2004
				  OPEN  bill_amt_csr ( l_khr_id , l_kle_id, cns_ept );
				  FETCH bill_amt_csr INTO l_amount;
				  CLOSE bill_amt_csr;

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Contract id: ' || l_khr_id || ' Line id: ' || l_kle_id);

          create_payable_flag := 'N';
          l_evrgrn_strm_purpose := null;
          l_evrgrn_prim_strm_purpose := null;
        ELSE -- The stream is 'FEE EVERGREEN'

	  	 	  OPEN  upper_rental_date_csr ( l_khr_id , l_kle_id, cns_fee );
				  FETCH upper_rental_date_csr INTO l_upper_date;
				  CLOSE upper_rental_date_csr;

		  	 	OPEN  lower_rental_date_csr ( l_khr_id , l_kle_id,  cns_fee, l_upper_date );
				  FETCH lower_rental_date_csr INTO l_lower_date;
				  CLOSE lower_rental_date_csr;

				  -------------------------------
				  -- Fetch Billing Amount
				  -------------------------------
				  OPEN  bill_amt_csr ( l_khr_id , l_kle_id, cns_fee );
				  FETCH bill_amt_csr INTO l_amount;
				  CLOSE bill_amt_csr;

          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Contract id: ' || l_khr_id || ' Line id: ' || l_kle_id);

          create_payable_flag := 'N';
          l_evrgrn_strm_purpose := null;
          l_evrgrn_prim_strm_purpose := null;
        END IF;


        ------------------------------------------------------------
		    --Check if Stream Elements exist already
		    ------------------------------------------------------------
		    l_evergreen_date := NULL;

        --change for User Defined Streams, by pjgomes, on 18 Oct 2004
		    OPEN  evergreen_element_csr ( l_khr_id , l_kle_id , stms.sty_name );
		    FETCH evergreen_element_csr INTO l_evergreen_date;
		    CLOSE evergreen_element_csr;

        l_last_Stream_bill_date := NULL;
		    IF l_evergreen_date IS NOT NULL  THEN
 		      l_last_Stream_bill_date := l_evergreen_date;
		    ELSE -- No evergreen elements exist.
		      l_last_Stream_bill_date := l_upper_date;
		    END IF;

		    ------------------------------------------------------------
		    --Determine billing frequency
		    ------------------------------------------------------------

        l_bill_freq := NULL;
        OPEN  c_bill_freq_csr ( l_khr_id );
        FETCH c_bill_freq_csr INTO l_bill_freq;
        CLOSE c_bill_freq_csr;

        ------------------------------------------
        -- Add frequency to date
        ------------------------------------------
        l_Stream_bill_date := NULL;
        --dkagrawa BUG#4604842 start
	-- calling okl_stream_generator_pvt.add_months_new to determine the next bill date
	l_billing_frequency := NULL;
        IF l_bill_freq = 'A' THEN
          l_billing_frequency := 12;
	ELSIF l_bill_freq = 'S' THEN
          l_billing_frequency := 6;
        ELSIF l_bill_freq = 'Q' THEN
          l_billing_frequency := 3;
        ELSIF l_bill_freq = 'M' THEN
          l_billing_frequency := 1;
        ELSE
          l_error_message := 'Invalid Billing Frequency. ';
          l_error_status  := Okl_Api.G_RET_STS_ERROR;
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: '||l_error_message);
        END IF;
        IF l_billing_frequency IS NOT NULL THEN
          OKL_STREAM_GENERATOR_PVT.add_months_new(p_start_date    => l_last_Stream_bill_date,
                                                  p_months_after  => l_billing_frequency,
                                                  x_date          => l_Stream_bill_date,
                                                  x_return_status => x_return_status);
        END IF;
        --dkagrawa BUG#4604842 end


        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        => Last Billed:     '||l_last_Stream_bill_date);
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        => Next Determined: '||l_Stream_bill_date);

		    ------------------------------------------------------------
		    -- If the program has a from and to date supplied the
		    -- evergreen stream element must be between the two
		    ------------------------------------------------------------
		    create_flag := 'Y';

		    IF p_from_bill_date IS NOT NULL THEN
		  	  IF (l_Stream_bill_date < p_from_bill_date) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Bill_DATE is less than supplied From Date.');
		  	 	  create_flag := 'N';
			    END IF;
		    END IF;

		    IF p_to_bill_date IS NOT NULL THEN
		  	  IF (l_Stream_bill_date > p_to_bill_date) THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Bill_DATE is greater than supplied To Date.');
		  	 	  create_flag := 'N';
			    END IF;
		    END IF;

        -- Check if there is an unbilled Stream element
        -- outstanding for this contract

		    IF (  create_flag = 'Y' ) THEN
          l_prev_unbilled_cnt:= 0;

          OPEN  prev_unbilled_csr ( stms.stm_id , l_last_Stream_bill_date );
          FETCH  prev_unbilled_csr INTO l_prev_unbilled_cnt;
          CLOSE prev_unbilled_csr;
          -- CHEck if an unbilled stream element exists for the same date
          -- and set the create flag
          IF l_prev_unbilled_cnt > 0 THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Previously Unbilled Stream Elements Exist.');
            create_flag := 'N';
          END IF;
        END IF;

        -- Check if there is an unbilled Stream element
        -- with the same date
		    IF (  create_flag = 'Y' ) THEN

          l_rec_exists_cnt := 0;

          OPEN  stm_rec_exists_csr( stms.stm_id , l_Stream_bill_date );
          FETCH stm_rec_exists_csr INTO l_rec_exists_cnt;
          CLOSE stm_rec_exists_csr;
          -- CHEck if an unbilled stream element exists for the same date
          -- and set the create flag
          IF l_rec_exists_cnt > 0 THEN
            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Duplicate Stream Element.');
            create_flag := 'N';
          END IF;
        END IF;

		    ------------------------------------------------------------
		    --Proceed to Create if within Date Ranges
		    ------------------------------------------------------------

        IF (  create_flag = 'Y' ) THEN

          ------------------------------------------------------------
		      --Create Stream elements for evergreen
		  	  ------------------------------------------------------------
          IF ( l_amount IS NOT NULL AND l_amount > 0) THEN

            l_max_line_num := 0;
            OPEN  max_line_num_csr ( stms.stm_id );
            FETCH max_line_num_csr INTO l_max_line_num;
            CLOSE max_line_num_csr;

			  	  p_selv_rec.stm_id 				    := stms.stm_id;
				    p_selv_rec.SE_LINE_NUMBER          := NVL( l_max_line_num, 0 ) + 1;
				    p_selv_rec.STREAM_ELEMENT_DATE     := l_Stream_bill_date;
				    p_selv_rec.AMOUNT                  := l_amount;
				    p_selv_rec.COMMENTS                := 'EVERGREEN BILLING ELEMENTS';
				    p_selv_rec.ACCRUED_YN			    := 'Y';

            Okl_Sel_Pvt.insert_row(
    		 			p_api_version,
    		 			p_init_msg_list,
    		 			x_return_status,
    		 			x_msg_count,
    		 			x_msg_data,
    		 			p_selv_rec,
    		 			x_selv_rec);

            l_sel_id := x_selv_rec.id;

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        --Evergreen Stream Element id: ' || l_sel_id);
	          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
              l_error_message := 'Error Creating Stream Element for Contract: '
                                        ||stms.contract_number
                                        ||' Stream: '||stms.sty_name
                                        ||' Bill Date: '||l_Stream_bill_date
                                        ||' Amount: '||l_amount;
                    l_error_status  := Okl_Api.G_RET_STS_ERROR;
     					      --RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	           ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                    l_error_message := 'Error Creating Stream Element for Contract: '
                                        ||stms.contract_number
                                        ||' Stream: '||stms.sty_name
                                        ||' Bill Date: '||l_Stream_bill_date
                                        ||' Amount: '||l_amount;
                    l_error_status  := Okl_Api.G_RET_STS_ERROR;
     					      --RAISE Okl_Api.G_EXCEPTION_ERROR;
              ELSE

                   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Created Evergreen Stream Element for Contract: '
                                      ||stms.contract_number
                                      ||' Stream: '||stms.sty_name
                                      ||' Bill Date: '||l_Stream_bill_date
                                      ||' Amount: '||l_amount
                                    );
       	      END IF;

              IF l_evrgrn_strm_purpose IS NOT NULL AND l_error_status = Okl_Api.G_RET_STS_SUCCESS THEN

			    -- Added by fmiao for bug 4961860
                l_evrgrn_psthrgh_flg := 0;
                IF(l_evrgrn_strm_purpose = 'INVESTOR_EVERGREEN_RENT_PAY') THEN
                  OPEN check_res_in_pool(l_investor_agrmt_id);
                  FETCH check_res_in_pool INTO l_res_in_pool;
                  CLOSE check_res_in_pool;
                  IF(l_res_in_pool IS NULL OR l_res_in_pool <> 'Y') THEN
                    l_evrgrn_psthrgh_flg := 1;
                  END IF;
                END IF;
                -- end fmiao for bug 4961860

                IF(l_evrgrn_psthrgh_flg = 0) THEN
				-- Added by fmiao for bug 4961860
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- EVERGREEN PAYABLE STREAM TYPE: ' || l_evrgrn_strm_purpose);
                ----------------------------------------------------------------
                --PROCESSING FOR EVERGREEN STREAM TYPE PAYABLE TO INVESTOR
                ----------------------------------------------------------------
                --get stream type id
                l_sty_id := null;
                l_primary_sty_id := NULL;

                /*OPEN get_sty_id_csr(l_evrgrn_strm_purpose);
                FETCH get_sty_id_csr INTO l_sty_id;
                CLOSE get_sty_id_csr;*/

               ------------------------------------------------------
               --Get the sty id for Evergreen Payable
               ------------------------------------------------------
               /*OPEN get_prim_sty_id_csr(l_khr_id, l_kle_id, l_evrgrn_prim_strm_purpose);
               FETCH get_prim_sty_id_csr INTO l_primary_sty_id;
               CLOSE get_prim_sty_id_csr;
               FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Sty id for ' || l_evrgrn_prim_strm_purpose || ': ' || l_primary_sty_id);             */

               --change for User Defined Streams, by pjgomes, on 18 Oct 2004
               OKL_STREAMS_UTIL.get_primary_stream_type(p_khr_id => l_investor_agrmt_id
                     ,p_primary_sty_purpose => l_evrgrn_strm_purpose
                     ,x_return_status => l_return_status
                     ,x_primary_sty_id => l_sty_id);

               IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || l_evrgrn_strm_purpose);
 					       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
  	           ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                 FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Obtaining sty id for: ' || l_evrgrn_strm_purpose);
 					       RAISE Okl_Api.G_EXCEPTION_ERROR;
  	           END IF;

                --check for stream
                l_stm_id := null;
                l_se_line_number := null;

                OPEN l_stream_csr(l_khr_id, l_kle_id, l_sty_id);
                FETCH l_stream_csr INTO l_stm_id;
                CLOSE l_stream_csr;

                --create stream for evergreen payable
                IF (l_stm_id IS NULL) THEN
                  l_stmv_rec := l_init_stmv_rec;

                  OPEN  c_tran_num_csr;
                  FETCH c_tran_num_csr INTO l_stmv_rec.transaction_number;
                  CLOSE c_tran_num_csr;

                  l_stmv_rec.sty_id                := l_sty_id;
                  l_stmv_rec.khr_id                := l_khr_id;
                  --l_stmv_rec.kle_id                := l_kle_id;
                  IF (l_kle_id <> -99) THEN
                    l_stmv_rec.kle_id             := l_kle_id;
                  ELSE
                    l_stmv_rec.kle_id             := null;
                  END IF;
                  l_stmv_rec.sgn_code              := 'MANL';
                  l_stmv_rec.say_code              := 'CURR';
                  l_stmv_rec.active_yn             := 'Y';
                  l_stmv_rec.date_current          := sysdate;
                  l_stmv_rec.comments              := l_evrgrn_strm_purpose;
                  IF (l_investor_agrmt_id IS NOT NULL) THEN
                       l_stmv_rec.source_id := l_investor_agrmt_id;
                       l_stmv_rec.source_table := 'OKL_K_HEADERS';
                  END IF;

                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Creating ' || l_evrgrn_strm_purpose || ' Stream');

                  Okl_Streams_Pub.create_streams(
                       p_api_version    =>     p_api_version,
                       p_init_msg_list  =>     p_init_msg_list,
                       x_return_status  =>     x_return_status,
                       x_msg_count      =>     x_msg_count,
                       x_msg_data       =>     x_msg_data,
                       p_stmv_rec       =>     l_stmv_rec,
                       x_stmv_rec       =>     lx_stmv_rec);

                  l_stm_id := lx_stmv_rec.id;
                  l_se_line_number := 1;

                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
                  IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: Creating Stream for ' || l_evrgrn_strm_purpose);
     					      RAISE Okl_Api.G_EXCEPTION_ERROR;
                  ELSE
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- SUCCESS: Creating Stream for ' || l_evrgrn_strm_purpose);
                  END IF;
                ELSE
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream for ' || l_evrgrn_strm_purpose || ' found');
                  open l_stream_line_nbr_csr(l_stm_id);
                  fetch l_stream_line_nbr_csr into l_se_line_number;
                  close l_stream_line_nbr_csr;
                  l_se_line_number := l_se_line_number + 1;
                  FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- Stream element line number => ' || l_se_line_number);
                END IF;

                --create stream element for evergreen stream payable
                IF (l_stm_id IS NOT NULL) THEN
                  l_selv_rec := l_init_selv_rec;
                  l_selv_rec.stm_id 				 := l_stm_id;
			            l_selv_rec.SE_LINE_NUMBER          := l_se_line_number;
                  l_selv_rec.STREAM_ELEMENT_DATE     := sysdate;
                  l_selv_rec.AMOUNT                  := l_amount;
                  l_selv_rec.COMMENTS                := l_evrgrn_strm_purpose || ' ELEMENTS';
                  l_selv_rec.ACCRUED_YN			     := 'Y';

                  l_selv_rec.sel_id := l_sel_id;
                  IF (l_investor_agrmt_id IS NOT NULL) THEN
                       l_selv_rec.source_id := l_investor_agrmt_id;
                       l_selv_rec.source_table := 'OKL_K_HEADERS';
                  END IF;

                  Okl_Sel_Pvt.insert_row(
    		 			      p_api_version,
    		 			      p_init_msg_list,
    		 			      x_return_status,
    		 			      x_msg_count,
    		 			      x_msg_data,
    		 			      l_selv_rec,
    		 			      lx_selv_rec);

                  IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,  '        -- Error Creating Payable Stream Element for Contract: '
                                        || evergreen_contracts.contract_number
                                        ||' Stream: '||l_evrgrn_strm_purpose
                                        ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                        ||' Amount: '||l_amount);
     					      RAISE Okl_Api.G_EXCEPTION_ERROR;
                  ELSE

                    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '         -- Created Investor Payable Stream Element for Contract: '
                                      || evergreen_contracts.contract_number
                                      ||' Stream: '||l_evrgrn_strm_purpose
                                      ||' Bill Date: '||l_selv_rec.STREAM_ELEMENT_DATE
                                      ||' Amount: '||l_amount
                                    );
                  END IF;
                END IF;
				END IF; -- Added by fmiao for bug 4961860
              END IF;

          END IF;
        END IF;

        IF l_error_status <> OKL_API.G_RET_STS_SUCCESS THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '        -- ERROR: '||l_error_message);
        END IF;

      END LOOP;
      --dkagrawa bug# 4728636 changes start
      IF l_prev_khr_id IS NULL THEN
        l_prev_khr_id := evergreen_contracts.khr_id;
      END IF;
      IF l_prev_khr_id <> evergreen_contracts.khr_id THEN
        IF (l_error_status = OKL_API.G_RET_STS_SUCCESS)  THEN
          OKL_BILLING_CONTROLLER_PVT.track_next_bill_date ( l_prev_khr_id );
        END IF;
        l_prev_khr_id := evergreen_contracts.khr_id;
      END IF;
   END LOOP;
   IF l_prev_khr_id IS NOT NULL THEN
     IF (l_error_status = OKL_API.G_RET_STS_SUCCESS)  THEN
       OKL_BILLING_CONTROLLER_PVT.track_next_bill_date ( l_prev_khr_id );
     END IF;
   END IF;
   --dkagrawa bug# 4728636 changes end

   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=========================================================================================');
   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '             ******* End Evergreen Processing  *******');
   FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '=========================================================================================');

   ------------------------------------------------------------
   -- End processing
   ------------------------------------------------------------


   x_return_status := l_return_status;
   Okl_Api.END_ACTIVITY (
	 x_msg_count	=> x_msg_count,
	 x_msg_data	=> x_msg_data);


  EXCEPTION

    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

    WHEN OTHERS THEN

		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

  END BILL_EVERGREEN_STREAMS;


END Okl_Evergreen_Billing_Pvt;

/
