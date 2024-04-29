--------------------------------------------------------
--  DDL for Package Body OKL_IPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IPT_PVT" AS
/* $Header: OKLSIPTB.pls 120.6 2007/11/06 11:16:02 ssdeshpa noship $ */
  ---------------------------------------------------------------------------
    -- FUNCTION get_seq_id
    ---------------------------------------------------------------------------
    FUNCTION get_seq_id RETURN NUMBER IS
    BEGIN
      RETURN(okc_p_util.raw_to_number(sys_guid()));
    END get_seq_id;
    ---------------------------------------------------------------------------
    -- PROCEDURE qc
    ---------------------------------------------------------------------------
    PROCEDURE qc IS
    BEGIN
      null;
    END qc;
    ---------------------------------------------------------------------------
    -- PROCEDURE change_version
    ---------------------------------------------------------------------------
    PROCEDURE change_version IS
    BEGIN
      null;
    END change_version;
    ---------------------------------------------------------------------------
    -- PROCEDURE api_copy
    ---------------------------------------------------------------------------
    PROCEDURE api_copy IS
    BEGIN
      null;
    END api_copy;
    ---------------------------------------------------------------------------
    -- PROCEDURE add_language
    ---------------------------------------------------------------------------
    PROCEDURE add_language IS
    BEGIN
      DELETE FROM OKL_INS_PRODUCTS_TL T
       WHERE NOT EXISTS (
          SELECT NULL
            FROM OKL_INS_PRODUCTS_B B
           WHERE B.ID = T.ID
          );
      UPDATE OKL_INS_PRODUCTS_TL T SET (
          NAME,
          FACTOR_NAME) = (SELECT
                                    B.NAME,
                                    B.FACTOR_NAME
                                  FROM OKL_INS_PRODUCTS_TL B
                                 WHERE B.ID = T.ID
                                   AND B.LANGUAGE = T.SOURCE_LANG)
        WHERE (
                T.ID,
                T.LANGUAGE)
            IN (SELECT
                    SUBT.ID,
                    SUBT.LANGUAGE
                  FROM OKL_INS_PRODUCTS_TL SUBB, OKL_INS_PRODUCTS_TL SUBT
                 WHERE SUBB.ID = SUBT.ID
                   AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                   AND (SUBB.NAME <> SUBT.NAME
                        OR SUBB.FACTOR_NAME <> SUBT.FACTOR_NAME
                        OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                        OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                        OR (SUBB.FACTOR_NAME IS NULL AND SUBT.FACTOR_NAME IS NOT NULL)
                        OR (SUBB.FACTOR_NAME IS NOT NULL AND SUBT.FACTOR_NAME IS NULL)
                ));
      INSERT INTO OKL_INS_PRODUCTS_TL (
          ID,
          LANGUAGE,
          SOURCE_LANG,
          SFWT_FLAG,
          NAME,
          FACTOR_NAME,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
        SELECT
              B.ID,
              L.LANGUAGE_CODE,
              B.SOURCE_LANG,
              B.SFWT_FLAG,
              B.NAME,
              B.FACTOR_NAME,
              B.CREATED_BY,
              B.CREATION_DATE,
              B.LAST_UPDATED_BY,
              B.LAST_UPDATE_DATE,
              B.LAST_UPDATE_LOGIN
          FROM OKL_INS_PRODUCTS_TL B, FND_LANGUAGES L
         WHERE L.INSTALLED_FLAG IN ('I', 'B')
           AND B.LANGUAGE = USERENV('LANG')
           AND NOT EXISTS(
                      SELECT NULL
                        FROM OKL_INS_PRODUCTS_TL T
                       WHERE T.ID = B.ID
                         AND T.LANGUAGE = L.LANGUAGE_CODE
                      );
    END add_language;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Duplicates
    ---------------------------------------------------------------------------
      PROCEDURE validate_duplicates(
        p_iptv_rec          IN iptv_rec_type,
        x_return_status 	OUT NOCOPY VARCHAR2) IS
        l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_dummy_var VARCHAR2(1) := '?';
    CURSOR l_iptv_csr IS
    SELECT 'x'
    FROM   okl_ins_products_v
    WHERE  trunc(date_from) = trunc(p_iptv_rec.date_from)
    AND    ipd_id = p_iptv_rec.ipd_id
    AND    ipt_type = p_iptv_rec.ipt_type
    AND    name = p_iptv_rec.name
    AND    ID <> p_iptv_rec.id;
      BEGIN
    	OPEN l_iptv_csr;
    	FETCH l_iptv_csr INTO l_dummy_var;
    	CLOSE l_iptv_csr;
    -- if l_dummy_var is still set to default, data was not found
       IF (l_dummy_var = 'x') THEN
          OKC_API.set_message(p_app_name 	    => G_APP_NAME,
  	                    p_msg_name      => 'OKL_UNIQUE'
  			    );
          l_return_status := Okc_Api.G_RET_STS_ERROR;
       END IF;
        x_return_status := l_return_status;
      EXCEPTION
         WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_duplicates;

    ---------------------------------------------------------------------------
   -- PROCEDURE Validate_factor_range
   ---------------------------------------------------------------------------
      PROCEDURE validate_factor_range(
        p_iptv_rec          IN iptv_rec_type,
        x_return_status 	OUT NOCOPY VARCHAR2) IS
        l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_dummy_var VARCHAR2(1) := '?';

    --#5222364 the below cursor was checking for overlap issue but was
    --  skipping between condition.
    --Fixed Bug #6436237 ssdeshpa MOAC Issues Changing Cursor start
    CURSOR l_iptv_lease_csr IS
         SELECT 'x'
         FROM   OKL_INS_PRODUCTS_B IPTB
              , OKX_SYSTEM_ITEMS_V OSI
              , OKL_SYSTEM_PARAMS SYSOP
         WHERE ( p_iptv_rec.factor_min BETWEEN IPTB.factor_min and IPTB.factor_max
                   or  p_iptv_rec.factor_max BETWEEN IPTB.factor_min and IPTB.factor_max
            )
         AND IPTB.IPD_ID = OSI.ID1
         AND OSI.ID2 = SYSOP.ITEM_INV_ORG_ID
         AND ipt_type = p_iptv_rec.ipt_type
     	 AND isu_id = p_iptv_rec.isu_id
         AND SYSDATE < NVL(DATE_TO,SYSDATE+1);
       --Fixed Bug #6436237 ssdeshpa MOAC Issues Changing Cursor End

      BEGIN


         OPEN l_iptv_lease_csr;
	 FETCH l_iptv_lease_csr INTO l_dummy_var;
    	 CLOSE l_iptv_lease_csr;

    -- if l_dummy_var is still set to default, data was not found
       IF (l_dummy_var = 'x') THEN
          /*
          OKC_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name =>'OKL_IPT_RANGE_OVERLAP'
                              );
                              */
          l_return_status := Okc_Api.G_RET_STS_ERROR;
       END IF;
        x_return_status := l_return_status;
      EXCEPTION
         WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR ,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_factor_range;

     ---------------------------------------------------------------------------
     -- PROCEDURE Validate_System_Item
     ---------------------------------------------------------------------------
        PROCEDURE validate_system_item(
          p_iptv_rec          IN iptv_rec_type,
          x_return_status     OUT NOCOPY VARCHAR2) IS
          l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
          l_dummy_var VARCHAR2(1) := '?';
          l_date_active_from  DATE;
          l_date_active_to    DATE;
          l_status	VARCHAR2(1);

      CURSOR l_sit_csr IS
      SELECT Status,START_DATE_ACTIVE,end_date_active
      FROM   okx_system_items_v
      WHERE  ID1 = p_iptv_rec.ipd_id;


      CURSOR l_sit_csr2 IS
      SELECT 'X'
      FROM   okx_system_items_v
      WHERE  ID1 = p_iptv_rec.ipd_id
      and NVL(Status,'I') = 'A';

        BEGIN
      	OPEN l_sit_csr;
      	FETCH l_sit_csr INTO l_status,l_date_active_from,l_date_active_to;
      	CLOSE l_sit_csr;

          OPEN l_sit_csr2;
      	FETCH l_sit_csr2 INTO l_dummy_var;
      	CLOSE l_sit_csr2;

          IF (l_dummy_var ='?') THEN

           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;
       EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     -- store SQL error message on message stack for caller
                     x_return_status := Okc_Api.G_RET_STS_ERROR;
               WHEN OTHERS THEN
                    -- store SQL error message on message stack for caller
                   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                    -- notify caller of an UNEXPECTED error
                   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                   -- verify that cursor was closed
             	IF l_sit_csr%ISOPEN THEN
             	 CLOSE l_sit_csr;
             	END IF;
                  IF l_sit_csr2%ISOPEN THEN
             	  CLOSE l_sit_csr2;
             	END IF;
    END validate_system_item;


    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_id
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure validate_ipt_id(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           -- data is required
           IF (p_iptv_rec.id = OKC_API.G_MISS_NUM) OR (p_iptv_rec.id IS NULL)
           THEN
             OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'id');
             -- Notify caller of  an error
             l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
             x_return_status := l_return_status;
          EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_id;
    ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_ipt_factor_min
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_ipt_factor_min(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       BEGIN
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
         --data is required
         IF p_iptv_rec.factor_min = Okc_Api.G_MISS_NUM OR p_iptv_rec.factor_min IS NULL
         THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
                               p_msg_name       => 'OKL_REQUIRED_VALUE',
                               p_token1         => G_COL_NAME_TOKEN,
                               p_token1_value   => 'Factor Minimum');
           -- Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
         ELSE
  	    x_return_status  := Okl_Util.check_domain_amount(p_iptv_rec.factor_min);
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
  	   	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                        p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                        p_token1             => G_COL_NAME_TOKEN,
  		   	                        p_token1_value       => 'Factor Minimum'
  		   	                                  );
  		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
       	        END IF;
         END IF;
         EXCEPTION
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_factor_min;
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_ipt_factor_max
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_ipt_factor_max(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       BEGIN
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
         --data is required
         IF p_iptv_rec.factor_max = Okc_Api.G_MISS_NUM OR
            p_iptv_rec.factor_max IS NULL
         THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
                               p_msg_name       => 'OKL_REQUIRED_VALUE',
                               p_token1         => G_COL_NAME_TOKEN,
                               p_token1_value   => 'Factor Maximum');
           -- Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
         ELSE
  	x_return_status  := Okl_Util.check_domain_amount(p_iptv_rec.factor_max);
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
  	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                                  p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                                  p_token1             => G_COL_NAME_TOKEN,
  		   	                                  p_token1_value       => 'Factor Maximum'
  		   	                                  );
  			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
       	        END IF;
         END IF;
         EXCEPTION
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_factor_max;
     ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_ipt_coverage_min
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_ipt_coverage_min(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       BEGIN
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
         --data is required
         IF p_iptv_rec.coverage_min = Okc_Api.G_MISS_NUM
         THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
                               p_msg_name       => 'OKL_REQUIRED_VALUE',
                               p_token1         => G_COL_NAME_TOKEN,
                               p_token1_value   => 'Coverage Minimum');
           -- Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
         IF (p_iptv_rec.coverage_min IS NOT NULL) THEN
  	    x_return_status  := Okl_Util.check_domain_amount(p_iptv_rec.coverage_min);
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
  	   	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                        p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                        p_token1             => G_COL_NAME_TOKEN,
  		   	                        p_token1_value       => 'Coverage Minimum'
  		   	                                  );
  		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
       	        END IF;
                  END IF;
         END IF;
         EXCEPTION
             WHEN G_EXCEPTION_HALT_VALIDATION THEN
               null;
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_coverage_min;
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_ipt_coverage_max
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_ipt_coverage_max(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       BEGIN
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
         --data is required
         IF p_iptv_rec.coverage_max = Okc_Api.G_MISS_NUM
         THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
                               p_msg_name       => 'OKL_REQUIRED_VALUE',
                               p_token1         => G_COL_NAME_TOKEN,
                               p_token1_value   => 'Coverage Maximum');
           -- Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
         IF (p_iptv_rec.coverage_max IS NOT NULL) THEN
  	x_return_status  := Okl_Util.check_domain_amount(p_iptv_rec.coverage_max);
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
  	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                                  p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                                  p_token1             => G_COL_NAME_TOKEN,
  		   	                                  p_token1_value       => 'Coverage Maximum'
  		   	                                  );
  			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
       	        END IF;
           END IF;
         END IF;
         EXCEPTION
           WHEN G_EXCEPTION_HALT_VALIDATION THEN
               null;
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_coverage_max;

     ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_ipt_deal_months_min
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_ipt_deal_months_min(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       BEGIN
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
         --data is required
         IF p_iptv_rec.deal_months_min = Okc_Api.G_MISS_NUM
         THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
                               p_msg_name       => 'OKL_REQUIRED_VALUE',
                               p_token1         => G_COL_NAME_TOKEN,
                               p_token1_value   => 'Deal Months Minimum');
           -- Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
          IF (p_iptv_rec.deal_months_min IS NOT NULL) THEN
  	    x_return_status  := Okl_Util.check_domain_amount(p_iptv_rec.deal_months_min);
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
  	   	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                        p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                        p_token1             => G_COL_NAME_TOKEN,
  		   	                        p_token1_value       => 'Deal Months Minimum'
  		   	                                  );
  		ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          END IF;
         END IF;
         EXCEPTION
           WHEN G_EXCEPTION_HALT_VALIDATION THEN
               null;
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_deal_months_min;
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_ipt_deal_months_max
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_ipt_deal_months_max(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       BEGIN
         --initialize the  return status
         x_return_status := Okc_Api.G_RET_STS_SUCCESS;
         --data is required
         IF p_iptv_rec.deal_months_max = Okc_Api.G_MISS_NUM
         THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
                               p_msg_name       => 'OKL_REQUIRED_VALUE',
                               p_token1         => G_COL_NAME_TOKEN,
                               p_token1_value   => 'Deal Months Maximum');
           -- Notify caller of  an error
           x_return_status := Okc_Api.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
         IF (p_iptv_rec.deal_months_min IS NOT NULL) THEN
  	    x_return_status  := Okl_Util.check_domain_amount(p_iptv_rec.deal_months_max);
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
  	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                                  p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                                  p_token1             => G_COL_NAME_TOKEN,
  		   	                                  p_token1_value       => 'Deal Months Maximum'
  		   	                                  );
  			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
       	        END IF;
                  END IF;
         END IF;
         EXCEPTION
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
               null;
            WHEN OTHERS THEN
              -- store SQL error  message on message stack for caller
  	    Okc_Api.set_message(p_app_name => G_APP_NAME,
  				    p_msg_name => G_UNEXPECTED_ERROR,
  				    p_token1 => G_SQLCODE_TOKEN,
  				    p_token1_value => SQLCODE,
  				    p_token2 => G_SQLERRM_TOKEN,
  				    p_token2_value => SQLERRM
  			);
              -- Notify the caller of an unexpected error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_deal_months_max;

    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_factor_amount_yn
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
           procedure  validate_ipt_factor_amount_yn(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
                 l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
           Begin
           -- initialize return status
        	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;

        	-- data is required
        	IF p_iptv_rec.factor_amount_yn = Okc_Api.G_MISS_CHAR --[1]
		         THEN
		           Okc_Api.set_message(p_app_name       => G_APP_NAME,
		                               p_msg_name       => 'OKL_REQUIRED_VALUE',
		                               p_token1         => G_COL_NAME_TOKEN,
		                               p_token1_value   => 'Factoramount Flag');
		           -- Notify caller of  an error
		           x_return_status := Okc_Api.G_RET_STS_ERROR;
                    RAISE G_EXCEPTION_HALT_VALIDATION;

                ELSE
                IF (p_iptv_rec.factor_amount_yn IS NOT NULL) THEN --[2]
  	         IF UPPER(p_iptv_rec.factor_amount_yn) NOT IN ('Y','N') THEN  --[3]
		   x_return_status:=OKC_API.G_RET_STS_ERROR;
		   		     --set error message in message stack
		   			OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
		   					p_msg_name     =>  G_INVALID_VALUE,
		   					p_token1       => G_COL_NAME_TOKEN,
		   					p_token1_value => 'FactorAmount Flag');
		   			x_return_status := OKC_API.G_RET_STS_ERROR;
  		 END IF; --[3]
  		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN --[4]
  	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
  		   	                                  p_msg_name           => 'OKL_POSITIVE_NUMBER',
  		   	                                  p_token1             => G_COL_NAME_TOKEN,
  		   	                                  p_token1_value       => 'Factoramount Flag'
  		   	                                  );
  	        ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	        		RAISE G_EXCEPTION_HALT_VALIDATION;
       	        END IF; --[4]
               END IF;--[2]
         END IF;  --[1]

     EXCEPTION
     	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              	-- notify caller of an UNEXPECTED error
              	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           END validate_ipt_factor_amount_yn;


    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_obj_version_num
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_obj_version_num(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
        l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.object_version_number = OKC_API.G_MISS_NUM OR p_iptv_rec.object_version_number IS NULL
           THEN
             OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'object_version_number');
         	-- Notify caller of  an error
    	l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
             x_return_status := l_return_status;
           EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_ipt_obj_version_num;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_ipd_id
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_ipd_id(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
       l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       -- WARNING : Cannot implement until OKX View OKX_SYSTEM_ITEMS_V defined
         l_dummy_var                    VARCHAR2(1) := '?';
       -- select the ID  of the parent  record from the parent table
        CURSOR l_iptv_csr IS
           SELECT 'x'
           FROM okx_system_items_v
           WHERE id1 = p_iptv_rec.ipd_id;
         begin
           --data is required
           IF p_iptv_rec.ipd_id = OKC_API.G_MISS_NUM OR p_iptv_rec.ipd_id IS NULL
           THEN
             OKC_API.set_message(p_app_name       => G_APP_NAME,
                                 p_msg_name       => 'OKL_REQUIRED_VALUE',
                                 p_token1         => G_COL_NAME_TOKEN,
                                 p_token1_value   => 'ipd_id');
            -- Notify caller of  an error
    	l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
             x_return_status := l_return_status;
           -- WARNING : Cannot implement until OKX View OKX_SYSTEM_ITEMS_V defined
           -- enforce foreign key
             OPEN l_iptv_csr;
    	   FETCH l_iptv_csr into l_dummy_var;
             CLOSE l_iptv_csr;
           -- if l_dummy_var is still set to default ,data was not found
             IF (l_dummy_var ='?') THEN
               OKC_API.set_message(p_app_name 	        => G_APP_NAME,
                                   p_msg_name           => G_NO_PARENT_RECORD,
                                   p_token1             => G_COL_NAME_TOKEN,
                                   p_token1_value       => 'ipd_id',
                                   p_token2             => g_child_table_token,
                                   p_token2_value       => 'OKL_INS_PRODUCTS_V',
                                   p_token3             => g_parent_table_token,
                                   p_token3_value       => 'OKX_SYSTEM_ITEMS_V');
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;
          EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         --WARNING : Cannot implement until OKX View OKX_INS_PRDCTS_V defined
                -- Verify  that cursor was closed
                IF l_iptv_csr%ISOPEN THEN
                  CLOSE l_iptv_csr;
                END IF;
      END validate_ipt_ipd_id;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_ipt_type
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_ipt_type(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
        l_dummy_var                    VARCHAR2(1) :='?';
        l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       -- select the ID  of the parent  record from the parent table
        CURSOR l_iptv_csr IS
           SELECT 'x'
           FROM fnd_lookups
           WHERE lookup_code = p_iptv_rec.ipt_type
           AND LOOKUP_TYPE = 'OKL_INSURANCE_PRODUCT_TYPE';
         begin
           --data is required
           IF p_iptv_rec.ipt_type = OKC_API.G_MISS_CHAR OR p_iptv_rec.ipt_type IS NULL
           THEN
           	 OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Insurance Type');

    	  -- Notify caller of  an error
             l_return_status := Okc_Api.G_RET_STS_ERROR;
    	END IF;
            x_return_status := l_return_status;
           -- enforce foreign key
             OPEN l_iptv_csr;
    	   FETCH l_iptv_csr into l_dummy_var;
             CLOSE l_iptv_csr;
           -- if l_dummy_var is still set to default ,data was not found
             IF (l_dummy_var ='?') THEN
               OKC_API.set_message(G_APP_NAME,G_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'Insurance Type',g_child_table_token,'OKL_INS_PRODUCTS_V',g_parent_table_token,'FND_LOOKUPS');

           --notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;
           EXCEPTION
               WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                -- Verify  that cursor was closed
                IF l_iptv_csr%ISOPEN THEN
                  CLOSE l_iptv_csr;
                END IF;
      END validate_ipt_ipt_type;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_name
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_name(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.name = OKC_API.G_MISS_CHAR OR p_iptv_rec.name IS NULL
           THEN

             OKC_API.set_message(p_app_name       => G_APP_NAME,
                                 p_msg_name       => 'OKL_REQUIRED_VALUE',
                                 p_token1         => G_COL_NAME_TOKEN,
                                 p_token1_value   => 'Name');
                    -- Notify caller of  an error
             	l_return_status := Okc_Api.G_RET_STS_ERROR;
             	x_return_status := l_return_status;

    	END IF;

           EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_name;

    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_factor_name
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_factor_name(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.factor_name = OKC_API.G_MISS_CHAR OR p_iptv_rec.factor_name IS NULL
           THEN

             OKC_API.set_message(p_app_name       => G_APP_NAME,
                                 p_msg_name       => 'OKL_REQUIRED_VALUE',
                                 p_token1         => G_COL_NAME_TOKEN,
                                 p_token1_value   => 'Factor Name');
                    -- Notify caller of  an error
             	l_return_status := Okc_Api.G_RET_STS_ERROR;
             	x_return_status := l_return_status;

    	END IF;

           EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_factor_name;

        ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_policy_symbol
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_policy_Symbol(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.policy_symbol = OKC_API.G_MISS_CHAR OR p_iptv_rec.policy_symbol IS NULL
           THEN

             OKC_API.set_message(p_app_name       => G_APP_NAME,
                                 p_msg_name       => 'OKL_REQUIRED_VALUE',
                                 p_token1         => G_COL_NAME_TOKEN,
                                 p_token1_value   => 'Policy Symbol');
                    -- Notify caller of  an error
             	l_return_status := Okc_Api.G_RET_STS_ERROR;
             	x_return_status := l_return_status;
             	-- halt further validation of this column
             	--raise G_EXCEPTION_HALT_VALIDATION;
    	END IF;

           EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_policy_symbol;

              ---------------------------------------------------------------------------
            -- Start of comments
            --
            -- Procedure Name	: validate_ipt_factor_code
            -- Description		:
            -- Business Rules	:
            -- Parameters		:
            -- Version		: 1.0
            -- End of Comments
            ---------------------------------------------------------------------------
               procedure  validate_ipt_factor_code(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
                 l_dummy_var                    VARCHAR2(1) :='?';
                 l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
                 CURSOR l_fact_code_csr IS
  	       SELECT 'x'
  	       FROM fnd_lookups
                 WHERE lookup_code = p_iptv_rec.factor_code
                       AND LOOKUP_TYPE = 'OKL_INSURANCE_FACTOR';
                 begin
                   --data is required
                   IF p_iptv_rec.factor_code = OKC_API.G_MISS_CHAR OR p_iptv_rec.factor_code IS NULL
                   THEN

                     OKC_API.set_message(p_app_name       => G_APP_NAME,
                                         p_msg_name       => 'OKL_REQUIRED_VALUE',
                                         p_token1         => G_COL_NAME_TOKEN,
                                         p_token1_value   => 'Factor Code');
                            -- Notify caller of  an error
                     	l_return_status := Okc_Api.G_RET_STS_ERROR;

                     	-- halt further validation of this column
                     	--raise G_EXCEPTION_HALT_VALIDATION;
            	 END IF;
            	 x_return_status := l_return_status;
            	 -- enforce foreign key
  		   OPEN l_fact_code_csr;
  		   FETCH l_fact_code_csr into l_dummy_var;
  		   CLOSE l_fact_code_csr;
  		-- if l_dummy_var is still set to default ,data was not found
  		 IF (l_dummy_var ='?') THEN
  		   OKC_API.set_message(G_APP_NAME,G_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'Insurance Type',g_child_table_token,'OKL_INS_PRODUCTS_V',g_parent_table_token,'FND_LOOKUPS');

  		 --notify caller of an error
  		   x_return_status := OKC_API.G_RET_STS_ERROR;
                   END IF;

                   EXCEPTION
                      WHEN OTHERS THEN
                        -- store SQL error  message on message stack for caller
                        Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                        -- Notify the caller of an unexpected error
                        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

                      IF l_fact_code_csr%ISOPEN THEN
  		       CLOSE l_fact_code_csr;
                      END IF;
        END validate_ipt_factor_code;



    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_isu_id
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_isu_id(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
        l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       -- WARNING : Cannot implement until OKX View OKX_INS_PROVIDER_V defined
         l_dummy_var                    VARCHAR2(1) := '?';
       -- select the ID  of the parent  record from the parent table

        CURSOR l_iptv_csr IS
           SELECT 'x'
           FROM okx_ins_provider_v
           WHERE party_id = p_iptv_rec.isu_id;

         begin
           --data is required
           IF p_iptv_rec.isu_id = OKC_API.G_MISS_NUM OR p_iptv_rec.isu_id IS NULL
           THEN

            OKC_API.set_message(p_app_name       => G_APP_NAME,
                                 p_msg_name       => 'OKL_REQUIRED_VALUE',
                                 p_token1         => G_COL_NAME_TOKEN,
                                 p_token1_value   => 'Provider');
             --Notify caller of  an error
             l_return_status := Okc_Api.G_RET_STS_ERROR;
    	END IF;
    	x_return_status := l_return_status;
           -- WARNING : Cannot implement until OKX View OKX_INS_PROVIDER_V defined

           -- enforce foreign key
             OPEN l_iptv_csr;
    	   FETCH l_iptv_csr into l_dummy_var;
             CLOSE l_iptv_csr;
           -- if l_dummy_var is still set to default ,data was not found
             IF (l_dummy_var ='?') THEN
               OKC_API.set_message(p_app_name 	        => G_APP_NAME,
                                   p_msg_name           => G_NO_PARENT_RECORD,
                                   p_token1             => G_COL_NAME_TOKEN,
                                   p_token1_value       => 'isu_id',
                                   p_token2             => g_child_table_token,
                                   p_token2_value       => 'OKL_INS_PRODUCTS_V',
                                   p_token3             => g_parent_table_token,
                                   p_token3_value       => 'OKX_INS_PROVIDER_V');
           -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;

          EXCEPTION
             WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                -- Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         --WARNING : Cannot implement until OKX View OKX_INS_PROVIDER_V defined

                -- Verify  that cursor was closed
                IF l_iptv_csr%ISOPEN THEN
                  CLOSE l_iptv_csr;
                END IF;

      END validate_ipt_isu_id;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_created_by
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_created_by(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.created_by = OKC_API.G_MISS_NUM OR  p_iptv_rec.created_by IS NULL
           THEN

             OKC_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_REQUIRED_VALUE',
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'created_by');
             --Notify caller of  an error
    	 l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
    	 x_return_status := l_return_status;
           EXCEPTION
              WHEN OTHERS THEN
                --store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                --Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_created_by;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_creation_date
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_creation_date(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.creation_date = OKC_API.G_MISS_DATE OR p_iptv_rec.creation_date IS NULL
           THEN
           	  OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'creation_date');

             --Notify caller of  an error
     	 l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
    	 x_return_status := l_return_status;
           EXCEPTION
              WHEN OTHERS THEN
                --store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                --Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_creation_date;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_last_updated_by
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_last_updated_by(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        begin
           --data is required
           IF p_iptv_rec.last_updated_by = OKC_API.G_MISS_NUM OR p_iptv_rec.last_updated_by IS NULL
           THEN
             OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'last_updated_by');

             --Notify caller of  an error
              l_return_status := Okc_Api.G_RET_STS_ERROR;
    	END IF;
    	 x_return_status := l_return_status;
          EXCEPTION
              WHEN OTHERS THEN
                --store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                --Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_last_updated_by;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_last_update_date
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_last_update_date(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF p_iptv_rec.last_update_date = OKC_API.G_MISS_DATE OR p_iptv_rec.last_update_date IS NULL
           THEN
             OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'last_update_date');

             --Notify caller of  an error
              l_return_status := Okc_Api.G_RET_STS_ERROR;
    	END IF;
    	 x_return_status := l_return_status;
          EXCEPTION
              WHEN OTHERS THEN
                --store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

                --Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_last_update_date;

        ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_ipt_date_from
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       procedure  validate_ipt_date_from(x_return_status OUT NOCOPY VARCHAR2,p_iptv_rec IN iptv_rec_type ) IS
         l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         begin
           --data is required
           IF (p_iptv_rec.date_from = OKC_API.G_MISS_DATE OR p_iptv_rec.date_from IS NULL)
           THEN
           	  OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Effective From');
             --Notify caller of  an error
     	        l_return_status := Okc_Api.G_RET_STS_ERROR;
              x_return_status := l_return_status ;
              RAISE G_EXCEPTION_HALT_VALIDATION;


            END IF;
    	    x_return_status := l_return_status;
           EXCEPTION
              WHEN G_EXCEPTION_HALT_VALIDATION THEN
              null;
              WHEN OTHERS THEN
                --store SQL error  message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                --Notify the caller of an unexpected error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END validate_ipt_date_from;

    ---------------------------------------------------------------------------
    -- FUNCTION get_rec for: OKL_INS_PRODUCTS_B
    ---------------------------------------------------------------------------
    FUNCTION get_rec (
      p_ipt_rec                      IN ipt_rec_type,
      x_no_data_found                OUT NOCOPY BOOLEAN
    ) RETURN ipt_rec_type IS
      CURSOR okl_ipt_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              ISU_ID,
              IPD_ID,
              IPT_TYPE,
              OBJECT_VERSION_NUMBER,
              POLICY_SYMBOL,
              FACTOR_CODE,
              FACTOR_MAX,
              FACTOR_MIN,
              COVERAGE_MIN,
              COVERAGE_MAX,
              DEAL_MONTHS_MIN,
              DEAL_MONTHS_MAX,
              DATE_FROM,
              DATE_TO,
              FACTOR_AMOUNT_YN,
              ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Ins_Products_B
       WHERE okl_ins_products_b.id = p_id;
      l_okl_ipt_pk                   okl_ipt_pk_csr%ROWTYPE;
      l_ipt_rec                      ipt_rec_type;
    BEGIN
      x_no_data_found := TRUE;
      -- Get current database values
      OPEN okl_ipt_pk_csr (p_ipt_rec.id);
      FETCH okl_ipt_pk_csr INTO
                l_ipt_rec.ID,
                l_ipt_rec.ISU_ID,
                l_ipt_rec.IPD_ID,
                l_ipt_rec.IPT_TYPE,
                l_ipt_rec.OBJECT_VERSION_NUMBER,
                l_ipt_rec.POLICY_SYMBOL,
                l_ipt_rec.FACTOR_CODE,
                l_ipt_rec.FACTOR_MAX,
                l_ipt_rec.FACTOR_MIN,
                l_ipt_rec.COVERAGE_MIN,
                l_ipt_rec.COVERAGE_MAX,
                l_ipt_rec.DEAL_MONTHS_MIN,
                l_ipt_rec.DEAL_MONTHS_MAX,
                l_ipt_rec.DATE_FROM,
                l_ipt_rec.DATE_TO,
                l_ipt_rec.FACTOR_AMOUNT_YN,
                l_ipt_rec.ATTRIBUTE_CATEGORY,
                l_ipt_rec.ATTRIBUTE1,
                l_ipt_rec.ATTRIBUTE2,
                l_ipt_rec.ATTRIBUTE3,
                l_ipt_rec.ATTRIBUTE4,
                l_ipt_rec.ATTRIBUTE5,
                l_ipt_rec.ATTRIBUTE6,
                l_ipt_rec.ATTRIBUTE7,
                l_ipt_rec.ATTRIBUTE8,
                l_ipt_rec.ATTRIBUTE9,
                l_ipt_rec.ATTRIBUTE10,
                l_ipt_rec.ATTRIBUTE11,
                l_ipt_rec.ATTRIBUTE12,
                l_ipt_rec.ATTRIBUTE13,
                l_ipt_rec.ATTRIBUTE14,
                l_ipt_rec.ATTRIBUTE15,
                l_ipt_rec.CREATED_BY,
                l_ipt_rec.CREATION_DATE,
                l_ipt_rec.LAST_UPDATED_BY,
                l_ipt_rec.LAST_UPDATE_DATE,
                l_ipt_rec.LAST_UPDATE_LOGIN;
      x_no_data_found := okl_ipt_pk_csr%NOTFOUND;
      CLOSE okl_ipt_pk_csr;
      RETURN(l_ipt_rec);
    END get_rec;
    FUNCTION get_rec (
      p_ipt_rec                      IN ipt_rec_type
    ) RETURN ipt_rec_type IS
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      RETURN(get_rec(p_ipt_rec, l_row_notfound));
    END get_rec;
    ---------------------------------------------------------------------------
    -- FUNCTION get_rec for: OKL_INS_PRODUCTS_TL
    ---------------------------------------------------------------------------
    FUNCTION get_rec (
      p_okl_ins_products_tl_rec      IN okl_ins_products_tl_rec_type,
      x_no_data_found                OUT NOCOPY BOOLEAN
    ) RETURN okl_ins_products_tl_rec_type IS
      CURSOR okl_ins_iptl_pk_csr (p_id                 IN NUMBER,
                                  p_language           IN VARCHAR2) IS
      SELECT
              ID,
              LANGUAGE,
              SOURCE_LANG,
              SFWT_FLAG,
              NAME,
              FACTOR_NAME,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Ins_Products_Tl
       WHERE okl_ins_products_tl.id = p_id
         AND okl_ins_products_tl.language = p_language;
      l_okl_ins_iptl_pk              okl_ins_iptl_pk_csr%ROWTYPE;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
    BEGIN
      x_no_data_found := TRUE;
      -- Get current database values
      OPEN okl_ins_iptl_pk_csr (p_okl_ins_products_tl_rec.id,
                                p_okl_ins_products_tl_rec.language);
      FETCH okl_ins_iptl_pk_csr INTO
                l_okl_ins_products_tl_rec.ID,
                l_okl_ins_products_tl_rec.LANGUAGE,
                l_okl_ins_products_tl_rec.SOURCE_LANG,
                l_okl_ins_products_tl_rec.SFWT_FLAG,
                l_okl_ins_products_tl_rec.NAME,
                l_okl_ins_products_tl_rec.FACTOR_NAME,
                l_okl_ins_products_tl_rec.CREATED_BY,
                l_okl_ins_products_tl_rec.CREATION_DATE,
                l_okl_ins_products_tl_rec.LAST_UPDATED_BY,
                l_okl_ins_products_tl_rec.LAST_UPDATE_DATE,
                l_okl_ins_products_tl_rec.LAST_UPDATE_LOGIN;
      x_no_data_found := okl_ins_iptl_pk_csr%NOTFOUND;
      CLOSE okl_ins_iptl_pk_csr;
      RETURN(l_okl_ins_products_tl_rec);
    END get_rec;
    FUNCTION get_rec (
      p_okl_ins_products_tl_rec      IN okl_ins_products_tl_rec_type
    ) RETURN okl_ins_products_tl_rec_type IS
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      RETURN(get_rec(p_okl_ins_products_tl_rec, l_row_notfound));
    END get_rec;
    ---------------------------------------------------------------------------
    -- FUNCTION get_rec for: OKL_INS_PRODUCTS_V
    ---------------------------------------------------------------------------
    FUNCTION get_rec (
      p_iptv_rec                     IN iptv_rec_type,
      x_no_data_found                OUT NOCOPY BOOLEAN
    ) RETURN iptv_rec_type IS
      CURSOR okl_iptv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              ISU_ID,
              IPD_ID,
              POLICY_SYMBOL,
              IPT_TYPE,
              NAME,
              FACTOR_MAX,
              DATE_FROM,
              FACTOR_MIN,
              DATE_TO,
              FACTOR_NAME,
              FACTOR_CODE,
              COVERAGE_MIN,
              COVERAGE_MAX,
              DEAL_MONTHS_MIN,
              DEAL_MONTHS_MAX,
              FACTOR_AMOUNT_YN,
              ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Ins_Products_V
       WHERE okl_ins_products_v.id = p_id;
      l_okl_iptv_pk                  okl_iptv_pk_csr%ROWTYPE;
      l_iptv_rec                     iptv_rec_type;
    BEGIN
      x_no_data_found := TRUE;
      -- Get current database values
      OPEN okl_iptv_pk_csr (p_iptv_rec.id);
      FETCH okl_iptv_pk_csr INTO
                l_iptv_rec.ID,
                l_iptv_rec.OBJECT_VERSION_NUMBER,
                l_iptv_rec.SFWT_FLAG,
                l_iptv_rec.ISU_ID,
                l_iptv_rec.IPD_ID,
                l_iptv_rec.POLICY_SYMBOL,
                l_iptv_rec.IPT_TYPE,
                l_iptv_rec.NAME,
                l_iptv_rec.FACTOR_MAX,
                l_iptv_rec.DATE_FROM,
                l_iptv_rec.FACTOR_MIN,
                l_iptv_rec.DATE_TO,
                l_iptv_rec.FACTOR_NAME,
                l_iptv_rec.FACTOR_CODE,
                l_iptv_rec.COVERAGE_MIN,
                l_iptv_rec.COVERAGE_MAX,
                l_iptv_rec.DEAL_MONTHS_MIN,
                l_iptv_rec.DEAL_MONTHS_MAX,
                l_iptv_rec.FACTOR_AMOUNT_YN,
                l_iptv_rec.ATTRIBUTE_CATEGORY,
                l_iptv_rec.ATTRIBUTE1,
                l_iptv_rec.ATTRIBUTE2,
                l_iptv_rec.ATTRIBUTE3,
                l_iptv_rec.ATTRIBUTE4,
                l_iptv_rec.ATTRIBUTE5,
                l_iptv_rec.ATTRIBUTE6,
                l_iptv_rec.ATTRIBUTE7,
                l_iptv_rec.ATTRIBUTE8,
                l_iptv_rec.ATTRIBUTE9,
                l_iptv_rec.ATTRIBUTE10,
                l_iptv_rec.ATTRIBUTE11,
                l_iptv_rec.ATTRIBUTE12,
                l_iptv_rec.ATTRIBUTE13,
                l_iptv_rec.ATTRIBUTE14,
                l_iptv_rec.ATTRIBUTE15,
                l_iptv_rec.CREATED_BY,
                l_iptv_rec.CREATION_DATE,
                l_iptv_rec.LAST_UPDATED_BY,
                l_iptv_rec.LAST_UPDATE_DATE,
                l_iptv_rec.LAST_UPDATE_LOGIN;
      x_no_data_found := okl_iptv_pk_csr%NOTFOUND;
      CLOSE okl_iptv_pk_csr;
      RETURN(l_iptv_rec);
    END get_rec;
    FUNCTION get_rec (
      p_iptv_rec                     IN iptv_rec_type
    ) RETURN iptv_rec_type IS
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      RETURN(get_rec(p_iptv_rec, l_row_notfound));
    END get_rec;
    --------------------------------------------------------
    -- FUNCTION null_out_defaults for: OKL_INS_PRODUCTS_V --
    --------------------------------------------------------
    FUNCTION null_out_defaults (
      p_iptv_rec	IN iptv_rec_type
    ) RETURN iptv_rec_type IS
      l_iptv_rec	iptv_rec_type := p_iptv_rec;
    BEGIN
      IF (l_iptv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.object_version_number := NULL;
      END IF;
      IF (l_iptv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.sfwt_flag := NULL;
      END IF;
      IF (l_iptv_rec.isu_id = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.isu_id := NULL;
      END IF;
      IF (l_iptv_rec.ipd_id = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.ipd_id := NULL;
      END IF;
      IF (l_iptv_rec.ipt_type = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.ipt_type := NULL;
      END IF;
      IF (l_iptv_rec.name = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.name := NULL;
      END IF;
      IF (l_iptv_rec.policy_symbol = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.policy_symbol := NULL;
      END IF;
      IF (l_iptv_rec.factor_max = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.factor_max := NULL;
      END IF;
      IF (l_iptv_rec.date_from = OKC_API.G_MISS_DATE) THEN
        l_iptv_rec.date_from := NULL;
      END IF;
      IF (l_iptv_rec.factor_min = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.factor_min := NULL;
      END IF;
      IF (l_iptv_rec.date_to = OKC_API.G_MISS_DATE) THEN
        l_iptv_rec.date_to := NULL;
      END IF;
      IF (l_iptv_rec.factor_name = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.factor_name := NULL;
      END IF;
      IF (l_iptv_rec.factor_code = OKC_API.G_MISS_CHAR) THEN
         l_iptv_rec.factor_code := NULL;
      END IF;
      IF (l_iptv_rec.coverage_min = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.coverage_min := NULL;
      END IF;
      IF (l_iptv_rec.coverage_max = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.coverage_max := NULL;
      END IF;
      IF (l_iptv_rec.deal_months_min = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.deal_months_min := NULL;
      END IF;
      IF (l_iptv_rec.deal_months_max = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.deal_months_max := NULL;
      END IF;
      IF (l_iptv_rec.factor_amount_yn = OKC_API.G_MISS_CHAR) THEN
              l_iptv_rec.factor_amount_yn := NULL;
      END IF;
      IF (l_iptv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute_category := NULL;
      END IF;
      IF (l_iptv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute1 := NULL;
      END IF;
      IF (l_iptv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute2 := NULL;
      END IF;
      IF (l_iptv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute3 := NULL;
      END IF;
      IF (l_iptv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute4 := NULL;
      END IF;
      IF (l_iptv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute5 := NULL;
      END IF;
      IF (l_iptv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute6 := NULL;
      END IF;
      IF (l_iptv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute7 := NULL;
      END IF;
      IF (l_iptv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute8 := NULL;
      END IF;
      IF (l_iptv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute9 := NULL;
      END IF;
      IF (l_iptv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute10 := NULL;
      END IF;
      IF (l_iptv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute11 := NULL;
      END IF;
      IF (l_iptv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute12 := NULL;
      END IF;
      IF (l_iptv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute13 := NULL;
      END IF;
      IF (l_iptv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute14 := NULL;
      END IF;
      IF (l_iptv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
        l_iptv_rec.attribute15 := NULL;
      END IF;
      IF (l_iptv_rec.created_by = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.created_by := NULL;
      END IF;
      IF (l_iptv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
        l_iptv_rec.creation_date := NULL;
      END IF;
      IF (l_iptv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.last_updated_by := NULL;
      END IF;
      IF (l_iptv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
        l_iptv_rec.last_update_date := NULL;
      END IF;
      IF (l_iptv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
        l_iptv_rec.last_update_login := NULL;
      END IF;
      RETURN(l_iptv_rec);
    END null_out_defaults;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Attributes
    ---------------------------------------------------------------------------
    ------------------------------------------------
    -- Validate_Attributes for:OKL_INS_PRODUCTS_V --
    ------------------------------------------------
    FUNCTION Validate_Attributes (
      p_iptv_rec IN  iptv_rec_type
    ) RETURN VARCHAR2 IS
      x_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
           l_return_status	 VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          -- call ipt ID column-level validation
          validate_ipt_id(x_return_status => l_return_status,p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt object version number column-level validation
          validate_ipt_obj_version_num(x_return_status => l_return_status,
                                       p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt factor max column-level validation
          validate_ipt_factor_max(x_return_status => l_return_status,
                              p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt factor min column-level validation
          validate_ipt_factor_min(x_return_status => l_return_status,
                              p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt coverage max column-level validation
          validate_ipt_coverage_max(x_return_status => l_return_status,
                                p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt coverage min column-level validation
          validate_ipt_coverage_min(x_return_status => l_return_status,
                              p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt deal months max column-level validation
          validate_ipt_deal_months_max(x_return_status => l_return_status,
                                   p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt deal months min column-level validation
          validate_ipt_deal_months_min(x_return_status => l_return_status,
                              p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt factor amount yn column-level validation
	  validate_ipt_factor_amount_yn(x_return_status => l_return_status,
	                                     p_iptv_rec      => p_iptv_rec);
	   -- store the highest degree of error
	    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	       IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	             x_return_status :=l_return_status;
	             RAISE G_EXCEPTION_HALT_VALIDATION;
	        ELSE
	             x_return_status := l_return_status; -- Record that there was an error
	        END IF;
            END IF;
          -- call ipt ipd_id column-level validation
          validate_ipt_ipd_id(x_return_status => l_return_status,
                              p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt ipt_type column-level validation
          validate_ipt_ipt_type(x_return_status => l_return_status,
                                p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt name column-level validation
          validate_ipt_name(x_return_status => l_return_status,
                            p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt factor name column-level validation
         --Fix for BUG 2716905 : factor code enhancement
         /* validate_ipt_factor_name(x_return_status => l_return_status,
                            p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;*/
          -- call ipt policy symbol column-level validation
          validate_ipt_policy_symbol(x_return_status => l_return_status,
                            p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
           -- call ipt isu_id column-level validation
          validate_ipt_isu_id(x_return_status => l_return_status,
                              p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt date_from column_level validation
          validate_ipt_date_from(x_return_status => l_return_status,
                                     p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;

           -- call ipt created_by column_level validation
          validate_ipt_created_by(x_return_status => l_return_status,
                                  p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt creation_date column_level validation
          validate_ipt_creation_date(x_return_status => l_return_status,
                                     p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt last_updated_by column_level validation
          validate_ipt_last_updated_by(x_return_status => l_return_status,
                                       p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
          -- call ipt last_update_date column_level validation
          validate_ipt_last_update_date(x_return_status => l_return_status,
                                        p_iptv_rec      => p_iptv_rec);
          -- store the highest degree of error
          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status; -- Record that there was an error
            END IF;
          END IF;
      RETURN(x_return_status);
      EXCEPTION
              WHEN G_EXCEPTION_HALT_VALIDATION THEN
                RETURN(x_return_status);
              WHEN OTHERS THEN
                -- store SQL error message on message stack for caller
                Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                -- notify caller of an UNEXPECTED error
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);

    END Validate_Attributes;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Record
    ---------------------------------------------------------------------------
    --------------------------------------------
    -- Validate_Record for:OKL_INS_PRODUCTS_V --
    --------------------------------------------
    FUNCTION Validate_Record (
      p_iptv_rec IN iptv_rec_type
    ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_dummy_var         VARCHAR2(1) := '?';
      BEGIN
         --Validate Duplicate records
         validate_duplicates(p_iptv_rec,l_return_status);
            IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
               OKC_API.set_message(p_app_name 	    => G_APP_NAME,
  	                         p_msg_name           => 'OKL_UNIQUE'
  				);
               IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	         x_return_status :=l_return_status;
	         RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
	         	x_return_status := l_return_status;   -- record that there was an error
  	       END IF;

            END IF;

         --Validate whether start date is less than the end date only if end date
         -- is not null

           -- IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
              IF (p_iptv_rec.date_to IS NOT NULL)THEN
  	          l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => p_iptv_rec.date_from
  	             ,p_to_date => p_iptv_rec.date_to );
  	        IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
  	                    Okc_Api.set_message(
  	                                        p_app_name     => g_app_name,
  	    			                p_msg_name     => 'OKL_INVALID_END_DATE', --Fix for 3745151 Invalid error messages
  	    			                p_token1       => 'COL_NAME1',
  	    			                p_token1_value => 'Effective To',
  	    			                p_token2       => 'COL_NAME2',
  	    			                p_token2_value => 'Effective From'
  	    			               );
  	                IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	                 x_return_status :=l_return_status;
  	                RAISE G_EXCEPTION_HALT_VALIDATION;
  	                ELSE
  	                x_return_status := l_return_status;   -- record that there was an error
  	                END IF;
  	                END IF;
  	             END IF;
         --  END IF;

            --Validate whether end date is less than the sysdate only if end date
  	  -- is not null

  	  -- IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
  	     IF (p_iptv_rec.date_to IS NOT NULL OR p_iptv_rec.date_to <> OKC_API.G_MISS_DATE)THEN
  	      l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date =>trunc(SYSDATE) -- Fix for bug 3924176.
  	                                                         ,p_to_date => p_iptv_rec.date_to  );
  	  	IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
  	            Okc_Api.set_message(
  	                                 p_app_name     =>  g_app_name,
  	 			         p_msg_name     => 'OKL_INVALID_DATE_RANGE',
  	 			         p_token1       => 'COL_NAME1',
  	 			         p_token1_value => 'Effective To'
  	 			         );
  	             IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	              x_return_status :=l_return_status;
  	             RAISE G_EXCEPTION_HALT_VALIDATION;
  	             ELSE
  	             x_return_status := l_return_status;   -- record that there was an error
  	             END IF;
  	             END IF;
  	          END IF;
         --  END IF;

         -- validate whether factor_min is less than factor_max
       --    IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
              IF (p_iptv_rec.factor_min IS NOT NULL OR p_iptv_rec.factor_min <> OKC_API.G_MISS_NUM )THEN
                IF (p_iptv_rec.factor_max IS NOT NULL OR p_iptv_rec.factor_max <> OKC_API.G_MISS_NUM )THEN
                 l_return_status:= OKL_UTIL.check_from_to_number_range( p_iptv_rec.factor_min
                                                                       ,p_iptv_rec.factor_max);

              IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  Okc_Api.set_message(
                                      p_app_name     => g_app_name,
  			                        p_msg_name     => 'OKL_GREATER_THAN',
  			                        p_token1       => 'COL_NAME1',
  			                        p_token1_value => 'Factor Maximum',
  			                        p_token2       => 'COL_NAME2',
  			                        p_token2_value => 'Factor Minimum'
  			                        );
              IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status :=l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
              x_return_status := l_return_status;   -- record that there was an error
              END IF;
              END IF;
              END IF;
              END IF;
     --      END IF;

          -- validate whether coverage_min is less than coverage_max
    --       IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
               IF (p_iptv_rec.coverage_min IS NOT NULL OR p_iptv_rec.coverage_min <> OKC_API.G_MISS_NUM )THEN
                IF (p_iptv_rec.coverage_max IS NOT NULL OR p_iptv_rec.coverage_max <> OKC_API.G_MISS_NUM )THEN
                 l_return_status:= OKL_UTIL.check_from_to_number_range( p_iptv_rec.coverage_min
                                                                      , p_iptv_rec.coverage_max);
               IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  Okc_Api.set_message(
                                      p_app_name     => g_app_name,
  			                        p_msg_name     => 'OKL_GREATER_THAN',
  			                        p_token1       => 'COL_NAME1',
  			                        p_token1_value => 'Coverage Maximum',
  			                        p_token2       => 'COL_NAME2',
  			                        p_token2_value => 'Coverage Minimum'
  			                        );
              IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status :=l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
              x_return_status := l_return_status;   -- record that there was an error
              END IF;
              END IF;
              END IF;
              END IF;
    --       END IF;
          -- validate whether deal_months_min is less than deal_max_months
    --       IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
              IF (p_iptv_rec.deal_months_min IS NOT NULL OR p_iptv_rec.deal_months_min <> OKC_API.G_MISS_NUM )THEN
                IF (p_iptv_rec.deal_months_max IS NOT NULL OR p_iptv_rec.deal_months_max <> OKC_API.G_MISS_NUM )THEN
                 l_return_status:= OKL_UTIL.check_from_to_number_range( p_iptv_rec.deal_months_min
                                                                     , p_iptv_rec.deal_months_max);
             IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  Okc_Api.set_message(
                                      p_app_name     => g_app_name,
  			                        p_msg_name     => 'OKL_GREATER_THAN',
  			                        p_token1       => 'COL_NAME1',
  			                        p_token1_value => 'Deal Months Maximum',
  			                        p_token2       => 'COL_NAME2',
  			                        p_token2_value => 'Deal Months Minimum'
  			                        );
              IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                  x_return_status :=l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
              x_return_status := l_return_status;   -- record that there was an error
              END IF;
              END IF;
              END IF;
              END IF;
    --        END IF;



             --validate if the factor min and factor max is not same for the lease policy
            --from same provider.

    --        IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
              IF (p_iptv_rec.ipt_type = 'LEASE_PRODUCT') THEN
               validate_factor_range(p_iptv_rec,l_return_status);
              IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  Okc_Api.set_message(
                                      p_app_name     => g_app_name,
  			              p_msg_name     => 'OKL_IPT_RANGE_OVERLAP'
  			              );
              	IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                  x_return_status :=l_return_status;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
              	ELSE
              	x_return_status := l_return_status;   -- record that there was an error
              	END IF;
              END IF;

              END IF;
    --        END IF;

             --validate if the status is valid for the inventory product

  --          IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
  	               validate_system_item(p_iptv_rec,l_return_status);
  	              IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
  	                  Okc_Api.set_message(
  	                                    p_app_name     => g_app_name,
  	  			            p_msg_name     => 'OKL_INS_INVALID_ITEM'
  	  			             );
  	              IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  	                  x_return_status :=l_return_status;
  	              RAISE G_EXCEPTION_HALT_VALIDATION;
  	              ELSE
  	              x_return_status := l_return_status;   -- record that there was an error
  	              END IF;
  	              END IF;
  --	            END IF;

              -- Validate Factor_code for Lease Insurance Product
   -- IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
   -- IF (p_iptv_rec.ipt_type = 'LEASE_PRODUCT') THEN
                   validate_ipt_factor_code(l_return_status,p_iptv_rec);
                   IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  -- 3745151 Fix for invalid messages.
                  -- Removed as proper error message is thrown in validate_ipt_factor.
                  /*
  		  Okc_Api.set_message(
  		   	              p_app_name     => g_app_name,
  		                      p_msg_name     => 'OKL_INS_INVALID_ITEM'
  		   	             );
                   */
  		  IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
  		   x_return_status :=l_return_status;
  		   RAISE G_EXCEPTION_HALT_VALIDATION;
                   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
  		   x_return_status :=l_return_status;
                   RAISE OKC_API.G_EXCEPTION_ERROR;
  		  ELSE
  		   x_return_status := l_return_status;   -- record that there was an error
  		  END IF;
  		 END IF;
   --	      END IF;
   -- 	     END IF;


           RETURN (x_return_status);

    END Validate_Record;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_update_Record
    ---------------------------------------------------------------------------
    --------------------------------------------
    -- Validate_update_Record for:OKL_INS_PRODUCTS_V --
    --------------------------------------------
    FUNCTION Validate_update_Record (
      p_iptv_rec IN iptv_rec_type
    ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_dummy_var         VARCHAR2(1) := '?';
      BEGIN
         --Validate whether start date is less than the end date
           IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
                 l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => p_iptv_rec.date_from
                                                                    ,p_to_date => p_iptv_rec.date_to );
              IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  Okc_Api.set_message(
                                      p_app_name     => g_app_name,
  			                        p_msg_name     => 'OKL_INVALID_DATE_RANGE',
  			                        p_token1       => 'COL_NAME1',
  			                        p_token1_value => 'Effective To',
  			                        p_token2       => 'COL_NAME2',
  			                        p_token2_value => 'Effective From'
  			                        );
              IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
              x_return_status := l_return_status;   -- record that there was an error
              END IF;
              END IF;
           END IF;

         --Validate whether end date is less than the sysdate only if end date
         -- is not null

           IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
                IF (p_iptv_rec.date_to IS NOT NULL OR p_iptv_rec.date_to <> OKC_API.G_MISS_DATE )THEN
                 l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => trunc(SYSDATE) -- Fix for bug 3924176.
                                                                    ,p_to_date => p_iptv_rec.date_to );
              IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                  Okc_Api.set_message(
                                      p_app_name     => g_app_name,
  			                        p_msg_name     => 'OKL_INVALID_DATE_RANGE',
  			                        p_token1       => 'COL_NAME1',
  			                        p_token1_value => 'Effective To'
  			                        );
              IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status :=l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
              ELSE
              x_return_status := l_return_status;   -- record that there was an error
              END IF;
              END IF;
           END IF;
           END IF;

           RETURN (x_return_status);

    END Validate_update_Record;

    ---------------------------------------------------------------------------
    -- PROCEDURE Migrate
    ---------------------------------------------------------------------------
    PROCEDURE migrate (
      p_from	IN iptv_rec_type,
      p_to	OUT NOCOPY ipt_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.isu_id := p_from.isu_id;
      p_to.ipd_id := p_from.ipd_id;
      p_to.ipt_type := p_from.ipt_type;
      p_to.object_version_number := p_from.object_version_number;
      p_to.policy_symbol := p_from.policy_symbol;
      p_to.factor_code := p_from.factor_code;
      p_to.factor_max := p_from.factor_max;
      p_to.factor_min := p_from.factor_min;
      p_to.coverage_min := p_from.coverage_min;
      p_to.coverage_max := p_from.coverage_max;
      p_to.deal_months_min := p_from.deal_months_min;
      p_to.deal_months_max := p_from.deal_months_max;
      p_to.date_from := p_from.date_from;
      p_to.date_to := p_from.date_to;
      p_to.factor_amount_yn := p_from.factor_amount_yn;
      p_to.attribute_category := p_from.attribute_category;
      p_to.attribute1 := p_from.attribute1;
      p_to.attribute2 := p_from.attribute2;
      p_to.attribute3 := p_from.attribute3;
      p_to.attribute4 := p_from.attribute4;
      p_to.attribute5 := p_from.attribute5;
      p_to.attribute6 := p_from.attribute6;
      p_to.attribute7 := p_from.attribute7;
      p_to.attribute8 := p_from.attribute8;
      p_to.attribute9 := p_from.attribute9;
      p_to.attribute10 := p_from.attribute10;
      p_to.attribute11 := p_from.attribute11;
      p_to.attribute12 := p_from.attribute12;
      p_to.attribute13 := p_from.attribute13;
      p_to.attribute14 := p_from.attribute14;
      p_to.attribute15 := p_from.attribute15;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from	IN ipt_rec_type,
      p_to	OUT NOCOPY iptv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.isu_id := p_from.isu_id;
      p_to.ipd_id := p_from.ipd_id;
      p_to.ipt_type := p_from.ipt_type;
      p_to.object_version_number := p_from.object_version_number;
      p_to.policy_symbol := p_from.policy_symbol;
      p_to.factor_code := p_from.factor_code;
      p_to.factor_max := p_from.factor_max;
      p_to.factor_min := p_from.factor_min;
      p_to.coverage_min := p_from.coverage_min;
      p_to.coverage_max := p_from.coverage_max;
      p_to.deal_months_min := p_from.deal_months_min;
      p_to.deal_months_max := p_from.deal_months_max;
      p_to.date_from := p_from.date_from;
      p_to.date_to := p_from.date_to;
      p_to.factor_amount_yn := p_from.factor_amount_yn;
      p_to.attribute_category := p_from.attribute_category;
      p_to.attribute1 := p_from.attribute1;
      p_to.attribute2 := p_from.attribute2;
      p_to.attribute3 := p_from.attribute3;
      p_to.attribute4 := p_from.attribute4;
      p_to.attribute5 := p_from.attribute5;
      p_to.attribute6 := p_from.attribute6;
      p_to.attribute7 := p_from.attribute7;
      p_to.attribute8 := p_from.attribute8;
      p_to.attribute9 := p_from.attribute9;
      p_to.attribute10 := p_from.attribute10;
      p_to.attribute11 := p_from.attribute11;
      p_to.attribute12 := p_from.attribute12;
      p_to.attribute13 := p_from.attribute13;
      p_to.attribute14 := p_from.attribute14;
      p_to.attribute15 := p_from.attribute15;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from	IN iptv_rec_type,
      p_to	OUT NOCOPY okl_ins_products_tl_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.sfwt_flag := p_from.sfwt_flag;
      p_to.name := p_from.name;
      p_to.factor_name := p_from.factor_name;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from	IN okl_ins_products_tl_rec_type,
      p_to	OUT NOCOPY iptv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.sfwt_flag := p_from.sfwt_flag;
      p_to.name := p_from.name;
      p_to.factor_name := p_from.factor_name;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    ---------------------------------------------------------------------------
    -- PROCEDURE validate_row
    ---------------------------------------------------------------------------
    -----------------------------------------
    -- validate_row for:OKL_INS_PRODUCTS_V --
    -----------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_rec                     IN iptv_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_iptv_rec                     iptv_rec_type := p_iptv_rec;
      l_ipt_rec                      ipt_rec_type;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_iptv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_iptv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END validate_row;
    ------------------------------------------
    -- PL/SQL TBL validate_row for:IPTV_TBL --
    ------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_tbl                     IN iptv_tbl_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_iptv_tbl.COUNT > 0) THEN
        i := p_iptv_tbl.FIRST;
        LOOP
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_iptv_rec                     => p_iptv_tbl(i));
          EXIT WHEN (i = p_iptv_tbl.LAST);
          i := p_iptv_tbl.NEXT(i);
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END validate_row;
    ---------------------------------------------------------------------------
    -- PROCEDURE insert_row
    ---------------------------------------------------------------------------
    ---------------------------------------
    -- insert_row for:OKL_INS_PRODUCTS_B --
    ---------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipt_rec                      IN ipt_rec_type,
      x_ipt_rec                      OUT NOCOPY ipt_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipt_rec                      ipt_rec_type := p_ipt_rec;
      l_def_ipt_rec                  ipt_rec_type;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_B --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_ipt_rec IN  ipt_rec_type,
        x_ipt_rec OUT NOCOPY ipt_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipt_rec := p_ipt_rec;
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        p_ipt_rec,                         -- IN
        l_ipt_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      INSERT INTO OKL_INS_PRODUCTS_B(
          id,
          isu_id,
          ipd_id,
          ipt_type,
          object_version_number,
          policy_symbol,
          factor_code,
          factor_max,
          factor_min,
          coverage_min,
          coverage_max,
          deal_months_min,
          deal_months_max,
          date_from,
          date_to,
          factor_amount_yn,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_ipt_rec.id,
          l_ipt_rec.isu_id,
          l_ipt_rec.ipd_id,
          l_ipt_rec.ipt_type,
          l_ipt_rec.object_version_number,
          l_ipt_rec.policy_symbol,
          l_ipt_rec.factor_code,
          l_ipt_rec.factor_max,
          l_ipt_rec.factor_min,
          l_ipt_rec.coverage_min,
          l_ipt_rec.coverage_max,
          l_ipt_rec.deal_months_min,
          l_ipt_rec.deal_months_max,
          l_ipt_rec.date_from,
          l_ipt_rec.date_to,
          l_ipt_rec.factor_amount_yn,
          l_ipt_rec.attribute_category,
          l_ipt_rec.attribute1,
          l_ipt_rec.attribute2,
          l_ipt_rec.attribute3,
          l_ipt_rec.attribute4,
          l_ipt_rec.attribute5,
          l_ipt_rec.attribute6,
          l_ipt_rec.attribute7,
          l_ipt_rec.attribute8,
          l_ipt_rec.attribute9,
          l_ipt_rec.attribute10,
          l_ipt_rec.attribute11,
          l_ipt_rec.attribute12,
          l_ipt_rec.attribute13,
          l_ipt_rec.attribute14,
          l_ipt_rec.attribute15,
          l_ipt_rec.created_by,
          l_ipt_rec.creation_date,
          l_ipt_rec.last_updated_by,
          l_ipt_rec.last_update_date,
          l_ipt_rec.last_update_login);
      -- Set OUT values
      x_ipt_rec := l_ipt_rec;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END insert_row;
    ----------------------------------------
    -- insert_row for:OKL_INS_PRODUCTS_TL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_products_tl_rec      IN okl_ins_products_tl_rec_type,
      x_okl_ins_products_tl_rec      OUT NOCOPY okl_ins_products_tl_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type := p_okl_ins_products_tl_rec;
      ldefoklinsproductstlrec        okl_ins_products_tl_rec_type;
      CURSOR get_languages IS
        SELECT *
          FROM FND_LANGUAGES
         WHERE INSTALLED_FLAG IN ('I', 'B');
      --------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_TL --
      --------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_products_tl_rec IN  okl_ins_products_tl_rec_type,
        x_okl_ins_products_tl_rec OUT NOCOPY okl_ins_products_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_products_tl_rec := p_okl_ins_products_tl_rec;
        x_okl_ins_products_tl_rec.LANGUAGE := USERENV('LANG');
        x_okl_ins_products_tl_rec.SOURCE_LANG := USERENV('LANG');
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        p_okl_ins_products_tl_rec,         -- IN
        l_okl_ins_products_tl_rec);        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      FOR l_lang_rec IN get_languages LOOP
        l_okl_ins_products_tl_rec.language := l_lang_rec.language_code;
        INSERT INTO OKL_INS_PRODUCTS_TL(
            id,
            language,
            source_lang,
            sfwt_flag,
            name,
            factor_name,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login)
          VALUES (
            l_okl_ins_products_tl_rec.id,
            l_okl_ins_products_tl_rec.language,
            l_okl_ins_products_tl_rec.source_lang,
            l_okl_ins_products_tl_rec.sfwt_flag,
            l_okl_ins_products_tl_rec.name,
            l_okl_ins_products_tl_rec.factor_name,
            l_okl_ins_products_tl_rec.created_by,
            l_okl_ins_products_tl_rec.creation_date,
            l_okl_ins_products_tl_rec.last_updated_by,
            l_okl_ins_products_tl_rec.last_update_date,
            l_okl_ins_products_tl_rec.last_update_login);
      END LOOP;
      -- Set OUT values
      x_okl_ins_products_tl_rec := l_okl_ins_products_tl_rec;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END insert_row;
    ---------------------------------------
    -- insert_row for:OKL_INS_PRODUCTS_V --
    ---------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_rec                     IN iptv_rec_type,
      x_iptv_rec                     OUT NOCOPY iptv_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_iptv_rec                     iptv_rec_type;
      l_def_iptv_rec                 iptv_rec_type;
      l_ipt_rec                      ipt_rec_type;
      lx_ipt_rec                     ipt_rec_type;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
      lx_okl_ins_products_tl_rec     okl_ins_products_tl_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_iptv_rec	IN iptv_rec_type
      ) RETURN iptv_rec_type IS
        l_iptv_rec	iptv_rec_type := p_iptv_rec;
      BEGIN
        l_iptv_rec.CREATION_DATE := SYSDATE;
        l_iptv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_iptv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_iptv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_iptv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_iptv_rec);
      END fill_who_columns;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_V --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_iptv_rec IN  iptv_rec_type,
        x_iptv_rec OUT NOCOPY iptv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_iptv_rec := p_iptv_rec;
        x_iptv_rec.OBJECT_VERSION_NUMBER := 1;
        x_iptv_rec.SFWT_FLAG := 'N';
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_iptv_rec := null_out_defaults(p_iptv_rec);
      -- Set primary key value
      l_iptv_rec.ID := get_seq_id;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        l_iptv_rec,                        -- IN
        l_def_iptv_rec);                   -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_iptv_rec := fill_who_columns(l_def_iptv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_iptv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_def_iptv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------
      -- Move VIEW record to "Child" records
      --------------------------------------
      migrate(l_def_iptv_rec, l_ipt_rec);
      migrate(l_def_iptv_rec, l_okl_ins_products_tl_rec);
      --------------------------------------------
      -- Call the INSERT_ROW for each child record
      --------------------------------------------
      insert_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_ipt_rec,
        lx_ipt_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_ipt_rec, l_def_iptv_rec);
      insert_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_products_tl_rec,
        lx_okl_ins_products_tl_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_okl_ins_products_tl_rec, l_def_iptv_rec);
      -- Set OUT values
      x_iptv_rec := l_def_iptv_rec;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
            WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_ERROR',
                x_msg_count,
                x_msg_data,
                '_PVT'
              );
            WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OKC_API.G_RET_STS_UNEXP_ERROR',
                x_msg_count,
                x_msg_data,
                '_PVT'
              );
            WHEN OTHERS THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
              (
                l_api_name,
                G_PKG_NAME,
                'OTHERS',
                x_msg_count,
                x_msg_data,
                '_PVT'
              );

    END insert_row;
    ----------------------------------------
    -- PL/SQL TBL insert_row for:IPTV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_tbl                     IN iptv_tbl_type,
      x_iptv_tbl                     OUT NOCOPY iptv_tbl_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_iptv_tbl.COUNT > 0) THEN
        i := p_iptv_tbl.FIRST;
        LOOP
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_iptv_rec                     => p_iptv_tbl(i),
            x_iptv_rec                     => x_iptv_tbl(i));
          EXIT WHEN (i = p_iptv_tbl.LAST);
          i := p_iptv_tbl.NEXT(i);
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END insert_row;
    ---------------------------------------------------------------------------
    -- PROCEDURE lock_row
    ---------------------------------------------------------------------------
    -------------------------------------
    -- lock_row for:OKL_INS_PRODUCTS_B --
    -------------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipt_rec                      IN ipt_rec_type) IS
      E_Resource_Busy               EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_ipt_rec IN ipt_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_INS_PRODUCTS_B
       WHERE ID = p_ipt_rec.id
         AND OBJECT_VERSION_NUMBER = p_ipt_rec.object_version_number
      FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
      CURSOR  lchk_csr (p_ipt_rec IN ipt_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_INS_PRODUCTS_B
      WHERE ID = p_ipt_rec.id;
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_object_version_number       OKL_INS_PRODUCTS_B.OBJECT_VERSION_NUMBER%TYPE;
      lc_object_version_number      OKL_INS_PRODUCTS_B.OBJECT_VERSION_NUMBER%TYPE;
      l_row_notfound                BOOLEAN := FALSE;
      lc_row_notfound               BOOLEAN := FALSE;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      BEGIN
        OPEN lock_csr(p_ipt_rec);
        FETCH lock_csr INTO l_object_version_number;
        l_row_notfound := lock_csr%NOTFOUND;
        CLOSE lock_csr;
      EXCEPTION
        WHEN E_Resource_Busy THEN
          IF (lock_csr%ISOPEN) THEN
            CLOSE lock_csr;
          END IF;
          OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
          RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
      END;
      IF ( l_row_notfound ) THEN
        OPEN lchk_csr(p_ipt_rec);
        FETCH lchk_csr INTO lc_object_version_number;
        lc_row_notfound := lchk_csr%NOTFOUND;
        CLOSE lchk_csr;
      END IF;
      IF (lc_row_notfound) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number > p_ipt_rec.object_version_number THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number <> p_ipt_rec.object_version_number THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number = -1 THEN
        OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END lock_row;
    --------------------------------------
    -- lock_row for:OKL_INS_PRODUCTS_TL --
    --------------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_products_tl_rec      IN okl_ins_products_tl_rec_type) IS
      E_Resource_Busy               EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_okl_ins_products_tl_rec IN okl_ins_products_tl_rec_type) IS
      SELECT *
        FROM OKL_INS_PRODUCTS_TL
       WHERE ID = p_okl_ins_products_tl_rec.id
      FOR UPDATE NOWAIT;
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_lock_var                    lock_csr%ROWTYPE;
      l_row_notfound                BOOLEAN := FALSE;
      lc_row_notfound               BOOLEAN := FALSE;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      BEGIN
        OPEN lock_csr(p_okl_ins_products_tl_rec);
        FETCH lock_csr INTO l_lock_var;
        l_row_notfound := lock_csr%NOTFOUND;
        CLOSE lock_csr;
      EXCEPTION
        WHEN E_Resource_Busy THEN
          IF (lock_csr%ISOPEN) THEN
            CLOSE lock_csr;
          END IF;
          OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
          RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
      END;
      IF ( l_row_notfound ) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END lock_row;
    -------------------------------------
    -- lock_row for:OKL_INS_PRODUCTS_V --
    -------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_rec                     IN iptv_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipt_rec                      ipt_rec_type;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------
      -- Move VIEW record to "Child" records
      --------------------------------------
      migrate(p_iptv_rec, l_ipt_rec);
      migrate(p_iptv_rec, l_okl_ins_products_tl_rec);
      --------------------------------------------
      -- Call the LOCK_ROW for each child record
      --------------------------------------------
      lock_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_ipt_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      lock_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_products_tl_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END lock_row;
    --------------------------------------
    -- PL/SQL TBL lock_row for:IPTV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_tbl                     IN iptv_tbl_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_iptv_tbl.COUNT > 0) THEN
        i := p_iptv_tbl.FIRST;
        LOOP
          lock_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_iptv_rec                     => p_iptv_tbl(i));
          EXIT WHEN (i = p_iptv_tbl.LAST);
          i := p_iptv_tbl.NEXT(i);
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END lock_row;
    ---------------------------------------------------------------------------
    -- PROCEDURE update_row
    ---------------------------------------------------------------------------
    ---------------------------------------
    -- update_row for:OKL_INS_PRODUCTS_B --
    ---------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipt_rec                      IN ipt_rec_type,
      x_ipt_rec                      OUT NOCOPY ipt_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipt_rec                      ipt_rec_type := p_ipt_rec;
      l_def_ipt_rec                  ipt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_ipt_rec	IN ipt_rec_type,
        x_ipt_rec	OUT NOCOPY ipt_rec_type
      ) RETURN VARCHAR2 IS
        l_ipt_rec                      ipt_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipt_rec := p_ipt_rec;
        -- Get current database values
        l_ipt_rec := get_rec(p_ipt_rec, l_row_notfound);
        IF (l_row_notfound) THEN
          l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF (x_ipt_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.id := l_ipt_rec.id;
        END IF;
        IF (x_ipt_rec.isu_id = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.isu_id := l_ipt_rec.isu_id;
        END IF;
        IF (x_ipt_rec.ipd_id = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.ipd_id := l_ipt_rec.ipd_id;
        END IF;
        IF (x_ipt_rec.ipt_type = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.ipt_type := l_ipt_rec.ipt_type;
        END IF;
        IF (x_ipt_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.object_version_number := l_ipt_rec.object_version_number;
        END IF;
        IF (x_ipt_rec.policy_symbol = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.policy_symbol := l_ipt_rec.policy_symbol;
        END IF;
        IF (x_ipt_rec.factor_code = OKC_API.G_MISS_CHAR)
	THEN
	  x_ipt_rec.factor_code := l_ipt_rec.factor_code;
        END IF;
        IF (x_ipt_rec.factor_max = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.factor_max := l_ipt_rec.factor_max;
        END IF;
        IF (x_ipt_rec.factor_min = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.factor_min := l_ipt_rec.factor_min;
        END IF;
        IF (x_ipt_rec.coverage_min = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.coverage_min := l_ipt_rec.coverage_min;
        END IF;
        IF (x_ipt_rec.coverage_max = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.coverage_max := l_ipt_rec.coverage_max;
        END IF;
        IF (x_ipt_rec.deal_months_min = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.deal_months_min := l_ipt_rec.deal_months_min;
        END IF;
        IF (x_ipt_rec.deal_months_max = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.deal_months_max := l_ipt_rec.deal_months_max;
        END IF;
        IF (x_ipt_rec.date_from = OKC_API.G_MISS_DATE)
        THEN
          x_ipt_rec.date_from := l_ipt_rec.date_from;
        END IF;
        IF (x_ipt_rec.date_to = OKC_API.G_MISS_DATE)
        THEN
          x_ipt_rec.date_to := l_ipt_rec.date_to;
        END IF;
        IF (x_ipt_rec.factor_amount_yn = OKC_API.G_MISS_CHAR)
	THEN
	   x_ipt_rec.factor_amount_yn := l_ipt_rec.factor_amount_yn;
        END IF;
        IF (x_ipt_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute_category := l_ipt_rec.attribute_category;
        END IF;
        IF (x_ipt_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute1 := l_ipt_rec.attribute1;
        END IF;
        IF (x_ipt_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute2 := l_ipt_rec.attribute2;
        END IF;
        IF (x_ipt_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute3 := l_ipt_rec.attribute3;
        END IF;
        IF (x_ipt_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute4 := l_ipt_rec.attribute4;
        END IF;
        IF (x_ipt_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute5 := l_ipt_rec.attribute5;
        END IF;
        IF (x_ipt_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute6 := l_ipt_rec.attribute6;
        END IF;
        IF (x_ipt_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute7 := l_ipt_rec.attribute7;
        END IF;
        IF (x_ipt_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute8 := l_ipt_rec.attribute8;
        END IF;
        IF (x_ipt_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute9 := l_ipt_rec.attribute9;
        END IF;
        IF (x_ipt_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute10 := l_ipt_rec.attribute10;
        END IF;
        IF (x_ipt_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute11 := l_ipt_rec.attribute11;
        END IF;
        IF (x_ipt_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute12 := l_ipt_rec.attribute12;
        END IF;
        IF (x_ipt_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute13 := l_ipt_rec.attribute13;
        END IF;
        IF (x_ipt_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute14 := l_ipt_rec.attribute14;
        END IF;
        IF (x_ipt_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_ipt_rec.attribute15 := l_ipt_rec.attribute15;
        END IF;
        IF (x_ipt_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.created_by := l_ipt_rec.created_by;
        END IF;
        IF (x_ipt_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ipt_rec.creation_date := l_ipt_rec.creation_date;
        END IF;
        IF (x_ipt_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.last_updated_by := l_ipt_rec.last_updated_by;
        END IF;
        IF (x_ipt_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ipt_rec.last_update_date := l_ipt_rec.last_update_date;
        END IF;
        IF (x_ipt_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ipt_rec.last_update_login := l_ipt_rec.last_update_login;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_B --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_ipt_rec IN  ipt_rec_type,
        x_ipt_rec OUT NOCOPY ipt_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipt_rec := p_ipt_rec;
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        p_ipt_rec,                         -- IN
        l_ipt_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_ipt_rec, l_def_ipt_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      UPDATE  OKL_INS_PRODUCTS_B
      SET ISU_ID = l_def_ipt_rec.isu_id,
          IPD_ID = l_def_ipt_rec.ipd_id,
          IPT_TYPE = l_def_ipt_rec.ipt_type,
          OBJECT_VERSION_NUMBER = l_def_ipt_rec.object_version_number,
          POLICY_SYMBOL = l_def_ipt_rec.policy_symbol,
          FACTOR_CODE = l_def_ipt_rec.factor_code,
          FACTOR_MAX = l_def_ipt_rec.factor_max,
          FACTOR_MIN = l_def_ipt_rec.factor_min,
          COVERAGE_MIN = l_def_ipt_rec.coverage_min,
          COVERAGE_MAX = l_def_ipt_rec.coverage_max,
          DEAL_MONTHS_MIN = l_def_ipt_rec.deal_months_min,
          DEAL_MONTHS_MAX = l_def_ipt_rec.deal_months_max,
          DATE_FROM = l_def_ipt_rec.date_from,
          DATE_TO = l_def_ipt_rec.date_to,
          FACTOR_AMOUNT_YN = l_def_ipt_rec.factor_amount_yn,
          ATTRIBUTE_CATEGORY = l_def_ipt_rec.attribute_category,
          ATTRIBUTE1 = l_def_ipt_rec.attribute1,
          ATTRIBUTE2 = l_def_ipt_rec.attribute2,
          ATTRIBUTE3 = l_def_ipt_rec.attribute3,
          ATTRIBUTE4 = l_def_ipt_rec.attribute4,
          ATTRIBUTE5 = l_def_ipt_rec.attribute5,
          ATTRIBUTE6 = l_def_ipt_rec.attribute6,
          ATTRIBUTE7 = l_def_ipt_rec.attribute7,
          ATTRIBUTE8 = l_def_ipt_rec.attribute8,
          ATTRIBUTE9 = l_def_ipt_rec.attribute9,
          ATTRIBUTE10 = l_def_ipt_rec.attribute10,
          ATTRIBUTE11 = l_def_ipt_rec.attribute11,
          ATTRIBUTE12 = l_def_ipt_rec.attribute12,
          ATTRIBUTE13 = l_def_ipt_rec.attribute13,
          ATTRIBUTE14 = l_def_ipt_rec.attribute14,
          ATTRIBUTE15 = l_def_ipt_rec.attribute15,
          CREATED_BY = l_def_ipt_rec.created_by,
          CREATION_DATE = l_def_ipt_rec.creation_date,
          LAST_UPDATED_BY = l_def_ipt_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_ipt_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_ipt_rec.last_update_login
      WHERE ID = l_def_ipt_rec.id;
      x_ipt_rec := l_def_ipt_rec;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END update_row;
    ----------------------------------------
    -- update_row for:OKL_INS_PRODUCTS_TL --
    ----------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_products_tl_rec      IN okl_ins_products_tl_rec_type,
      x_okl_ins_products_tl_rec      OUT NOCOPY okl_ins_products_tl_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type := p_okl_ins_products_tl_rec;
      ldefoklinsproductstlrec        okl_ins_products_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_okl_ins_products_tl_rec	IN okl_ins_products_tl_rec_type,
        x_okl_ins_products_tl_rec	OUT NOCOPY okl_ins_products_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_products_tl_rec := p_okl_ins_products_tl_rec;
        -- Get current database values
        l_okl_ins_products_tl_rec := get_rec(p_okl_ins_products_tl_rec, l_row_notfound);
        IF (l_row_notfound) THEN
          l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF (x_okl_ins_products_tl_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_okl_ins_products_tl_rec.id := l_okl_ins_products_tl_rec.id;
        END IF;
        IF (x_okl_ins_products_tl_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_ins_products_tl_rec.language := l_okl_ins_products_tl_rec.language;
        END IF;
        IF (x_okl_ins_products_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_ins_products_tl_rec.source_lang := l_okl_ins_products_tl_rec.source_lang;
        END IF;
        IF (x_okl_ins_products_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_ins_products_tl_rec.sfwt_flag := l_okl_ins_products_tl_rec.sfwt_flag;
        END IF;
        IF (x_okl_ins_products_tl_rec.name = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_ins_products_tl_rec.name := l_okl_ins_products_tl_rec.name;
        END IF;
        IF (x_okl_ins_products_tl_rec.factor_name = OKC_API.G_MISS_CHAR)
        THEN
          x_okl_ins_products_tl_rec.factor_name := l_okl_ins_products_tl_rec.factor_name;
        END IF;
        IF (x_okl_ins_products_tl_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okl_ins_products_tl_rec.created_by := l_okl_ins_products_tl_rec.created_by;
        END IF;
        IF (x_okl_ins_products_tl_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_ins_products_tl_rec.creation_date := l_okl_ins_products_tl_rec.creation_date;
        END IF;
        IF (x_okl_ins_products_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okl_ins_products_tl_rec.last_updated_by := l_okl_ins_products_tl_rec.last_updated_by;
        END IF;
        IF (x_okl_ins_products_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okl_ins_products_tl_rec.last_update_date := l_okl_ins_products_tl_rec.last_update_date;
        END IF;
        IF (x_okl_ins_products_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okl_ins_products_tl_rec.last_update_login := l_okl_ins_products_tl_rec.last_update_login;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      --------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_TL --
      --------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_products_tl_rec IN  okl_ins_products_tl_rec_type,
        x_okl_ins_products_tl_rec OUT NOCOPY okl_ins_products_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_products_tl_rec := p_okl_ins_products_tl_rec;
        x_okl_ins_products_tl_rec.LANGUAGE := USERENV('LANG');
        x_okl_ins_products_tl_rec.SOURCE_LANG := USERENV('LANG');
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        p_okl_ins_products_tl_rec,         -- IN
        l_okl_ins_products_tl_rec);        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_okl_ins_products_tl_rec, ldefoklinsproductstlrec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      UPDATE  OKL_INS_PRODUCTS_TL
      SET NAME = ldefoklinsproductstlrec.name,
          SOURCE_LANG = ldefoklinsproductstlrec.source_lang, -- Added for Bug 3637102
          FACTOR_NAME = ldefoklinsproductstlrec.factor_name,
          CREATED_BY = ldefoklinsproductstlrec.created_by,
          CREATION_DATE = ldefoklinsproductstlrec.creation_date,
          LAST_UPDATED_BY = ldefoklinsproductstlrec.last_updated_by,
          LAST_UPDATE_DATE = ldefoklinsproductstlrec.last_update_date,
          LAST_UPDATE_LOGIN = ldefoklinsproductstlrec.last_update_login
      WHERE ID = ldefoklinsproductstlrec.id
        AND  USERENV('LANG') in (SOURCE_LANG,LANGUAGE); --Bug 3637102 Added language
      UPDATE  OKL_INS_PRODUCTS_TL
      SET SFWT_FLAG = 'Y'
      WHERE ID = ldefoklinsproductstlrec.id
        AND SOURCE_LANG <> USERENV('LANG');
      x_okl_ins_products_tl_rec := ldefoklinsproductstlrec;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END update_row;
    ---------------------------------------
    -- update_row for:OKL_INS_PRODUCTS_V --
    ---------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_rec                     IN iptv_rec_type,
      x_iptv_rec                     OUT NOCOPY iptv_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_iptv_rec                     iptv_rec_type := p_iptv_rec;
      l_def_iptv_rec                 iptv_rec_type;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
      lx_okl_ins_products_tl_rec     okl_ins_products_tl_rec_type;
      l_ipt_rec                      ipt_rec_type;
      lx_ipt_rec                     ipt_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_iptv_rec	IN iptv_rec_type
      ) RETURN iptv_rec_type IS
        l_iptv_rec	iptv_rec_type := p_iptv_rec;
      BEGIN
        l_iptv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_iptv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_iptv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_iptv_rec);
      END fill_who_columns;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_iptv_rec	IN iptv_rec_type,
        x_iptv_rec	OUT NOCOPY iptv_rec_type
      ) RETURN VARCHAR2 IS
        l_iptv_rec                     iptv_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_iptv_rec := p_iptv_rec;
        -- Get current database values
        l_iptv_rec := get_rec(p_iptv_rec, l_row_notfound);
        IF (l_row_notfound) THEN
          l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF (x_iptv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.id := l_iptv_rec.id;
        END IF;
        IF (x_iptv_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.object_version_number := l_iptv_rec.object_version_number;
        END IF;
        IF (x_iptv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.sfwt_flag := l_iptv_rec.sfwt_flag;
        END IF;
        IF (x_iptv_rec.isu_id = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.isu_id := l_iptv_rec.isu_id;
        END IF;
        IF (x_iptv_rec.ipd_id = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.ipd_id := l_iptv_rec.ipd_id;
        END IF;
        IF (x_iptv_rec.ipt_type = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.ipt_type := l_iptv_rec.ipt_type;
        END IF;
        IF (x_iptv_rec.name = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.name := l_iptv_rec.name;
        END IF;
        IF (x_iptv_rec.policy_symbol = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.policy_symbol := l_iptv_rec.policy_symbol;
        END IF;
        IF (x_iptv_rec.factor_max = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.factor_max := l_iptv_rec.factor_max;
        END IF;
        IF (x_iptv_rec.date_from = OKC_API.G_MISS_DATE)
        THEN
          x_iptv_rec.date_from := l_iptv_rec.date_from;
        END IF;
        IF (x_iptv_rec.factor_min = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.factor_min := l_iptv_rec.factor_min;
        END IF;
        IF (x_iptv_rec.date_to = OKC_API.G_MISS_DATE)
        THEN
          x_iptv_rec.date_to := l_iptv_rec.date_to;
        END IF;
        IF (x_iptv_rec.factor_amount_yn = OKC_API.G_MISS_CHAR)
	THEN
	    x_iptv_rec.factor_amount_yn := l_iptv_rec.factor_amount_yn;
        END IF;
        IF (x_iptv_rec.factor_name = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.factor_name := l_iptv_rec.factor_name;
        END IF;
        IF (x_iptv_rec.factor_code = OKC_API.G_MISS_CHAR)
	 THEN
	    x_iptv_rec.factor_code := l_iptv_rec.factor_code;
        END IF;
        IF (x_iptv_rec.coverage_min = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.coverage_min := l_iptv_rec.coverage_min;
        END IF;
        IF (x_iptv_rec.coverage_max = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.coverage_max := l_iptv_rec.coverage_max;
        END IF;
        IF (x_iptv_rec.deal_months_min = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.deal_months_min := l_iptv_rec.deal_months_min;
        END IF;
        IF (x_iptv_rec.deal_months_max = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.deal_months_max := l_iptv_rec.deal_months_max;
        END IF;
        IF (x_iptv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute_category := l_iptv_rec.attribute_category;
        END IF;
        IF (x_iptv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute1 := l_iptv_rec.attribute1;
        END IF;
        IF (x_iptv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute2 := l_iptv_rec.attribute2;
        END IF;
        IF (x_iptv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute3 := l_iptv_rec.attribute3;
        END IF;
        IF (x_iptv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute4 := l_iptv_rec.attribute4;
        END IF;
        IF (x_iptv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute5 := l_iptv_rec.attribute5;
        END IF;
        IF (x_iptv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute6 := l_iptv_rec.attribute6;
        END IF;
        IF (x_iptv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute7 := l_iptv_rec.attribute7;
        END IF;
        IF (x_iptv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute8 := l_iptv_rec.attribute8;
        END IF;
        IF (x_iptv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute9 := l_iptv_rec.attribute9;
        END IF;
        IF (x_iptv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute10 := l_iptv_rec.attribute10;
        END IF;
        IF (x_iptv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute11 := l_iptv_rec.attribute11;
        END IF;
        IF (x_iptv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute12 := l_iptv_rec.attribute12;
        END IF;
        IF (x_iptv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute13 := l_iptv_rec.attribute13;
        END IF;
        IF (x_iptv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute14 := l_iptv_rec.attribute14;
        END IF;
        IF (x_iptv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_iptv_rec.attribute15 := l_iptv_rec.attribute15;
        END IF;
        IF (x_iptv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.created_by := l_iptv_rec.created_by;
        END IF;
        IF (x_iptv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_iptv_rec.creation_date := l_iptv_rec.creation_date;
        END IF;
        IF (x_iptv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.last_updated_by := l_iptv_rec.last_updated_by;
        END IF;
        IF (x_iptv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_iptv_rec.last_update_date := l_iptv_rec.last_update_date;
        END IF;
        IF (x_iptv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_iptv_rec.last_update_login := l_iptv_rec.last_update_login;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_V --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_iptv_rec IN  iptv_rec_type,
        x_iptv_rec OUT NOCOPY iptv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_iptv_rec := p_iptv_rec;
        x_iptv_rec.OBJECT_VERSION_NUMBER := NVL(x_iptv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        p_iptv_rec,                        -- IN
        l_iptv_rec);                       -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_iptv_rec, l_def_iptv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_iptv_rec := fill_who_columns(l_def_iptv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_iptv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_update_Record(l_def_iptv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------
      -- Move VIEW record to "Child" records
      --------------------------------------
      migrate(l_def_iptv_rec, l_okl_ins_products_tl_rec);
      migrate(l_def_iptv_rec, l_ipt_rec);
      --------------------------------------------
      -- Call the UPDATE_ROW for each child record
      --------------------------------------------
      update_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_products_tl_rec,
        lx_okl_ins_products_tl_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_okl_ins_products_tl_rec, l_def_iptv_rec);
      update_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_ipt_rec,
        lx_ipt_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_ipt_rec, l_def_iptv_rec);
      x_iptv_rec := l_def_iptv_rec;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END update_row;
    ----------------------------------------
    -- PL/SQL TBL update_row for:IPTV_TBL --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_tbl                     IN iptv_tbl_type,
      x_iptv_tbl                     OUT NOCOPY iptv_tbl_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_iptv_tbl.COUNT > 0) THEN
        i := p_iptv_tbl.FIRST;
        LOOP
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_iptv_rec                     => p_iptv_tbl(i),
            x_iptv_rec                     => x_iptv_tbl(i));
          EXIT WHEN (i = p_iptv_tbl.LAST);
          i := p_iptv_tbl.NEXT(i);
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END update_row;
    ---------------------------------------------------------------------------
    -- PROCEDURE delete_row
    ---------------------------------------------------------------------------
    ---------------------------------------
    -- delete_row for:OKL_INS_PRODUCTS_B --
    ---------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipt_rec                      IN ipt_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipt_rec                      ipt_rec_type:= p_ipt_rec;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      DELETE FROM OKL_INS_PRODUCTS_B
       WHERE ID = l_ipt_rec.id;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END delete_row;
    ----------------------------------------
    -- delete_row for:OKL_INS_PRODUCTS_TL --
    ----------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_products_tl_rec      IN okl_ins_products_tl_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type:= p_okl_ins_products_tl_rec;
      l_row_notfound                 BOOLEAN := TRUE;
      --------------------------------------------
      -- Set_Attributes for:OKL_INS_PRODUCTS_TL --
      --------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_products_tl_rec IN  okl_ins_products_tl_rec_type,
        x_okl_ins_products_tl_rec OUT NOCOPY okl_ins_products_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_products_tl_rec := p_okl_ins_products_tl_rec;
        x_okl_ins_products_tl_rec.LANGUAGE := USERENV('LANG');
        RETURN(l_return_status);
      END Set_Attributes;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --- Setting item attributes
      l_return_status := Set_Attributes(
        p_okl_ins_products_tl_rec,         -- IN
        l_okl_ins_products_tl_rec);        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      DELETE FROM OKL_INS_PRODUCTS_TL
       WHERE ID = l_okl_ins_products_tl_rec.id;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END delete_row;
    ---------------------------------------
    -- delete_row for:OKL_INS_PRODUCTS_V --
    ---------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_rec                     IN iptv_rec_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_iptv_rec                     iptv_rec_type := p_iptv_rec;
      l_okl_ins_products_tl_rec      okl_ins_products_tl_rec_type;
      l_ipt_rec                      ipt_rec_type;
    BEGIN
      l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                G_PKG_NAME,
                                                p_init_msg_list,
                                                l_api_version,
                                                p_api_version,
                                                '_PVT',
                                                x_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --------------------------------------
      -- Move VIEW record to "Child" records
      --------------------------------------
      migrate(l_iptv_rec, l_okl_ins_products_tl_rec);
      migrate(l_iptv_rec, l_ipt_rec);
      --------------------------------------------
      -- Call the DELETE_ROW for each child record
      --------------------------------------------
      delete_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_products_tl_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      delete_row(
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        l_ipt_rec
      );
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END delete_row;
    ----------------------------------------
    -- PL/SQL TBL delete_row for:IPTV_TBL --
    ----------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_iptv_tbl                     IN iptv_tbl_type) IS
      l_api_version                 CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_iptv_tbl.COUNT > 0) THEN
        i := p_iptv_tbl.FIRST;
        LOOP
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_iptv_rec                     => p_iptv_tbl(i));
          EXIT WHEN (i = p_iptv_tbl.LAST);
          i := p_iptv_tbl.NEXT(i);
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
    END delete_row;
  END OKL_IPT_PVT;

/
