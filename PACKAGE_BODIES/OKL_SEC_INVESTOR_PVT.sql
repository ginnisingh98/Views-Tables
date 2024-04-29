--------------------------------------------------------
--  DDL for Package Body OKL_SEC_INVESTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_INVESTOR_PVT" AS
/* $Header: OKLRSZIB.pls 120.5 2008/02/15 05:47:48 gboomina noship $ */
/* ***********************************************  */
--G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
--G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_PROCESSING    EXCEPTION;
G_EXCEPTION_STOP_VALIDATION    EXCEPTION;


G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_SEC_PARTIES_PVT';
G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
l_api_name    VARCHAR2(35)    := 'SEC_PARTIES';


PROCEDURE migrate_records(
    p_inv_rec                      IN  inv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

  l_clev_rec    clev_rec_type;
  l_klev_rec    klev_rec_type;


  BEGIN

  l_clev_rec.id                             := p_inv_rec.cle_id;
  l_clev_rec.lse_id                         := p_inv_rec.cle_lse_id;
  l_clev_rec.line_number                    := p_inv_rec.cle_line_number;
  --l_clev_rec.sts_code                       := p_inv_rec.cle_sts_code;
  l_clev_rec.comments                       := p_inv_rec.cle_comments;
  l_clev_rec.date_terminated                := p_inv_rec.cle_date_terminated;
  l_clev_rec.start_date                     := p_inv_rec.cle_start_date;
  l_clev_rec.end_date                       := p_inv_rec.cle_end_date;
  l_clev_rec.start_date                     := p_inv_rec.START_DATE;
  -- akjain, added for Rules Migration
  l_clev_rec.bill_to_site_use_id                     := p_inv_rec.bill_to_site_use_id;
  l_clev_rec.cust_acct_id                     := p_inv_rec.cust_acct_id;

  l_klev_rec.ID                             := p_inv_rec.KLE_ID;
  l_klev_rec.PERCENT_STAKE                  := p_inv_rec.KLE_PERCENT_STAKE;
  l_klev_rec.PERCENT                        := p_inv_rec.KLE_PERCENT;
  l_klev_rec.EVERGREEN_PERCENT              := p_inv_rec.KLE_EVERGREEN_PERCENT;
  l_klev_rec.AMOUNT_STAKE                   := p_inv_rec.KLE_AMOUNT_STAKE;
  l_klev_rec.DATE_SOLD                      := p_inv_rec.KLE_DATE_SOLD;
  l_klev_rec.DELIVERED_DATE                 := p_inv_rec.KLE_DELIVERED_DATE;
  l_klev_rec.AMOUNT                         := p_inv_rec.KLE_AMOUNT;
  l_klev_rec.DATE_FUNDING                   := p_inv_rec.KLE_DATE_FUNDING;
  l_klev_rec.DATE_FUNDING_REQUIRED          := p_inv_rec.KLE_DATE_FUNDING_REQUIRED;
  l_klev_rec.DATE_ACCEPTED                  := p_inv_rec.KLE_DATE_ACCEPTED;
  l_klev_rec.DATE_DELIVERY_EXPECTED         := p_inv_rec.KLE_DATE_DELIVERY_EXPECTED;
  l_klev_rec.CAPITAL_AMOUNT                 := p_inv_rec.KLE_CAPITAL_AMOUNT;

  l_klev_rec.DATE_PAY_INVESTOR_START        := p_inv_rec.DATE_PAY_INVESTOR_START;
  l_klev_rec.PAY_INVESTOR_FREQUENCY         := p_inv_rec.PAY_INVESTOR_FREQUENCY;
  l_klev_rec.PAY_INVESTOR_EVENT             := p_inv_rec.PAY_INVESTOR_EVENT;
  l_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS   := p_inv_rec.PAY_INVESTOR_REMITTANCE_DAYS;

  x_clev_rec := l_clev_rec;
  x_klev_rec := l_klev_rec;

  END migrate_records;




PROCEDURE migrate_records(
    p_inv_rec                      IN  inv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

  l_cplv_rec    cplv_rec_type;
  lx_clev_rec    clev_rec_type;
  lx_klev_rec    klev_rec_type;

  BEGIN

  l_cplv_rec.id                             := p_inv_rec.cpl_id;
  l_cplv_rec.chr_id                         := p_inv_rec.cpl_chr_id;
  l_cplv_rec.cle_id                         := p_inv_rec.cpl_cle_id;
  l_cplv_rec.rle_code                       := p_inv_rec.cpl_rle_code;
  l_cplv_rec.dnz_chr_id                     := p_inv_rec.cpl_dnz_chr_id;


  --dbms_output.put_line('p_inv_rec.cpl_dnz_chr_id'||p_inv_rec.cpl_dnz_chr_id);

  l_cplv_rec.object1_id1                    := p_inv_rec.cpl_object1_id1;
  l_cplv_rec.object1_id2                    := p_inv_rec.cpl_object1_id2;
  l_cplv_rec.jtot_object1_code              := p_inv_rec.cpl_jtot_object1_code;

--insert into okl_sec_temp values (p_inv_rec.cpl_chr_id, 'migrate_records. '||p_inv_rec.cpl_object1_id1||p_inv_rec.cpl_object1_id2);


  migrate_records(
      p_inv_rec     => p_inv_rec,
      x_clev_rec    => lx_clev_rec,
      x_klev_rec    => lx_klev_rec);


  x_cplv_rec := l_cplv_rec;
  x_clev_Rec := lx_clev_rec;
  x_klev_rec := lx_klev_rec;

  END migrate_records;


FUNCTION check_parties(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cplv_rec                     IN  cplv_rec_type)
    RETURN BOOLEAN IS

CURSOR PARTIES_CSR
( p_chr_id   IN NUMBER,
 p_party_id1 IN VARCHAR2) IS
SELECT 'x'
FROM   okl_sec_investors_uv
WHERE  chr_id = p_chr_id
       AND id1 = p_party_id1;

l_fetched               BOOLEAN     := FALSE;
l_temp                  VARCHAR2(1);


  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'check_parties';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;

  BEGIN

--insert into okl_sec_temp values (p_cplv_rec.dnz_chr_id, 'in count parties '||p_cplv_rec.object1_id1);

   OPEN PARTIES_CSR(p_cplv_rec.dnz_chr_id,
                    p_cplv_rec.object1_id1);

   FETCH PARTIES_CSR INTO l_temp;

   --insert into okl_sec_temp values (0, 'l_fetched '||l_fetched);
   IF PARTIES_CSR%NOTFOUND THEN
        l_fetched := FALSE;
   ELSE
        l_fetched := TRUE;
   END IF;

   --insert into okl_sec_temp values (0, 'l_fetched '||l_fetched);

   CLOSE PARTIES_CSR;
   x_return_status := 'S';
   RETURN l_fetched;

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


END check_parties;


FUNCTION get_lse_id(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_lty_code                     IN  VARCHAR2)
RETURN NUMBER IS

CURSOR LINE_STYLES_CSR
(p_lty_code IN VARCHAR2) IS
SELECT ID
FROM   okc_line_styles_v
WHERE  lty_code = p_lty_code;


l_fetched               BOOLEAN     := FALSE;
l_lse_id                NUMBER;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'check_parties';
  l_api_version            CONSTANT NUMBER    := 1.0;

BEGIN

   OPEN LINE_STYLES_CSR(p_lty_code);

   FETCH LINE_STYLES_CSR INTO l_lse_id;
   CLOSE LINE_STYLES_CSR;

   x_return_status := 'S';

   RETURN l_lse_id;

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

END get_lse_id;


PROCEDURE get_header_details(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_chr_id                       IN  NUMBER,
      x_currency_code                OUT NOCOPY VARCHAR2,
      x_org_id                       OUT NOCOPY VARCHAR2,
      x_end_date                     OUT NOCOPY DATE)
IS

CURSOR CURRENCY_CSR
(p_chr_id IN VARCHAR2) IS
SELECT CURRENCY_CODE,
       AUTHORING_ORG_ID,
       END_DATE
FROM   okc_k_headers_b
WHERE  id = p_chr_id;


l_fetched               BOOLEAN     := FALSE;
l_currency_code         VARCHAR2(15);
l_org_id                VARCHAR2(15);
l_end_date              DATE;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'GET_HEADER_DETAILS';
  l_api_version            CONSTANT NUMBER    := 1.0;

BEGIN

   OPEN CURRENCY_CSR(p_chr_id);

   FETCH CURRENCY_CSR INTO l_currency_code, l_org_id, l_end_date;
   CLOSE CURRENCY_CSR;

   x_currency_code := l_currency_code;
   x_org_id := l_org_id;
   x_end_date := l_end_date;

   x_return_status := 'S';


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

END get_header_details;


PROCEDURE validate_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type) IS


  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'VALIDATE_INVESTOR';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;
  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;


  BEGIN

        -- dbms_output.put_line('begin ');
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


      LOOP
        i := i + 1;

        --dbms_output.put_line('begin 1');

        IF(p_inv_tbl(i).cpl_object1_id1 IS NULL OR
           p_inv_tbl(i).cpl_object1_id1 = ''    OR
           p_inv_tbl(i).cpl_object1_id1 = OKC_API.G_MISS_CHAR) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_INVESTOR');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                   );

            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        --dbms_output.put_line('begin 2');

        IF(p_inv_tbl(i).kle_amount IS NULL OR
           p_inv_tbl(i).kle_amount = ''    OR
           p_inv_tbl(i).kle_amount = OKC_API.G_MISS_NUM) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_AMT_STAKE');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                   );
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        --dbms_output.put_line('begin 3');
        IF(p_inv_tbl(i).start_date IS NULL OR
           p_inv_tbl(i).start_date = ''    OR
           p_inv_tbl(i).start_date = OKC_API.G_MISS_DATE) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_INV_DATE');

            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                   );
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF(p_inv_tbl(i).PAY_INVESTOR_FREQUENCY IS NULL OR
            p_inv_tbl(i).PAY_INVESTOR_FREQUENCY = ''    OR
            p_inv_tbl(i).PAY_INVESTOR_FREQUENCY = OKC_API.G_MISS_CHAR) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_PAY_FREQ');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                      );
                    RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF(p_inv_tbl(i).date_pay_investor_start IS NULL OR
            p_inv_tbl(i).date_pay_investor_start = ''    OR
            p_inv_tbl(i).date_pay_investor_start = OKC_API.G_MISS_DATE) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_PAY_START');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                      );
                    RAISE OKC_API.G_EXCEPTION_ERROR;
		-- mvasudev, 02/06/2004
	    ELSIF p_inv_tbl(i).date_pay_investor_start < p_inv_tbl(i).start_date
		THEN
            x_return_status := OKC_API.g_ret_sts_error;
            OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME
                               ,p_msg_name => 'OKL_SEC_INVALID_PAYOUT_DATE');
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF(p_inv_tbl(i).PAY_INVESTOR_EVENT IS NULL OR
            p_inv_tbl(i).PAY_INVESTOR_EVENT = ''    OR
            p_inv_tbl(i).PAY_INVESTOR_EVENT = OKC_API.G_MISS_CHAR) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_PAY_EVENT');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                      );
                    RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        IF(p_inv_tbl(i).PAY_INVESTOR_REMITTANCE_DAYS IS NULL OR
            p_inv_tbl(i).PAY_INVESTOR_REMITTANCE_DAYS = ''    OR
            p_inv_tbl(i).PAY_INVESTOR_REMITTANCE_DAYS = OKC_API.G_MISS_NUM) THEN

            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_REMIT');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_REQUIRED_VALUE'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                      );
                    RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

       IF(p_inv_tbl(i).BILL_TO_SITE_USE_ID IS NULL OR
                  p_inv_tbl(i).BILL_TO_SITE_USE_ID = ''    OR
                  p_inv_tbl(i).BILL_TO_SITE_USE_ID = OKC_API.G_MISS_NUM) THEN

                   x_return_status := OKC_API.g_ret_sts_error;
                   l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                                     p_region_code   => G_AK_REGION_NAME,
                                                     p_attribute_code    => 'OKL_LA_SEC_INV_BILL_TO');

                   OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                           , p_msg_name => 'OKL_REQUIRED_VALUE'
                                           , p_token1 => 'COL_NAME'
                                           , p_token1_value => l_ak_prompt
                                          );
                   RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;

        IF(p_inv_tbl(i).CUST_ACCT_ID IS NULL OR
                      p_inv_tbl(i).CUST_ACCT_ID = ''    OR
                      p_inv_tbl(i).CUST_ACCT_ID = OKC_API.G_MISS_NUM) THEN

                       x_return_status := OKC_API.g_ret_sts_error;
                       l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                                         p_region_code   => G_AK_REGION_NAME,
                                                         p_attribute_code    => 'OKL_LA_SEC_INV_CUST_ACCOUNT');

                       OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                               , p_msg_name => 'OKL_REQUIRED_VALUE'
                                               , p_token1 => 'COL_NAME'
                                               , p_token1_value => l_ak_prompt
                                              );
                       RAISE OKC_API.G_EXCEPTION_ERROR;
               END IF;

        EXIT WHEN (i >= p_inv_tbl.last);
       END LOOP;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


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


