--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPRODUCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPRODUCTS_PVT" AS
/* $Header: OKLRSPDB.pls 120.28.12010000.6 2009/06/02 10:50:49 racheruv ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.PRODUCTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
G_IN_USE                    CONSTANT VARCHAR2(100) := 'OKL_IN_USE';
G_BOOK_CLASS_MISS	    CONSTANT VARCHAR2(200) := 'OKL_BOOK_CLASS_MISS';
G_PDT_NOT_VALIDATED         CONSTANT VARCHAR2(200) := 'OKL_PDT_NOT_VALIDATED';
G_PDT_SUBMTD_FOR_APPROVAL   CONSTANT VARCHAR2(200) := 'OKL_PDT_SUBMTD_FOR_APPROVAL';
G_PTL_AES_BC_MISMATCH       CONSTANT VARCHAR2(200) := 'OKL_PTL_AES_BC_MISMATCH';
G_PDT_IN_PEND_APPROVAL      CONSTANT VARCHAR2(200) := 'OKL_PDT_IN_PEND_APPROVAL';
G_PDT_APPROVED              CONSTANT VARCHAR2(200) := 'OKL_PDT_APPROVED';
G_PDT_VALDTION_NOT_VALID    CONSTANT VARCHAR2(200) := 'OKL_PDT_VALDTION_NOT_VALID';


  -- product Stream Type
  SUBTYPE psyv_rec_type IS Okl_Pdt_Stys_Pub.psyv_rec_type;
  SUBTYPE psyv_tbl_type IS Okl_Pdt_Stys_Pub.psyv_tbl_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PRODUCTS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_pdtv_rec                     IN pdtv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_pdtv_rec					   OUT NOCOPY pdtv_rec_type
  ) IS
    CURSOR okl_pdtv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            VERSION,
            NVL(DESCRIPTION,Okl_Api.G_MISS_CHAR) DESCRIPTION,
            AES_ID,
            PTL_ID,
            REPORTING_PDT_ID,
            NVL(LEGACY_PRODUCT_YN, Okl_Api.G_MISS_CHAR) LEGACY_PRODUCT_YN,
            FROM_DATE,
            NVL(TO_DATE,Okl_Api.G_MISS_DATE) TO_DATE,
            NVL(product_status_code, Okl_Api.G_MISS_CHAR) product_status_code,
            NVL(ATTRIBUTE_CATEGORY, Okl_Api.G_MISS_CHAR) ATTRIBUTE_CATEGORY,
            NVL(ATTRIBUTE1, Okl_Api.G_MISS_CHAR) ATTRIBUTE1,
            NVL(ATTRIBUTE2, Okl_Api.G_MISS_CHAR) ATTRIBUTE2,
            NVL(ATTRIBUTE3, Okl_Api.G_MISS_CHAR) ATTRIBUTE3,
            NVL(ATTRIBUTE4, Okl_Api.G_MISS_CHAR) ATTRIBUTE4,
            NVL(ATTRIBUTE5, Okl_Api.G_MISS_CHAR) ATTRIBUTE5,
            NVL(ATTRIBUTE6, Okl_Api.G_MISS_CHAR) ATTRIBUTE6,
            NVL(ATTRIBUTE7, Okl_Api.G_MISS_CHAR) ATTRIBUTE7,
            NVL(ATTRIBUTE8, Okl_Api.G_MISS_CHAR) ATTRIBUTE8,
            NVL(ATTRIBUTE9, Okl_Api.G_MISS_CHAR) ATTRIBUTE9,
            NVL(ATTRIBUTE10, Okl_Api.G_MISS_CHAR) ATTRIBUTE10,
            NVL(ATTRIBUTE11, Okl_Api.G_MISS_CHAR) ATTRIBUTE11,
            NVL(ATTRIBUTE12, Okl_Api.G_MISS_CHAR) ATTRIBUTE12,
            NVL(ATTRIBUTE13, Okl_Api.G_MISS_CHAR) ATTRIBUTE13,
            NVL(ATTRIBUTE14, Okl_Api.G_MISS_CHAR) ATTRIBUTE14,
            NVL(ATTRIBUTE15, Okl_Api.G_MISS_CHAR) ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, Okl_Api.G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM Okl_Products_V
     WHERE okl_products_v.id    = p_id;
    l_okl_pdtv_pk                  okl_pdtv_pk_csr%ROWTYPE;
    l_pdtv_rec                     pdtv_rec_type;
  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_pdtv_pk_csr (p_pdtv_rec.id);
    FETCH okl_pdtv_pk_csr INTO
              l_pdtv_rec.ID,
              l_pdtv_rec.OBJECT_VERSION_NUMBER,
              l_pdtv_rec.NAME,
              l_pdtv_rec.VERSION,
              l_pdtv_rec.DESCRIPTION,
              l_pdtv_rec.AES_ID,
              l_pdtv_rec.PTL_ID,
              l_pdtv_rec.REPORTING_PDT_ID,

              l_pdtv_rec.LEGACY_PRODUCT_YN,
              l_pdtv_rec.FROM_DATE,
              l_pdtv_rec.TO_DATE,
              l_pdtv_rec.product_status_code,
              l_pdtv_rec.ATTRIBUTE_CATEGORY,
              l_pdtv_rec.ATTRIBUTE1,


              l_pdtv_rec.ATTRIBUTE2,
              l_pdtv_rec.ATTRIBUTE3,
              l_pdtv_rec.ATTRIBUTE4,
              l_pdtv_rec.ATTRIBUTE5,
              l_pdtv_rec.ATTRIBUTE6,
              l_pdtv_rec.ATTRIBUTE7,
              l_pdtv_rec.ATTRIBUTE8,
              l_pdtv_rec.ATTRIBUTE9,
              l_pdtv_rec.ATTRIBUTE10,
              l_pdtv_rec.ATTRIBUTE11,
              l_pdtv_rec.ATTRIBUTE12,
              l_pdtv_rec.ATTRIBUTE13,
              l_pdtv_rec.ATTRIBUTE14,
              l_pdtv_rec.ATTRIBUTE15,
              l_pdtv_rec.CREATED_BY,
              l_pdtv_rec.CREATION_DATE,
              l_pdtv_rec.LAST_UPDATED_BY,
              l_pdtv_rec.LAST_UPDATE_DATE,
              l_pdtv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pdtv_pk_csr%NOTFOUND;
    CLOSE okl_pdtv_pk_csr;
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

      IF (okl_pdtv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pdtv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_pdt_pqy_vals for: OKL_PDT_PQY_VALS
  -- Private procedure called from delete_pqvalues.
  ---------------------------------------------------------------------------

  PROCEDURE delete_pdt_pqy_vals(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT okl_api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pdtv_rec              IN  pdtv_rec_type) IS
    i                        PLS_INTEGER :=0;
    l_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_del_pqvv_tbl           OKL_PQY_VALUES_PUB.pqvv_tbl_type;

    CURSOR pqv_csr IS
      SELECT pqvv.id
        FROM okl_pdt_pqy_vals_v pqvv
       WHERE pqvv.pdt_id = p_pdtv_rec.id;

  BEGIN

    FOR pqv_rec IN pqv_csr
    LOOP
      i := i + 1;
      l_del_pqvv_tbl(i).id := pqv_rec.id;
    END LOOP;
    IF l_del_pqvv_tbl.COUNT > 0 THEN
     /* public api to delete product option values */
