--------------------------------------------------------
--  DDL for Package Body OKL_FA_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FA_EXTENSION_PVT" AS
/* $Header: OKLCFXHB.pls 120.1 2007/08/06 13:47:23 prasjain noship $ */

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_fxh_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_fxhv_rec, p_fxlv_tbl
  --                  ,x_fxhv_rec, x_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                     IN  fxhv_rec_type
    ,p_fxlv_tbl                     IN  fxlv_tbl_type
    ,x_fxhv_rec                     OUT NOCOPY fxhv_rec_type
    ,x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type
    )
  IS
    i                               NUMBER;
    l_fxhv_rec                      fxhv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_fxlv_tbl                      fxlv_tbl_type := p_fxlv_tbl;
  BEGIN
    -- Populate TRX EXTENSION
    create_fxh_extension(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_fxhv_rec      => p_fxhv_rec
     ,x_fxhv_rec      => x_fxhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS
    THEN
      -- populate the foreign key for the detail
      IF (l_fxlv_tbl.COUNT > 0)
      THEN
        i:= l_fxlv_tbl.FIRST;
        LOOP
          l_fxlv_tbl(i).header_extension_id := x_fxhv_rec.header_extension_id;
          EXIT WHEN(i = l_fxlv_tbl.LAST);
          i := l_fxlv_tbl.NEXT(i);
        END LOOP;
      END IF;
      -- populate the detail
      create_fxl_extension(
        p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_fxlv_tbl      => l_fxlv_tbl
        ,x_fxlv_tbl      => x_fxlv_tbl);
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
  END create_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_fxh_extension
  -- Description     : wrapper api for creating Transaction Extension Header
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec, x_fxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                IN  fxhv_rec_type
    ,x_fxhv_rec                OUT NOCOPY fxhv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxh_pvt.insert_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxhv_rec      => p_fxhv_rec
      ,x_fxhv_rec      => x_fxhv_rec);

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
  END create_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_fxh_extension
  -- Description     : wrapper api for creating a table of records for
  --                   Transaction Extension Header
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_tbl, x_fxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxh_extension(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_fxhv_tbl                  IN  fxhv_tbl_type
    ,x_fxhv_tbl                  OUT NOCOPY fxhv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                            NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxhv_tbl.COUNT > 0)
    THEN
      i := p_fxhv_tbl.FIRST;
      LOOP
        create_fxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_fxhv_rec                     => p_fxhv_tbl(i)
          ,x_fxhv_rec                     => x_fxhv_tbl(i));
          -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
          THEN
            IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
            THEN
              l_overall_status := x_return_status;
            END IF;
          END IF;
        EXIT WHEN (i = p_fxhv_tbl.LAST);
        i := p_fxhv_tbl.NEXT(i);
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
  END create_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_fxh_extension
  -- Description     : wrapper api for updating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec, p_fxlv_tbl,
  --                   ,x_fxhv_rec, x_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_fxh_extension(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_fxhv_rec              IN  fxhv_rec_type,
    p_fxlv_tbl              IN  fxlv_tbl_type,
    x_fxhv_rec              OUT NOCOPY fxhv_rec_type,
    x_fxlv_tbl              OUT NOCOPY fxlv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_fxh_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxhv_rec      => p_fxhv_rec
      ,x_fxhv_rec      => x_fxhv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS)
    THEN
      -- Update the detail
      update_fxl_extension(
         p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_fxlv_tbl      => p_fxlv_tbl
        ,x_fxlv_tbl      => x_fxlv_tbl);
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
  END update_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_fxh_extension
  -- Description     : wrapper api for validating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec, p_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_fxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_fxhv_rec              IN  fxhv_rec_type
    ,p_fxlv_tbl              IN  fxlv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_fxh_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxhv_rec      => p_fxhv_rec);

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
    THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
       THEN
         l_overall_status := x_return_status;
       END IF;
    END IF;
    -- Validate the detail
    validate_fxl_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxlv_tbl      => p_fxlv_tbl);
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

  END validate_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_fxh_extension
  -- Description     : wrapper api for locking a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec
  -- Version         : 1.0
  -- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_fxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_fxhv_rec              IN  fxhv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxh_pvt.lock_row(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_fxhv_rec      => p_fxhv_rec);

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
  END lock_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_fxh_extension
  -- Description     : wrapper api for locking a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_fxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_fxhv_tbl              IN  fxhv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxhv_tbl.COUNT > 0)
    THEN
      i := p_fxhv_tbl.FIRST;
      LOOP
        lock_fxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_fxhv_rec                     => p_fxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;
        EXIT WHEN (i = p_fxhv_tbl.LAST);
        i := p_fxhv_tbl.NEXT(i);
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
  END lock_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_fxh_extension
  -- Description     : wrapper api for updating a Header record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec, x_fxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_fxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                   IN  fxhv_rec_type
    ,x_fxhv_rec                   OUT NOCOPY fxhv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxh_pvt.update_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxhv_rec      => p_fxhv_rec
      ,x_fxhv_rec      => x_fxhv_rec);
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
  END update_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_fxh_extension
  -- Description     : wrapper api for updating a table of Header records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_tbl, x_fxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_fxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_fxhv_tbl                   IN  fxhv_tbl_type
    ,x_fxhv_tbl                   OUT NOCOPY fxhv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxhv_tbl.COUNT > 0) THEN
      i := p_fxhv_tbl.FIRST;
      LOOP
        update_fxh_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fxhv_rec                     => p_fxhv_tbl(i),
          x_fxhv_rec                     => x_fxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxhv_tbl.LAST);
        i := p_fxhv_tbl.NEXT(i);
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
  END update_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_fxh_extension
  -- Description     : wrapper api for deleting a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_fxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_fxhv_rec              IN  fxhv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fxlv_tbl               fxlv_tbl_type;

    CURSOR fxl_csr IS
      SELECT fxl.line_extension_id
        FROM OKL_EXT_FA_LINE_SOURCES_B fxl
       WHERE fxl.header_extension_id = p_fxhv_rec.header_extension_id;
  BEGIN
    FOR fxl_rec IN fxl_csr
    LOOP
      i := i + 1;
      l_fxlv_tbl(i).line_extension_id := fxl_rec.line_extension_id;
    END LOOP;
    delete_fxl_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxlv_tbl      => l_fxlv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS
    THEN
      okl_fxh_pvt.delete_row(
         p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_fxhv_rec      => p_fxhv_rec);
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
  END delete_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_fxh_extension
  -- Description     : wrapper api for deleting a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_fxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_fxhv_tbl              IN  fxhv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_fxhv_tbl.COUNT > 0)
    THEN
      i := p_fxhv_tbl.FIRST;
      LOOP
        delete_fxh_extension(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_fxhv_rec      => p_fxhv_tbl(i));
         IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
         THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
           THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;
         EXIT WHEN (i = p_fxhv_tbl.LAST);
         i := p_fxhv_tbl.NEXT(i);
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
  END delete_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_fxh_extension
  -- Description     : wrapper api for validating a Header record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_rec
  -- Version         : 1.0
  -- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_fxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_fxhv_rec                   IN  fxhv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxh_pvt.validate_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxhv_rec      => p_fxhv_rec);
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
  END validate_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_fxh_extension
  -- Description     : wrapper api for validating a table of Header records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_fxh_extension(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_fxhv_tbl                  IN  fxhv_tbl_type)
  IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                           NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxhv_tbl.COUNT > 0)
    THEN
      i := p_fxhv_tbl.FIRST;
      LOOP
        validate_fxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_fxhv_rec                     => p_fxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxhv_tbl.LAST);
        i := p_fxhv_tbl.NEXT(i);
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
  END validate_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_fxl_extension
  -- Description     : wrapper api for creation of Transaction Extension Line
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_rec, x_fxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_rec                       IN  fxlv_rec_type
    ,x_fxlv_rec                       OUT NOCOPY fxlv_rec_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxl_pvt.insert_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxlv_rec      => p_fxlv_rec
      ,x_fxlv_rec      => x_fxlv_rec);
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
  END create_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_fxl_extension
  -- Description     : wrapper api for creation of multiple records of
  --                   Transaction Extension Line
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_tbl, x_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_tbl                       IN  fxlv_tbl_type
    ,x_fxlv_tbl                       OUT NOCOPY fxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0)
    THEN
      i := p_fxlv_tbl.FIRST;
      LOOP
        create_fxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_fxlv_rec                     => p_fxlv_tbl(i)
          ,x_fxlv_rec                     => x_fxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  END create_fxl_extension;
  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_fxl_extension
  -- Description     : wrapper api for locking a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_rec                       IN  fxlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxl_pvt.lock_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxlv_rec      => p_fxlv_rec );
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
  END lock_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_fxl_extension
  -- Description     : wrapper api for locking a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_fxl_extension(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_fxlv_tbl                      IN  fxlv_tbl_type)
  IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                  NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0)
    THEN
      i := p_fxlv_tbl.FIRST;
      LOOP
        lock_fxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_fxlv_rec                     => p_fxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  END lock_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_fxl_extension
  -- Description     : wrapper api for updating a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_rec, x_fxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_rec                       IN  fxlv_rec_type
    ,x_fxlv_rec                       OUT NOCOPY fxlv_rec_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxl_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_fxlv_rec      => p_fxlv_rec
                          ,x_fxlv_rec      => x_fxlv_rec
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
  END update_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_fxl_extension
  -- Description     : wrapper api for updating a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_tbl, x_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_tbl                       IN  fxlv_tbl_type
    ,x_fxlv_tbl                       OUT NOCOPY fxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0)
    THEN
      i := p_fxlv_tbl.FIRST;
      LOOP
        update_fxl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fxlv_rec                     => p_fxlv_tbl(i),
          x_fxlv_rec                     => x_fxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  END update_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_fxl_extension
  -- Description     : wrapper api for deleting record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_rec                       IN  fxlv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxl_pvt.delete_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxlv_rec      => p_fxlv_rec);
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
  END delete_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_fxl_extension
  -- Description     : wrapper api for deleting a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_tbl                       IN  fxlv_tbl_type)
  IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_fxlv_tbl.COUNT > 0)
    THEN
      i := p_fxlv_tbl.FIRST;
      LOOP
        delete_fxl_extension(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_fxlv_rec      => p_fxlv_tbl(i));
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
       THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  END delete_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_fxl_extension
  -- Description     : wrapper api for validating a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_rec                       IN  fxlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_fxl_pvt.validate_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_fxlv_rec      => p_fxlv_rec );
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
  END validate_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_fxl_extension
  -- Description     : wrapper api for validating a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_fxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxlv_tbl                       IN  fxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0)
    THEN
      i := p_fxlv_tbl.FIRST;
      LOOP
        validate_fxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_fxlv_rec                     => p_fxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  END validate_fxl_extension;
  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added : Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_fxh_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_fxh_rec, p_fxhl_tbl
  --                  ,x_fxh_rec, x_fxhl_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_fxh_rec                 IN  fxh_rec_type
    ,p_fxhl_tbl                IN  fxhl_tbl_type
    ,x_fxh_rec                 OUT NOCOPY fxh_rec_type
    ,x_fxhl_tbl                OUT NOCOPY fxhl_tbl_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  okl_fxh_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_fxh_rec       => p_fxh_rec
                          ,p_fxhl_tbl      => p_fxhl_tbl
                          ,x_fxh_rec       => x_fxh_rec
                          ,x_fxhl_tbl      => x_fxhl_tbl
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
  END create_fxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added : Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_fxl_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_fxl_rec, p_fxll_tbl
  --                  ,x_fxl_rec, x_fxll_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxl_rec                        IN  fxl_rec_type
    ,p_fxll_tbl                       IN  fxll_tbl_type
    ,x_fxl_rec                        OUT NOCOPY fxl_rec_type
    ,x_fxll_tbl                       OUT NOCOPY fxll_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
    okl_fxl_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_fxl_rec       => p_fxl_rec
                          ,p_fxll_tbl      => p_fxll_tbl
                          ,x_fxl_rec       => x_fxl_rec
                          ,x_fxll_tbl      => x_fxll_tbl
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
  END create_fxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added : Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_fxl_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_fxl_tbl_tbl, x_fxl_tbl_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_fxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_fxl_tbl_tbl                    IN  fxl_tbl_tbl_type
    ,x_fxl_tbl_tbl                    OUT NOCOPY fxl_tbl_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;
  BEGIN

  OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxl_tbl_tbl.COUNT > 0) THEN
      i := p_fxl_tbl_tbl.FIRST;
      LOOP
        create_fxl_extension(
              p_api_version                    => p_api_version
             ,p_init_msg_list                  => OKC_API.G_FALSE
             ,x_return_status                  => x_return_status
             ,x_msg_count                      => x_msg_count
             ,x_msg_data                       => x_msg_data
             ,p_fxl_rec                        => p_fxl_tbl_tbl(i).fxl_rec
             ,p_fxll_tbl                       => p_fxl_tbl_tbl(i).fxll_tbl
             ,x_fxl_rec                        => x_fxl_tbl_tbl(i).fxl_rec
             ,x_fxll_tbl                       => x_fxl_tbl_tbl(i).fxll_tbl);

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_fxl_tbl_tbl.LAST);
        i := p_fxl_tbl_tbl.NEXT(i);
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
  END create_fxl_extension;
END OKL_FA_EXTENSION_PVT;

/
