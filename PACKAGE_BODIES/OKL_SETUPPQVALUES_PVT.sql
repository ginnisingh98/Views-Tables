--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPQVALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPQVALUES_PVT" AS
/* $Header: OKLRSUVB.pls 120.20 2007/09/26 08:25:39 rajnisku noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.PRODUCTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

G_ITEM_NOT_FOUND_ERROR EXCEPTION;
G_COLUMN_TOKEN			  CONSTANT VARCHAR2(100) := 'COLUMN';
G_TABLE_TOKEN                     CONSTANT VARCHAR2(200) := 'OKL_TABLE_NAME'; --- CHG001
G_BOOK_CLASS_MISMATCH		  CONSTANT VARCHAR2(200) := 'OKL_BOOK_CLASS_MISMATCH';
G_TAX_OWNER_MISMATCH		  CONSTANT VARCHAR2(200) := 'OKL_TAX_OWNER_MISMATCH';
G_INT_CALC_BASIS_MISMATCH	  CONSTANT VARCHAR2(200) := 'OKL_INT_CALC_BASIS_MISMATCH';
G_REVENUE_REC_METD_MISMATCH	  CONSTANT VARCHAR2(200) := 'OKL_REVENUE_REC_METD_MISMATCH';
G_INVESTOR_MISMATCH               CONSTANT VARCHAR2(200) := 'OKL_INVESTOR_MISMATCH';
G_REV_REC_NO_UPDATE               CONSTANT VARCHAR2(200) := 'OKL_REV_REC_NO_UPDATE';


G_OPLEASE_LESSEE_MISMATCH               CONSTANT VARCHAR2(200) := 'OKL_OPLEASE_LESSEE_MISMATCH'; --- CHG001
G_LOAN_LESSOR_MISMATCH                 CONSTANT VARCHAR2(200) := 'OKL_LOAN_ LESSOR_MISMATCH'; --- CHG001
G_LOANREV_LESSOR_MISMATCH               CONSTANT VARCHAR2(200) := 'OKL_LOANREV_LESSOR_MISMATCH'; --- CHG001


G_FLT_FAC_LOAN_REV_MISMATCH               CONSTANT VARCHAR2(200) := 'OKL_FLT_FAC_LOAN_REV_MISMATCH'; --- CHG001
G_FLT_FAC_EST_BILL_MISMATCH               CONSTANT VARCHAR2(200) := 'OKL_FLT_FAC_EST_BILL_MISMATCH'; --- CHG001
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: Okl_Pdt_Pqy_Vals_v
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_pqvv_rec                     IN pqvv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_pqvv_rec					   OUT NOCOPY pqvv_rec_type
  ) IS
    CURSOR okl_pqvv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PDQ_ID,
            PDT_ID,
            QVE_ID,
            FROM_DATE,
            TO_DATE,


            CREATED_BY,
            CREATION_DATE,

            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
     FROM Okl_Pdt_Pqy_Vals_V
     WHERE okl_pdt_pqy_vals_v.id = p_id;
    l_okl_pqvv_pk                  okl_pqvv_pk_csr%ROWTYPE;
    l_pqvv_rec                     pqvv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pqvv_pk_csr (p_pqvv_rec.id);
    FETCH okl_pqvv_pk_csr INTO
              l_pqvv_rec.ID,
              l_pqvv_rec.OBJECT_VERSION_NUMBER,
              l_pqvv_rec.PDQ_ID,
              l_pqvv_rec.PDT_ID,
              l_pqvv_rec.QVE_ID,
              l_pqvv_rec.FROM_DATE,
              l_pqvv_rec.TO_DATE,
              l_pqvv_rec.CREATED_BY,
              l_pqvv_rec.CREATION_DATE,
              l_pqvv_rec.LAST_UPDATED_BY,
              l_pqvv_rec.LAST_UPDATE_DATE,
              l_pqvv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pqvv_pk_csr%NOTFOUND;
    CLOSE okl_pqvv_pk_csr;
	x_pqvv_rec 	:= l_pqvv_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_pqvv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pqvv_pk_csr;
      END IF;

  END get_rec;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_parent_dates for: Okl_Pdt_Pqy_Vals_v
 ---------------------------------------------------------------------------

 PROCEDURE get_parent_dates(
    p_pqvv_rec                     IN pqvv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_pdtv_rec					   OUT NOCOPY pdtv_rec_type
  ) IS
    CURSOR okl_pdt_pk_csr (p_pdt_id  IN NUMBER) IS
    SELECT  FROM_DATE,
            TO_DATE
     FROM Okl_products_V pdtv
     WHERE pdtv.id = p_pdt_id;
    l_okl_pdtv_pk                  okl_pdt_pk_csr%ROWTYPE;
    l_pdtv_rec                     pdtv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pdt_pk_csr (p_pqvv_rec.pdt_id);
    FETCH okl_pdt_pk_csr INTO
              l_pdtv_rec.FROM_DATE,
              l_pdtv_rec.TO_DATE;
    x_no_data_found := okl_pdt_pk_csr%NOTFOUND;
    CLOSE okl_pdt_pk_csr;
    x_pdtv_rec := l_pdtv_rec;
 EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;


      IF (okl_pdt_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pdt_pk_csr;

      END IF;

 END get_parent_dates;



 -----------------------------------------------------------------------------

  -- PROCEDURE check_constraints for: Okl_Pdt_Pqy_Vals_v
 -----------------------------------------------------------------------------


 PROCEDURE Check_Constraints (
    p_api_version    IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	p_pqvv_rec		 IN  pqvv_rec_type,
        p_db_pqvv_rec 		IN   pqvv_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_valid          OUT NOCOPY BOOLEAN
  ) IS
   CURSOR okl_pqvv_chk_upd(p_pdt_id  NUMBER
	) IS
    SELECT '1' FROM okl_k_headers_v khdr
    WHERE khdr.pdt_id = p_pdt_id;

   CURSOR okl_pqv_pdt_fk_csr (p_pdt_id    IN Okl_Products_V.ID%TYPE,
                              p_date      IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_products_V pdt
    WHERE pdt.ID    = p_pdt_id
    AND   NVL(pdt.TO_DATE, p_date) < p_date;

    CURSOR okl_pqv_constraints_csr(p_qve_id     IN Okl_Pdt_Pqy_Vals_V.QVE_ID%TYPE,
		   					       p_from_date  IN Okl_Pdt_Pqy_Vals_V.FROM_DATE%TYPE,
							       p_to_date 	 IN Okl_Pdt_Pqy_Vals_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pqy_Values_V qve
     WHERE qve.ID  = p_qve_id
	 AND   ((qve.FROM_DATE > p_from_date OR
            p_from_date > NVL(qve.TO_DATE,p_from_date)) OR
	 	    NVL(qve.TO_DATE, p_to_date) < p_to_date);

   CURSOR c1(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
		p_pdq_id okl_pdt_pqy_vals_v.pdq_id%TYPE) IS
   SELECT '1'
   FROM okl_pdt_pqy_vals_v
   WHERE  pdt_id = p_pdt_id
   AND    pdq_id = p_pdq_id
   AND id <> NVL(p_pqvv_rec.id,-9999);

   CURSOR pdt_parameters_csr(cp_pdt_id IN Okl_Pdt_Pqy_Vals_V.QVE_ID%TYPE)
   IS
   SELECT pqy.id pqy_id,pqy.name name,
          qve.id qve_id,qve.value value
   FROM   okl_pdt_pqy_vals_v pqv,
          okl_pqy_values_v qve,
          okl_pdt_qualitys_v pqy
   WHERE  pqv.pdt_id = cp_pdt_id
   AND    pqy.ID = qve.PQY_ID
   AND    qve.ID = pqv.QVE_ID
   AND    pqy.name IN ('LEASE','INVESTOR','TAXOWNER','INTEREST_CALCULATION_BASIS','REVENUE_RECOGNITION_METHOD');


   CURSOR pdt_parameters_csr1(cp_pdt_id IN Okl_Pdt_Pqy_Vals_V.QVE_ID%TYPE)
   IS
   SELECT pqy.id pqy_id,pqy.name name,
          qve.id qve_id,qve.value value
   FROM   okl_pdt_pqy_vals_v pqv,
          okl_pqy_values_v qve,
          okl_pdt_qualitys_v pqy
   WHERE  pqv.pdt_id = cp_pdt_id
   AND    pqy.ID = qve.PQY_ID
   AND    qve.ID = pqv.QVE_ID
   AND    pqy.name IN ('REVENUE_RECOGNITION_METHOD','INTEREST_CALCULATION_BASIS');

   CURSOR csr_loan_rev(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE)
   IS
   SELECT a.deal_type,a. REVENUE_RECOGNITION_METHOD,A.INTEREST_CALCULATION_BASIS
   FROM okl_product_parameters_v a
   WHERE a.id = p_pdt_id;


   cursor chk_pqy_value(p_pdq_id okl_pdt_pqy_vals_v.pdq_id%TYPE)
   IS
   SELECT pqy.name
   FROM okl_pdt_qualitys pqy,
        okl_pdt_pqys pdq
   WHERE pdq.id = p_pdq_id
   and   pqy.id = pdq.pqy_id;

   cursor chk_deal_type(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
			p_qve_id okl_pdt_pqy_vals_v.qve_id%TYPE)
   IS
   SELECT DISTINCT C.deal_type
   FROM okl_products_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE a.aes_id = b.id
   AND b.gts_id = c.id
   AND a.id = p_pdt_id
   intersect
   select value from okl_pqy_values qve
   where qve.id = p_qve_id;


   cursor chk_investor(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
			p_qve_id okl_pdt_pqy_vals_v.qve_id%TYPE)
   IS
   SELECT DISTINCT decode (C.deal_type, 'SALE','SECURITIZATION','SYNDICATION','SYNDICATION') DEAL_TYPE
   FROM okl_products_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE a.aes_id = b.id
   AND b.gts_id = c.id
   AND a.id = p_pdt_id
   intersect
   select value from okl_pqy_values qve
   where qve.id = p_qve_id;

   cursor chk_tax_owner(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
			p_qve_id okl_pdt_pqy_vals_v.qve_id%TYPE)
   IS
   SELECT DISTINCT C.TAX_OWNER
   FROM okl_products_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE a.aes_id = b.id
   AND b.gts_id = c.id
   AND a.id = p_pdt_id
   intersect
   select value from okl_pqy_values qve
   where qve.id = p_qve_id;

 cursor chk_intrst_calc_mthd(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
			p_qve_id okl_pdt_pqy_vals_v.qve_id%TYPE)
   IS
   SELECT DISTINCT C.INTEREST_CALC_METH_CODE
   FROM okl_products_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE a.aes_id = b.id
   AND b.gts_id = c.id
   AND a.id = p_pdt_id
   intersect
   select value from okl_pqy_values qve
   where qve.id = p_qve_id;

 cursor chk_rev_rec_methd(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
			p_qve_id okl_pdt_pqy_vals_v.qve_id%TYPE)
   IS
   SELECT DISTINCT C.REVENUE_RECOG_METH_CODE
   FROM okl_products_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE a.aes_id = b.id
   AND b.gts_id = c.id
   AND a.id = p_pdt_id
   intersect
   select value from okl_pqy_values qve
   where qve.id = p_qve_id;

  Cursor csr_rev_rec_no_update(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE) IS
  SELECT '1'
  FROM okl_product_parameters_v pdt
  where reporting_pdt_id = p_pdt_id;

  csr_rec         pdt_parameters_csr%ROWTYPE;
  l_leaseop_lessee_mismatch  NUMBER(4):=0;
  l_loan_lessor_mismatch     NUMBER(4):=0;
  l_loanrev_lessor_mismatch  NUMBER(4):=0;
  l_FLT_FAC_loan_rev_mismatch  NUMBER(4):=0;
  l_FLT_FAC_EST_BILL_mismatch NUMBER(4):=0;
  l_REV_REC_NO_UPDATE   VARCHAR2(1);

  l_check		  VARCHAR2(1) := '?';
  l_deal_type		  VARCHAR2(500);
  l_investor              VARCHAR2(500);

  l_tax_owner		  VARCHAR2(50);
  l_pqy_value 		  VARCHAR2(50);
  l_row_not_found BOOLEAN     := FALSE;
  l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  l_unq_tbl       Okc_Util.unq_tbl_type;
  l_pqv_status    VARCHAR2(1);
  l_row_found     BOOLEAN := FALSE;
  l_token_1       VARCHAR2(999);
  l_token_2       VARCHAR2(999);
  l_token_3       VARCHAR2(999);
  l_token_4       VARCHAR2(999);
  l_token_5       VARCHAR2(999);
  l_token_6       VARCHAR2(999);
  l_token_7       VARCHAR2(999);

  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;


    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_PQV_VAL_SUMRY',
                                                        p_attribute_code => 'OKL_PDT_QUALITY_VALUES');


    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCTS');

    l_token_3 := l_token_1 ||','||l_token_2;


    l_token_4 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
                                                      p_attribute_code => 'OKL_KDTLS_CONTRACT');

    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_PQV_VAL_CREATE',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY_VALUE');

    l_token_6 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_PQV_VAL_SUMRY',
                                                        p_attribute_code => 'OKL_VALUE');

    l_token_7 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PQVALS_CRUPD',
                                                   p_attribute_code => 'OKL_PRODUCT_QUALITY_VALUES');

    -- Check for pqvv valid dates
    OPEN okl_pqvv_chk_upd(p_pqvv_rec.pdt_id);

    FETCH okl_pqvv_chk_upd INTO l_check;
    l_row_not_found := okl_pqvv_chk_upd%NOTFOUND;
    CLOSE okl_pqvv_chk_upd;

    IF l_row_not_found = FALSE THEN
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_IN_USE,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_1,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_4);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

   Open chk_pqy_value(p_pqvv_rec.pdq_id);
   fetch chk_pqy_value into l_pqy_value;
   if chk_pqy_value%notfound then
      null;
   end if;
   close chk_pqy_value;


   IF p_pqvv_rec.id <> Okl_Api.G_MISS_NUM OR
      p_pqvv_rec.id IS NOT NULL THEN

    if ltrim(rtrim(l_pqy_value)) IN ('REVENUE_RECOGNITION_METHOD') THEN

     -- Check csr_rev_rec_no_update
     OPEN csr_rev_rec_no_update(p_pqvv_rec.pdt_id);

     FETCH csr_rev_rec_no_update INTO l_REV_REC_NO_UPDATE;

     IF csr_rev_rec_no_update%FOUND AND p_pqvv_rec.qve_id <> p_db_pqvv_rec.qve_id then
	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_REV_REC_NO_UPDATE);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
     END IF;

    CLOSE csr_rev_rec_no_update;

    END IF;
  END IF;

  if ltrim(rtrim(l_pqy_value)) IN ('INVESTOR') THEN


    -- Check chk_investor
    OPEN chk_investor(p_pqvv_rec.pdt_id,p_pqvv_rec.qve_id);

    FETCH chk_investor INTO l_investor;

    if chk_investor%NOTFOUND then


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_INVESTOR_MISMATCH);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
   END IF;

   CLOSE chk_investor;
   END IF;

   if ltrim(rtrim(l_pqy_value)) IN ('LEASE') THEN


    -- Check chk_deal_type
    OPEN chk_deal_type(p_pqvv_rec.pdt_id,p_pqvv_rec.qve_id);

    FETCH chk_deal_type INTO l_deal_type;

    if chk_deal_type%NOTFOUND then


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_BOOK_CLASS_MISMATCH);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
   END IF;

   CLOSE chk_deal_type;
   END IF;

   if ltrim(rtrim(l_pqy_value)) = 'TAXOWNER' THEN

    -- Check chk_tax_owner
    OPEN chk_tax_owner(p_pqvv_rec.pdt_id,p_pqvv_rec.qve_id);

    FETCH chk_tax_owner INTO l_tax_owner;

    if chk_tax_owner%NOTFOUND then

	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_BOOK_CLASS_MISMATCH);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
   END IF;


   CLOSE chk_tax_owner;
   END IF;


   if ltrim(rtrim(l_pqy_value)) IN ('INTEREST_CALCULATION_BASIS') THEN


    -- Check chk_deal_type
    OPEN chk_intrst_calc_mthd(p_pqvv_rec.pdt_id,p_pqvv_rec.qve_id);

    FETCH chk_intrst_calc_mthd INTO l_deal_type;

    if chk_intrst_calc_mthd%NOTFOUND then


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_INT_CALC_BASIS_MISMATCH);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
   END IF;

   CLOSE chk_intrst_calc_mthd;
   END IF;


   if ltrim(rtrim(l_pqy_value)) IN ('REVENUE_RECOGNITION_METHOD') THEN


    -- Check chk_deal_type
    OPEN chk_rev_rec_methd(p_pqvv_rec.pdt_id,p_pqvv_rec.qve_id);

    FETCH chk_rev_rec_methd INTO l_deal_type;

    if chk_rev_rec_methd%NOTFOUND then


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_REVENUE_REC_METD_MISMATCH);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;
   END IF;

   CLOSE chk_rev_rec_methd;
   END IF;


	-- check for uniquness.
	IF p_pqvv_rec.id = Okl_Api.G_MISS_NUM THEN
	   OPEN c1(p_pqvv_rec.pdt_id,
	      p_pqvv_rec.pdq_id);
       FETCH c1 INTO l_pqv_status;
       l_row_found := c1%FOUND;
       CLOSE c1;
       IF l_row_found THEN

          		Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
			  	            p_msg_name	    => 'OKL_COLUMN_NOT_UNIQUE',
				            p_token1	    => G_TABLE_TOKEN,
				            p_token1_value => l_token_1,
				            p_token2	    => G_COLUMN_TOKEN,
				            p_token2_value => l_token_6);

	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
	END IF;

  BEGIN
   FOR CSR_REC IN pdt_parameters_csr(p_pqvv_rec.pdt_id)
   LOOP
    IF csr_rec.name = 'LEASE' AND csr_rec.value = 'LEASEOP' THEN
     SELECT COUNT(b.id)
	 INTO l_leaseop_lessee_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value =  'LESSEE'
     AND    b.name = 'TAXOWNER';
	ELSIF csr_rec.name = 'TAXOWNER' and csr_rec.value = 'LESSEE' THEN
     SELECT COUNT(b.id)
	 INTO l_leaseop_lessee_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value = 'LEASEOP'
     AND    b.name = 'LEASE';
	END IF;

        IF csr_rec.name = 'INTEREST_CALCULATION_BASIS' and csr_rec.value = 'FLOAT_FACTORS' THEN
      SELECT COUNT(b.id)
	 INTO l_FLT_FAC_loan_rev_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value =  'LOAN-REVOLVING'
     AND    b.name = 'LEASE';
     ELSIF csr_rec.name = 'LEASE' and csr_rec.value = 'LOAN-REVOLVING' THEN
      SELECT COUNT(b.id)
	 INTO l_FLT_FAC_loan_rev_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value =  'FLOAT_FACTORS'
     AND    b.name = 'INTEREST_CALCULATION_BASIS';
    END IF;


   IF csr_rec.name = 'REVENUE_RECOGNITION_METHOD' and csr_rec.value = 'ESTIMATED_AND_BILLED' THEN
      SELECT COUNT(b.id)
	 INTO l_FLT_FAC_EST_BILL_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value =  'FLOAT_FACTORS'
     AND    b.name = 'INTEREST_CALCULATION_BASIS';
   ELSIF csr_rec.name = 'INTEREST_CALCULATION_BASIS' and csr_rec.value = 'FLOAT_FACTORS' THEN
     SELECT COUNT(b.id)
	 INTO l_FLT_FAC_EST_BILL_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value =  'ESTIMATED_AND_BILLED'
     AND    b.name = 'REVENUE_RECOGNITION_METHOD';
   END IF;


   IF csr_rec.name = 'LEASE' AND csr_rec.value = 'LOAN' THEN
     SELECT COUNT(b.id)

	 INTO l_loan_lessor_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value = 'LESSOR'

     AND    b.name = 'TAXOWNER';
    ELSIF csr_rec.name = 'TAXOWNER' AND csr_rec.value = 'LESSOR' THEN
     SELECT COUNT(b.id)
	 INTO l_leaseop_lessee_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value = 'LOAN'
     AND    b.name = 'LEASE';
    END IF;

	IF csr_rec.name = 'LEASE' AND csr_rec.value = 'LOAN-REVOLVING' THEN
     SELECT COUNT(b.id)

	 INTO l_loanrev_lessor_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value = 'LESSOR'
     AND    b.name = 'TAXOWNER';
    ELSIF csr_rec.name = 'TAXOWNER' AND csr_rec.value = 'LESSOR' THEN
     SELECT COUNT(b.id)
	 INTO l_leaseop_lessee_mismatch
     FROM  OKL_pdt_pqy_vals_V a,
           okl_pdt_qualitys_v b,
           okl_pqy_values_v c
     WHERE  a.pdt_ID = p_pqvv_rec.pdt_id
     AND    b.id = c.pqy_id
     AND    c.id = p_pqvv_rec.qve_id
     AND    c.value = 'LOAN-REVOLVING'
     AND    b.name = 'LEASE';
    END IF;
	END LOOP;

    IF l_FLT_FAC_loan_rev_mismatch <> 0 THEN
         Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_FLT_FAC_LOAN_REV_MISMATCH);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF l_FLT_FAC_EST_BILL_mismatch <> 0 THEN
         Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_FLT_FAC_EST_BILL_MISMATCH);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;


    IF l_leaseop_lessee_mismatch <> 0 THEN
         Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_OPLEASE_LESSEE_MISMATCH);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF l_loan_lessor_mismatch <> 0 THEN
      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_LOAN_LESSOR_MISMATCH);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF l_loanrev_lessor_mismatch <> 0 THEN
        Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_LOANREV_LESSOR_MISMATCH);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  END;

   -- Check for constraints dates
   IF p_pqvv_rec.id = Okl_Api.G_MISS_NUM THEN
    OPEN okl_pqv_constraints_csr(p_pqvv_rec.qve_id,
		 					  	 p_pqvv_rec.from_date,
							  	 p_pqvv_rec.TO_DATE);
    FETCH okl_pqv_constraints_csr INTO l_check;
    l_row_not_found := okl_pqv_constraints_csr%NOTFOUND;
    CLOSE okl_pqv_constraints_csr;

    IF l_row_not_found = FALSE THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_7,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_3);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   END IF;


  EXCEPTION

    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,

							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_valid := FALSE;
	   x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF (okl_pqvv_chk_upd%ISOPEN) THEN
	   	  CLOSE okl_pqvv_chk_upd;
       END IF;

       IF (okl_pqv_pdt_fk_csr%ISOPEN) THEN
 	   	  CLOSE okl_pqv_pdt_fk_csr;
       END IF;

       IF (okl_pqv_constraints_csr%ISOPEN) THEN
 	   	  CLOSE okl_pqv_constraints_csr;

       END IF;

       IF (c1%ISOPEN) THEN
 	   	  CLOSE c1;
       END IF;

       IF (chk_deal_type%ISOPEN) THEN
 	   	  CLOSE chk_deal_type;
       END IF;

      IF (chk_investor%ISOPEN) THEN
 	   	  CLOSE chk_investor;
       END IF;


       IF (chk_tax_owner%ISOPEN) THEN
 	   	  CLOSE chk_tax_owner;
       END IF;

       IF (chk_pqy_value%ISOPEN) THEN
 	   	  CLOSE chk_pqy_value;
       END IF;


 END Check_Constraints;

   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Qve_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Qve_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Qve_Id(p_pqvv_rec      IN   pqvv_rec_type
					   ,x_return_status OUT  NOCOPY VARCHAR2)
  IS
      CURSOR okl_qvev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_pqy_values_v
       WHERE okl_pqy_values_v.id = p_id;

      l_qve_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_token_1                      VARCHAR2(999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PDT_PQV_VAL_CREATE',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY_VALUE');

    -- check for data before processing
    IF (p_pqvv_rec.qve_id IS NULL) OR
       (p_pqvv_rec.qve_id = Okl_Api.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSUVB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pqv_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pqv_Pvt.g_required_value
                          ,p_token1         => Okl_Pqv_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSUVB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF (p_pqvv_rec.QVE_ID IS NOT NULL)
      THEN
        OPEN okl_qvev_pk_csr(p_pqvv_rec.QVE_ID);
        FETCH okl_qvev_pk_csr INTO l_qve_status;
        l_row_notfound := okl_qvev_pk_csr%NOTFOUND;
        CLOSE okl_qvev_pk_csr;
        IF (l_row_notfound) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.set_message
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSUVB.pls call Okl_Api.set_message ');
    END;
  END IF;
          Okl_Api.set_message(Okl_Pqv_Pvt.G_APP_NAME, Okl_Pqv_Pvt.G_INVALID_VALUE,Okl_Pqv_Pvt.G_COL_NAME_TOKEN,l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSUVB.pls call Okl_Api.set_message ');


    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.set_message
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pqv_Pvt.g_app_name,
                          p_msg_name     => Okl_Pqv_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pqv_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pqv_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Qve_Id;

 ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --Function Name   : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
 ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_pqvv_rec IN  pqvv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Qve_Id
    Validate_Qve_Id(p_pqvv_rec,x_return_status);
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okl_Api.SET_MESSAGE(p_app_name         => Okl_Pqv_Pvt.g_app_name,
                           p_msg_name         => Okl_Pqv_Pvt.g_unexpected_error,
                           p_token1           => Okl_Pqv_Pvt.g_sqlcode_token,
                           p_token1_value     => SQLCODE,

                           p_token2           => Okl_Pqv_Pvt.g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE insert_pqvvalues for: Okl_Pdt_Pqy_Vals_v
  ---------------------------------------------------------------------------
  PROCEDURE insert_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqyv_rec                     IN  pqyv_rec_type,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_pqvv_rec                     IN  pqvv_rec_type,
    x_pqvv_rec                     OUT NOCOPY pqvv_rec_type
    ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_pqvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_valid			  BOOLEAN;

	l_pqvv_rec		  pqvv_rec_type;
	l_db_pqvv_rec		  pqvv_rec_type;

    l_pdtv_rec		  pdtv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_no_data_found   	  	BOOLEAN := TRUE;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_pqvv_rec := p_pqvv_rec;

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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

    get_parent_dates(p_pqvv_rec 	  => l_pqvv_rec,
                    x_no_data_found   => l_row_notfound,
                    x_return_status   => l_return_status,
	                x_pdtv_rec	      => l_pdtv_rec);


	IF (l_row_notfound) THEN
      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--assign parent dates.

	l_pqvv_rec.from_date := l_pdtv_rec.from_date;
	l_pqvv_rec.TO_DATE   := l_pdtv_rec.TO_DATE;

    /* call check_constraints to check the validity of this relationship */

	Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_pqvv_rec 		=> l_pqvv_rec,
                      p_db_pqvv_rec 		=> l_db_pqvv_rec,
				   	  x_return_status	=> l_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
				   	  x_valid			=> l_valid);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* public api to insert pqyvalues */

