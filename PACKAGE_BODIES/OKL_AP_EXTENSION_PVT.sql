--------------------------------------------------------
--  DDL for Package Body OKL_AP_EXTENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AP_EXTENSION_PVT" AS
/* $Header: OKLCPXHB.pls 120.1 2007/08/06 13:48:18 prasjain noship $ */
  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pxh_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_pxhv_rec, p_pxlv_tbl
  --                  ,x_pxhv_rec, x_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxh_extension(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                     IN  pxhv_rec_type
    ,p_pxlv_tbl                     IN  pxlv_tbl_type
    ,x_pxhv_rec                     OUT NOCOPY pxhv_rec_type
    ,x_pxlv_tbl                     OUT NOCOPY pxlv_tbl_type
    )
  IS
    i                               NUMBER;
    l_pxhv_rec                      pxhv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_pxlv_tbl                      pxlv_tbl_type := p_pxlv_tbl;
  BEGIN
    -- Populate Tpx EXTENSION
    create_pxh_extension(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_pxhv_rec      => p_pxhv_rec
     ,x_pxhv_rec      => x_pxhv_rec);
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS
    THEN
      -- populate the foreign key for the detail
      IF (l_pxlv_tbl.COUNT > 0)
      THEN
        i:= l_pxlv_tbl.FIRST;
        LOOP
          l_pxlv_tbl(i).header_extension_id := x_pxhv_rec.header_extension_id;
          EXIT WHEN(i = l_pxlv_tbl.LAST);
          i := l_pxlv_tbl.NEXT(i);
        END LOOP;
      END IF;
      -- populate the detail
      create_pxl_extension(
        p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_pxlv_tbl      => l_pxlv_tbl
        ,x_pxlv_tbl      => x_pxlv_tbl);
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
  END create_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pxh_extension
  -- Description     : wrapper api for creating Transaction Extension Header
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec, x_pxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                IN  pxhv_rec_type
    ,x_pxhv_rec                OUT NOCOPY pxhv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxh_pvt.insert_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxhv_rec      => p_pxhv_rec
      ,x_pxhv_rec      => x_pxhv_rec);

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
  END create_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pxh_extension
  -- Description     : wrapper api for creating a table of records for
  --                   Transaction Extension Header
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_tbl, x_pxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxh_extension(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_pxhv_tbl                  IN  pxhv_tbl_type
    ,x_pxhv_tbl                  OUT NOCOPY pxhv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                            NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxhv_tbl.COUNT > 0)
    THEN
      i := p_pxhv_tbl.FIRST;
      LOOP
        create_pxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_pxhv_rec                     => p_pxhv_tbl(i)
          ,x_pxhv_rec                     => x_pxhv_tbl(i));
          -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
          THEN
            IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
            THEN
              l_overall_status := x_return_status;
            END IF;
          END IF;
        EXIT WHEN (i = p_pxhv_tbl.LAST);
        i := p_pxhv_tbl.NEXT(i);
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
  END create_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_pxh_extension
  -- Description     : wrapper api for updating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec, p_pxlv_tbl,
  --                   ,x_pxhv_rec, x_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_pxh_extension(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pxhv_rec              IN  pxhv_rec_type,
    p_pxlv_tbl              IN  pxlv_tbl_type,
    x_pxhv_rec              OUT NOCOPY pxhv_rec_type,
    x_pxlv_tbl              OUT NOCOPY pxlv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_pxh_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxhv_rec      => p_pxhv_rec
      ,x_pxhv_rec      => x_pxhv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS)
    THEN
      -- Update the detail
      update_pxl_extension(
         p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_pxlv_tbl      => p_pxlv_tbl
        ,x_pxlv_tbl      => x_pxlv_tbl);
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
  END update_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_pxh_extension
  -- Description     : wrapper api for validating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec, p_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_pxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pxhv_rec              IN  pxhv_rec_type
    ,p_pxlv_tbl              IN  pxlv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_pxh_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxhv_rec      => p_pxhv_rec);

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
    THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
       THEN
         l_overall_status := x_return_status;
       END IF;
    END IF;
    -- Validate the detail
    validate_pxl_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxlv_tbl      => p_pxlv_tbl);
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

  END validate_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_pxh_extension
  -- Description     : wrapper api for locking a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec
  -- Version         : 1.0
  -- End of comments
