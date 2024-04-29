--------------------------------------------------------
--  DDL for Package Body OKL_LLA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LLA_UTIL_PVT" AS
/* $Header: OKLRLAUB.pls 120.18.12010000.8 2009/09/29 17:22:09 racheruv ship $ */
/* ***********************************************  */
--G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
--G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_PROCESSING    EXCEPTION;
G_EXCEPTION_STOP_VALIDATION    EXCEPTION;


G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_LLA_UTIL_PVT';
G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
l_api_name    VARCHAR2(35)    := 'LLA_UTIL';

FUNCTION get_number
     (p_amount_in IN VARCHAR2)
   RETURN VARCHAR2
   AS
     l_amount_out VARCHAR2(150) := p_amount_in;
   BEGIN
       SELECT REPLACE(REPLACE(p_amount_in,SUBSTR(value,2,1)),SUBSTR(value,1,1),'.')
--       select replace(replace(p_amount_in,substr(',.',2,1)),substr(',.',1,1),'.')
       INTO l_amount_out
       FROM v$nls_parameters
       WHERE parameter = 'NLS_NUMERIC_CHARACTERS';
       RETURN(l_amount_out);
   EXCEPTION
     WHEN OTHERS THEN
     RETURN(p_amount_in);
END;

-------------------------------------------------------------------------------
-- FUNCTION get_lookup_meaning
-------------------------------------------------------------------------------
-- Start of comments
--
-- Function Name   : get_lookup_meaning
-- Description     : This function returns the lookup meaning for specified
--                 : lookup_code and lookup_type
--
-- Business Rules  :
--
-- Parameters      :
-- Version         : 1.0
-- History         : 21-FEB-2007 asahoo created
-- End of comments
FUNCTION get_lookup_meaning(p_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE
                           ,p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE)
  RETURN VARCHAR2 IS
  CURSOR fnd_lookup_csr(p_lookup_type fnd_lookups.lookup_type%TYPE
                       ,p_lookup_code fnd_lookups.lookup_code%TYPE) IS
  SELECT MEANING
  FROM  FND_LOOKUPS FND
  WHERE FND.LOOKUP_TYPE = p_lookup_type
  AND   FND.LOOKUP_CODE = p_lookup_code;
  l_return_value FND_LOOKUPS.MEANING%TYPE := NULL;
  BEGIN
    IF (p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL) THEN
       OPEN fnd_lookup_csr(p_lookup_type, p_lookup_code);
       FETCH fnd_lookup_csr INTO l_return_value;
       CLOSE fnd_lookup_csr;
    END IF;
    RETURN l_return_value;
  END get_lookup_meaning;


PROCEDURE format_round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2) IS


    --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
    l_proc_name   VARCHAR2(35)    := 'FORMAT_ROUND_AMOUNT';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;

    BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      x_amount := OKL_ACCOUNTING_UTIL.cc_round_format_amount(p_amount => TO_NUMBER(get_number(p_amount)),
                                                             p_currency_code => p_currency_code);


    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

 EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END format_round_amount;


  PROCEDURE format_round_amount(
              p_api_version             IN NUMBER,
              p_init_msg_list       IN VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2,
              p_amount              IN  VARCHAR2,
              p_currency_code       IN  VARCHAR2,
              p_org_id              IN  VARCHAR2,
              x_amount              OUT NOCOPY VARCHAR2) IS


      --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
      l_proc_name   VARCHAR2(35)    := 'FORMAT_ROUND_AMOUNT';
      l_api_version CONSTANT VARCHAR2(30) := p_api_version;

      BEGIN

        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
        x_return_status := OKC_API.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              x_return_status => x_return_status);

        -- check if activity started successfully
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        x_amount := OKL_ACCOUNTING_UTIL.cc_round_format_amount(p_amount => TO_NUMBER(get_number(p_amount)),
                                                               p_currency_code => p_currency_code);


      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

   EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
           x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => G_PKG_NAME,
              p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => G_API_TYPE);

        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
           x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => G_PKG_NAME,
              p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => G_API_TYPE);

        WHEN OTHERS THEN
           x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => G_PKG_NAME,
              p_exc_name  => 'OTHERS',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => G_API_TYPE);

    END format_round_amount;



  PROCEDURE round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2) IS


    --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
    l_proc_name   VARCHAR2(35)    := 'ROUND_AMOUNT';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;

    BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      x_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(
                                        p_amount => TO_NUMBER(get_number(p_amount)),
                                        p_currency_code => p_currency_code);


    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

 EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END round_amount;


