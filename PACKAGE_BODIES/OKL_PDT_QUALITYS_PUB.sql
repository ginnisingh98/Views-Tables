--------------------------------------------------------
--  DDL for Package Body OKL_PDT_QUALITYS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PDT_QUALITYS_PUB" AS
/* $Header: OKLPPQYB.pls 115.7 2002/12/18 12:29:08 kjinger noship $ */



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

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;

    l_return_status                 VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;



  BEGIN

    SAVEPOINT create_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_pdt_qualitys_pvt.create_pdt_qualitys(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_pqyv_rec      => l_pqyv_rec

                        ,p_qvev_tbl      => l_qvev_tbl

                        ,x_pqyv_rec      => x_pqyv_rec

                        ,x_qvev_tbl      => x_qvev_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_pqyv_rec := x_pqyv_rec;
	   l_qvev_tbl := x_qvev_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','create_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_pdt_qualitys;



  PROCEDURE create_pdt_qualitys(

     p_api_version             IN  NUMBER

    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status           OUT NOCOPY VARCHAR2

    ,x_msg_count               OUT NOCOPY NUMBER

    ,x_msg_data                OUT NOCOPY VARCHAR2

    ,p_pqyv_rec                IN  pqyv_rec_type

    ,x_pqyv_rec                OUT NOCOPY pqyv_rec_type) IS

    l_return_status            VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;



  BEGIN

    SAVEPOINT create_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_pdt_qualitys_pvt.create_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_rec

                          ,x_pqyv_rec      => x_pqyv_rec

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_pqyv_rec := x_pqyv_rec;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','create_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_pdt_qualitys;



  PROCEDURE create_pdt_qualitys(

     p_api_version               IN  NUMBER

    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status             OUT NOCOPY VARCHAR2

    ,x_msg_count                 OUT NOCOPY NUMBER

    ,x_msg_data                  OUT NOCOPY VARCHAR2

    ,p_pqyv_tbl                  IN  pqyv_tbl_type

    ,x_pqyv_tbl                  OUT NOCOPY pqyv_tbl_type) IS

    l_return_status              VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_pdt_qualitys';

    i                            NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_pqyv_tbl                      pqyv_tbl_type := p_pqyv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_pqyv_tbl.COUNT > 0) THEN

      i := l_pqyv_tbl.FIRST;

      LOOP

        okl_pdt_qualitys_pub.create_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_tbl(i)

                          ,x_pqyv_rec      => x_pqyv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_pqyv_tbl.LAST);

          i := l_pqyv_tbl.NEXT(i);
       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_pqyv_tbl := x_pqyv_tbl;


    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','create_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


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

    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'update_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;



  BEGIN

    SAVEPOINT update_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_pdt_qualitys_pvt.update_pdt_qualitys(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => x_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_pqyv_rec      => l_pqyv_rec

                        ,p_qvev_tbl      => l_qvev_tbl

                        ,x_pqyv_rec      => x_pqyv_rec

                        ,x_qvev_tbl      => x_qvev_tbl

                        );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_pqyv_rec := x_pqyv_rec;
	   l_qvev_tbl := x_qvev_tbl;

   -- vertical industry-post processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','update_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_pdt_qualitys;



  PROCEDURE validate_pdt_qualitys(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_pqyv_rec              IN  pqyv_rec_type

    ,p_qvev_tbl              IN  qvev_tbl_type) IS



    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'validate_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;



  BEGIN

    SAVEPOINT validate_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