END validate_investor;



PROCEDURE create_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type,
    x_inv_tbl                      OUT NOCOPY inv_tbl_type) IS

  l_cplv_rec    cplv_rec_type;
  l_clev_rec    clev_rec_type;
  l_klev_rec    klev_rec_type;

  lx_cplv_rec    cplv_rec_type;
  lx_clev_rec    clev_rec_type;
  lx_klev_rec    klev_rec_type;


  l_inv_rec     inv_rec_type;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'CREATE_CONTRACT_PARTY';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;
  l_exists BOOLEAN := FALSE;
  lse_id NUMBER;
  lx_currency_code VARCHAR2(15) := '';
  lx_org_id VARCHAR2(15) := '';
  lx_end_date DATE;

  l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

  BEGIN

        --dbms_output.put_line('begin .......... ..');
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

        --delete from okl_sec_temp;

        validate_investor(
                p_api_version        => p_api_version,
                p_init_msg_list      => p_init_msg_list,
                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,
                p_inv_tbl            => p_inv_tbl);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


      lse_id := get_lse_id(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_lty_code                     => G_TOPLINE_LTY_CODE);

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF(p_inv_tbl.COUNT > 0) THEN

        get_header_details(
        p_api_version                  => p_api_version,
        p_init_msg_list                => p_init_msg_list,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chr_id                       => p_inv_tbl(1).cpl_dnz_chr_id,
        x_currency_code                => lx_currency_code,
        x_org_id                       => lx_org_id,
        x_end_date                     => lx_end_date);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        --dbms_output.put_line('lx_currency_code '||lx_currency_code);
        --dbms_output.put_line('lx_end_date '||lx_end_date);
      END IF;


      LOOP
        i := i + 1;

       migrate_records(
           p_inv_rec                      => p_inv_tbl(i),
           x_cplv_rec                     => l_cplv_rec,
           x_clev_rec                     => l_clev_rec,
           x_klev_rec                     => l_klev_rec);