----------------------------------------------------------------------------------
  PROCEDURE lock_pxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pxhv_rec              IN  pxhv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxh_pvt.lock_row(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_pxhv_rec      => p_pxhv_rec);

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
  END lock_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_pxh_extension
  -- Description     : wrapper api for locking a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_pxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pxhv_tbl              IN  pxhv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxhv_tbl.COUNT > 0)
    THEN
      i := p_pxhv_tbl.FIRST;
      LOOP
        lock_pxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_pxhv_rec                     => p_pxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;
        EXIT WHEN (i = p_pxhv_tbl.LAST);
        i := p_pxhv_tbl.NEXT(i);
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
  END lock_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_pxh_extension
  -- Description     : wrapper api for updating a Header record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec, x_pxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_pxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                   IN  pxhv_rec_type
    ,x_pxhv_rec                   OUT NOCOPY pxhv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxh_pvt.update_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxhv_rec      => p_pxhv_rec
      ,x_pxhv_rec      => x_pxhv_rec);
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
  END update_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_pxh_extension
  -- Description     : wrapper api for updating a table of Header records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_tbl, x_pxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_pxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_pxhv_tbl                   IN  pxhv_tbl_type
    ,x_pxhv_tbl                   OUT NOCOPY pxhv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxhv_tbl.COUNT > 0) THEN
      i := p_pxhv_tbl.FIRST;
      LOOP
        update_pxh_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pxhv_rec                     => p_pxhv_tbl(i),
          x_pxhv_rec                     => x_pxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxhv_tbl.LAST);
        i := p_pxhv_tbl.NEXT(i);
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
  END update_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_pxh_extension
  -- Description     : wrapper api for deleting a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_pxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pxhv_rec              IN  pxhv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pxlv_tbl               pxlv_tbl_type;

    CURSOR pxl_csr IS
      SELECT pxl.line_extension_id
        FROM OKL_EXT_ap_LINE_SOURCES_B pxl
       WHERE pxl.header_extension_id = p_pxhv_rec.header_extension_id;
  BEGIN
    FOR pxl_rec IN pxl_csr
    LOOP
      i := i + 1;
      l_pxlv_tbl(i).line_extension_id := pxl_rec.line_extension_id;
    END LOOP;
    delete_pxl_extension(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxlv_tbl      => l_pxlv_tbl);
    IF x_return_status = OKC_API.G_RET_STS_SUCCESS
    THEN
      okl_pxh_pvt.delete_row(
         p_api_version   => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data
        ,p_pxhv_rec      => p_pxhv_rec);
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
  END delete_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_pxh_extension
  -- Description     : wrapper api for deleting a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_pxh_extension(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pxhv_tbl              IN  pxhv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_pxhv_tbl.COUNT > 0)
    THEN
      i := p_pxhv_tbl.FIRST;
      LOOP
        delete_pxh_extension(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_pxhv_rec      => p_pxhv_tbl(i));
         IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
         THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
           THEN
             l_overall_status := x_return_status;
           END IF;
         END IF;
         EXIT WHEN (i = p_pxhv_tbl.LAST);
         i := p_pxhv_tbl.NEXT(i);
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
  END delete_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_pxh_extension
  -- Description     : wrapper api for validating a Header record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_rec
  -- Version         : 1.0
  -- End of comments
