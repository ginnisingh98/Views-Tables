--------------------------------------------------------
--  DDL for Package Body OKL_PDT_QUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PDT_QUALITYS_PVT" AS
  /* $Header: OKLCPQYB.pls 115.5 2002/02/18 20:13:09 pkm ship       $ */


  PROCEDURE create_pdt_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                     IN  pqyv_rec_type
    ,p_qvev_tbl                     IN  qvev_tbl_type
    ,x_pqyv_rec                     OUT NOCOPY pqyv_rec_type
    ,x_qvev_tbl                     OUT NOCOPY qvev_tbl_type
    ) IS

    i                               NUMBER;
    l_pqyv_rec                      pqyv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;

  BEGIN
  -- Populate Product Qualities
    create_pdt_qualitys(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_pqyv_rec      => p_pqyv_rec
                        ,x_pqyv_rec      => x_pqyv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  -- populate the foreign key for the detail
    IF (l_qvev_tbl.COUNT > 0) THEN
       i:= l_qvev_tbl.FIRST;
       LOOP
         l_qvev_tbl(i).pqy_id := x_pqyv_rec.id;
         EXIT WHEN(i = l_qvev_tbl.LAST);
         i := l_qvev_tbl.NEXT(i);
       END LOOP;
    END IF;


    -- populate the detail
    create_pdt_quality_vals(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_qvev_tbl      => l_qvev_tbl
                             ,x_qvev_tbl      => x_qvev_tbl);
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
  END create_pdt_qualitys;

  PROCEDURE create_pdt_qualitys(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                IN  pqyv_rec_type
    ,x_pqyv_rec                OUT NOCOPY pqyv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pqy_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pqyv_rec      => p_pqyv_rec
                          ,x_pqyv_rec      => x_pqyv_rec
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
  END create_pdt_qualitys;
--null;
  PROCEDURE create_pdt_qualitys(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_pqyv_tbl                  IN  pqyv_tbl_type
    ,x_pqyv_tbl                  OUT NOCOPY pqyv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_pqy_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pqyv_tbl      => p_pqyv_tbl
                          ,x_pqyv_tbl      => x_pqyv_tbl
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

  END create_pdt_qualitys;

  -- Object type procedure for update
  PROCEDURE update_pdt_qualitys(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_pqyv_rec              IN  pqyv_rec_type,
    p_qvev_tbl              IN  qvev_tbl_type,
    x_pqyv_rec              OUT NOCOPY pqyv_rec_type,
    x_qvev_tbl              OUT NOCOPY qvev_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_pdt_qualitys(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_pqyv_rec      => p_pqyv_rec
                        ,x_pqyv_rec      => x_pqyv_rec
                        );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Update the detail
    update_pdt_quality_vals(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_qvev_tbl      => p_qvev_tbl
                             ,x_qvev_tbl      => x_qvev_tbl
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

  END update_pdt_qualitys;

  PROCEDURE validate_pdt_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pqyv_rec              IN  pqyv_rec_type
    ,p_qvev_tbl              IN  qvev_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_pdt_qualitys(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pqyv_rec      => p_pqyv_rec
                          );

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

    -- Validate the detail
    validate_pdt_quality_vals(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_qvev_tbl      => p_qvev_tbl
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

  END validate_pdt_qualitys;

  PROCEDURE lock_pdt_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pqyv_rec              IN  pqyv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_pqy_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_pqyv_rec      => p_pqyv_rec
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
  END lock_pdt_qualitys;

  PROCEDURE lock_pdt_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pqyv_tbl              IN  pqyv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_pqy_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_pqyv_tbl      => p_pqyv_tbl
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
  END lock_pdt_qualitys;

  PROCEDURE update_pdt_qualitys(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                   IN  pqyv_rec_type
    ,x_pqyv_rec                   OUT NOCOPY pqyv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_pqy_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pqyv_rec      => p_pqyv_rec
                          ,x_pqyv_rec      => x_pqyv_rec
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
  END update_pdt_qualitys;

  PROCEDURE update_pdt_qualitys(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_pqyv_tbl                   IN  pqyv_tbl_type
    ,x_pqyv_tbl                   OUT NOCOPY pqyv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pqy_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pqyv_tbl      => p_pqyv_tbl
                          ,x_pqyv_tbl      => x_pqyv_tbl
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
  END update_pdt_qualitys;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_pdt_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pqyv_rec              IN  pqyv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qvev_tbl               qvev_tbl_type;

    CURSOR qve_csr IS
      SELECT qve.id
        FROM OKL_PQY_VALUES qve
       WHERE qve.pqy_id = p_pqyv_rec.id;
  BEGIN
    FOR qve_rec IN qve_csr
    LOOP
      i := i + 1;
      l_qvev_tbl(i).id := qve_rec.id;
    END LOOP;
    IF l_qvev_tbl.COUNT > 0 THEN
      delete_pdt_quality_vals(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_qvev_tbl      => l_qvev_tbl
                               );

      IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
        END IF;
      END IF;
    END IF;
    --Delete the Master
    okl_pqy_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_pqyv_rec      => p_pqyv_rec
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
  END delete_pdt_qualitys;

  PROCEDURE delete_pdt_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_pqyv_tbl              IN  pqyv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_pqyv_tbl.COUNT > 0) THEN
      i := p_pqyv_tbl.FIRST;
      LOOP
        delete_pdt_qualitys(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_pqyv_rec      => p_pqyv_tbl(i)
                            );
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
       EXIT WHEN (i = p_pqyv_tbl.LAST);
       i := p_pqyv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;
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
  END delete_pdt_qualitys;

  PROCEDURE validate_pdt_qualitys(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_pqyv_rec                   IN  pqyv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_pqy_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_pqyv_rec      => p_pqyv_rec
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
  END validate_pdt_qualitys;

  PROCEDURE validate_pdt_qualitys(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_pqyv_tbl                  IN  pqyv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_pqy_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_pqyv_tbl      => p_pqyv_tbl
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
  END validate_pdt_qualitys;

  PROCEDURE create_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_rec                       IN  qvev_rec_type
    ,x_qvev_rec                       OUT NOCOPY qvev_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_qve_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_qvev_rec      => p_qvev_rec
                          ,x_qvev_rec      => x_qvev_rec
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
  END create_pdt_quality_vals;

  PROCEDURE create_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_tbl                       IN  qvev_tbl_type
    ,x_qvev_tbl                       OUT NOCOPY qvev_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_qve_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_qvev_tbl      => p_qvev_tbl
                          ,x_qvev_tbl      => x_qvev_tbl
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
  END create_pdt_quality_vals;

  PROCEDURE lock_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_rec                       IN  qvev_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_qve_pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_qvev_rec      => p_qvev_rec
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

  END lock_pdt_quality_vals;

  PROCEDURE lock_pdt_quality_vals(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_qvev_tbl                      IN  qvev_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_qve_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_qvev_tbl      => p_qvev_tbl
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
  END lock_pdt_quality_vals;

  PROCEDURE update_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_rec                       IN  qvev_rec_type
    ,x_qvev_rec                       OUT NOCOPY qvev_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_qve_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_qvev_rec      => p_qvev_rec
                          ,x_qvev_rec      => x_qvev_rec
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
  END update_pdt_quality_vals;

  PROCEDURE update_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_tbl                       IN  qvev_tbl_type
    ,x_qvev_tbl                       OUT NOCOPY qvev_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_qve_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_qvev_tbl      => p_qvev_tbl
                          ,x_qvev_tbl      => x_qvev_tbl
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
  END update_pdt_quality_vals;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_rec                       IN  qvev_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_qve_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_qvev_rec      => p_qvev_rec);
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
  END delete_pdt_quality_vals;

  PROCEDURE delete_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_tbl                       IN  qvev_tbl_type) IS

    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
  BEGIN
  --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_qvev_tbl.COUNT > 0) THEN
      i := p_qvev_tbl.FIRST;
      LOOP
        delete_pdt_quality_vals(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_qvev_rec      => p_qvev_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_qvev_tbl.LAST);
        i := p_qvev_tbl.NEXT(i);
       END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
     END IF;
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
  END delete_pdt_quality_vals;

  PROCEDURE validate_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_rec                       IN  qvev_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_qve_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_qvev_rec      => p_qvev_rec
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
  END validate_pdt_quality_vals;

  PROCEDURE validate_pdt_quality_vals(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_qvev_tbl                       IN  qvev_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_qve_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_qvev_tbl      => p_qvev_tbl
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
  END validate_pdt_quality_vals;

END OKL_PDT_QUALITYS_PVT;

/