-- Start of wraper code generated automatically by Debug code generator for OKL_PQY_VALUES_PUB.delete_pqy_values
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call OKL_PQY_VALUES_PUB.delete_pqy_values ');
    END;
  END IF;
    OKL_PQY_VALUES_PUB.delete_pqy_values(p_api_version   => p_api_version,
                             	     	 p_init_msg_list  => p_init_msg_list,
                              		     x_return_status  => l_return_status,
                              		     x_msg_count      => x_msg_count,
                              		     x_msg_data       => x_msg_data,
                              		     p_pqvv_tbl       => l_del_pqvv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call OKL_PQY_VALUES_PUB.delete_pqy_values ');
    END;
  END IF;

-- End of wraper code generated automatically by Debug code generator for OKL_PQY_VALUES_PUB.delete_pqy_values

      IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_PROCESSING;
      ELSE

        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN

          l_return_status := x_return_status;

        END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      NULL;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);

      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END delete_pdt_pqy_vals;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_pdt_psy_vals for: OKL_PDT_PQY_VALS
  -- Private procedure called from delete_pqvalues.
  ---------------------------------------------------------------------------

  PROCEDURE delete_pdt_psys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT okl_api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pdtv_rec              IN  pdtv_rec_type) IS
    i                        PLS_INTEGER :=0;
    l_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_del_psyv_tbl           Okl_Pdt_Stys_Pub.psyv_tbl_type;

    CURSOR psy_csr IS
      SELECT psyv.id
        FROM okl_prod_strm_types_v psyv
       WHERE psyv.pdt_id = p_pdtv_rec.id;

  BEGIN

    FOR psy_rec IN psy_csr
    LOOP
      i := i + 1;
      l_del_psyv_tbl(i).id := psy_rec.id;
    END LOOP;

    IF l_del_psyv_tbl.COUNT > 0 THEN

    Okl_Pdt_Stys_Pub.delete_pdt_stys(p_api_version   => p_api_version,
                             	     p_init_msg_list  => p_init_msg_list,
                              	     x_return_status  => l_return_status,
                              	     x_msg_count      => x_msg_count,
                              	     x_msg_data       => x_msg_data,
                              	     p_psyv_tbl       => l_del_psyv_tbl);


      IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_PROCESSING;
      ELSE
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
        END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      NULL;
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);

      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END delete_pdt_psys;


  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_PRODUCTS_V
  -- To verify whether the dates are valid in the following entities
  -- 1. Quality Value
  -- 2. Option
  -- 3. Option Value
  -- 4. Product Template
  ---------------------------------------------------------------------------

  PROCEDURE Check_Constraints (
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_upd_pdtv_rec     IN pdtv_rec_type,
    p_pdtv_rec         IN pdtv_rec_type,
    p_db_pdtv_rec      IN pdtv_rec_type,


    x_return_status	   OUT NOCOPY VARCHAR2,

    x_valid            OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_contracts_csr (p_pdt_id     IN Okl_Products_V.ID%TYPE,
		   					  p_from_date  IN Okl_Products_V.FROM_DATE%TYPE,
							  p_to_date    IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_K_Headers_V khr,
         Okl_K_Headers_Full_V khf
     WHERE khr.PDT_ID    = p_pdt_id
     AND   khf.ID        = khr.ID
	 AND   khf.START_DATE BETWEEN p_from_date AND p_to_date;


  CURSOR okl_pdtv_chk(p_pdt_id  NUMBER
	) IS
    SELECT '1' FROM okl_k_headers_v khdr
    WHERE khdr.pdt_id = p_pdt_id;

    CURSOR okl_pdt_constraints_csr (p_pdt_id     IN Okl_Products_V.ID%TYPE,
		   					        p_from_date  IN Okl_Products_V.FROM_DATE%TYPE,
							        p_to_date 	 IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Pqy_Values_V qve,
         Okl_Pdt_Pqy_Vals_V pqv
    WHERE pqv.PDT_ID    = p_pdt_id
    AND   qve.ID        = pqv.QVE_ID
	AND   ((qve.FROM_DATE > p_from_date OR
            p_from_date > NVL(qve.TO_DATE,p_from_date)) OR
	 	    NVL(qve.TO_DATE, p_to_date) < p_to_date)
    UNION ALL
    SELECT '2'
    FROM Okl_Pdt_Opts_V pon,
         Okl_Options_V opt
    WHERE pon.PDT_ID    = p_pdt_id
    AND   opt.ID        = pon.OPT_ID
	AND   ((opt.FROM_DATE > p_from_date OR
            p_from_date > NVL(opt.TO_DATE,p_from_date)) OR
	 	    NVL(opt.TO_DATE, p_to_date) < p_to_date)
    UNION ALL
    SELECT '3'
    FROM Okl_Pdt_Opts_V pon,
         Okl_Pdt_Opt_Vals_V pov,
         Okl_Opt_Values_V ove
    WHERE pon.PDT_ID    = p_pdt_id
    AND   pov.PON_ID    = pon.ID
    AND   ove.ID        = pov.OVE_ID
	AND   ((ove.FROM_DATE > p_from_date OR
        	 p_from_date > NVL(ove.TO_DATE,p_from_date)) OR
	 	    NVL(ove.TO_DATE, p_to_date) < p_to_date);
/*    UNION ALL
    SELECT '4'
    FROM Okl_Strm_Type_b sty,
         Okl_Prod_Strm_Types_v psy
    WHERE psy.PDT_ID    = p_pdt_id
    AND   psy.sty_id    = sty.ID
	AND   ((sty.START_DATE > p_from_date OR
            p_from_date > NVL(sty.END_DATE,p_from_date)) OR
	 	    NVL(sty.END_DATE, p_to_date) < p_to_date)
*/


    CURSOR okl_pdt_aes_ptl_csr (p_aes_id      IN Okl_Products_V.AES_ID%TYPE,
                                p_ptl_id      IN Okl_Products_V.PTL_ID%TYPE,
		   					    p_from_date   IN Okl_Products_V.FROM_DATE%TYPE,
							    p_to_date 	  IN Okl_Products_V.TO_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Ae_Tmpt_Sets_V aes
    WHERE aes.ID    = p_aes_id
	AND   ((aes.START_DATE > p_from_date OR
	       p_from_date > NVL(aes.END_DATE,p_from_date)) OR
	       NVL(aes.END_DATE, p_to_date) < p_to_date)
    UNION ALL
    SELECT '2'
    FROM Okl_Pdt_Templates_V PTL
    WHERE PTL.ID        = p_ptl_id
	AND   ((PTL.FROM_DATE > p_from_date OR
               p_from_date > NVL(PTL.TO_DATE,p_from_date)) OR
	 	    NVL(PTL.TO_DATE, p_to_date) < p_to_date);

   CURSOR c1(p_name okl_products_v.name%TYPE,
		p_version okl_products_v.version%TYPE) IS
   SELECT '1'
   FROM okl_products_v
   WHERE  name = p_name

   AND    version = p_version;

   CURSOR choose_qlty_csr(cp_ptl_id okl_pdt_templates_v.id%TYPE) IS
   SELECT DISTINCT pqy.id id,
                   pqy.name name
   FROM   okl_pdt_qualitys_v pqy,
          okl_pdt_pqys_v pdq
   WHERE  pqy.id = pdq.pqy_id
   AND    pdq.ptl_id = cp_ptl_id

   AND    pqy.name IN ('LEASE','INVESTOR','TAXOWNER');

   l_pdt_status     VARCHAR2(1);
   l_chk_bc     VARCHAR2(100);
   l_chk_aes_bc     VARCHAR2(100);
   l_chk_ptl_bc     VARCHAR2(100);
   l_token_1        VARCHAR2(1999);
   l_token_2        VARCHAR2(1999);
   l_token_3        VARCHAR2(1999);
   l_token_4        VARCHAR2(1999);
   l_token_5        VARCHAR2(1999);
   l_token_6        VARCHAR2(1999);
   l_token_7        VARCHAR2(1999);
   l_token_8        VARCHAR2(1999);
   l_token_9        VARCHAR2(1999);

   l_token_10        VARCHAR2(1999);

   csr_rec        choose_qlty_csr%ROWTYPE;
   l_quality_miss_cnt  NUMBER(4):=0;
   l_pdt_ptl_changed          NUMBER(4):=0;
   l_pdt_psy_changed          NUMBER(4):=0;
   l_lease_values_miss_cnt    NUMBER(4):=0;
   l_taxown_values_miss_cnt   NUMBER(4):=0;
   l_sec_values_miss_cnt      NUMBER(4):=0;
   l_invalid_product_cnt   NUMBER(4):=0;
   l_return_status  VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_row_found      BOOLEAN := FALSE;
   l_check		   	VARCHAR2(1) := '?';
   l_row_not_found	BOOLEAN := FALSE;
   l_name           okl_products_v.name%TYPE;
   l_to_date       okl_products_v.TO_DATE%TYPE;

   l_rep_ptl_id               NUMBER; -- racheruv..R12.1.2
  BEGIN
    x_valid := TRUE;
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCTS');

    l_token_2 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_TEMPLATE_SERCH',
                                                      p_attribute_code => 'OKL_PRODUCT_TEMPLATES');

    l_token_3 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_TEMPLATE_SETS',
                                                      p_attribute_code => 'OKL_TEMPLATE_SETS');
    l_token_4 := l_token_2 ||','||l_token_3;

    l_token_5 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PQVALS_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT_QUALITY_VALUES');

    l_token_6 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTION_SERCH',
                                                      p_attribute_code => 'OKL_OPTIONS');

    l_token_7 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_OPTVAL_SERCH',
                                                      p_attribute_code => 'OKL_OPTION_VALUES');

    l_token_8 := l_token_5 ||','|| l_token_6 || ',' || l_token_7;

    l_token_9 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_CONTRACT_DTLS',
                                                      p_attribute_code => 'OKL_KDTLS_CONTRACT');


    l_token_10 := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_PRODUCT_CRUPD',
                                                      p_attribute_code => 'OKL_PRODUCT');

   -- Halt the processing if the Product is active(used by a contract).
   IF p_pdtv_rec.id <> Okl_Api.G_MISS_NUM THEN
    OPEN okl_pdtv_chk(p_upd_pdtv_rec.id);


    FETCH okl_pdtv_chk INTO l_check;
    l_row_not_found := okl_pdtv_chk%NOTFOUND;
    CLOSE okl_pdtv_chk;

    IF l_row_not_found = FALSE THEN

	      OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_IN_USE,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_10,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_9);


       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
   END IF;



    -- Fix for g_miss_date
    IF p_pdtv_rec.TO_DATE = Okl_Api.G_MISS_DATE THEN
          l_to_date := NULL;
    ELSE
          l_to_date := p_pdtv_rec.TO_DATE;
    END IF;

    IF p_pdtv_rec.id = Okl_Api.G_MISS_NUM THEN
       l_name := Okl_Accounting_Util.okl_upper(p_pdtv_rec.name);

       OPEN c1(l_name,
	      p_pdtv_rec.version);
       FETCH c1 INTO l_pdt_status;
       l_row_found := c1%FOUND;
       CLOSE c1;
       IF l_row_found THEN



	      Okl_Api.set_message('OKL',G_UNQS, G_TABLE_TOKEN, l_token_1);
		  x_return_status := Okl_Api.G_RET_STS_ERROR;
		  x_valid := FALSE;
	      RAISE G_EXCEPTION_HALT_PROCESSING;
        END IF;
    END IF;


    IF p_pdtv_rec.id <> Okl_Api.G_MISS_NUM AND
            p_db_pdtv_rec.aes_id <> p_pdtv_rec.aes_id THEN
            SELECT COUNT(aes.id)
     	    INTO l_pdt_psy_changed
            FROM
                okl_ae_tmpt_sets_v aes,
                okl_prod_strm_types_v psy
            WHERE aes.id = p_db_pdtv_rec.aes_id
            and psy.pdt_id = p_upd_pdtv_rec.id;

            -- check to see if the product already has a streams attached to it , if yes delete the
	    -- old child records.
 	    IF l_pdt_psy_changed > 0 THEN
			    delete_pdt_psys(p_api_version   => p_api_version,
                       		         p_init_msg_list => p_init_msg_list,
                         		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_pdtv_rec      => p_pdtv_rec);

				IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN


       		                  x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
          	  	          RAISE G_EXCEPTION_HALT_PROCESSING;
          	                ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR)THEN


					x_return_status    := Okl_Api.G_RET_STS_ERROR;
      	  	 	              RAISE G_EXCEPTION_HALT_PROCESSING;

			        END IF;

 		 END IF;
    END IF;

 /*===============================
  -- multi gaap validations BEGIN
=================================*/

  BEGIN
    -- ALLOW REPORTING PRODUCT FOR LOCAL SECURITIZATION PRODUCT
    SELECT COUNT(pqy.id)
	INTO l_invalid_product_cnt
    FROM
	     okl_pdt_qualitys_v pqy,
         okl_pdt_pqys_v pdq
    where pqy.id = pdq.pqy_id
    AND    pdq.ptl_id = p_pdtv_rec.ptl_id
	AND    pqy.name = 'INVESTOR';

    IF l_invalid_product_cnt > 0 AND (p_upd_pdtv_rec.reporting_pdt_id IS NOT NULL AND
	                               p_upd_pdtv_rec.reporting_pdt_id <> OKL_API.G_MISS_NUM) THEN
	   -- racheruv .. r12.1.2 .. start
       select ptl_id
	     into l_rep_ptl_id
		 from okl_products
        where id = p_upd_pdtv_rec.reporting_pdt_id;

		select count(pqy.id)
		  into l_invalid_product_cnt
		  from okl_pdt_qualitys_v pqy,
		       okl_pdt_pqys_v pdq
         where pqy.id = pdq.pqy_id
		   and pdq.ptl_id = l_rep_ptl_id
		   and pqy.name = 'INVESTOR';

       if l_invalid_product_cnt = 0 then

			Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						        p_msg_name	   => G_INVALID_PDT);
	        x_valid := FALSE;
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_PROCESSING;
       end if; -- racheruv .. R12.1.2 .. end.
    END IF;

    -- CHECK TO verify if atlease one quality LEASE BOOK CLASSIFICATION /TAX OWNER oR
    -- INVESTOR AGREEMENT CLASSIFICATION is defined for a product.
    SELECT COUNT(pqy.id)
	INTO l_quality_miss_cnt
    FROM
	     okl_pdt_qualitys_v pqy,
         okl_pdt_pqys_v pdq
    WHERE  pqy.id = pdq.pqy_id
    AND    pdq.ptl_id = p_pdtv_rec.ptl_id
    AND    pqy.name IN ('LEASE','INVESTOR','TAXOWNER');


	IF l_quality_miss_cnt = 0 THEN


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						    p_msg_name	   => G_LEASE_SEC_TAXOWN_MISS);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
	ELSE
      -- CHECK TO verify if all the quality attached to the product have values defined
      FOR csr_rec in choose_qlty_csr(p_pdtv_rec.ptl_id)
      LOOP

         IF p_pdtv_rec.id <> Okl_Api.G_MISS_NUM AND
                p_db_pdtv_rec.ptl_id <> p_pdtv_rec.ptl_id THEN
  	    SELECT COUNT(pqv.id)

     	    INTO l_pdt_ptl_changed
            FROM okl_pqy_values_v qve,
		 okl_pdt_qualitys pqy,
                 okl_pdt_pqys_v pdq,
			    okl_pdt_pqy_vals pqv
            WHERE qve.pqy_id = pqy.id
	    AND   pqv.qve_id = qve.id
   	    AND   pqv.pdq_id = pdq.id
	    AND   pdq.ptl_id = p_db_pdtv_rec.ptl_id
	    AND   pqv.pdt_id = p_upd_pdtv_rec.id;
	    -- check to see if the product already has a product template attached to it , if yes delete the
	    -- old child records.
 	    IF l_pdt_ptl_changed > 0 THEN
			     delete_pdt_pqy_vals(p_api_version   => p_api_version,
                       		         p_init_msg_list => p_init_msg_list,
                         		     x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_pdtv_rec      => p_pdtv_rec);

  		IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       		       x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
          	   RAISE G_EXCEPTION_HALT_PROCESSING;
        	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR)THEN
			x_return_status    := Okl_Api.G_RET_STS_ERROR;
      	  	   RAISE G_EXCEPTION_HALT_PROCESSING;
       	        END IF;

       	    END IF;
	  END IF;

            IF csr_rec.name = 'LEASE' THEN

               SELECT COUNT(qve.id)
	       INTO l_lease_values_miss_cnt
               FROM okl_pqy_values_v qve
               WHERE qve.pqy_id = csr_rec.id
	       AND   qve.value IN ('LEASEDF','LEASEOP','LEASEST','LOAN','LOAN-REVOLVING');

    	       IF l_lease_values_miss_cnt <> 5 THEN



                  Okl_Api.SET_MESSAGE(p_app_name   => G_APP_NAME,
				      p_msg_name	   => G_LEASE_VALUES_MISS);
  	          x_valid := FALSE;
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_PROCESSING;
               END IF;

            END IF;

           IF csr_rec.name = 'TAXOWNER' THEN
        	 SELECT COUNT(qve.id)
		 INTO l_taxown_values_miss_cnt
	         FROM okl_pqy_values_v qve
	         WHERE qve.pqy_id = csr_rec.id
	         AND   qve.value IN ('LESSEE','LESSOR');

		  IF l_taxown_values_miss_cnt <> 2 THEN


	             Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	  			       p_msg_name	   => G_TAXOWN_VALUES_MISS);
	             x_valid := FALSE;
	             x_return_status := Okl_Api.G_RET_STS_ERROR;
        	    RAISE G_EXCEPTION_HALT_PROCESSING;
 	          END IF;
           END IF;

      IF csr_rec.name = 'INVESTOR' THEN

         SELECT COUNT(qve.id)
		 INTO l_sec_values_miss_cnt
         FROM
		      okl_pqy_values_v qve
          WHERE qve.pqy_id = csr_rec.id
		  AND   qve.value IN ('SECURITIZATION','SYNDICATION');

		  IF l_sec_values_miss_cnt <> 2 THEN



            Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
		 				    p_msg_name	       => G_SEC_VALUES_MISS);
	        x_valid := FALSE;
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_PROCESSING;
          END IF;
	   END IF;
     END LOOP;
    END IF;

  END;

/*===============================
  -- multi gaap validations END
=================================*/

    -- Check for contract dates

    IF p_pdtv_rec.id <> Okl_Api.G_MISS_NUM THEN
       OPEN okl_contracts_csr (p_pdtv_rec.id,
		 				       p_pdtv_rec.from_date,
						       l_to_date);
       FETCH okl_contracts_csr INTO l_check;
       l_row_not_found := okl_contracts_csr%NOTFOUND;
       CLOSE okl_contracts_csr;

       IF l_row_not_found = FALSE THEN


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_DATES_MISMATCH,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => l_token_9,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_1);
	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
    END IF;

    -- Check for constraints dates in the case of update only
    IF p_upd_pdtv_rec.id <> Okl_Api.G_MISS_NUM THEN
       OPEN okl_pdt_constraints_csr (p_upd_pdtv_rec.id,
		 					  	     p_pdtv_rec.from_date,
							  	     l_to_date);
       FETCH okl_pdt_constraints_csr INTO l_check;
       l_row_not_found := okl_pdt_constraints_csr%NOTFOUND;
       CLOSE okl_pdt_constraints_csr;


       IF l_row_not_found = FALSE THEN


	      Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						      p_msg_name	   => G_DATES_MISMATCH,
						      p_token1		   => G_PARENT_TABLE_TOKEN,
                                                      p_token1_value  => l_token_8,
						      p_token2		   => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => l_token_1);

	      x_valid := FALSE;
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;


    END IF;

    /* check the aes_id and ptl_id specified is valid */
    OPEN okl_pdt_aes_ptl_csr (p_pdtv_rec.aes_id,
                              p_pdtv_rec.ptl_id,
	 					  	  p_pdtv_rec.from_date,
							  l_to_date);
    FETCH okl_pdt_aes_ptl_csr INTO l_check;
    l_row_not_found := okl_pdt_aes_ptl_csr%NOTFOUND;
    CLOSE okl_pdt_aes_ptl_csr;

    IF l_row_not_found = FALSE THEN

	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => l_token_4,
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => l_token_1);
	   x_valid := FALSE;
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;



  EXCEPTION
   WHEN G_EXCEPTION_HALT_PROCESSING THEN


    -- no processing necessary; validation can continue

    -- with the next column
    NULL;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		Okl_Api.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name	    =>	G_UNEXPECTED_ERROR,
							p_token1	    =>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	    =>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_valid := FALSE;
	   x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF (okl_contracts_csr%ISOPEN) THEN
	   	  CLOSE okl_contracts_csr;
       END IF;

       IF (okl_pdt_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pdt_constraints_csr;

       END IF;

       IF (okl_pdt_aes_ptl_csr%ISOPEN) THEN
	   	  CLOSE okl_pdt_aes_ptl_csr;
       END IF;

       IF (c1%ISOPEN) THEN
	   	  CLOSE c1;
       END IF;

       IF (okl_pdtv_chk%ISOPEN) THEN
	   	  CLOSE okl_pdtv_chk;
       END IF;

  END Check_Constraints;

   ---------------------------------------------------------------------------
  -- PROCEDURE Getpdt_parameters
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Getpdt_parameters
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Getpdt_parameters(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
	x_no_data_found                OUT NOCOPY BOOLEAN,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN  pdtv_rec_type,
	p_product_date                 IN  DATE DEFAULT SYSDATE,
	p_pdt_parameter_rec            OUT NOCOPY pdt_parameters_rec_type
	)
	IS
   CURSOR okl_pdt_parameters_cur(cp_pdt_id IN okl_products_v.id%TYPE)
   IS
   SELECT
      Name,
      Product_subclass,
      Deal_Type,
      Tax_Owner,
      Revenue_Recognition_Method,
      Interest_Calculation_Basis,
      reporting_pdt_id,
	  reporting_product
   FROM okl_product_parameters_v
   WHERE id = cp_pdt_id;

   l_no_data_found        BOOLEAN;
   l_pdt_parameters_rec   pdt_parameters_rec_type;

BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_pdt_parameters_cur (p_pdtv_rec.id);
    FETCH okl_pdt_parameters_cur INTO
				    l_pdt_parameters_rec.name,
  				    l_pdt_parameters_rec.product_subclass,
					l_pdt_parameters_rec.deal_type,
					l_pdt_parameters_rec.tax_owner,
					l_pdt_parameters_rec.Revenue_Recognition_Method,
					l_pdt_parameters_rec.Interest_Calculation_Basis,
					l_pdt_parameters_rec.reporting_pdt_id,
					l_pdt_parameters_rec.reporting_product;
    x_no_data_found := okl_pdt_parameters_cur%NOTFOUND;
    CLOSE okl_pdt_parameters_cur;

	IF x_no_data_found = TRUE THEN
	        Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,

						        p_msg_name	   => G_PRODUCT_SETUP_INCOMPLETE);
         x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    p_pdt_parameter_rec := l_pdt_parameters_rec;

EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_pdt_parameters_cur%ISOPEN) THEN
	   	  CLOSE okl_pdt_parameters_cur;
      END IF;