----------------------------------------------------------------------------------
  PROCEDURE validate_pxh_extension(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_pxhv_rec                   IN  pxhv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxh_pvt.validate_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxhv_rec      => p_pxhv_rec);
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
  END validate_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_pxh_extension
  -- Description     : wrapper api for validating a table of Header records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxhv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_pxh_extension(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_pxhv_tbl                  IN  pxhv_tbl_type)
  IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                           NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxhv_tbl.COUNT > 0)
    THEN
      i := p_pxhv_tbl.FIRST;
      LOOP
        validate_pxh_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => Okc_Api.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_pxhv_rec                     => p_pxhv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxhv_tbl.LAST);
        i := p_pxhv_tbl.NEXT(i);
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
  END validate_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pxl_extension
  -- Description     : wrapper api for creation of Transaction Extension Line
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_rec, x_pxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_rec                       IN  pxlv_rec_type
    ,x_pxlv_rec                       OUT NOCOPY pxlv_rec_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxl_pvt.insert_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxlv_rec      => p_pxlv_rec
      ,x_pxlv_rec      => x_pxlv_rec);
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
  END create_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pxl_extension
  -- Description     : wrapper api for creation of multiple records of
  --                   Transaction Extension Line
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_tbl, x_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_tbl                       IN  pxlv_tbl_type
    ,x_pxlv_tbl                       OUT NOCOPY pxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxlv_tbl.COUNT > 0)
    THEN
      i := p_pxlv_tbl.FIRST;
      LOOP
        create_pxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_pxlv_rec                     => p_pxlv_tbl(i)
          ,x_pxlv_rec                     => x_pxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxlv_tbl.LAST);
        i := p_pxlv_tbl.NEXT(i);
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
  END create_pxl_extension;
  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_pxl_extension
  -- Description     : wrapper api for locking a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_rec                       IN  pxlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxl_pvt.lock_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxlv_rec      => p_pxlv_rec );
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
  END lock_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : lock_pxl_extension
  -- Description     : wrapper api for locking a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE lock_pxl_extension(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_pxlv_tbl                      IN  pxlv_tbl_type)
  IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                  NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxlv_tbl.COUNT > 0)
    THEN
      i := p_pxlv_tbl.FIRST;
      LOOP
        lock_pxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_pxlv_rec                     => p_pxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxlv_tbl.LAST);
        i := p_pxlv_tbl.NEXT(i);
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
  END lock_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_pxl_extension
  -- Description     : wrapper api for updating a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_rec, x_pxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_rec                       IN  pxlv_rec_type
    ,x_pxlv_rec                       OUT NOCOPY pxlv_rec_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxl_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pxlv_rec      => p_pxlv_rec
                          ,x_pxlv_rec      => x_pxlv_rec
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
  END update_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_pxl_extension
  -- Description     : wrapper api for updating a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_tbl, x_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE update_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_tbl                       IN  pxlv_tbl_type
    ,x_pxlv_tbl                       OUT NOCOPY pxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxlv_tbl.COUNT > 0)
    THEN
      i := p_pxlv_tbl.FIRST;
      LOOP
        update_pxl_extension(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pxlv_rec                     => p_pxlv_tbl(i),
          x_pxlv_rec                     => x_pxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxlv_tbl.LAST);
        i := p_pxlv_tbl.NEXT(i);
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
  END update_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_pxl_extension
  -- Description     : wrapper api for deleting record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_rec                       IN  pxlv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxl_pvt.delete_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxlv_rec      => p_pxlv_rec);
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
  END delete_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_pxl_extension
  -- Description     : wrapper api for deleting a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE delete_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_tbl                       IN  pxlv_tbl_type)
  IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_pxlv_tbl.COUNT > 0)
    THEN
      i := p_pxlv_tbl.FIRST;
      LOOP
        delete_pxl_extension(
           p_api_version   => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,p_pxlv_rec      => p_pxlv_tbl(i));
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
       THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxlv_tbl.LAST);
        i := p_pxlv_tbl.NEXT(i);
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
  END delete_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_pxl_extension
  -- Description     : wrapper api for validating a record
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_rec
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_rec                       IN  pxlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pxl_pvt.validate_row(
       p_api_version   => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,x_return_status => x_return_status
      ,x_msg_count     => x_msg_count
      ,x_msg_data      => x_msg_data
      ,p_pxlv_rec      => p_pxlv_rec );
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
  END validate_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_pxl_extension
  -- Description     : wrapper api for validating a table of records
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status
  --                   ,x_msg_count, x_msg_data, p_pxlv_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE validate_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxlv_tbl                       IN  pxlv_tbl_type)
  IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pxlv_tbl.COUNT > 0)
    THEN
      i := p_pxlv_tbl.FIRST;
      LOOP
        validate_pxl_extension(
           p_api_version                  => p_api_version
          ,p_init_msg_list                => OKC_API.G_FALSE
          ,x_return_status                => x_return_status
          ,x_msg_count                    => x_msg_count
          ,x_msg_data                     => x_msg_data
          ,p_pxlv_rec                     => p_pxlv_tbl(i));
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS
        THEN
          IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR
          THEN
            l_overall_status := x_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_pxlv_tbl.LAST);
        i := p_pxlv_tbl.NEXT(i);
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
  END validate_pxl_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added for Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_pxh_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_pxh_rec, p_pxhl_tbl
  --                  ,x_pxh_rec, x_pxhl_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxh_extension(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_pxh_rec                 IN  pxh_rec_type
    ,p_pxhl_tbl                IN  pxhl_tbl_type
    ,x_pxh_rec                 OUT NOCOPY pxh_rec_type
    ,x_pxhl_tbl                OUT NOCOPY pxhl_tbl_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  okl_pxh_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pxh_rec       => p_pxh_rec
                          ,p_pxhl_tbl      => p_pxhl_tbl
                          ,x_pxh_rec       => x_pxh_rec
                          ,x_pxhl_tbl      => x_pxhl_tbl
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
  END create_pxh_extension;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Added for Bug# 6268782 : PRASJAIN
  --
  -- Procedure Name  : create_pxl_extension
  -- Description     : wrapper api for creating Transaction Extension
  -- Business Rules  :
  -- Parameters      : p_api_version ,p_init_msg_list,x_return_status
  --                  ,x_msg_count ,x_msg_data ,p_pxl_rec, p_pxll_tbl
  --                  ,x_pxl_rec, x_pxll_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------
  PROCEDURE create_pxl_extension(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_pxl_rec                        IN  pxl_rec_type
    ,p_pxll_tbl                       IN  pxll_tbl_type
    ,x_pxl_rec                        OUT NOCOPY pxl_rec_type
    ,x_pxll_tbl                       OUT NOCOPY pxll_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
    okl_pxl_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pxl_rec       => p_pxl_rec
                          ,p_pxll_tbl      => p_pxll_tbl
                          ,x_pxl_rec       => x_pxl_rec
                          ,x_pxll_tbl      => x_pxll_tbl
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
  END create_pxl_extension;
END OKL_AP_EXTENSION_PVT;

/