--insert into okl_sec_temp values (l_cplv_rec.dnz_chr_id, 'create ');
--insert into okl_sec_temp values (l_cplv_rec.dnz_chr_id, 'before count '||l_cplv_rec.object1_id1||l_cplv_rec.object1_id2);

        l_exists := check_parties(
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_cplv_rec                     => l_cplv_rec);


   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


--dbms_output.put_line('l_count '||l_count);

    IF(l_exists) THEN
            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := Okl_Accounting_Util.Get_Message_Token(
                                              p_region_code   => G_AK_REGION_NAME,
                                              p_attribute_code    => 'OKL_LA_SEC_INVESTOR');
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                                    , p_msg_name => 'OKL_DUP_PARTY'
                                    , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                                      );
                    RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_clev_rec.dnz_chr_id := l_cplv_rec.dnz_chr_id;
    l_clev_rec.chr_id     := l_cplv_rec.dnz_chr_id;
    l_clev_rec.lse_id     := lse_id;
    l_clev_rec.display_sequence := 1;
    l_clev_rec.exception_yn := 'N';
    l_clev_rec.sts_code := 'NEW';

    l_clev_rec.currency_code := lx_currency_code;
    l_clev_rec.end_date := lx_end_date;


--    insert into okl_sec_temp values ('1 ',l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));

    l_klev_rec.AMOUNT := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(p_amount => TO_NUMBER(l_klev_rec.AMOUNT),
                                             p_currency_code => lx_currency_code);

