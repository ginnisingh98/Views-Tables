--------------------------------------------------------
--  DDL for Package Body OKL_TRX_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRX_EXTENSION_PVT" AS
/*$Header: OKLCTEHB.pls 120.2 2007/08/06 13:50:26 prasjain noship $*/

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_trx_extension
-- Description     : wrapper api for creating Transaction Extension
-- Business Rules  :
-- Parameters      : p_api_version ,p_init_msg_list,x_return_status
--                   ,x_msg_count ,x_msg_data ,p_tehv_rec, p_telv_tbl
--                   ,x_tehv_rec, x_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_trx_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tehv_rec                     IN  tehv_rec_type
    ,p_telv_tbl                     IN  telv_tbl_type
    ,x_tehv_rec                     OUT NOCOPY tehv_rec_type
    ,x_telv_tbl                     OUT NOCOPY telv_tbl_type
    ) IS

    i                               NUMBER;
    l_tehv_rec                      tehv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_telv_tbl                      telv_tbl_type := p_telv_tbl;

  BEGIN
  -- Populate TRX EXTENSION
    create_trx_extension(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_tehv_rec      => p_tehv_rec
                        ,x_tehv_rec      => x_tehv_rec);

    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN

         -- populate the foreign key for the detail
           IF (l_telv_tbl.COUNT > 0) THEN
              i:= l_telv_tbl.FIRST;
              LOOP
                l_telv_tbl(i).teh_id := x_tehv_rec.header_extension_id;

                EXIT WHEN(i = l_telv_tbl.LAST);
                i := l_telv_tbl.NEXT(i);
              END LOOP;
           END IF;


           -- populate the detail
           create_txl_extension(
                                     p_api_version   => p_api_version
                                    ,p_init_msg_list => p_init_msg_list
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,p_telv_tbl      => l_telv_tbl
                                    ,x_telv_tbl      => x_telv_tbl);
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
  END create_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_trx_extension
-- Description     : wrapper api for creating Transaction Extension Header
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec, x_tehv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_trx_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_tehv_rec                IN  tehv_rec_type
    ,x_tehv_rec                OUT NOCOPY tehv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

  okl_teh_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tehv_rec      => p_tehv_rec
                          ,x_tehv_rec      => x_tehv_rec
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
        NULL;

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => sqlcode
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_trx_extension
-- Description     : wrapper api for creating a table of records for
--                   Transaction Extension Header
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_tbl, x_tehv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_trx_extension(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_tehv_tbl                  IN  tehv_tbl_type
    ,x_tehv_tbl                  OUT NOCOPY tehv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                            NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tehv_tbl.COUNT > 0) THEN
      i := p_tehv_tbl.FIRST;
      LOOP
        create_trx_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tehv_rec                     => p_tehv_tbl(i),
          x_tehv_rec                     => x_tehv_tbl(i));
        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tehv_tbl.LAST);
        i := p_tehv_tbl.NEXT(i);
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

  END create_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_trx_extension
-- Description     : wrapper api for updating Transaction Extension
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec, p_telv_tbl,
--                   ,x_tehv_rec, x_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_trx_extension(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tehv_rec              IN  tehv_rec_type,
    p_telv_tbl              IN  telv_tbl_type,
    x_tehv_rec              OUT NOCOPY tehv_rec_type,
    x_telv_tbl              OUT NOCOPY telv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_trx_extension(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_tehv_rec      => p_tehv_rec
                        ,x_tehv_rec      => x_tehv_rec
                        );

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    -- Update the detail
    update_txl_extension(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_telv_tbl      => p_telv_tbl
                             ,x_telv_tbl      => x_telv_tbl
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

  END update_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_trx_extension
-- Description     : wrapper api for validating Transaction Extension
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec, p_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_trx_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tehv_rec              IN  tehv_rec_type
    ,p_telv_tbl              IN  telv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- Validate the master
    validate_trx_extension(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tehv_rec      => p_tehv_rec
                          );

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
       END IF;
    END IF;

    -- Validate the detail
    validate_txl_extension(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_telv_tbl      => p_telv_tbl
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

  END validate_trx_extension;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : lock_trx_extension
-- Description     : wrapper api for locking a record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_trx_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tehv_rec              IN  tehv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_teh_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_tehv_rec      => p_tehv_rec
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
  END lock_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : lock_trx_extension
-- Description     : wrapper api for locking a table of records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_trx_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tehv_tbl              IN  tehv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tehv_tbl.COUNT > 0) THEN
      i := p_tehv_tbl.FIRST;
      LOOP
        lock_trx_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tehv_rec                     => p_tehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tehv_tbl.LAST);
        i := p_tehv_tbl.NEXT(i);
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
  END lock_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_trx_extension
-- Description     : wrapper api for updating a Header record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec, x_tehv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_trx_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_tehv_rec                   IN  tehv_rec_type
    ,x_tehv_rec                   OUT NOCOPY tehv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_teh_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tehv_rec      => p_tehv_rec
                          ,x_tehv_rec      => x_tehv_rec
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
  END update_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_trx_extension
-- Description     : wrapper api for updating a table of Header records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_tbl, x_tehv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_trx_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_tehv_tbl                   IN  tehv_tbl_type
    ,x_tehv_tbl                   OUT NOCOPY tehv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;

  BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tehv_tbl.COUNT > 0) THEN
      i := p_tehv_tbl.FIRST;
      LOOP
        update_trx_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tehv_rec                     => p_tehv_tbl(i),
          x_tehv_rec                     => x_tehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tehv_tbl.LAST);
        i := p_tehv_tbl.NEXT(i);
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
  END update_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_trx_extension
