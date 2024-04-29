--------------------------------------------------------
--  DDL for Package Body OKL_ACCT_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCT_EVENT_PUB" AS
/* $Header: OKLPAETB.pls 115.11 2002/12/18 12:09:07 kjinger noship $ */



  PROCEDURE create_acct_event(

     p_api_version                  IN  NUMBER

    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                OUT NOCOPY VARCHAR2

    ,x_msg_count                    OUT NOCOPY NUMBER

    ,x_msg_data                     OUT NOCOPY VARCHAR2

    ,p_aetv_rec                     IN  aetv_rec_type

    ,p_aehv_tbl                     IN  aehv_tbl_type

    ,p_aelv_tbl                     IN  aelv_tbl_type

    ,x_aetv_rec                     OUT NOCOPY aetv_rec_type

    ,x_aehv_tbl                     OUT NOCOPY aehv_tbl_type

    ,x_aelv_tbl                     OUT NOCOPY aelv_tbl_type

    ) IS



    i                               NUMBER;

    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_acct_event';

    l_aetv_rec                      aetv_rec_type := p_aetv_rec;

    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;

    l_aelv_tbl						aelv_tbl_type := p_aelv_tbl;

  BEGIN

    SAVEPOINT create_acct_event;

    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.create_acct_event(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => x_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_aetv_rec      => l_aetv_rec

                        ,p_aehv_tbl      => l_aehv_tbl


                        ,p_aelv_tbl => l_aelv_tbl


                        ,x_aetv_rec      => x_aetv_rec

                        ,x_aehv_tbl      => x_aehv_tbl

						,x_aelv_tbl => x_aelv_tbl);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN

      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN

      RAISE OKC_API.G_EXCEPTION_ERROR;

    END IF;

	   l_aetv_rec := x_aetv_rec;
	   l_aehv_tbl := x_aehv_tbl;
	   l_aelv_tbl := x_aelv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END create_acct_event;



  PROCEDURE create_acct_event(

     p_api_version             IN  NUMBER

    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status           OUT NOCOPY VARCHAR2

    ,x_msg_count               OUT NOCOPY NUMBER

    ,x_msg_data                OUT NOCOPY VARCHAR2

    ,p_aetv_rec                IN  aetv_rec_type

    ,x_aetv_rec                OUT NOCOPY aetv_rec_type) IS

    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_acct_event';

    l_aetv_rec                      aetv_rec_type := p_aetv_rec;



  BEGIN

    SAVEPOINT create_acct_event;

    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_acct_event_pvt.create_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_rec

                          ,x_aetv_rec      => x_aetv_rec

                          );



	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aetv_rec := x_aetv_rec;

    -- vertical industry-post-processing






     -- customer post-processing






  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acct_event;



  PROCEDURE create_acct_event(

     p_api_version               IN  NUMBER

    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status             OUT NOCOPY VARCHAR2

    ,x_msg_count                 OUT NOCOPY NUMBER

    ,x_msg_data                  OUT NOCOPY VARCHAR2

    ,p_aetv_tbl                  IN  aetv_tbl_type

    ,x_aetv_tbl                  OUT NOCOPY aetv_tbl_type) IS

    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_acct_event';

    i                            NUMBER;

    l_aetv_tbl                      aetv_tbl_type := p_aetv_tbl;

    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

    SAVEPOINT create_acct_event;

    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_aetv_tbl.COUNT > 0) THEN

      i := l_aetv_tbl.FIRST;

      LOOP

        create_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_tbl(i)

                          ,x_aetv_rec      => x_aetv_tbl(i)

                          );

          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;

          EXIT WHEN (i = l_aetv_tbl.LAST);

          i := l_aetv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


	   l_aetv_tbl := x_aetv_tbl;

    -- vertical industry-post-processing






     -- customer post-processing





  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acct_event;



  -- Object type procedure for update

  PROCEDURE update_acct_event(

    p_api_version           IN  NUMBER,

    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

    x_return_status         OUT NOCOPY VARCHAR2,

    x_msg_count             OUT NOCOPY NUMBER,

    x_msg_data              OUT NOCOPY VARCHAR2,

    p_aetv_rec              IN  aetv_rec_type,

    p_aehv_tbl              IN  aehv_tbl_type,

	p_aelv_tbl				IN	aelv_tbl_type,

    x_aetv_rec              OUT NOCOPY aetv_rec_type,

    x_aehv_tbl              OUT NOCOPY aehv_tbl_type,

	x_aelv_tbl				OUT NOCOPY aelv_tbl_type) IS

    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'update_acct_event';

    l_aetv_rec                      aetv_rec_type := p_aetv_rec;

    l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;

    l_aelv_tbl                      aelv_tbl_type := p_aelv_tbl;



  BEGIN

    SAVEPOINT update_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.update_acct_event(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_aetv_rec      => l_aetv_rec

                        ,p_aehv_tbl      => l_aehv_tbl

                        ,p_aelv_tbl => l_aelv_tbl

                        ,x_aetv_rec      => x_aetv_rec

                        ,x_aehv_tbl      => x_aehv_tbl

						,x_aelv_tbl       => x_aelv_tbl

                        );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aetv_rec := x_aetv_rec;
	   l_aehv_tbl := x_aehv_tbl;
	   l_aelv_tbl := x_aelv_tbl;

   -- vertical industry-post processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_event;



  PROCEDURE validate_acct_event(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aetv_rec              IN  aetv_rec_type

    ,p_aehv_tbl              IN  aehv_tbl_type

	,p_aelv_tbl				 IN aelv_tbl_type) IS



    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name              CONSTANT VARCHAR2(30)  := 'validate_acct_event';

    l_aetv_rec                      aetv_rec_type := p_aetv_rec;

    l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;

    l_aelv_tbl                      aelv_tbl_type := p_aelv_tbl;



  BEGIN

    SAVEPOINT validate_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






