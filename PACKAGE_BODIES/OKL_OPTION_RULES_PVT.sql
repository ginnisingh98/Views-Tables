--------------------------------------------------------
--  DDL for Package Body OKL_OPTION_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPTION_RULES_PVT" AS
  /* $Header: OKLCORLB.pls 115.4 2002/02/18 20:13:05 pkm ship       $ */


  PROCEDURE create_option_rules(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_orlv_rec                     IN  orlv_rec_type
    ,p_ovdv_tbl                     IN  ovdv_tbl_type
    ,x_orlv_rec                     OUT NOCOPY orlv_rec_type
    ,x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type
    ) IS

    i                               NUMBER;
    l_orlv_rec                      orlv_rec_type;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_ovdv_tbl                      ovdv_tbl_type := p_ovdv_tbl;

  BEGIN
  -- Populate TRX CONTRACTS
    create_option_rules(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_orlv_rec      => p_orlv_rec
                        ,x_orlv_rec      => x_orlv_rec);
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  -- populate the foreign key for the detail
    IF (l_ovdv_tbl.COUNT > 0) THEN
       i:= l_ovdv_tbl.FIRST;
       LOOP
         l_ovdv_tbl(i).orl_id := x_orlv_rec.id;
         EXIT WHEN(i = l_ovdv_tbl.LAST);
         i := l_ovdv_tbl.NEXT(i);
       END LOOP;
    END IF;


    -- populate the detail
    create_option_val_rules(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_ovdv_tbl      => l_ovdv_tbl
                             ,x_ovdv_tbl      => x_ovdv_tbl);
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
  END create_option_rules;

  PROCEDURE create_option_rules(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_orlv_rec                IN  orlv_rec_type
    ,x_orlv_rec                OUT NOCOPY orlv_rec_type) IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_orl_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orlv_rec      => p_orlv_rec
                          ,x_orlv_rec      => x_orlv_rec
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
  END create_option_rules;