END Getpdt_parameters;


  ---------------------------------------------------------------------------
  -- FUNCTION exist_subscription
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : exist_subscription
  -- Description     : Return 'Y' if there are some active subscription for
  --                   the given event Otherwise it returns 'N'
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
 IS
  CURSOR exist_subscription IS
   SELECT 'Y'
     FROM wf_event_subscriptions a,
          wf_events b
    WHERE a.event_filter_guid = b.guid
      AND a.status = 'ENABLED'
      AND b.name   = p_event_name
      AND ROWNUM   = 1;
  l_yn  VARCHAR2(1);
 BEGIN
  OPEN exist_subscription;
   FETCH exist_subscription INTO l_yn;
   IF exist_subscription%NOTFOUND THEN
      l_yn := 'N';
   END IF;
  CLOSE exist_subscription;
  RETURN l_yn;
 END;


 ---------------------------------------------------------------------------
 -- product_approval_process
 ---------------------------------------------------------------------------
 -- Start of comments
 --

 -- Procedure Name  : product_approval_process
 -- Description     : procedure to submit product for approval
 --                   the given event Otherwise it returns 'N'
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ---------------------------------------------------------------------------

 PROCEDURE product_approval_process
 ( p_api_version                  IN  NUMBER,
   p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_pdtv_rec                     IN  pdtv_rec_type)
 IS
 l_parameter_list wf_parameter_list_t;
 l_key  VARCHAR2(240);
 l_found   VARCHAR2(1);
 l_event_name VARCHAR2(240) := 'oracle.apps.okl.llap.productapprovalprocess';

 -- Selects the nextval from sequence, used later for defining event key
 CURSOR okl_key_csr IS
 SELECT okl_wf_item_s.NEXTVAL
 FROM   dual;

 -- Get product Details
 CURSOR c_fetch_pdt_dtls(p_pdt_id OKl_products_V.ID%TYPE)
 IS
 SELECT pdt.product_status_code status

 FROM okl_products_v pdt
 WHERE pdt.id = p_pdt_id;

 -- modification by dcshanmu for bug 5999276 ends
 -- Get OU id for the ATS
 CURSOR c_get_ou_for_aes_id_csr(p_aes_id OKl_products_V.AES_ID%TYPE)
 IS
 SELECT		ORG_ID
 FROM		OKL_AE_TMPT_SETS_ALL aes
 WHERE		aes.ID = p_aes_id;

 l_org_id NUMBER;
 -- modification by dcshanmu for bug 5999276 ends


 l_seq NUMBER ;
 l_status                   OKL_PRODUCTS_V.product_status_code%TYPE;
 l_pdt_id                   OKL_PRODUCTS_V.ID%TYPE;
 l_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version              NUMBER	:= 1.0;
 l_init_msg_list            VARCHAR2(10) := OKL_API.G_FALSE;
 l_api_name        	    CONSTANT VARCHAR2(30) := 'product_approval_process';
 l_no_data_found   	  	BOOLEAN := TRUE;
 l_pdtv_rec pdtv_rec_type;
 x_pdtv_rec pdtv_rec_type;
 l_upd_pdtv_rec pdtv_rec_type;

BEGIN

 -- SAVEPOINT product_approval_process;
 -- initialize return status
 x_return_status := Okl_Api.G_RET_STS_SUCCESS;

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

  l_UPD_pdtv_rec.id := p_pdtv_rec.id;

  -- Get the product name and status
  OPEN  c_fetch_pdt_dtls(p_pdtv_rec.id);
  FETCH c_fetch_pdt_dtls INTO l_status;

  IF c_fetch_pdt_dtls%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
		            p_msg_name     => G_NO_MATCHING_RECORD,
		            p_token1       => G_COL_NAME_TOKEN,
		            p_token1_value => 'OKC_PRODUCTS_V.ID');
 	RAISE G_EXCEPTION_HALT_PROCESSING;
     END IF;
     CLOSE c_fetch_pdt_dtls;

     IF l_status = 'PENDING APPROVAL' THEN
     --This product has been already submitted for approval.
        OKL_API.set_message(p_app_name    => G_APP_NAME,
                           p_msg_name     => G_PDT_IN_PEND_APPROVAL);
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF l_status = 'APPROVED' THEN
     --This product has been approved.
        OKL_API.set_message(p_app_name    => G_APP_NAME,
                           p_msg_name     => G_PDT_APPROVED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF l_status = 'PASSED' THEN
     -- normal processing
           NULL;
     ELSE
         OKL_API.set_message(p_app_name    => G_APP_NAME,
                           p_msg_name     => G_PDT_NOT_VALIDATED);
 	--RAISE G_EXCEPTION_HALT_PROCESSING;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

 -- Test if there are any active subscritions
 -- if it is the case then execute the subscriptions
 l_found := exist_subscription(l_event_name);
 IF l_found = 'Y' THEN
   --Get the item key
   OPEN okl_key_csr;
   FETCH okl_key_csr INTO l_seq;
   CLOSE okl_key_csr;

   l_key := l_event_name ||l_seq ;

  -- modification by dcshanmu for bug 5999276 starts
    -- Get the operating unit id for the ATS
  OPEN  c_get_ou_for_aes_id_csr(p_pdtv_rec.aes_id);
  FETCH c_get_ou_for_aes_id_csr INTO l_org_id;

  CLOSE c_get_ou_for_aes_id_csr;

  IF l_org_id IS NULL THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
		            p_msg_name     => G_NO_MATCHING_RECORD,
		            p_token1       => G_COL_NAME_TOKEN,
		            p_token1_value => 'OKC_PRODUCTS_V.AES_ID');
 	RAISE G_EXCEPTION_HALT_PROCESSING;
     END IF;
-- modification by dcshanmu for bug 5999276 ends

   --Set Parameters
   wf_event.AddParameterToList('TRANSACTION_ID',TO_CHAR(p_pdtv_rec.ID),l_parameter_list);
   --added by akrangan
   -- modified by dcshanmu for bug 5999276 starts
   wf_event.AddParameterToList('ORG_ID',l_org_id ,l_parameter_list);
   -- We need to status to Approved Pending since We are sending for approval

   update_product_status(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_pdt_status    => G_PDT_STS_PENDING_APPROVAL,
                           p_pdt_id        => p_pdtv_rec.ID);


      IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN

        RAISE G_EXCEPTION_HALT_PROCESSING;
      ELSE
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
        END IF;
      END IF;

   -- Raise Event
   -- It is overloaded function so use according to requirement

   wf_event.RAISE(  p_event_name  => l_event_name
                   ,p_event_key   => l_key
                   ,p_parameters  => l_parameter_list);

   l_parameter_list.DELETE;
 ELSE
 FND_MESSAGE.SET_NAME('OKL', 'OKL_NO_EVENT');
 FND_MSG_PUB.ADD;
 x_return_status :=   OKL_API.G_RET_STS_ERROR ;
 END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);

EXCEPTION
   WHEN G_EXCEPTION_HALT_PROCESSING THEN

    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
 WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

      IF c_fetch_pdt_dtls%ISOPEN THEN
        CLOSE c_fetch_pdt_dtls;
      END IF;

      IF okl_key_csr%ISOPEN THEN
        CLOSE okl_key_csr;
      END IF;
 WHEN OTHERS THEN
      --ROLLBACK TO product_approval_process;
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;



      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;


      IF c_fetch_pdt_dtls%ISOPEN THEN
        CLOSE c_fetch_pdt_dtls;
      END IF;

 END product_approval_process;

 -----------------------------------------------------------------------------
 -- PROCEDURE get_agent
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : get_agent
 -- Description     :
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ---------------------------------------------------------------------------

 PROCEDURE get_agent(p_user_id     IN  NUMBER,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_name        OUT NOCOPY VARCHAR2,
                        x_description OUT NOCOPY VARCHAR2) IS

    CURSOR wf_users_csr(c_user_id NUMBER)
    IS
    SELECT NAME, DISPLAY_NAME
    FROM   WF_USERS
    WHERE  orig_system_id = c_user_id
    AND    ORIG_SYSTEM = G_WF_USER_ORIG_SYSTEM_HR;

    CURSOR fnd_users_csr(c_user_id NUMBER)
    IS
    SELECT USER_NAME, DESCRIPTION

    FROM   FND_USER
    WHERE  user_id = c_user_id;
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    OPEN  wf_users_csr(p_user_id);
    FETCH wf_users_csr INTO x_name, x_description;
    CLOSE wf_users_csr;
    IF x_name IS NULL THEN
      OPEN  fnd_users_csr(p_user_id);
      FETCH fnd_users_csr INTO x_name, x_description;
      CLOSE fnd_users_csr;
      IF x_name IS NULL THEN
        x_name        := G_DEFAULT_USER_DESC;
        x_description := G_DEFAULT_USER_DESC;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status      := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_agent;



 -----------------------------------------------------------------------------
 -- PROCEDURE set_additionalparameters
 -----------------------------------------------------------------------------
 -- Start of comments

 --
 -- Procedure Name  : procedure to addtional parameters for approval process
 -- Description     :
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ------------------------------------------------------------------------------
 PROCEDURE set_additionalparameters(
			    itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
			    actid		IN NUMBER,
			    funcmode	IN VARCHAR2,
			    resultout OUT NOCOPY VARCHAR2) AS

    -- Get the valid application id from FND
    CURSOR c_get_app_id_csr
    IS
    SELECT APPLICATION_ID
    FROM   FND_APPLICATION
    WHERE  APPLICATION_SHORT_NAME = G_APP_NAME;

    -- Get the Transaction Type Id from OAM
    -- modification of where condn by dcshanmu for bug 5999276 starts
    CURSOR c_get_trx_type_csr(c_trx_type  VARCHAR2)
    IS
    SELECT transaction_type_id,
           fnd_application_id
    FROM   ame_transaction_types_v
    WHERE  DESCRIPTION='OKL LP Product Approval Process';
    -- modification of where condn by dcshanmu for bug 5999276 starts

    CURSOR l_wf_item_key_csr IS
    SELECT okl_wf_item_s.NEXTVAL item_key
    FROM  dual;

    l_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version              NUMBER	:= 1.0;
    l_api_name        CONSTANT VARCHAR2(30) := 'set_additionalparameters';

    l_msg_count	               NUMBER;
    l_init_msg_list            VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data		       VARCHAR2(2000);

    l_parameter_list           wf_parameter_list_t;
    l_key                      VARCHAR2(240);
    l_event_name               VARCHAR2(240);
    l_pdt_id                   OKL_PRODUCTS_V.ID%TYPE;

    l_application_id           FND_APPLICATION.APPLICATION_ID%TYPE;
    l_trans_appl_id            AME_CALLING_APPS.APPLICATION_ID%TYPE;
    l_trans_type_id            AME_CALLING_APPS.TRANSACTION_TYPE_ID%TYPE;

    l_requester                VARCHAR2(200);
    l_name                     VARCHAR2(200);
    l_requester_id             VARCHAR2(200);
    l_message       VARCHAR2(30000);
    X_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Create Internal Transaction

    l_pdt_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => G_WF_ITM_PRODUCT_ID);


    -- Get the user id, Item key
    l_requester_id := FND_GLOBAL.USER_ID;

    get_agent(p_user_id       => l_requester_id,
              x_return_status => x_return_status,

              x_name          => l_requester,
	      x_description   => l_name);

     -- Get the Application ID
    OPEN  c_get_app_id_csr;
    FETCH c_get_app_id_csr INTO l_application_id;
    IF c_get_app_id_csr%NOTFOUND THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE c_get_app_id_csr;

    -- Get the Transaction Type ID
    OPEN  c_get_trx_type_csr(G_TRANS_APP_NAME);
    FETCH c_get_trx_type_csr INTO l_trans_type_id,
                                  l_trans_appl_id;
    IF c_get_trx_type_csr%NOTFOUND THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE c_get_trx_type_csr;

  	    IF l_application_id = l_trans_appl_id THEN

		    l_message  := '<p>The Product will be completed following your approval.</p>';

                    wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                    itemkey => itemkey,
				    aname   => G_WF_ITM_MESSAGE_DESCRIPTION,
         	                    avalue  => l_message);



 		    wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                    itemkey => itemkey,
				    aname   => G_WF_ITM_PRODUCT_ID,
         	                    avalue  => l_pdt_id);


 		    wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                    itemkey => itemkey,
				    aname   => G_WF_ITM_APPLICATION_ID,
         	                    avalue  => l_application_id);

 		    wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                    itemkey => itemkey,
				    aname   => G_WF_ITM_TRANSACTION_TYPE_ID,
         	                    avalue  => 'OKLLPPAP');

 		    wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                    itemkey => itemkey,
				    aname   => G_WF_ITM_REQUESTER,
         	                    avalue  => l_requester);


 		    wf_engine.SetItemAttrText ( itemtype=> itemtype,
		                    itemkey => itemkey,
				    aname   => G_WF_ITM_REQUESTER_ID,
         	                    avalue  => l_requester_id);


	    END IF; -- l_application_id

  EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_get_app_id_csr%ISOPEN THEN
        CLOSE c_get_app_id_csr;
      END IF;
      IF c_get_trx_type_csr%ISOPEN THEN

        CLOSE c_get_trx_type_csr;
      END IF;

      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_get_app_id_csr%ISOPEN THEN
        CLOSE c_get_app_id_csr;
      END IF;
      IF c_get_trx_type_csr%ISOPEN THEN
        CLOSE c_get_trx_type_csr;
      END IF;

      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
      RAISE;


 WHEN OTHERS THEN
      IF c_get_app_id_csr%ISOPEN THEN
        CLOSE c_get_app_id_csr;

      END IF;
      IF c_get_trx_type_csr%ISOPEN THEN
        CLOSE c_get_trx_type_csr;
      END IF;

      wf_core.context('OKL_SETUPPRODUCTS_PVT',
                      'set_additionalparameters',
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);

   resultout := 'ERROR';
   RAISE;
 END set_additionalparameters;

 ----------------------------------------------------------------------
 --- procedure to update product status
 ----------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : update_product_status
 -- Description     : procedure to update product status code.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
