--------------------------------------------------------
--  DDL for Package Body OKL_INDICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INDICES_PUB" AS
/* $Header: OKLPIDXB.pls 115.5 2002/12/18 12:20:35 kjinger noship $ */



  PROCEDURE create_indices(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_idxv_rec                     IN  idxv_rec_type

    ,p_ivev_tbl                     IN  ivev_tbl_type

    ,x_idxv_rec                     OUT NOCOPY idxv_rec_type

    ,x_ivev_tbl                     OUT NOCOPY ivev_tbl_type

    ) IS



    i                               NUMBER;

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;

    l_return_status                 VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;



  BEGIN

    SAVEPOINT create_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_indices_pvt.create_indices(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_idxv_rec      => l_idxv_rec

                        ,p_ivev_tbl      => l_ivev_tbl

                        ,x_idxv_rec      => x_idxv_rec

                        ,x_ivev_tbl      => x_ivev_tbl);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_idxv_rec := x_idxv_rec;
	   l_ivev_tbl := x_ivev_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','create_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_indices;



  PROCEDURE create_indices(

     p_api_version             IN  NUMBER

    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status           OUT NOCOPY VARCHAR2

    ,x_msg_count               OUT NOCOPY NUMBER

    ,x_msg_data                OUT NOCOPY VARCHAR2

    ,p_idxv_rec                IN  idxv_rec_type

    ,x_idxv_rec                OUT NOCOPY idxv_rec_type) IS

    l_return_status            VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;



  BEGIN

    SAVEPOINT create_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_indices_pvt.create_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_rec

                          ,x_idxv_rec      => x_idxv_rec

                          );



       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_idxv_rec := x_idxv_rec;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','create_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_indices;



  PROCEDURE create_indices(

     p_api_version               IN  NUMBER

    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status             OUT NOCOPY VARCHAR2

    ,x_msg_count                 OUT NOCOPY NUMBER

    ,x_msg_data                  OUT NOCOPY VARCHAR2

    ,p_idxv_tbl                  IN  idxv_tbl_type

    ,x_idxv_tbl                  OUT NOCOPY idxv_tbl_type) IS

    l_return_status              VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_indices';

    i                            NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_idxv_tbl                      idxv_tbl_type := p_idxv_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_idxv_tbl.COUNT > 0) THEN

      i := l_idxv_tbl.FIRST;

      LOOP

        okl_indices_pub.create_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_tbl(i)

                          ,x_idxv_rec      => x_idxv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_idxv_tbl.LAST);

          i := l_idxv_tbl.NEXT(i);
       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_idxv_tbl := x_idxv_tbl;


    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','create_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_indices;



  -- Object type procedure for update

  PROCEDURE update_indices(

    p_api_version           IN  NUMBER,

    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,

    x_msg_count             OUT NOCOPY NUMBER,

    x_msg_data              OUT NOCOPY VARCHAR2,

    p_idxv_rec              IN  idxv_rec_type,

    p_ivev_tbl              IN  ivev_tbl_type,

    x_idxv_rec              OUT NOCOPY idxv_rec_type,

    x_ivev_tbl              OUT NOCOPY ivev_tbl_type) IS

    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'update_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;



  BEGIN

    SAVEPOINT update_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_indices_pvt.update_indices(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => x_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_idxv_rec      => l_idxv_rec

                        ,p_ivev_tbl      => l_ivev_tbl

                        ,x_idxv_rec      => x_idxv_rec

                        ,x_ivev_tbl      => x_ivev_tbl

                        );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_idxv_rec := x_idxv_rec;
	   l_ivev_tbl := x_ivev_tbl;

   -- vertical industry-post processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','update_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_indices;



  PROCEDURE validate_indices(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_idxv_rec              IN  idxv_rec_type

    ,p_ivev_tbl              IN  ivev_tbl_type) IS



    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'validate_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;



  BEGIN

    SAVEPOINT validate_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






