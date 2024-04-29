--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_UPDATE_PVT" AS
/* $Header: OKLRAEUB.pls 115.3 2002/12/18 12:45:56 kjinger noship $ */


PROCEDURE  UPDATE_ACCT_ENTRIES(p_api_version        IN      NUMBER,
                               p_init_msg_list      IN      VARCHAR2,
                               x_return_status      OUT     NOCOPY VARCHAR2,
                               x_msg_count          OUT     NOCOPY NUMBER,
                               x_msg_data           OUT     NOCOPY VARCHAR2,
                               p_aelv_rec           IN      AELV_REC_TYPE,
                               x_aelv_rec           OUT NOCOPY     AELV_REC_TYPE)

IS

  l_result               VARCHAR2(1) := OKL_API.G_FALSE;
  l_ae_header_id         NUMBER;
  l_accounting_event_id  NUMBER;
  l_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS ;

  CURSOR aelv_csr(v_line_id NUMBER) IS
  SELECT ae_header_id
  FROM OKL_AE_LINES
  WHERE ae_line_id = v_line_id;

  CURSOR aehv_csr(v_hdr_id NUMBER) IS
  SELECT accounting_event_id
  FROM OKL_AE_HEADERS
  WHERE ae_header_id = v_hdr_id;

  l_aelv_rec       AELV_REC_TYPE ;
  l_aehv_rec_in    OKL_ACCT_EVENT_PUB.AEHV_REC_TYPE;
  l_aehv_rec_out   OKL_ACCT_EVENT_PUB.AEHV_REC_TYPE;
  l_aetv_rec_in    OKL_ACCT_EVENT_PUB.AETV_REC_TYPE;
  l_aetv_rec_out   OKL_ACCT_EVENT_PUB.AETV_REC_TYPE;


BEGIN

    l_aelv_rec := p_aelv_rec;
    l_result := OKL_ACCOUNTING_UTIL.validate_gl_ccid(l_aelv_rec.code_combination_id);

    IF (l_result = OKL_API.G_TRUE) THEN

        l_aelv_rec.accounting_error_code := NULL;

        OKL_ACCT_EVENT_PUB.UPDATE_ACCT_LINES(p_api_version       => p_api_version,
                                             p_init_msg_list     => p_init_msg_list,
                                             x_return_status     => l_return_status,
                                             x_msg_count         => x_msg_count,
                                             x_msg_data          => x_msg_data,
                                             p_aelv_rec          => l_aelv_rec,
                                             x_aelv_rec          => x_aelv_rec);

        IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

            OPEN aelv_csr(p_aelv_rec.ae_line_id);
            FETCH aelv_csr INTO l_ae_header_id;
            CLOSE aelv_csr;

            OPEN aehv_csr(l_ae_header_id);
            FETCH aehv_csr INTO l_accounting_event_id;
            CLOSE aehv_csr;

            l_aehv_rec_in.ae_header_id := l_ae_header_id;
            l_aehv_rec_in.accounting_error_code := NULL;

            l_aetv_rec_in.accounting_Event_id := l_accounting_event_id;
            l_aetv_rec_in.event_status_code := 'ACCOUNTED';

            OKL_ACCT_EVENT_PUB.UPDATE_ACCT_HEADER(p_api_version       => p_api_version,
                                                  p_init_msg_list     => p_init_msg_list,
                                                  x_return_status     => l_return_status,
                                                  x_msg_count         => x_msg_count,
                                                  x_msg_data          => x_msg_data,
                                                  p_aehv_rec          => l_aehv_rec_in,
                                                  x_aehv_rec          => l_aehv_rec_out);

            IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

                OKL_ACCT_EVENT_PUB.UPDATE_ACCT_EVENT(p_api_version       => p_api_version,
                                                     p_init_msg_list     => p_init_msg_list,
                                                     x_return_status     => l_return_status,
                                                     x_msg_count         => x_msg_count,
                                                     x_msg_data          => x_msg_data,
                                                     p_aetv_rec          => l_aetv_rec_in,
                                                     x_aetv_rec          => l_aetv_rec_out);
            END IF;

        END IF;

    ELSE

        Okc_Api.SET_MESSAGE(p_app_name     => 'OKC',
                            p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'CODE_COMBINATION_ID');

        l_return_status := OKL_API.G_RET_STS_ERROR;

   END IF;

   x_return_status := l_return_status;

EXCEPTION

  WHEN OTHERS THEN
      OKL_API.SET_MESSAGE(p_app_name      => g_app_name
                         ,p_msg_name      => g_unexpected_error
                         ,p_token1        => g_sqlcode_token
                         ,p_token1_value  => SQLCODE
                         ,p_token2        => g_sqlerrm_token
                         ,p_token2_value  => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_ACCT_ENTRIES;


END OKL_ACCOUNTING_UPDATE_PVT;

/
