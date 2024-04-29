--------------------------------------------------------
--  DDL for Package Body OKL_TRX_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRX_CONTRACTS_PVT" AS
  /* $Header: OKLCTCNB.pls 120.10.12010000.3 2008/08/25 21:22:05 smereddy ship $ */

 G_PRIMARY   CONSTANT VARCHAR2(200) := 'PRIMARY';
 G_SECONDARY  CONSTANT VARCHAR2(200) := 'SECONDARY';

  PROCEDURE create_trx_contracts(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                     IN  tcnv_rec_type
    ,p_tclv_tbl                     IN  tclv_tbl_type
    ,x_tcnv_rec                     OUT NOCOPY tcnv_rec_type
    ,x_tclv_tbl                     OUT NOCOPY tclv_tbl_type
    ) IS

    i                               NUMBER;
    l_tcnv_rec                      tcnv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_tclv_tbl                      tclv_tbl_type := p_tclv_tbl;

  BEGIN
  -- Populate TRX CONTRACTS
    create_trx_contracts(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_tcnv_rec      => p_tcnv_rec
                        ,x_tcnv_rec      => x_tcnv_rec);

    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN

         -- populate the foreign key for the detail
           IF (l_tclv_tbl.COUNT > 0) THEN
              i:= l_tclv_tbl.FIRST;
              LOOP
                l_tclv_tbl(i).tcn_id := x_tcnv_rec.id;

