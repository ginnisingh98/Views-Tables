--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_PVT" AS
  /* $Header: OKLCSTMB.pls 120.3 2005/07/05 05:25:47 mansrini noship $ */

  PROCEDURE create_streams(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_rec                     IN  stmv_rec_type
    ,p_selv_tbl                     IN  selv_tbl_type
    ,x_stmv_rec                     OUT NOCOPY stmv_rec_type
    ,x_selv_tbl                     OUT NOCOPY selv_tbl_type
    ) IS

    i                               NUMBER;
    l_stmv_rec                      stmv_rec_type;
    l_return_status                 VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
    l_selv_tbl                      selv_tbl_type := p_selv_tbl;

  BEGIN
  -- Populate streams table
    create_streams(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_stmv_rec      => p_stmv_rec
                        ,x_stmv_rec      => x_stmv_rec);
    -- rabhupat bug#4371472 user defined exceptions are not handled
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- rabhupat bug#4371472 end
  -- populate the foreign key for the stream elements
    IF (l_selv_tbl.COUNT > 0) THEN
       i:= l_selv_tbl.FIRST;
       LOOP
         l_selv_tbl(i).stm_id := x_stmv_rec.id;
         EXIT WHEN(i = l_selv_tbl.LAST);
         i := l_selv_tbl.NEXT(i);
       END LOOP;
    END IF;

    -- populate the detail
    create_stream_elements(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_selv_tbl      => l_selv_tbl
                             ,x_selv_tbl      => x_selv_tbl);
    -- rabhupat bug#4371472 user defined exceptions are not handled
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- rabhupat bug#4371472 end
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;

      WHEN OTHERS THEN
        Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => SQLCODE
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END create_streams;


-- create streams(master-table,detail-table)
  PROCEDURE create_streams(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                     IN stmv_tbl_type
    ,p_selv_tbl                    IN selv_tbl_type
    ,x_stmv_tbl                    OUT NOCOPY stmv_tbl_type
    ,x_selv_tbl                    OUT NOCOPY selv_tbl_type
     )
	 IS
    l_return_status VARCHAR2(1) :=OKC_API.G_RET_STS_SUCCESS;
    l_stmv_tbl      stmv_tbl_type;
    l_selv_tbl      selv_tbl_type := p_selv_tbl;

    i               BINARY_INTEGER;
    j               BINARY_INTEGER;
BEGIN
     -- populate the master
    create_streams(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_stmv_tbl,
    x_stmv_tbl);
	okl_accounting_util.get_error_message(x_msg_count, x_msg_data);

    -- rabhupat bug#4371472 user defined exceptions are not handled
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- rabhupat bug#4371472 end

   FOR i IN x_stmv_tbl.first..x_stmv_tbl.last
    LOOP
      FOR j IN l_selv_tbl.first..l_selv_tbl.last
      LOOP
        IF l_selv_tbl(j).parent_index = i
        THEN
           l_selv_tbl(j).stm_id := x_stmv_tbl(i).id;
         END IF;
      END LOOP;
    END LOOP;
   /*
   -- populate the foreign keys for the detail
       if(l_selv_tbl.count > 0) then
            i:=l_selv_tbl.FIRST;
            loop
            -- assuming that stm_id in the okl_strm_elements table is referring to id in the okl_streams table
              l_selv_tbl(i).stm_id:=x_stmv_tbl(i).id;
              exit when(i=l_selv_tbl.last);
              i :=l_selv_tbl.next(i);
            end loop;
       end if; */

-- populate the detail
    create_stream_elements(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_selv_tbl,
    x_selv_tbl);

  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            l_return_status :=x_return_status;
         END IF;
  END IF;
EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
  WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END create_streams;

  PROCEDURE create_streams(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_stmv_rec                IN  stmv_rec_type
    ,x_stmv_rec                OUT NOCOPY stmv_rec_type) IS
    l_return_status            VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Stm_Pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_stmv_rec      => p_stmv_rec
                          ,x_stmv_rec      => x_stmv_rec
                          );

    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
      -- Custom code if any

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;

      WHEN OTHERS THEN
        Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => SQLCODE
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END create_streams;



  PROCEDURE create_streams(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                  IN  stmv_tbl_type
    ,x_stmv_tbl                  OUT NOCOPY stmv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Stm_Pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_stmv_tbl      => p_stmv_tbl
                          ,x_stmv_tbl      => x_stmv_tbl
                          );
    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
      -- Custom code if any

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;

      WHEN OTHERS THEN
        Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                           ,p_msg_name          => g_unexpected_error
                           ,p_token1            => g_sqlcode_token
                           ,p_token1_value      => SQLCODE
                           ,p_token2            => g_sqlerrm_token
                           ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END create_streams;

  -- Added by kthiruva on 12-May-2005 for Streams Performance
  -- Bug 4346646 - Start of Changes
  -- create streams(master-table,detail-table)
  PROCEDURE create_streams_perf(
     p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                     IN stmv_tbl_type
    ,p_selv_tbl                    IN selv_tbl_type
    ,x_stmv_tbl                    OUT NOCOPY stmv_tbl_type
    ,x_selv_tbl                    OUT NOCOPY selv_tbl_type
     )
	 IS
    l_return_status VARCHAR2(1) :=OKC_API.G_RET_STS_SUCCESS;
    l_stmv_tbl      stmv_tbl_type;
    l_selv_tbl      selv_tbl_type := p_selv_tbl;

    i               BINARY_INTEGER;
    j               BINARY_INTEGER;
    l_new_rec       BOOLEAN := true;
BEGIN
     -- calling the bulk update method of the TAPI
    okl_stm_pvt.insert_row_perf(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_stmv_tbl,
    x_stmv_tbl);
	okl_accounting_util.get_error_message(x_msg_count, x_msg_data);

    -- rabhupat bug#4371472 user defined exceptions are not handled
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- rabhupat bug#4371472 end

  -- This procedure call receives a table of stream headers and a table of stream
  -- elements.

  -- Populate the stm_id by using the x_stmv_tbl( l_selv_tbl(i).parent_index).id
  -- Modified by RGOOTY
  IF l_selv_tbl.COUNT > 0
  THEN
    i := l_selv_tbl.FIRST;
    WHILE i <= l_selv_tbl.LAST
    LOOP
      l_selv_tbl(i).stm_id := x_stmv_tbl( l_selv_tbl(i).parent_index ).id;
      i := l_selv_tbl.NEXT(i);
    END LOOP;
  END IF;

  -- populate the detail
  create_stream_elements(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_selv_tbl,
    x_selv_tbl);

  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
         IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            l_return_status :=x_return_status;
         END IF;
  END IF;
EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
       NULL;
  WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => SQLCODE,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => SQLERRM);

   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END create_streams_perf;