-- call complex entity API

    okl_pdt_qualitys_pvt.validate_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_rec

                          ,p_qvev_tbl      => l_qvev_tbl

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','validate_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_pdt_qualitys;



  PROCEDURE lock_pdt_qualitys(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_pqyv_rec              IN  pqyv_rec_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_pdt_qualitys';





  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_pdt_qualitys;


    okl_pdt_qualitys_pvt.lock_pdt_qualitys(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_pqyv_rec      => p_pqyv_rec

                        );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','lock_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_pdt_qualitys;



  PROCEDURE lock_pdt_qualitys(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_pqyv_tbl              IN  pqyv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_pdt_qualitys';

    i                        NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_pdt_qualitys;

    IF (p_pqyv_tbl.COUNT > 0) THEN

      i := p_pqyv_tbl.FIRST;

      LOOP

        okl_pdt_qualitys_pub.lock_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => p_pqyv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_pqyv_tbl.LAST);

          i := p_pqyv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAM_TYPE_PUB','lock_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_pdt_qualitys;



  PROCEDURE update_pdt_qualitys(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_pqyv_rec                   IN  pqyv_rec_type

    ,x_pqyv_rec                   OUT NOCOPY pqyv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;

  BEGIN

    SAVEPOINT update_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_pdt_qualitys_pvt.update_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_rec

                          ,x_pqyv_rec      => x_pqyv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_pqyv_rec := x_pqyv_rec;

    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','update_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_pdt_qualitys;



  PROCEDURE update_pdt_qualitys(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_pqyv_tbl                   IN  pqyv_tbl_type

    ,x_pqyv_tbl                   OUT NOCOPY pqyv_tbl_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_pdt_qualitys';

    i                             NUMBER;

	l_overall_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_pqyv_tbl					  pqyv_tbl_type := p_pqyv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT update_pdt_qualitys;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_pqyv_tbl.COUNT > 0) THEN

      i := l_pqyv_tbl.FIRST;

      LOOP

        update_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_tbl(i)

                          ,x_pqyv_rec      => x_pqyv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_pqyv_tbl.LAST);

          i := l_pqyv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_pqyv_tbl := x_pqyv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','update_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



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

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;



  BEGIN

    SAVEPOINT delete_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_pdt_qualitys_pvt.delete_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_rec

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','delete_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_pdt_qualitys;



  PROCEDURE delete_pdt_qualitys(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_pqyv_tbl              IN  pqyv_tbl_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_pdt_qualitys';

    l_overall_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_pqyv_tbl					  pqyv_tbl_type := p_pqyv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT delete_pdt_qualitys;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_pqyv_tbl.COUNT > 0) THEN

      i := l_pqyv_tbl.FIRST;

      LOOP

        delete_pdt_qualitys(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_pqyv_rec      => l_pqyv_tbl(i)

                            );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

         EXIT WHEN (i = l_pqyv_tbl.LAST);

         i := l_pqyv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

      END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','delete_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END delete_pdt_qualitys;



  PROCEDURE validate_pdt_qualitys(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_pqyv_rec                   IN  pqyv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'validate_pdt_qualitys';

    l_pqyv_rec                      pqyv_rec_type := p_pqyv_rec;



  BEGIN

    SAVEPOINT validate_pdt_qualitys;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_pdt_qualitys_pvt.validate_pdt_qualitys(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_pqyv_rec      => l_pqyv_rec

                            );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','validate_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_pdt_qualitys;



  PROCEDURE validate_pdt_qualitys(

      p_api_version               IN  NUMBER,

      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

      x_return_status             OUT NOCOPY VARCHAR2,

      x_msg_count                 OUT NOCOPY NUMBER,

      x_msg_data                  OUT NOCOPY VARCHAR2,

      p_pqyv_tbl                  IN  pqyv_tbl_type) IS

      l_return_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

      l_api_name                  CONSTANT VARCHAR2(30)  := 'validate_pdt_qualitys';

      i                           NUMBER;

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_pqyv_tbl					  pqyv_tbl_type := p_pqyv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT validate_pdt_qualitys;

   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_pqyv_tbl.COUNT > 0) THEN

      i := l_pqyv_tbl.FIRST;

      LOOP

        validate_pdt_qualitys(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_pqyv_rec      => l_pqyv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_pqyv_tbl.LAST);

          i := l_pqyv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_qualitys;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','validate_pdt_qualitys');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END validate_pdt_qualitys;



  PROCEDURE create_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_rec                       IN  qvev_rec_type

    ,x_qvev_rec                       OUT NOCOPY qvev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_pdt_quality_vals';

    l_qvev_rec                      qvev_rec_type := p_qvev_rec;

  BEGIN

    SAVEPOINT create_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_pdt_qualitys_pvt.create_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => l_qvev_rec

                          ,x_qvev_rec      => x_qvev_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_qvev_rec := x_qvev_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','create_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_pdt_quality_vals;



  PROCEDURE create_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_tbl                       IN  qvev_tbl_type

    ,x_qvev_tbl                       OUT NOCOPY qvev_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_pdt_quality_vals';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_qvev_tbl.COUNT > 0) THEN

      i := l_qvev_tbl.FIRST;

      LOOP

        create_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => l_qvev_tbl(i)

                          ,x_qvev_rec      => x_qvev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_qvev_tbl.LAST);

          i := l_qvev_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_qvev_tbl := x_qvev_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','create_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END create_pdt_quality_vals;



  PROCEDURE lock_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_rec                       IN  qvev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_pdt_quality_vals';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_pdt_quality_vals;

    okl_pdt_qualitys_pvt.lock_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => p_qvev_rec

                          );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','lock_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_pdt_quality_vals;



  PROCEDURE lock_pdt_quality_vals(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_qvev_tbl                      IN  qvev_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_pdt_quality_vals';

    i                                NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_pdt_quality_vals;

    IF (p_qvev_tbl.COUNT > 0) THEN

      i := p_qvev_tbl.FIRST;

      LOOP

        lock_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => p_qvev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_qvev_tbl.LAST);

          i := p_qvev_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','lock_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_pdt_quality_vals;



  PROCEDURE update_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_rec                       IN  qvev_rec_type

    ,x_qvev_rec                       OUT NOCOPY qvev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pdt_quality_vals';

    l_qvev_rec                      qvev_rec_type := p_qvev_rec;

  BEGIN

    SAVEPOINT update_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_pdt_qualitys_pvt.update_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => l_qvev_rec

                          ,x_qvev_rec      => x_qvev_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_qvev_rec := x_qvev_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','update_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_pdt_quality_vals;



  PROCEDURE update_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_tbl                       IN  qvev_tbl_type

    ,x_qvev_tbl                       OUT NOCOPY qvev_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pdt_quality_vals';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT update_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_qvev_tbl.COUNT > 0) THEN

      i := l_qvev_tbl.FIRST;

      LOOP

        update_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => l_qvev_tbl(i)

                          ,x_qvev_rec      => x_qvev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_qvev_tbl.LAST);

          i := l_qvev_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_qvev_tbl := x_qvev_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','update_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



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

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_pdt_quality_vals';

    l_qvev_rec                      qvev_rec_type := p_qvev_rec;

  BEGIN

    SAVEPOINT delete_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_pdt_qualitys_pvt.delete_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => l_qvev_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','delete_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_pdt_quality_vals;



  PROCEDURE delete_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_tbl                       IN  qvev_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_pdt_quality_vals';

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT delete_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_qvev_tbl.COUNT > 0) THEN

      i := l_qvev_tbl.FIRST;

      LOOP

        delete_pdt_quality_vals(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => l_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_qvev_rec      => l_qvev_tbl(i));
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_qvev_tbl.LAST);

          i := l_qvev_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','delete_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_pdt_quality_vals;



  PROCEDURE validate_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_rec                       IN  qvev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_pdt_quality_vals';

    l_qvev_rec                      qvev_rec_type := p_qvev_rec;

  BEGIN

    SAVEPOINT validate_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_pdt_qualitys_pvt.validate_pdt_quality_vals(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_qvev_rec      => l_qvev_rec

                            );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','validate_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_pdt_quality_vals;



  PROCEDURE validate_pdt_quality_vals(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_qvev_tbl                       IN  qvev_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_pdt_quality_vals';

    i                                 NUMBER;

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_qvev_tbl                      qvev_tbl_type := p_qvev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT validate_pdt_quality_vals;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_qvev_tbl.COUNT > 0) THEN

      i := l_qvev_tbl.FIRST;

      LOOP

        validate_pdt_quality_vals(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_qvev_rec      => l_qvev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_qvev_tbl.LAST);

          i := l_qvev_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_pdt_quality_vals;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PDT_QUALITYS_PUB','validate_pdt_quality_vals');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_pdt_quality_vals;



END OKL_PDT_QUALITYS_PUB;


/