PROCEDURE round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            p_org_id              IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2) IS


    --l_api_name    VARCHAR2(35)    := 'RGRP_RULES_PROCESS';
    l_proc_name   VARCHAR2(35)    := 'ROUND_AMOUNT';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;

    BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      x_amount := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(
                                        p_amount => TO_NUMBER(get_number(p_amount)),
                                        p_currency_code => p_currency_code);


    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

 EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END round_amount;

   FUNCTION get_canonical_date
     (p_date_char IN VARCHAR2)
   RETURN VARCHAR2
   AS
     -- p_date := p_date_char;
     -- p_mask := p_date_mask;
     p_date_out VARCHAR2(15) := p_date_char;

   BEGIN
     --p_canonical_date := to_char(to_date(p_date_char,G_DISPLAY_MASK), g_canonical_mask);
     IF(LENGTH(RTRIM(p_date_out)) > 0) THEN
         p_date_out := get_canonical_date(p_date_out,G_DISPLAY_MASK);
     END IF;
     RETURN p_date_out;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN(p_date_char);
   END;


   FUNCTION get_canonical_date
     (p_date_char IN VARCHAR2,
      p_date_mask IN VARCHAR2)
   RETURN VARCHAR2
   AS
     -- p_date := p_date_char;
     -- p_mask := p_date_mask;
     p_date_out VARCHAR2(15) := p_date_char;

   BEGIN
     IF(LENGTH(RTRIM(p_date_out)) > 0) THEN
         p_date_out := FND_DATE.date_to_canonical(TO_DATE(p_date_out,p_date_mask));
     END IF;
     RETURN p_date_out;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN(p_date_char);
   END;


   FUNCTION validate_get_canonical_date
       (p_date_char IN VARCHAR2)
     RETURN VARCHAR2
     AS
       -- p_date := p_date_char;
       -- p_mask := p_date_mask;
       p_date_out VARCHAR2(30) := p_date_char;
       p_date           DATE;

     BEGIN
       --p_canonical_date := to_char(to_date(p_date_char,G_DISPLAY_MASK), g_canonical_mask);
       IF(LENGTH(RTRIM(p_date_out)) > 0) THEN
         p_date := TO_DATE(p_date_out,G_DISPLAY_MASK);
 --        p_date_out := to_char(p_date,g_canonical_mask);
         p_date_out := FND_DATE.date_to_canonical(p_date);
       END IF;
       RETURN p_date_out;
     EXCEPTION
       WHEN OTHERS THEN
         RETURN(OKL_API.G_FALSE);
   END;


   FUNCTION get_display_date
     (p_date_char IN VARCHAR2)
   RETURN VARCHAR2
   AS
     -- p_date := p_date_char;
     -- p_mask := p_date_mask;
   p_date_out VARCHAR2(30) := p_date_char;
   l_display_mask VARCHAR2(15) := fnd_profile.value('ICX_DATE_FORMAT_MASK'); -- Added for bug fix 8429670
   BEGIN
     IF(LENGTH(RTRIM(p_date_out)) > 0) THEN
        -- p_date_out := get_display_date(p_date_out,G_DISPLAY_MASK); --8429670
        p_date_out := get_display_date(p_date_out,l_display_mask); --8429670
     END IF;
     RETURN p_date_out;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN(p_date_char);
   END;

     FUNCTION get_display_date
       (p_date_char IN VARCHAR2,
        p_date_mask IN VARCHAR2)
     RETURN VARCHAR2
     AS
       -- p_date := p_date_char;
       -- p_mask := p_date_mask;
       l_date DATE;
       l_date_out  VARCHAR2(30);

     BEGIN
       IF(LENGTH(RTRIM(p_date_char)) > 0) THEN
 --          p_date_out := to_char(to_date(p_date_out,g_canonical_mask), p_date_mask);
 --          p_date_out := to_char(FND_DATE.canonical_to_date(p_date_out), p_date_mask);

 --l_date := FND_DATE.canonical_to_date('2003/02/10');
 --l_date_out := to_char(l_date,'DD-MON-YYYY');
             l_date := FND_DATE.canonical_to_date(p_date_char);
             l_date_out := TO_CHAR(l_date,p_date_mask);
       END IF;
       RETURN l_date_out;
     EXCEPTION
       WHEN OTHERS THEN
         RETURN(p_date_char);
   END;


 FUNCTION convert_date
     (p_date_in_char  IN VARCHAR2,
      p_date_in_mask  IN VARCHAR2,
      p_date_out_mask IN VARCHAR2)
   RETURN VARCHAR2
   AS
     -- p_date := p_date_char;
     -- p_mask := p_date_mask;
     p_date_out VARCHAR2(15);

   BEGIN
     p_date_out := TO_CHAR(TO_DATE(p_date_in_char,p_date_in_mask), p_date_out_mask);
     RETURN p_date_out;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
   END;

  /*
  -- mvasudev, 08/17/2004
  Added the following functions for Business Events Enabling
  */
  FUNCTION  check_mass_rebook_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2
  AS
	--cursor to check if the contract is selected for Mass Rebook
	CURSOR  l_chk_mass_rbk_csr
	IS
	SELECT '1'
	FROM   okc_k_headers_b chrb,
	       okl_trx_contracts ktrx
	WHERE  chrb.ID          = p_chr_id
	AND    ktrx.khr_id     =  chrb.id
	AND    ktrx.tsu_code   = 'ENTERED'
	AND    ktrx.rbr_code   IS NOT NULL
	AND    ktrx.tcn_type   = 'TRBK'
        --rkuttiya added for 12.1.1 Multi GAAP
        AND    ktrx.representation_type = 'PRIMARY'
        --
	AND   EXISTS (SELECT '1'
	              FROM   okl_rbk_selected_contract rbk_khr
	              WHERE  rbk_khr.khr_id = chrb.id
	              AND    rbk_khr.status <> 'PROCESSED');


	l_ret_value VARCHAR2(1) := OKL_API.G_FALSE;

  BEGIN

	FOR l_chk_mass_rbk_rec IN l_chk_mass_rbk_csr
	LOOP
	  l_ret_value := OKL_API.G_TRUE;
	EXIT WHEN l_ret_value = OKL_API.G_TRUE;
	END LOOP;

	RETURN l_ret_value;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END check_mass_rebook_contract;

  FUNCTION  check_rebook_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2
  AS

	--cursor to check if the contract is rebooked contract
	CURSOR l_chk_rbk_csr
	IS
	SELECT '1'
	FROM   okc_k_headers_b chrb,
	       okl_trx_contracts ktrx
	WHERE  ktrx.khr_id_new = chrb.id
	AND    ktrx.tsu_code = 'ENTERED'
	AND    ktrx.rbr_code IS NOT NULL
	AND    ktrx.tcn_type = 'TRBK'
    --rkuttiya added for 12.1.1 Multi GAAP
        AND    ktrx.representation_type = 'PRIMARY'
    --
	AND    chrb.id = p_chr_id
	AND    chrb.orig_system_source_codE = 'OKL_REBOOK';

	l_ret_value VARCHAR2(1) := OKL_API.G_FALSE;

  BEGIN

	FOR l_chk_rbk_rec IN l_chk_rbk_csr
	LOOP
	  l_ret_value := OKL_API.G_TRUE;
	EXIT WHEN l_ret_value = OKL_API.G_TRUE;
	END LOOP;

	RETURN l_ret_value;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END check_rebook_contract;

  FUNCTION  check_release_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2
  AS

	--cursor to check if contract is a re-lease contract
	CURSOR l_chk_rel_khr_csr
	IS
	SELECT '1'
	FROM   okc_k_headers_b chrb
	WHERE  chrb.id = p_chr_id
	AND    NVL(chrb.orig_system_source_code,'XXXX') = 'OKL_RELEASE';

	l_ret_value VARCHAR2(1) := OKL_API.G_FALSE;

  BEGIN

	FOR l_chk_rel_khr_rec IN l_chk_rel_khr_csr
	LOOP
	  l_ret_value := OKL_API.G_TRUE;
	EXIT WHEN l_ret_value = OKL_API.G_TRUE;
	END LOOP;

	RETURN l_ret_value;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END check_release_contract;

  FUNCTION  check_release_assets(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2
  AS

		--cursor to check if contract has re-lease assets
		CURSOR l_chk_rel_ast_csr  IS
		SELECT '1'
		FROM   okc_k_headers_b chrb
		WHERE   NVL(chrb.orig_system_source_code,'XXXX') <> 'OKL_RELEASE'
		AND     chrb.ID = p_chr_id
		AND     EXISTS (SELECT '1'
		               FROM   okc_rules_b rul
		               WHERE  rul.dnz_chr_id = chrb.id
		               AND    rul.rule_information_category = 'LARLES'
		               AND    NVL(rule_information1,'N') = 'Y');


	l_ret_value VARCHAR2(1) := OKL_API.G_FALSE;

  BEGIN

	FOR l_chk_rel_ast_rec IN l_chk_rel_ast_csr
	LOOP
	  l_ret_value := OKL_API.G_TRUE;
	EXIT WHEN l_ret_value = OKL_API.G_TRUE;
	END LOOP;

	RETURN l_ret_value;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END check_release_assets;

  FUNCTION  check_split_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2
  AS
	l_ret_value    VARCHAR2(1) DEFAULT '0';
  BEGIN
       -- NEED TO CODE LATER ??
        RETURN OKL_API.G_FALSE;
  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END check_split_contract;

  FUNCTION  check_new_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2
  AS
	l_ret_value    VARCHAR2(1) DEFAULT '0';
  BEGIN

    l_ret_value := check_mass_rebook_contract(p_chr_id);
	IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
	  RETURN OKL_API.G_FALSE;
	-- not a mass rebook
	ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
      l_ret_value := check_rebook_contract(p_chr_id);
	  IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		  RETURN OKL_API.G_FALSE;
	  -- not a rebook
	  ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
        l_ret_value := check_release_contract(p_chr_id);
	    IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		  RETURN OKL_API.G_FALSE;
	    -- not a release contract
	    ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
          l_ret_value := check_release_assets(p_chr_id);
	      IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		    RETURN OKL_API.G_FALSE;
	    ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
          l_ret_value := check_split_contract(p_chr_id);
	      IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		    RETURN OKL_API.G_FALSE;
	          ELSE
	        -- not a release asset contract
		        RETURN OKL_API.G_TRUE;
		      END IF;
	      END IF;
        END IF;
      END IF;
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END check_new_contract;

  FUNCTION get_contract_process(
            p_chr_id IN NUMBER)
  RETURN VARCHAR2
  AS
	l_ret_value    VARCHAR2(1) DEFAULT '0';
	l_process VARCHAR2(20);

  BEGIN

    l_ret_value := check_mass_rebook_contract(p_chr_id);
	IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
	  RETURN G_KHR_PROCESS_MASS_REBOOK;
	-- not a mass rebook
	ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
      l_ret_value := check_rebook_contract(p_chr_id);
	  IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		  RETURN G_KHR_PROCESS_REBOOK;
	  -- not a rebook
	  ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
        l_ret_value := check_release_contract(p_chr_id);
	    IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		  RETURN G_KHR_PROCESS_RELEASE_CONTRACT;
	    -- not a release contract
	    ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
          l_ret_value := check_release_assets(p_chr_id);
	      IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		    RETURN G_KHR_PROCESS_RELEASE_ASSETS;
	    ELSIF (l_ret_value=OKL_API.G_FALSE) THEN
          l_ret_value := check_split_contract(p_chr_id);
	      IF (l_ret_value IS NOT NULL) AND (l_ret_value = OKL_API.G_TRUE) THEN
		    RETURN G_KHR_PROCESS_SPLIT_CONTRACT;
          ELSE
	        -- not a release asset contract
            RETURN G_KHR_PROCESS_NEW;
		      END IF;
	      END IF;
        END IF;
      END IF;
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END get_contract_process;

  FUNCTION is_lease_contract(
          p_chr_id okc_k_headers_b.id%TYPE)
  RETURN VARCHAR2
  IS
    CURSOR l_okl_chr_scs_csr
    IS
    SELECT scs_code
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    l_scs_code okc_k_headers_b.scs_code%TYPE := NULL;
    l_return_value VARCHAR2(1):= OKL_API.G_FALSE;
  BEGIN
    FOR l_okl_chr_scs_rec IN l_okl_chr_scs_csr
    LOOP
      IF (l_okl_chr_scs_rec.scs_code IS NOT NULL AND l_okl_chr_scs_rec.scs_code = 'LEASE') THEN
       l_return_value := OKL_API.G_TRUE;
      END IF;
    END LOOP;

   RETURN l_return_value;

  END is_lease_contract;

  /* -- end, mvasudev, 08/17/2004 */

  -- mvasudev,| 07-25-2005 cklee/mvasudev -- Fixed 11.5.9 Bug#4392051/okl.h 4437938        |

     /* rajose
       The following function is called for calculation of contract end date and payment
       structure end date.
       P_start_day i/p parameter is the differentiating factor.
           If p_start_day is null the logic for calculating contract end date is followed else logic for
           payment structure end dates is followed.
           If p_start_day is passed its mandatory to pass the contract end date, as the contract end
           date is used to check whether the payment structure end date has reached the end date of the contract.
           If contract end dated has not reached or contract end date is not passed, the end date calculation
           of the payment structure follows OKL G logic of add_months(start_date,period) -1.
    */
  FUNCTION calculate_end_date(
            p_start_date              IN  DATE,
            p_months         IN  NUMBER,
            p_start_day IN NUMBER DEFAULT NULL,
            p_contract_end_date IN DATE DEFAULT NULL --Bug#5441811
            )
  RETURN DATE
  IS
    l_next_start_date DATE;

    l_next_start_day  NUMBER;
    l_next_start_month   NUMBER;
    l_next_start_year   NUMBER;
    l_start_month   NUMBER;

    l_start_last_day NUMBER;
	l_next_start_last_day NUMBER;

	l_end_date DATE;
    l_start_day NUMBER;
    l_end_day  NUMBER;

    --Bug 6007644
    l_return_status      VARCHAR2(1);
    l_temp_day           NUMBER;
    l_temp_month         NUMBER;
    l_temp_year          NUMBER;
    --end Bug 6007644

  BEGIN

    -- Bug 6007644
    OKL_STREAM_GENERATOR_PVT.add_months_new(p_start_date    => p_start_date,
                                            p_months_after  => p_months,
                                            x_date          => l_end_date,
                                            x_return_status => l_return_status);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --end Bug 6007644

    IF p_start_day IS NOT NULL THEN

    --Bug 6007644
      IF p_start_day = 31 THEN
        l_end_date := LAST_DAY(l_end_date);
      END IF;

      IF(p_start_day in(29, 30)) THEN
        l_temp_month := to_char(l_end_date, 'MM');
        l_temp_year  := to_char(l_end_date, 'YYYY');
        IF(l_temp_month = 2) THEN
          IF  mod(l_temp_year,400 ) = 0 OR (mod(l_temp_year, 100) <> 0 AND mod(l_temp_year,4) = 0)
          THEN
            -- Leap Year is divisible by 4, but not with 100 except for the years which are divisible by 400
            -- Like 1900 is not leap year, but 2000 is a leap year
            l_temp_day := 29;
          ELSE
            -- Its a non Leap Year
            l_temp_day := 28;
          END IF;
        ELSE
          l_temp_day := p_start_day;
        END IF;
        l_end_date := to_date(l_temp_day || '-' || l_temp_month || '-' || l_temp_year, 'DD-MM-YYYY');
      END IF;
      --end Bug 6007644

    END IF;

    -- Bug 6007644
    l_end_date := l_end_date - 1;
    -- end Bug 6007644

   RETURN (l_end_date);

   EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END calculate_end_date;
  -- end,| 07-25-2005 cklee/mvasudev -- Fixed 11.5.9 Bug#4392051/okl.h 4437938        |

  --Bug# 4959361
  PROCEDURE check_line_update_allowed(p_api_version   IN  NUMBER,
                                      p_init_msg_list IN  VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      p_cle_id        IN  NUMBER) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_LINE_UPDATE_ALLOWED';
    l_api_version     CONSTANT NUMBER	:= 1.0;

    --cursor to check line status
    CURSOR l_cle_csr(p_cle_id IN NUMBER)
    IS
    SELECT cle.sts_code,
           cle.dnz_chr_id
    FROM   okc_k_lines_b cle
    WHERE  cle.id = p_cle_id;

    l_cle_rec l_cle_csr%ROWTYPE;
    l_chk_rebook_chr VARCHAR2(1);

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
       p_api_name      => l_api_name,
       p_pkg_name      => g_pkg_name,
       p_init_msg_list => p_init_msg_list,
       l_api_version   => l_api_version,
       p_api_version   => p_api_version,
       p_api_type      => '_PVT',
       x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    OPEN l_cle_csr(p_cle_id => p_cle_id);
    FETCH l_cle_csr INTO l_cle_rec;
    CLOSE l_cle_csr;

    l_chk_rebook_chr := OKL_LLA_UTIL_PVT.check_rebook_contract(p_chr_id => l_cle_rec.dnz_chr_id);

    IF (l_chk_rebook_chr = OKL_API.G_TRUE AND l_cle_rec.sts_code = 'TERMINATED') THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_LA_RBK_TER_LINE_UPDATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END check_line_update_allowed;
  --Bug# 4959361
    --added by asawanka
  -- p_kle_id is top line id.  select id from okc_k_lines_b where cle_id is null
  -- p_khr_id is contract id
   FUNCTION  get_asset_location(
            p_kle_id IN NUMBER,
            p_khr_id IN NUMBER)
           RETURN VARCHAR2 IS
    CURSOR l_khr_status_csr IS
     SELECT STS_CODE
     FROM okc_k_headers_all_b
     WHERE ID = p_khr_id;

    CURSOR l_get_booked_Astloc_csr IS
       SELECT SUBSTR(ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,HL.ADDRESS1,HL.ADDRESS2,HL.ADDRESS3,
             HL.ADDRESS4,HL.CITY,HL.COUNTY,HL.STATE,HL.PROVINCE,HL.POSTAL_CODE,NULL,HL.COUNTRY,
             NULL, NULL,NULL,NULL,NULL,NULL,NULL,'N','N',80,1,1),1,80) DESCRIPTION
       FROM  HZ_LOCATIONS HL,
             CSI_ITEM_INSTANCES CSI,
             OKC_K_ITEMS CIM
       WHERE CIM.CLE_ID = (SELECT A.ID
                           FROM OKC_K_LINES_V A,
                                OKC_LINE_STYLES_B B
                           WHERE CLE_ID = (SELECT A.ID
                                           FROM OKC_K_LINES_V A,
                                                OKC_LINE_STYLES_B B
                                           WHERE CLE_ID = p_kle_id
                                           AND A.LSE_ID = B.ID
                                           AND A.dnz_chr_id = p_khr_id
                                           AND B.LTY_CODE = 'FREE_FORM2')
                           AND A.LSE_ID = B.ID
                           AND A.dnz_chr_id = p_khr_id
                           AND B.LTY_CODE = 'INST_ITEM')
      AND    CIM.DNZ_CHR_ID = p_khr_id
      AND    CIM.OBJECT1_ID1         = CSI.INSTANCE_ID
      AND    CIM.OBJECT1_ID2         = '#'
      AND    CIM.JTOT_OBJECT1_CODE   = 'OKX_IB_ITEM'
      AND    CSI.INSTALL_LOCATION_ID = HL.LOCATION_ID
      AND    CSI.INSTALL_LOCATION_TYPE_CODE  = 'HZ_LOCATIONS'
     UNION
      SELECT SUBSTR(ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS(NULL,HL.ADDRESS1,HL.ADDRESS2,HL.ADDRESS3,
             HL.ADDRESS4,HL.CITY,HL.COUNTY,HL.STATE,HL.PROVINCE,HL.POSTAL_CODE,NULL,HL.COUNTRY,
             NULL, NULL,NULL,NULL,NULL,NULL,NULL,'N','N',80,1,1),1,80) DESCRIPTION
      FROM   HZ_LOCATIONS HL,
             HZ_PARTY_SITES HPS,
             CSI_ITEM_INSTANCES CSI,
             OKC_K_ITEMS CIM
      WHERE  CIM.CLE_ID = (SELECT A.ID
                           FROM OKC_K_LINES_V A,
                                OKC_LINE_STYLES_B B
                           WHERE CLE_ID = (SELECT A.ID
                                           FROM OKC_K_LINES_V A,
                                                OKC_LINE_STYLES_B B
                                           WHERE CLE_ID = p_kle_id
                                           AND A.LSE_ID = B.ID
                                           AND A.dnz_chr_id = p_khr_id
                                           AND B.LTY_CODE = 'FREE_FORM2')
                           AND A.LSE_ID = B.ID
                           AND A.dnz_chr_id = p_khr_id
                           AND B.LTY_CODE = 'INST_ITEM')
      AND    CIM.DNZ_CHR_ID = p_khr_id
      AND    CIM.OBJECT1_ID1         = CSI.INSTANCE_ID
      AND    CIM.OBJECT1_ID2         = '#'
      AND    CIM.JTOT_OBJECT1_CODE   = 'OKX_IB_ITEM'
      AND    CSI.INSTALL_LOCATION_ID = HPS.PARTY_SITE_ID
      AND    HPS.LOCATION_ID         = HL.LOCATION_ID
      AND    CSI.INSTALL_LOCATION_TYPE_CODE  = 'HZ_PARTY_SITES';

   CURSOR l_get_nonbooked_Astloc_csr IS
      SELECT  B.DESCRIPTION
      FROM OKX_PARTY_SITE_USES_V B
      WHERE B.ID1 = (SELECT A.OBJECT_ID1_NEW
                     FROM OKL_TXL_ITM_INSTS_V A
                     WHERE A.KLE_ID = (SELECT A.ID
                                       FROM OKC_K_LINES_V A,
                                            OKC_LINE_STYLES_B B
                                       WHERE CLE_ID = (SELECT A.ID
                                                       FROM OKC_K_LINES_V A,
                                                            OKC_LINE_STYLES_B B
                                                       WHERE CLE_ID = p_kle_id
                                                       AND A.LSE_ID = B.ID
                                                       AND A.dnz_chr_id = p_khr_id
                                                       AND B.LTY_CODE = 'FREE_FORM2')
                                       AND A.LSE_ID = B.ID
                                       AND A.dnz_chr_id = p_khr_id
                                       AND B.LTY_CODE = 'INST_ITEM'))
      AND   B.ID2 = '#';
     l_khr_sts  VARCHAR2(240);
     l_asset_loc VARCHAR2(240) := NULL;

   BEGIN
     IF p_khr_id IS NULL OR p_kle_id is NULL THEN
      RETURN NULL;
     END IF;

     OPEN l_khr_status_csr;
     FETCH l_khr_status_csr INTO l_khr_sts;
     CLOSE l_khr_status_csr;

     IF l_khr_sts = 'BOOKED' THEN
       OPEN l_get_booked_Astloc_csr;
       FETCH l_get_booked_Astloc_csr INTO l_asset_loc;
       CLOSE l_get_booked_Astloc_csr;
     ELSE
       OPEN l_get_nonbooked_Astloc_csr;
       FETCH l_get_nonbooked_Astloc_csr INTO l_asset_loc;
       CLOSE l_get_nonbooked_Astloc_csr;
     END IF;

     RETURN l_asset_loc;

    EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
   END get_asset_location;
      --added by asawanka
  -- p_kle_id is top line id.  select id from okc_k_lines_b where cle_id is null
  -- p_khr_id is contract id
   FUNCTION  get_ast_install_loc_id(
            p_kle_id IN NUMBER,
            p_khr_id IN NUMBER)
           RETURN NUMBER IS
    CURSOR l_khr_status_csr IS
     SELECT STS_CODE
     FROM okc_k_headers_all_b
     WHERE ID = p_khr_id;

    CURSOR l_get_booked_Astloc_csr IS
       SELECT psu.party_site_use_id
       FROM  HZ_LOCATIONS HL,
             CSI_ITEM_INSTANCES CSI,
             OKC_K_ITEMS CIM,
             hz_party_site_uses psu,
             hz_party_sites hps
       WHERE CIM.CLE_ID in (SELECT A.ID
                           FROM OKC_K_LINES_V A,
                                OKC_LINE_STYLES_B B
                           WHERE CLE_ID in (SELECT A.ID
                                           FROM OKC_K_LINES_V A,
                                                OKC_LINE_STYLES_B B
                                           WHERE CLE_ID = p_kle_id
                                           AND A.LSE_ID = B.ID
                                           AND A.dnz_chr_id = p_khr_id
                                           AND B.LTY_CODE = 'FREE_FORM2')
                           AND A.LSE_ID = B.ID
                           AND A.dnz_chr_id = p_khr_id
                           AND B.LTY_CODE = 'INST_ITEM')
      AND    CIM.DNZ_CHR_ID = p_khr_id
      AND    CIM.OBJECT1_ID1         = CSI.INSTANCE_ID
      AND    CIM.OBJECT1_ID2         = '#'
      AND    CIM.JTOT_OBJECT1_CODE   = 'OKX_IB_ITEM'
      AND    CSI.INSTALL_LOCATION_ID = HL.LOCATION_ID
      AND    CSI.INSTALL_LOCATION_TYPE_CODE  = 'HZ_LOCATIONS'
      AND    psu.site_use_type ='INSTALL_AT'
      AND    psu.party_site_id = hps.party_site_id
      AND    hps.location_id = hl.location_id
     UNION
      SELECT psu.party_site_use_id
      FROM   HZ_LOCATIONS HL,
             HZ_PARTY_SITES HPS,
             HZ_PARTY_SITE_USES PSU,
             CSI_ITEM_INSTANCES CSI,
             OKC_K_ITEMS CIM
      WHERE  CIM.CLE_ID in (SELECT A.ID
                           FROM OKC_K_LINES_V A,
                                OKC_LINE_STYLES_B B
                           WHERE CLE_ID in (SELECT A.ID
                                           FROM OKC_K_LINES_V A,
                                                OKC_LINE_STYLES_B B
                                           WHERE CLE_ID = p_kle_id
                                           AND A.LSE_ID = B.ID
                                           AND A.dnz_chr_id = p_khr_id
                                           AND B.LTY_CODE = 'FREE_FORM2')
                           AND A.LSE_ID = B.ID
                           AND A.dnz_chr_id = p_khr_id
                           AND B.LTY_CODE = 'INST_ITEM')
      AND    CIM.DNZ_CHR_ID = p_khr_id
      AND    CIM.OBJECT1_ID1         = CSI.INSTANCE_ID
      AND    CIM.OBJECT1_ID2         = '#'
      AND    CIM.JTOT_OBJECT1_CODE   = 'OKX_IB_ITEM'
      AND    CSI.INSTALL_LOCATION_ID = HPS.PARTY_SITE_ID
      AND    HPS.LOCATION_ID         = HL.LOCATION_ID
      AND    CSI.INSTALL_LOCATION_TYPE_CODE  = 'HZ_PARTY_SITES'
      AND    psu.party_site_id = hps.party_site_id
      AND    psu.site_use_type = 'INSTALL_AT';

   CURSOR l_get_nonbooked_Astloc_csr IS
      SELECT A.OBJECT_ID1_NEW
                     FROM OKL_TXL_ITM_INSTS_V A
                     WHERE A.KLE_ID IN (SELECT A.ID
                                       FROM OKC_K_LINES_V A,
                                            OKC_LINE_STYLES_B B
                                       WHERE CLE_ID IN (SELECT A.ID
                                                       FROM OKC_K_LINES_V A,
                                                            OKC_LINE_STYLES_B B
                                                       WHERE CLE_ID = p_kle_id
                                                       AND A.LSE_ID = B.ID
                                                       AND A.dnz_chr_id = p_khr_id
                                                       AND B.LTY_CODE = 'FREE_FORM2')
                                       AND A.LSE_ID = B.ID
                                       AND A.dnz_chr_id = p_khr_id
                                       AND B.LTY_CODE = 'INST_ITEM');
     l_khr_sts  VARCHAR2(240);
     l_asset_loc NUMBER := NULL;

   BEGIN
     IF p_khr_id IS NULL OR p_kle_id is NULL THEN
      RETURN NULL;
     END IF;

     OPEN l_khr_status_csr;
     FETCH l_khr_status_csr INTO l_khr_sts;
     CLOSE l_khr_status_csr;

     IF l_khr_sts = 'BOOKED' THEN
       OPEN l_get_booked_Astloc_csr;
       FETCH l_get_booked_Astloc_csr INTO l_asset_loc;
       CLOSE l_get_booked_Astloc_csr;
     ELSE
       OPEN l_get_nonbooked_Astloc_csr;
       FETCH l_get_nonbooked_Astloc_csr INTO l_asset_loc;
       CLOSE l_get_nonbooked_Astloc_csr;
     END IF;

     RETURN l_asset_loc;

    EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
   END get_ast_install_loc_id;
  --added by asawanka
  -- p_kle_id is top line id.  select id from okc_k_lines_b where cle_id is null
  -- p_khr_id is contract id
   FUNCTION  get_booked_asset_number(
            p_kle_id IN NUMBER,
            p_khr_id IN NUMBER)
           RETURN VARCHAR2 IS
    CURSOR l_khr_status_csr IS
     SELECT STS_CODE
     FROM okc_k_headers_all_b
     WHERE ID = p_khr_id;

    CURSOR l_get_booked_astnum_csr IS
    SELECT FAV.ASSET_NUMBER ASSETNUMBER
    FROM  OKC_K_LINES_V CLE_FIN
        , OKC_LINE_STYLES_B LSE_FIN
        , OKC_K_LINES_B CLE_FA
        , OKC_LINE_STYLES_B LSE_FA
        , OKC_K_ITEMS CIM_FA
        , FA_ADDITIONS_B FAV
    WHERE CLE_FIN.CLE_ID IS NULL
        AND CLE_FIN.id = p_kle_id
        AND CLE_FIN.DNZ_CHR_ID = p_khr_id
        AND LSE_FIN.ID = CLE_FIN.LSE_ID
        AND LSE_FIN.LTY_CODE = 'FREE_FORM1'
        AND CLE_FA.CLE_ID = CLE_FIN.ID
        AND CLE_FA.LSE_ID = LSE_FA.ID
        AND LSE_FA.LTY_CODE = 'FIXED_ASSET'
        AND CIM_FA.CLE_ID = CLE_FA.ID
        AND CIM_FA.OBJECT1_ID1 = FAV.ASSET_ID
        AND CIM_FA.OBJECT1_ID2 = '#'  ;

     l_asset_num VARCHAR2(240);
     l_khr_sts  VARCHAR2(30);
   BEGIN
     IF p_khr_id IS NULL OR p_kle_id is NULL THEN
      RETURN NULL;
     END IF;

     OPEN l_khr_status_csr;
     FETCH l_khr_status_csr INTO l_khr_sts;
     CLOSE l_khr_status_csr;

     IF l_khr_sts = 'BOOKED' THEN
       OPEN l_get_booked_Astnum_csr;
       FETCH l_get_booked_Astnum_csr INTO l_asset_num;
       CLOSE l_get_booked_Astnum_csr;
     ELSE
       l_asset_num := NULL;
     END IF;

     RETURN l_asset_num;

    EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
   END get_booked_asset_number;