-- Description     : wrapper api for deleting a record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE delete_trx_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tehv_rec              IN  tehv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_telv_tbl               telv_tbl_type;

    CURSOR tel_csr IS
      SELECT tel.line_extension_id
        FROM OKL_TXL_EXTENSION_B tel
       WHERE tel.teh_id = p_tehv_rec.header_extension_id;
  BEGIN
    FOR tel_rec IN tel_csr
    LOOP
      i := i + 1;
      l_telv_tbl(i).line_extension_id := tel_rec.line_extension_id;
    END LOOP;

    delete_txl_extension(     p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_telv_tbl      => l_telv_tbl);


    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      okl_teh_pvt.delete_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tehv_rec      => p_tehv_rec);

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
  END delete_trx_extension;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_trx_extension
-- Description     : wrapper api for deleting a table of records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE delete_trx_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_tehv_tbl              IN  tehv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tehv_tbl.COUNT > 0) THEN
      i := p_tehv_tbl.FIRST;
      LOOP
        delete_trx_extension(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tehv_rec      => p_tehv_tbl(i)
                            );

         IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
         END IF;

         EXIT WHEN (i = p_tehv_tbl.LAST);
         i := p_tehv_tbl.NEXT(i);
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
  END delete_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_trx_extension
-- Description     : wrapper api for validating a Header record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_trx_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_tehv_rec                   IN  tehv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_teh_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_tehv_rec      => p_tehv_rec
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
  END validate_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_trx_extension
-- Description     : wrapper api for validating a table of Header records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_tehv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_trx_extension(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_tehv_tbl                  IN  tehv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
      i                           NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tehv_tbl.COUNT > 0) THEN
      i := p_tehv_tbl.FIRST;
      LOOP
        validate_trx_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tehv_rec                     => p_tehv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tehv_tbl.LAST);
        i := p_tehv_tbl.NEXT(i);
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
  END validate_trx_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_txl_extension
-- Description     : wrapper api for creation of Transaction Extension Line
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_rec, x_telv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_rec                       IN  telv_rec_type
    ,x_telv_rec                       OUT NOCOPY telv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
    okl_tel_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_telv_rec      => p_telv_rec
                          ,x_telv_rec      => x_telv_rec
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
  END create_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_txl_extension
-- Description     : wrapper api for creation of multiple records of
--                   Transaction Extension Line
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_tbl, x_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE create_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_tbl                       IN  telv_tbl_type
    ,x_telv_tbl                       OUT NOCOPY telv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;

  BEGIN

  OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
      LOOP
        create_txl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_telv_rec                     => p_telv_tbl(i),
          x_telv_rec                     => x_telv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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
  END create_txl_extension;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : lock_txl_extension
-- Description     : wrapper api for locking a record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_rec                       IN  telv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tel_pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_telv_rec      => p_telv_rec
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

  END lock_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : lock_txl_extension
-- Description     : wrapper api for locking a table of records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_txl_extension(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_telv_tbl                      IN  telv_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                  NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
      LOOP
        lock_txl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_telv_rec                     => p_telv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);

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
  END lock_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_txl_extension
-- Description     : wrapper api for updating a record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_rec, x_telv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_rec                       IN  telv_rec_type
    ,x_telv_rec                       OUT NOCOPY telv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_tel_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_telv_rec      => p_telv_rec
                          ,x_telv_rec      => x_telv_rec
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
  END update_txl_extension;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_txl_extension