--    insert into okl_sec_temp values ('2 ', l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));

    --dbms_output.put_line('l_cplv_rec.dnz_chr_id '||l_cplv_rec.dnz_chr_id);


    OKL_CONTRACT_PUB.create_contract_line(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_clev_rec           => l_clev_rec,
        p_klev_rec           => l_klev_rec,
        x_clev_rec           => lx_clev_rec,
        x_klev_rec           => lx_klev_rec);

        l_cplv_rec.cle_id := lx_clev_rec.id;

   --dbms_output.put_line('lx_clev_rec.id '||lx_clev_rec.id);

   --dbms_output.put_line('x_return_status '||x_return_status);
   --dbms_output.put_line('x_msg_count '||x_msg_count);

   x_inv_tbl(1).cle_id := lx_clev_rec.id;
   x_inv_tbl(1).cle_sts_code := lx_clev_rec.sts_code;
   --x_inv_tbl(1).description  :=

--   insert into okl_sec_temp values ('3 ',l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));

   x_inv_tbl(1).description := OKL_ACCOUNTING_UTIL.format_amount(p_amount => TO_NUMBER(l_klev_rec.AMOUNT),
                                                  p_currency_code => lx_currency_code);

--   insert into okl_sec_temp values ('4 ',l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_cplv_rec.rle_code := G_INVESTOR_RLE_CODE;
   l_cplv_rec.jtot_object1_code := G_INVESTOR_OBJECT_CODE;


  OKL_OKC_MIGRATION_PVT.create_k_party_role(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              l_cplv_rec,
                              lx_cplv_rec);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
EXIT WHEN (i >= p_inv_tbl.last);
END LOOP;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
--         insert into okl_sec_temp values (751, 'here ');
--COMMIT;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
--      COMMIT;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
--      COMMIT;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END create_investor;



PROCEDURE update_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type,
    x_inv_tbl                      OUT NOCOPY inv_tbl_type) IS

  -- Cursor for getting the status of the open transaction
 CURSOR l_trans_status_csr(p_ia_id IN NUMBER)
  IS
  SELECT  pools.transaction_status,pools.id,pools.pol_id FROM OKL_POOL_TRANSACTIONS pools,OKL_POOLS header
  where pools.transaction_status <> 'COMPLETE'
  and pools.transaction_type='ADD' and pools.transaction_reason='ADJUSTMENTS'
  and pools.pol_id=header.id and header.khr_id=p_ia_id ;


  l_cplv_rec    cplv_rec_type;
  l_clev_rec    clev_rec_type;
  l_klev_rec    klev_rec_type;

  lx_cplv_rec    cplv_rec_type;
  lx_clev_rec    clev_rec_type;
  lx_klev_rec    klev_rec_type;
  l_transaction_status VARCHAR2(30);
  l_trx_id NUMBER;
  l_pol_id NUMBER;

  l_inv_rec     inv_rec_type;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_PARTY';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;
  l_count NUMBER := 0;
  lse_id NUMBER;

  lx_currency_code VARCHAR2(15) := '';
  lx_org_id VARCHAR2(15) := '';
  lx_end_date DATE;

    lp_poxv_rec      OKL_POX_PVT.poxv_rec_type;
   lx_poxv_rec      OKL_POX_PVT.poxv_rec_type;

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

        validate_investor(
                        p_api_version        => p_api_version,
                        p_init_msg_list      => p_init_msg_list,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_inv_tbl            => p_inv_tbl);

                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