-- Added procedure as part of Bug#6651871 to create Pay Site for Supplier start

PROCEDURE create_pay_site(
            party_id                  IN NUMBER,
	    party_site_id             IN NUMBER := NULL, -- added to create pay site
	    p_org_id                  IN NUMBER, -- added to create pay site
	    p_api_version             IN NUMBER,
	    p_init_msg_list           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2
	    )
IS
    l_proc_name   VARCHAR2(35)    := 'create_pay_site';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;
    l_vendor_site_rec_type AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
    l_vendor_site_rec_upd AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
    l_vendor_site_id NUMBER;
    l_party_site_id NUMBER;
    l_location_id NUMBER;
    l_vendor_id NUMBER;
    l_party_site_number VARCHAR2(30);
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(200);
    l_address_line1 VARCHAR2(240);
    l_city VARCHAR2(60);
    l_state VARCHAR2(60);
    l_zip VARCHAR2(60);
    l_country VARCHAR2(60);
    l_county VARCHAR2(60);
    l_address_style VARCHAR2(30);
    l_province VARCHAR2(60);

CURSOR get_party_site_info(p_party_id NUMBER)
IS
select hzps.party_site_id
      ,hzps.location_id
      ,aps.vendor_id
      ,hzps.party_site_number
      ,hzl.address1
      ,hzl.city
      ,hzl.state
      ,hzl.postal_code
      ,hzl.country
      ,hzl.county
      ,hzl.address_style
      ,hzl.province