------------------------------------------------------------------------
 PROCEDURE update_product_status(

            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_pdt_status      IN  VARCHAR2,
            p_pdt_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_PRODUCT_STATUS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_pdtv_rec pdtv_rec_type;
    l_upd_pdtv_rec pdtv_rec_type;
    x_pdtv_rec pdtv_rec_type;
    l_no_data_found   	  	BOOLEAN := TRUE;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_UPD_pdtv_rec.id := p_pdt_id;
    l_upd_pdtv_rec.product_status_code := p_pdt_status;

    UPDATE OKL_PRODUCTS SET PRODUCT_STATUS_CODE = l_upd_pdtv_rec.product_status_code
    WHERE ID = l_UPD_pdtv_rec.id;

/*
    Okl_Products_Pub.update_products(p_api_version   => p_api_version,
                            	     p_init_msg_list => p_init_msg_list,
                              	     x_return_status => l_return_status,
                              	     x_msg_count     => x_msg_count,
                              	     x_msg_data      => x_msg_data,
                              	     p_pdtv_rec      => l_upd_pdtv_rec,
                              	     x_pdtv_rec      => x_pdtv_rec);

*/

    IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

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


  END update_product_status;

 ---------------------------------------------------------------------------------
 -- PROCEDURE get_approval_status
 ---------------------------------------------------------------------------------
 -- Start of comments
 --

 -- Procedure Name  : get_approval_status
 -- Description     : procedure to get approval status from workflow.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------

PROCEDURE get_approval_status(itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              resultout OUT  NOCOPY VARCHAR2)
  IS

    l_return_status	VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    l_api_version       NUMBER	:= 1.0;
    l_msg_count		NUMBER;
    l_init_msg_list     VARCHAR2(10) := OKL_API.G_FALSE;
    l_msg_data		VARCHAR2(2000);
    l_api_name VARCHAR2(30) := 'get_approval_status';

    l_pdt_id           OKC_K_HEADERS_V.ID%TYPE;
    l_approved_yn        VARCHAR2(30);

  BEGIN
    -- We getting the contract_Id from WF
    l_pdt_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'TRANSACTION_ID');


    --Run Mode
    IF funcmode = 'RUN' THEN
      l_approved_yn :=  wf_engine.GetItemAttrText (itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname     => G_WF_ITM_APPROVED_YN);

      IF l_approved_yn = G_WF_ITM_APPROVED_YN_YES THEN

      update_product_status(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
                           p_pdt_status    => G_PDT_STS_APPROVED,
                           p_pdt_id        => l_pdt_id);


         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

      ELSE

       update_product_status(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
                           p_pdt_status    => G_PDT_STS_INVALID,
                           p_pdt_id        => l_pdt_id);


         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;


         END IF;


      END IF;

      resultout := 'COMPLETE:';
      RETURN;
    END IF;

    --Transfer Mode
    IF funcmode = 'TRANSFER' THEN
      resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    -- CANCEL mode
    IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;
    -- TIMEOUT mode
    IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      RETURN;
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME,
                      l_api_name,
                       itemtype,
                       itemkey,
                       TO_CHAR(actid),
                       funcmode);
	  RAISE;
  END get_approval_status;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_book_class
  ---------------------------------------------------------------------------
  -- Start of comments
  --

  -- Procedure Name  : Validate_book_class
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_book_class(p_pdtv_rec      IN OUT  NOCOPY pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1               VARCHAR2(1999);


 CURSOR c2(p_pdt_id NUMBER) IS
 SELECT '1'
 FROM okl_product_parameters_v a
 where a.id = p_pdt_id;


 CURSOR c1(p_pdt_id NUMBER) IS
 SELECT DISTINCT a.deal_type
 FROM okl_product_parameters_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
 WHERE a.aes_id = b.id
 AND b.gts_id = c.id
 AND a.deal_type = c.deal_type
 AND a.id = p_pdt_id;

/*
   cursor chk_deal_type(p_pdt_id okl_pdt_pqy_vals_v.pdt_id%TYPE,
			p_aes_id okl_products_v.aes_id%TYPE)
   IS
   SELECT DISTINCT C.deal_type
   FROM okl_products_v a,
      okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE a.aes_id = b.id
   AND b.gts_id = c.id

   AND a.id = p_pdt_id
   and a.aes_id = p_aes_id
   intersect
   select DEAL_TYPE from okl_product_parameters_v ppar
   where ppar.id = p_pdt_id;


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
*/


 l_row_found      VARCHAR2(20);
 l_found      VARCHAR2(10);


  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PRODUCT_CRUPD','OKL_NAME');

     OPEN c2(p_pdtv_rec.id);
     FETCH c2 INTO l_found;

     if c2%found then

     OPEN c1(p_pdtv_rec.id);
      FETCH c1 INTO l_row_found;
        IF (c1%NOTFOUND) THEN
	   Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	   		       p_msg_name	   => G_BOOK_CLASS_MISMATCH);
        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;

        END IF;
      CLOSE c1;

     end if;
    close c2;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;


    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,

                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_book_class;


  ---------------------------------------------------------------------------
  -- PROCEDURE check_accrual_streams
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_accrual_streams
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE check_accrual_streams(p_pdtv_rec      IN OUT  NOCOPY pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1               VARCHAR2(1999);
/*
 CURSOR c1(p_pdt_id NUMBER) IS
 SELECT name
 FROM OKL_PROD_STRM_TYPES_UV a
 WHERE pdt_id = p_pdt_id
 INTERSECT
 SELECT STY_NAME FROM OKL_ST_GEN_TMPT_CNTRCT_UV
 WHERE PDT_ID = p_pdt_id;

*/
 l_row_found      VARCHAR2(20);

  BEGIN
null;
/*
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PDT_TMPL_CREATE_UPDATE','OKL_PRODUCT_TEMPLATE');

     OPEN c1(p_pdtv_rec.id);
      FETCH c1 INTO l_row_found;
        IF (c1%NOTFOUND) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pdt_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pdt_Pvt.g_required_value
                          ,p_token1         => Okl_Pdt_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);

        x_return_status    := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_PROCESSING;

        END IF;

      CLOSE c1;
*/
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,

                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_accrual_streams;

 ---------------------------------------------------------------------------------
 -- PROCEDURE validate_product
 ---------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : validate_product
 -- Description     : procedure to validate product.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0

 -- End of comments
 ----------------------------------------------------------------------------------
  PROCEDURE validate_product(  p_api_version     IN  NUMBER,
			       p_init_msg_list   IN  VARCHAR2,
			       x_return_status   OUT NOCOPY VARCHAR2,
		               x_msg_count       OUT NOCOPY NUMBER,
			       x_msg_data        OUT NOCOPY VARCHAR2,
			       p_pdtv_rec        IN  pdtv_rec_type,
			       x_pdtv_rec        OUT NOCOPY pdtv_rec_type
			       ) is
  l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_PRODUCT';
  l_api_version       CONSTANT NUMBER       := 1;
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_pdtv_rec pdtv_rec_type := p_pdtv_rec;
  l_upd_pdtv_rec pdtv_rec_type := p_pdtv_rec;
  l_db_pdtv_rec pdtv_rec_type;
  l_no_data_found   	  	BOOLEAN := TRUE;
  l_init_msg_list            VARCHAR2(10) := OKL_API.G_FALSE;
  l_msg_count	               NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_check_dt		   	VARCHAR2(1) := '?';
--rkuttiya added for Multi GAAP Project
  l_deal_type                VARCHAR2(150);
  l_deal_type1               VARCHAR2(40);
  l_chk_bc     VARCHAR2(100);
  l_tax_upfront_sty_id OKL_SYSTEM_PARAMS.tax_upfront_sty_id%TYPE;
  l_gtt_id OKL_ST_GEN_TEMPLATES.ID%TYPE;
  l_primary_sty_id OKL_ST_GEN_TMPT_LNS.primary_sty_id%TYPE;
  l_stream_name okl_strm_type_v.styb_purpose_meaning%TYPE;

   -- Cursor to fetch the Product Quality Values
   CURSOR get_pp_csr(p_pdt_id NUMBER)
   IS
     SELECT id pdt_id,
            product_subclass,
            deal_type,
            deal_type_meaning,
            tax_owner,
            tax_owner_meaning,
            revenue_recognition_method,
            revenue_recognition_meaning,
            interest_calculation_basis,
            interest_calculation_meaning
      FROM  okl_product_parameters_v pp
     WHERE  pp.id = p_pdt_id;

   CURSOR get_sgt_values_csr( p_pdt_id NUMBER)
   IS
     SELECT  gts.name sgt_name,
             gts.pricing_engine,
             gts.deal_type,
             gts.tax_owner,
             gts.interest_calc_meth_code,
             gts.revenue_recog_meth_code
     FROM OKL_PRODUCTS_V PDT,
          OKL_AE_TMPT_SETS_V AES,
          OKL_ST_GEN_TMPT_SETS GTS
     WHERE PDT.AES_ID = AES.ID
      AND  AES.GTS_ID = GTS.ID
      AND  PDT.ID = p_pdt_id;

   CURSOR chk_ptl_aes_bc(p_aes_id      IN Okl_Products_V.AES_ID%TYPE,
                         p_ptl_id      IN Okl_Products_V.PTL_ID%TYPE,
             	         p_pdt_id      IN Okl_Products_V.id%TYPE)
   IS
   SELECT DISTINCT DECODE(C.product_type,'FINANCIAL','LEASE','INVESTOR')
   FROM okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE b.gts_id = c.id
   AND b.id = p_aes_id
   INTERSECT
   SELECT DISTINCT PQY.NAME
   FROM okl_PDT_PQYS_V  PDQ,
   OKL_PQY_VALUES_V QVE,OKL_PDT_QUALITYS_V PQY
   WHERE PQY.ID = QVE.PQY_ID
   AND PQY.ID= PDQ.PQY_ID
   AND PDQ.PTL_ID = p_PTL_ID
   AND pqy.name IN('LEASE','INVESTOR');

   CURSOR c_tax_sty_id_cur IS
     SELECT tax_upfront_sty_id
     FROM  OKL_SYSTEM_PARAMS;

   CURSOR c_st_gen_templates_cur (p_pdt_id IN okl_products_v.id%TYPE)
   IS
     SELECT gttv.id gtt_id, gtsv.name name, gttv.version version
     FROM
       OKL_ST_GEN_TEMPLATES GTTV,
       OKL_ST_GEN_TMPT_SETS GTSV,

       okl_ae_tmpt_sets_v AES,
       okl_products_v PDT
     WHERE
       GTTV.gts_id      = GTSV.id     AND
       GTTV.tmpt_status = 'ACTIVE'    AND
       GTSV.id          = AES.gts_id  AND
       AES.id           = PDT.aes_id  AND
       PDT.id           = p_pdt_id    AND
       GTSV.product_type ='FINANCIAL';

   CURSOR c_st_gen_template_lns_cur(p_gtt_id             IN OKL_ST_GEN_TEMPLATES.id%TYPE,
                                    p_tax_upfront_sty_id IN OKL_SYSTEM_PARAMS.tax_upfront_sty_id%TYPE)
   IS
     SELECT GTLV.PRIMARY_STY_ID
     FROM
      OKL_ST_GEN_TEMPLATES GTTV,
      OKL_ST_GEN_TMPT_LNS  GTLV
     WHERE
       GTTV.ID             = p_gtt_id          AND
       GTTV.ID             = GTLV.gtt_id       AND
       GTLV.PRIMARY_STY_ID = p_tax_upfront_sty_id AND
       GTLV.PRIMARY_YN = 'Y' ;

    CURSOR c_stream_name(p_id IN okl_strm_type_v.ID%TYPE)
    IS
      SELECT styb_purpose_meaning
      FROM okl_strm_type_v
      WHERE ID = p_id;

   -- Bug 6803437: Start
   -- Cursor to fetch the Reporting Product Status
   CURSOR get_rep_pdt_sts_code_csr( p_pdt_id  NUMBER )
   IS
     SELECT  rp.product_status_code    rp_pdt_sts_code
            ,rp.name                   rp_pdt_name
            ,rp.id                     rp_pdt_id -- Bug 7134895
       FROM  okl_products np,
             okl_products rp
      WHERE  rp.id = np.reporting_pdt_id
        AND  np.id = p_pdt_id;
   -- Bug 6803437: End

   --rkuttiya added for 12.1.1 Multi GAAP Project
   --to check whether the reporting product is attached to  any other contract
    CURSOR okl_rpt_pdtv_chk(p_pdt_id NUMBER) IS
    SELECT '1'
    FROM okl_k_headers_v khdr
    WHERE khdr.pdt_id = p_pdt_id;
  --

    /* Bug 7134895 */
    l_rpt_pdt_id      OKL_PRODUCTS.ID%TYPE := null;
    l_rev_rec_method  okl_product_parameters_v.revenue_recognition_method%TYPE := null;
    l_int_calc_basis  okl_product_parameters_v.interest_calculation_basis%TYPE := null;
    l_rpt_rev_rec_method  okl_product_parameters_v.revenue_recognition_method%TYPE := null;
    l_rpt_int_calc_basis  okl_product_parameters_v.interest_calculation_basis%TYPE := null;
    l_qv_found       BOOLEAN;
    l_inv_deal_type  OKL_ST_GEN_TMPT_SETS.deal_type%TYPE;
   -- Bug 6803437: Start
   l_rp_pdt_sts_code  VARCHAR2(30);
   l_rp_pdt_name      OKL_PRODUCTS_V.NAME%TYPE;
   l_raise_exception BOOLEAN := FALSE;
   -- Bug 6803437: End
   --rkuttiya added for 12.1.1 Multi GAAP Project
   l_rpt_deal_type       VARCHAR2(150);
   l_deal_type_meaning   VARCHAR2(4000);
   l_pricing_engine      VARCHAR2(30);
   l_rpt_pricing_engine  VARCHAR2(30);
   l_check               VARCHAR2(1);
BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

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


   -- Validation process is kicked only when the product is in invalid or new status.
   IF l_pdtv_rec.product_status_code IN  ('INVALID','NEW') THEN

     /*=========================================
     -- user defined streams validations BEGIN
     ==========================================*/


     -- Bookclass and taxowner on the product template should match the bookclass
     -- and taxowner on the stream template.
     OPEN chk_ptl_aes_bc(l_pdtv_rec.aes_id,l_pdtv_rec.ptl_id,l_pdtv_rec.id);
     FETCH chk_ptl_aes_bc INTO l_chk_bc;
     CLOSE chk_ptl_aes_bc;

     IF (l_chk_bc IS NULL) THEN

                  Okl_Api.SET_MESSAGE(p_app_name   => G_APP_NAME,
				      p_msg_name   => G_PTL_AES_BC_MISMATCH);
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     /*mansrini Tax enhancement proj: If the product is of financial type, check upfront tax id matches*/

       OPEN c_tax_sty_id_cur;
       FETCH c_tax_sty_id_cur INTO l_tax_upfront_sty_id;
       CLOSE c_tax_sty_id_cur;

       IF l_tax_upfront_sty_id IS NOT NULL THEN

	 FOR r_st_gen_templates_rec IN c_st_gen_templates_cur(l_pdtv_rec.id) LOOP

	   OPEN c_st_gen_template_lns_cur(r_st_gen_templates_rec.gtt_id,l_tax_upfront_sty_id);
  	   FETCH c_st_gen_template_lns_cur INTO l_primary_sty_id;

           IF c_st_gen_template_lns_cur%NOTFOUND THEN
     	     CLOSE c_st_gen_template_lns_cur;

             OPEN  c_stream_name(l_tax_upfront_sty_id);
	     FETCH c_stream_name INTO l_stream_name;
	     CLOSE c_stream_name;

             OKL_API.SET_MESSAGE (p_app_name        => G_APP_NAME,
                                  p_msg_name        => G_TAX_STYID_MISMATCH,
                                  p_token1          => 'SGT_NAME',
                                  p_token1_value    => r_st_gen_templates_rec.name,
                                  p_token2          => 'SGT_VERSION',
                                  p_token2_value    => r_st_gen_templates_rec.version,
                                  p_token3          => 'STRM_NAME',
                                  p_token3_value    => l_stream_name);


             x_return_status := Okl_Api.G_RET_STS_ERROR;
             RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

	   IF c_st_gen_template_lns_cur%ISOPEN THEN
  	     CLOSE c_st_gen_template_lns_cur;
           END IF;

	 END LOOP;

       END IF;
    -- check to see if the product book class is defined
    l_qv_found    := FALSE;
    FOR pdt_rec IN get_pp_csr(l_pdtv_rec.id)
    LOOP
      l_qv_found := TRUE;
      l_rev_rec_method := pdt_rec.revenue_recognition_method;
      l_int_calc_basis := pdt_rec.interest_calculation_basis;
     --rkuttiya added for 12.1.1 MultiGAAP project
      l_deal_type      := pdt_rec.deal_type;
      l_deal_type_meaning := pdt_rec.deal_type_meaning;
    --
      FOR sgt_rec IN get_sgt_values_csr( l_pdtv_rec.id )
      LOOP
        l_pricing_engine := sgt_rec.pricing_engine;
        -- Check the Deal Type, Tax Owner, Interest Calculation Basis, Revenue Recognition Basis
        IF pdt_rec.product_subclass = 'INVESTOR'
        THEN
          -- For Investor products just need to check the INVESTOR quality value alone
          IF sgt_rec.deal_type = 'SALE'
          THEN
            -- In the SGT, though the meaning has been changed to Securitization, the lookup code
            -- is still remaining as SALE, but the Product ones has been changed to SECURITIZATION
            l_inv_deal_type  := 'SECURITIZATION';
          ELSE
            l_inv_deal_type  := sgt_rec.deal_type;
          END IF;
          IF pdt_rec.deal_type <> l_inv_deal_type
          THEN
            OKL_API.SET_MESSAGE(
              p_app_name	    => G_APP_NAME,
              p_msg_name	    => 'OKL_NEW_INVESTOR_MISMATCH',
              p_token1	      => 'PQVALUE',
              p_token1_value	=> OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_SECURITIZATION_TYPE', pdt_rec.deal_type ),
              p_token2	      => 'SGTVALUE',
              p_token2_value	=> OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_STREAM_INV_BOOK_CLASS', sgt_rec.deal_type) );
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSIF pdt_rec.product_subclass = 'LEASE'
        THEN
          -- Deal Type, Tax Owner, Interest Calculation Basis, Revenue Recognition Basis
          --  should match with that of the SGT Quality Values
          IF pdt_rec.deal_type <> sgt_rec.deal_type OR
             pdt_rec.tax_owner <> sgt_rec.tax_owner OR
             pdt_rec.interest_calculation_basis <> sgt_rec.interest_calc_meth_code OR
             pdt_rec.revenue_recognition_method <> sgt_rec.revenue_recog_meth_code
          THEN
            Okl_Api.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_NEW_PDT_QUAL_MISMATCH',
              p_token1        => 'SGTDEALTYPE',
              p_token1_value	=> OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_STREAM_ALL_BOOK_CLASS',sgt_rec.deal_type ),
              p_token2        => 'SGTTAXOWNER',
              p_token2_value	=> OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_TAX_OWNER',sgt_rec.tax_owner),
              p_token3        => 'SGTINTCALC',
              p_token3_value	=> OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_INTEREST_CALCULATION_BASIS',sgt_rec.interest_calc_meth_code ),
              p_token4        => 'SGTRRB',
              p_token4_value	=> OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_REVENUE_RECOGNITION_METHOD',sgt_rec.revenue_recog_meth_code)
            );
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF; -- IF pdt_rec.product_subclass
/*  rkuttiya commented out following code for bug 7385171
 *  remove validation for variable rate
	 --Bug 4728496 dpsingh start
	  IF ( (pdt_rec.interest_calculation_basis IN ('FLOAT_FACTORS','CATCHUP/CLEANUP') OR pdt_rec.revenue_recognition_method IN ('ESTIMATED_AND_BILLED','ACTUAL')) AND l_pdtv_rec.reporting_pdt_id IS NOT NULL)
	  THEN
             Okl_Api.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_REP_PDT_ATT_VAR_PDT'
              );
	    RAISE OKL_API.G_EXCEPTION_ERROR;
	  END IF;
	   --Bug 4728496 dpsingh end*/

      END LOOP; -- FOR sgt_rec
    END LOOP; -- FOR pdt_rec
    IF l_qv_found = FALSE
    THEN
      -- Show the error message saying that user should enter all the
      -- Quality values.
      OKL_API.SET_MESSAGE(
        p_app_name      => G_APP_NAME,
  		  p_msg_name	    => 'OKL_PDT_QVALS_UNDEFINED');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
     /*=======================================
      -- user defined streams validations END
     ========================================*/
     -- Bug 6803437: Start
     -- New Validation:
     --    The Reporting Product (if any) associated to the Product being validated
     --      should be in Approved Status.
     l_rpt_pdt_id := null; -- Bug 7134895
     l_rp_pdt_sts_code := 'APPROVED';
     FOR t_rec IN get_rep_pdt_sts_code_csr( p_pdt_id  => l_pdtv_rec.id  )
     LOOP
       l_rp_pdt_sts_code := t_rec.rp_pdt_sts_code;
       l_rp_pdt_name     := t_rec.rp_pdt_name;
       l_rpt_pdt_id       := t_rec.rp_pdt_id; -- Bug 7134895
     END LOOP;
     IF l_rp_pdt_sts_code <> 'APPROVED'
     THEN
       -- Raise an Exception and return x_valid as FALSE
       OKL_API.set_message(
          p_app_name      => G_APP_NAME
          ,p_msg_name     => 'OKL_REP_PDT_NOT_APPROVED'
          ,p_token1       => 'REPPRODUCT'
          ,p_token1_value => l_rp_pdt_name
       );
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF; -- IF l_rp_pdt_sts_code

     -- Bug 7134895
     l_raise_exception := FALSE;
     IF (l_rpt_pdt_id IS NOT NULL AND l_rpt_pdt_id <> OKL_API.G_MISS_NUM) THEN
       -- Get rev_rec_method and int_calc_basis for reporting product and
       -- compare against the base product if they are same
      FOR rpt_pdt_rec IN get_pp_csr(l_rpt_pdt_id)
      LOOP
        l_rpt_rev_rec_method := rpt_pdt_rec.revenue_recognition_method;
        l_rpt_int_calc_basis := rpt_pdt_rec.interest_calculation_basis;
        --rkuttiya added for 12.1.1 MultiGAAP Project
        l_rpt_deal_type      := rpt_pdt_rec.deal_type;
        FOR sgt_rpt_rec IN get_sgt_values_csr(l_rpt_pdt_id)
        LOOP
          l_rpt_pricing_engine := sgt_rpt_rec.pricing_engine;
        END LOOP;
      END LOOP;
  --rkuttiya added for 12.1.1 Multi Gaap Project
      /* -- Bug 7450075
      OPEN okl_rpt_pdtv_chk(l_rpt_pdt_id);
      FETCH okl_rpt_pdtv_chk INTO l_check;
      CLOSE okl_rpt_pdtv_chk;

      IF l_check IS NOT NULL THEN
        Okl_Api.SET_MESSAGE(
                p_app_name      => G_APP_NAME,
                p_msg_name      => 'OKL_PDT_RPT_KHR_ASSOC'
               );
          x_return_status := Okl_Api.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; */

      IF (l_rpt_rev_rec_method <> l_rev_rec_method) THEN
        Okl_Api.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_PDT_RPT_RRM_MISMATCH'
            );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        l_raise_exception := TRUE;
      END IF;

      IF (l_rpt_int_calc_basis <> l_int_calc_basis) THEN
        Okl_Api.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_PDT_RPT_ICB_MISMATCH'
            );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     --rkuttiya added for 12.1.1 Multi GAAP project
      IF (l_deal_type = 'LOAN') AND (l_rpt_deal_type <> 'LOAN') THEN
         Okl_Api.SET_MESSAGE(
               p_app_name      => G_APP_NAME,
               p_msg_name      => 'OKL_PDT_RPT_SELECT_LOAN'
             );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

      IF (l_deal_type = 'LOAN-REVOLVING') AND (l_rpt_deal_type <>
'LOAN-REVOLVING') THEN
         Okl_Api.SET_MESSAGE(
                   p_app_name      => G_APP_NAME,
                    p_msg_name      => 'OKL_PDT_RPT_SELECT_REVLOAN'
                   );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (l_deal_type IN ('LEASEDF','LEASEOP','LEASEST')) AND
        (l_rpt_deal_type NOT IN ('LEASEDF','LEASEOP','LEASEST')) THEN
         Okl_Api.SET_MESSAGE(
                    p_app_name      => G_APP_NAME,
                    p_msg_name      => 'OKL_PDT_RPT_SELECT_LEASE'
                    );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- racheruv .. R12.1.2 changes start
     IF (l_deal_type IN ('SYNDICATION','SECURITIZATION')) AND
        (l_rpt_deal_type NOT IN ('SYNDICATION','SECURITIZATION')) THEN
         Okl_Api.SET_MESSAGE(
                    p_app_name      => G_APP_NAME,
                    p_msg_name      => 'OKL_PDT_RPT_SELECT_LEASE'
                    );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
	 -- racheruv .. R12.1.2 changes end.

     IF l_pricing_engine <> l_rpt_pricing_engine THEN
        Okl_Api.SET_MESSAGE(
                     p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_PDT_RPT_SELECT_SGT',
                     p_token1        => 'PRICINGENG',
                     p_token1_value  => l_pricing_engine
                     );
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  --rkuttiya end validations for Multi GAAP
    END IF;

    IF (l_raise_exception) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     -- update the product for any user changes.
     update_products(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
                           p_pdtv_rec 	 => l_pdtv_rec,
                           x_pdtv_rec 	 => x_pdtv_rec);




         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;


      -- update the product status to 'passed' if the changes are valid and all the
      -- other validations are through.

      l_pdtv_rec.product_status_code := 'PASSED';

      update_product_status(p_api_version   => l_api_version,
                           p_init_msg_list => l_init_msg_list,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data,
                           p_pdt_status    => l_pdtv_rec.product_status_code,
                           p_pdt_id        => l_pdtv_rec.id);


         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

         ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR)  THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
    ELSE
    -- product cannot be validated while pending approval status/approved/passed status.

	    Okl_Api.SET_MESSAGE(p_app_name   => G_APP_NAME,
				      p_msg_name	   => G_PDT_VALDTION_NOT_VALID);
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
        	  RAISE OKL_API.G_EXCEPTION_ERROR;
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

    IF (chk_ptl_aes_bc%ISOPEN) THEN
	   	  CLOSE chk_ptl_aes_bc;
      END IF;


