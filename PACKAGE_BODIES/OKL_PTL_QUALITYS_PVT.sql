--------------------------------------------------------
--  DDL for Package Body OKL_PTL_QUALITYS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PTL_QUALITYS_PVT" AS
  /* $Header: OKLCPTQB.pls 115.4 2002/02/18 20:13:12 pkm ship       $ */


  PROCEDURE create_ptl_qualitys(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                     IN  ptqv_rec_type
    ,p_ptvv_tbl                     IN  ptvv_tbl_type
    ,x_ptqv_rec                     OUT NOCOPY ptqv_rec_type
    ,x_ptvv_tbl                     OUT NOCOPY ptvv_tbl_type
    ) IS

    i                               NUMBER;
    l_ptqv_rec                      ptqv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_ptvv_tbl                      ptvv_tbl_type := p_ptvv_tbl;

  BEGIN
  -- Populate Template Qualitys
    create_ptl_qualitys(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_ptqv_rec      => p_ptqv_rec
                        ,x_ptqv_rec      => x_ptqv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  -- populate the foreign key for the detail
    IF (l_ptvv_tbl.COUNT > 0) THEN
       i:= l_ptvv_tbl.FIRST;
       LOOP
         l_ptvv_tbl(i).ptq_id := x_ptqv_rec.id;
         EXIT WHEN(i = l_ptvv_tbl.LAST);
         i := l_ptvv_tbl.NEXT(i);
       END LOOP;
    END IF;


    -- populate the detail
    create_ptl_qlty_values(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_ptvv_tbl      => l_ptvv_tbl
                             ,x_ptvv_tbl      => x_ptvv_tbl);
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
  END create_ptl_qualitys;

  PROCEDURE create_ptl_qualitys(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                IN  ptqv_rec_type
    ,x_ptqv_rec                OUT NOCOPY ptqv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptq_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptqv_rec      => p_ptqv_rec
                          ,x_ptqv_rec      => x_ptqv_rec
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
  END create_ptl_qualitys;
--null;
  PROCEDURE create_ptl_qualitys(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_ptqv_tbl                  IN  ptqv_tbl_type
    ,x_ptqv_tbl                  OUT NOCOPY ptqv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptq_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptqv_tbl      => p_ptqv_tbl
                          ,x_ptqv_tbl      => x_ptqv_tbl
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

  END create_ptl_qualitys;

  -- Object type procedure for update
  PROCEDURE update_ptl_qualitys(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ptqv_rec              IN  ptqv_rec_type,
    p_ptvv_tbl              IN  ptvv_tbl_type,
    x_ptqv_rec              OUT NOCOPY ptqv_rec_type,
    x_ptvv_tbl              OUT NOCOPY ptvv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_ptl_qualitys(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_ptqv_rec      => p_ptqv_rec
                        ,x_ptqv_rec      => x_ptqv_rec
                        );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Update the detail
    update_ptl_qlty_values(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_ptvv_tbl      => p_ptvv_tbl
                             ,x_ptvv_tbl      => x_ptvv_tbl
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

  END update_ptl_qualitys;

  PROCEDURE validate_ptl_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ptqv_rec              IN  ptqv_rec_type
    ,p_ptvv_tbl              IN  ptvv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_ptl_qualitys(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptqv_rec      => p_ptqv_rec
                          );

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

    -- Validate the detail
    validate_ptl_qlty_values(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_ptvv_tbl      => p_ptvv_tbl
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

  END validate_ptl_qualitys;

  PROCEDURE lock_ptl_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ptqv_rec              IN  ptqv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptq_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_ptqv_rec      => p_ptqv_rec
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
  END lock_ptl_qualitys;

  PROCEDURE lock_ptl_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ptqv_tbl              IN  ptqv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptq_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_ptqv_tbl      => p_ptqv_tbl
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
  END lock_ptl_qualitys;

  PROCEDURE update_ptl_qualitys(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                   IN  ptqv_rec_type
    ,x_ptqv_rec                   OUT NOCOPY ptqv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptq_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptqv_rec      => p_ptqv_rec
                          ,x_ptqv_rec      => x_ptqv_rec
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
  END update_ptl_qualitys;

  PROCEDURE update_ptl_qualitys(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_ptqv_tbl                   IN  ptqv_tbl_type
    ,x_ptqv_tbl                   OUT NOCOPY ptqv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptq_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptqv_tbl      => p_ptqv_tbl
                          ,x_ptqv_tbl      => x_ptqv_tbl
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
  END update_ptl_qualitys;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_ptl_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ptqv_rec              IN  ptqv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ptvv_tbl               ptvv_tbl_type;

    CURSOR ptv_csr IS
      SELECT ptv.id
        FROM OKL_PTQ_VALUES ptv
       WHERE ptv.ptq_id = p_ptqv_rec.id;
  BEGIN
    FOR ptv_rec IN ptv_csr
    LOOP
      i := i + 1;
      l_ptvv_tbl(i).id := ptv_rec.id;
    END LOOP;
    IF l_ptvv_tbl.COUNT > 0 THEN
      delete_ptl_qlty_values(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_ptvv_tbl      => l_ptvv_tbl
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
    okl_ptq_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptqv_rec      => p_ptqv_rec
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
  END delete_ptl_qualitys;

  PROCEDURE delete_ptl_qualitys(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ptqv_tbl              IN  ptqv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_ptqv_tbl.COUNT > 0) THEN
      i := p_ptqv_tbl.FIRST;
      LOOP
        delete_ptl_qualitys(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ptqv_rec      => p_ptqv_tbl(i)
                            );
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
      EXIT WHEN (i = p_ptqv_tbl.LAST);
      i := p_ptqv_tbl.NEXT(i);
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
  END delete_ptl_qualitys;

  PROCEDURE validate_ptl_qualitys(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_ptqv_rec                   IN  ptqv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptq_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ptqv_rec      => p_ptqv_rec
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
  END validate_ptl_qualitys;

  PROCEDURE validate_ptl_qualitys(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_ptqv_tbl                  IN  ptqv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptq_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ptqv_tbl      => p_ptqv_tbl
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
  END validate_ptl_qualitys;

  PROCEDURE create_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_rec                       IN  ptvv_rec_type
    ,x_ptvv_rec                       OUT NOCOPY ptvv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptv_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptvv_rec      => p_ptvv_rec
                          ,x_ptvv_rec      => x_ptvv_rec
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
  END create_ptl_qlty_values;

  PROCEDURE create_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_tbl                       IN  ptvv_tbl_type
    ,x_ptvv_tbl                       OUT NOCOPY ptvv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptv_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptvv_tbl      => p_ptvv_tbl
                          ,x_ptvv_tbl      => x_ptvv_tbl
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
  END create_ptl_qlty_values;

  PROCEDURE lock_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_rec                       IN  ptvv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptv_pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptvv_rec      => p_ptvv_rec
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

  END lock_ptl_qlty_values;

  PROCEDURE lock_ptl_qlty_values(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_ptvv_tbl                      IN  ptvv_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptv_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_ptvv_tbl      => p_ptvv_tbl
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
  END lock_ptl_qlty_values;

  PROCEDURE update_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_rec                       IN  ptvv_rec_type
    ,x_ptvv_rec                       OUT NOCOPY ptvv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptv_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptvv_rec      => p_ptvv_rec
                          ,x_ptvv_rec      => x_ptvv_rec
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
  END update_ptl_qlty_values;

  PROCEDURE update_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_tbl                       IN  ptvv_tbl_type
    ,x_ptvv_tbl                       OUT NOCOPY ptvv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ptv_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptvv_tbl      => p_ptvv_tbl
                          ,x_ptvv_tbl      => x_ptvv_tbl
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
  END update_ptl_qlty_values;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_rec                       IN  ptvv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptv_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ptvv_rec      => p_ptvv_rec);
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
  END delete_ptl_qlty_values;

  PROCEDURE delete_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_tbl                       IN  ptvv_tbl_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
  BEGIN
  --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_ptvv_tbl.COUNT > 0) THEN
      i := p_ptvv_tbl.FIRST;
      LOOP
        delete_ptl_qlty_values(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_ptvv_rec      => p_ptvv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
      EXIT WHEN (i = p_ptvv_tbl.LAST);
      i := p_ptvv_tbl.NEXT(i);
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
  END delete_ptl_qlty_values;

  PROCEDURE validate_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_rec                       IN  ptvv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptv_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ptvv_rec      => p_ptvv_rec
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
  END validate_ptl_qlty_values;

  PROCEDURE validate_ptl_qlty_values(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ptvv_tbl                       IN  ptvv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ptv_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ptvv_tbl      => p_ptvv_tbl
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
  END validate_ptl_qlty_values;

END OKL_PTL_QUALITYS_PVT;

/