from
      hz_party_sites hzps
     ,hz_parties hz
     ,ap_suppliers aps
     ,hz_locations hzl
where
      hzps.party_id = hz.party_id
and   hzps.IDENTIFYING_ADDRESS_FLAG = 'Y'
and   hz.party_id = aps.party_id
and   hz.party_id = p_party_id
and   hzps.location_id = hzl.location_id;


CURSOR get_location_id(p_party_site_id NUMBER)
IS
select
       hzps.location_id
      ,hzps.party_site_number
      ,aps.vendor_id
      ,hzl.address1
      ,hzl.city
      ,hzl.state
      ,hzl.postal_code
      ,hzl.country
      ,hzl.county
      ,hzl.address_style
      ,hzl.province
from
   hz_party_sites hzps
  ,ap_suppliers aps
  ,hz_locations hzl
where
     hzps.party_id = aps.party_id
and  party_site_id = p_party_site_id
and   hzps.location_id = hzl.location_id;

BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => l_return_status);

      -- check if activity started successfully
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

   IF(party_site_id IS NOT NULL AND party_site_id <> OKL_API.G_MISS_NUM) THEN
     l_party_site_id := party_site_id;
     OPEN get_location_id(l_party_site_id);
     FETCH get_location_id
     INTO l_location_id, l_party_site_number, l_vendor_id, l_address_line1,
          l_city, l_state, l_zip, l_country, l_county, l_address_style, l_province;
     CLOSE get_location_id;
   ELSE
     OPEN get_party_site_info(party_id);
     FETCH get_party_site_info
     INTO l_party_site_id, l_location_id, l_vendor_id, l_party_site_number,l_address_line1,
          l_city, l_state, l_zip, l_country, l_county, l_address_style, l_province;
     CLOSE get_party_site_info;
  END IF;

  l_vendor_site_rec_type.org_id := p_org_id;
  l_vendor_site_rec_type.party_site_id := l_party_site_id;
  l_vendor_site_rec_type.location_id := l_location_id;
  l_vendor_site_rec_type.vendor_id := l_vendor_id;
  l_vendor_site_rec_type.VENDOR_SITE_CODE := substr(l_party_site_number, 0, 14);
  l_vendor_site_rec_type.PURCHASING_SITE_FLAG := 'N';
  l_vendor_site_rec_type.PRIMARY_PAY_SITE_FLAG := 'N';
  l_vendor_site_rec_type.PAY_SITE_FLAG := 'Y';


  POS_VENDOR_PUB_PKG.Create_Vendor_Site
  (
     p_vendor_site_rec => l_vendor_site_rec_type,
     x_return_status  => l_return_status,
     x_msg_count      => l_msg_count,
     x_msg_data       => l_msg_data,
     x_vendor_site_id => l_vendor_site_id,
     x_party_site_id  => l_party_site_id,
     x_location_id    => l_location_id
  );
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  l_vendor_site_rec_upd.vendor_site_id := l_vendor_site_id;
  l_vendor_site_rec_upd.party_site_id := l_party_site_id;
  l_vendor_site_rec_upd.vendor_id := l_vendor_id;
  l_vendor_site_rec_upd.ADDRESS_LINE1 := l_address_line1;
  l_vendor_site_rec_upd.CITY := l_city;
  l_vendor_site_rec_upd.STATE := l_state;
  l_vendor_site_rec_upd.ZIP := l_zip;
  l_vendor_site_rec_upd.COUNTRY := l_country;
  l_vendor_site_rec_upd.COUNTY := l_county;
  l_vendor_site_rec_upd.ADDRESS_STYLE := l_address_style;
  l_vendor_site_rec_upd.PROVINCE := l_province;

 POS_VENDOR_PUB_PKG.Update_Vendor_Site
