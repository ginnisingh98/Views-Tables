--------------------------------------------------------
--  DDL for Package Body OKL_QA_SECURITIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QA_SECURITIZATION" AS
/* $Header: OKLRSZQB.pls 120.15 2008/03/26 08:18:36 sosharma noship $ */

  -- Start of comments
  --
  -- Procedure Name  : check_functional_constraints
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_functional_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    p_api_version     NUMBER;
    p_init_msg_list   VARCHAR2(256) DEFAULT OKC_API.G_FALSE;
    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);

/* Bug# 2924696
    CURSOR l_princ_csr ( chrID NUMBER ) IS
    select nvl( total_principal_amount, -1) princi
    from okl_pools
    where khr_id = chrID;

    l_princ_rec l_princ_csr%ROWTYPE;
*/

    CURSOR l_contract_name ( n VARCHAR2 ) IS
    Select count(*) cnt
    From okc_k_headers_v where contract_number = n;
    l_cn l_contract_name%ROWTYPE;

    CURSOR l_rev_strm_check_csr(p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
    SELECT distinct pool.khr_id, pcon.sty_id, pcon.sty_code
    FROM   okl_pools pool, okl_pool_contents pcon
    WHERE  pool.id = pcon.pol_id
    AND    pool.khr_id = p_chr_id
    AND    not exists (
    SELECT 'Y'
    FROM   okc_line_styles_b rev_style,
           okl_k_lines revl,
           okc_k_lines_b rev
    WHERE  rev.lse_id = rev_style.id
    AND    rev_style.lty_code = 'REVENUE_SHARE'
    AND    revl.id = rev.id
    AND    revl.sty_id = pcon.sty_id
    AND  rev.cle_id = p_cle_id );

    CURSOR l_rev_strm_comp_csr(p_cle_id IN NUMBER) IS
    SELECT rev.id, rev.cle_id, revl.sty_id,revl.percent_stake,
           strm.stream_type_subclass
    FROM okc_line_styles_b rev_style,
         okl_k_lines revl,
         okc_k_lines_b rev,
         okl_strm_type_v strm
    WHERE  rev.lse_id = rev_style.id
    AND    rev_style.lty_code = 'REVENUE_SHARE'
    AND    revl.id = rev.id
    AND    rev.cle_id = p_cle_id
    AND    revl.sty_id = strm.id
    ORDER BY strm.stream_type_subclass;

    CURSOR strm_name_csr1(styid IN NUMBER) IS
    SELECT tl.name name,
           stm.stream_type_class stream_type_class,
           stm.stream_type_subclass stream_type_subclass,
           tl.description ALLOC_BASIS,
           stm.capitalize_yn capitalize_yn,
           stm.periodic_yn  periodic_yn
    FROM okl_strm_type_b stm,
         OKL_STRM_TYPE_TL tl
    WHERE tl.id = stm.id
         and tl.language = 'US'
         and stm.id = styid;

    CURSOR inv_dbrmnt_csr(p_cle_id IN NUMBER) IS
    SELECT name, stream_type_subclass
    FROM   okl_strm_type_v strm
    WHERE  stream_type_subclass = 'INVESTOR_DISBURSEMENT'
    AND    not exists (
      SELECT 'Y'
      FROM   okc_line_styles_b rev_style,
      okl_k_lines revl,
      okc_k_lines_b rev
      WHERE  rev.lse_id = rev_style.id
      AND    rev_style.lty_code = 'REVENUE_SHARE'
      AND    revl.id = rev.id
      AND    revl.sty_id = strm.id
      AND    rev.cle_id = p_cle_id);

    CURSOR l_fnd_meaning_csr(p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2) IS
    SELECT fnd.meaning
    FROM fnd_lookups fnd
    WHERE fnd.lookup_type = p_lookup_type
    AND fnd.lookup_code = p_lookup_code;

    -- To check if revenue shares exist for each investor.
    CURSOR l_okl_inv_sty_subclass_csr(p_investor_id IN NUMBER, p_stream_type_subclass IN VARCHAR2) IS
    SELECT 1
    FROM   okl_k_lines kleb,
           okc_k_lines_b cles,
           okc_line_styles_b lseb
    WHERE  kleb.id = cles.id
    AND    cles.lse_id = lseb.id
    AND    cles.cle_id = p_investor_id
    AND    lseb.lty_code = 'REVENUE_SHARE'
    AND    kleb.stream_type_subclass = p_stream_type_subclass;

    -- To check if the stream type subclass has been securitized.
    CURSOR l_okl_poc_sty_subclass_csr(p_agreement_id IN NUMBER, p_stream_type_subclass IN VARCHAR2) IS
    SELECT 1
    FROM okl_pool_contents pocb,
         okl_pools polb,
         okl_strm_type_b styb
    WHERE polb.khr_id = p_agreement_id
    AND   pocb.pol_id = polb.id
    AND   pocb.sty_id = styb.id
    AND   styb.stream_type_subclass = p_stream_type_subclass;

    --Bug# 5032252 --start
    CURSOR l_rev_share_per_csr(p_investor_id IN NUMBER, p_stream_type_subclass IN VARCHAR2) IS
    SELECT kleb.percent_stake
    FROM   okl_k_lines kleb,
           okc_k_lines_b cles,
		   okc_line_styles_b lseb
    WHERE  kleb.id = cles.id
    AND    cles.lse_id = lseb.id
    AND    cles.cle_id = p_investor_id
    AND    lseb.lty_code = 'REVENUE_SHARE'
    AND    kleb.stream_type_subclass = p_stream_type_subclass;

    --Bug# 5032252 --end
    --CURSOR for selecting wheteher payment line exist for INCOME fee or not
    CURSOR payment_csr (p_agreement_id IN NUMBER )is
      select hzp.party_name partyname
           , okl_strmtyp.name streamtypename
      FROM okc_k_lines_b cle
         , okc_line_styles_b lse
         , okl_k_lines kle
         , okc_k_party_roles_b parb
         , hz_parties hzp
         , okc_k_items cit
         , okl_strmtyp_source_v okl_strmtyp
      WHERE lse.id = cle.lse_id
        AND kle.id = cle.id
        and kle.fee_type='INCOME'
        AND lse.lty_code = 'FEE'
        AND cit.dnz_chr_id = cle.dnz_chr_id
        AND cle.sts_code <> ('ABANDONED')
        AND cit.cle_id = cle.id
        AND to_char(okl_strmtyp.id1) = cit.object1_id1
        AND to_char(okl_strmtyp.id2) = cit.object1_id2
        AND parb.cle_id =  cle.id
        and hzp.party_id=parb.OBJECT1_ID1
        and cle.dnz_chr_id = p_agreement_id
        AND not EXISTS(
           SELECT 1
           from okc_rule_groups_b rgp
              , okc_rules_b rule
           where rgp.id = rule.rgp_id
             and rgp.rgd_code = 'LALEVL'
             and rgp.dnz_chr_id = p_agreement_id
             and rule.rule_information_category = 'LASLL'
             AND rgp.cle_id = cle.id);

    --Added by kthiruva on 01-Feb-2008
    --Bug 6773285 - Start of Changes
    CURSOR l_rev_share_dtls_csr(p_investor_id IN NUMBER) IS
    SELECT kleb.stream_type_subclass,
           kleb.percent_stake
    FROM   okl_k_lines kleb,
           okc_k_lines_b cles,
                   okc_line_styles_b lseb
    WHERE  kleb.id = cles.id
    AND    cles.lse_id = lseb.id
    AND    cles.cle_id = p_investor_id
    AND    lseb.lty_code = 'REVENUE_SHARE';
    --Bug 6773285 - End of Changes

    l_exists  VARCHAR2(1);
    l_hdr     l_hdr_csr%ROWTYPE;
    l_lne     l_lne_csr%ROWTYPE;
    l_sub_lne     l_lne_csr1%ROWTYPE;
     payment_rec payment_csr%ROWTYPE;
    i NUMBER;
    n NUMBER;
    l_princ_value NUMBER;
    l_stream_value NUMBER;
    l_invstr_rec   invstr_csr%ROWTYPE;
    ind NUMBER;
    l_prev_percent_stake NUMBER;
    strm_name_rec strm_name_csr1%ROWTYPE;
    l_fnd_meaning_rec l_fnd_meaning_csr%ROWTYPE;
    l_stream_type_subclass  VARCHAR2(400);
    l_subclass_prev_value  varchar2(400);
    l_subclass_curr_value  varchar2(400);

    /*Bug 6660196
    sosharma added constant l_api_version
    */
    l_api_version      CONSTANT NUMBER       := 1.0;

    --Bug# 5032252
    l_rev_share_per okl_k_lines.PERCENT_STAKE%TYPE;
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr into l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    OPEN  l_contract_name(l_hdr.contract_number);
    FETCH l_contract_name into l_cn;
    IF l_contract_name%NOTFOUND THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_contract_name;

    If( l_cn.cnt > 1) Then
            OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_AGMT_NOTUNQ');
             -- notify caller of an error
            x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;


    OPEN  l_lne_csr('INVESTMENT', p_chr_id);
    FETCH l_lne_csr into l_lne;
    If( l_lne_csr%NOTFOUND ) Then
            OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_SHARE_LINES');
             -- notify caller of an error
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_lne_csr;

    OPEN  l_lne_csr('REVENUE_SHARE', p_chr_id);
    FETCH l_lne_csr into l_lne;
    If( l_lne_csr%NOTFOUND ) Then
            OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_REVENUE_LINES');
             -- notify caller of an error
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_lne_csr;

    OPEN payment_csr(p_chr_id) ;
    FETCH payment_csr INTO payment_rec;
    CLOSE payment_csr;
    IF(payment_rec.streamtypename IS NOT NULL)
    THEN
      OKL_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_QA_INCOME_NO_PAYMENT',
	        p_token1       => 'INVESTORNMAE',
	        p_token1_value => payment_rec.partyname,
          p_token2       => 'FEENAME',
	        p_token2_value => payment_rec.streamtypename);
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    FOR l_lne IN l_lne_csr('INVESTMENT', p_chr_id)
    LOOP

        n := 0;
        FOR l_sub_lne in l_lne_csr1( 'REVENUE_SHARE', p_chr_id)
	LOOP
	    If ( l_lne.id = l_sub_lne.cle_id ) Then
	        n := n + 1;
	    End If;
	END LOOP;

        OPEN  invstr_csr(p_chr_id, l_lne.id);
        FETCH invstr_csr into l_invstr_rec;
        CLOSE invstr_csr;

	If ( n = 0) Then

            OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_ASST_NO_RVNUELNS',
	          p_token1       => 'INVESTOR',
	          p_token1_value => l_invstr_rec.name);
            x_return_status := OKL_API.G_RET_STS_ERROR;

        End If;

        --for the investor, checking for existence of revenue shares for streams of subclass
        --LATE_CHARGE and LATE_INTEREST.
          l_stream_type_subclass := 'LATE_CHARGE';
          OPEN  l_okl_inv_sty_subclass_csr(l_lne.id , l_stream_type_subclass);
          FETCH l_okl_inv_sty_subclass_csr INTO l_exists;
          IF( l_okl_inv_sty_subclass_csr%NOTFOUND) Then
            OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
                    p_token1       => 'INVESTOR',
                    p_token1_value => l_invstr_rec.name,
                    p_token3       => 'SUB_CLASS',
                    p_token3_value => l_stream_type_subclass);
             x_return_status := OKL_API.G_RET_STS_ERROR;
          END IF;
          CLOSE l_okl_inv_sty_subclass_csr;

          l_stream_type_subclass := 'LATE_INTEREST';
          OPEN  l_okl_inv_sty_subclass_csr(l_lne.id , l_stream_type_subclass);
          FETCH l_okl_inv_sty_subclass_csr INTO l_exists;
          IF( l_okl_inv_sty_subclass_csr%NOTFOUND) Then
            OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
                    p_token1       => 'INVESTOR',
                    p_token1_value => l_invstr_rec.name,
                    p_token3       => 'SUB_CLASS',
                    p_token3_value => l_stream_type_subclass);
             x_return_status := OKL_API.G_RET_STS_ERROR;
          END IF;
          CLOSE l_okl_inv_sty_subclass_csr;

        --for the investor, checking for existence of streams of subclass RENT
        --and RESIDUAL if these stream type subclasses have been securitized.
          l_stream_type_subclass := 'RENT';
          OPEN  l_okl_poc_sty_subclass_csr(p_chr_id, l_stream_type_subclass);
          FETCH l_okl_poc_sty_subclass_csr INTO l_exists;
          IF (l_okl_poc_sty_subclass_csr%FOUND) Then
            OPEN  l_okl_inv_sty_subclass_csr(l_lne.id , l_stream_type_subclass);
            FETCH l_okl_inv_sty_subclass_csr INTO l_exists;
            IF( l_okl_inv_sty_subclass_csr%NOTFOUND) Then
              OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
                  p_token1       => 'INVESTOR',
                  p_token1_value => l_invstr_rec.name,
                  p_token3       => 'SUB_CLASS',
                  p_token3_value => l_stream_type_subclass);
              x_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_okl_inv_sty_subclass_csr;

			--Bug# 5032252 --start
            OPEN  l_rev_share_per_csr(l_lne.id , l_stream_type_subclass);
            FETCH l_rev_share_per_csr INTO l_rev_share_per;
            IF (l_rev_share_per = 0) THEN
              OKL_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_INV_REV_SHARE_ZERO',
                     p_token1       => 'SUB_CLASS',
                     p_token1_value => l_stream_type_subclass);
              x_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_rev_share_per_csr;
            --Bug# 5032252 --end

          END IF;
          CLOSE l_okl_poc_sty_subclass_csr;
          l_stream_type_subclass := 'RESIDUAL';
          OPEN  l_okl_poc_sty_subclass_csr(p_chr_id, l_stream_type_subclass);
          FETCH l_okl_poc_sty_subclass_csr INTO l_exists;
          IF (l_okl_poc_sty_subclass_csr%FOUND) Then
            OPEN  l_okl_inv_sty_subclass_csr(l_lne.id , l_stream_type_subclass);
            FETCH l_okl_inv_sty_subclass_csr INTO l_exists;
            IF( l_okl_inv_sty_subclass_csr%NOTFOUND) Then
              OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
                  p_token1       => 'INVESTOR',
                  p_token1_value => l_invstr_rec.name,
                  p_token3       => 'SUB_CLASS',
                  p_token3_value => l_stream_type_subclass);
              x_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_okl_inv_sty_subclass_csr;

			--Bug# 5032252 --start
            OPEN  l_rev_share_per_csr(l_lne.id , l_stream_type_subclass);
            FETCH l_rev_share_per_csr INTO l_rev_share_per;
            IF (l_rev_share_per = 0) THEN
              OKL_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_INV_REV_SHARE_ZERO',
                     p_token1       => 'SUB_CLASS',
                     p_token1_value => l_stream_type_subclass);
              x_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_rev_share_per_csr;
            --Bug# 5032252 --end

          END IF;
          CLOSE l_okl_poc_sty_subclass_csr;
   -----------------------------------------------------------------------------
     --Bug # 674000 ssdeshpa start
     --for the investor, checking for existence of streams of subclass LOAN_PAYMENT
     --if these stream type subclasses have been securitized.
          l_stream_type_subclass := 'LOAN_PAYMENT';
          OPEN  l_okl_poc_sty_subclass_csr(p_chr_id, l_stream_type_subclass);
          FETCH l_okl_poc_sty_subclass_csr INTO l_exists;
          IF (l_okl_poc_sty_subclass_csr%FOUND) Then
            OPEN  l_okl_inv_sty_subclass_csr(l_lne.id , l_stream_type_subclass);
            FETCH l_okl_inv_sty_subclass_csr INTO l_exists;
            IF( l_okl_inv_sty_subclass_csr%NOTFOUND) Then
              OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
                  p_token1       => 'INVESTOR',
                  p_token1_value => l_invstr_rec.name,
                  p_token3       => 'SUB_CLASS',
                  p_token3_value => l_stream_type_subclass);
              x_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_okl_inv_sty_subclass_csr;
            OPEN  l_rev_share_per_csr(l_lne.id , l_stream_type_subclass);
            FETCH l_rev_share_per_csr INTO l_rev_share_per;
            IF (l_rev_share_per = 0) THEN
              OKL_API.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_INV_REV_SHARE_ZERO',
                     p_token1       => 'SUB_CLASS',
                     p_token1_value => l_stream_type_subclass);
              x_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_rev_share_per_csr;
          END IF;
          CLOSE l_okl_poc_sty_subclass_csr;
     --Bug 674000 ssdeshpa end
     --------------------------------------------------------------------------
    --Ensure that Revenue Share is defined only if the stream type class is securitised
          FOR l_rev_share_dtls_rec IN  l_rev_share_dtls_csr(l_lne.id)
                  LOOP
                    IF l_rev_share_dtls_rec.stream_type_subclass = 'RENT'
                    THEN
                      l_stream_type_subclass := 'RENT';
                      --Check if pool contents exist for this subclass, if not an error needs to be raised
                      --that revenue share has been defined without the stream being securitized
                    OPEN  l_okl_poc_sty_subclass_csr(p_chr_id,l_stream_type_subclass);
                    FETCH l_okl_poc_sty_subclass_csr INTO l_exists;
                    IF (l_okl_poc_sty_subclass_csr%NOTFOUND)
                          THEN
                            OKL_API.set_message(
                                 p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_QA_REV_SHARE_INVALID',
                                 p_token1       => 'SUB_CLASS',
                                 p_token1_value => l_stream_type_subclass);
                          END IF;
                    CLOSE l_okl_poc_sty_subclass_csr;
                    END IF;


                    IF l_rev_share_dtls_rec.stream_type_subclass = 'RESIDUAL'
                    THEN
                      l_stream_type_subclass := 'RESIDUAL';
                      --Check if pool contents exist for this subclass, if not an error needs to be raised
                      --that revenue share has been defined without the stream being securitized


                      OPEN  l_okl_poc_sty_subclass_csr(p_chr_id, l_stream_type_subclass);
                      FETCH l_okl_poc_sty_subclass_csr INTO l_exists;
                      IF (l_okl_poc_sty_subclass_csr%NOTFOUND)
                          THEN
                              OKL_API.set_message(
                                p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_QA_REV_SHARE_INVALID',
                                p_token1       => 'SUB_CLASS',
                                p_token1_value => l_stream_type_subclass);
                          END IF;
                    CLOSE l_okl_poc_sty_subclass_csr;
                    END IF;

                    IF l_rev_share_dtls_rec.stream_type_subclass = 'LOAN_PAYMENT'
                    THEN
                      l_stream_type_subclass := 'LOAN_PAYMENT';
                      --Check if pool contents exist for this subclass, if not an error needs to be raised
                      --that revenue share has been defined without the stream being securitized
                      OPEN  l_okl_poc_sty_subclass_csr(p_chr_id,l_stream_type_subclass);
                      FETCH l_okl_poc_sty_subclass_csr INTO l_exists;
                      IF (l_okl_poc_sty_subclass_csr%NOTFOUND)
                          THEN
                             OKL_API.set_message(
                                p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_QA_REV_SHARE_INVALID',
                                p_token1       => 'SUB_CLASS',
                                p_token1_value => l_stream_type_subclass);
                          END IF;
                    CLOSE l_okl_poc_sty_subclass_csr;
                    END IF;
                  END LOOP;

        /*
        *FOR l_rev_strm_check_rec IN l_rev_strm_check_csr(p_chr_id => p_chr_id, p_cle_id => l_lne.id)
        *LOOP
        *
        *    OPEN strm_name_csr1 (styid => l_rev_strm_check_rec.sty_id);
        *    FETCH strm_name_csr1 INTO strm_name_rec;
        *    CLOSE strm_name_csr1;
        *
        *    OPEN l_fnd_meaning_csr(p_lookup_type => 'OKL_STREAM_TYPE_SUBCLASS',
        *                               p_lookup_code => strm_name_rec.stream_type_subclass);
        *    FETCH l_fnd_meaning_csr INTO l_fnd_meaning_rec;
        *    CLOSE l_fnd_meaning_csr;
        *
        *    -- set message and continue in loop
        *    OKL_API.set_message(
        *          p_app_name     => G_APP_NAME,
        *          p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
        *          p_token1       => 'INVESTOR',
        *          p_token1_value => l_invstr_rec.name,
        *          p_token2       => 'STRM_TYPE',
        *          p_token2_value => strm_name_rec.name,
        *          p_token3       => 'SUB_CLASS',
        *          p_token3_value => l_fnd_meaning_rec.meaning);
        *    x_return_status := OKL_API.G_RET_STS_ERROR;
        *
        *END LOOP;
        *
        *FOR inv_dbrmnt_rec IN inv_dbrmnt_csr(p_cle_id => l_lne.id)
        *LOOP
        *    OPEN l_fnd_meaning_csr(p_lookup_type => 'OKL_STREAM_TYPE_SUBCLASS',
        *                               p_lookup_code => inv_dbrmnt_rec.stream_type_subclass);
        *    FETCH l_fnd_meaning_csr INTO l_fnd_meaning_rec;
        *    CLOSE l_fnd_meaning_csr;
        *
        *    -- set message and continue in loop
        *    OKL_API.set_message(
        *          p_app_name     => G_APP_NAME,
        *          p_msg_name     => 'OKL_QA_INV_STRM_MISMATCH',
        *          p_token1       => 'INVESTOR',
        *          p_token1_value => l_invstr_rec.name,
        *          p_token2       => 'STRM_TYPE',
        *          p_token2_value => inv_dbrmnt_rec.name,
        *          p_token3       => 'SUB_CLASS',
        *          p_token3_value => l_fnd_meaning_rec.meaning);
        *    x_return_status := OKL_API.G_RET_STS_ERROR;
        *END LOOP;
        *
        *ind := 0;
        *
        *FOR l_rev_strm_comp_rec IN l_rev_strm_comp_csr(p_cle_id => l_lne.id)
        *LOOP
        *  -- the share percentages for each revenue stream within a stream
        *  -- type subclass must be the same.
        *  l_subclass_curr_value := l_rev_strm_comp_rec.stream_type_subclass;
        *  If(ind = 0) Then
        *    l_subclass_prev_value := l_rev_strm_comp_rec.stream_type_subclass;
        *    l_prev_percent_stake := l_rev_strm_comp_rec.percent_stake;
        *    ind := 1;
        *  ElsIf( l_subclass_prev_value <> l_subclass_curr_value) Then
        *    l_subclass_prev_value := l_subclass_curr_value;
        *    l_prev_percent_stake :=  l_rev_strm_comp_rec.percent_stake;
        *  Else
        *    If (l_prev_percent_stake <> l_rev_strm_comp_rec.percent_stake) Then
        *    OPEN strm_name_csr1 (styid => l_rev_strm_comp_rec.sty_id);
        *    FETCH strm_name_csr1 INTO strm_name_rec;
        *    CLOSE strm_name_csr1;
        *
        *    OPEN l_fnd_meaning_csr(p_lookup_type => 'OKL_STREAM_TYPE_SUBCLASS',
        *                               p_lookup_code => strm_name_rec.stream_type_subclass);
        *    FETCH l_fnd_meaning_csr INTO l_fnd_meaning_rec;
        *    CLOSE l_fnd_meaning_csr;
        *
        *    OKL_API.set_message(
        *          p_app_name     => G_APP_NAME,
        *          p_msg_name     => 'OKL_QA_INV_DIFF_STAKE',
        *          p_token1       => 'INVESTOR',
        *          p_token1_value => l_invstr_rec.name,
        *          p_token2       => 'SUB_CLASS',
        *          p_token2_value => l_fnd_meaning_rec.meaning);
        *    x_return_status := OKL_API.G_RET_STS_ERROR;
        *    End If;
        *  End If;
        *
        *END LOOP;
        */

    END LOOP;

