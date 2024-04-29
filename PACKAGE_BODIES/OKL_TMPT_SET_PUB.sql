--------------------------------------------------------
--  DDL for Package Body OKL_TMPT_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TMPT_SET_PUB" AS
/* $Header: OKLPAESB.pls 115.10 2002/12/18 12:08:51 kjinger noship $ */


  PROCEDURE create_tmpt_set(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_aesv_rec                     IN  aesv_rec_type

    ,p_avlv_tbl                     IN  avlv_tbl_type

    ,p_atlv_tbl                     IN  atlv_tbl_type

    ,x_aesv_rec                     OUT NOCOPY aesv_rec_type

    ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type

    ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type

    ) IS



    i                               NUMBER;

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_tmpt_set';

    l_aesv_rec                      aesv_rec_type := p_aesv_rec;

    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;

    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;

  BEGIN

    SAVEPOINT create_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.create_tmpt_set(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_aesv_rec      => l_aesv_rec

                        ,p_avlv_tbl      => l_avlv_tbl

	                    ,p_atlv_tbl      => l_atlv_tbl

                        ,x_aesv_rec      => x_aesv_rec

                        ,x_avlv_tbl      => x_avlv_tbl

						,x_atlv_tbl => x_atlv_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aesv_rec := x_aesv_rec;
	   l_avlv_tbl := x_avlv_tbl;
	   l_atlv_tbl := x_atlv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_tmpt_set;



  PROCEDURE create_tmpt_set(

     p_api_version             IN  NUMBER

    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status           OUT NOCOPY VARCHAR2

    ,x_msg_count               OUT NOCOPY NUMBER

    ,x_msg_data                OUT NOCOPY VARCHAR2

    ,p_aesv_rec                IN  aesv_rec_type

    ,x_aesv_rec                OUT NOCOPY aesv_rec_type) IS

    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_tmpt_set';

    l_aesv_rec                      aesv_rec_type := p_aesv_rec;



  BEGIN

    SAVEPOINT create_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_tmpt_set_pvt.create_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_rec

                          ,x_aesv_rec      => x_aesv_rec

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aesv_rec := x_aesv_rec;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_tmpt_set;



  PROCEDURE create_tmpt_set(

     p_api_version               IN  NUMBER

    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status             OUT NOCOPY VARCHAR2

    ,x_msg_count                 OUT NOCOPY NUMBER

    ,x_msg_data                  OUT NOCOPY VARCHAR2

    ,p_aesv_tbl                  IN  aesv_tbl_type

    ,x_aesv_tbl                  OUT NOCOPY aesv_tbl_type) IS

    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_tmpt_set';

    i                            NUMBER;

    l_aesv_tbl                      aesv_tbl_type := p_aesv_tbl;

    l_overall_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status

     SAVEPOINT create_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_aesv_tbl.COUNT > 0) THEN

      i := l_aesv_tbl.FIRST;

      LOOP

        create_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_tbl(i)

                          ,x_aesv_rec      => x_aesv_tbl(i)

                          );

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_aesv_tbl.LAST);

          i := l_aesv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



	   l_aesv_tbl := x_aesv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing




  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_tmpt_set;



  -- Object type procedure for update

  PROCEDURE update_tmpt_set(

    p_api_version           IN  NUMBER,

    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,

    x_msg_count             OUT NOCOPY NUMBER,

    x_msg_data              OUT NOCOPY VARCHAR2,

    p_aesv_rec              IN  aesv_rec_type,

    p_avlv_tbl              IN  avlv_tbl_type,

	p_atlv_tbl				IN	atlv_tbl_type,

    x_aesv_rec              OUT NOCOPY aesv_rec_type,

    x_avlv_tbl              OUT NOCOPY avlv_tbl_type,

	x_atlv_tbl				OUT NOCOPY atlv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'update_tmpt_set';

    l_aesv_rec                      aesv_rec_type := p_aesv_rec;

    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;

    l_atlv_tbl                      atlv_tbl_type := p_atlv_tbl;



  BEGIN

    SAVEPOINT update_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.update_tmpt_set(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_aesv_rec      => l_aesv_rec

                        ,p_avlv_tbl      => l_avlv_tbl

                        ,p_atlv_tbl => l_atlv_tbl

                        ,x_aesv_rec      => x_aesv_rec

                        ,x_avlv_tbl      => x_avlv_tbl

						,x_atlv_tbl       => x_atlv_tbl

                        );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aesv_rec := x_aesv_rec;
	   l_avlv_tbl := x_avlv_tbl;
	   l_atlv_tbl := x_atlv_tbl;


   -- vertical industry-post processing





   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_tmpt_set;



  PROCEDURE validate_tmpt_set(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aesv_rec              IN  aesv_rec_type

    ,p_avlv_tbl              IN  avlv_tbl_type

	,p_atlv_tbl				 IN atlv_tbl_type) IS



    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'validate_tmpt_set';

    l_aesv_rec                      aesv_rec_type := p_aesv_rec;

    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;

    l_atlv_tbl                      atlv_tbl_type := p_atlv_tbl;



  BEGIN

    SAVEPOINT validate_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






-- call complex entity API

    okl_tmpt_set_pvt.validate_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_rec

                          ,p_avlv_tbl      => l_avlv_tbl

                          ,p_atlv_tbl => l_atlv_tbl

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
      ROLLBACK TO validate_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_tmpt_set;



  PROCEDURE lock_tmpt_set(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aesv_rec              IN  aesv_rec_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_tmpt_set';





  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_tmpt_set;



    okl_tmpt_set_pvt.lock_tmpt_set(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_aesv_rec      => p_aesv_rec

                        );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_tmpt_set;



  PROCEDURE lock_tmpt_set(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aesv_tbl              IN  aesv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_tmpt_set';

    i                        NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_tmpt_set;


    IF (p_aesv_tbl.COUNT > 0) THEN

      i := p_aesv_tbl.FIRST;

      LOOP

        lock_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => p_aesv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;
          EXIT WHEN (i = p_aesv_tbl.LAST);

          i := p_aesv_tbl.NEXT(i);

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
      ROLLBACK TO lock_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_tmpt_set;



  PROCEDURE update_tmpt_set(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_aesv_rec                   IN  aesv_rec_type

    ,x_aesv_rec                   OUT NOCOPY aesv_rec_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_tmpt_set';

    l_aesv_rec                      aesv_rec_type := p_aesv_rec;



  BEGIN

    SAVEPOINT update_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_tmpt_set_pvt.update_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_rec

                          ,x_aesv_rec      => x_aesv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aesv_rec := x_aesv_rec;


    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_tmpt_set;



  PROCEDURE update_tmpt_set(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_aesv_tbl                   IN  aesv_tbl_type

    ,x_aesv_tbl                   OUT NOCOPY aesv_tbl_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_tmpt_set';

    i                             NUMBER;

    l_aesv_tbl                    aesv_tbl_type := p_aesv_tbl;

  BEGIN

  --Initialize the return status

    SAVEPOINT update_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_aesv_tbl.COUNT > 0) THEN

      i := l_aesv_tbl.FIRST;

      LOOP

        update_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_tbl(i)

                          ,x_aesv_rec      => x_aesv_tbl(i)

                          );

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_aesv_tbl.LAST);

          i := l_aesv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_Status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aesv_tbl := x_aesv_tbl;

    -- vertical industry-post-processing






    -- customer post-processing





  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_tmpt_set;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_tmpt_set(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aesv_rec              IN  aesv_rec_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_tmpt_set';



    l_aesv_rec                      aesv_rec_type := p_aesv_rec;



  BEGIN

    SAVEPOINT delete_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_tmpt_set_pvt.delete_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_rec

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
      ROLLBACK TO delete_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','delete_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_tmpt_set;



  PROCEDURE delete_tmpt_set(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aesv_tbl              IN  aesv_tbl_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_tmpt_set';

    l_aesv_tbl                      aesv_tbl_type := p_aesv_tbl;

  BEGIN

    --Initialize the return status

     SAVEPOINT delete_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_aesv_tbl.COUNT > 0) THEN

      i := l_aesv_tbl.FIRST;

      LOOP

        delete_tmpt_set(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => x_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_aesv_rec      => l_aesv_tbl(i)

                            );

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

         EXIT WHEN (i = l_aesv_tbl.LAST);

         i := l_aesv_tbl.NEXT(i);

       END LOOP;

      END IF;

      x_return_status := l_overall_status;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;




    -- vertical industry-post-processing






    -- customer post-processing




  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','delete_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_tmpt_set;



  PROCEDURE validate_tmpt_set(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_aesv_rec                   IN  aesv_rec_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'validate_tmpt_set';

    l_aesv_rec                      aesv_rec_type := p_aesv_rec;



  BEGIN

    SAVEPOINT validate_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.validate_tmpt_set(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_aesv_rec      => l_aesv_rec

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
      ROLLBACK TO validate_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_tmpt_set;



  PROCEDURE validate_tmpt_set(

      p_api_version               IN  NUMBER,

      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

      x_return_status             OUT NOCOPY VARCHAR2,

      x_msg_count                 OUT NOCOPY NUMBER,

      x_msg_data                  OUT NOCOPY VARCHAR2,

      p_aesv_tbl                  IN  aesv_tbl_type) IS

      l_return_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
      l_overall_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

      l_api_name                  CONSTANT VARCHAR2(30)  := 'validate_tmpt_set';

      i                           NUMBER;

      l_aesv_tbl                      aesv_tbl_type := p_aesv_tbl;

  BEGIN

  --Initialize the return status

     SAVEPOINT validate_tmpt_set;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_aesv_tbl.COUNT > 0) THEN

      i := l_aesv_tbl.FIRST;

      LOOP

        validate_tmpt_set(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aesv_rec      => l_aesv_tbl(i)

                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_aesv_tbl.LAST);

          i := l_aesv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_tmpt_set;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_tmpt_set;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_tmpt_set;



  PROCEDURE create_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_rec                       IN  avlv_rec_type

    ,x_avlv_rec                       OUT NOCOPY avlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_template';

    l_avlv_rec                      avlv_rec_type := p_avlv_rec;





  BEGIN

    SAVEPOINT create_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_tmpt_set_pvt.create_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => l_avlv_rec

                          ,x_avlv_rec      => x_avlv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_avlv_rec := x_avlv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_template;



  PROCEDURE create_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_tbl                       IN  avlv_tbl_type

    ,x_avlv_tbl                       OUT NOCOPY avlv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_template';

    i                                 NUMBER;

	l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;




  BEGIN

  --Initialize the return status

    SAVEPOINT create_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing








    IF (l_avlv_tbl.COUNT > 0) THEN

      i := l_avlv_tbl.FIRST;

      LOOP

        create_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => l_avlv_tbl(i)

                          ,x_avlv_rec      => x_avlv_tbl(i)

                          );

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_avlv_tbl.LAST);

          i := l_avlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status ;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	   l_avlv_tbl := x_avlv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_template;



  PROCEDURE lock_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_rec                       IN  avlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_template';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_template;


    okl_tmpt_set_pvt.lock_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => p_avlv_rec

                          );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_template;



  PROCEDURE lock_template(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_avlv_tbl                      IN  avlv_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_template';

    i                                NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_template;


    IF (p_avlv_tbl.COUNT > 0) THEN

      i := p_avlv_tbl.FIRST;

      LOOP

        lock_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => p_avlv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;
          EXIT WHEN (i = p_avlv_tbl.LAST);

          i := p_avlv_tbl.NEXT(i);

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
      ROLLBACK TO lock_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_template;



  PROCEDURE update_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_rec                       IN  avlv_rec_type

    ,x_avlv_rec                       OUT NOCOPY avlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_template';

    l_avlv_rec                      avlv_rec_type := p_avlv_rec;

  BEGIN

    SAVEPOINT update_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;




   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_tmpt_set_pvt.update_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => l_avlv_rec

                          ,x_avlv_rec      => x_avlv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_avlv_rec := x_avlv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_template;



  PROCEDURE update_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_tbl                       IN  avlv_tbl_type

    ,x_avlv_tbl                       OUT NOCOPY avlv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_template';

    i                                 NUMBER;

    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;

   BEGIN

  --Initialize the return status

     SAVEPOINT update_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;




   -- customer pre-processing






   -- vertical industry-preprocessing




    IF (l_avlv_tbl.COUNT > 0) THEN

      i := l_avlv_tbl.FIRST;

      LOOP

        update_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => l_avlv_tbl(i)

                          ,x_avlv_rec      => x_avlv_tbl(i)

                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_avlv_tbl.LAST);

          i := l_avlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_avlv_tbl := x_avlv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing







  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_template;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_rec                       IN  avlv_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_template';

    l_avlv_rec                      avlv_rec_type := p_avlv_rec;

  BEGIN

    SAVEPOINT delete_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.delete_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => l_avlv_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;




   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','delete_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_template;



  PROCEDURE delete_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_tbl                       IN  avlv_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_template';

    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;


  BEGIN

  --Initialize the return status

   SAVEPOINT delete_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_avlv_tbl.COUNT > 0) THEN

      i := l_avlv_tbl.FIRST;

      LOOP

        delete_template(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => x_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_avlv_rec      => l_avlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_avlv_tbl.LAST);

          i := l_avlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;




   -- vertical industry-post-processing






   -- customer post-processing







  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','delete_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END delete_template;



  PROCEDURE validate_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_rec                       IN  avlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_template';

    l_avlv_rec                      avlv_rec_type := p_avlv_rec;

  BEGIN

    SAVEPOINT validate_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.validate_template(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_avlv_rec      => l_avlv_rec

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
      ROLLBACK TO validate_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_template;



  PROCEDURE validate_template(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_avlv_tbl                       IN  avlv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_template';

    i                                 NUMBER;

    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;


  BEGIN

  --Initialize the return status

     SAVEPOINT validate_template;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_avlv_tbl.COUNT > 0) THEN

      i := l_avlv_tbl.FIRST;

      LOOP

        validate_template(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_avlv_rec      => l_avlv_tbl(i)

                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_avlv_tbl.LAST);

          i := l_avlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_template;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_template;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_template;


  PROCEDURE create_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_rec                       IN  atlv_rec_type

    ,x_atlv_rec                       OUT NOCOPY atlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_tmpt_lines';

    l_atlv_rec                      atlv_rec_type := p_atlv_rec;





  BEGIN

    SAVEPOINT create_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_tmpt_set_pvt.create_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => l_atlv_rec

                          ,x_atlv_rec      => x_atlv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_atlv_rec := x_atlv_rec;

   -- vertical industry-post-processing






   -- customer post-processing





  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_tmpt_lines;



  PROCEDURE create_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_tbl                       IN  atlv_tbl_type

    ,x_atlv_tbl                       OUT NOCOPY atlv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_tmpt_lines';

    i                                 NUMBER;


    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;


  BEGIN

  --Initialize the return status

   SAVEPOINT create_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing








    IF (l_atlv_tbl.COUNT > 0) THEN

      i := l_atlv_tbl.FIRST;

      LOOP

        create_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => l_atlv_tbl(i)

                          ,x_atlv_rec      => x_atlv_tbl(i)

                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_atlv_tbl.LAST);

          i := l_atlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_Status;


       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_atlv_tbl := x_atlv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing





  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','create_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_tmpt_lines;



  PROCEDURE lock_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_rec                       IN  atlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_tmpt_lines';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_tmpt_lines;

    okl_tmpt_set_pvt.lock_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => p_atlv_rec

                          );


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_tmpt_lines;



  PROCEDURE lock_tmpt_lines(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_atlv_tbl                      IN  atlv_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_tmpt_lines';

    i                                NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_tmpt_lines;


    IF (p_atlv_tbl.COUNT > 0) THEN

      i := p_atlv_tbl.FIRST;

      LOOP

        lock_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => p_atlv_tbl(i)

                          );

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = p_atlv_tbl.LAST);

          i := p_atlv_tbl.NEXT(i);

       END LOOP;
	   -- return overall status

     END IF;

     x_return_status := l_overall_status;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_tmpt_lines;



  PROCEDURE update_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_rec                       IN  atlv_rec_type

    ,x_atlv_rec                       OUT NOCOPY atlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_tmpt_lines';

    l_atlv_rec                      atlv_rec_type := p_atlv_rec;

  BEGIN

    SAVEPOINT update_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_tmpt_set_pvt.update_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => l_atlv_rec

                          ,x_atlv_rec      => x_atlv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_atlv_rec := x_atlv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_tmpt_lines;



  PROCEDURE update_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_tbl                       IN  atlv_tbl_type

    ,x_atlv_tbl                       OUT NOCOPY atlv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_tmpt_lines';

    i                                 NUMBER;

    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;

  BEGIN

  --Initialize the return status

    SAVEPOINT update_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing




    IF (l_atlv_tbl.COUNT > 0) THEN

      i := l_atlv_tbl.FIRST;

      LOOP

        update_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => l_atlv_tbl(i)

                          ,x_atlv_rec      => x_atlv_tbl(i)

                          );

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_atlv_tbl.LAST);

          i := l_atlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


	   l_atlv_tbl := x_atlv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing








  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','update_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_tmpt_lines;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_rec                       IN  atlv_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_tmpt_lines';

    l_atlv_rec                      atlv_rec_type := p_atlv_rec;

  BEGIN

    SAVEPOINT delete_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.delete_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => l_atlv_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;




   -- vertical industry-post-processing






   -- customer post-processing





  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','delete_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_tmpt_lines;



  PROCEDURE delete_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_tbl                       IN  atlv_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_tmpt_lines';

    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;

  BEGIN

  --Initialize the return status

    SAVEPOINT delete_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing







    IF (l_atlv_tbl.COUNT > 0) THEN

      i := l_atlv_tbl.FIRST;

      LOOP

        delete_tmpt_lines(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => x_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_atlv_rec      => l_atlv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_atlv_tbl.LAST);

          i := l_atlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;




   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','delete_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_tmpt_lines;



  PROCEDURE validate_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_rec                       IN  atlv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_tmpt_lines';

    l_atlv_rec                      atlv_rec_type := p_atlv_rec;

  BEGIN

    SAVEPOINT validate_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_tmpt_set_pvt.validate_tmpt_lines(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_atlv_rec      => l_atlv_rec

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
      ROLLBACK TO validate_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_tmpt_lines;



  PROCEDURE validate_tmpt_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_atlv_tbl                       IN  atlv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_tmpt_lines';

    i                                 NUMBER;

    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;

  BEGIN

  --Initialize the return status

    SAVEPOINT validate_tmpt_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_atlv_tbl.COUNT > 0) THEN

      i := l_atlv_tbl.FIRST;

      LOOP

        validate_tmpt_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_atlv_rec      => l_atlv_tbl(i)

                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_atlv_tbl.LAST);

          i := l_atlv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



   -- vertical industry-post-processing






   -- customer post-processing







  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_tmpt_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','validate_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_tmpt_lines;

END OKL_TMPT_SET_PUB;


/