(
  p_vendor_site_rec => l_vendor_site_rec_upd,
  x_return_status  => l_return_status,
  x_msg_count      => l_msg_count,
  x_msg_data       => l_msg_data
  );

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


  OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                       x_msg_data    => x_msg_data);
EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);
END create_pay_site;

-- Added procedure as part of Bug#6651871 to create Pay Site for Supplier end

-- Added procedure as part of Bug#6636587 to Create Vendor for a Party in TCA start

PROCEDURE create_related_vendor(
            party_id                  IN NUMBER,
	    party_site_id             IN NUMBER := NULL, -- added to create pay site
	    p_org_id                  IN NUMBER , -- added to create pay site
	    p_api_version             IN NUMBER,
	    p_init_msg_list           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2
	    )
IS
    l_proc_name   VARCHAR2(35)    := 'create_related_vendor';
    l_api_version CONSTANT VARCHAR2(30) := p_api_version;
    l_vendor_rec APPS.AP_VENDOR_PUB_PKG.R_VENDOR_REC_TYPE;
    l_vendor_id NUMBER;
    l_party_id NUMBER;
    l_party_site_id NUMBER;
    l_org_id NUMBER;
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_init_msg_list VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(200);


BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY(
            p_api_name      => l_api_name,
            p_pkg_name      => G_PKG_NAME,
            p_init_msg_list => p_init_msg_list,
            l_api_version   => l_api_version,
            p_api_version   => p_api_version,
            p_api_type      => G_API_TYPE,
            x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     l_party_site_id := party_site_id;
     l_org_id := p_org_id;
     l_vendor_rec.PARTY_ID := party_id;

     pos_vendor_pub_pkg.create_vendor(
      p_vendor_rec    => l_vendor_rec,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data ,
      x_vendor_id     => l_vendor_id,
      x_party_id      => l_party_id);

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    create_pay_site(
           party_id => l_party_id,
	   party_site_id => l_party_site_id,
           p_org_id => l_org_id,
	   p_api_version => l_api_version,
	   p_init_msg_list => l_init_msg_list,
           x_return_status => l_return_status,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data
	    );

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);



 EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

  END create_related_vendor;