--    insert into okl_sec_temp values ('u-1 ',0, lx_currency_code, lx_org_id, '');

        get_header_details(
        p_api_version                  => p_api_version,
        p_init_msg_list                => p_init_msg_list,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chr_id                       => p_inv_tbl(1).cpl_dnz_chr_id,
        x_currency_code                => lx_currency_code,
        x_org_id                       => lx_org_id,
        x_end_date                     => lx_end_date);

--    insert into okl_sec_temp values ('u-2 ',0, lx_currency_code, lx_org_id, '');

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                   RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

--    insert into okl_sec_temp values ('u-3 ',0, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));
      LOOP
        i := i + 1;

       migrate_records(
           p_inv_rec                      => p_inv_tbl(i),
           x_cplv_rec                     => l_cplv_rec,
           x_clev_rec                     => l_clev_rec,
           x_klev_rec                     => l_klev_rec);


    --dbms_output.put_line('l_cplv_rec.dnz_chr_id '||l_cplv_rec.dnz_chr_id);

    l_clev_rec.currency_code := lx_currency_code;
    l_clev_rec.end_date := lx_end_date;


--    insert into okl_sec_temp values ('u1 ',l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));


    l_klev_rec.AMOUNT := OKL_ACCOUNTING_UTIL.cross_currency_round_amount(p_amount => TO_NUMBER(l_klev_rec.AMOUNT),
                                             p_currency_code => lx_currency_code);

    --insert into okl_sec_temp values ('u2 ', l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));



    OKL_CONTRACT_PUB.update_contract_line(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_clev_rec           => l_clev_rec,
        p_klev_rec           => l_klev_rec,
        x_clev_rec           => lx_clev_rec,
        x_klev_rec           => lx_klev_rec);

        l_cplv_rec.cle_id := lx_clev_rec.id;

   --dbms_output.put_line('lx_clev_rec.id '||lx_clev_rec.id);

   --dbms_output.put_line('x_return_status '||x_return_status);
   --dbms_output.put_line('x_msg_count '||x_msg_count);

   x_inv_tbl(1).cle_id := lx_clev_rec.id;


   x_inv_tbl(1).cle_sts_code := lx_clev_rec.sts_code;
   --x_inv_tbl(1).description  :=

