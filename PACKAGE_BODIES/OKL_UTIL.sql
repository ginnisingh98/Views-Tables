--------------------------------------------------------
--  DDL for Package Body OKL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UTIL" AS
 /* $Header: OKLRUTLB.pls 120.7.12010000.3 2008/11/17 06:24:01 kkorrapo ship $ */



 ----------------------------------------------------------------------------
      --Get country FOR before active line
 ----------------------------------------------------------------------------

 FUNCTION get_preactive_line_inst
  (p_financial_line IN NUMBER)
  RETURN VARCHAR2 IS

 CURSOR c_install_site ( p_k_financial_line NUMBER)IS
 SELECT party_site_uses.country
      FROM
      OKC_K_LINES_B FREEFORM2_CLE,
      OKC_LINE_STYLES_B FREEFORM2_LSE,
      OKC_K_LINES_B INSTITEM_CLE,
      OKC_LINE_STYLES_B INSTITEM_LSE,
      OKL_TXL_ITM_INSTS OTITM ,
      OKX_PARTY_SITE_USES_V PARTY_SITE_USES,
      OKX_COUNTRIES_V   OKX_COUNTRY
      WHERE party_site_uses.country = okx_country.id1
      AND party_site_uses.site_use_type = 'INSTALL_AT'
      AND  PARTY_SITE_USES.ID1 = OTITM.object_id1_new       -- location
       AND OTITM.OBJECT_ID2_NEW = PARTY_SITE_USES.ID2
      AND OTITM.jtot_object_code_new = 'OKX_PARTSITE'
      AND  INSTITEM_CLE.ID = OTITM.KLE_ID
      AND INSTITEM_CLE.CLE_ID = FREEFORM2_CLE.ID
      AND INSTITEM_CLE.LSE_ID = INSTITEM_LSE.ID
      AND INSTITEM_LSE.lty_code = 'INST_ITEM'
      AND FREEFORM2_CLE.CLE_ID = p_k_financial_line
      AND FREEFORM2_CLE.LSE_ID = FREEFORM2_LSE.ID
      AND FREEFORM2_LSE.lty_code = 'FREE_FORM2'   ;


      l_country_code OKX_COUNTRIES_V.id1%TYPE;

    BEGIN


    OPEN c_install_site(p_financial_line);
    FETCH c_install_site INTO l_country_code;
    CLOSE c_install_site;

    RETURN(l_country_code);


 End get_preactive_line_inst;



 ----------------------------------------------------------------------------
      --   --Get country FOR after active line
 ----------------------------------------------------------------------------

  FUNCTION get_active_line_inst_country
  (p_financial_line IN NUMBER)
  RETURN VARCHAR2 IS

 CURSOR c_install_site ( p_k_financial_line NUMBER)IS
     select PARTY_SITES_USES.country
    from
 OKC_K_LINES_B instance_CLE,
 OKC_LINE_STYLES_B instance_LS,
 OKC_K_LINES_B IB_CLE,
 OKC_LINE_STYLES_B IB_LS,
  CSI_ITEM_INSTANCES INSTALL_BASE,
  OKC_K_ITEMS INSTANCE_ITEM,
  HZ_PARTY_SITES PARTY_SITES,
  OKX_PARTY_SITE_USES_V PARTY_SITES_USES
 WHERE
  PARTY_SITES_USES.site_use_type = 'INSTALL_AT'
 AND PARTY_SITES_USES.PARTY_SITE_ID = PARTY_SITES.PARTY_SITE_ID
 AND  PARTY_SITES.PARTY_SITE_ID = INSTALL_BASE.INSTALL_LOCATION_ID
 AND INSTALL_BASE.INSTALL_LOCATION_TYPE_CODE = 'HZ_PARTY_SITES' -- Fix for Canon bug 3551010
 AND INSTALL_BASE.instance_id = INSTANCE_ITEM.object1_id1  AND --Fix for 3837619
   '#' = INSTANCE_ITEM.object1_id2 AND
 INSTANCE_ITEM.CLE_ID = IB_CLE.ID
 and IB_LS.LTY_CODE = 'INST_ITEM'
 AND IB_LS.ID = IB_CLE.LSE_ID
 AND IB_CLE.cle_id = instance_CLE.ID
 AND instance_LS.LTY_CODE = 'FREE_FORM2'
 AND instance_LS.ID = instance_CLE.LSE_ID
 AND instance_CLE.cle_id = p_k_financial_line