-- Added procedure as part of Bug#6636587 to Create Vendor for a Party in TCA start

-- Added to create Pay Site for Supplier end

  --Bug# 8370699
  FUNCTION  get_last_activation_date(
            p_chr_id IN NUMBER)
            RETURN DATE
  AS
	--cursor to fetch last activation date
	CURSOR  l_last_activation_date_csr(p_chr_id IN NUMBER)
	IS
	SELECT MAX(ktrx.transaction_date)
	FROM   okc_k_headers_b chrb,
	       okl_trx_contracts ktrx
	WHERE  chrb.id         =  p_chr_id
	AND    ktrx.khr_id     =  chrb.id
	AND    ktrx.tsu_code   = 'PROCESSED'
	AND    ktrx.tcn_type   IN ('TRBK','SPA','BKG','REL')
      AND    ktrx.representation_type = 'PRIMARY';

	l_last_activation_date DATE;

  BEGIN

      OPEN l_last_activation_date_csr(p_chr_id => p_chr_id);
      FETCH l_last_activation_date_csr INTO l_last_activation_date;
      CLOSE l_last_activation_date_csr;

	RETURN l_last_activation_date;

  EXCEPTION
     WHEN OTHERS THEN
       RETURN(NULL);
  END get_last_activation_date;

--==================================================================
-- New procedure added to establish external ID for the contract
-- where new lines are added.
--==================================================================
/*
procedure update_external_id (p_chr_id in number,
                              x_return_status OUT NOCOPY VARCHAR2) IS

 cursor get_line_details_csr(p_chr_id in number) IS
 SELECT KLE.ID ID
   FROM OKL_K_LINES KLE, OKC_K_LINES_B CLE
  WHERE CLE.DNZ_CHR_ID = p_chr_id
    AND CLE.ID = KLE.ID
    AND CLE.LSE_ID in (33, 52, 53, 70) -- 48
    AND cle.sts_code NOT IN ('HOLD', 'EXPIRED', 'CANCELLED','ABANDONED', 'TERMINATED')
    AND kle.orig_contract_line_id is null;

cursor get_vendor_extid_csr(p_chr_id in number) is
    SELECT vDtls.ID
      FROM okl_party_payment_hdr vHdr,
           okl_party_payment_dtls vDtls,
           okc_k_lines_b cle,
           okl_k_lines kle
     WHERE vDtls.payment_hdr_id = vHdr.id
       AND vHdr.CLE_ID = cle.id
       AND vHdr.DNZ_CHR_ID = p_chr_id
       AND vHdr.PASSTHRU_TERM = 'BASE'
       AND vHdr.DNZ_CHR_ID = cle.dnz_chr_id
       AND cle.lse_id = 52
       AND cle.id = kle.id
       AND cle.sts_code NOT IN ('HOLD', 'EXPIRED', 'CANCELLED','ABANDONED', 'TERMINATED')
       and kle.fee_type = 'PASSTHROUGH'
       and vDtls.orig_contract_line_id is null;

TYPE EXTR_ID_TBL is table of number index by binary_integer;
T_EXTR_ID_TBL EXTR_ID_TBL;
l_api_name		CONSTANT  VARCHAR2(30) := 'UPDATE_EXTERNAL_ID';
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_init_msg_list VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(200);
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,l_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  OPEN get_line_details_csr(p_chr_id);
  FETCH get_line_details_csr bulk collect into t_extr_id_tbl;
  CLOSE get_line_details_csr;

  if t_extr_id_tbl.count > 0 then
    forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
      update okl_k_lines
         set orig_contract_line_id = t_extr_id_tbl(i)
       where id = t_extr_id_tbl(i)
         and orig_contract_line_id is null;
  end if;

  t_extr_id_tbl.delete;

  open get_vendor_extid_csr(p_chr_id);
  fetch get_vendor_extid_csr bulk collect into t_extr_id_tbl;
  close get_vendor_extid_csr;

  if t_extr_id_tbl.count > 0 then
    forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
    update okl_party_payment_dtls
       set orig_contract_line_id = t_extr_id_tbl(i)
     where id = t_extr_id_tbl(i)
       and orig_contract_line_id is null;
  end if;

  t_extr_id_tbl.delete;

exception
    WHEN OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               l_msg_count,
                               l_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                l_msg_count,
                                l_msg_data,
                                '_PVT');
    WHEN OTHERS then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                l_msg_count,
                                l_msg_data,
                                '_PVT');
END update_external_id;
*/

