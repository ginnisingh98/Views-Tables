--------------------------------------------------------
--  DDL for Package Body OKL_AR_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AR_EXTENSION_PVT" AS
/* $Header: OKLCRXHB.pls 120.1 2007/08/06 13:49:26 prasjain noship $ */

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rxh_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_rxhv_rec, p_rxlv_tbl
  --                  ,x_rxhv_rec, x_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                     IN  rxhv_rec_type
    ,p_rxlv_tbl                     IN  rxlv_tbl_type
    ,x_rxhv_rec                     OUT NOCOPY rxhv_rec_type
    ,x_rxlv_tbl                     OUT NOCOPY rxlv_tbl_type
    )
  IS
    i                               NUMBER;
    l_rxhv_rec                      rxhv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_rxlv_tbl                      rxlv_tbl_type := p_rxlv_tbl;
  BEGIN
    -- Populate TRX EXTENSION
    create_rxh_extension(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_rxhv_rec      => p_rxhv_rec
     ,x_rxhv_rec      => x_rxhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS
    THEN
      -- populate the foreign key for the detail
      IF (l_rxlv_tbl.COUNT > 0)
      THEN
        i:= l_rxlv_tbl.FIRST;
        LOOP
          l_rxlv_tbl(i).header_extension_id := x_rxhv_rec.header_extension_id;
          EXIT WHEN(i = l_rxlv_tbl.LAST);
          i := l_rxlv_tbl.NEXT(i);
        END LOOP;
      END IF;
      -- populate the detail
      create_rxl_extension(
        p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_rxlv_tbl      => l_rxlv_tbl
        ,x_rxlv_tbl      => x_rxlv_tbl);
     END IF;
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION
      THEN
        NULL;
      WHEN OTHERS
      THEN
        OKC_API.SET_MESSAGE(
           p_app_name          => g_app_name
          ,p_msg_name          => g_unexpected_error
          ,p_token1            => g_sqlcode_token
          ,p_token1_value      => sqlcode
          ,p_token2            => g_sqlerrm_token
          ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rxh_extension
  -- Description     : wrapper api for creating Transaction Extension Header
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec, x_rxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                IN  rxhv_rec_type
    ,x_rxhv_rec                OUT NOCOPY rxhv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxh_pvt.insert_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxhv_rec      => p_rxhv_rec
      ,x_rxhv_rec      => x_rxhv_rec);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
    -- Custom code if any
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION
      THEN
        NULL;
      WHEN OTHERS
      THEN
        OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => sqlcode
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rxh_extension
  -- Description     : wrapper api for creating a table of records for
  --                   Transaction Extension Header
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_tbl, x_rxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxh_extension(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_rxhv_tbl                  IN  rxhv_tbl_type
    ,x_rxhv_tbl                  OUT NOCOPY rxhv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                            NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0)
    THEN
      i := p_rxhv_tbl.FIRST;
      LOOP
        create_rxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_rxhv_rec                     => p_rxhv_tbl(i)
          ,x_rxhv_rec                     => x_rxhv_tbl(i));
          -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
          THEN
            IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
            THEN
              l_overall_status := x_return_status;
            END IF;
          END IF;
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION
      THEN
        NULL;
      WHEN OTHERS
      THEN
        OKC_API.SET_MESSAGE(
           p_app_name          => g_app_name
          ,p_msg_name          => g_unexpected_error
          ,p_token1            => g_sqlcode_token
          ,p_token1_value      => sqlcode
          ,p_token2            => g_sqlerrm_token
          ,p_token2_value      => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_rxh_extension
  -- Description     : wrapper api for updating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec, p_rxlv_tbl,
  --                   ,x_rxhv_rec, x_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_rxh_extension(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rxhv_rec              IN  rxhv_rec_type,
    p_rxlv_tbl              IN  rxlv_tbl_type,
    x_rxhv_rec              OUT NOCOPY rxhv_rec_type,
    x_rxlv_tbl              OUT NOCOPY rxlv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_rxh_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxhv_rec      => p_rxhv_rec
      ,x_rxhv_rec      => x_rxhv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS)
    THEN
      -- Update the detail
      update_rxl_extension(
         p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_rxlv_tbl      => p_rxlv_tbl
        ,x_rxlv_tbl      => x_rxlv_tbl);
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_rxh_extension
  -- Description     : wrapper api for validating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec, p_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_rxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_rxhv_rec              IN  rxhv_rec_type
    ,p_rxlv_tbl              IN  rxlv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_rxh_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxhv_rec      => p_rxhv_rec);

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
    THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
       THEN
         l_overall_status := x_return_status;
       END IF;
    END IF;
    -- Validate the detail
    validate_rxl_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxlv_tbl      => p_rxlv_tbl);
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
    THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
       THEN
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

  END validate_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_rxh_extension
  -- Description     : wrapper api for locking a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec
  -- Version         : 1.0
  -- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_rxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_rxhv_rec              IN  rxhv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxh_pvt.lock_row(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_rxhv_rec      => p_rxhv_rec);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
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
  END lock_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_rxh_extension
  -- Description     : wrapper api for locking a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_rxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_rxhv_tbl              IN  rxhv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0)
    THEN
      i := p_rxhv_tbl.FIRST;
      LOOP
        lock_rxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_rxhv_rec                     => p_rxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_rxh_extension
  -- Description     : wrapper api for updating a Header record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec, x_rxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_rxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                   IN  rxhv_rec_type
    ,x_rxhv_rec                   OUT NOCOPY rxhv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxh_pvt.update_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxhv_rec      => p_rxhv_rec
      ,x_rxhv_rec      => x_rxhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
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
  END update_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_rxh_extension
  -- Description     : wrapper api for updating a table of Header records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_tbl, x_rxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_rxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_rxhv_tbl                   IN  rxhv_tbl_type
    ,x_rxhv_tbl                   OUT NOCOPY rxhv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0) THEN
      i := p_rxhv_tbl.FIRST;
      LOOP
        update_rxh_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rxhv_rec                     => p_rxhv_tbl(i),
          x_rxhv_rec                     => x_rxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_rxh_extension
  -- Description     : wrapper api for deleting a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_rxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_rxhv_rec              IN  rxhv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rxlv_tbl               rxlv_tbl_type;

    CURSOR rxl_csr IS
      SELECT rxl.line_extension_id
        FROM OKL_EXT_ar_LINE_SOURCES_B rxl
       WHERE rxl.header_extension_id = p_rxhv_rec.header_extension_id;
  BEGIN
    FOR rxl_rec IN rxl_csr
    LOOP
      i := i + 1;
      l_rxlv_tbl(i).line_extension_id := rxl_rec.line_extension_id;
    END LOOP;
    delete_rxl_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxlv_tbl      => l_rxlv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS
    THEN
      okl_rxh_pvt.delete_row(
         p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_rxhv_rec      => p_rxhv_rec);
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_rxh_extension
  -- Description     : wrapper api for deleting a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_rxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_rxhv_tbl              IN  rxhv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_rxhv_tbl.COUNT > 0)
    THEN
      i := p_rxhv_tbl.FIRST;
      LOOP
        delete_rxh_extension(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_rxhv_rec      => p_rxhv_tbl(i));
         IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
         THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
           THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;
         EXIT WHEN (i = p_rxhv_tbl.LAST);
         i := p_rxhv_tbl.NEXT(i);
       END LOOP;
      END IF;
      x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_rxh_extension
  -- Description     : wrapper api for validating a Header record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_rec
  -- Version         : 1.0
  -- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_rxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_rxhv_rec                   IN  rxhv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxh_pvt.validate_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxhv_rec      => p_rxhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_rxh_extension
  -- Description     : wrapper api for validating a table of Header records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_rxh_extension(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_rxhv_tbl                  IN  rxhv_tbl_type)
  IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                           NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxhv_tbl.COUNT > 0)
    THEN
      i := p_rxhv_tbl.FIRST;
      LOOP
        validate_rxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_rxhv_rec                     => p_rxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxhv_tbl.LAST);
        i := p_rxhv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rxl_extension
  -- Description     : wrapper api for creation of Transaction Extension Line
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_rec, x_rxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_rec                       IN  rxlv_rec_type
    ,x_rxlv_rec                       OUT NOCOPY rxlv_rec_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxl_pvt.insert_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxlv_rec      => p_rxlv_rec
      ,x_rxlv_rec      => x_rxlv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_rxl_extension
  -- Description     : wrapper api for creation of multiple records of
  --                   Transaction Extension Line
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_tbl, x_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_tbl                       IN  rxlv_tbl_type
    ,x_rxlv_tbl                       OUT NOCOPY rxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxlv_tbl.COUNT > 0)
    THEN
      i := p_rxlv_tbl.FIRST;
      LOOP
        create_rxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_rxlv_rec                     => p_rxlv_tbl(i)
          ,x_rxlv_rec                     => x_rxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxlv_tbl.LAST);
        i := p_rxlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END create_rxl_extension;
  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_rxl_extension
  -- Description     : wrapper api for locking a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_rec                       IN  rxlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxl_pvt.lock_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxlv_rec      => p_rxlv_rec );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_rxl_extension
  -- Description     : wrapper api for locking a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_rxl_extension(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_rxlv_tbl                      IN  rxlv_tbl_type)
  IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                  NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxlv_tbl.COUNT > 0)
    THEN
      i := p_rxlv_tbl.FIRST;
      LOOP
        lock_rxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_rxlv_rec                     => p_rxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxlv_tbl.LAST);
        i := p_rxlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END lock_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_rxl_extension
  -- Description     : wrapper api for updating a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_rec, x_rxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_rec                       IN  rxlv_rec_type
    ,x_rxlv_rec                       OUT NOCOPY rxlv_rec_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxl_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_rxlv_rec      => p_rxlv_rec
                          ,x_rxlv_rec      => x_rxlv_rec
                          );
      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_rxl_extension
  -- Description     : wrapper api for updating a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_tbl, x_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_tbl                       IN  rxlv_tbl_type
    ,x_rxlv_tbl                       OUT NOCOPY rxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxlv_tbl.COUNT > 0)
    THEN
      i := p_rxlv_tbl.FIRST;
      LOOP
        update_rxl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rxlv_rec                     => p_rxlv_tbl(i),
          x_rxlv_rec                     => x_rxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxlv_tbl.LAST);
        i := p_rxlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_rxl_extension
  -- Description     : wrapper api for deleting record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_rec                       IN  rxlv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxl_pvt.delete_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxlv_rec      => p_rxlv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_rxl_extension
  -- Description     : wrapper api for deleting a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_tbl                       IN  rxlv_tbl_type)
  IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_rxlv_tbl.COUNT > 0)
    THEN
      i := p_rxlv_tbl.FIRST;
      LOOP
        delete_rxl_extension(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_rxlv_rec      => p_rxlv_tbl(i));
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
       THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxlv_tbl.LAST);
        i := p_rxlv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_rxl_extension
  -- Description     : wrapper api for validating a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_rec                       IN  rxlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_rxl_pvt.validate_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_rxlv_rec      => p_rxlv_rec );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
      THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_rxl_extension
  -- Description     : wrapper api for validating a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_rxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxlv_tbl                       IN  rxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rxlv_tbl.COUNT > 0)
    THEN
      i := p_rxlv_tbl.FIRST;
      LOOP
        validate_rxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_rxlv_rec                     => p_rxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_rxlv_tbl.LAST);
        i := p_rxlv_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION
    THEN
      NULL;
    WHEN OTHERS
    THEN
      OKC_API.SET_MESSAGE(
         p_app_name          => g_app_name
        ,p_msg_name          => g_unexpected_error
        ,p_token1            => g_sqlcode_token
        ,p_token1_value      => sqlcode
        ,p_token2            => g_sqlerrm_token
        ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added for Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_rxh_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_rxh_rec, p_rxhl_tbl
  --                  ,x_rxh_rec, x_rxhl_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_rxh_rec                 IN  rxh_rec_type
    ,p_rxhl_tbl                IN  rxhl_tbl_type
    ,x_rxh_rec                 OUT NOCOPY rxh_rec_type
    ,x_rxhl_tbl                OUT NOCOPY rxhl_tbl_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  okl_rxh_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_rxh_rec       => p_rxh_rec
                          ,p_rxhl_tbl      => p_rxhl_tbl
                          ,x_rxh_rec       => x_rxh_rec
                          ,x_rxhl_tbl      => x_rxhl_tbl
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
  END create_rxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added for Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_rxl_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_rxl_rec, p_rxll_tbl
  --                  ,x_rxl_rec, x_rxll_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_rxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_rxl_rec                        IN  rxl_rec_type
    ,p_rxll_tbl                       IN  rxll_tbl_type
    ,x_rxl_rec                        OUT NOCOPY rxl_rec_type
    ,x_rxll_tbl                       OUT NOCOPY rxll_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
    okl_rxl_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_rxl_rec       => p_rxl_rec
                          ,p_rxll_tbl      => p_rxll_tbl
                          ,x_rxl_rec       => x_rxl_rec
                          ,x_rxll_tbl      => x_rxll_tbl
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
  END create_rxl_extension;
END OKL_AR_EXTENSION_PVT;

/