-- Start of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.insert_pqy_values
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN

        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSUVB.pls call Okl_Pqy_Values_Pub.insert_pqy_values ');
    END;
  END IF;
    Okl_Pqy_Values_Pub.insert_pqy_values(p_api_version   => p_api_version,
                            	    	 p_init_msg_list => p_init_msg_list,
                              		 	 x_return_status => l_return_status,
                              		 	 x_msg_count     => x_msg_count,
                              		 	 x_msg_data      => x_msg_data,
                              		 	 p_pqvv_rec      => l_pqvv_rec,
                              		 	 x_pqvv_rec      => x_pqvv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSUVB.pls call Okl_Pqy_Values_Pub.insert_pqy_values ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.insert_pqy_values

     IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,

												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,

												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END insert_pqvalues;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_pqvvalues for: Okl_Pdt_Pqy_Vals_v
  ---------------------------------------------------------------------------
  PROCEDURE update_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pqyv_rec                     IN  pqyv_rec_type,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_pqvv_rec                     IN  pqvv_rec_type,
    x_pqvv_rec                     OUT NOCOPY pqvv_rec_type
    ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_pqvalues';
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_valid			  BOOLEAN;
	l_pqvv_rec		  pqvv_rec_type;
    l_pdtv_rec		  pdtv_rec_type;
    l_db_pqvv_rec		  pqvv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_no_data_found   	  	BOOLEAN := TRUE;


  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_pqvv_rec := p_pqvv_rec;

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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

    /* fetch old details from the database */

      get_rec(p_pqvv_rec 	 	=> l_pqvv_rec,
		    x_return_status => l_return_status,

			x_no_data_found => l_no_data_found,
    		x_pqvv_rec		=> l_db_pqvv_rec);

       IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	get_parent_dates(p_pqvv_rec 	  => l_pqvv_rec,
                     x_no_data_found  => l_row_notfound,
	                 x_return_status  => l_return_status,
	                 x_pdtv_rec		  => l_pdtv_rec);

	IF (l_row_notfound) THEN

      l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	ELSIF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

	--assign parent dates.

	l_pqvv_rec.from_date := l_pdtv_rec.from_date;
	l_pqvv_rec.TO_DATE   := l_pdtv_rec.TO_DATE;


    /* call check_constraints to check the validity of this relationship */

	Check_Constraints(p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      p_pqvv_rec 		=> l_pqvv_rec,
                      p_db_pqvv_rec 		=> l_db_pqvv_rec,
				   	  x_return_status	=> l_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
				   	  x_valid			=> l_valid);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE Okl_Api.G_EXCEPTION_ERROR;

    END IF;

	/* public api to update pqyvalues */


-- Start of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.update_pqy_values
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSUVB.pls call Okl_Pqy_Values_Pub.update_pqy_values ');
    END;
  END IF;
    Okl_Pqy_Values_Pub.update_pqy_values(p_api_version   => p_api_version,
                            		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_pqvv_rec      => l_pqvv_rec,
                              		 	   x_pqvv_rec      => x_pqvv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSUVB.pls call Okl_Pqy_Values_Pub.update_pqy_values ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.update_pqy_values

     IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
     ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END update_pqvalues;
  PROCEDURE update_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_pqvv_tbl                     IN  pqvv_tbl_type,
    x_pqvv_tbl                     OUT NOCOPY pqvv_tbl_type) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_pqvalues';
	l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	i                       NUMBER := 0;
	l_api_version     CONSTANT NUMBER := 1;
    	BEGIN
    	    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    	  l_overall_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_overall_status);
		-- Make sure PL/SQL table has records in it before passing
		IF (p_pqvv_tbl.COUNT > 0) THEN
			i := p_pqvv_tbl.FIRST;
			LOOP
				update_pqvalues(
				  p_api_version                  => p_api_version,
				  p_init_msg_list                => OKL_API.G_FALSE,
				  x_return_status                => x_return_status,
				  x_msg_count                    => x_msg_count,
				  x_msg_data                     => x_msg_data,
				   p_pqyv_rec                =>       p_pqyv_rec,
                  p_pdtv_rec   =>    p_pdtv_rec,
                 p_pqvv_rec                     =>   p_pqvv_tbl(i),
                x_pqvv_rec                       => x_pqvv_tbl(i)
                );
				  		IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	    EXIT WHEN (i = p_pqvv_tbl.LAST);
				i := p_pqvv_tbl.NEXT(i);
			END LOOP;
			END IF;
				 Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	 EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,

												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');




   END update_pqvalues;
   PROCEDURE insert_pqvalues(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
     p_pqyv_rec                     IN  pqyv_rec_type,
    p_pdtv_rec                     IN  pdtv_rec_type,
    p_pqvv_tbl                     IN  pqvv_tbl_type,
    x_pqvv_tbl                     OUT NOCOPY pqvv_tbl_type) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_pqvalues';
	l_overall_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	i                       NUMBER := 0;
	l_api_version     CONSTANT NUMBER := 1;
	 l_pqyv_rec pqyv_rec_type ;
			l_pdtv_rec pdtv_rec_type;
    	BEGIN
    	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    	    l_overall_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_overall_status);

		-- Make sure PL/SQL table has records in it before passing
		IF (p_pqvv_tbl.COUNT > 0) THEN
			i := p_pqvv_tbl.FIRST;

			LOOP


				insert_pqvalues(
				  p_api_version                  => p_api_version,
				  p_init_msg_list                => OKL_API.G_FALSE,
				  x_return_status                => x_return_status,
				  x_msg_count                    => x_msg_count,
				  x_msg_data                     => x_msg_data,
				   p_pqyv_rec                =>       p_pqyv_rec,
                  p_pdtv_rec   =>    p_pdtv_rec,
                 p_pqvv_rec                     =>   p_pqvv_tbl(i),
                x_pqvv_rec                       => x_pqvv_tbl(i)
                );

				  		IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	    EXIT WHEN (i = p_pqvv_tbl.LAST);
				i := p_pqvv_tbl.NEXT(i);
			END LOOP;
			END IF;
			 Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	 EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,

												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');




   END insert_pqvalues;

END Okl_Setuppqvalues_Pvt;

/