-- call complex entity API

    okl_indices_pvt.validate_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_rec

                          ,p_ivev_tbl      => l_ivev_tbl

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
      ROLLBACK TO validate_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','validate_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_indices;



  PROCEDURE lock_indices(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_idxv_rec              IN  idxv_rec_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_indices';





  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_indices;


    okl_indices_pvt.lock_indices(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_idxv_rec      => p_idxv_rec

                        );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','lock_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_indices;



  PROCEDURE lock_indices(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_idxv_tbl              IN  idxv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_indices';

    i                        NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_indices;

    IF (p_idxv_tbl.COUNT > 0) THEN

      i := p_idxv_tbl.FIRST;

      LOOP

        okl_indices_pub.lock_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => p_idxv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_idxv_tbl.LAST);

          i := p_idxv_tbl.NEXT(i);

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
      ROLLBACK TO lock_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_STREAM_TYPE_PUB','lock_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_indices;



  PROCEDURE update_indices(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_idxv_rec                   IN  idxv_rec_type

    ,x_idxv_rec                   OUT NOCOPY idxv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;

  BEGIN

    SAVEPOINT update_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_indices_pvt.update_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_rec

                          ,x_idxv_rec      => x_idxv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_idxv_rec := x_idxv_rec;

    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','update_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_indices;



  PROCEDURE update_indices(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_idxv_tbl                   IN  idxv_tbl_type

    ,x_idxv_tbl                   OUT NOCOPY idxv_tbl_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_indices';

    i                             NUMBER;

	l_overall_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_idxv_tbl					  idxv_tbl_type := p_idxv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT update_indices;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_idxv_tbl.COUNT > 0) THEN

      i := l_idxv_tbl.FIRST;

      LOOP

        update_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_tbl(i)

                          ,x_idxv_rec      => x_idxv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_idxv_tbl.LAST);

          i := l_idxv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_idxv_tbl := x_idxv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','update_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_indices;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_indices(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_idxv_rec              IN  idxv_rec_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;



  BEGIN

    SAVEPOINT delete_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_indices_pvt.delete_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_rec

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
      ROLLBACK TO delete_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','delete_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_indices;



  PROCEDURE delete_indices(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_idxv_tbl              IN  idxv_tbl_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_indices';

    l_overall_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_idxv_tbl					  idxv_tbl_type := p_idxv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT delete_indices;

   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_idxv_tbl.COUNT > 0) THEN

      i := l_idxv_tbl.FIRST;

      LOOP

        delete_indices(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_idxv_rec      => l_idxv_tbl(i)

                            );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

         EXIT WHEN (i = l_idxv_tbl.LAST);

         i := l_idxv_tbl.NEXT(i);

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
      ROLLBACK TO delete_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','delete_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END delete_indices;



  PROCEDURE validate_indices(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_idxv_rec                   IN  idxv_rec_type) IS

    l_return_status               VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'validate_indices';

    l_idxv_rec                      idxv_rec_type := p_idxv_rec;



  BEGIN

    SAVEPOINT validate_indices;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_indices_pvt.validate_indices(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_idxv_rec      => l_idxv_rec

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
      ROLLBACK TO validate_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','validate_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_indices;



  PROCEDURE validate_indices(

      p_api_version               IN  NUMBER,

      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

      x_return_status             OUT NOCOPY VARCHAR2,

      x_msg_count                 OUT NOCOPY NUMBER,

      x_msg_data                  OUT NOCOPY VARCHAR2,

      p_idxv_tbl                  IN  idxv_tbl_type) IS

      l_return_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

      l_api_name                  CONSTANT VARCHAR2(30)  := 'validate_indices';

      i                           NUMBER;

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_idxv_tbl					  idxv_tbl_type := p_idxv_tbl;

  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT validate_indices;

   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_idxv_tbl.COUNT > 0) THEN

      i := l_idxv_tbl.FIRST;

      LOOP

        validate_indices(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_idxv_rec      => l_idxv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_idxv_tbl.LAST);

          i := l_idxv_tbl.NEXT(i);

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
      ROLLBACK TO validate_indices;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_indices;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','validate_indices');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END validate_indices;



  PROCEDURE create_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_rec                       IN  ivev_rec_type

    ,x_ivev_rec                       OUT NOCOPY ivev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_index_values';

    l_ivev_rec                      ivev_rec_type := p_ivev_rec;

  BEGIN

    SAVEPOINT create_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_indices_pvt.create_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => l_ivev_rec

                          ,x_ivev_rec      => x_ivev_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_ivev_rec := x_ivev_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','create_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_index_values;



  PROCEDURE create_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_tbl                       IN  ivev_tbl_type

    ,x_ivev_tbl                       OUT NOCOPY ivev_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_index_values';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT create_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_ivev_tbl.COUNT > 0) THEN

      i := l_ivev_tbl.FIRST;

      LOOP

        create_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => l_ivev_tbl(i)

                          ,x_ivev_rec      => x_ivev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_ivev_tbl.LAST);

          i := l_ivev_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_ivev_tbl := x_ivev_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','create_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END create_index_values;



  PROCEDURE lock_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_rec                       IN  ivev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_index_values';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_index_values;

    okl_indices_pvt.lock_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => p_ivev_rec

                          );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','lock_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_index_values;



  PROCEDURE lock_index_values(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_ivev_tbl                      IN  ivev_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_index_values';

    i                                NUMBER;

	l_overall_status			 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_index_values;

    IF (p_ivev_tbl.COUNT > 0) THEN

      i := p_ivev_tbl.FIRST;

      LOOP

        lock_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => p_ivev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_ivev_tbl.LAST);

          i := p_ivev_tbl.NEXT(i);

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
      ROLLBACK TO lock_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','lock_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_index_values;



  PROCEDURE update_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_rec                       IN  ivev_rec_type

    ,x_ivev_rec                       OUT NOCOPY ivev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_index_values';

    l_ivev_rec                      ivev_rec_type := p_ivev_rec;

  BEGIN

    SAVEPOINT update_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_indices_pvt.update_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => l_ivev_rec

                          ,x_ivev_rec      => x_ivev_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_ivev_rec := x_ivev_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','update_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_index_values;



  PROCEDURE update_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_tbl                       IN  ivev_tbl_type

    ,x_ivev_tbl                       OUT NOCOPY ivev_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_index_values';

    i                                 NUMBER;

    l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT update_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_ivev_tbl.COUNT > 0) THEN

      i := l_ivev_tbl.FIRST;

      LOOP

        update_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => l_ivev_tbl(i)

                          ,x_ivev_rec      => x_ivev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_ivev_tbl.LAST);

          i := l_ivev_tbl.NEXT(i);

       END LOOP;
	   -- return overall status
	   l_return_status := l_overall_status;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_ivev_tbl := x_ivev_tbl;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','update_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_index_values;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_rec                       IN  ivev_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_index_values';

    l_ivev_rec                      ivev_rec_type := p_ivev_rec;

  BEGIN

    SAVEPOINT delete_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_indices_pvt.delete_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => l_ivev_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','delete_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_index_values;



  PROCEDURE delete_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_tbl                       IN  ivev_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_index_values';

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT delete_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_ivev_tbl.COUNT > 0) THEN

      i := l_ivev_tbl.FIRST;

      LOOP

        delete_index_values(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => l_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_ivev_rec      => l_ivev_tbl(i));
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_ivev_tbl.LAST);

          i := l_ivev_tbl.NEXT(i);

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
      ROLLBACK TO delete_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','delete_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_index_values;



  PROCEDURE validate_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_rec                       IN  ivev_rec_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_index_values';

    l_ivev_rec                      ivev_rec_type := p_ivev_rec;

  BEGIN

    SAVEPOINT validate_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_indices_pvt.validate_index_values(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_ivev_rec      => l_ivev_rec

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
      ROLLBACK TO validate_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','validate_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_index_values;



  PROCEDURE validate_index_values(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_ivev_tbl                       IN  ivev_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_index_values';

    i                                 NUMBER;

      l_overall_status             VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;

    l_ivev_tbl                      ivev_tbl_type := p_ivev_tbl;

  BEGIN

  --Initialize the return status
    SAVEPOINT validate_index_values;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_ivev_tbl.COUNT > 0) THEN

      i := l_ivev_tbl.FIRST;

      LOOP

        validate_index_values(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_ivev_rec      => l_ivev_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := x_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = l_ivev_tbl.LAST);

          i := l_ivev_tbl.NEXT(i);

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
      ROLLBACK TO validate_index_values;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_index_values;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INDICES_PUB','validate_index_values');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_index_values;



END OKL_INDICES_PUB;


/