END validate_product;





  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Aes_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Aes_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Aes_Id(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_aes_status                   VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;
  l_token_1               VARCHAR2(1999);
  CURSOR okl_aesv_pk_csr (p_id                 IN NUMBER) IS

      SELECT  '1'
        FROM okl_ae_tmpt_sets_v
       WHERE okl_ae_tmpt_sets_v.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_TEMPLATE_SETS','OKL_TEMPLATE_SET');

    -- check for data before processing
    IF (p_pdtv_rec.aes_id IS NULL) OR
       (p_pdtv_rec.aes_id = Okl_Api.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
  IF(L_DEBUG_ENABLED='Y') THEN

    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pdt_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pdt_Pvt.g_required_value
                          ,p_token1         => Okl_Pdt_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF (p_pdtv_rec.AES_ID IS NOT NULL) THEN
        OPEN okl_aesv_pk_csr(p_pdtv_rec.AES_ID);
        FETCH okl_aesv_pk_csr INTO l_aes_status;
        l_row_notfound := okl_aesv_pk_csr%NOTFOUND;
        CLOSE okl_aesv_pk_csr;
        IF (l_row_notfound) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.set_message
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Api.set_message ');
    END;
  END IF;
          Okl_Api.set_message(Okl_Pdt_Pvt.G_APP_NAME, Okl_Pdt_Pvt.G_INVALID_VALUE,Okl_Pdt_Pvt.G_COL_NAME_TOKEN,l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN

    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Api.set_message ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.set_message
          RAISE G_EXCEPTION_HALT_PROCESSING;
        END IF;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);


      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Aes_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ptl_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ptl_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Ptl_Id(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_ptl_status                   VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;
  l_token_1               VARCHAR2(1999);

  CURSOR okl_ptlv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_pdt_templates_v
       WHERE okl_pdt_templates_v.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PDT_TMPL_CREATE_UPDATE','OKL_PRODUCT_TEMPLATE');

    -- check for data before processing
    IF (p_pdtv_rec.ptl_id IS NULL) OR
       (p_pdtv_rec.ptl_id = Okl_Api.G_MISS_NUM) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE

  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pdt_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pdt_Pvt.g_required_value
                          ,p_token1         => Okl_Pdt_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

    IF (p_pdtv_rec.PTL_ID IS NOT NULL) THEN
        OPEN okl_ptlv_pk_csr(p_pdtv_rec.PTL_ID);
        FETCH okl_ptlv_pk_csr INTO l_ptl_status;
        l_row_notfound := okl_ptlv_pk_csr%NOTFOUND;
        CLOSE okl_ptlv_pk_csr;
        IF (l_row_notfound) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.set_message
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Api.set_message ');

    END;
  END IF;
          Okl_Api.set_message(Okl_Pdt_Pvt.G_APP_NAME, Okl_Pdt_Pvt.G_INVALID_VALUE,Okl_Pdt_Pvt.G_COL_NAME_TOKEN,l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Api.set_message ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.set_message
          RAISE G_EXCEPTION_HALT_PROCESSING;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,

                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Ptl_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_From_Date(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;
  l_token_1               VARCHAR2(1999);


  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PRODUCT_CRUPD','OKL_EFFECTIVE_FROM');

    -- check for data before processing
    IF (p_pdtv_rec.from_date IS NULL) OR
       (p_pdtv_rec.from_date = Okl_Api.G_MISS_DATE) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN

    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pdt_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pdt_Pvt.g_required_value
                          ,p_token1         => Okl_Pdt_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,

                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Name(p_pdtv_rec      IN OUT  NOCOPY pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okl_Api.G_RET_STS_SUCCESS;

  l_token_1               VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_PRODUCT_CRUPD','OKL_NAME');

    -- check for data before processing
    IF (p_pdtv_rec.name IS NULL) OR
       (p_pdtv_rec.name = Okl_Api.G_MISS_CHAR) THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');
    END;
  END IF;
       Okl_Api.SET_MESSAGE(p_app_name       => Okl_Pdt_Pvt.g_app_name
                          ,p_msg_name       => Okl_Pdt_Pvt.g_required_value
                          ,p_token1         => Okl_Pdt_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Api.SET_MESSAGE ');

    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Api.SET_MESSAGE
       x_return_status    := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
    p_pdtv_rec.name := Okl_Accounting_Util.okl_upper(p_pdtv_rec.name);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,

                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;


---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_pdtv_rec IN OUT NOCOPY pdtv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_pdtv_rec pdtv_rec_type := p_pdtv_rec;
  BEGIN

    -- Validate_Name
    Validate_Name(l_pdtv_rec, x_return_status);
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

    -- Validate_Aes_Id
    Validate_Aes_Id(l_pdtv_rec, x_return_status);
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

    -- Validate_Ptl_Id
    Validate_Ptl_Id(l_pdtv_rec, x_return_status);
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

    -- Validate_From_Date
    Validate_From_Date(l_pdtv_rec, x_return_status);
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

    p_pdtv_rec := l_pdtv_rec;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okl_Api.SET_MESSAGE(p_app_name         => Okl_Pdt_Pvt.g_app_name,
                           p_msg_name         => Okl_Pdt_Pvt.g_unexpected_error,
                           p_token1           => Okl_Pdt_Pvt.g_sqlcode_token,
                           p_token1_value     => SQLCODE,

                           p_token2           => Okl_Pdt_Pvt.g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_pdtv_rec                 IN OUT NOCOPY pdtv_rec_type,
	p_db_pdtv_rec				   IN pdtv_rec_type
  ) IS
  l_upd_pdtv_rec	pdtv_rec_type;
  l_db_pdtv_rec     pdtv_rec_type;
  BEGIN

	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_pdtv_rec := p_upd_pdtv_rec;

       l_db_pdtv_rec := p_db_pdtv_rec;

	   IF l_upd_pdtv_rec.product_status_code = l_db_pdtv_rec.product_status_code THEN

	  	  l_upd_pdtv_rec.product_status_code := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.description = l_db_pdtv_rec.description THEN

	  	  l_upd_pdtv_rec.description := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_pdtv_rec.from_date := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_pdtv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_pdtv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_pdtv_rec.TO_DATE := Okl_Api.G_MISS_DATE;
	   END IF;

	   IF l_upd_pdtv_rec.legacy_product_yn = l_db_pdtv_rec.legacy_product_yn THEN
	   	  l_upd_pdtv_rec.legacy_product_yn := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.aes_id = l_db_pdtv_rec.aes_id THEN

	   	  l_upd_pdtv_rec.aes_id := Okl_Api.G_MISS_NUM;

	   END IF;

	   IF l_upd_pdtv_rec.ptl_id = l_db_pdtv_rec.ptl_id THEN
	   	  l_upd_pdtv_rec.ptl_id := Okl_Api.G_MISS_NUM;
	   END IF;

   	   IF l_upd_pdtv_rec.reporting_pdt_id = l_db_pdtv_rec.reporting_pdt_id THEN
	   	  l_upd_pdtv_rec.reporting_pdt_id := Okl_Api.G_MISS_NUM;
	   END IF;

	   IF l_upd_pdtv_rec.attribute_category = l_db_pdtv_rec.attribute_category THEN
	   	  l_upd_pdtv_rec.attribute_category := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute1 = l_db_pdtv_rec.attribute1 THEN
	   	  l_upd_pdtv_rec.attribute1 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute2 = l_db_pdtv_rec.attribute2 THEN
	   	  l_upd_pdtv_rec.attribute2 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute3 = l_db_pdtv_rec.attribute3 THEN
	   	  l_upd_pdtv_rec.attribute3 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute4 = l_db_pdtv_rec.attribute4 THEN
	   	  l_upd_pdtv_rec.attribute4 := Okl_Api.G_MISS_CHAR;
	   END IF;


	   IF l_upd_pdtv_rec.attribute5 = l_db_pdtv_rec.attribute5 THEN
	   	  l_upd_pdtv_rec.attribute5 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute6 = l_db_pdtv_rec.attribute6 THEN
	   	  l_upd_pdtv_rec.attribute6 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute7 = l_db_pdtv_rec.attribute7 THEN
	   	  l_upd_pdtv_rec.attribute7 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute8 = l_db_pdtv_rec.attribute8 THEN
	   	  l_upd_pdtv_rec.attribute8 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute9 = l_db_pdtv_rec.attribute9 THEN
	   	  l_upd_pdtv_rec.attribute9 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute10 = l_db_pdtv_rec.attribute10 THEN
	   	  l_upd_pdtv_rec.attribute10 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute11 = l_db_pdtv_rec.attribute11 THEN
	   	  l_upd_pdtv_rec.attribute11 := Okl_Api.G_MISS_CHAR;

	   END IF;

	   IF l_upd_pdtv_rec.attribute12 = l_db_pdtv_rec.attribute12 THEN
	   	  l_upd_pdtv_rec.attribute12 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute13 = l_db_pdtv_rec.attribute13 THEN
	   	  l_upd_pdtv_rec.attribute13 := Okl_Api.G_MISS_CHAR;
	   END IF;

	   IF l_upd_pdtv_rec.attribute14 = l_db_pdtv_rec.attribute14 THEN
	   	  l_upd_pdtv_rec.attribute14 := Okl_Api.G_MISS_CHAR;
	   END IF;


	   IF l_upd_pdtv_rec.attribute15 = l_db_pdtv_rec.attribute15 THEN
	   	  l_upd_pdtv_rec.attribute15 := Okl_Api.G_MISS_CHAR;
	   END IF;

       p_upd_pdtv_rec := l_upd_pdtv_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_pdtv_rec                 IN pdtv_rec_type,
	p_db_pdtv_rec				   IN pdtv_rec_type
  ) RETURN pdtv_rec_type IS
  l_pdtv_rec	pdtv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_pdtv_rec := p_db_pdtv_rec;

	   IF p_upd_pdtv_rec.aes_id <> Okl_Api.G_MISS_NUM THEN
	  	  l_pdtv_rec.aes_id := p_upd_pdtv_rec.aes_id;
	   END IF;

	   IF p_upd_pdtv_rec.ptl_id <> Okl_Api.G_MISS_NUM THEN

	  	  l_pdtv_rec.ptl_id := p_upd_pdtv_rec.ptl_id;
	   END IF;

   	   IF p_upd_pdtv_rec.reporting_pdt_id <> Okl_Api.G_MISS_NUM THEN
	  	  l_pdtv_rec.reporting_pdt_id := p_upd_pdtv_rec.reporting_pdt_id;
	   END IF;

	   IF p_upd_pdtv_rec.description <> Okl_Api.G_MISS_CHAR THEN
	  	  l_pdtv_rec.description := p_upd_pdtv_rec.description;
	   END IF;


	   IF p_upd_pdtv_rec.product_status_code <> Okl_Api.G_MISS_CHAR THEN
	  	  l_pdtv_rec.product_status_code := p_upd_pdtv_rec.product_status_code;
	   END IF;


	   IF p_upd_pdtv_rec.legacy_product_yn <> Okl_Api.G_MISS_CHAR THEN
	  	  l_pdtv_rec.legacy_product_yn := p_upd_pdtv_rec.legacy_product_yn;
	   END IF;

	   IF p_upd_pdtv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
	  	  l_pdtv_rec.from_date := p_upd_pdtv_rec.from_date;
	   END IF;

	   IF p_upd_pdtv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
	   	  l_pdtv_rec.TO_DATE := p_upd_pdtv_rec.TO_DATE;
	   END IF;

	   IF p_upd_pdtv_rec.attribute_category <> Okl_Api.G_MISS_CHAR THEN

	   	  l_pdtv_rec.attribute_category := p_upd_pdtv_rec.attribute_category;
	   END IF;

	   IF p_upd_pdtv_rec.attribute1 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute1 := p_upd_pdtv_rec.attribute1;
	   END IF;

	   IF p_upd_pdtv_rec.attribute2 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute2 := p_upd_pdtv_rec.attribute2;
	   END IF;

	   IF p_upd_pdtv_rec.attribute3 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute3 := p_upd_pdtv_rec.attribute3;
	   END IF;

	   IF p_upd_pdtv_rec.attribute4 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute4 := p_upd_pdtv_rec.attribute4;
	   END IF;

	   IF p_upd_pdtv_rec.attribute5 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute5 := p_upd_pdtv_rec.attribute5;
	   END IF;

	   IF p_upd_pdtv_rec.attribute6 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute6 := p_upd_pdtv_rec.attribute6;
	   END IF;

	   IF p_upd_pdtv_rec.attribute7 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute7 := p_upd_pdtv_rec.attribute7;
	   END IF;

	   IF p_upd_pdtv_rec.attribute8 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute8 := p_upd_pdtv_rec.attribute8;
	   END IF;


	   IF p_upd_pdtv_rec.attribute9 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute9 := p_upd_pdtv_rec.attribute9;
	   END IF;


	   IF p_upd_pdtv_rec.attribute10 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute10 := p_upd_pdtv_rec.attribute10;
	   END IF;

	   IF p_upd_pdtv_rec.attribute11 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute11 := p_upd_pdtv_rec.attribute11;
	   END IF;

	   IF p_upd_pdtv_rec.attribute12 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute12 := p_upd_pdtv_rec.attribute12;
	   END IF;

	   IF p_upd_pdtv_rec.attribute13 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute13 := p_upd_pdtv_rec.attribute13;
	   END IF;

	   IF p_upd_pdtv_rec.attribute14 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute14 := p_upd_pdtv_rec.attribute14;
	   END IF;

	   IF p_upd_pdtv_rec.attribute15 <> Okl_Api.G_MISS_CHAR THEN
	   	  l_pdtv_rec.attribute15 := p_upd_pdtv_rec.attribute15;
	   END IF;

	   RETURN l_pdtv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------

  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_upd_pdtv_rec                 IN pdtv_rec_type,
	p_db_pdtv_rec				   IN pdtv_rec_type,
	p_pdtv_rec					   IN pdtv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2
  ) IS
  l_upd_pdtv_rec  pdtv_rec_type;
  l_pdtv_rec	  pdtv_rec_type;
  l_db_pdtv_rec	  pdtv_rec_type;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN

	   x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	   l_pdtv_rec := p_pdtv_rec;
       l_upd_pdtv_rec := p_upd_pdtv_rec;
	   l_db_pdtv_rec := p_db_pdtv_rec;

       /* check for start date greater than sysdate */
	   /*IF to_date(to_char(l_upd_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	      to_date(to_char(l_upd_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);

          x_return_status    := OKL_API.G_RET_STS_ERROR;
	      RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;	       */

       /* check for the records with from and to dates less than sysdate */

      /* IF to_date(to_char(l_upd_pdtv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
			      		      p_msg_name		=> G_PAST_RECORDS);
  	      x_return_status    := OKL_API.G_RET_STS_ERROR;
	      RAISE G_EXCEPTION_HALT_PROCESSING;
	   END IF;*/

       /* if the start date is in the past, the start date cannot be
       modified */
	  /* IF to_date(to_char(l_upd_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	      to_date(to_char(P_db_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
			  			      p_msg_name		=> 'OKL_NOT_ALLOWED',
                              p_token1         => G_COL_NAME_TOKEN,
                              p_token1_value   => 'START_DATE');
          x_return_status    := OKL_API.G_RET_STS_ERROR;
	      RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;	   	*/

	   IF p_upd_pdtv_rec.from_date <> Okl_Api.G_MISS_DATE OR
	   	  p_upd_pdtv_rec.TO_DATE <> Okl_Api.G_MISS_DATE OR
		  p_upd_pdtv_rec.reporting_pdt_id <> Okl_Api.G_MISS_NUM OR
		  p_upd_pdtv_rec.aes_id <> Okl_Api.G_MISS_NUM OR
		  p_upd_pdtv_rec.ptl_id <> Okl_Api.G_MISS_NUM OR
    -- Handle the condition when the Reporting product is being passed as NULL where as the DB has it
    ( p_upd_pdtv_rec.reporting_pdt_id IS NULL AND l_db_pdtv_rec.reporting_pdt_id IS NOT NULL )
    THEN


		  /* call check_overlaps */
		 /* Okl_Setuppdttemplates_Pvt.check_overlaps(p_id	   	 	    => l_upd_pdtv_rec.id,
		  				                     p_name	            => l_pdtv_rec.name,
		  				                     p_from_date 		=> l_pdtv_rec.from_date,
						                     p_to_date		    => l_pdtv_rec.TO_DATE,


						                     p_table			=> 'Okl_Products_V',
						                     x_return_status	=> l_return_status,
						                     x_valid			=> l_valid);
       	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		 x_return_status    := OKL_API.G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		  	    (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
       		 x_return_status    := OKL_API.G_RET_STS_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  END IF;*/

		  /* call check_constraints */
		  Check_Constraints(p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
          		            x_msg_count      => x_msg_count,
          		            x_msg_data       => x_msg_data,
		                    p_upd_pdtv_rec   => l_upd_pdtv_rec,
                            p_pdtv_rec 	 	 => l_pdtv_rec,
                            p_db_pdtv_rec 	 => l_db_pdtv_rec,
						    x_return_status	 => l_return_status,
						    x_valid			 => l_valid);

  	  IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       		 x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		  	    (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND

		   	     l_valid <> TRUE) THEN
      		 	x_return_status    := Okl_Api.G_RET_STS_ERROR;
      	  	 	RAISE G_EXCEPTION_HALT_PROCESSING;
       	  END IF;


    	  IF l_valid <> TRUE THEN
       		 	x_return_status    := Okl_Api.G_RET_STS_ERROR;
      	  	 	RAISE G_EXCEPTION_HALT_PROCESSING;
       	  END IF;

	   END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_updates;


  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_PRODUCTS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_pdtv_rec                 IN pdtv_rec_type,
	p_db_pdtv_rec				   IN pdtv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
 BEGIN
  /* Scenario 1: Only description and/or descriptive flexfield changes */

  IF (p_upd_pdtv_rec.from_date = Okl_Api.G_MISS_DATE AND
	  p_upd_pdtv_rec.TO_DATE = Okl_Api.G_MISS_DATE AND
	  p_upd_pdtv_rec.aes_id = Okl_Api.G_MISS_NUM AND
	  p_upd_pdtv_rec.ptl_id = Okl_Api.G_MISS_NUM AND
	  p_upd_pdtv_rec.reporting_pdt_id = Okl_Api.G_MISS_NUM) THEN
	  --p_db_pdtv_rec.from_date = l_sysdate THEN
	 l_action := '1';
	/* Scenario 2: only changing description/descriptive flexfield changes
	   and end date for all records or changing anything for a future record other
	   than start date or modified start date is less than existing start date */
  ELSE
  l_action := '2';
  END IF;

  RETURN(l_action);
 END determine_action;

 ---------------------------------------------------------------------------
  -- PROCEDURE get_prod_strm_types for: OKL_PRODUCTS_V

  -- To fetch the product Stream Types that are attached to the existing
  -- version of the product
  ---------------------------------------------------------------------------
  PROCEDURE get_prod_strm_types (p_upd_pdtv_rec   IN pdtv_rec_type,
    					         p_pdtv_rec       IN pdtv_rec_type,

                                 p_flag           IN VARCHAR2,
						         x_return_status  OUT NOCOPY VARCHAR2,
						         x_count		  OUT NOCOPY NUMBER,
						         x_psyv_tbl	      OUT NOCOPY psyv_tbl_type
  ) IS
    CURSOR okl_psyv_fk_csr (p_pdt_id IN Okl_prod_strm_types_V.pdt_id%TYPE) IS
    SELECT ID,
           PDT_ID,
		   STY_ID,
		   ACCRUAL_YN,
           FROM_DATE,
           TO_DATE
    FROM Okl_prod_strm_types_V psy
    WHERE psy.PDT_ID    = p_pdt_id;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_psyv_tbl	    psyv_tbl_type;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_psy_rec IN okl_psyv_fk_csr(p_upd_pdtv_rec.id)
	LOOP

       IF p_flag = G_UPDATE THEN
          l_psyv_tbl(l_count).ID := okl_psy_rec.ID;
       END IF;
	   l_psyv_tbl(l_count).PDT_ID := p_pdtv_rec.ID;
	   l_psyv_tbl(l_count).STY_ID := okl_psy_rec.STY_ID;
	   l_psyv_tbl(l_count).ACCRUAL_YN := okl_psy_rec.ACCRUAL_YN;
       IF p_upd_pdtv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
          l_psyv_tbl(l_count).from_date := p_upd_pdtv_rec.from_date;
       ELSE
          l_psyv_tbl(l_count).from_date := okl_psy_rec.from_date;
       END IF;
       IF p_upd_pdtv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
          l_psyv_tbl(l_count).TO_DATE := p_upd_pdtv_rec.TO_DATE;
       ELSE
          l_psyv_tbl(l_count).TO_DATE := okl_psy_rec.TO_DATE;
       END IF;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_psyv_tbl := l_psyv_tbl;

EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;


      IF (okl_psyv_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_psyv_fk_csr;
      END IF;

  END get_prod_strm_types;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_pdt_pqy_vals for: OKL_PRODUCTS_V
  -- To fetch the product quality values that are attached to the existing
  -- version of the product
  ---------------------------------------------------------------------------
  PROCEDURE get_pdt_pqy_vals (p_upd_pdtv_rec   IN pdtv_rec_type,
    					      p_pdtv_rec       IN pdtv_rec_type,
                              p_flag           IN VARCHAR2,
						      x_return_status  OUT NOCOPY VARCHAR2,
						      x_count		   OUT NOCOPY NUMBER,
						      x_pqvv_tbl	   OUT NOCOPY pqvv_tbl_type
  ) IS
    CURSOR okl_pqvv_fk_csr (p_pdt_id IN Okl_Pdt_Pqy_Vals_V.pdt_id%TYPE) IS
    SELECT ID,
           PDQ_ID,
		   QVE_ID,
           FROM_DATE,
           TO_DATE
    FROM Okl_pdt_pqy_vals_V pqv
    WHERE pqv.PDT_ID    = p_pdt_id;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_pqvv_tbl	    pqvv_tbl_type;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_pqv_rec IN okl_pqvv_fk_csr(p_upd_pdtv_rec.id)
	LOOP
       IF p_flag = G_UPDATE THEN
          l_pqvv_tbl(l_count).ID := okl_pqv_rec.ID;
       END IF;

	   l_pqvv_tbl(l_count).PDT_ID := p_pdtv_rec.ID;
	   l_pqvv_tbl(l_count).PDQ_ID := okl_pqv_rec.PDQ_ID;
	   l_pqvv_tbl(l_count).QVE_ID := okl_pqv_rec.QVE_ID;
       IF p_upd_pdtv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
          l_pqvv_tbl(l_count).from_date := p_upd_pdtv_rec.from_date;
       ELSE
          l_pqvv_tbl(l_count).from_date := okl_pqv_rec.from_date;
       END IF;
       IF p_upd_pdtv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
          l_pqvv_tbl(l_count).TO_DATE := p_upd_pdtv_rec.TO_DATE;
       ELSE
          l_pqvv_tbl(l_count).TO_DATE := okl_pqv_rec.TO_DATE;
       END IF;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_pqvv_tbl := l_pqvv_tbl;

EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,

                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_pqvv_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_pqvv_fk_csr;
      END IF;

  END get_pdt_pqy_vals;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_pdt_opts for: OKL_PRODUCTS_V
  -- To fetch the product options that are attached to the existing
  -- version of the product
  ---------------------------------------------------------------------------
  PROCEDURE get_pdt_opts (p_upd_pdtv_rec   IN pdtv_rec_type,
    					  p_pdtv_rec       IN pdtv_rec_type,
                          p_flag           IN VARCHAR2,
						  x_return_status  OUT NOCOPY VARCHAR2,
						  x_count		   OUT NOCOPY NUMBER,
						  x_ponv_tbl	   OUT NOCOPY ponv_tbl_type
  ) IS
    CURSOR okl_ponv_fk_csr (p_pdt_id IN Okl_Pdt_Opts_V.pdt_id%TYPE) IS
    SELECT ID,
           OPT_ID,
           OPTIONAL_YN,
           FROM_DATE,
           TO_DATE
    FROM Okl_Pdt_Opts_V pon
    WHERE pon.PDT_ID    = p_pdt_id;


  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_ponv_tbl	    ponv_tbl_type;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_pon_rec IN okl_ponv_fk_csr(p_upd_pdtv_rec.id)
	LOOP
       IF p_flag = G_UPDATE THEN
          l_ponv_tbl(l_count).ID := okl_pon_rec.ID;
       END IF;
	   l_ponv_tbl(l_count).PDT_ID := p_pdtv_rec.ID;
	   l_ponv_tbl(l_count).OPT_ID := okl_pon_rec.OPT_ID;
	   l_ponv_tbl(l_count).OPTIONAL_YN := okl_pon_rec.OPTIONAL_YN;
       IF p_upd_pdtv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
          l_ponv_tbl(l_count).from_date := p_upd_pdtv_rec.from_date;
       ELSE
          l_ponv_tbl(l_count).from_date := okl_pon_rec.from_date;
       END IF;
       IF p_upd_pdtv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
          l_ponv_tbl(l_count).TO_DATE := p_upd_pdtv_rec.TO_DATE;
       ELSE
          l_ponv_tbl(l_count).TO_DATE := okl_pon_rec.TO_DATE;
       END IF;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;

	x_ponv_tbl := l_ponv_tbl;

EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );

		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_ponv_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_ponv_fk_csr;
      END IF;

  END get_pdt_opts;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_pdt_opt_vals for: OKL_PRODUCTS_V
  -- To fetch the valid option values for the attached options to the existing
  -- version of the product
  ---------------------------------------------------------------------------
  PROCEDURE get_pdt_opt_vals (p_upd_pdtv_rec   IN pdtv_rec_type,
    					      p_pdtv_rec       IN pdtv_rec_type,
                              p_ponv_tbl       IN ponv_tbl_type,
                              p_flag           IN VARCHAR2,
						      x_return_status  OUT NOCOPY VARCHAR2,
						      x_count		   OUT NOCOPY NUMBER,
						      x_povv_tbl	   OUT NOCOPY povv_tbl_type

  ) IS
    CURSOR okl_povv_fk_csr (p_pdt_id IN Okl_Products_V.id%TYPE) IS
    SELECT pov.ID ID,
           ove.OPT_ID OPT_ID,
           pov.OVE_ID OVE_ID,
           pov.FROM_DATE FROM_DATE,
           pov.TO_DATE TO_DATE
    FROM Okl_Pdt_Opts_V pon,
         Okl_Pdt_Opt_Vals_V pov,
         Okl_Opt_Values_V ove
    WHERE pon.PDT_ID    = p_pdt_id
    AND   pov.PON_ID    = pon.ID
    AND   ove.ID        = pov.OVE_ID;

  	l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_count 		NUMBER := 0;
	l_povv_tbl	    povv_tbl_type;
    i               NUMBER := 0;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_pov_rec IN okl_povv_fk_csr(p_upd_pdtv_rec.id)
	LOOP
       IF p_flag = G_UPDATE THEN
          l_povv_tbl(l_count).ID := okl_pov_rec.ID;
       END IF;
	   l_povv_tbl(l_count).OVE_ID := okl_pov_rec.OVE_ID;
       FOR i IN p_ponv_tbl.FIRST .. p_ponv_tbl.LAST
       LOOP
           IF p_ponv_tbl(i).opt_id = okl_pov_rec.opt_id THEN
       	      l_povv_tbl(l_count).pon_id := p_ponv_tbl(i).id;
           END IF;
       END LOOP;

       IF p_upd_pdtv_rec.from_date <> Okl_Api.G_MISS_DATE THEN
          l_povv_tbl(l_count).from_date := p_upd_pdtv_rec.from_date;
       ELSE
          l_povv_tbl(l_count).from_date := okl_pov_rec.from_date;
       END IF;
       IF p_upd_pdtv_rec.TO_DATE <> Okl_Api.G_MISS_DATE THEN
          l_povv_tbl(l_count).TO_DATE := p_upd_pdtv_rec.TO_DATE;
       ELSE
          l_povv_tbl(l_count).TO_DATE := okl_pov_rec.TO_DATE;
       END IF;
	   l_count := l_count + 1;
	END LOOP;

	x_count := l_count;
	x_povv_tbl := l_povv_tbl;

EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF (okl_povv_fk_csr%ISOPEN) THEN

	   	  CLOSE okl_povv_fk_csr;
      END IF;

  END get_pdt_opt_vals;

  ---------------------------------------------------------------------------
  -- PROCEDURE copy_update_constraints for: OKL_PRODUCTS_V
  -- To copy constraints data from one version to the other
  ---------------------------------------------------------------------------
  PROCEDURE copy_update_constraints (p_api_version    IN  NUMBER,
                                     p_init_msg_list  IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                                     p_upd_pdtv_rec   IN  pdtv_rec_type,
                                     p_db_pdtv_rec    IN  pdtv_rec_type,
    					             p_pdtv_rec       IN  pdtv_rec_type,

                                     p_flag           IN  VARCHAR2,
						             x_return_status  OUT NOCOPY VARCHAR2,
                      		 		 x_msg_count      OUT NOCOPY NUMBER,
                              		 x_msg_data       OUT NOCOPY VARCHAR2
  ) IS
	l_upd_pdtv_rec	 	  	pdtv_rec_type; /* input copy */
	l_pdtv_rec	  	 	  	pdtv_rec_type; /* latest with the retained changes */
	l_db_pdtv_rec			pdtv_rec_type; /* for db copy */
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_pqv_count				NUMBER := 0;
    l_pon_count             NUMBER := 0;
    l_pov_count             NUMBER := 0;
    l_psy_count             NUMBER := 0;
	l_pqvv_tbl				pqvv_tbl_type;
	l_out_pqvv_tbl			pqvv_tbl_type;
	l_ponv_tbl				ponv_tbl_type;
	l_out_ponv_tbl			ponv_tbl_type;
	l_povv_tbl				povv_tbl_type;
	l_out_povv_tbl			povv_tbl_type;

    l_psyv_tbl				psyv_tbl_type;
	l_out_psyv_tbl			psyv_tbl_type;

 BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	l_upd_pdtv_rec := p_pdtv_rec;
    l_pdtv_rec := p_pdtv_rec;
    l_db_pdtv_rec := p_db_pdtv_rec;

    /* product Stream Types carryover */
	get_prod_strm_types(p_upd_pdtv_rec	  => l_upd_pdtv_rec,
	 				    p_pdtv_rec		  => l_pdtv_rec,
                        p_flag            => p_flag,
					    x_return_status   => l_return_status,
					    x_count		      => l_psy_count,
					    x_psyv_tbl		  => l_psyv_tbl);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_pqv_count > 0 THEN
       IF p_flag = G_UPDATE THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Pdt_Stys_Pub.update_pdt_stys
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Pdt_Stys_Pub.update_pdt_stys ');
    END;
  END IF;
	      Okl_Pdt_Stys_Pub.update_pdt_stys(p_api_version   => p_api_version,
                           		 		     p_init_msg_list => p_init_msg_list,
                              		 		 x_return_status => l_return_status,

                              		 		 x_msg_count     => x_msg_count,
                              		 		 x_msg_data      => x_msg_data,
                              		 		 p_psyv_tbl      => l_psyv_tbl,
                              		 		 x_psyv_tbl      => l_out_psyv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Pdt_Stys_Pub.update_pdt_stys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pdt_Stys_Pub.update_pdt_stys
       ELSE
-- Start of wraper code generated automatically by Debug code generator for Okl_Pdt_Stys_Pub.insert_pdt_stys
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Pdt_Stys_Pub.insert_pdt_stys ');
    END;
  END IF;
	      Okl_Pdt_Stys_Pub.insert_pdt_stys(p_api_version   => p_api_version,
                           		 		     p_init_msg_list => p_init_msg_list,
                              		 		 x_return_status => l_return_status,
                              		 		 x_msg_count     => x_msg_count,
                              		 		 x_msg_data      => x_msg_data,
                              		 		 p_psyv_tbl      => l_psyv_tbl,
                              		 		 x_psyv_tbl      => l_out_psyv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Pdt_Stys_Pub.insert_pdt_stys ');

    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pdt_Stys_Pub.insert_pdt_stys
       END IF;
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
	END IF;

	/* product quality values carryover */
	get_pdt_pqy_vals(p_upd_pdtv_rec	  => l_upd_pdtv_rec,
	 				 p_pdtv_rec		  => l_pdtv_rec,
                     p_flag           => p_flag,

					 x_return_status  => l_return_status,
					 x_count		  => l_pqv_count,
					 x_pqvv_tbl		  => l_pqvv_tbl);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_pqv_count > 0 THEN
       IF p_flag = G_UPDATE THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.update_pqy_values
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Pqy_Values_Pub.update_pqy_values ');
    END;
  END IF;
	      Okl_Pqy_Values_Pub.update_pqy_values(p_api_version   => p_api_version,

                           		 		       p_init_msg_list => p_init_msg_list,
                              		 		   x_return_status => l_return_status,
                              		 		   x_msg_count     => x_msg_count,
                              		 		   x_msg_data      => x_msg_data,
                              		 		   p_pqvv_tbl      => l_pqvv_tbl,
                              		 		   x_pqvv_tbl      => l_out_pqvv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Pqy_Values_Pub.update_pqy_values ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.update_pqy_values
       ELSE
-- Start of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.insert_pqy_values
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Pqy_Values_Pub.insert_pqy_values ');
    END;
  END IF;
	      Okl_Pqy_Values_Pub.insert_pqy_values(p_api_version   => p_api_version,
                           		 		       p_init_msg_list => p_init_msg_list,
                              		 		   x_return_status => l_return_status,
                              		 		   x_msg_count     => x_msg_count,
                              		 		   x_msg_data      => x_msg_data,
                              		 		   p_pqvv_tbl      => l_pqvv_tbl,
                              		 		   x_pqvv_tbl      => l_out_pqvv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Pqy_Values_Pub.insert_pqy_values ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pqy_Values_Pub.insert_pqy_values
       END IF;
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN

	      x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
	END IF;

	/* product options carryover */
	get_pdt_opts(p_upd_pdtv_rec	  => l_upd_pdtv_rec,
	   			 p_pdtv_rec		  => l_pdtv_rec,
                 p_flag           => p_flag,
				 x_return_status  => l_return_status,
				 x_count		  => l_pon_count,
				 x_ponv_tbl		  => l_ponv_tbl);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_pon_count > 0 THEN
       IF p_flag = G_UPDATE THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Product_Options_Pub.update_product_options
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Product_Options_Pub.update_product_options ');
    END;
  END IF;

	      Okl_Product_Options_Pub.update_product_options(p_api_version   => p_api_version,
                            		 	                 p_init_msg_list => p_init_msg_list,
                              		 	                 x_return_status => l_return_status,
                              		 	                 x_msg_count     => x_msg_count,
                              		 	                 x_msg_data      => x_msg_data,
                              		 	                 p_ponv_tbl      => l_ponv_tbl,
                              		 	                 x_ponv_tbl      => l_out_ponv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Product_Options_Pub.update_product_options ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Product_Options_Pub.update_product_options
       ELSE
-- Start of wraper code generated automatically by Debug code generator for Okl_Product_Options_Pub.insert_product_options
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Product_Options_Pub.insert_product_options ');
    END;
  END IF;

	      Okl_Product_Options_Pub.insert_product_options(p_api_version   => p_api_version,
                            		 	                 p_init_msg_list => p_init_msg_list,
                              		 	                 x_return_status => l_return_status,
                              		 	                 x_msg_count     => x_msg_count,
                              		 	                 x_msg_data      => x_msg_data,
                              		 	                 p_ponv_tbl      => l_ponv_tbl,
                              		 	                 x_ponv_tbl      => l_out_ponv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Product_Options_Pub.insert_product_options ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Product_Options_Pub.insert_product_options
       END IF;
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN

	      x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;

	END IF;

    /* valid product option values carryover */
	get_pdt_opt_vals(p_upd_pdtv_rec	 => l_upd_pdtv_rec,
	   				 p_pdtv_rec		 => l_pdtv_rec,
                     p_ponv_tbl      => l_out_ponv_tbl,
                     p_flag          => p_flag,
					 x_return_status => l_return_status,
					 x_count		 => l_pov_count,
					 x_povv_tbl		 => l_povv_tbl);
    IF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

	IF l_pov_count > 0 THEN
       IF p_flag = G_UPDATE THEN
-- Start of wraper code generated automatically by Debug code generator for Okl_Pdt_Opt_Vals_Pub.update_pdt_opt_vals
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Pdt_Opt_Vals_Pub.update_pdt_opt_vals ');
    END;
  END IF;
	      Okl_Pdt_Opt_Vals_Pub.update_pdt_opt_vals(p_api_version   => p_api_version,
                            		 	           p_init_msg_list => p_init_msg_list,
                              		 	           x_return_status => l_return_status,
                              		 	           x_msg_count     => x_msg_count,
                              		 	           x_msg_data      => x_msg_data,
                              		 	           p_povv_tbl      => l_povv_tbl,
                              		 	           x_povv_tbl      => l_out_povv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN

    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Pdt_Opt_Vals_Pub.update_pdt_opt_vals ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pdt_Opt_Vals_Pub.update_pdt_opt_vals
       ELSE
-- Start of wraper code generated automatically by Debug code generator for Okl_Pdt_Opt_Vals_Pub.insert_pdt_opt_vals
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Pdt_Opt_Vals_Pub.insert_pdt_opt_vals ');
    END;
  END IF;
	      Okl_Pdt_Opt_Vals_Pub.insert_pdt_opt_vals(p_api_version   => p_api_version,
                            		 	           p_init_msg_list => p_init_msg_list,
                              		 	           x_return_status => l_return_status,
                              		 	           x_msg_count     => x_msg_count,
                              		 	           x_msg_data      => x_msg_data,
                              		 	           p_povv_tbl      => l_povv_tbl,
                              		 	           x_povv_tbl      => l_out_povv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Pdt_Opt_Vals_Pub.insert_pdt_opt_vals ');
    END;

  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Pdt_Opt_Vals_Pub.insert_pdt_opt_vals
       END IF;
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
	      x_return_status    := Okl_Api.G_RET_STS_UNEXP_ERROR;
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
      Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,

                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
		-- notify UNEXPECTED error for calling API.
		x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END copy_update_constraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_products for: OKL_PRODUCTS_V
  ---------------------------------------------------------------------------

  PROCEDURE insert_products(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pdtv_rec         IN  pdtv_rec_type,
                        	x_pdtv_rec         OUT NOCOPY pdtv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_products';
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
    --return_status   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
	l_pdtv_rec		  pdtv_rec_type;
	l_db_pdtv_rec	  pdtv_rec_type;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');

   CURSOR chk_ptl_aes_bc(p_aes_id      IN Okl_Products_V.AES_ID%TYPE,
                         p_ptl_id      IN Okl_Products_V.PTL_ID%TYPE,
             	         p_pdt_id      IN Okl_Products_V.id%TYPE)
   IS
   SELECT DISTINCT DECODE(C.product_type,'FINANCIAL','LEASE','INVESTOR')
   FROM okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE b.gts_id = c.id
   AND b.id = p_aes_id
   INTERSECT
   SELECT DISTINCT PQY.NAME
   FROM okl_PDT_PQYS_V  PDQ,
   OKL_PQY_VALUES_V QVE,OKL_PDT_QUALITYS_V PQY
   WHERE PQY.ID = QVE.PQY_ID
   AND PQY.ID= PDQ.PQY_ID
   AND PDQ.PTL_ID = p_PTL_ID
   AND pqy.name IN('LEASE','INVESTOR');

   l_chk_bc     VARCHAR2(100);


  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_pdtv_rec := p_pdtv_rec;

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


    l_return_status := Validate_Attributes(l_pdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN chk_ptl_aes_bc(l_pdtv_rec.aes_id,l_pdtv_rec.ptl_id,l_pdtv_rec.id);
    FETCH chk_ptl_aes_bc INTO l_chk_bc;
    CLOSE chk_ptl_aes_bc;

    IF l_chk_bc IS NULL THEN

                  Okl_Api.SET_MESSAGE(p_app_name   => G_APP_NAME,
				      p_msg_name   => G_PTL_AES_BC_MISMATCH);
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



  /* check for the records with from and to dates less than sysdate */
 /*   IF to_date(to_char(l_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_pdtv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
*/
  	/* call check_constraints */
	Check_Constraints(p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
	                  p_upd_pdtv_rec     => l_pdtv_rec,
                      p_pdtv_rec 	 	 => l_pdtv_rec,
					  p_db_pdtv_rec 	 => l_db_pdtv_rec,
					  x_return_status	 => l_return_status,
					  x_valid			 => l_valid);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN

        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) OR
		   (l_return_status = Okl_Api.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

	/* public api to insert products */
-- Start of wraper code generated automatically by Debug code generator for Okl_Products_Pub.insert_products
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Products_Pub.insert_products ');
    END;
  END IF;



    l_pdtv_rec.PRODUCT_STATUS_CODE := G_PDT_STS_NEW;

    Okl_Products_Pub.insert_products(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_pdtv_rec      => l_pdtv_rec,
                              		 x_pdtv_rec      => x_pdtv_rec);


  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Products_Pub.insert_products ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Products_Pub.insert_products

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

  END insert_products;


  ---------------------------------------------------------------------------
  -- PROCEDURE update_products for: OKL_PRODUCTS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_products(p_api_version       IN  NUMBER,
                                p_init_msg_list     IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                        	    x_return_status     OUT NOCOPY VARCHAR2,
                        	    x_msg_count         OUT NOCOPY NUMBER,
                        	    x_msg_data          OUT NOCOPY VARCHAR2,
                        	    p_pdtv_rec          IN  pdtv_rec_type,
                        	    x_pdtv_rec          OUT NOCOPY pdtv_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_products';
    l_validated             	VARCHAR2(2000);
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
	l_oldversion_enddate  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_db_pdtv_rec    	  	pdtv_rec_type; /* database copy */
	l_upd_pdtv_rec	 	  	pdtv_rec_type; /* input copy */
	l_pdtv_rec	  	 	  	pdtv_rec_type; /* latest with the retained changes */
	l_tmp_pdtv_rec			pdtv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
--    x_return_status   	  	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_new_version			VARCHAR2(100);

	l_pqv_count				NUMBER := 0;
    l_pon_count             NUMBER := 0;
    l_pov_count             NUMBER := 0;
	l_pqvv_tbl				pqvv_tbl_type;
	l_out_pqvv_tbl			pqvv_tbl_type;
	l_ponv_tbl				ponv_tbl_type;
	l_out_ponv_tbl			ponv_tbl_type;
	l_povv_tbl				povv_tbl_type;
	l_out_povv_tbl			povv_tbl_type;
 l_chk_bc     VARCHAR2(100);



   CURSOR chk_ptl_aes_bc(p_aes_id      IN Okl_Products_V.AES_ID%TYPE,
                         p_ptl_id      IN Okl_Products_V.PTL_ID%TYPE,
             	         p_pdt_id      IN Okl_Products_V.id%TYPE)
   IS
   SELECT DISTINCT DECODE(C.product_type,'FINANCIAL','LEASE','INVESTOR')
   FROM okl_ae_tmpt_sets_v b,
      OKL_ST_GEN_TMPT_SETS c
   WHERE b.gts_id = c.id
   AND b.id = p_aes_id
   INTERSECT
   SELECT DISTINCT PQY.NAME
   FROM okl_PDT_PQYS_V  PDQ,
   OKL_PQY_VALUES_V QVE,OKL_PDT_QUALITYS_V PQY
   WHERE PQY.ID = QVE.PQY_ID
   AND PQY.ID= PDQ.PQY_ID
   AND PDQ.PTL_ID = p_PTL_ID
   AND pqy.name IN('LEASE','INVESTOR');

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_upd_pdtv_rec := p_pdtv_rec;


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
      get_rec(p_pdtv_rec 	 	=> l_upd_pdtv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_pdtv_rec		=> l_db_pdtv_rec);
       IF l_return_status <> Okl_Api.G_RET_STS_SUCCESS OR

	   l_no_data_found = TRUE THEN
	   RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

    -- updates not allowed when the product is in pending approval status.
    --IF l_db_pdtv_rec.product_status_code IN  ('PENDING APPROVAL') THEN
      --       Okl_Api.SET_MESSAGE(p_app_name	   => G_APP_NAME,
	--  			       p_msg_name	   => G_PDT_SUBMTD_FOR_APPROVAL);
	 --          x_return_status := Okl_Api.G_RET_STS_ERROR;
        --	  RAISE OKL_API.G_EXCEPTION_ERROR;
    --END IF;

    OPEN chk_ptl_aes_bc(l_upd_pdtv_rec.aes_id,l_upd_pdtv_rec.ptl_id,l_upd_pdtv_rec.id);
    FETCH chk_ptl_aes_bc INTO l_chk_bc;
    CLOSE chk_ptl_aes_bc;

    IF l_chk_bc IS NULL THEN

                  Okl_Api.SET_MESSAGE(p_app_name   => G_APP_NAME,
				      p_msg_name   => G_PTL_AES_BC_MISMATCH);
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_pdtv_rec     => l_upd_pdtv_rec,
                      p_db_pdtv_rec      => l_db_pdtv_rec);

	/* check for start date greater than sysdate */
	/*IF to_date(to_char(l_upd_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;	*/

      /* check for the records with start and end dates less than sysdate */
/*    IF to_date(to_char(l_db_pdtv_rec.from_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
	   to_date(to_char(l_db_pdtv_rec.TO_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN

	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
*/
	/* determine how the processing to be done */
	l_action := determine_action(p_upd_pdtv_rec	 => l_upd_pdtv_rec,
			 					 p_db_pdtv_rec	 => l_db_pdtv_rec,
								 p_date			 => l_sysdate);


	/* Scenario 1: only changing description */
	IF l_action = '1' THEN

	   /* public api to update products */
-- Start of wraper code generated automatically by Debug code generator for Okl_Products_Pub.update_products
/*
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Products_Pub.update_products ');
    END;
  END IF;
*/


        IF P_pdtv_rec.product_status_code NOT IN  ('PENDING APPROVAL','APPROVED') THEN
          l_upd_pdtv_rec.product_status_code := 'PASSED';
        END IF;

       Okl_Products_Pub.update_products(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_pdtv_rec      => l_upd_pdtv_rec,
                              		 	x_pdtv_rec      => x_pdtv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Products_Pub.update_products ');

    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Products_Pub.update_products

       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN

          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN

       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 2: only changing description and end date for all records
       or modified start date is less than existing start date for a future record */

	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_pdtv_rec := defaults_to_actuals(p_upd_pdtv_rec => l_upd_pdtv_rec,
	   					  				 p_db_pdtv_rec  => l_db_pdtv_rec);
       /* check the changes */

	   check_updates(p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
	                 p_upd_pdtv_rec	 => l_upd_pdtv_rec,
	   			     p_db_pdtv_rec	 => l_db_pdtv_rec,
					 p_pdtv_rec		 => l_pdtv_rec,
					 x_return_status => l_return_status);

       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN

		    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
		    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		        RAISE Okl_Api.G_EXCEPTION_ERROR;
		    END IF;

       	  RAISE Okl_Api.G_EXCEPTION_ERROR;

       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;



       /* check the changes for product pricing template*/
-- Start of wraper code generated automatically by Debug code generator for Okl_Setup_Prd_Prctempl_Pub.check_product_constraints
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Setup_Prd_Prctempl_Pub.check_product_constraints ');
    END;
  END IF;


	  Okl_Setup_Prd_Prctempl_Pub.check_product_constraints(

	   						       p_api_version      => p_api_version,
								   p_init_msg_list    => p_init_msg_list,
								   x_return_status    => l_return_status,
								   x_msg_count        => x_msg_count,
								   x_msg_data         => x_msg_data,
								   p_pdtv_rec         => l_pdtv_rec,
								   x_validated            => l_validated);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Setup_Prd_Prctempl_Pub.check_product_constraints ');
    END;

  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Setup_Prd_Prctempl_Pub.check_product_constraints
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;



	   /* public api to update formulae */
-- Start of wraper code generated automatically by Debug code generator for Okl_Products_Pub.update_products
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSPDB.pls call Okl_Products_Pub.update_products ');
    END;
  END IF;


 IF nvl(l_upd_pdtv_rec.ptl_id,Okl_Api.G_MISS_num) = Okl_Api.G_MISS_num THEN
    l_upd_pdtv_rec.ptl_id := l_db_pdtv_rec.ptl_id;
 end if;

 IF nvl(l_upd_pdtv_rec.aes_id,Okl_Api.G_MISS_num) = Okl_Api.G_MISS_num THEN
    l_upd_pdtv_rec.aes_id := l_db_pdtv_rec.aes_id;
 end if;

--rkuttiya added condition for reporting product id
/* Following is not required as user should be able to unassign reporting product.
   -- racheruv .. bug 7159594
-- 12.1.1. Multi GAAP Project
 IF nvl(l_upd_pdtv_rec.reporting_pdt_id,Okl_Api.G_MISS_num) = Okl_Api.G_MISS_num
THEN
    l_upd_pdtv_rec.reporting_pdt_id := l_db_pdtv_rec.reporting_pdt_id;
  END IF;
--
*/

    -- updates not allowed when the product is in pending approval status.
    IF l_db_pdtv_rec.ptl_id <> l_upd_pdtv_rec.ptl_id or
         l_db_pdtv_rec.aes_id <> l_upd_pdtv_rec.aes_id OR
         --racheruv added for 12.1.1 Multi GAAP Project Bug 7159594
         nvl(l_db_pdtv_rec.reporting_pdt_id, -1) <> l_upd_pdtv_rec.reporting_pdt_id THEN


       l_upd_pdtv_rec.product_status_code := 'INVALID';

    END IF;



       Okl_Products_Pub.update_products(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_pdtv_rec      => l_upd_pdtv_rec,

                              		 	x_pdtv_rec      => x_pdtv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSPDB.pls call Okl_Products_Pub.update_products ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Products_Pub.update_products
       IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
       ELSIF l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

       /* update constraints */
	   /*copy_update_constraints(p_api_version     => p_api_version,
                               p_init_msg_list   => p_init_msg_list,
                               p_upd_pdtv_rec	 => l_upd_pdtv_rec,
	   			               p_db_pdtv_rec	 => l_db_pdtv_rec,
					           p_pdtv_rec		 => l_pdtv_rec,
                               p_flag            => G_UPDATE,
                               x_return_status   => l_return_status,
                    		   x_msg_count       => x_msg_count,
                               x_msg_data        => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;*/

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
  END update_products;
END Okl_Setupproducts_Pvt;

/
