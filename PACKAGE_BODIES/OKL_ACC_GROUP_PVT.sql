--------------------------------------------------------
--  DDL for Package Body OKL_ACC_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACC_GROUP_PVT" as
/* $Header: OKLCAGCB.pls 115.4 2002/02/18 20:10:22 pkm ship       $ */

PROCEDURE create_acc_group(p_api_version                  IN NUMBER
                          ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status                OUT NOCOPY VARCHAR2
                          ,x_msg_count                    OUT NOCOPY NUMBER
                          ,x_msg_data                     OUT NOCOPY VARCHAR2
                          ,p_agcv_rec                     IN agcv_rec_type
                          ,p_agbv_tbl                     IN agbv_tbl_type
                          ,x_agcv_rec                     OUT NOCOPY agcv_rec_type
                          ,x_agbv_tbl                     OUT NOCOPY agbv_tbl_type
    ) IS

    i                  NUMBER;
    l_agcv_rec         agcv_rec_type;
    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_agbv_tbl         agbv_tbl_type  := p_agbv_tbl;

BEGIN

  create_acc_ccid(p_api_version        => p_api_version
                 ,p_init_msg_list      => p_init_msg_list
                 ,x_return_status      => x_return_status
                 ,x_msg_count          => x_msg_count
                 ,x_msg_data           => x_msg_data
                 ,p_agcv_rec           => p_agcv_rec
                 ,x_agcv_rec           => x_agcv_rec);

  IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
         -- populate the foreign key for the detail
     IF (l_agbv_tbl.COUNT > 0) THEN
         i:= l_agbv_tbl.FIRST;
         LOOP
            l_agbv_tbl(i).acc_group_id := x_agcv_rec.id;
            EXIT WHEN(i = l_agbv_tbl.LAST);
            i := l_agbv_tbl.NEXT(i);
         END LOOP;
     END IF;


     -- populate the detail
     create_acc_bal(p_api_version   => p_api_version
                   ,p_init_msg_list => p_init_msg_list
                   ,x_return_status => x_return_status
                   ,x_msg_count     => x_msg_count
                   ,x_msg_data      => x_msg_data
                   ,p_agbv_tbl      => l_agbv_tbl
                   ,x_agbv_tbl      => x_agbv_tbl);
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

END create_acc_group;

PROCEDURE create_acc_ccid(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_agcv_rec                IN  agcv_rec_type
    ,x_agcv_rec                OUT NOCOPY agcv_rec_type) IS

    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    okl_agc_pvt.insert_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agcv_rec      => p_agcv_rec
                          ,x_agcv_rec      => x_agcv_rec
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

END create_acc_ccid;



PROCEDURE create_acc_ccid(p_api_version               IN  NUMBER
                         ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status             OUT NOCOPY VARCHAR2
                         ,x_msg_count                 OUT NOCOPY NUMBER
                         ,x_msg_data                  OUT NOCOPY VARCHAR2
                         ,p_agcv_tbl                  IN  agcv_tbl_type
                         ,x_agcv_tbl                  OUT NOCOPY agcv_tbl_type) IS

 l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
 l_overall_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
 i                            NUMBER := 0;

BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        create_acc_ccid(p_api_version                  => p_api_version,
                        p_init_msg_list                => Okc_Api.G_FALSE,
                        x_return_status                => x_return_status,
                        x_msg_count                    => x_msg_count,
                        x_msg_data                     => x_msg_data,
                        p_agcv_rec                     => p_agcv_tbl(i),
                        x_agcv_rec                     => x_agcv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
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

END create_acc_ccid;


PROCEDURE update_acc_group(p_api_version           IN  NUMBER,
                           p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           x_msg_count             OUT NOCOPY NUMBER,
                           x_msg_data              OUT NOCOPY VARCHAR2,
                           p_agcv_rec              IN  agcv_rec_type,
                           p_agbv_tbl              IN  agbv_tbl_type,
                           x_agcv_rec              OUT NOCOPY agcv_rec_type,
                           x_agbv_tbl              OUT NOCOPY agbv_tbl_type)

IS

  l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
    -- Update the master
    update_acc_ccid(p_api_version   => p_api_version
                   ,p_init_msg_list => p_init_msg_list
                   ,x_return_status => x_return_status
                   ,x_msg_count     => x_msg_count
                   ,x_msg_data      => x_msg_data
                   ,p_agcv_rec      => p_agcv_rec
                   ,x_agcv_rec      => x_agcv_rec);

    IF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

    -- Update the detail
        update_acc_bal(p_api_version   => p_api_version
                      ,p_init_msg_list => p_init_msg_list
                      ,x_return_status => x_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_agbv_tbl      => p_agbv_tbl
                      ,x_agbv_tbl      => x_agbv_tbl);

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

  END update_acc_group;


PROCEDURE validate_acc_group(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_agcv_rec              IN  agcv_rec_type
    ,p_agbv_tbl              IN  agbv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Validate the master
    validate_acc_ccid(p_api_version   => p_api_version
                     ,p_init_msg_list => p_init_msg_list
                     ,x_return_status => x_return_status
                     ,x_msg_count     => x_msg_count
                     ,x_msg_data      => x_msg_data
                     ,p_agcv_rec      => p_agcv_rec);

    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
       END IF;
    END IF;

    -- Validate the detail
    validate_acc_bal(p_api_version   => p_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    ,p_agbv_tbl      => p_agbv_tbl);

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

  END validate_acc_group;


PROCEDURE lock_acc_ccid(p_api_version           IN  NUMBER
                       ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                       ,x_return_status         OUT NOCOPY VARCHAR2
                       ,x_msg_count             OUT NOCOPY NUMBER
                       ,x_msg_data              OUT NOCOPY VARCHAR2
                       ,p_agcv_rec              IN  agcv_rec_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    okl_agc_pvt.lock_row(p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_agcv_rec      => p_agcv_rec);

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
  END lock_acc_ccid;


PROCEDURE lock_acc_ccid(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_agcv_tbl              IN  agcv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                        NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        lock_acc_ccid(p_api_version                  => p_api_version,
                      p_init_msg_list                => Okc_Api.G_FALSE,
                      x_return_status                => x_return_status,
                      x_msg_count                    => x_msg_count,
                      x_msg_data                     => x_msg_data,
                      p_agcv_rec                     => p_agcv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
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

  END lock_acc_ccid;


PROCEDURE update_acc_ccid(p_api_version                IN  NUMBER
                         ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status              OUT NOCOPY VARCHAR2
                         ,x_msg_count                  OUT NOCOPY NUMBER
                         ,x_msg_data                   OUT NOCOPY VARCHAR2
                         ,p_agcv_rec                   IN  agcv_rec_type
                         ,x_agcv_rec                   OUT NOCOPY agcv_rec_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    okl_agc_pvt.update_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agcv_rec      => p_agcv_rec
                          ,x_agcv_rec      => x_agcv_rec);

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
  END update_acc_ccid;


PROCEDURE update_acc_ccid(p_api_version                IN  NUMBER
                         ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status              OUT NOCOPY VARCHAR2
                         ,x_msg_count                  OUT NOCOPY NUMBER
                         ,x_msg_data                   OUT NOCOPY VARCHAR2
                         ,p_agcv_tbl                   IN  agcv_tbl_type
                         ,x_agcv_tbl                   OUT NOCOPY agcv_tbl_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                             NUMBER := 0;

  BEGIN

  Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        update_acc_ccid(p_api_version                  => p_api_version,
                        p_init_msg_list                => Okc_Api.G_FALSE,
                        x_return_status                => x_return_status,
                        x_msg_count                    => x_msg_count,
                        x_msg_data                     => x_msg_data,
                        p_agcv_rec                     => p_agcv_tbl(i),
                        x_agcv_rec                     => x_agcv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
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
  END update_acc_ccid;


 PROCEDURE delete_acc_ccid(p_api_version           IN  NUMBER
                          ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status         OUT NOCOPY VARCHAR2
                          ,x_msg_count             OUT NOCOPY NUMBER
                          ,x_msg_data              OUT NOCOPY VARCHAR2
                          ,p_agcv_rec              IN  agcv_rec_type) IS

    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_agbv_tbl               agbv_tbl_type;

 CURSOR agb_csr IS
 SELECT agb.id
 FROM OKL_ACC_GROUP_BAL agb
 WHERE agb.acc_group_id = p_agcv_rec.id;

  BEGIN
    FOR agb_rec IN agb_csr
    LOOP
      i := i + 1;
      l_agbv_tbl(i).id := agb_rec.id;
    END LOOP;


    delete_acc_bal( p_api_version   => p_api_version
                   ,p_init_msg_list => p_init_msg_list
                   ,x_return_status => x_return_status
                   ,x_msg_count     => x_msg_count
                   ,x_msg_data      => x_msg_data
                   ,p_agbv_tbl      => l_agbv_tbl);


    IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      okl_agc_pvt.delete_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_agcv_rec      => p_agcv_rec);

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

  END delete_acc_ccid;


 PROCEDURE delete_acc_ccid(p_api_version           IN  NUMBER
                          ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_return_status         OUT NOCOPY VARCHAR2
                          ,x_msg_count             OUT NOCOPY NUMBER
                          ,x_msg_data              OUT NOCOPY VARCHAR2
                          ,p_agcv_tbl              IN  agcv_tbl_type) IS

    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        delete_acc_ccid( p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_agcv_rec      => p_agcv_tbl(i));

       IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
          END IF;
       END IF;

         EXIT WHEN (i = p_agcv_tbl.LAST);
         i := p_agcv_tbl.NEXT(i);
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
END delete_acc_ccid;


 PROCEDURE validate_acc_ccid(p_api_version                IN  NUMBER
                            ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                            ,x_return_status              OUT NOCOPY VARCHAR2
                            ,x_msg_count                  OUT NOCOPY NUMBER
                            ,x_msg_data                   OUT NOCOPY VARCHAR2
                            ,p_agcv_rec                   IN  agcv_rec_type) IS

  l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    okl_agc_pvt.validate_row(p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_agcv_rec      => p_agcv_rec);

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
  END validate_acc_ccid;

PROCEDURE validate_acc_ccid(p_api_version               IN  NUMBER,
                            p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status             OUT NOCOPY VARCHAR2,
                            x_msg_count                 OUT NOCOPY NUMBER,
                            x_msg_data                  OUT NOCOPY VARCHAR2,
                            p_agcv_tbl                  IN  agcv_tbl_type)

 IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
      i                           NUMBER := 0;

  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        validate_acc_ccid(p_api_version                  => p_api_version,
                          p_init_msg_list                => Okc_Api.G_FALSE,
                          x_return_status                => x_return_status,
                          x_msg_count                    => x_msg_count,
                          x_msg_data                     => x_msg_data,
                          p_agcv_rec                     => p_agcv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
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
END validate_acc_ccid;


PROCEDURE create_acc_bal(p_api_version                    IN  NUMBER
                        ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                  OUT NOCOPY VARCHAR2
                        ,x_msg_count                      OUT NOCOPY NUMBER
                        ,x_msg_data                       OUT NOCOPY VARCHAR2
                        ,p_agbv_rec                       IN  agbv_rec_type
                        ,x_agbv_rec                       OUT NOCOPY agbv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    okl_agb_pvt.insert_row(p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agbv_rec      => p_agbv_rec
                          ,x_agbv_rec      => x_agbv_rec);

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

END create_acc_bal;

PROCEDURE create_acc_bal(p_api_version                    IN  NUMBER
                        ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                        ,x_return_status                  OUT NOCOPY VARCHAR2
                        ,x_msg_count                      OUT NOCOPY NUMBER
                        ,x_msg_data                       OUT NOCOPY VARCHAR2
                        ,p_agbv_tbl                       IN  agbv_tbl_type
                        ,x_agbv_tbl                       OUT NOCOPY agbv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i        NUMBER := 0;

  BEGIN

  OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agbv_tbl.COUNT > 0) THEN
      i := p_agbv_tbl.FIRST;
      LOOP
        create_acc_bal(p_api_version                  => p_api_version,
                       p_init_msg_list                => OKC_API.G_FALSE,
                       x_return_status                => x_return_status,
                       x_msg_count                    => x_msg_count,
                       x_msg_data                     => x_msg_data,
                       p_agbv_rec                     => p_agbv_tbl(i),
                       x_agbv_rec                     => x_agbv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agbv_tbl.LAST);
        i := p_agbv_tbl.NEXT(i);
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

  END create_acc_bal;

 PROCEDURE lock_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_rec                       IN  agbv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_agb_pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agbv_rec      => p_agbv_rec
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

  END lock_acc_bal;

PROCEDURE lock_acc_bal(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_agbv_tbl                      IN  agbv_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                  NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agbv_tbl.COUNT > 0) THEN
      i := p_agbv_tbl.FIRST;
      LOOP
        lock_acc_bal(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agbv_rec                     => p_agbv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agbv_tbl.LAST);
        i := p_agbv_tbl.NEXT(i);

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
  END lock_acc_bal;

PROCEDURE update_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_rec                       IN  agbv_rec_type
    ,x_agbv_rec                       OUT NOCOPY agbv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    okl_agb_pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agbv_rec      => p_agbv_rec
                          ,x_agbv_rec      => x_agbv_rec
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
  END update_acc_bal;

PROCEDURE update_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_tbl                       IN  agbv_tbl_type
    ,x_agbv_tbl                       OUT NOCOPY agbv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                                 NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agbv_tbl.COUNT > 0) THEN
      i := p_agbv_tbl.FIRST;
      LOOP
        update_acc_bal(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agbv_rec                     => p_agbv_tbl(i),
          x_agbv_rec                     => x_agbv_tbl(i));

        -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agbv_tbl.LAST);
        i := p_agbv_tbl.NEXT(i);
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
  END update_acc_bal;

 PROCEDURE delete_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_rec                       IN  agbv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_agb_pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_agbv_rec      => p_agbv_rec);
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
  END delete_acc_bal;

 PROCEDURE delete_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_tbl                       IN  agbv_tbl_type) IS

    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
  --Initialize the return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_agbv_tbl.COUNT > 0) THEN
      i := p_agbv_tbl.FIRST;
      LOOP
        delete_acc_bal(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_agbv_rec      => p_agbv_tbl(i));

         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
               l_overall_status := x_return_status;
            END IF;
         END IF;

         EXIT WHEN (i = p_agbv_tbl.LAST);
         i := p_agbv_tbl.NEXT(i);
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
  END delete_acc_bal;

  PROCEDURE validate_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_rec                       IN  agbv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    okl_agb_pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_agbv_rec      => p_agbv_rec
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
  END validate_acc_bal;

  PROCEDURE validate_acc_bal(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_agbv_tbl                       IN  agbv_tbl_type) IS

  l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
  i                                 NUMBER := 0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agbv_tbl.COUNT > 0) THEN
      i := p_agbv_tbl.FIRST;
      LOOP
        validate_acc_bal(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agbv_rec                     => p_agbv_tbl(i));
  -- store the highest degree of error
          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

        EXIT WHEN (i = p_agbv_tbl.LAST);
        i := p_agbv_tbl.NEXT(i);
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
  END validate_acc_bal;

END OKL_ACC_GROUP_PVT;

/
