--------------------------------------------------------
--  DDL for Package Body OKL_POPULATE_PRCENG_RESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POPULATE_PRCENG_RESULT_PVT" AS
/* $Header: OKLRPERB.pls 120.3 2005/10/30 04:35:42 appldev noship $ */

  FUNCTION get_rec (
    p_sirv_rec                     IN sirv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sirv_rec_type IS
    CURSOR sirv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            TRANSACTION_NUMBER,
            SRT_CODE,
            EFFECTIVE_PRE_TAX_YIELD,
            YIELD_NAME,
            INDEX_NUMBER,
            EFFECTIVE_AFTER_TAX_YIELD,
            NOMINAL_PRE_TAX_YIELD,
            NOMINAL_AFTER_TAX_YIELD,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            IMPLICIT_INTEREST_RATE,
            DATE_PROCESSED,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
            -- end,mvasudev -- 02/21/2002
      FROM Okl_Sif_Rets_V
     WHERE okl_sif_rets_v.id    = p_id;
    l_sirv_pk                      sirv_pk_csr%ROWTYPE;
    l_sirv_rec                     sirv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sirv_pk_csr (p_sirv_rec.id);
    FETCH sirv_pk_csr INTO
              l_sirv_rec.ID,
              l_sirv_rec.TRANSACTION_NUMBER,
              l_sirv_rec.SRT_CODE,
              l_sirv_rec.EFFECTIVE_PRE_TAX_YIELD,
              l_sirv_rec.YIELD_NAME,
              l_sirv_rec.INDEX_NUMBER,
              l_sirv_rec.EFFECTIVE_AFTER_TAX_YIELD,
              l_sirv_rec.NOMINAL_PRE_TAX_YIELD,
              l_sirv_rec.NOMINAL_AFTER_TAX_YIELD,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_sirv_rec.OBJECT_VERSION_NUMBER,
              l_sirv_rec.CREATED_BY,
              l_sirv_rec.LAST_UPDATED_BY,
              l_sirv_rec.CREATION_DATE,
              l_sirv_rec.LAST_UPDATE_DATE,
              l_sirv_rec.LAST_UPDATE_LOGIN,
              l_sirv_rec.IMPLICIT_INTEREST_RATE,
              l_sirv_rec.DATE_PROCESSED,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            l_sirv_rec.REQUEST_ID,
            l_sirv_rec.PROGRAM_APPLICATION_ID,
            l_sirv_rec.PROGRAM_ID,
            l_sirv_rec.PROGRAM_UPDATE_DATE;
            -- end,mvasudev -- 02/21/2002

    x_no_data_found := sirv_pk_csr%NOTFOUND;
    CLOSE sirv_pk_csr;
    RETURN(l_sirv_rec);
  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_rets for: OKL_SIF_RETS
  ---------------------------------------------------------------------------
  PROCEDURE populate_sif_rets(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_sirv_rec                     IN  sirv_rec_type,
                              x_sirv_rec                     OUT NOCOPY sirv_rec_type
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_rets';
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    OKL_SIF_RETS_PUB.insert_sif_rets(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => l_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_sirv_rec      => p_sirv_rec,
                                     x_sirv_rec      => x_sirv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_sif_rets;

-- Update Added by Saran

  PROCEDURE update_sif_rets(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_sirv_rec                     IN  sirv_rec_type,
                              x_sirv_rec                     OUT NOCOPY sirv_rec_type
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'update_sif_rets';
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_sirv_rec  sirv_rec_type;
	l_no_data_found BOOLEAN := FALSE;

  BEGIN
    l_sirv_rec := get_rec (p_sirv_rec, l_no_data_found);

	IF(p_sirv_rec.transaction_number <> G_MISS_NUM)
	THEN
	  l_sirv_rec.transaction_number := p_sirv_rec.transaction_number;
	END IF;
	IF(p_sirv_rec.index_number <> G_MISS_NUM)
	THEN
	  l_sirv_rec.index_number := p_sirv_rec.index_number;
	END IF;
	IF(p_sirv_rec.implicit_interest_rate <> G_MISS_NUM)
	THEN
	  l_sirv_rec.implicit_interest_rate := p_sirv_rec.implicit_interest_rate;
	END IF;
	IF(p_sirv_rec.yield_name <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.yield_name := p_sirv_rec.yield_name;
	END IF;
	IF(p_sirv_rec.srt_code <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.srt_code := p_sirv_rec.srt_code;
	END IF;
	IF(p_sirv_rec.date_processed <> G_MISS_DATE)
	THEN
	  l_sirv_rec.date_processed := p_sirv_rec.date_processed;
	END IF;
	IF(p_sirv_rec.effective_pre_tax_yield <> G_MISS_NUM)
	THEN
	  l_sirv_rec.effective_pre_tax_yield := p_sirv_rec.effective_pre_tax_yield;
	END IF;
	IF(p_sirv_rec.effective_after_tax_yield <> G_MISS_NUM)
	THEN
	  l_sirv_rec.effective_after_tax_yield := p_sirv_rec.effective_after_tax_yield;
	END IF;
	IF(p_sirv_rec.nominal_pre_tax_yield <> G_MISS_NUM)
	THEN
	  l_sirv_rec.nominal_pre_tax_yield := p_sirv_rec.nominal_pre_tax_yield;
	END IF;
	IF(p_sirv_rec.nominal_after_tax_yield <> G_MISS_NUM)
	THEN
	  l_sirv_rec.nominal_after_tax_yield := p_sirv_rec.nominal_after_tax_yield;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute01 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute01 := p_sirv_rec.stream_interface_attribute01;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute02 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute02 := p_sirv_rec.stream_interface_attribute02;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute03 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute03 := p_sirv_rec.stream_interface_attribute03;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute04 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute04 := p_sirv_rec.stream_interface_attribute04;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute05 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute05 := p_sirv_rec.stream_interface_attribute05;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute06 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute06 := p_sirv_rec.stream_interface_attribute06;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute07 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute07 := p_sirv_rec.stream_interface_attribute07;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute08 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute08 := p_sirv_rec.stream_interface_attribute08;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute09 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute09 := p_sirv_rec.stream_interface_attribute09;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute10 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute10 := p_sirv_rec.stream_interface_attribute10;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute11 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute11 := p_sirv_rec.stream_interface_attribute11;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute12 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute12 := p_sirv_rec.stream_interface_attribute12;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute13 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute13 := p_sirv_rec.stream_interface_attribute13;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute14 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute14 := p_sirv_rec.stream_interface_attribute14;
	END IF;
	IF(p_sirv_rec.stream_interface_attribute15 <> G_MISS_CHAR)
	THEN
	  l_sirv_rec.stream_interface_attribute15 := p_sirv_rec.stream_interface_attribute15;
	END IF;
	IF(p_sirv_rec.request_id <> G_MISS_NUM)
	THEN
	  l_sirv_rec.request_id := p_sirv_rec.request_id;
	END IF;
	IF(p_sirv_rec.program_application_id <> G_MISS_NUM)
	THEN
	  l_sirv_rec.program_application_id := p_sirv_rec.program_application_id;
	END IF;
	IF(p_sirv_rec.program_id <> G_MISS_NUM)
	THEN
	  l_sirv_rec.program_id := p_sirv_rec.program_id;
	END IF;
	IF(p_sirv_rec.program_update_date <> G_MISS_DATE)
	THEN
	  l_sirv_rec.program_update_date := p_sirv_rec.program_update_date;
	END IF;

    OKL_SIF_RETS_PUB.update_sif_rets(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => l_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_sirv_rec      => l_sirv_rec,
                                     x_sirv_rec      => x_sirv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_sif_rets;

  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_strms for: OKL_SIF_RET_STREAMS
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_strms (p_api_version                  IN  NUMBER,
                                    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status                OUT NOCOPY VARCHAR2,
                                    x_msg_count                    OUT NOCOPY NUMBER,
                                    x_msg_data                     OUT NOCOPY VARCHAR2,
                                    p_srsv_rec                     IN  srsv_rec_type,
                                    x_srsv_rec                     OUT NOCOPY srsv_rec_type
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_strms';
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
  	--dbms_output.PUT_LINE('populate_sif_ret_strms pvt');
--BAKUCHIB Bug#2807737 start
    OKL_SIF_RET_STRMS_PUB.insert_sif_ret_strms_per(
                          p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => l_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_srsv_rec      => p_srsv_rec,
                          x_srsv_rec      => x_srsv_rec);
    G_COUNTER := G_COUNTER + 1;
    G_SRSV_TBL(G_COUNTER) := x_srsv_rec;
--BAKUCHIB Bug#2807737 end
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_sif_ret_strms;


  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_errors for: OKL_SIF_RET_ERRORS
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_errors (p_api_version                  IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_srmv_rec                     IN  srmv_rec_type,
                                     x_srmv_rec                     OUT NOCOPY srmv_rec_type
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_errors';
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    OKL_SIF_RET_ERRORS_PUB.insert_sif_ret_errors(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => l_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_srmv_rec      => p_srmv_rec,
                                                 x_srmv_rec      => x_srmv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_sif_ret_errors;

  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_errors for: OKL_SIF_RET_ERRORS
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_levels (
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_srlv_rec                     IN  srlv_rec_type,
    x_srlv_rec                     OUT NOCOPY srlv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_levels';
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    OKL_SIF_RET_LEVELS_PUB.insert_sif_ret_levels(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => l_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_srlv_rec      => p_srlv_rec,
                                                 x_srlv_rec      => x_srlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END populate_sif_ret_levels;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_status
  -- Directly updates the status at the contrat header level
  -- For outbound
  ---------------------------------------------------------------------------
  PROCEDURE update_outbound_status (
    p_api_version    IN NUMBER,
    p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_sifv_rec       IN sifv_rec_type,
    x_sifv_rec       OUT NOCOPY sifv_rec_type,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2) IS
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name  CONSTANT VARCHAR2(30) := 'update_outbound_status';
  BEGIN
--BAKUCHIB Bug#2807737 start
  --Added by BKATRAGA.
  --Bug 4302322 -Start of changes
   IF(G_COUNTER > 0) THEN
    OKL_SIF_RET_STRMS_PUB.MASS_INSERT_SIF_RET(p_srsv_tbl=>  G_SRSV_TBL);
   END IF;
  --Bug - End of Changes
--sgorantl Bug#3777084 start
    G_COUNTER := 0;
--sgorantl Bug#3777084 end
--BAKUCHIB Bug#2807737 End
    OKL_STREAM_INTERFACES_PUB.update_stream_interfaces(
                       p_api_version => p_api_version
	 	       ,p_init_msg_list => p_init_msg_list
	 	       ,x_return_status => l_return_status
	 	       ,x_msg_count => x_msg_count
	 	       ,x_msg_data => x_msg_data
	 	       ,p_sifv_rec => p_sifv_rec
	 	       ,x_sifv_rec => x_sifv_rec);

    IF l_return_status = G_RET_STS_ERROR THEN
	  RAISE G_EXCEPTION_ERROR;
	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_outbound_status;

END OKL_POPULATE_PRCENG_RESULT_PVT;

/