--Bug 4346646-End of Changes

  -- Object type procedure for update
  PROCEDURE update_streams(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_stmv_rec              IN  stmv_rec_type,
    p_selv_tbl              IN  selv_tbl_type,
    x_stmv_rec              OUT NOCOPY stmv_rec_type,
    x_selv_tbl              OUT NOCOPY selv_tbl_type) IS
    l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Update the master
    update_streams(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_stmv_rec      => p_stmv_rec
                        ,x_stmv_rec      => x_stmv_rec
                        );
    -- rabhupat bug#4371472 user defined exceptions are not handled
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- rabhupat bug#4371472 end

    -- Update the stream elements
    update_stream_elements(
                              p_api_version   => p_api_version
                             ,p_init_msg_list => p_init_msg_list
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data
                             ,p_selv_tbl      => p_selv_tbl
                             ,x_selv_tbl      => x_selv_tbl
                             );

    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;

    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END update_streams;

  PROCEDURE validate_streams(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_stmv_rec              IN  stmv_rec_type
    ,p_selv_tbl              IN  selv_tbl_type) IS

    l_return_status         VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate the master
    validate_streams(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_stmv_rec      => p_stmv_rec
                          );

    -- rabhupat bug#4371472 user defined exceptions are not handled
    IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- rabhupat bug#4371472 end

    -- Validate the stream elements
    validate_stream_elements(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_selv_tbl      => p_selv_tbl
                               );

    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END validate_streams;

  PROCEDURE lock_streams(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_stmv_rec              IN  stmv_rec_type) IS
    l_return_status          VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Stm_Pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_stmv_rec      => p_stmv_rec
                        );
    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END lock_streams;

  PROCEDURE lock_streams(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_stmv_tbl              IN  stmv_tbl_type) IS
    l_return_status          VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Stm_Pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_stmv_tbl      => p_stmv_tbl
                        );
    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END lock_streams;

  PROCEDURE update_streams(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_stmv_rec                   IN  stmv_rec_type
    ,x_stmv_rec                   OUT NOCOPY stmv_rec_type) IS
    l_return_status               VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Stm_Pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_stmv_rec      => p_stmv_rec
                          ,x_stmv_rec      => x_stmv_rec
                          );
    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END update_streams;

  PROCEDURE update_streams(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_stmv_tbl                   IN  stmv_tbl_type
    ,x_stmv_tbl                   OUT NOCOPY stmv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Stm_Pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_stmv_tbl      => p_stmv_tbl
                          ,x_stmv_tbl      => x_stmv_tbl
                          );
    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END update_streams;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_streams(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_stmv_rec              IN  stmv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_selv_tbl               selv_tbl_type;

    CURSOR sel_csr IS
      SELECT sel.id
        FROM OKL_STRM_ELEMENTS sel
       WHERE sel.stm_id = p_stmv_rec.id;
  BEGIN
    FOR sel_rec IN sel_csr
    LOOP
      i := i + 1;
      l_selv_tbl(i).id := sel_rec.id;
    END LOOP;
    IF l_selv_tbl.COUNT > 0 THEN
      delete_stream_elements(
                                p_api_version   => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_selv_tbl      => l_selv_tbl
                               );

      -- rabhupat bug#4371472 user defined exceptions are not handled
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- rabhupat bug#4371472 end
    END IF;
    --Delete the Master
    Okl_Stm_Pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_stmv_rec      => p_stmv_rec
                          );

    IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
         l_return_status := x_return_status;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);

      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END delete_streams;

  PROCEDURE delete_streams(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_stmv_tbl              IN  stmv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    --Initialize the return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_stmv_tbl.COUNT > 0) THEN
      i := p_stmv_tbl.FIRST;
      LOOP
        delete_streams(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_stmv_rec      => p_stmv_tbl(i)
                            );

         EXIT WHEN (i = p_stmv_tbl.LAST);
         i := p_stmv_tbl.NEXT(i);
       END LOOP;
      END IF;
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END delete_streams;

  PROCEDURE validate_streams(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_stmv_rec                   IN  stmv_rec_type) IS
    l_return_status               VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Stm_Pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_stmv_rec      => p_stmv_rec
                            );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_streams;

  PROCEDURE validate_streams(
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
      x_return_status             OUT NOCOPY VARCHAR2,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      p_stmv_tbl                  IN  stmv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Stm_Pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_stmv_tbl      => p_stmv_tbl
                            );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_streams;

  PROCEDURE create_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_rec                       IN  selv_rec_type
    ,x_selv_rec                       OUT NOCOPY selv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Sel_Pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_rec      => p_selv_rec
                          ,x_selv_rec      => x_selv_rec
                          );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END create_stream_elements;

  PROCEDURE create_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_tbl                       IN  selv_tbl_type
    ,x_selv_tbl                       OUT NOCOPY selv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Sel_Pvt.insert_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_tbl      => p_selv_tbl
                          ,x_selv_tbl      => x_selv_tbl
                          );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END create_stream_elements;

  PROCEDURE lock_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_rec                       IN  selv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Sel_Pvt.lock_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_rec      => p_selv_rec
                          );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END lock_stream_elements;

  PROCEDURE lock_stream_elements(
     p_api_version                   IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_selv_tbl                      IN  selv_tbl_type) IS
    l_return_status                  VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Sel_Pvt.lock_row(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_selv_tbl      => p_selv_tbl
                        );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END lock_stream_elements;

  PROCEDURE update_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_rec                       IN  selv_rec_type
    ,x_selv_rec                       OUT NOCOPY selv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Sel_Pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_rec      => p_selv_rec
                          ,x_selv_rec      => x_selv_rec
                          );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END update_stream_elements;

  PROCEDURE update_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_tbl                       IN  selv_tbl_type
    ,x_selv_tbl                       OUT NOCOPY selv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Sel_Pvt.update_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_tbl      => p_selv_tbl
                          ,x_selv_tbl      => x_selv_tbl
                          );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END update_stream_elements;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_rec                       IN  selv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Sel_Pvt.delete_row(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_selv_rec      => p_selv_rec);
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END delete_stream_elements;

  PROCEDURE delete_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_tbl                       IN  selv_tbl_type) IS

    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
  --Initialize the return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_selv_tbl.COUNT > 0) THEN
      i := p_selv_tbl.FIRST;
      LOOP
        delete_stream_elements(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_selv_rec      => p_selv_tbl(i));
          EXIT WHEN (i = p_selv_tbl.LAST);
          i := p_selv_tbl.NEXT(i);
       END LOOP;
     END IF;
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END delete_stream_elements;

  PROCEDURE validate_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_rec                       IN  selv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Sel_Pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_selv_rec      => p_selv_rec
                            );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_stream_elements;

  PROCEDURE validate_stream_elements(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_selv_tbl                       IN  selv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    Okl_Sel_Pvt.validate_row(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_selv_tbl      => p_selv_tbl
                            );
      IF x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
          l_return_status := x_return_status;
           END IF;
      END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      Okc_Api.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => SQLCODE
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => SQLERRM);
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_stream_elements;

  PROCEDURE create_version(
             p_api_version          IN  NUMBER,
  	   p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
  	   x_return_status        OUT NOCOPY VARCHAR2,
  	   x_msg_count            OUT NOCOPY NUMBER,
       	   x_msg_data             OUT NOCOPY VARCHAR2,
             p_khr_id 		  IN NUMBER,
             p_major_version 	  IN NUMBER) IS


      	   BEGIN

        	   x_return_status := OKC_API.G_RET_STS_SUCCESS;


      	   INSERT INTO OKL_STREAMS_H
        	   (
                major_version,
      	  	  ID,
      	  	  TRANSACTION_NUMBER,
      	  	  OBJECT_VERSION_NUMBER,
      	  	  SGN_CODE,
      	  	  SAY_CODE,
      	  	  STY_ID,
      	  	  KLE_ID,
      	  	  KHR_ID,
      	  	  ACTIVE_YN,
      	  	  PURPOSE_CODE,
      	  	  DATE_CURRENT,
      	  	  DATE_WORKING,
      	  	  DATE_HISTORY,
      	  	  COMMENTS,
      	  	  CREATED_BY,
      	  	  CREATION_DATE,
      	  	  LAST_UPDATED_BY,
      	  	  LAST_UPDATE_DATE,
      	  	  PROGRAM_ID,
      	  	  REQUEST_ID,
      	  	  PROGRAM_APPLICATION_ID,
      	  	  PROGRAM_UPDATE_DATE,
      	  	  LAST_UPDATE_LOGIN ,
      	  	  STM_ID,
      	  	  SOURCE_ID,
        	  SOURCE_TABLE,
--HKPATEL changed for bug 4212626
			  TRX_ID,
			  LINK_HIST_STREAM_ID

      		  )
        	   SELECT
            	  p_major_version,
      		  ID,
      		  TRANSACTION_NUMBER,
      		  OBJECT_VERSION_NUMBER,
      		  SGN_CODE,
      		  SAY_CODE,
      		  STY_ID,
      		  KLE_ID,
      		  KHR_ID,
      		  ACTIVE_YN,
      		  PURPOSE_CODE,
      		  DATE_CURRENT,
      		  DATE_WORKING,
      		  DATE_HISTORY,
      		  COMMENTS,
      		  CREATED_BY,
      		  CREATION_DATE,
      		  LAST_UPDATED_BY,
      		  LAST_UPDATE_DATE,
      		  PROGRAM_ID,
      		  REQUEST_ID,
      		  PROGRAM_APPLICATION_ID,
      		  PROGRAM_UPDATE_DATE,
      		  LAST_UPDATE_LOGIN ,
      		  STM_ID,
      		  SOURCE_ID,
        	  SOURCE_TABLE,