/* Removed as per Bug# 2924696 , 04/25/2004
    OPEN  l_princ_csr( p_chr_id );
    FETCH l_princ_csr INTO l_princ_rec;
    CLOSE l_princ_csr;

    If( l_princ_rec.princi <= 0  ) Then

           OKL_API.set_message(
             p_app_name     => G_APP_NAME,
             p_msg_name     => 'OKL_QA_PRINC_VALUE');
            -- notify caller of an error
           x_return_status := OKL_API.G_RET_STS_ERROR;
   END IF;
*/

   OKL_POOL_PVT.get_tot_receivable_amt(
                   p_api_version   => l_api_version , --Bug 6660196
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => l_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   x_value         => l_stream_value,
                   p_khr_id        => p_chr_id );

   If( l_stream_value IS NULL OR l_stream_value = 0 ) Then
           OKL_API.set_message(
             p_app_name     => G_APP_NAME,
             p_msg_name     => 'OKL_QA_STREAM_VALUE');
            -- notify caller of an error
           x_return_status := OKL_API.G_RET_STS_ERROR;
   END IF;


  IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
      OKL_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_okl_inv_sty_subclass_csr%ISOPEN THEN
      CLOSE l_okl_inv_sty_subclass_csr;
    END IF;
    IF l_okl_poc_sty_subclass_csr%ISOPEN THEN
      CLOSE l_okl_poc_sty_subclass_csr;
    END IF;
	--Bug 5032252
	IF l_rev_share_per_csr%ISOPEN THEN
	  CLOSE l_rev_share_per_csr;
	END IF;

	IF l_okl_poc_sty_subclass_csr%ISOPEN THEN
      CLOSE l_okl_poc_sty_subclass_csr;
	END IF;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_okl_inv_sty_subclass_csr%ISOPEN THEN
      CLOSE l_okl_inv_sty_subclass_csr;
    END IF;
    IF l_okl_poc_sty_subclass_csr%ISOPEN THEN
      CLOSE l_okl_poc_sty_subclass_csr;
    END IF;
	--Bug 5032252
	IF l_rev_share_per_csr%ISOPEN THEN
	  CLOSE l_rev_share_per_csr;
	END IF;

	IF l_okl_poc_sty_subclass_csr%ISOPEN THEN
      CLOSE l_okl_poc_sty_subclass_csr;
	END IF;

  END check_functional_constraints;

  -- Start of comments
  --
  -- Procedure Name  : check_rule_constraints
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_rule_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    l_hdr      l_hdr_csr%ROWTYPE;
    l_lne      l_lne_csr%ROWTYPE;

    l_lnerl_rec l_lnerl_csr%ROWTYPE;
    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_fnd_rec   fnd_csr%ROWTYPE;
    l_t_and_c_rec   t_and_c_csr%ROWTYPE;
    l_invstr_rec   invstr_csr%ROWTYPE;

    i NUMBER;

  BEGIN

    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr into l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    OPEN  l_hdrrl_csr('LASEIR', 'LASEIR', TO_NUMBER(p_chr_id)); -- Agreement rules
    FETCH l_hdrrl_csr into l_hdrrl_rec;
    If( l_hdrrl_csr%NOTFOUND ) Then

        OPEN  t_and_c_csr('OKLLASECLASEIR');
        FETCH t_and_c_csr into l_t_and_c_rec;
        CLOSE t_and_c_csr;

        OKL_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKL_QA_NOAGMT_RULES',
	  p_token1       => 'RULE_GROUP_NAME',
	  p_token1_value => l_t_and_c_rec.meaning);
         -- notify caller of an error
        x_return_status := OKL_API.G_RET_STS_ERROR;
    Else
        If (l_hdrrl_rec.rule_information1 = 'YIELD'
          AND (l_hdr.after_tax_yield = 0 OR l_hdr.after_tax_yield is null)) Then
          OKL_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_YLD_DBRSMT');
          x_return_status := OKL_API.G_RET_STS_ERROR;
        End If;

    End If;
    CLOSE l_hdrrl_csr;

    OPEN  l_hdrrl_csr('LASEBB', 'LASEFM', TO_NUMBER(p_chr_id)); -- Agreement rules
    FETCH l_hdrrl_csr into l_hdrrl_rec;
    If( l_hdrrl_csr%NOTFOUND OR l_hdrrl_rec.rule_information1 IS NULL) Then
      OKL_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_QA_BUYBACK_FORMULA');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;
	CLOSE l_hdrrl_csr;

    FOR l_lne IN l_lne_csr('INVESTMENT', p_chr_id)
    LOOP

        OPEN  l_lnerl_csr('LASEDB', 'LASEDB', TO_NUMBER(p_chr_id), l_lne.id);
        FETCH l_lnerl_csr into l_lnerl_rec;
        If( l_lnerl_csr%NOTFOUND ) Then

            OPEN  t_and_c_csr('OKLLASECLASEIR');
            FETCH t_and_c_csr into l_t_and_c_rec;
            CLOSE t_and_c_csr;

            OPEN  invstr_csr(p_chr_id, l_lne.id);
            FETCH invstr_csr into l_invstr_rec;
            CLOSE invstr_csr;

            OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NOSHR_RULES',
              p_token1       => 'RULE_GROUP_NAME',
              p_token1_value => l_t_and_c_rec.meaning,
	      p_token2       => 'INVESTOR',
	      p_token2_value => l_invstr_rec.name);
            x_return_status := OKL_API.G_RET_STS_ERROR;
        End If;
        CLOSE l_lnerl_csr;

    END LOOP;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_lnerl_csr%ISOPEN THEN
      CLOSE l_lnerl_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;
    IF fnd_csr%ISOPEN THEN
      CLOSE fnd_csr;
    END IF;
    IF t_and_c_csr%ISOPEN THEN
      CLOSE t_and_c_csr;
    END IF;
    IF invstr_csr%ISOPEN THEN
      CLOSE invstr_csr;
    END IF;
  END check_rule_constraints;



  -- Start of comments
  --
  -- Procedure Name  : check_ia_type_for_strms
  -- Description     : Check whether the streams in a contract are associated
  -- 				   with the same type of Investor Agreements if they are in
  --				   different Investor Agreements
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_ia_type_for_strms(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    CURSOR get_chr_id (p_chr_id IN NUMBER) IS
	SELECT DISTINCT(poc.khr_id)
	FROM okl_pool_contents poc, okl_pools pol
	WHERE pol.khr_id = p_chr_id
	AND pol.id = poc.pol_id;

	-- Get the sec type for the ia, convert the old product --
	-- value SALE to SECURITIZATION and LOAN to SYNDICATION --
    CURSOR ia_type_csr (p_khr_id IN NUMBER) IS
	SELECT a.khr_id,
		   decode(c.securitization_type, 'SALE','SECURITIZATION','LOAN','SYNDICATION',
		   'SECURITIZATION','SECURITIZATION','SYNDICATION','SYNDICATION') securitization_type,
		   b.contract_number
	FROM okl_pool_contents a, okc_k_headers_b b,okl_k_headers c, okl_pools d
	WHERE a.khr_id = p_khr_id
	AND a.pol_id=d.id
	AND d.khr_id= c.id
	AND b.id=c.id;

    l_khr_id number;

	l_previous_type okl_k_headers.securitization_type%TYPE;
	l_previous_khr_id NUMBER;

    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_token VARCHAR2(2000);

  BEGIN

    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

	OPEN get_chr_id (p_chr_id);
	LOOP
      FETCH get_chr_id INTO l_khr_id;
	  EXIT WHEN get_chr_id%NOTFOUND;

	  FOR  ia_type_rec IN ia_type_csr (l_khr_id) LOOP

	     IF (NVL(l_previous_khr_id,ia_type_rec.khr_id) = ia_type_rec.khr_id AND
	      	 NVL(l_previous_type,ia_type_rec.securitization_type) <> ia_type_rec.securitization_type) THEN
	    	 OKL_API.set_message(
         	 		 p_app_name     => G_APP_NAME,
          			 p_msg_name     => 'OKL_IA_STRM_IA_TYPES',
	      			 p_token1       => 'CONTRACT_NUMBER',
	  	  			 p_token1_value => ia_type_rec.contract_number);
          			 -- notify caller of an error
        			 x_return_status := OKL_API.G_RET_STS_ERROR;
	  	  END IF;
	  	  l_previous_khr_id := ia_type_rec.khr_id;
	  	  l_previous_type := ia_type_rec.securitization_type;

	  END LOOP;
	END LOOP;

	CLOSE get_chr_id;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF get_chr_id%ISOPEN THEN
      CLOSE get_chr_id;
    END IF;
	IF ia_type_csr%ISOPEN THEN
      CLOSE ia_type_csr;
    END IF;
  END check_ia_type_for_strms;


END OKL_QA_SECURITIZATION;

/