--   insert into okl_sec_temp values ('u3 ',l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, to_char(l_klev_rec.AMOUNT));

   x_inv_tbl(1).description := OKL_ACCOUNTING_UTIL.format_amount(p_amount => TO_NUMBER(l_klev_rec.AMOUNT),
                                                  p_currency_code => lx_currency_code);

--   insert into okl_sec_temp values ('u4 ',l_cplv_rec.dnz_chr_id, lx_currency_code, lx_org_id, x_inv_tbl(1).description);


      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

EXIT WHEN (i >= p_inv_tbl.last);
END LOOP;
-- get existing the transaction status
    OPEN l_trans_status_csr(p_inv_tbl(1).cpl_dnz_chr_id);
       FETCH l_trans_status_csr INTO l_transaction_status,l_trx_id,l_pol_id;
       CLOSE l_trans_status_csr;

    IF l_transaction_status = 'APPROVAL_REJECTED' THEN
      lp_poxv_rec.TRANSACTION_STATUS := 'INCOMPLETE';
      lp_poxv_rec.POL_ID := l_pol_id;
      lp_poxv_rec.ID := l_trx_id;

    -- create ADD transaction for Adjustment
      Okl_Pool_Pvt.update_pool_transaction(p_api_version   => p_api_version
 	                                    ,p_init_msg_list => p_init_msg_list
 	                                    ,x_return_status => l_return_status
 	                                    ,x_msg_count     => x_msg_count
 	                                    ,x_msg_data      => x_msg_data
 	                                    ,p_poxv_rec      => lp_poxv_rec
 	                                    ,x_poxv_rec      => lx_poxv_rec);

     IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;
   END IF;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