-- call complex entity API

    okl_acct_event_pvt.validate_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_rec

                          ,p_aehv_tbl      => l_aehv_tbl

                          ,p_aelv_tbl => l_aelv_tbl

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
      ROLLBACK TO validate_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_event;



  PROCEDURE lock_acct_event(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aetv_rec              IN  aetv_rec_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_acct_event';


  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_acct_event;

    okl_acct_event_pvt.lock_acct_event(

                         p_api_version   => p_api_version

                        ,p_init_msg_list => p_init_msg_list

                        ,x_return_status => l_return_status

                        ,x_msg_count     => x_msg_count

                        ,x_msg_data      => x_msg_data

                        ,p_aetv_rec      => p_aetv_rec

                        );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_acct_event;



  PROCEDURE lock_acct_event(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aetv_tbl              IN  aetv_tbl_type) IS

    l_return_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'lock_acct_event';

    i                        NUMBER;

    l_overall_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_acct_event;

    IF (p_aetv_tbl.COUNT > 0) THEN

      i := p_aetv_tbl.FIRST;

      LOOP

        lock_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => p_aetv_tbl(i)

                          );
		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;

          EXIT WHEN (i = p_aetv_tbl.LAST);

          i := p_aetv_tbl.NEXT(i);

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
      ROLLBACK TO lock_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_acct_event;



  PROCEDURE update_acct_event(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_aetv_rec                   IN  aetv_rec_type

    ,x_aetv_rec                   OUT NOCOPY aetv_rec_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_acct_event';

    l_aetv_rec                      aetv_rec_type := p_aetv_rec;



  BEGIN

    SAVEPOINT update_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_acct_event_pvt.update_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_rec

                          ,x_aetv_rec      => x_aetv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aetv_rec := x_aetv_rec;

    -- vertical industry-post-processing






    -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_event;



  PROCEDURE update_acct_event(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_aetv_tbl                   IN  aetv_tbl_type

    ,x_aetv_tbl                   OUT NOCOPY aetv_tbl_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_acct_event';

    i                             NUMBER;

    l_aetv_tbl                      aetv_tbl_type := p_aetv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

  --Initialize the return status

    SAVEPOINT update_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_aetv_tbl.COUNT > 0) THEN

      i := l_aetv_tbl.FIRST;

      LOOP

        update_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_tbl(i)

                          ,x_aetv_rec      => x_aetv_tbl(i)

                          );


      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
      END IF;

          EXIT WHEN (i = l_aetv_tbl.LAST);

          i := l_aetv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_Status;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	   l_aetv_tbl := x_aetv_tbl;

    -- vertical industry-post-processing






    -- customer post-processing




  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_event;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_acct_event(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aetv_rec              IN  aetv_rec_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_acct_event';



    l_aetv_rec                      aetv_rec_type := p_aetv_rec;



  BEGIN

    SAVEPOINT delete_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_acct_event_pvt.delete_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_rec

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
      ROLLBACK TO delete_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','delete_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acct_event;



  PROCEDURE delete_acct_event(

     p_api_version           IN  NUMBER

    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status         OUT NOCOPY VARCHAR2

    ,x_msg_count             OUT NOCOPY NUMBER

    ,x_msg_data              OUT NOCOPY VARCHAR2

    ,p_aetv_tbl              IN  aetv_tbl_type) IS

    i                        NUMBER :=0;

    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_acct_event';

    l_aetv_tbl                      aetv_tbl_type := p_aetv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    --Initialize the return status

     SAVEPOINT delete_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;


   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_aetv_tbl.COUNT > 0) THEN

      i := l_aetv_tbl.FIRST;

      LOOP

        delete_acct_event(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => x_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_aetv_rec      => l_aetv_tbl(i)

                            );

          IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;


         EXIT WHEN (i = l_aetv_tbl.LAST);

         i := l_aetv_tbl.NEXT(i);

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
      ROLLBACK TO delete_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','delete_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END delete_acct_event;



  PROCEDURE validate_acct_event(

     p_api_version                IN  NUMBER

    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status              OUT NOCOPY VARCHAR2

    ,x_msg_count                  OUT NOCOPY NUMBER

    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_aetv_rec                   IN  aetv_rec_type) IS

    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                    CONSTANT VARCHAR2(30)  := 'validate_acct_event';

    l_aetv_rec                      aetv_rec_type := p_aetv_rec;



  BEGIN

    SAVEPOINT validate_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.validate_acct_event(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_aetv_rec      => l_aetv_rec

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
      ROLLBACK TO validate_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_event;



  PROCEDURE validate_acct_event(

      p_api_version               IN  NUMBER,

      p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,

      x_return_status             OUT NOCOPY VARCHAR2,

      x_msg_count                 OUT NOCOPY NUMBER,

      x_msg_data                  OUT NOCOPY VARCHAR2,

      p_aetv_tbl                  IN  aetv_tbl_type) IS

      l_return_status             VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

      l_api_name                  CONSTANT VARCHAR2(30)  := 'validate_acct_event';

      i                           NUMBER;

	  l_aetv_tbl                      aetv_tbl_type := p_aetv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

  --Initialize the return status

     SAVEPOINT validate_acct_event;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_aetv_tbl.COUNT > 0) THEN

      i := l_aetv_tbl.FIRST;

      LOOP

        validate_acct_event(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aetv_rec      => l_aetv_tbl(i)

                          );

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aetv_tbl.LAST);

          i := l_aetv_tbl.NEXT(i);

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
      ROLLBACK TO validate_acct_event;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_event;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_event');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_event;



  PROCEDURE create_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_rec                       IN  aehv_rec_type

    ,x_aehv_rec                       OUT NOCOPY aehv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_acct_header';

    l_aehv_rec                      aehv_rec_type := p_aehv_rec;





  BEGIN

    SAVEPOINT create_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_acct_event_pvt.create_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => l_aehv_rec

                          ,x_aehv_rec      => x_aehv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aehv_rec := x_aehv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acct_header;



  PROCEDURE create_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_tbl                       IN  aehv_tbl_type

    ,x_aehv_tbl                       OUT NOCOPY aehv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_acct_header';

    i                                 NUMBER;

    l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

  --Initialize the return status

     SAVEPOINT create_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_aehv_tbl.COUNT > 0) THEN

      i := l_aehv_tbl.FIRST;

      LOOP

        create_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => l_aehv_tbl(i)

                          ,x_aehv_rec      => x_aehv_tbl(i)

                          );

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aehv_tbl.LAST);

          i := l_aehv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aehv_tbl := x_aehv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing




  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acct_header;



  PROCEDURE lock_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_rec                       IN  aehv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_acct_header';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_acct_header;


    okl_acct_event_pvt.lock_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => p_aehv_rec

                          );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_acct_header;



  PROCEDURE lock_acct_header(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_aehv_tbl                      IN  aehv_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_acct_header';

    i                                NUMBER;

    l_overall_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_acct_header;

    IF (p_aehv_tbl.COUNT > 0) THEN

      i := p_aehv_tbl.FIRST;

      LOOP

        lock_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => p_aehv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;
          EXIT WHEN (i = p_aehv_tbl.LAST);

          i := p_aehv_tbl.NEXT(i);

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
      ROLLBACK TO lock_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_acct_header;



  PROCEDURE update_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_rec                       IN  aehv_rec_type

    ,x_aehv_rec                       OUT NOCOPY aehv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_header';

    l_aehv_rec                      aehv_rec_type := p_aehv_rec;

  BEGIN

    SAVEPOINT update_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_acct_event_pvt.update_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => l_aehv_rec

                          ,x_aehv_rec      => x_aehv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aehv_rec := x_aehv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_header;



  PROCEDURE update_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_tbl                       IN  aehv_tbl_type

    ,x_aehv_tbl                       OUT NOCOPY aehv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_header';

    i                                 NUMBER;

    l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;



  BEGIN

  --Initialize the return status

     SAVEPOINT update_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing




    IF (l_aehv_tbl.COUNT > 0) THEN

      i := l_aehv_tbl.FIRST;

      LOOP

        update_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => l_aehv_tbl(i)

                          ,x_aehv_rec      => x_aehv_tbl(i)

                          );

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aehv_tbl.LAST);

          i := l_aehv_tbl.NEXT(i);

       END LOOP;

     END IF;

      x_return_status := l_overall_status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aehv_tbl := x_aehv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing





  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_header;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_rec                       IN  aehv_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acct_header';

    l_aehv_rec                      aehv_rec_type := p_aehv_rec;

  BEGIN

    SAVEPOINT delete_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.delete_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => l_aehv_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','delete_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acct_header;



  PROCEDURE delete_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_tbl                       IN  aehv_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acct_header';

	l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status

     SAVEPOINT delete_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing







    IF (l_aehv_tbl.COUNT > 0) THEN

      i := l_aehv_tbl.FIRST;

      LOOP

        delete_acct_header(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => x_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_aehv_rec      => l_aehv_tbl(i));

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aehv_tbl.LAST);

          i := l_aehv_tbl.NEXT(i);

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
      ROLLBACK TO delete_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','delete_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acct_header;



  PROCEDURE validate_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_rec                       IN  aehv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_acct_header';

    l_aehv_rec                      aehv_rec_type := p_aehv_rec;

  BEGIN

    SAVEPOINT validate_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.validate_acct_header(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_aehv_rec      => l_aehv_rec

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
      ROLLBACK TO validate_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_header;



  PROCEDURE validate_acct_header(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aehv_tbl                       IN  aehv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_acct_header';

    i                                 NUMBER;

    l_aehv_tbl                      aehv_tbl_type := p_aehv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status


    SAVEPOINT validate_acct_header;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing







    IF (l_aehv_tbl.COUNT > 0) THEN

      i := l_aehv_tbl.FIRST;

      LOOP

        validate_acct_header(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aehv_rec      => l_aehv_tbl(i)

                          );
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;



          EXIT WHEN (i = l_aehv_tbl.LAST);

          i := l_aehv_tbl.NEXT(i);

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
      ROLLBACK TO validate_acct_header;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_header');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_header;


  PROCEDURE create_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_rec                       IN  aelv_rec_type

    ,x_aelv_rec                       OUT NOCOPY aelv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_acct_lines';

    l_aelv_rec                      aelv_rec_type := p_aelv_rec;





  BEGIN

    SAVEPOINT create_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;




   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API





    okl_acct_event_pvt.create_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => l_aelv_rec

                          ,x_aelv_rec      => x_aelv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aelv_rec := x_aelv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acct_lines;



  PROCEDURE create_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_tbl                       IN  aelv_tbl_type

    ,x_aelv_tbl                       OUT NOCOPY aelv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_acct_lines';

    i                                 NUMBER;

    l_aelv_tbl						aelv_tbl_type := p_aelv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

  --Initialize the return status

     SAVEPOINT create_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;




   -- customer pre-processing






   -- vertical industry-preprocessing







    IF (l_aelv_tbl.COUNT > 0) THEN

      i := l_aelv_tbl.FIRST;

      LOOP

        create_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => l_aelv_tbl(i)

                          ,x_aelv_rec      => x_aelv_tbl(i)

                          );
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aelv_tbl.LAST);

          i := l_aelv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

	   l_aelv_tbl := x_aelv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing







  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','create_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END create_acct_lines;



  PROCEDURE lock_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_rec                       IN  aelv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'lock_acct_lines';

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_acct_header;

    okl_acct_event_pvt.lock_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => p_aelv_rec

                          );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_acct_lines;



  PROCEDURE lock_acct_lines(

     p_api_version                   IN  NUMBER

    ,p_init_msg_list                 IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                 OUT NOCOPY VARCHAR2

    ,x_msg_count                     OUT NOCOPY NUMBER

    ,x_msg_data                      OUT NOCOPY VARCHAR2

    ,p_aelv_tbl                      IN  aelv_tbl_type) IS

    l_return_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                       CONSTANT VARCHAR2(30)  := 'lock_acct_lines';

    i                                NUMBER;

    l_overall_status          VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;
	SAVEPOINT lock_acct_lines;

    IF (p_aelv_tbl.COUNT > 0) THEN

      i := p_aelv_tbl.FIRST;

      LOOP

        lock_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => p_aelv_tbl(i)

                          );

		  -- store the highest degree of error
		  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			 	l_overall_status := l_return_status;
			END IF;
		  END IF;
          EXIT WHEN (i = p_aelv_tbl.LAST);

          i := p_aelv_tbl.NEXT(i);

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
      ROLLBACK TO lock_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TMPT_SET_PUB','lock_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lock_acct_lines;



  PROCEDURE update_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_rec                       IN  aelv_rec_type

    ,x_aelv_rec                       OUT NOCOPY aelv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_lines';

    l_aelv_rec                      aelv_rec_type := p_aelv_rec;

  BEGIN

    SAVEPOINT update_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API

    okl_acct_event_pvt.update_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => l_aelv_rec

                          ,x_aelv_rec      => x_aelv_rec

                          );

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aelv_rec := x_aelv_rec;

   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_lines;



  PROCEDURE update_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_tbl                       IN  aelv_tbl_type

    ,x_aelv_tbl                       OUT NOCOPY aelv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_acct_lines';

    i                                 NUMBER;

    l_aelv_tbl						aelv_tbl_type := p_aelv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

  --Initialize the return status
    SAVEPOINT update_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






    IF (l_aelv_tbl.COUNT > 0) THEN

      i := l_aelv_tbl.FIRST;

      LOOP

        update_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => l_aelv_tbl(i)

                          ,x_aelv_rec      => x_aelv_tbl(i)

                          );

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aelv_tbl.LAST);

          i := l_aelv_tbl.NEXT(i);

       END LOOP;

     END IF;

     x_return_status := l_overall_status;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	   l_aelv_tbl := x_aelv_tbl;

   -- vertical industry-post-processing






   -- customer post-processing








  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','update_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END update_acct_lines;



       --Put custom code for cascade delete by developer

  PROCEDURE delete_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_rec                       IN  aelv_rec_type) IS

    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acct_lines';

    l_aelv_rec                      aelv_rec_type := p_aelv_rec;

  BEGIN

    SAVEPOINT delete_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.delete_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => l_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => l_aelv_rec);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



   -- vertical industry-post-processing






   -- customer post-processing






  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','delete_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acct_lines;



  PROCEDURE delete_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_tbl                       IN  aelv_tbl_type) IS



    i                                 NUMBER :=0;

    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_acct_lines';

	l_aelv_tbl						aelv_tbl_type := p_aelv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

  --Initialize the return status

     SAVEPOINT delete_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing







    IF (l_aelv_tbl.COUNT > 0) THEN

      i := l_aelv_tbl.FIRST;

      LOOP

        delete_acct_lines(

                                  p_api_version   => p_api_version

                                 ,p_init_msg_list => p_init_msg_list

                                 ,x_return_status => x_return_status

                                 ,x_msg_count     => x_msg_count

                                 ,x_msg_data      => x_msg_data

                                 ,p_aelv_rec      => l_aelv_tbl(i));

      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aelv_tbl.LAST);

          i := l_aelv_tbl.NEXT(i);

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
      ROLLBACK TO delete_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','delete_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END delete_acct_lines;



  PROCEDURE validate_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_rec                       IN  aelv_rec_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_acct_lines';

    l_aelv_rec                      aelv_rec_type := p_aelv_rec;

  BEGIN

    SAVEPOINT validate_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing






   -- call complex entity API



    okl_acct_event_pvt.validate_acct_lines(

                             p_api_version   => p_api_version

                            ,p_init_msg_list => p_init_msg_list

                            ,x_return_status => l_return_status

                            ,x_msg_count     => x_msg_count

                            ,x_msg_data      => x_msg_data

                            ,p_aelv_rec      => l_aelv_rec

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
      ROLLBACK TO validate_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_lines;



  PROCEDURE validate_acct_lines(

     p_api_version                    IN  NUMBER

    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

    ,x_return_status                  OUT NOCOPY VARCHAR2

    ,x_msg_count                      OUT NOCOPY NUMBER

    ,x_msg_data                       OUT NOCOPY VARCHAR2

    ,p_aelv_tbl                       IN  aelv_tbl_type) IS

    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;

    l_api_name                        CONSTANT VARCHAR2(30)  := 'validate_acct_lines';

    i                                 NUMBER;

    l_aelv_tbl						aelv_tbl_type := p_aelv_tbl;
    l_overall_status            VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

  --Initialize the return status

     SAVEPOINT validate_acct_lines;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;



   -- customer pre-processing






   -- vertical industry-preprocessing





    IF (l_aelv_tbl.COUNT > 0) THEN

      i := l_aelv_tbl.FIRST;

      LOOP

        validate_acct_lines(

                           p_api_version   => p_api_version

                          ,p_init_msg_list => p_init_msg_list

                          ,x_return_status => x_return_status

                          ,x_msg_count     => x_msg_count

                          ,x_msg_data      => x_msg_data

                          ,p_aelv_rec      => l_aelv_tbl(i)

                          );
      IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
          END IF;

          EXIT WHEN (i = l_aelv_tbl.LAST);

          i := l_aelv_tbl.NEXT(i);

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
      ROLLBACK TO validate_acct_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_acct_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCT_EVENT_PUB','validate_acct_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_acct_lines;





END OKL_ACCT_EVENT_PUB;


/