--HKPATEL changed for bug 4212626
			  TRX_ID,
			  LINK_HIST_STREAM_ID

        	   FROM OKL_STREAMS
        	   WHERE
        	   say_code = 'CURR' and
        	   khr_id = p_khr_id;


  --    	   x_return_status := l_return_status;

        	   EXCEPTION
             -- other appropriate handlers
             WHEN OTHERS THEN
             -- store SQL error message on message stack
                   OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                       p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                       p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                       p_token1_value => sqlcode,
                                       p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                       p_token2_value => sqlerrm);

             -- notify  UNEXPECTED error
                   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


        END create_version;

        PROCEDURE create_strm_element_version(
          p_api_version          IN  NUMBER,
  	  p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
  	  x_return_status        OUT NOCOPY VARCHAR2,
  	  x_msg_count            OUT NOCOPY NUMBER,
       	  x_msg_data             OUT NOCOPY VARCHAR2,
          p_khr_id 	       IN NUMBER,
          p_major_version        IN NUMBER) IS

        	l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

      	BEGIN


      	INSERT INTO OKL_STRM_ELEMENTS_H
        	(
                MAJOR_VERSION,
      	 	  ID ,
      	  	  SE_LINE_NUMBER ,
      	  	  DATE_BILLED ,
      	  	  STM_ID ,
      	  	  OBJECT_VERSION_NUMBER ,
      	  	  STREAM_ELEMENT_DATE ,
      	  	  AMOUNT ,
      	  	  COMMENTS ,
      	  	  ACCRUED_YN ,
      	  	  PROGRAM_ID ,
      	  	  REQUEST_ID,
      	  	  PROGRAM_APPLICATION_ID,
      	  	  PROGRAM_UPDATE_DATE ,
      	  	  CREATED_BY ,
      	  	  CREATION_DATE ,
      	  	  LAST_UPDATED_BY ,
      	  	  LAST_UPDATE_DATE ,
      	  	  LAST_UPDATE_LOGIN ,
      	  	  SEL_ID ,
      	  	  SOURCE_ID ,
      		  SOURCE_TABLE,
--HKPATEL changed for bug 4212626
			  BILL_ADJ_FLAG,
			  ACCRUAL_ADJ_FLAG

         )
         SELECT
            	  p_major_version,
      		  ID ,
      		  SE_LINE_NUMBER ,
                DATE_BILLED ,
                STM_ID ,
                OBJECT_VERSION_NUMBER ,
                STREAM_ELEMENT_DATE ,
                AMOUNT ,
                COMMENTS ,
                ACCRUED_YN ,
                PROGRAM_ID ,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_UPDATE_DATE ,
                CREATED_BY ,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE ,
                LAST_UPDATE_LOGIN ,
                SEL_ID ,
                SOURCE_ID,
      		  SOURCE_TABLE,