--==================================================================
-- New procedure added to establish external ID for the contract
-- where new lines are added.
--==================================================================
--==================================================================
-- New procedure added to establish external ID for the contract
-- where new lines are added.
--==================================================================
procedure update_external_id (p_chr_id in number,
                              x_return_status OUT NOCOPY VARCHAR2) IS

 cursor get_line_details_csr(p_chr_id in number) IS
 SELECT KLE.ID ID
   FROM OKL_K_LINES KLE, OKC_K_LINES_B CLE
  WHERE CLE.DNZ_CHR_ID = p_chr_id
    AND CLE.ID = KLE.ID
    AND CLE.LSE_ID in (33, 52, 53, 70) -- 48
    AND cle.sts_code NOT IN ('HOLD', 'EXPIRED', 'CANCELLED','ABANDONED', 'TERMINATED')
    AND kle.orig_contract_line_id is null;

 cursor get_upg_line_details_csr(p_orig_chr_id in number) IS
 SELECT kle.id, kle.orig_contract_line_id
   FROM OKL_K_LINES KLE, OKC_K_LINES_B CLE
  WHERE CLE.DNZ_CHR_ID = p_orig_chr_id
    AND CLE.ID = KLE.ID
    AND CLE.LSE_ID in (33, 52, 53, 70) -- 48
    AND cle.sts_code NOT IN ('HOLD', 'EXPIRED', 'CANCELLED','ABANDONED', 'TERMINATED');


cursor get_vendor_extid_csr(p_chr_id in number) is
    SELECT vDtls.ID
      FROM okl_party_payment_hdr vHdr,
           okl_party_payment_dtls vDtls,
           okc_k_lines_b cle,
           okl_k_lines kle,
	   okc_k_headers_all_b chr
     WHERE vDtls.payment_hdr_id = vHdr.id
       AND vHdr.CLE_ID = cle.id
       AND vHdr.DNZ_CHR_ID = p_chr_id
       AND vHdr.PASSTHRU_TERM = 'BASE'
       AND vHdr.DNZ_CHR_ID = cle.dnz_chr_id
       AND cle.lse_id = 52
       AND cle.id = kle.id
       AND cle.sts_code NOT IN ('HOLD', 'EXPIRED', 'CANCELLED','ABANDONED', 'TERMINATED')
       and kle.fee_type = 'PASSTHROUGH'
       and vDtls.orig_contract_line_id is null;

TYPE EXTR_ID_TBL is table of number index by binary_integer;
T_EXTR_ID_TBL           EXTR_ID_TBL;
t_orig_chr_id_tbl       extr_id_tbl;
t_orig_cle_id_tbl       extr_id_tbl;
t_vendor_id_tbl         extr_id_tbl;

l_orig_chr_id           number;

cursor get_orig_vendor_dtls(p_orig_chr_id in number) IS
    SELECT vDtls.orig_contract_line_id, vDtls.vendor_id, cle.id
      FROM okl_party_payment_hdr vHdr,
           okl_party_payment_dtls vDtls,
           okc_k_lines_b cle,
           okl_k_lines kle
     WHERE vDtls.payment_hdr_id = vHdr.id
       AND vHdr.CLE_ID = cle.id
       AND vHdr.PASSTHRU_TERM = 'BASE'
       AND vHdr.DNZ_CHR_ID = cle.dnz_chr_id
       AND cle.lse_id = 52
       AND cle.id = kle.id
       and kle.fee_type = 'PASSTHROUGH'
       AND cle.sts_code NOT IN ('HOLD', 'EXPIRED', 'CANCELLED','ABANDONED', 'TERMINATED')
       AND vHdr.DNZ_CHR_ID = p_orig_chr_id;

l_orig_pymnt_dtl_id     number;

    CURSOR is_rbk_on_csr( p_khr_id    IN NUMBER)
    IS
    SELECT 'Y' online_rebook_in_progress,
           orig_chr.id
      FROM okc_k_headers_all_b   rbk_chr,
           okc_k_headers_all_b   orig_chr,
           okl_trx_contracts_all trx
     WHERE rbk_chr.id = p_khr_id
       AND rbk_chr.orig_system_source_code = 'OKL_REBOOK'
       AND trx.khr_id_new = rbk_chr.id
       AND trx.tsu_code = 'ENTERED'
       AND trx.tcn_type = 'TRBK'
       AND rbk_chr.orig_system_id1 = orig_chr.id;

l_rbk_in_progress       VARCHAR2(1);