union
 select HZ_LOCATIONS.country
          from
       OKC_K_LINES_B instance_CLE,
       OKC_LINE_STYLES_B instance_LS,
       OKC_K_LINES_B IB_CLE,
       OKC_LINE_STYLES_B IB_LS,
        CSI_ITEM_INSTANCES INSTALL_BASE,
        OKC_K_ITEMS INSTANCE_ITEM,
        HZ_LOCATIONS HZ_LOCATIONS
       WHERE
      HZ_LOCATIONS.LOCATION_ID = INSTALL_BASE.INSTALL_LOCATION_ID
       AND INSTALL_BASE.INSTALL_LOCATION_TYPE_CODE = 'HZ_LOCATIONS' -- Fix for Canon bug 3551010
       AND INSTALL_BASE.instance_id = INSTANCE_ITEM.object1_id1  AND --Fix for Bug 3837619
         '#' = INSTANCE_ITEM.object1_id2 AND
       INSTANCE_ITEM.CLE_ID = IB_CLE.ID
       and IB_LS.LTY_CODE = 'INST_ITEM'
       AND IB_LS.ID = IB_CLE.LSE_ID
       AND IB_CLE.cle_id = instance_CLE.ID
       AND instance_LS.LTY_CODE = 'FREE_FORM2'
       AND instance_LS.ID = instance_CLE.LSE_ID
      AND instance_CLE.cle_id = p_k_financial_line   ;


      l_country_code OKX_COUNTRIES_V.id1%TYPE;



    BEGIN


    OPEN c_install_site(p_financial_line);
    FETCH c_install_site INTO l_country_code;
    CLOSE c_install_site;

    RETURN(l_country_code);


 End get_active_line_inst_country;











 ---------------------------------------------------------------------

 ---Get Record Status
 ---------------------------------------------------------------------
 FUNCTION get_rec_status (p_start_date IN DATE, p_end_date IN DATE)
 RETURN VARCHAR2 IS

   lv_sysdate DATE := TRUNC(SYSDATE);

   BEGIN

     IF TRUNC(p_start_date) <= lv_sysdate AND NVL(TRUNC(p_end_date),
 lv_sysdate) >= lv_sysdate THEN
       RETURN 'ACTIVE';
      ELSIF TRUNC(p_start_date) > lv_sysdate THEN
        RETURN  'FUTURE';
      ELSIF TRUNC(p_end_date) < lv_sysdate THEN
       RETURN  'EXPIRED';
     ELSE
       RETURN 'UNKNOWN';
     END IF;

  END get_rec_status;


---------------------------------------------------------
 FUNCTION check_from_to_number_range(p_from_number IN NUMBER ,p_to_number IN  NUMBER  ) RETURN VARCHAR2 IS
       x_return_status		VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         IF (p_from_number IS  NULL) OR (p_to_number  IS NULL) THEN
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
		 ELSE
             IF (p_to_number < p_from_number) THEN
                x_return_status := Okc_Api.G_RET_STS_ERROR;
             END IF;
         END IF;
         RETURN (x_return_status);
        EXCEPTION
           WHEN OTHERS THEN
                x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
                RETURN(x_return_status);
 END check_from_to_number_range;
---------------------------------------------------------------------------
  -- Lookup Code Validation