-- Added by Santonyr on 25-Nov-2002
-- Get the currency from transaction if the passed one is null

		IF (l_tclv_tbl(i).currency_code IS NULL) OR
		   (l_tclv_tbl(i).currency_code = OKL_API.G_MISS_CHAR) THEN
		   l_tclv_tbl(i).currency_code := x_tcnv_rec.currency_code;
		END IF;

                EXIT WHEN(i = l_tclv_tbl.LAST);
                i := l_tclv_tbl.NEXT(i);
              END LOOP;
           END IF;


           -- populate the detail
           create_trx_cntrct_lines(
                                     p_api_version   => p_api_version
                                    ,p_init_msg_list => p_init_msg_list
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,p_tclv_tbl      => l_tclv_tbl
                                    ,x_tclv_tbl      => x_tclv_tbl);
     END IF;

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => sqlcode
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_trx_contracts;

  PROCEDURE create_trx_contracts(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                IN  tcnv_rec_type
    ,x_tcnv_rec                OUT NOCOPY tcnv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
-- Added by zrehman for SLA project (Bug 5707866) 15-Feb-2007 start
    CURSOR cntr_prod_csr(pdt_id OKL_PRODUCTS.ID%TYPE) IS
    SELECT name
    FROM okl_products
    WHERE id = pdt_id;

    CURSOR book_csr(p_id OKL_PRODUCTS.ID%TYPE) IS
    SELECT quality_val, quality_name
    FROM okl_prod_qlty_val_uv
    WHERE pdt_id = p_id
    AND QUALITY_NAME IN ('LEASE', 'INVESTOR');

    CURSOR tax_csr(p_id OKL_PRODUCTS.ID%TYPE) IS
    SELECT quality_val
    FROM okl_prod_qlty_val_uv
    WHERE pdt_id = p_id
    AND QUALITY_NAME = 'TAXOWNER';

    CURSOR representation_csr(set_of_books_id OKL_TRX_CONTRACTS.set_of_books_id%TYPE) IS
    SELECT name,
           short_name
    FROM gl_ledgers
    WHERE ledger_id = set_of_books_id;

    CURSOR cntr_pid_csr(p_khr_id okl_k_headers.KHR_ID%TYPE) IS
    SELECT pdt_id
    FROM okl_k_headers
    WHERE id = p_khr_id;

    l_tcnv_rec  tcnv_rec_type;
    l_data_not_found NUMBER := 1;
    l_quality_name OKL_PDT_QUALITYS.NAME%TYPE;
  BEGIN
    l_tcnv_rec := p_tcnv_rec;

    --Modified by kthiruva for SLA Uptake
    --Set the sob id only if it has not been set already.
    IF(l_tcnv_rec.set_of_books_id IS NULL OR l_tcnv_rec.set_of_books_id = Okc_Api.G_MISS_NUM ) THEN
      l_tcnv_rec.set_of_books_id := okl_accounting_util.get_set_of_books_id;
    END IF;

    IF(l_tcnv_rec.REPRESENTATION_TYPE IS NULL OR l_tcnv_rec.REPRESENTATION_TYPE = Okc_Api.G_MISS_CHAR ) THEN
      l_tcnv_rec.REPRESENTATION_TYPE := G_PRIMARY;
    END IF;

    IF(l_tcnv_rec.representation_name IS NULL) OR (l_tcnv_rec.representation_name = Okc_Api.G_MISS_CHAR)
    OR (l_tcnv_rec.representation_code IS NULL) OR (l_tcnv_rec.representation_code = Okc_Api.G_MISS_CHAR) THEN
       OPEN representation_csr(l_tcnv_rec.set_of_books_id);
       FETCH representation_csr into l_tcnv_rec.representation_name, l_tcnv_rec.representation_code;
         IF representation_csr%NOTFOUND THEN
           OKL_API.set_message(
                            p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INVALID_VALUE',
                            p_token1       => 'COL_NAME',
                            p_token1_value => 'set_of_books_id'
                           );
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
       CLOSE representation_csr;
    END IF;

-- Added by zrehman for SLA project, to allow for null pdt_id (Bug 5707866) 14-Mar-2007 start
    IF(p_tcnv_rec.pdt_id IS NULL OR p_tcnv_rec.pdt_id = Okc_Api.G_MISS_NUM ) THEN
      IF p_tcnv_rec.khr_id IS NOT NULL AND p_tcnv_rec.khr_id <>Okc_Api.G_MISS_NUM THEN
        OPEN cntr_pid_csr(p_tcnv_rec.khr_id);
        FETCH cntr_pid_csr INTO l_tcnv_rec.pdt_id;
        IF cntr_pid_csr%NOTFOUND THEN
          l_data_not_found := 0;
        END IF;
        CLOSE cntr_pid_csr;
       IF(l_data_not_found = 0) THEN
           OKL_API.set_message(
                            p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INVALID_VALUE',
                            p_token1       => 'COL_NAME',
                            p_token1_value => 'khr_id'
                           );
        RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
     END IF;
  END IF;
-- Added by zrehman for SLA project, to allow for null pdt_id (Bug 5707866) 14-Mar-2007 end

    IF (l_tcnv_rec.PRODUCT_NAME IS NULL OR l_tcnv_rec.PRODUCT_NAME = Okc_Api.G_MISS_CHAR) THEN
      IF l_tcnv_rec.pdt_id IS NOT NULL AND l_tcnv_rec.pdt_id <>Okc_Api.G_MISS_NUM THEN
        OPEN cntr_prod_csr(l_tcnv_rec.pdt_id);
        FETCH cntr_prod_csr INTO  l_tcnv_rec.PRODUCT_NAME;
        IF cntr_prod_csr%NOTFOUND THEN
          l_data_not_found := 0;
        END IF;
        CLOSE cntr_prod_csr;
     END IF;
   END IF;

    IF (l_tcnv_rec.book_classification_code IS NULL OR l_tcnv_rec.book_classification_code = Okc_Api.G_MISS_CHAR) THEN
      IF l_tcnv_rec.pdt_id IS NOT NULL AND l_tcnv_rec.pdt_id <>Okc_Api.G_MISS_NUM THEN
        OPEN book_csr(l_tcnv_rec.pdt_id);
        FETCH book_csr INTO l_tcnv_rec.book_classification_code, l_quality_name;
        IF book_csr%NOTFOUND THEN
          l_data_not_found := 0;
        END IF;
       CLOSE book_csr;
      END IF;
    END IF;

    IF l_quality_name = 'LEASE' THEN
      IF (l_tcnv_rec.tax_owner_code IS NULL OR l_tcnv_rec.tax_owner_code = Okc_Api.G_MISS_CHAR) THEN
        IF l_tcnv_rec.pdt_id IS NOT NULL AND l_tcnv_rec.pdt_id <>Okc_Api.G_MISS_NUM THEN
          OPEN tax_csr(l_tcnv_rec.pdt_id);
          FETCH tax_csr INTO l_tcnv_rec.tax_owner_code;
          IF tax_csr%NOTFOUND THEN
            l_data_not_found := 0;
          END IF;
         CLOSE tax_csr;
       END IF;
      END IF;
    END IF;


     IF(l_data_not_found = 0) THEN
           OKL_API.set_message(
                            p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_INVALID_VALUE',
                            p_token1       => 'COL_NAME',
                            p_token1_value => 'pdt_id'
                           );
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
 -- Added by zrehman for SLA project (Bug 5707866) 15-Feb-2007 end
    okl_tcn_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tcnv_rec      => l_tcnv_rec
                          ,x_tcnv_rec      => x_tcnv_rec
                          );

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  -- Custom code if any

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := OKL_Api.G_RET_STS_UNEXP_ERROR;
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
         x_return_status := OKL_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKL_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => sqlcode
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => sqlerrm);
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END create_trx_contracts;

  PROCEDURE create_trx_contracts(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_tcnv_tbl                  IN  tcnv_tbl_type
    ,x_tcnv_tbl                  OUT NOCOPY tcnv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                            NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        create_trx_contracts(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i),
          x_tcnv_rec                     => x_tcnv_tbl(i));
        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;


    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => sqlcode
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END create_trx_contracts;

  -- Object type procedure for update
  PROCEDURE update_trx_contracts(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcnv_rec              IN  tcnv_rec_type,
    p_tclv_tbl              IN  tclv_tbl_type,
    x_tcnv_rec              OUT NOCOPY tcnv_rec_type,
    x_tclv_tbl              OUT NOCOPY tclv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_trx_contracts(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_tcnv_rec      => p_tcnv_rec
                        ,x_tcnv_rec      => x_tcnv_rec
                        );

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    -- Update the detail
    update_trx_cntrct_lines(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_tclv_tbl      => p_tclv_tbl
                             ,x_tclv_tbl      => x_tclv_tbl
                             );

     END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END update_trx_contracts;

  PROCEDURE validate_trx_contracts(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tcnv_rec              IN  tcnv_rec_type
    ,p_tclv_tbl              IN  tclv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- Validate the master
    validate_trx_contracts(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tcnv_rec      => p_tcnv_rec
                          );

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
       END IF;
    END IF;

    -- Validate the detail
    validate_trx_cntrct_lines(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_tclv_tbl      => p_tclv_tbl
                               );

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
       END IF;
    END IF;

    x_return_status := l_overall_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_trx_contracts;

  PROCEDURE lock_trx_contracts(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tcnv_rec              IN  tcnv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_tcn_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_tcnv_rec      => p_tcnv_rec
                        );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_trx_contracts;

  PROCEDURE lock_trx_contracts(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tcnv_tbl              IN  tcnv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        lock_trx_contracts(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;

    END IF;

     x_return_status := l_overall_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_trx_contracts;

  PROCEDURE update_trx_contracts(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                   IN  tcnv_rec_type
    ,x_tcnv_rec                   OUT NOCOPY tcnv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_tcnv_rec                    tcnv_rec_type;
  BEGIN
  -- Added by zrehman on 16-Mar-2007 as part of SLA Bug#5707866 Start
    l_tcnv_rec  := p_tcnv_rec;
    IF l_tcnv_rec.TSU_CODE = 'CANCELED' THEN
       l_tcnv_rec.ACCOUNTING_REVERSAL_YN := 'Y';
    END IF;
  -- Added by zrehman on 16-Mar-2007 as part of SLA Bug#5707866 End
    okl_tcn_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tcnv_rec      => l_tcnv_rec -- Bug#5707866
                          ,x_tcnv_rec      => x_tcnv_rec
                          );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_trx_contracts;

  PROCEDURE update_trx_contracts(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_tcnv_tbl                   IN  tcnv_tbl_type
    ,x_tcnv_tbl                   OUT NOCOPY tcnv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;

  BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        update_trx_contracts(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i),
          x_tcnv_rec                     => x_tcnv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_trx_contracts;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_trx_contracts(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tcnv_rec              IN  tcnv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tclv_tbl               tclv_tbl_type;

    CURSOR tcl_csr IS
      SELECT tcl.id
        FROM OKL_TXL_CNTRCT_LNS tcl
       WHERE tcl.tcn_id = p_tcnv_rec.id;
  BEGIN
    FOR tcl_rec IN tcl_csr
    LOOP
      i := i + 1;
      l_tclv_tbl(i).id := tcl_rec.id;
    END LOOP;

    delete_trx_cntrct_lines( p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_tclv_tbl      => l_tclv_tbl);


    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      okl_tcn_pvt.delete_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tcnv_rec      => p_tcnv_rec);

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_trx_contracts;


  PROCEDURE delete_trx_contracts(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tcnv_tbl              IN  tcnv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        delete_trx_contracts(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tcnv_rec      => p_tcnv_tbl(i)
                            );

         IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
         END IF;

         EXIT WHEN (i = p_tcnv_tbl.LAST);
         i := p_tcnv_tbl.NEXT(i);
       END LOOP;

      END IF;

      x_return_status := l_overall_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_trx_contracts;

  PROCEDURE validate_trx_contracts(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                   IN  tcnv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tcn_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tcnv_rec      => p_tcnv_rec
                            );
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_contracts;

  PROCEDURE validate_trx_contracts(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_tcnv_tbl                  IN  tcnv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
      i                           NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tcnv_tbl.COUNT > 0) THEN
      i := p_tcnv_tbl.FIRST;
      LOOP
        validate_trx_contracts(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tcnv_rec                     => p_tcnv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);
      END LOOP;

    END IF;

     x_return_status := l_overall_status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_contracts;

  PROCEDURE create_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_rec                       IN  tclv_rec_type
    ,x_tclv_rec                       OUT NOCOPY tclv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_stream_type_code                OKL_TXL_CNTRCT_LNS.STREAM_TYPE_CODE%TYPE;
    l_stream_type_purpose             OKL_TXL_CNTRCT_LNS.STREAM_TYPE_PURPOSE%TYPE;
    CURSOR okl_strm_type_csr(sty_id IN  OKL_TXL_CNTRCT_LNS.STY_ID%TYPE) IS
    SELECT
     code,
     stream_type_purpose
    FROM
     OKL_STRM_TYPE_B
    WHERE
     id = sty_id;
     l_tclv_rec  tclv_rec_type;
  BEGIN
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007 start
    l_tclv_rec := p_tclv_rec;
    IF (p_tclv_rec.sty_id IS NOT NULL AND p_tclv_rec.sty_id <> OKC_API.G_MISS_NUM) THEN
      OPEN okl_strm_type_csr(p_tclv_rec.sty_id);
      FETCH okl_strm_type_csr INTO
               l_stream_type_code,
               l_stream_type_purpose;
      IF okl_strm_type_csr%NOTFOUND THEN
           OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_INVALID_VALUE',
                p_token1       => 'COL_NAME',
                p_token1_value => 'sty_id'
               );
      RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE okl_strm_type_csr;
      l_tclv_rec.stream_type_purpose := l_stream_type_purpose;
      l_tclv_rec.stream_type_code := l_stream_type_code;
    END IF;
  -- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007 end
    okl_tcl_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tclv_rec      => l_tclv_rec
                          ,x_tclv_rec      => x_tclv_rec
                          );
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_trx_cntrct_lines;

  PROCEDURE create_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_tbl                       IN  tclv_tbl_type
    ,x_tclv_tbl                       OUT NOCOPY tclv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;

  BEGIN

  OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        create_trx_cntrct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i),
          x_tclv_rec                     => x_tclv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_trx_cntrct_lines;

  PROCEDURE lock_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_rec                       IN  tclv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tcl_pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tclv_rec      => p_tclv_rec
                          );
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END lock_trx_cntrct_lines;

  PROCEDURE lock_trx_cntrct_lines(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_tclv_tbl                      IN  tclv_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                  NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        lock_trx_cntrct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);

      END LOOP;

    END IF;

    x_return_status := l_overall_status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_trx_cntrct_lines;

  PROCEDURE update_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_rec                       IN  tclv_rec_type
    ,x_tclv_rec                       OUT NOCOPY tclv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_tcl_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tclv_rec      => p_tclv_rec
                          ,x_tclv_rec      => x_tclv_rec
                          );
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_trx_cntrct_lines;

  PROCEDURE update_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_tbl                       IN  tclv_tbl_type
    ,x_tclv_tbl                       OUT NOCOPY tclv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        update_trx_cntrct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i),
          x_tclv_rec                     => x_tclv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;

    END IF;

    x_return_status := l_overall_status;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_trx_cntrct_lines;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_rec                       IN  tclv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tcl_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tclv_rec      => p_tclv_rec);
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_trx_cntrct_lines;

  PROCEDURE delete_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_tbl                       IN  tclv_tbl_type) IS

    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
  --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        delete_trx_cntrct_lines(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_tclv_rec      => p_tclv_tbl(i));

         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
               l_overall_status := x_return_status;
            END IF;
         END IF;

         EXIT WHEN (i = p_tclv_tbl.LAST);
         i := p_tclv_tbl.NEXT(i);
       END LOOP;

     END IF;

     x_return_status := l_overall_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_trx_cntrct_lines;

  PROCEDURE validate_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_rec                       IN  tclv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tcl_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tclv_rec      => p_tclv_rec
                            );
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_cntrct_lines;

  PROCEDURE validate_trx_cntrct_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tclv_tbl                       IN  tclv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tclv_tbl.COUNT > 0) THEN
      i := p_tclv_tbl.FIRST;
      LOOP
        validate_trx_cntrct_lines(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tclv_rec                     => p_tclv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);
      END LOOP;

       x_return_status := l_overall_status;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_trx_cntrct_lines;

END OKL_TRX_CONTRACTS_PVT;

/