--null;
  PROCEDURE create_option_rules(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_orlv_tbl                  IN  orlv_tbl_type
    ,x_orlv_tbl                  OUT NOCOPY orlv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_orl_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orlv_tbl      => p_orlv_tbl
                          ,x_orlv_tbl      => x_orlv_tbl
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

  END create_option_rules;

  -- Object type procedure for update
  PROCEDURE update_option_rules(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_orlv_rec              IN  orlv_rec_type,
    p_ovdv_tbl              IN  ovdv_tbl_type,
    x_orlv_rec              OUT NOCOPY orlv_rec_type,
    x_ovdv_tbl              OUT NOCOPY ovdv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_option_rules(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_orlv_rec      => p_orlv_rec
                        ,x_orlv_rec      => x_orlv_rec
                        );
    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Update the detail
    update_option_val_rules(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_ovdv_tbl      => p_ovdv_tbl
                             ,x_ovdv_tbl      => x_ovdv_tbl
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

  END update_option_rules;

  PROCEDURE validate_option_rules(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_orlv_rec              IN  orlv_rec_type
    ,p_ovdv_tbl              IN  ovdv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_option_rules(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orlv_rec      => p_orlv_rec
                          );

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

    -- Validate the detail
    validate_option_val_rules(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_ovdv_tbl      => p_ovdv_tbl
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

  END validate_option_rules;

  PROCEDURE lock_option_rules(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_orlv_rec              IN  orlv_rec_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_orl_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_orlv_rec      => p_orlv_rec
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
  END lock_option_rules;

  PROCEDURE lock_option_rules(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_orlv_tbl              IN  orlv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_orl_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_orlv_tbl      => p_orlv_tbl
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
  END lock_option_rules;

  PROCEDURE update_option_rules(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_orlv_rec                   IN  orlv_rec_type
    ,x_orlv_rec                   OUT NOCOPY orlv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_orl_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orlv_rec      => p_orlv_rec
                          ,x_orlv_rec      => x_orlv_rec
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
  END update_option_rules;

  PROCEDURE update_option_rules(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_orlv_tbl                   IN  orlv_tbl_type
    ,x_orlv_tbl                   OUT NOCOPY orlv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_orl_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orlv_tbl      => p_orlv_tbl
                          ,x_orlv_tbl      => x_orlv_tbl
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
  END update_option_rules;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_option_rules(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_orlv_rec              IN  orlv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovdv_tbl               ovdv_tbl_type;

    CURSOR ovd_csr IS
      SELECT ovd.id
        FROM OKL_OPV_RULES_V ovd
       WHERE ovd.orl_id = p_orlv_rec.id;
  BEGIN
    FOR ovd_rec IN ovd_csr
    LOOP
      i := i + 1;
      l_ovdv_tbl(i).id := ovd_rec.id;
    END LOOP;
    IF l_ovdv_tbl.COUNT > 0 THEN
      delete_option_val_rules(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_ovdv_tbl      => l_ovdv_tbl
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
    okl_orl_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_orlv_rec      => p_orlv_rec
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
  END delete_option_rules;

  PROCEDURE delete_option_rules(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_orlv_tbl              IN  orlv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_orlv_tbl.COUNT > 0) THEN
      i := p_orlv_tbl.FIRST;
      LOOP
        delete_option_rules(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_orlv_rec      => p_orlv_tbl(i)
                            );
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
         EXIT WHEN (i = p_orlv_tbl.LAST);
         i := p_orlv_tbl.NEXT(i);
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
  END delete_option_rules;

  PROCEDURE validate_option_rules(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_orlv_rec                   IN  orlv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_orl_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_orlv_rec      => p_orlv_rec
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
  END validate_option_rules;

  PROCEDURE validate_option_rules(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_orlv_tbl                  IN  orlv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_orl_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_orlv_tbl      => p_orlv_tbl
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
  END validate_option_rules;

  PROCEDURE create_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_rec                       IN  ovdv_rec_type
    ,x_ovdv_rec                       OUT NOCOPY ovdv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ovd_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovdv_rec      => p_ovdv_rec
                          ,x_ovdv_rec      => x_ovdv_rec
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
  END create_option_val_rules;

  PROCEDURE create_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_tbl                       IN  ovdv_tbl_type
    ,x_ovdv_tbl                       OUT NOCOPY ovdv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ovd_pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovdv_tbl      => p_ovdv_tbl
                          ,x_ovdv_tbl      => x_ovdv_tbl
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
  END create_option_val_rules;

  PROCEDURE lock_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_rec                       IN  ovdv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ovd_pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovdv_rec      => p_ovdv_rec
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

  END lock_option_val_rules;

  PROCEDURE lock_option_val_rules(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_ovdv_tbl                      IN  ovdv_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ovd_pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_ovdv_tbl      => p_ovdv_tbl
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
  END lock_option_val_rules;

  PROCEDURE update_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_rec                       IN  ovdv_rec_type
    ,x_ovdv_rec                       OUT NOCOPY ovdv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ovd_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovdv_rec      => p_ovdv_rec
                          ,x_ovdv_rec      => x_ovdv_rec
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
  END update_option_val_rules;

  PROCEDURE update_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_tbl                       IN  ovdv_tbl_type
    ,x_ovdv_tbl                       OUT NOCOPY ovdv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_ovd_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovdv_tbl      => p_ovdv_tbl
                          ,x_ovdv_tbl      => x_ovdv_tbl
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
  END update_option_val_rules;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_rec                       IN  ovdv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ovd_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_ovdv_rec      => p_ovdv_rec);
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
  END delete_option_val_rules;

  PROCEDURE delete_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_tbl                       IN  ovdv_tbl_type) IS

    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
  BEGIN
  --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_ovdv_tbl.COUNT > 0) THEN
      i := p_ovdv_tbl.FIRST;
      LOOP
        delete_option_val_rules(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_ovdv_rec      => p_ovdv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ovdv_tbl.LAST);
        i := p_ovdv_tbl.NEXT(i);
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
  END delete_option_val_rules;

  PROCEDURE validate_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_rec                       IN  ovdv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ovd_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ovdv_rec      => p_ovdv_rec
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
  END validate_option_val_rules;

  PROCEDURE validate_option_val_rules(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_ovdv_tbl                       IN  ovdv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_ovd_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_ovdv_tbl      => p_ovdv_tbl
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
  END validate_option_val_rules;

END OKL_OPTION_RULES_PVT;

/