---------------------------------------------------------------------------
FUNCTION check_lookup_code(p_lookup_type IN VARCHAR2,
                            p_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS
  x_return_status VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;
  l_sysdate   DATE  := SYSDATE ;
  l_dummy_var         VARCHAR2(1) := '?';
  CURSOR l_lookup_code_csr IS
          SELECT 'X'
          FROM   fnd_lookups fndlup
          WHERE  fndlup.lookup_type = p_lookup_type
          AND    fndlup.lookup_code = p_lookup_code
          AND    l_sysdate BETWEEN
                         NVL(fndlup.start_date_active,l_sysdate)
                         AND NVL(fndlup.end_date_active,l_sysdate);
 BEGIN
   OPEN l_lookup_code_csr;
   FETCH l_lookup_code_csr INTO l_dummy_var;
   CLOSE l_lookup_code_csr;
 -- if l_dummy_var still set to default, data was not found
   IF (l_dummy_var = '?') THEN
     -- notify caller of an error
        x_return_status := Okl_Api.G_RET_STS_ERROR;
   END IF;
      RETURN (x_return_status);
  EXCEPTION
   WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
	 -- verify that cursor was closed
      IF l_lookup_code_csr%ISOPEN THEN
       CLOSE l_lookup_code_csr;
      END IF;
      RETURN(x_return_status);
END check_lookup_code;

----------------------------------------------------------------------------
 FUNCTION check_domain_yn(p_col_value IN VARCHAR2)RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      IF (p_col_value  IS NULL)OR (p_col_value = OKC_API.G_MISS_CHAR) THEN
          x_return_status:=Okl_Api.G_RET_STS_ERROR;
	  ELSE
	     IF UPPER(p_col_value) NOT IN('Y','N') THEN
         	x_return_status:=Okl_Api.G_RET_STS_ERROR;
      	END IF;
      END IF;
    RETURN (x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
           x_return_status:=Okl_Api.G_RET_STS_UNEXP_ERROR;
	       RETURN (x_return_status);
  END check_domain_yn;
 ---------------------------------------------------------------------------
 FUNCTION check_domain_amount (p_col_value IN NUMBER)
   RETURN VARCHAR2 IS
    x_return_status VARCHAR2(1):= Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
     IF (p_col_value IS  NULL) OR  (p_col_value = Okl_Api.G_MISS_NUM) THEN
           x_return_status:=Okl_Api.G_RET_STS_ERROR;
		 --check in domain
	ELSE
		 IF p_col_value < 0 THEN
		     	x_return_status:=Okl_Api.G_RET_STS_ERROR;
		END IF;
     END IF;
       RETURN (x_return_status);
   EXCEPTION
     WHEN OTHERS THEN
          -- notify  UNEXPECTED error
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        RETURN (x_return_status);
   END check_domain_amount;
   ---------------------------------------------------------------------
 FUNCTION check_from_to_date_range(p_from_date IN DATE,p_to_date IN DATE  )
   RETURN VARCHAR2 IS
     x_return_status		VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     BEGIN
       IF p_from_date IS NOT NULL AND
          p_to_date IS NOT NULL THEN
           IF p_to_date < p_from_date THEN
              x_return_status :=Okl_Api.G_RET_STS_ERROR;
           END IF;
       ELSIF (p_from_date IS NULL) AND
	     (p_to_date IS NOT NULL) THEN
      	        x_return_status :=Okl_Api.G_RET_STS_ERROR;
       END IF;
       RETURN (x_return_status);
      EXCEPTION
         WHEN OTHERS THEN
              x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
             RETURN(x_return_status);
  END check_from_to_date_range;




  FUNCTION check_org_id (
          p_org_id        IN VARCHAR2,
          p_null_allowed  IN VARCHAR2 DEFAULT 'Y')
          RETURN          VARCHAR2 IS

          l_result        VARCHAR2(1)     := Okl_Api.G_RET_STS_SUCCESS;
          l_select_result VARCHAR2(1)     := '?';
          l_sysdate       DATE            := SYSDATE;

          CURSOR C1 IS
                  SELECT  'S'
                  FROM    hr_all_organization_units hou -- gboomina modified for Bug 6691305
                  WHERE   hou.organization_id = TO_NUMBER(p_org_id)
                  AND     l_sysdate BETWEEN NVL (hou.date_from, l_sysdate)
                                    AND     NVL (hou.date_to,   l_sysdate);

    BEGIN

          IF NVL (p_null_allowed, 'N') <> 'Y' AND p_org_id IS NULL THEN
                  l_result := Okl_Api.G_RET_STS_UNEXP_ERROR;
          END IF;

          IF p_org_id IS NOT NULL THEN
                  OPEN    C1;
                  FETCH   C1 INTO l_select_result;
                  CLOSE   C1;
                  IF l_select_result ='?' THEN
                             l_result := Okl_Api.G_RET_STS_ERROR;
                  END IF;
          END IF;

          RETURN (l_result);

    EXCEPTION
          WHEN OTHERS THEN
                  l_result:=Okl_Api.G_RET_STS_UNEXP_ERROR;
                  IF C1%ISOPEN THEN
                          CLOSE C1;
                  END IF;
                  RETURN l_result;

  END check_org_id;

--Bug 7022258-Added by kkorrapo
FUNCTION get_next_seq_num(
 	            p_seq_name           IN VARCHAR2,
 	            p_table_name         IN VARCHAR2,
 	            p_col_name           IN VARCHAR2)
 	   RETURN VARCHAR2
 	   IS
 	     l_next_val          NUMBER;
 	     l_col_value         VARCHAR2(150);
 	     l_seq_stmt          VARCHAR2(100);
 	     l_query_stmt        VARCHAR2(100);
 	     TYPE l_csr_typ IS REF CURSOR;
 	     l_ref_csr l_csr_typ;
 	     CURSOR c_get_prefix(c_table_name IN VARCHAR2) IS
 	     SELECT DECODE(c_table_name,'OKL_LEASE_QUOTES_B',LSEQTE_SEQ_PREFIX_TXT,'OKL_QUICK_QUOTES_B',QCKQTE_SEQ_PREFIX_TXT,'OKL_LEASE_OPPORTUNITIES_B',LSEOPP_SEQ_PREFIX_TXT,'OKL_LEASE_APPLICATIONS_B',LSEAPP_SEQ_PREFIX_TXT)
 	     FROM okl_system_params;
 	     l_prefix VARCHAR2(30);
 	     l_value  VARCHAR(250);
 	   BEGIN
 	     l_next_val   := 0;
 	     l_seq_stmt   := 'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL';
 	     l_query_stmt := 'SELECT ' ||
 	                     p_col_name ||
 	                     ' FROM ' ||
 	                     p_table_name ||
 	                     ' WHERE '||
 	                     p_col_name || ' = :1 ';
 	     --get prefix
 	     OPEN c_get_prefix(p_table_name);
 	     FETCH c_get_prefix INTO l_prefix;
 	     CLOSE c_get_prefix;

 	     LOOP
 	       --Execute the dynamic sql for obtaining next value of sequence
 	       OPEN l_ref_csr FOR l_seq_stmt;
 	       FETCH l_ref_csr INTO l_next_val;
 	         IF l_ref_csr%NOTFOUND THEN
 	           EXIT;
 	         END IF;
 	       CLOSE l_ref_csr;


 	       IF l_prefix IS NOT NULL THEN
 	        l_value := l_prefix || TO_CHAR(l_next_val);
 	       ELSE
 	        l_value := TO_CHAR(l_next_val);
 	       END IF;

 	       --Execute the dynamic sql for validating uniqueness of the next value from sequence
 	       OPEN l_ref_csr FOR l_query_stmt USING l_value;
 	       FETCH l_ref_csr INTO l_col_value;
 	         IF l_ref_csr%NOTFOUND THEN
 	           EXIT;
 	         END IF;
 	       CLOSE l_ref_csr;
 	     END LOOP;
 	     RETURN l_value;
 	   EXCEPTION
 	     WHEN OTHERS
 	     THEN
 	       IF l_ref_csr%ISOPEN
 	       THEN
 	         CLOSE l_ref_csr;
 	       END IF;
 	       RETURN 0;
 	   END get_next_seq_num;
 	  FUNCTION validate_seq_num(
 	            p_seq_name           IN VARCHAR2,
 	            p_table_name         IN VARCHAR2,
 	            p_col_name           IN VARCHAR2,
 	            p_value              IN VARCHAR2)
 	   RETURN varchar2
 	   IS
 	     l_col_value         VARCHAR2(150);
 	     l_query_stmt        VARCHAR2(100);
 	     TYPE l_csr_typ IS REF CURSOR;
 	     l_ref_csr l_csr_typ;
 	     CURSOR c_get_prefix(c_table_name IN VARCHAR2) IS
 	     SELECT DECODE(c_table_name,'OKL_LEASE_QUOTES_B',LSEQTE_SEQ_PREFIX_TXT,'OKL_QUICK_QUOTES_B',QCKQTE_SEQ_PREFIX_TXT,'OKL_LEASE_OPPORTUNITIES_B',LSEOPP_SEQ_PREFIX_TXT,'OKL_LEASE_APPLICATIONS_B',LSEAPP_SEQ_PREFIX_TXT)
 	     FROM okl_system_params;
 	     l_prefix VARCHAR2(30);
 	   BEGIN
 	     l_query_stmt := 'SELECT ' ||
 	                     p_col_name ||
 	                     ' FROM ' ||
 	                     p_table_name ||
 	                     ' WHERE '||
 	                     p_col_name || ' = :1 ';
 	     --get prefix
 	     OPEN c_get_prefix(p_table_name);
 	     FETCH c_get_prefix INTO l_prefix;
 	     CLOSE c_get_prefix;

 	       IF l_prefix IS NOT NULL THEN
 	        IF INSTR(p_value,l_prefix) <> 1 THEN
 	         okl_api.set_message(p_app_name     =>             g_app_name
 	                          ,p_msg_name     =>             'OKL_NO_PREFIX'
 	                          ,p_token1       =>             'COL_NAME'
 	                          ,p_token1_value =>            p_value
 	                          ,p_token2       =>             'PREFIX'
 	                          ,p_token2_value =>            l_prefix);
 	         RETURN 'N';
 	        END IF;
 	       END IF;

 	       --Execute the dynamic sql for validating uniqueness of the next value from sequence
 	       OPEN l_ref_csr FOR l_query_stmt USING p_value;
 	       FETCH l_ref_csr INTO l_col_value;
 	         IF l_ref_csr%NOTFOUND THEN
 	           CLOSE l_ref_csr;
 	           RETURN 'Y';
 	         ELSE
 	           CLOSE l_ref_csr;
 	            okl_api.set_message(p_app_name     =>             g_app_name
 	                          ,p_msg_name     =>             'OKL_DUPLICATE_CURE_REQUEST'
 	                          ,p_token1       =>             'COL_NAME'
 	                          ,p_token1_value =>            p_value);
 	           RETURN 'N';
 	         END IF;
 	   EXCEPTION
 	     WHEN OTHERS
 	     THEN
 	       IF l_ref_csr%ISOPEN
 	       THEN
 	         CLOSE l_ref_csr;
 	       END IF;
 	       RETURN 0;
 	   END validate_seq_num;
 --Bug 7022258--Addition end

END Okl_Util;

/