--      commit;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
--      commit;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      WHEN OTHERS THEN
--      commit;
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END update_investor;


PROCEDURE delete_investor(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inv_tbl                      IN  inv_tbl_type) IS

    l_clev_rec    clev_rec_type;
    l_klev_rec    klev_rec_type;

    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30) := 'DELETE_CONTRACT_PARTY';
    l_api_version            CONSTANT NUMBER    := 1.0;

    i NUMBER := 0;
    l_count NUMBER := 0;
    lse_id NUMBER;

    -- gboomina Bug 6814331 - Start
    -- Cursor to get Fee lines defined for an Investor
    CURSOR investor_fee_line_csr ( p_investor_line_id NUMBER) IS
      SELECT okc_fee_line.id ,
             okc_fee_line.chr_id
      FROM okc_k_lines_b okc_fee_line ,
           okl_k_lines okl_fee_line ,
           okc_line_styles_b lse ,
           okc_k_party_roles_b inv_line_role ,
           okc_k_party_roles_b fee_line_role
      WHERE inv_line_role.cle_id = p_investor_line_id
        AND inv_line_role.object1_id1 = fee_line_role.object1_id1
        AND inv_line_role.rle_code = fee_line_role.rle_code
        AND inv_line_role.dnz_chr_id = fee_line_role.dnz_chr_id
        AND fee_line_role.cle_id = okc_fee_line.id
        AND okc_fee_line.lse_id = lse.id
        AND lse.lty_code = 'FEE'
        AND okc_fee_line.chr_id = fee_line_role.dnz_chr_id
        AND okc_fee_line.id = okl_fee_line.id;

    investor_fee_line_rec  investor_fee_line_csr%ROWTYPE;
    l_fee_rec              OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    -- gboomina Bug 6814331 - End

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

    LOOP
      i := i + 1;

      -- gboomina Bug 6814331 - Start
      -- Delete fees attached to the investor before deleting the
      -- investor line
      FOR investor_fee_line_rec IN investor_fee_line_csr(p_inv_tbl(i).cle_id)
      LOOP
        l_fee_rec.line_id := investor_fee_line_rec.id;
        l_fee_rec.dnz_chr_id := investor_fee_line_rec.chr_id;

        OKL_MAINTAIN_FEE_PVT.delete_fee_type (
                                 p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                 x_return_status  => x_return_status,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data,
                                 p_fee_types_rec  => l_fee_rec) ;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END LOOP;
      -- gboomina Bug 6814331 - End

      -- Delete investor line now after all the fees attached to the
      -- investor got deleted successfully
      OKL_CONTRACT_PUB.delete_contract_line(
          p_api_version        => p_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_line_id            => p_inv_tbl(i).cle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXIT WHEN (i >= p_inv_tbl.last);
  END LOOP;

  --Call End Activity
  OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                       x_msg_data     => x_msg_data);


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


END delete_investor;