l_api_name		CONSTANT  VARCHAR2(30) := 'UPDATE_EXTERNAL_ID';
l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_init_msg_list         VARCHAR2(1) DEFAULT OKL_API.G_FALSE;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(200);
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,l_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  -- find out if an online rebook process is in progress
  -- if the call is coming from the 'Price' button, the processing is different.
  open is_rbk_on_csr(p_chr_id);
  fetch is_rbk_on_csr into l_rbk_in_progress, l_orig_chr_id;
  close is_rbk_on_csr;

  -- There are 2 scenarios present for establishing the exernal_id:
  -- a. Upgrade calls to establish the external_id for the first time
  -- b. Price button on the revision page. There are 2 variations in this:
  --    ( i) Pricing happens for a new or an already upgraded contract
  --    (ii) Pricing for an online rebook copy happens after the contract is upgraded using the 'Upgrade' button
  --
  -- In the case of (a.) above, the line_id will be set as the external_id, orig_system_id1 will be null
  -- In the case of (b. i):
  --    For new, external_id will be the line_id
  --    For upgraded, only new lines added during the revision will have external_id. in this case, it'll be the line_id
  -- In the case of (b. ii):
  --   The original contract gets upgraded, and external_id is established.
  --   The rebook copy is not in sync with the original for external_ids.
  --   In this case, the original_system_id1 needs to updated to the rebook copy.

  if l_rbk_in_progress is null then

    OPEN get_line_details_csr(p_chr_id);
    FETCH get_line_details_csr bulk collect into t_extr_id_tbl;
    CLOSE get_line_details_csr;

    if t_extr_id_tbl.count > 0 then
      forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
        update okl_k_lines
           set orig_contract_line_id = t_extr_id_tbl(i)
         where id = t_extr_id_tbl(i)
           and orig_contract_line_id is null;
    end if;

    t_extr_id_tbl.delete;

  elsif l_rbk_in_progress = 'Y' then
    open get_upg_line_details_csr(l_orig_chr_id);
    fetch get_upg_line_details_csr bulk collect into t_orig_cle_id_tbl, t_extr_id_tbl;
    close get_upg_line_details_csr;

    if t_extr_id_tbl.count > 0 then
      forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
      update okl_k_lines a
         set orig_contract_line_id = t_extr_id_tbl(i)
       where id in (select id FROM okc_k_lines_b b
                    where orig_system_id1 = t_orig_cle_id_tbl(i)
                      and dnz_chr_id = p_chr_id)
         and orig_contract_line_id is null;
    end if;

    t_extr_id_tbl.delete;
	t_orig_cle_id_tbl.delete;

    -- if any new lines are added, then update the external ids for them.
    OPEN get_line_details_csr(p_chr_id);
    FETCH get_line_details_csr bulk collect into t_extr_id_tbl;
    CLOSE get_line_details_csr;

    if t_extr_id_tbl.count > 0 then
      forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
        update okl_k_lines
           set orig_contract_line_id = t_extr_id_tbl(i)
         where id = t_extr_id_tbl(i)
           and orig_contract_line_id is null;
    end if;

    t_extr_id_tbl.delete;

  end if;

  if l_rbk_in_progress is null then

    open get_vendor_extid_csr(p_chr_id);
    fetch get_vendor_extid_csr bulk collect into t_extr_id_tbl;
    close get_vendor_extid_csr;

    -- if the upgrade is happening on the original contract or a new line is added
    if t_extr_id_tbl.count > 0 then
      forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
      update okl_party_payment_dtls
         set orig_contract_line_id = t_extr_id_tbl(i)
       where id = t_extr_id_tbl(i)
         and orig_contract_line_id is null;
    end if;

  elsif l_rbk_in_progress = 'Y' then

    open get_orig_vendor_dtls(l_orig_chr_id);
    fetch get_orig_vendor_dtls bulk collect into t_extr_id_tbl, t_vendor_id_tbl, t_orig_cle_id_tbl;
    close get_orig_vendor_dtls;

    if t_extr_id_tbl.count > 0 then
      forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
      update okl_party_payment_dtls a
         set orig_contract_line_id = t_extr_id_tbl(i)
       where id in (
          SELECT vDtls.id
            FROM okl_party_payment_hdr vHdr,
                 okl_party_payment_dtls vDtls,
                 okc_k_lines_b cle
           WHERE vDtls.payment_hdr_id = vHdr.id
             AND vHdr.CLE_ID = cle.id
             AND vHdr.PASSTHRU_TERM = 'BASE'
             AND vHdr.DNZ_CHR_ID = cle.dnz_chr_id
             AND cle.lse_id = 52
             AND vHdr.DNZ_CHR_ID = p_chr_id
             and cle.orig_system_id1 = t_orig_cle_id_tbl(i)
             and vdtls.vendor_id = t_vendor_id_tbl(i)
             and orig_contract_line_id is null);
    end if;

    t_extr_id_tbl.delete;
    t_orig_cle_id_tbl.delete;
    t_orig_chr_id_tbl.delete;
    t_vendor_id_tbl.delete;

    open get_vendor_extid_csr(p_chr_id);
    fetch get_vendor_extid_csr bulk collect into t_extr_id_tbl;
    close get_vendor_extid_csr;

    -- if a new line is added
    if t_extr_id_tbl.count > 0 then
      forall i in t_extr_id_tbl.first..t_extr_id_tbl.last
      update okl_party_payment_dtls
         set orig_contract_line_id = t_extr_id_tbl(i)
       where id = t_extr_id_tbl(i)
         and orig_contract_line_id is null;
    end if;

    t_extr_id_tbl.delete;

  end if; --  l_rbk_in_progress = 'Y'

  t_extr_id_tbl.delete;
  t_orig_cle_id_tbl.delete;
  t_orig_chr_id_tbl.delete;
  t_vendor_id_tbl.delete;

exception
    WHEN OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               l_msg_count,
                               l_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                l_msg_count,
                                l_msg_data,
                                '_PVT');
    WHEN OTHERS then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                l_msg_count,
                                l_msg_data,
                                '_PVT');
END update_external_id;

--Bug# 8756653
PROCEDURE check_rebook_upgrade(p_api_version   IN  NUMBER,
                               p_init_msg_list IN  VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_chr_id        IN  NUMBER,
                               p_rbk_chr_id    IN  NUMBER DEFAULT NULL) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_REBOOK_UPGRADE';
    l_api_version     CONSTANT NUMBER	:= 1.0;


    CURSOR l_chr_upg_csr(p_chr_id IN NUMBER)
    IS
    SELECT 'Y' chr_upgraded_yn
    FROM okl_stream_trx_data
    WHERE orig_khr_id = p_chr_id
    AND last_trx_state = 'Y';

    CURSOR l_acct_sys_op_csr IS
    SELECT amort_inc_adj_rev_dt_yn
    FROM okl_sys_acct_opts;

    CURSOR l_chr_csr(p_chr_id IN NUMBER) IS
    SELECT contract_number
    FROM okc_k_headers_all_b
    WHERE id = p_chr_id;

    CURSOR l_rbk_chr_upg_csr(p_rbk_chr_id IN NUMBER)
    IS
    SELECT 'Y' chr_upgraded_yn
    FROM okl_stream_trx_data
    WHERE khr_id = p_rbk_chr_id
    AND transaction_state is not null;

    l_chr_upgraded_yn VARCHAR2(1);
    l_pricing_engine           okl_st_gen_tmpt_sets.pricing_engine%TYPE;
    l_amort_inc_adj_rev_dt_yn  okl_sys_acct_opts.amort_inc_adj_rev_dt_yn%TYPE;
    l_contract_number          okc_k_headers_all_b.contract_number%TYPE;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := Okl_Api.START_ACTIVITY(
       p_api_name      => l_api_name,
       p_pkg_name      => g_pkg_name,
       p_init_msg_list => p_init_msg_list,
       l_api_version   => l_api_version,
       p_api_version   => p_api_version,
       p_api_type      => '_PVT',
       x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    l_amort_inc_adj_rev_dt_yn := 'N';
    OPEN l_acct_sys_op_csr;
    FETCH l_acct_sys_op_csr INTO l_amort_inc_adj_rev_dt_yn;
    CLOSE l_acct_sys_op_csr;

    IF (NVL(l_amort_inc_adj_rev_dt_yn,'N') = 'Y') THEN

      OKL_STREAMS_UTIL.get_pricing_engine(p_khr_id => p_chr_id,
                                          x_pricing_engine => l_pricing_engine,
                                          x_return_status => x_return_status);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF (l_pricing_engine  = 'EXTERNAL') THEN

        l_chr_upgraded_yn := 'N';
        OPEN l_chr_upg_csr(p_chr_id => p_chr_id);
        FETCH l_chr_upg_csr INTO l_chr_upgraded_yn;
        CLOSE l_chr_upg_csr;

        IF (NVL(l_chr_upgraded_yn,'N') = 'N') THEN

          OPEN l_chr_csr(p_chr_id => p_chr_id);
          FETCH l_chr_csr INTO l_contract_number;
          CLOSE l_chr_csr;

          OKL_API.set_message(p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKL_LA_CONTRACT_NOT_UPGRADED',
                              p_token1       => 'CONTRACT_NUMBER',
                              p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;

        ELSE

          IF p_rbk_chr_id IS NOT NULL THEN
            l_chr_upgraded_yn := 'N';
            OPEN l_rbk_chr_upg_csr(p_rbk_chr_id => p_rbk_chr_id);
            FETCH l_rbk_chr_upg_csr INTO l_chr_upgraded_yn;
            CLOSE l_rbk_chr_upg_csr;

            IF (NVL(l_chr_upgraded_yn,'N') = 'N') THEN

              OPEN l_chr_csr(p_chr_id => p_chr_id);
              FETCH l_chr_csr INTO l_contract_number;
              CLOSE l_chr_csr;

              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LA_RBK_NOT_PRICED_UPG',
                                  p_token1       => 'CONTRACT_NUMBER',
                                  p_token1_value => l_contract_number);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

        END IF;

      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END check_rebook_upgrade;

END Okl_Lla_Util_Pvt;

/