-- Description     : wrapper api for updating a table of records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_tbl, x_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE update_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_tbl                       IN  telv_tbl_type
    ,x_telv_tbl                       OUT NOCOPY telv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
      LOOP
        update_txl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_telv_rec                     => p_telv_tbl(i),
          x_telv_rec                     => x_telv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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
  END update_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_txl_extension
-- Description     : wrapper api for deleting record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE delete_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_rec                       IN  telv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tel_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_telv_rec      => p_telv_rec);
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
  END delete_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_txl_extension
-- Description     : wrapper api for deleting a table of records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE delete_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_tbl                       IN  telv_tbl_type) IS

    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
  --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
      LOOP
        delete_txl_extension(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_telv_rec      => p_telv_tbl(i));

         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
               l_overall_status := x_return_status;
            END IF;
         END IF;

         EXIT WHEN (i = p_telv_tbl.LAST);
         i := p_telv_tbl.NEXT(i);
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
  END delete_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_txl_extension
-- Description     : wrapper api for validating a record
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_rec
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_rec                       IN  telv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_tel_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_telv_rec      => p_telv_rec
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
  END validate_txl_extension;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : validate_txl_extension
-- Description     : wrapper api for validating a table of records
-- Business Rules  :
-- Parameters      : p_api_version, p_init_msg_list, x_return_status
--                   ,x_msg_count, x_msg_data, p_telv_tbl
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_telv_tbl                       IN  telv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_telv_tbl.COUNT > 0) THEN
      i := p_telv_tbl.FIRST;
      LOOP
        validate_txl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_telv_rec                     => p_telv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_telv_tbl.LAST);
        i := p_telv_tbl.NEXT(i);
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
  END validate_txl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added : PRASJAIN : Bug# 6268782
  --
  -- Procedure Name  : create_trx_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                   ,x_msg_count ,x_msg_data ,p_teh_rec, p_tehl_tbl
  --                   ,x_teh_rec, x_tehl_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_trx_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_teh_rec                 IN  teh_rec_type
    ,p_tehl_tbl                IN  tehl_tbl_type
    ,x_teh_rec                 OUT NOCOPY teh_rec_type
    ,x_tehl_tbl                OUT NOCOPY tehl_tbl_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  okl_teh_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_teh_rec       => p_teh_rec
                          ,p_tehl_tbl      => p_tehl_tbl
                          ,x_teh_rec       => x_teh_rec
                          ,x_tehl_tbl      => x_tehl_tbl
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
        NULL;

      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => sqlcode
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_trx_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added : PRASJAIN : Bug# 6268782
  --
  -- Procedure Name  : create_txl_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                   ,x_msg_count ,x_msg_data ,p_tel_rec, p_tell_tbl
  --                   ,x_tel_rec, x_tell_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tel_rec                        IN  tel_rec_type
    ,p_tell_tbl                       IN  tell_tbl_type
    ,x_tel_rec                        OUT NOCOPY tel_rec_type
    ,x_tell_tbl                       OUT NOCOPY tell_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
    okl_tel_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_tel_rec       => p_tel_rec
                          ,p_tell_tbl      => p_tell_tbl
                          ,x_tel_rec       => x_tel_rec
                          ,x_tell_tbl      => x_tell_tbl
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
  END create_txl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added : PRASJAIN : Bug# 6268782
  --
  -- Procedure Name  : create_txl_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                   ,x_msg_count ,x_msg_data ,p_tel_rec, p_tell_tbl
  --                   ,x_tel_rec, x_tell_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_txl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_tel_tbl_tbl                    IN  tel_tbl_tbl_type
    ,x_tel_tbl_tbl                    OUT NOCOPY tel_tbl_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;
  BEGIN

  OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tel_tbl_tbl.COUNT > 0) THEN
      i := p_tel_tbl_tbl.FIRST;
      LOOP
        create_txl_extension(
              p_api_version                    => p_api_version
             ,p_init_msg_list                  => OKC_API.G_FALSE
             ,x_return_status                  => x_return_status
             ,x_msg_count                      => x_msg_count
             ,x_msg_data                       => x_msg_data
             ,p_tel_rec                        => p_tel_tbl_tbl(i).tel_rec
             ,p_tell_tbl                       => p_tel_tbl_tbl(i).tell_tbl
             ,x_tel_rec                        => x_tel_tbl_tbl(i).tel_rec
             ,x_tell_tbl                       => x_tel_tbl_tbl(i).tell_tbl);

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_tel_tbl_tbl.LAST);
        i := p_tel_tbl_tbl.NEXT(i);
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
  END create_txl_extension;
END OKL_TRX_EXTENSION_PVT;

/