--HKPATEL changed for bug 4212626
			  BILL_ADJ_FLAG,
			  ACCRUAL_ADJ_FLAG

        	FROM OKL_STRM_ELEMENTS
        	WHERE stm_id in (Select id from OKL_STREAMS where khr_id = p_khr_id and say_code ='CURR');

        	EXCEPTION
             -- other appropriate handlers
          WHEN OTHERS THEN
             -- store SQL error message on message stack
                   OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                       p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                       p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                       p_token1_value => sqlcode,
                                       p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                       p_token2_value => sqlerrm);

             -- notify  UNEXPECTED error
                   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        END create_strm_element_version;

        PROCEDURE version_stream(
       	p_api_version                  IN  NUMBER,
       	p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
       	x_return_status                OUT NOCOPY VARCHAR2,
       	x_msg_count                    OUT NOCOPY NUMBER,
       	x_msg_data                     OUT NOCOPY VARCHAR2,
       	p_khr_id 		       IN NUMBER,
       	p_major_version 	       IN NUMBER)  IS

          l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

    	  Cursor l_valid_contract_csr(l_khr_id NUMBER) Is
          	select 'x'
          	from OKL_K_HEADERS
          	where id = l_khr_id;

          Cursor l_strm_csr(l_khr_id NUMBER, l_major_version NUMBER) Is
          	select 'x'
          	from OKL_STREAMS_H
          	where khr_id = l_khr_id and major_version = l_major_version ;

          	l_strm_val varchar2(1);
    		l_cntrct_val varchar2(1);
          BEGIN
    	    OPEN l_valid_contract_csr(p_khr_id);
          	FETCH l_valid_contract_csr into l_cntrct_val;


          	IF l_valid_contract_csr%NOTFOUND THEN
          	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                 p_msg_name => 'OKL_INVALID_CONTRACT_ID',
                                 p_token1   => 'CONT_ID',
                                 p_token1_value => to_char(p_khr_id));

              l_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;

          	ELSE
      	  	null;


            END IF;
          	CLOSE l_valid_contract_csr;

          	OPEN l_strm_csr(p_khr_id , p_major_version );
          	FETCH l_strm_csr into l_strm_val;

          	IF l_strm_csr%NOTFOUND THEN
          	  null;
          	ELSE

    		  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                 p_msg_name => 'OKL_UNIQUE_CONTRACT_VERSION',
                                 p_token1   => 'CONT_VERSION',
                                 p_token1_value => p_major_version);

              l_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;

            END IF;
          	CLOSE l_strm_csr;


      		create_version(
      		               p_api_version,
  	               	       p_init_msg_list,
  			       x_return_status,
  			       x_msg_count,
       	   		       x_msg_data,
      		               p_khr_id ,
      		               p_major_version);




      		create_strm_element_version(
      		               p_api_version,
  			       p_init_msg_list,
  			       x_return_status,
  			       x_msg_count,
       	   		       x_msg_data,
      		               p_khr_id ,
      		               p_major_version);



          	EXCEPTION
    		WHEN G_EXCEPTION_HALT_VALIDATION THEN
    		NULL;
      	       -- other appropriate handlers
      	    WHEN OTHERS THEN
      	       -- store SQL error message on message stack
      	             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
      	                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
      	                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
      	                                 p_token1_value => sqlcode,
      	                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
      	                                 p_token2_value => sqlerrm);

      	       -- notify  UNEXPECTED error
      	             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;




  END version_stream;

END Okl_Streams_Pvt;

/