/*

Procedure get_sec_header_info(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_chr_id_old                   IN  NUMBER,
    x_hdr_tbl                      OUT NOCOPY hdr_tbl_type) IS

  l_api_name               CONSTANT VARCHAR2(30) := 'GET_SEC_HEADER_INFO';
  l_api_version            CONSTANT NUMBER    := 1.0;

   Cursor chr_csr ( chrId NUMBER ) IS
   SELECT
   CHR.ID ID,
   CHR.CONTRACT_NUMBER CONTRACT_NUMBER,
   TL.SHORT_DESCRIPTION SHORT_DESCRIPTION,
   CHR.START_DATE START_DATE,
   CHR.END_DATE END_DATE,
   CHR.AUTHORING_ORG_ID AUTHORING_ORG_ID,
   CHR.INV_ORGANIZATION_ID INV_ORG_ID,
   CHR.STS_CODE STS_CODE,
   STL.MEANING MEANING,
   FND.CURRENCY_CODE CURRENCY_CODE,
   FND.NAME CURRENCY,
   KLP.ID PDT_ID,
   KLP.NAME PRODUCT_NAME,
   KLP.DESCRIPTION PRODUCT_DESCRIPTION,
   POL.POOL_NUMBER,
   POL.TOTAL_PRINCIPAL_AMOUNT,
   POL.TOTAL_RECEIVABLE_AMOUNT
   FROM
   OKC_K_HEADERS_B CHR,OKC_STATUSES_TL STL,OKC_K_HEADERS_TL TL,OKL_K_HEADERS KHR,
   OKL_PRODUCTS KLP, OKL_POOLS POL, FND_CURRENCIES_VL FND
   WHERE
   TL.ID = CHR.ID AND STL.CODE = CHR.STS_CODE AND TL.LANGUAGE = USERENV('LANG')
   AND KHR.ID = CHR.ID AND KLP.ID(+) = KHR.PDT_ID
   AND CHR.CURRENCY_CODE = FND.CURRENCY_CODE
   AND CHR.SCS_CODE = 'INVESTOR_AGREEMENT'
   AND CHR.ID = POL.KHR_ID
   AND CHR.ID = chrId;

  CHR_REC chr_csr%ROWTYPE;

     BEGIN

     If ( ( nvl(p_chr_id,0) <>  0 )
             AND ((nvl(p_chr_id_old,0) = 0)
                   OR  ( p_chr_id <> p_chr_id_old) )) Then

        OPEN  chr_csr( p_chr_id );
        FETCH chr_csr INTO CHR_REC;
        if (chr_csr%NOTFOUND ) Then
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
        CLOSE chr_csr;

        x_hdr_tbl(1) :=    CHR_REC.ID;
        x_hdr_tbl(2) :=    CHR_REC.CONTRACT_NUMBER;
        x_hdr_tbl(3) :=    CHR_REC.SHORT_DESCRIPTION;
        x_hdr_tbl(4) :=    CHR_REC.START_DATE;
        x_hdr_tbl(5) :=    CHR_REC.END_DATE;
        x_hdr_tbl(6) :=    CHR_REC.AUTHORING_ORG_ID;
        x_hdr_tbl(7) :=    CHR_REC.INV_ORG_ID;
        x_hdr_tbl(8) :=    CHR_REC.STS_CODE;
        x_hdr_tbl(9) :=    CHR_REC.MEANING;
        x_hdr_tbl(10) :=   CHR_REC.CURRENCY_CODE;
        x_hdr_tbl(11) :=   CHR_REC.CURRENCY;
        x_hdr_tbl(12) :=   CHR_REC.PDT_ID;
        x_hdr_tbl(13) :=   CHR_REC.PRODUCT_NAME;
        x_hdr_tbl(14) :=   CHR_REC.PRODUCT_DESCRIPTION;
        x_hdr_tbl(15) :=   CHR_REC.POOL_NUMBER;
        x_hdr_tbl(16) :=   CHR_REC.TOTAL_PRINCIPAL_AMOUNT;
        x_hdr_tbl(17) :=   CHR_REC.TOTAL_RECEIVABLE_AMOUNT;

    Else
       x_hdr_tbl(1) := 'GET_FROM_REQUEST';
    End if;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    Exception
        when OKL_API.G_EXCEPTION_ERROR then
                x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

        when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
                x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

        when OTHERS then
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);


  END get_sec_header_info;
  */


END Okl_Sec_Investor_Pvt;

/
